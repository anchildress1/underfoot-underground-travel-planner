"""
Django Ninja Schemas (Ported from src/models)
"""
from typing import Any

from ninja import Field, Schema
from pydantic import ConfigDict, field_validator


# --- from domain_models.py ---
class ParsedInput(Schema):
    """Parsed user input."""

    location: str
    intent: str
    confidence: float


class NormalizedLocation(Schema):
    """Normalized location data."""

    normalized: str
    confidence: float
    coordinates: dict[str, float] | None = None


class SearchContext(Schema):
    """Search context for current execution."""

    location: str
    intent: str
    coordinates: dict[str, float] | None
    confidence: float


class SearchResult(Schema):
    """Single search result."""

    name: str
    description: str
    source: str
    url: str | None = None
    score: float = 0.0
    category: str = "nearby"
    metadata: dict[str, Any] | None = None


class AggregatedResults(Schema):
    """Results from multiple sources."""

    serp: list[SearchResult]
    reddit: list[SearchResult]
    eventbrite: list[SearchResult]

    def all_results(self) -> list[SearchResult]:
        return self.serp + self.reddit + self.eventbrite


class CategorizedResults(Schema):
    """Results categorized by relevance."""

    primary: list[SearchResult]
    nearby: list[SearchResult]


class ScoringSummary(Schema):
    """Summary of scoring results."""

    total_results: int
    average_score: float
    max_score: float
    min_score: float


# --- from request_models.py ---
MIN_CHAT_INPUT_LENGTH = 2
MAX_CHAT_INPUT_LENGTH = 500


class SearchRequest(Schema):
    """Search request with comprehensive validation."""

    model_config = ConfigDict(
        extra="forbid"
    )  # Ninja handles validation, strictness can be config'd

    chat_input: str = Field(
        ...,
        min_length=MIN_CHAT_INPUT_LENGTH,
        max_length=MAX_CHAT_INPUT_LENGTH,
        description="User search query",
    )
    force: bool = Field(default=False, description="Force cache bypass")

    @field_validator("chat_input")
    @classmethod
    def sanitize_input(cls, v: str) -> str:
        """Sanitize input to prevent injection attacks."""
        sanitized = "".join(char for char in v if char.isprintable())
        dangerous_patterns = ["<script", "javascript:", "onerror=", "onclick="]
        for pattern in dangerous_patterns:
            if pattern in sanitized.lower():
                raise ValueError(f"Potentially dangerous input: {pattern}")
        return sanitized.strip()


class NormalizeLocationRequest(Schema):
    """Location normalization request."""

    input: str = Field(..., min_length=1, max_length=200, description="Raw location input")
    force: bool = Field(default=False, description="Force cache bypass")


# --- from response_models.py ---
class DebugInfo(Schema):
    """Debug information for responses."""

    request_id: str
    execution_time_ms: int
    cache: str | None = None
    upstream_status: int | None = None
    upstream_error: str | None = None


class NormalizeLocationResponse(Schema):
    """Location normalization response."""

    input: str
    normalized: str
    confidence: float
    raw_candidates: list[dict[str, Any]] = Field(default_factory=list)
    debug: dict[str, Any]


class SearchResponse(Schema):
    """Search result response."""

    user_intent: str
    user_location: str
    response: str
    places: list[dict[str, Any]] = Field(default_factory=list)
    debug: DebugInfo


class HealthResponse(Schema):
    """Health check response."""

    status: str
    timestamp: str
    elapsed_ms: int
    dependencies: dict[str, dict[str, Any]]
    version: str = "0.1.0"


class ErrorResponse(Schema):
    """Error response."""

    error: str
    message: str
    request_id: str
    timestamp: str
    context: dict[str, Any] = Field(default_factory=dict)
