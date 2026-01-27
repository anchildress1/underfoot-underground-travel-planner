"""Supabase database service."""

from datetime import UTC, datetime, timedelta
from functools import lru_cache
from typing import Any, cast

from supabase import Client, create_client

from chat.config.settings import get_settings
from chat.utils.logger import get_logger

logger = get_logger(__name__)


@lru_cache(maxsize=1)
def get_supabase_client() -> Client:
    """Get cached Supabase client.

    Returns:
        Supabase client instance

    Raises:
        ValueError: If neither supabase_key nor supabase_secret_key is set
    """
    settings = get_settings()
    api_key = settings.supabase_key or settings.supabase_secret_key or ""

    if not api_key:
        raise ValueError(
            "Missing SUPABASE_KEY or SUPABASE_SECRET_KEY in .env. "
            "See supabase/DEPLOYMENT_CHECKLIST.md for setup."
        )

    return create_client(settings.supabase_url, api_key)


class SupabaseService:
    """Service for Supabase operations."""

    _instance = None
    _client = None

    def __new__(cls) -> "SupabaseService":
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    @property
    def client(self) -> Client:
        """Lazy-load Supabase client."""
        if self._client is None:
            self._client = get_supabase_client()
        return self._client

    def store_search_results(
        self,
        query_hash: str,
        location: str,
        intent: str,
        results: dict,
        ttl_seconds: int = 3600,
    ) -> bool:
        """Store search results in cache.

        Args:
            query_hash: Hash of the query
            location: Normalized location
            intent: User intent JSON
            results: Search results JSON
            ttl_seconds: Time to live in seconds

        Returns:
            True if stored successfully
        """
        try:
            expires_at = datetime.now(UTC) + timedelta(seconds=ttl_seconds)

            data = {
                "query_hash": query_hash,
                "location": location,
                "intent": intent,
                "results_json": results,
                "expires_at": expires_at.isoformat(),
            }

            self.client.table("app_cache.search_results").upsert(data).execute()

            logger.info(
                "supabase.cache_stored",
                query_hash=query_hash,
                location=location,
                ttl_seconds=ttl_seconds,
            )

            return True

        except Exception as e:
            logger.error("supabase.store_error", error=str(e), exc_info=True)
            return False

    def get_search_results(self, query_hash: str) -> dict | None:
        """Retrieve cached search results.

        Args:
            query_hash: Hash of the query

        Returns:
            Cached results or None
        """
        try:
            response = (
                self.client.table("app_cache.search_results")
                .select("*")
                .eq("query_hash", query_hash)
                .gt("expires_at", datetime.now(UTC).isoformat())
                .execute()
            )

            if response.data and len(response.data) > 0:
                logger.info("supabase.cache_hit", query_hash=query_hash)
                return cast(dict, response.data[0]["results_json"])

            logger.info("supabase.cache_miss", query_hash=query_hash)
            return None

        except Exception as e:
            logger.error("supabase.get_error", error=str(e), exc_info=True)
            return None

    def store_location(
        self,
        raw_input: str,
        normalized_location: str,
        confidence: float,
        raw_candidates: list,
        ttl_days: int = 30,
    ) -> bool:
        """Store normalized location in cache.

        Args:
            raw_input: Raw user input
            normalized_location: Normalized location string
            confidence: Confidence score (0-1)
            raw_candidates: List of candidate locations
            ttl_days: Time to live in days

        Returns:
            True if stored successfully
        """
        try:
            expires_at = datetime.now(UTC) + timedelta(days=ttl_days)

            data = {
                "raw_input": raw_input,
                "normalized_location": normalized_location,
                "confidence": confidence,
                "raw_candidates": raw_candidates,
                "expires_at": expires_at.isoformat(),
            }

            self.client.table("app_cache.location_cache").upsert(data).execute()

            logger.info(
                "supabase.location_stored",
                raw_input=raw_input,
                normalized=normalized_location,
                confidence=confidence,
            )

            return True

        except Exception as e:
            logger.error("supabase.location_store_error", error=str(e), exc_info=True)
            return False

    def get_location(self, raw_input: str) -> dict | None:
        """Retrieve cached location normalization.

        Args:
            raw_input: Raw user input

        Returns:
            Cached location data or None
        """
        try:
            response = (
                self.client.table("app_cache.location_cache")
                .select("*")
                .eq("raw_input", raw_input)
                .gt("expires_at", datetime.now(UTC).isoformat())
                .execute()
            )

            if response.data and len(response.data) > 0:
                logger.info("supabase.location_hit", raw_input=raw_input)
                return cast(dict[Any, Any], response.data[0])

            logger.info("supabase.location_miss", raw_input=raw_input)
            return None

        except Exception as e:
            logger.error("supabase.location_get_error", error=str(e), exc_info=True)
            return None

    def get_stats(self) -> dict:
        """Get cache statistics.

        Returns:
            Stats dict with counts
        """
        try:
            search_count = len(
                self.client.table("app_cache.search_results")
                .select("id", count="exact")
                .execute()
                .data
            )

            location_count = len(
                self.client.table("app_cache.location_cache")
                .select("id", count="exact")
                .execute()
                .data
            )

            return {
                "connected": True,
                "search_results_count": search_count,
                "location_cache_count": location_count,
            }

        except Exception as e:
            logger.error("supabase.stats_error", error=str(e), exc_info=True)
            return {"connected": False, "error": str(e)}


supabase = SupabaseService()
