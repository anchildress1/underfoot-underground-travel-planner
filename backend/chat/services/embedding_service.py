"""Vector embedding service for semantic search.

BREAKING CHANGES EXPECTED - Project in Beta
=============================================
This service is under active development with NO backwards compatibility guarantees.
- Function signatures may change without notice
- Error handling behavior will evolve
- Database schema may require migrations
- All exceptions are raised (no silent failures)

See AGENTS.md for project philosophy on breaking changes.
"""

import json
import re
from functools import lru_cache
from typing import Any

from openai import OpenAI

from chat.config.settings import get_settings
from chat.services.supabase_service import SupabaseService
from chat.utils.errors import UnderfootError
from chat.utils.logger import get_logger

logger = get_logger(__name__)

MAX_TEXT_LENGTH = 8000  # Conservative limit; ada-002 token budget ~8191 tokens (~32k chars)


class EmbeddingError(UnderfootError):
    """Embedding-related errors.

    Raised for:
    - OpenAI API failures (auth, rate limits, network)
    - pgvector function not available
    - Invalid metadata or dimension mismatches
    - Database storage failures
    """

    pass


@lru_cache(maxsize=1)
def get_openai_client() -> OpenAI:
    """Get cached OpenAI client."""
    settings = get_settings()
    return OpenAI(api_key=settings.openai_api_key)


