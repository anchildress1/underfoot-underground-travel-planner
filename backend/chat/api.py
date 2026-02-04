import time
from datetime import UTC, datetime
from typing import Any

from django.http import HttpRequest
from ninja import Router

from chat.schemas import ErrorResponse, HealthResponse, SearchRequest, SearchResponse
from chat.services import cache_service, search_service
from chat.utils.errors import UnderfootError
from chat.utils.input_sanitizer import InputSanitizer, IntentParser
from chat.utils.logger import get_logger

logger = get_logger(__name__)
router = Router()


@router.get("/health", response=HealthResponse)
def health(request: HttpRequest) -> Any:
    """Comprehensive health check endpoint."""
    # We need to make this async-compatible or use clean_sync/async_to_sync if services are async
    # Django Ninja supports all async handlers.
    return health_async(request)


async def health_async(request: HttpRequest) -> dict[str, Any]:  # noqa: ARG001
    start = time.perf_counter()
    dependencies = {}
    try:
        stats = await cache_service.get_cache_stats()
        dependencies["supabase"] = {"status": "healthy" if stats["connected"] else "degraded"}
    except Exception as e:
        dependencies["supabase"] = {"status": "degraded", "error": str(e)}

    elapsed_ms = int((time.perf_counter() - start) * 1000)
    return {
        "status": "healthy",
        "timestamp": datetime.now(UTC).isoformat(),
        "elapsed_ms": elapsed_ms,
        "dependencies": dependencies,
    }


@router.post("/search", response={200: SearchResponse, 500: ErrorResponse})
async def search(request: HttpRequest, data: SearchRequest) -> Any:  # noqa: ARG001
    """Execute search with AI orchestration."""
    try:
        sanitized_input = InputSanitizer.sanitize(data.chat_input)

        intent = IntentParser.parse_intent(sanitized_input)
        logger.info("search.intent_parsed", **intent)

        vector_query = IntentParser.extract_vector_query(intent)

        result = await search_service.execute_search(
            chat_input=sanitized_input,
            force=data.force,
            intent=intent,
            vector_query=vector_query,
        )
        return 200, result

    except UnderfootError as e:
        logger.error("search.underfoot_error", error=str(e))
        return 500, {
            "error": "UNDERFOOT_ERROR",
            "message": e.message,
            "request_id": "unknown",  # Accessing middleware context might differ in Django
            "timestamp": datetime.now(UTC).isoformat(),
            "context": e.context,
        }
    except Exception as e:
        logger.error("search.error", error=str(e), exc_info=True)
        return 500, {
            "error": "INTERNAL_ERROR",
            "message": "Search failed",
            "request_id": "unknown",
            "timestamp": datetime.now(UTC).isoformat(),
        }
