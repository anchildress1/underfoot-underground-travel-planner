"""Unit tests for Embedding service."""

from unittest.mock import MagicMock, patch

import pytest

from src.services.embedding_service import EmbeddingError, EmbeddingService


@pytest.fixture
def embedding_service():
    """Create fresh EmbeddingService instance with mocked dependencies."""
    EmbeddingService._instance = None

    with (
        patch("src.services.embedding_service.get_openai_client") as mock_openai,
        patch("src.services.embedding_service.SupabaseService") as mock_supabase_cls,
    ):
        mock_supabase = MagicMock()
        mock_supabase.client.rpc.return_value.execute.return_value = MagicMock(data=[])
        mock_supabase_cls.return_value = mock_supabase

        service = EmbeddingService()
        service.openai_client = mock_openai.return_value
        service.supabase = mock_supabase

        yield service

    EmbeddingService._instance = None
    if hasattr(EmbeddingService, "_pgvector_validated"):
        del EmbeddingService._pgvector_validated


def test_singleton_pattern(embedding_service):
    """Test singleton pattern prevents multiple instances."""
    service2 = EmbeddingService()
    assert service2 is embedding_service


def test_initialization_only_once(embedding_service):
    """Test __init__ only runs once even with multiple calls."""
    initial_client = embedding_service.openai_client

    EmbeddingService()

    assert embedding_service.openai_client is initial_client


def test_pgvector_validation_lazy(embedding_service):
    """Test pgvector validation is lazy (not called during __init__)."""
    assert not hasattr(embedding_service, "_pgvector_validated")

    mock_response = MagicMock()
    mock_response.data = [MagicMock(embedding=[0.1] * 1536)]
    embedding_service.openai_client.embeddings.create.return_value = mock_response

    embedding_service.generate_embedding("test")

    assert embedding_service._pgvector_validated is True


def test_pgvector_validation_failure(embedding_service):
    """Test initialization fails when pgvector is unavailable."""
    embedding_service.supabase.client.rpc.return_value.execute.side_effect = Exception(
        "function app_embeddings.search_places_by_similarity does not exist"
    )

    with pytest.raises(EmbeddingError, match="pgvector extension"):
        embedding_service._ensure_pgvector_ready()


def test_generate_embedding_success(embedding_service):
    """Test successful embedding generation."""
    mock_response = MagicMock()
    mock_response.data = [MagicMock(embedding=[0.1] * 1536)]

    embedding_service.openai_client.embeddings.create.return_value = mock_response

    result = embedding_service.generate_embedding("test text")

    assert len(result) == 1536
    assert result[0] == 0.1
    embedding_service.openai_client.embeddings.create.assert_called_once()


def test_generate_embedding_empty_text(embedding_service):
    """Test embedding generation fails with empty text."""
    with pytest.raises(ValueError, match="non-empty"):
        embedding_service.generate_embedding("")

    with pytest.raises(ValueError, match="non-empty"):
        embedding_service.generate_embedding("   ")


def test_generate_embedding_text_too_long(embedding_service):
    """Test embedding generation fails with text exceeding limit."""
    long_text = "a" * 8001

    with pytest.raises(ValueError, match="Text too long"):
        embedding_service.generate_embedding(long_text)


def test_generate_embedding_wrong_dimensions(embedding_service):
    """Test embedding generation fails with wrong dimensions."""
    mock_response = MagicMock()
    mock_response.data = [MagicMock(embedding=[0.1] * 512)]

    embedding_service.openai_client.embeddings.create.return_value = mock_response

    with pytest.raises(EmbeddingError, match="Dimension mismatch"):
        embedding_service.generate_embedding("test text")


def test_generate_embedding_api_error(embedding_service):
    """Test embedding generation handles OpenAI API errors."""
    embedding_service.openai_client.embeddings.create.side_effect = Exception("API error")

    with pytest.raises(EmbeddingError, match="Failed to generate embedding"):
        embedding_service.generate_embedding("test text")


def test_generate_embedding_rate_limit(embedding_service):
    """Test embedding generation handles rate limit errors."""
    from openai import RateLimitError

    embedding_service.openai_client.embeddings.create.side_effect = RateLimitError(
        "Rate limit exceeded", response=MagicMock(status_code=429), body=None
    )

    with pytest.raises(EmbeddingError, match="Failed to generate embedding"):
        embedding_service.generate_embedding("test text")


