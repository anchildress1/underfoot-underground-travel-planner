from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=False)

    log_level: str = "INFO"

    openai_api_key: str = "sk-test-key"
    google_maps_api_key: str = "test-google-maps-key"
    serpapi_key: str = "test-serpapi-key"
    reddit_client_id: str = "test-reddit-client-id"
    reddit_client_secret: str = "test-reddit-secret"
    eventbrite_token: str = "test-eventbrite-token"

    supabase_url: str = "https://test.supabase.co"
    supabase_publishable_key: str = "test-publishable-key"
    supabase_secret_key: str | None = None
    supabase_key: str | None = None  # app_admin_user password for TimescaleDB + application roles


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Get cached settings instance.

    Returns:
        Singleton Settings instance

    Raises:
        ValidationError: If required environment variables are missing
    """
    return Settings()
