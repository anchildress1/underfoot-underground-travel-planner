"""Pytest configuration and fixtures."""

import pytest


@pytest.fixture(autouse=True)
def mock_env_vars(monkeypatch):
    """Mock environment variables for testing."""
    test_env = {
        "LOG_LEVEL": "DEBUG",
        "OPENAI_API_KEY": "test_openai_key",
        "GOOGLE_MAPS_API_KEY": "test_google_maps_key",
        "SERPAPI_KEY": "test_serpapi_key",
        "REDDIT_CLIENT_ID": "test_reddit_client_id",
        "REDDIT_CLIENT_SECRET": "test_reddit_client_secret",
        "EVENTBRITE_TOKEN": "test_eventbrite_token",
        "SUPABASE_URL": "https://test.supabase.co",
        "SUPABASE_PUBLISHABLE_KEY": "test_publishable_key",
        "SUPABASE_SECRET_KEY": "test_secret_key",
        "SUPABASE_KEY": "test_app_admin_key",
    }
    for key, value in test_env.items():
        monkeypatch.setenv(key, value)