def test_generate_embedding_auth_error(embedding_service):
    """Test embedding generation handles authentication errors."""
    from openai import AuthenticationError

    embedding_service.openai_client.embeddings.create.side_effect = AuthenticationError(
        "Invalid API key", response=MagicMock(status_code=401), body=None
    )

    with pytest.raises(EmbeddingError, match="Failed to generate embedding"):
        embedding_service.generate_embedding("test text")


def test_generate_embedding_unicode(embedding_service):
    """Test embedding generation handles Unicode and special characters."""
    mock_response = MagicMock()
    mock_response.data = [MagicMock(embedding=[0.1] * 1536)]

    embedding_service.openai_client.embeddings.create.return_value = mock_response

    text = "🏞️ Underground Café — special chars: <>&"
    result = embedding_service.generate_embedding(text)

    assert len(result) == 1536
    call_args = embedding_service.openai_client.embeddings.create.call_args
    assert call_args[1]["input"] == text.strip()


def test_validate_metadata_success(embedding_service):
    """Test metadata validation passes for valid data."""
    valid_metadata = {
        "name": "Test Place",
        "location": "Pikeville, KY",
        "rating": 4.5,
        "tags": ["cave", "underground"],
    }

    embedding_service._validate_metadata(valid_metadata)


def test_validate_metadata_empty(embedding_service):
    """Test metadata validation fails for empty dict."""
    with pytest.raises(EmbeddingError, match="must not be empty"):
        embedding_service._validate_metadata({})


def test_validate_metadata_missing_name(embedding_service):
    """Test metadata validation fails without 'name' field."""
    with pytest.raises(EmbeddingError, match="must include 'name'"):
        embedding_service._validate_metadata({"location": "Pikeville, KY"})

    with pytest.raises(EmbeddingError, match="must include 'name'"):
        embedding_service._validate_metadata({"name": ""})

    with pytest.raises(EmbeddingError, match="must include 'name'"):
        embedding_service._validate_metadata({"name": "   "})


def test_validate_metadata_non_serializable(embedding_service):
    """Test metadata validation fails for non-serializable objects."""
    from datetime import datetime

    invalid_metadata = {"name": "Test", "created_at": datetime.now()}

    with pytest.raises(EmbeddingError, match="JSON-serializable"):
        embedding_service._validate_metadata(invalid_metadata)


def test_validate_source_id_reddit_valid(embedding_service):
    """Test Reddit source_id validation passes for valid formats."""
    embedding_service._validate_source_id("reddit", "abc123")
    embedding_service._validate_source_id("reddit", "post_abc_123")
    embedding_service._validate_source_id("reddit", "xyz_999")


def test_validate_source_id_reddit_invalid(embedding_service):
    """Test Reddit source_id validation fails for invalid formats."""
    with pytest.raises(ValueError, match="Invalid Reddit source_id"):
        embedding_service._validate_source_id("reddit", "ABC-123")

    with pytest.raises(ValueError, match="Invalid Reddit source_id"):
        embedding_service._validate_source_id("reddit", "post with spaces")


def test_validate_source_id_eventbrite_valid(embedding_service):
    """Test Eventbrite source_id validation passes for numeric IDs."""
    embedding_service._validate_source_id("eventbrite", "123456789")
    embedding_service._validate_source_id("eventbrite", "42")


def test_validate_source_id_eventbrite_invalid(embedding_service):
    """Test Eventbrite source_id validation fails for non-numeric IDs."""
    with pytest.raises(ValueError, match="Invalid Eventbrite source_id"):
        embedding_service._validate_source_id("eventbrite", "event_123")

    with pytest.raises(ValueError, match="Invalid Eventbrite source_id"):
        embedding_service._validate_source_id("eventbrite", "abc")


def test_validate_source_id_serp_valid(embedding_service):
    """Test SERP source_id validation passes for hashes/URLs."""
    embedding_service._validate_source_id("serp", "abcd1234efgh5678")
    embedding_service._validate_source_id("serp", "https://example.com/place")


