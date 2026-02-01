"""Tests for cache service."""

from unittest.mock import MagicMock, patch

import pytest

from chat.services.cache_service import (
    generate_cache_key,
    get_cache_stats,
    get_cached_location,
    get_cached_search_results,
    set_cached_location,
    set_cached_search_results,
)


class TestCacheService:
    """Test cache service functionality."""

    def test_generate_cache_key(self):
        """Test cache key generation."""
        # Test basic key generation
        key1 = generate_cache_key("pizza", "New York")
        key2 = generate_cache_key("pizza", "New York")
        assert key1 == key2
        assert len(key1) == 32

        # Test case insensitive
        key3 = generate_cache_key("PIZZA", "NEW YORK")
        assert key1 == key3

        # Test whitespace normalization
        key4 = generate_cache_key("  pizza  ", "  New York  ")
        assert key1 == key4

        # Test different inputs produce different keys
        key5 = generate_cache_key("pizza", "Chicago")
        assert key1 != key5

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_get_cached_search_results_success(self, mock_supabase):
        """Test successful cache retrieval."""
        mock_result = {"results": ["test"]}
        mock_supabase.get_search_results.return_value = mock_result

        result = await get_cached_search_results("pizza", "New York")

        assert result == mock_result
        mock_supabase.get_search_results.assert_called_once()

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_get_cached_search_results_not_found(self, mock_supabase):
        """Test cache miss."""
        mock_supabase.get_search_results.return_value = None

        result = await get_cached_search_results("pizza", "New York")

        assert result is None

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_get_cached_search_results_error(self, mock_supabase):
        """Test cache retrieval error handling."""
        mock_supabase.get_search_results.side_effect = Exception("DB error")

        result = await get_cached_search_results("pizza", "New York")

        assert result is None

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_set_cached_search_results_success(self, mock_supabase):
        """Test successful cache storage."""
        mock_supabase.store_search_results.return_value = True

        result = await set_cached_search_results("pizza", "New York", {"results": ["test"]})

        assert result is True
        mock_supabase.store_search_results.assert_called_once()

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_set_cached_search_results_failure(self, mock_supabase):
        """Test cache storage failure."""
        mock_supabase.store_search_results.return_value = False

        result = await set_cached_search_results("pizza", "New York", {"results": ["test"]})

        assert result is False

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_set_cached_search_results_error(self, mock_supabase):
        """Test cache storage error handling."""
        mock_supabase.store_search_results.side_effect = Exception("DB error")

        result = await set_cached_search_results("pizza", "New York", {"results": ["test"]})

        assert result is False

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_get_cached_location_success(self, mock_supabase):
        """Test successful location cache retrieval."""
        mock_data = {
            "normalized_location": "New York, NY",
            "confidence": 0.95,
            "raw_candidates": [{"name": "New York"}],
        }
        mock_result = MagicMock()
        mock_result.data = mock_data

        mock_supabase.client.table.return_value.select.return_value.eq.return_value.gt.return_value.single.return_value.execute.return_value = (
            mock_result
        )

        result = await get_cached_location("new york")

        assert result["normalized"] == "New York, NY"
        assert result["confidence"] == 0.95

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase", None)
    async def test_get_cached_location_no_supabase(self):
        """Test location cache when supabase is None."""
        result = await get_cached_location("new york")
        assert result is None

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_get_cached_location_error(self, mock_supabase):
        """Test location cache error handling."""
        mock_supabase.client.table.return_value.select.return_value.eq.return_value.gt.return_value.single.return_value.execute.side_effect = Exception(
            "DB error"
        )

        result = await get_cached_location("new york")

        assert result is None

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_set_cached_location_success(self, mock_supabase):
        """Test successful location cache storage."""
        mock_supabase.client.table.return_value.upsert.return_value.execute.return_value = (
            MagicMock()
        )

        result = await set_cached_location("new york", "New York, NY", 0.95)

        assert result is True
        mock_supabase.client.table.assert_called_with("location_cache")

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase", None)
    async def test_set_cached_location_no_supabase(self):
        """Test location cache storage when supabase is None."""
        result = await set_cached_location("new york", "New York, NY", 0.95)
        assert result is False

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_set_cached_location_error(self, mock_supabase):
        """Test location cache storage error handling."""
        mock_supabase.client.table.return_value.upsert.return_value.execute.side_effect = Exception(
            "DB error"
        )

        result = await set_cached_location("new york", "New York, NY", 0.95)

        assert result is False

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_get_cache_stats_success(self, mock_supabase):
        """Test successful cache stats retrieval."""
        mock_stats = {"search_results_count": 10, "location_cache_count": 5, "connected": True}
        mock_supabase.get_stats.return_value = mock_stats

        result = await get_cache_stats()

        assert result == mock_stats

    @pytest.mark.asyncio
    @patch("chat.services.cache_service.supabase")
    async def test_get_cache_stats_error(self, mock_supabase):
        """Test cache stats error handling."""
        mock_supabase.get_stats.side_effect = Exception("DB error")

        result = await get_cache_stats()

        assert result == {"search_results_count": 0, "location_cache_count": 0, "connected": False}
