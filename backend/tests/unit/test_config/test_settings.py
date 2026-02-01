"""Unit tests for settings configuration."""

from chat.config.settings import get_settings


def test_get_settings():
    """Test settings singleton."""
    settings1 = get_settings()
    settings2 = get_settings()

    # Should return the same instance (singleton)
    assert settings1 is settings2

    # Should have required attributes
    assert hasattr(settings1, "log_level")
    assert hasattr(settings1, "openai_api_key")
