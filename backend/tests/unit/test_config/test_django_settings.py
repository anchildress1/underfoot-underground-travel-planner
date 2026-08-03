"""Unit tests for the env var guards in underfoot/settings.py.

The guards run at module import time, so these tests reload the module
under controlled env vars and always reload it back to its original
state afterward so later tests see Django's normal DEBUG=True settings.
"""

import importlib
from contextlib import contextmanager

import pytest
from django.core.exceptions import ImproperlyConfigured

from underfoot import settings as underfoot_settings

_GUARDED_VARS = ("DEBUG", "DJANGO_SECRET_KEY", "DJANGO_ALLOWED_HOSTS")


@contextmanager
def _env(**overrides):
    monkeypatch = pytest.MonkeyPatch()
    for key in _GUARDED_VARS:
        monkeypatch.delenv(key, raising=False)
    for key, value in overrides.items():
        monkeypatch.setenv(key, value)
    try:
        yield
    finally:
        monkeypatch.undo()
        importlib.reload(underfoot_settings)


def test_secret_key_required_when_debug_false():
    with (
        _env(DEBUG="False", DJANGO_ALLOWED_HOSTS="example.com"),
        pytest.raises(ImproperlyConfigured, match="DJANGO_SECRET_KEY"),
    ):
        importlib.reload(underfoot_settings)


def test_allowed_hosts_required_when_debug_false():
    with (
        _env(DEBUG="False", DJANGO_SECRET_KEY="test-key"),
        pytest.raises(ImproperlyConfigured, match="DJANGO_ALLOWED_HOSTS"),
    ):
        importlib.reload(underfoot_settings)


def test_debug_false_boots_with_both_vars_set():
    with _env(
        DEBUG="False",
        DJANGO_SECRET_KEY="test-key",
        DJANGO_ALLOWED_HOSTS="example.com, other.example.com",
    ):
        importlib.reload(underfoot_settings)
        assert underfoot_settings.SECRET_KEY == "test-key"
        assert underfoot_settings.ALLOWED_HOSTS == ["example.com", "other.example.com"]
