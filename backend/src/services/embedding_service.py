"""Vector embedding service for semantic search."""

from functools import lru_cache
from typing import Any

from openai import OpenAI

from src.config.settings import get_settings
from src.services.supabase_service import SupabaseService
from src.utils.logger import get_logger

logger = get_logger(__name__)


@lru_cache(maxsize=1)
def get_openai_client() -> OpenAI:
    """Get cached OpenAI client."""
    settings = get_settings()
    return OpenAI(api_key=settings.openai_api_key)


class EmbeddingService:
    """Service for vector embeddings and similarity search."""

    _instance = None

    def __new__(cls) -> "EmbeddingService":
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self) -> None:
        self.openai_client = get_openai_client()
        self.supabase = SupabaseService()
        self.embedding_model = "text-embedding-ada-002"
        self.embedding_dimensions = 1536

    def generate_embedding(self, text: str) -> list[float]:
        """Generate embedding vector for text.

        Args:
            text: Text to embed

        Returns:
            Embedding vector

        Raises:
            Exception: If OpenAI API call fails
        """
        try:
            response = self.openai_client.embeddings.create(
                model=self.embedding_model, input=text
            )

            embedding = response.data[0].embedding

            logger.info(
                "embedding.generated",
                text_length=len(text),
                dimensions=len(embedding),
            )

            return embedding

        except Exception as e:
            logger.error("embedding.generate_error", error=str(e), exc_info=True)
            raise

    def store_place_embedding(
        self,
        source: str,
        source_id: str,
        text: str,
        metadata: dict[str, Any],
    ) -> bool:
        """Generate and store place embedding.

        Args:
            source: Source type (serp, reddit, eventbrite)
            source_id: Unique ID from source
            text: Text to embed (name + description)
            metadata: Additional metadata (name, location, url, etc.)

        Returns:
            True if stored successfully
        """
        try:
            embedding = self.generate_embedding(text)

            data = {
                "source": source,
                "source_id": source_id,
                "embedding": embedding,
                "metadata": metadata,
            }

            _response = self.supabase.client.table("places_embeddings").upsert(data).execute()

            logger.info(
                "embedding.stored",
                source=source,
                source_id=source_id,
                metadata_keys=list(metadata.keys()),
            )

            return True

        except Exception as e:
            logger.error("embedding.store_error", error=str(e), exc_info=True)
            return False

    def similarity_search(
        self,
        query_text: str,
        limit: int = 10,
        similarity_threshold: float = 0.7,
    ) -> list[dict[str, Any]]:
        """Search for similar places using vector similarity.

        Args:
            query_text: Search query
            limit: Maximum results to return
            similarity_threshold: Minimum similarity score (0-1)

        Returns:
            List of similar places with metadata and scores
        """
        try:
            query_embedding = self.generate_embedding(query_text)

            response = (
                self.supabase.client.rpc(
                    "search_places_by_similarity",
                    {
                        "query_embedding": query_embedding,
                        "match_threshold": similarity_threshold,
                        "match_count": limit,
                    },
                )
                .execute()
            )

            results = response.data or []

            logger.info(
                "embedding.search",
                query_length=len(query_text),
                results_count=len(results),
                threshold=similarity_threshold,
            )

            return results

        except Exception as e:
            logger.error("embedding.search_error", error=str(e), exc_info=True)
            return []


embedding_service = EmbeddingService()
