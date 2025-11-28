"""CORS middleware configuration."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.config.settings import get_settings

settings = get_settings()


def add_cors_middleware(app: FastAPI) -> None:
    """Add CORS middleware to FastAPI app.

    Args:
        app: FastAPI application instance
    """
    # For local development, allow localhost; for production, use explicit frontend domain
    allowed_origins = [
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        # Add production frontend domain when deploying:
        # "https://your-frontend-domain.pages.dev",
    ]

    app.add_middleware(
        CORSMiddleware,
        allow_origins=allowed_origins,
        allow_credentials=False,
        allow_methods=["GET", "POST", "OPTIONS"],
        allow_headers=["Content-Type", "Accept"],
        expose_headers=["X-Request-ID", "X-Response-Time"],
    )