def test_validate_source_id_serp_invalid(embedding_service):
    """Test SERP source_id validation fails for short IDs."""
    with pytest.raises(ValueError, match="Invalid SERP source_id"):
        embedding_service._validate_source_id("serp", "abc123")

    with pytest.raises(ValueError, match="Invalid SERP source_id"):
        embedding_service._validate_source_id("serp", "short")


@pytest.mark.parametrize(
    "source,source_id,should_pass",
    [
        ("serp", "12345678", True),
        ("serp", "https://example.com/place", True),
        ("serp", "url_hash_abcd1234", True),
        ("serp", "short", False),
        ("serp", "1234567", False),
        ("reddit", "abc_123", True),
        ("reddit", "post_xyz_999", True),
        ("reddit", "ABC-123", False),
        ("reddit", "post with spaces", False),
        ("eventbrite", "123456789", True),
        ("eventbrite", "42", True),
        ("eventbrite", "event_123", False),
        ("eventbrite", "abc", False),
    ],
)
def test_validate_source_id_parametrized(embedding_service, source, source_id, should_pass):
    """Test source_id validation with comprehensive parameter matrix."""
    if should_pass:
        embedding_service._validate_source_id(source, source_id)
    else:
        with pytest.raises(ValueError):
            embedding_service._validate_source_id(source, source_id)


def test_store_place_embedding_success(embedding_service):
    """Test successful place embedding storage."""
    mock_embedding_response = MagicMock()
    mock_embedding_response.data = [MagicMock(embedding=[0.1] * 1536)]
    embedding_service.openai_client.embeddings.create.return_value = mock_embedding_response

    mock_db_response = MagicMock()
    embedding_service.supabase.client.table.return_value.upsert.return_value.execute.return_value = (
        mock_db_response
    )

    metadata = {"name": "Secret Cave", "location": "Pikeville, KY"}

    embedding_service.store_place_embedding(
        source="serp", source_id="12345678", text="Secret Cave underground", metadata=metadata
    )

    embedding_service.supabase.client.table.assert_called_with("app_embeddings.places_embeddings")


def test_store_place_embedding_invalid_source(embedding_service):
    """Test storage fails with invalid source."""
    with pytest.raises(ValueError, match="Invalid source"):
        embedding_service.store_place_embedding(
            source="invalid", source_id="123", text="test", metadata={"name": "Test"}
        )


def test_store_place_embedding_empty_source_id(embedding_service):
    """Test storage fails with empty source_id."""
    with pytest.raises(ValueError, match="source_id must be non-empty"):
        embedding_service.store_place_embedding(
            source="serp", source_id="", text="test", metadata={"name": "Test"}
        )

    with pytest.raises(ValueError, match="source_id must be non-empty"):
        embedding_service.store_place_embedding(
            source="serp", source_id="   ", text="test", metadata={"name": "Test"}
        )


def test_store_place_embedding_invalid_source_id_format(embedding_service):
    """Test storage fails with invalid source_id format for source type."""
    with pytest.raises(ValueError, match="Invalid Reddit source_id"):
        embedding_service.store_place_embedding(
            source="reddit", source_id="ABC-123", text="test", metadata={"name": "Test"}
        )


def test_store_place_embedding_serp_source_id_too_short(embedding_service):
    """Test SERP source_id must be at least 8 characters."""
    with pytest.raises(ValueError, match="Invalid SERP source_id"):
        embedding_service.store_place_embedding(
            source="serp", source_id="short", text="test", metadata={"name": "Test"}
        )


def test_store_place_embedding_empty_metadata(embedding_service):
    """Test storage fails with empty metadata."""
    with pytest.raises(EmbeddingError, match="must not be empty"):
        embedding_service.store_place_embedding(
            source="serp", source_id="12345678", text="test", metadata={}
        )


def test_store_place_embedding_missing_name_in_metadata(embedding_service):
    """Test storage fails when metadata missing 'name' field."""
    with pytest.raises(EmbeddingError, match="must include 'name'"):
        embedding_service.store_place_embedding(
            source="serp",
            source_id="12345678",
            text="test",
            metadata={"location": "Pikeville, KY"},
        )


def test_store_place_embedding_invalid_metadata(embedding_service):
    """Test storage fails with non-serializable metadata."""
    from datetime import datetime

    metadata = {"name": "Test", "created": datetime.now()}

    with pytest.raises(EmbeddingError, match="JSON-serializable"):
        embedding_service.store_place_embedding(
            source="serp", source_id="12345678", text="test", metadata=metadata
        )