class EmbeddingService:
    """Service for vector embeddings and similarity search.

    Singleton service that manages OpenAI embeddings and pgvector similarity search.
    Uses text-embedding-ada-002 model (1536 dimensions).

    CRITICAL: embedding_dimensions=1536 is HARD-CODED in:
    - OpenAI ada-002 model output
    - pgvector column: places_embeddings.embedding vector(1536)
    - Database migration: 20251101000001_places_embeddings.sql

    Changing models (e.g., text-embedding-3-small) requires:
    1. ALTER TABLE places_embeddings ALTER COLUMN embedding TYPE vector(NEW_DIM)
    2. Re-generate ALL embeddings (no dimension mismatch allowed)
    3. Rebuild ivfflat index

    Beta Status: This service has NO backwards compatibility.
    All methods raise exceptions on failure (no silent False/[] returns).
    """

    _instance = None

    def __new__(cls) -> "EmbeddingService":
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self) -> None:
        if hasattr(self, "_initialized"):
            return

        self.openai_client = get_openai_client()
        self.supabase = SupabaseService()
        self.embedding_model = "text-embedding-ada-002"  # Hard-coded: matches database column type
        self.embedding_dimensions = (
            1536  # Hard-coded: ada-002 output; changing requires DB migration
        )

        self._initialized = True

    def _ensure_pgvector_ready(self) -> None:
        """Lazy validation of pgvector on first use (not in __init__).

        Validates that:
        - pgvector extension is installed
        - search_places_by_similarity() RPC function exists
        - Supabase connection is working

        Raises:
            EmbeddingError: If pgvector is not available or RPC function is missing

        Note: Validation happens on first real use to avoid:
        - Test collection failures
        - Unnecessary RPC calls during fixture setup
        - CI/CD failures without local Supabase
        """
        if hasattr(self, "_pgvector_validated"):
            return

        try:
            dummy_embedding = [0.0] * self.embedding_dimensions
            self.supabase.client.rpc(
                "app_embeddings.search_places_by_similarity",
                {
                    "query_embedding": dummy_embedding,
                    "match_threshold": 0.9999,
                    "match_count": 1,
                },
            ).execute()

            logger.info("embedding.pgvector_validated", function="search_places_by_similarity")
            self._pgvector_validated = True

        except Exception as e:
            logger.error(
                "pgvector.validation_failed",
                error=str(e),
                function="search_places_by_similarity",
                exc_info=True,
            )
            raise EmbeddingError(
                "pgvector extension or search_places_by_similarity() function not available. "
                "Ensure migrations have been applied. "
                "See supabase/MIGRATION_NOTES.md for setup steps."
            ) from e

    def _validate_source_id(self, source: str, source_id: str) -> None:
        """Validate source_id format matches expected pattern for source type.

        Args:
            source: Source type (serp, reddit, eventbrite)
            source_id: ID to validate

        Raises:
            ValueError: If source_id format doesn't match source expectations
        """
        if source == "reddit" and not re.match(r"^[a-z0-9_]+$", source_id):
            raise ValueError(
                f"Invalid Reddit source_id '{source_id}'. Expected alphanumeric + underscore."
            )
        elif source == "eventbrite" and not source_id.isdigit():
            raise ValueError(
                f"Invalid Eventbrite source_id '{source_id}'. Expected numeric event ID."
            )
        elif source == "serp" and len(source_id) < 8:
            raise ValueError(
                f"Invalid SERP source_id '{source_id}'. Expected URL hash or meaningful ID (≥8 chars)."
            )

    def _validate_metadata(self, metadata: dict[str, Any]) -> None:
        """Validate metadata is non-empty, has required fields, and is JSON-serializable.

        Args:
            metadata: Metadata dictionary to validate

        Raises:
            EmbeddingError: If metadata is invalid

        Note: Requires 'name' field at minimum for searchability.
        Name is validated for non-empty content after whitespace normalization.
        """
        if not metadata:
            raise EmbeddingError("Metadata must not be empty. At minimum, provide {'name': '...'}.")

        if "name" not in metadata or not str(metadata["name"]).strip():
            raise EmbeddingError(
                "Metadata must include 'name' field with non-empty value "
                "(after whitespace normalization)."
            )

        try:
            json.dumps(metadata)
        except (TypeError, ValueError) as e:
            logger.error(
                "metadata.validation_failed",
                error=str(e),
                metadata_keys=list(metadata.keys()),
            )
            raise EmbeddingError(
                f"Metadata must be JSON-serializable. Invalid keys: {list(metadata.keys())}. "
                f"Common issues: datetime objects, custom classes. Error: {e}"
            ) from e

    def generate_embedding(self, text: str) -> list[float]:
        """Generate embedding vector for text.

        Args:
            text: Text to embed (non-empty, ≤8000 chars after whitespace normalization)

        Returns:
            Embedding vector (1536 dimensions for ada-002)
            MUST match self.embedding_dimensions and places_embeddings.embedding column type

        Raises:
            ValueError: If text is empty or too long
            EmbeddingError: If OpenAI API call fails or dimension mismatch

        Note: text.strip() normalizes whitespace BEFORE length validation and embedding.
        OpenAI ada-002 token limit is ~8191 tokens (~32k chars), but shorter
        text produces better semantic embeddings.
        """
        self._ensure_pgvector_ready()

        if not text or not text.strip():
            raise ValueError("Text must be non-empty for embedding generation")

        text = text.strip()

        if len(text) > MAX_TEXT_LENGTH:
            raise ValueError(
                f"Text too long ({len(text)} chars). Maximum {MAX_TEXT_LENGTH} chars. "
                "Consider summarizing or splitting the text."
            )

        try:
            response = self.openai_client.embeddings.create(model=self.embedding_model, input=text)

            embedding = response.data[0].embedding

            if len(embedding) != self.embedding_dimensions:
                raise EmbeddingError(
                    f"Dimension mismatch: Expected {self.embedding_dimensions}, "
                    f"got {len(embedding)}. Model may have changed."
                )

            logger.info(
                "embedding.generated",
                text_length=len(text),
                dimensions=len(embedding),
                model=self.embedding_model,
            )

            return embedding

        except ValueError:
            raise
        except Exception as e:
            logger.error("embedding.generate_error", error=str(e), exc_info=True)
            raise EmbeddingError(
                f"Failed to generate embedding: {str(e)}. "
                "Check OpenAI API key, rate limits, and network connectivity."
            ) from e

    def store_place_embedding(
        self,
        source: str,
        source_id: str,
        text: str,
        metadata: dict[str, Any],
    ) -> None:
        """Generate and store place embedding.

        Args:
            source: Source type (serp, reddit, eventbrite)
            source_id: Unique ID from source (format validated per source type)
            text: Text to embed (whitespace normalized via strip() before embedding)
            metadata: Place metadata (MUST include 'name' with non-whitespace content)

        Raises:
            ValueError: If source/source_id/text/metadata invalid
            EmbeddingError: If embedding generation or storage fails

        Example:
            >>> service.store_place_embedding(
            ...     source="reddit",
            ...     source_id="abc123",
            ...     text="Secret Cave - Hidden underground cavern",
            ...     metadata={"name": "Secret Cave", "location": "Pikeville, KY"}
            ... )
        """
        valid_sources = {"serp", "reddit", "eventbrite"}
        if source not in valid_sources:
            raise ValueError(f"Invalid source '{source}'. Must be one of {valid_sources}")

        if not source_id or not source_id.strip():
            raise ValueError("source_id must be non-empty")

        source_id = source_id.strip()
        self._validate_source_id(source, source_id)
        self._validate_metadata(metadata)

        embedding = self.generate_embedding(text)

        data = {
            "source": source,
            "source_id": source_id,
            "embedding": embedding,
            "metadata": metadata,
        }

        try:
            self.supabase.client.table("app_embeddings.places_embeddings").upsert(data).execute()  # type: ignore[arg-type]

            logger.info(
                "embedding.stored",
                source=source,
                source_id=source_id,
                metadata_keys=list(metadata.keys()),
            )

        except Exception as e:
            logger.error("embedding.store_error", error=str(e), exc_info=True)
            raise EmbeddingError(
                f"Failed to store embedding: {str(e)}. "
                "Check Supabase connection, RLS policies, and table schema."
            ) from e

    def similarity_search(
        self,
        query_text: str,
        limit: int = 10,
        similarity_threshold: float = 0.7,
    ) -> list[dict[str, Any]]:
        """Search for similar places using vector similarity.

        Args:
            query_text: Search query (non-empty, whitespace-normalized)
            limit: Maximum results to return (1-100)
            similarity_threshold: Minimum similarity score (0-1, cosine similarity)

        Returns:
            List of matching places with metadata and similarity scores.
            Empty list means "no matches above threshold".

        Raises:
            ValueError: If parameters are invalid
            EmbeddingError: If search fails

        Example:
            >>> results = service.similarity_search("underground caves", limit=5, threshold=0.8)
            >>> for r in results:
            ...     print(f"{r['metadata']['name']}: {r['similarity']:.2f}")
        """
        self._ensure_pgvector_ready()

        if not query_text or not query_text.strip():
            raise ValueError("query_text must be non-empty")

        if not 1 <= limit <= 100:
            raise ValueError(f"limit must be between 1 and 100, got {limit}")

        if not 0 <= similarity_threshold <= 1:
            raise ValueError(
                f"similarity_threshold must be between 0 and 1, got {similarity_threshold}"
            )

        try:
            query_embedding = self.generate_embedding(query_text)

            response = self.supabase.client.rpc(
                "app_embeddings.search_places_by_similarity",
                {
                    "query_embedding": query_embedding,
                    "match_threshold": similarity_threshold,
                    "match_count": limit,
                },
            ).execute()

            results = response.data or []

            logger.info(
                "embedding.search",
                query_length=len(query_text),
                results_count=len(results),  # type: ignore[arg-type]
                threshold=similarity_threshold,
            )

            return results  # type: ignore[return-value]

        except ValueError:
            raise
        except Exception as e:
            logger.error("embedding.search_error", error=str(e), exc_info=True)
            raise EmbeddingError(
                f"Similarity search failed: {str(e)}. "
                "Check pgvector availability, RPC function exists, and network connectivity."
            ) from e


@lru_cache(maxsize=1)
def get_embedding_service() -> EmbeddingService:
    """Get cached EmbeddingService singleton instance.

    Returns:
        Singleton EmbeddingService instance

    Raises:
        EmbeddingError: If pgvector validation fails on first use

    Note: pgvector validation is LAZY (happens on first real use, not here).
    This prevents test collection failures and unnecessary RPC calls.
    """
    return EmbeddingService()
