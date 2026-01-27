"""Unit tests for Supabase service."""

from datetime import UTC, datetime, timedelta
from unittest.mock import MagicMock, patch

import pytest

from chat.services.supabase_service import SupabaseService


@pytest.fixture
def supabase_service():
    """Create fresh SupabaseService instance with mocked client."""
    SupabaseService._instance = None
    with patch("chat.services.supabase_service.get_supabase_client") as mock_client:
        service = SupabaseService()
        service._client = mock_client.return_value
        yield service
    SupabaseService._instance = None


def test_store_search_results_success(supabase_service):
    """Test storing search results successfully."""
    mock_response = MagicMock()
    mock_response.data = [{"id": "test-id"}]

    supabase_service.client.table.return_value.upsert.return_value.execute.return_value = (
        mock_response
    )

    result = supabase_service.store_search_results(
        query_hash="test_hash",
        location="Pikeville, KY",
        intent="hidden gems",
        results={"places": []},
        ttl_seconds=3600,
    )

    assert result is True
    supabase_service.client.table.assert_called_with("app_cache.search_results")


def test_store_search_results_failure(supabase_service):
    """Test handling storage failures."""
    supabase_service.client.table.return_value.upsert.side_effect = Exception("DB error")

    result = supabase_service.store_search_results(
        query_hash="test_hash",
        location="Pikeville, KY",
        intent="hidden gems",
        results={"places": []},
    )

    assert result is False


def test_get_search_results_cache_hit(supabase_service):
    """Test retrieving cached search results."""
    mock_response = MagicMock()
    mock_response.data = [
        {
            "query_hash": "test_hash",
            "location": "Pikeville, KY",
            "results_json": {"places": [{"name": "Test Place"}]},
            "expires_at": (datetime.now(UTC) + timedelta(hours=1)).isoformat(),
        }
    ]

    (
        supabase_service.client.table.return_value.select.return_value.eq.return_value.gt.return_value.execute.return_value
    ) = mock_response

    result = supabase_service.get_search_results("test_hash")

    assert result is not None
    assert "places" in result
    supabase_service.client.table.assert_called_with("app_cache.search_results")


def test_get_search_results_cache_miss(supabase_service):
    """Test cache miss returns None."""
    mock_response = MagicMock()
    mock_response.data = []

    (
        supabase_service.client.table.return_value.select.return_value.eq.return_value.gt.return_value.execute.return_value
    ) = mock_response

    result = supabase_service.get_search_results("missing_hash")

    assert result is None


def test_get_search_results_error(supabase_service):
    """Test handling retrieval errors."""
    supabase_service.client.table.return_value.select.side_effect = Exception("DB error")

    result = supabase_service.get_search_results("test_hash")

    assert result is None


def test_store_location_success(supabase_service):
    """Test storing normalized location."""
    mock_response = MagicMock()
    mock_response.data = [{"id": "test-id"}]

    supabase_service.client.table.return_value.upsert.return_value.execute.return_value = (
        mock_response
    )

    result = supabase_service.store_location(
        raw_input="pikeville ky",
        normalized_location="Pikeville, KY",
        confidence=0.95,
        raw_candidates=[{"name": "Pikeville, KY"}],
        ttl_days=30,
    )

    assert result is True
    supabase_service.client.table.assert_called_with("app_cache.location_cache")


def test_store_location_failure(supabase_service):
    """Test handling location storage failures."""
    supabase_service.client.table.return_value.upsert.side_effect = Exception("DB error")

    result = supabase_service.store_location(
        raw_input="pikeville ky",
        normalized_location="Pikeville, KY",
        confidence=0.95,
        raw_candidates=[],
    )

    assert result is False


def test_get_location_cache_hit(supabase_service):
    """Test retrieving cached location normalization."""
    mock_response = MagicMock()
    mock_response.data = [
        {
            "raw_input": "pikeville ky",
            "normalized_location": "Pikeville, KY",
            "confidence": 0.95,
            "expires_at": (datetime.now(UTC) + timedelta(days=30)).isoformat(),
        }
    ]

    (
        supabase_service.client.table.return_value.select.return_value.eq.return_value.gt.return_value.execute.return_value
    ) = mock_response

    result = supabase_service.get_location("pikeville ky")

    assert result is not None
    assert result["normalized_location"] == "Pikeville, KY"
    assert result["confidence"] == 0.95


def test_get_location_cache_miss(supabase_service):
    """Test location cache miss returns None."""
    mock_response = MagicMock()
    mock_response.data = []

    (
        supabase_service.client.table.return_value.select.return_value.eq.return_value.gt.return_value.execute.return_value
    ) = mock_response

    result = supabase_service.get_location("unknown location")

    assert result is None


def test_get_location_error(supabase_service):
    """Test handling location retrieval errors."""
    supabase_service.client.table.return_value.select.side_effect = Exception("DB error")

    result = supabase_service.get_location("pikeville ky")

    assert result is None


def test_get_stats_success(supabase_service):
    """Test retrieving cache statistics."""
    search_mock = MagicMock()
    search_mock.data = [{"id": "1"}, {"id": "2"}, {"id": "3"}]

    location_mock = MagicMock()
    location_mock.data = [{"id": "1"}, {"id": "2"}]

    def table_mock(table_name):
        mock_table = MagicMock()
        if table_name == "app_cache.search_results":
            mock_table.select.return_value.execute.return_value = search_mock
        else:
            mock_table.select.return_value.execute.return_value = location_mock
        return mock_table

    supabase_service.client.table = table_mock

    stats = supabase_service.get_stats()

    assert stats["connected"] is True
    assert stats["search_results_count"] == 3
    assert stats["location_cache_count"] == 2


def test_get_stats_error(supabase_service):
    """Test handling stats retrieval errors."""
    supabase_service.client.table.side_effect = Exception("DB error")

    stats = supabase_service.get_stats()

    assert stats["connected"] is False
    assert "error" in stats