def test_store_place_embedding_db_error(embedding_service):
    """Test storage handles database errors."""
    mock_embedding_response = MagicMock()
    mock_embedding_response.data = [MagicMock(embedding=[0.1] * 1536)]
    embedding_service.openai_client.embeddings.create.return_value = mock_embedding_response

    embedding_service.supabase.client.table.return_value.upsert.return_value.execute.side_effect = (
        Exception("DB error")
    )

    with pytest.raises(EmbeddingError, match="Failed to store embedding"):
        embedding_service.store_place_embedding(
            source="serp", source_id="12345678", text="test", metadata={"name": "Test"}
        )


def test_similarity_search_success(embedding_service):
    """Test successful similarity search."""
    mock_embedding_response = MagicMock()
    mock_embedding_response.data = [MagicMock(embedding=[0.1] * 1536)]
    embedding_service.openai_client.embeddings.create.return_value = mock_embedding_response

    mock_search_response = MagicMock()
    mock_search_response.data = [
        {
            "id": "1",
            "source": "serp",
            "metadata": {"name": "Cave"},
            "similarity": 0.95,
        }
    ]
    embedding_service.supabase.client.rpc.return_value.execute.return_value = mock_search_response

    results = embedding_service.similarity_search("underground caves")

    assert len(results) == 1
    assert results[0]["similarity"] == 0.95
    embedding_service.supabase.client.rpc.assert_called_with(
        "app_embeddings.search_places_by_similarity",
        {"query_embedding": [0.1] * 1536, "match_threshold": 0.7, "match_count": 10},
    )


def test_similarity_search_empty_query(embedding_service):
    """Test search fails with empty query."""
    with pytest.raises(ValueError, match="query_text must be non-empty"):
        embedding_service.similarity_search("")

    with pytest.raises(ValueError, match="query_text must be non-empty"):
        embedding_service.similarity_search("   ")


@pytest.mark.parametrize(
    "query_text,error_match",
    [
        ("", "query_text must be non-empty"),
        ("   ", "query_text must be non-empty"),
        ("a" * 8001, "Text too long"),
    ],
)
def test_similarity_search_query_validation(embedding_service, query_text, error_match):
    """Test search validates query text edge cases."""
    with pytest.raises(ValueError, match=error_match):
        embedding_service.similarity_search(query_text)


def test_similarity_search_invalid_limit(embedding_service):
    """Test search fails with invalid limit."""
    with pytest.raises(ValueError, match="limit must be between 1 and 100"):
        embedding_service.similarity_search("test", limit=0)

    with pytest.raises(ValueError, match="limit must be between 1 and 100"):
        embedding_service.similarity_search("test", limit=101)


def test_similarity_search_invalid_threshold(embedding_service):
    """Test search fails with invalid similarity threshold."""
    with pytest.raises(ValueError, match="similarity_threshold must be between 0 and 1"):
        embedding_service.similarity_search("test", similarity_threshold=-0.1)

    with pytest.raises(ValueError, match="similarity_threshold must be between 0 and 1"):
        embedding_service.similarity_search("test", similarity_threshold=1.5)


def test_similarity_search_rpc_error(embedding_service):
    """Test search handles RPC errors."""
    embedding_service._pgvector_validated = True

    mock_embedding_response = MagicMock()
    mock_embedding_response.data = [MagicMock(embedding=[0.1] * 1536)]
    embedding_service.openai_client.embeddings.create.return_value = mock_embedding_response

    embedding_service.supabase.client.rpc.return_value.execute.side_effect = Exception("RPC error")

    with pytest.raises(EmbeddingError, match="Similarity search failed"):
        embedding_service.similarity_search("test")


def test_similarity_search_no_results(embedding_service):
    """Test search returns empty list when no results found."""
    mock_embedding_response = MagicMock()
    mock_embedding_response.data = [MagicMock(embedding=[0.1] * 1536)]
    embedding_service.openai_client.embeddings.create.return_value = mock_embedding_response

    mock_search_response = MagicMock()
    mock_search_response.data = []
    embedding_service.supabase.client.rpc.return_value.execute.return_value = mock_search_response

    results = embedding_service.similarity_search("nonexistent place")

    assert results == []
