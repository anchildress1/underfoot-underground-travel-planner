import time
from collections.abc import Callable
from contextvars import ContextVar
from uuid import uuid4

from django.http import HttpRequest, HttpResponse

from chat.utils.logger import get_logger

logger = get_logger(__name__)
request_id_var: ContextVar[str] = ContextVar("request_id", default="")


class RequestTracingMiddleware:
    def __init__(self, get_response: Callable[[HttpRequest], HttpResponse]) -> None:
        self.get_response = get_response

    def __call__(self, request: HttpRequest) -> HttpResponse:
        request_id = request.headers.get("X-Request-ID") or f"uf_{uuid4().hex[:12]}"
        request_id_var.set(request_id)

        # Attach to request for convenience
        request.request_id = request_id  # type: ignore[attr-defined]

        start = time.perf_counter()

        try:
            response = self.get_response(request)
        except Exception as e:
            self.log_failure(request, request_id, start, e)
            raise

        self.log_success(request, response, request_id, start)

        response["X-Request-ID"] = request_id
        response["X-Response-Time"] = str(int((time.perf_counter() - start) * 1000))

        return response

    def log_success(
        self, request: HttpRequest, response: HttpResponse, request_id: str, start: float
    ) -> None:
        elapsed_ms = int((time.perf_counter() - start) * 1000)
        logger.info(
            "request.complete",
            request_id=request_id,
            method=request.method,
            path=request.path,
            status=response.status_code,
            elapsed_ms=elapsed_ms,
            user_agent=request.headers.get("User-Agent", "unknown")[:100],
        )

    def log_failure(
        self, request: HttpRequest, request_id: str, start: float, error: BaseException
    ) -> None:
        elapsed_ms = int((time.perf_counter() - start) * 1000)
        logger.error(
            "request.failed",
            request_id=request_id,
            method=request.method,
            path=request.path,
            elapsed_ms=elapsed_ms,
            error_type=type(error).__name__,
            error_msg=str(error),
            exc_info=True,
        )
