from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=False)

    log_level: str = "INFO"

    openai_api_key: str
    google_maps_api_key: str
    serpapi_key: str
    reddit_client_id: str
    reddit_client_secret: str
    eventbrite_token: str

    supabase_url: str
    supabase_publishable_key: str
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
    return Settings()  # type: ignore[call-arg]
