.PHONY: help dev dev-backend dev-frontend build build-backend build-frontend ai-checks
.PHONY: install install-backend install-frontend
.PHONY: format format-backend format-frontend
.PHONY: lint lint-backend lint-frontend
.PHONY: test test-backend test-frontend
.PHONY: typecheck typecheck-backend typecheck-frontend
.PHONY: clean clean-backend clean-frontend

help:
	@echo "Available targets:"
	@echo "  make dev              - Run backend and mobile dev servers"
	@echo "  make dev-backend      - Run backend dev server"
	@echo "  make dev-frontend     - Run mobile (Flutter) dev server"
	@echo "  make install          - Install all dependencies"
	@echo "  make format           - Format all code"
	@echo "  make lint             - Lint all code"
	@echo "  make test             - Run all tests"
	@echo "  make typecheck        - Type check all code"
	@echo "  make clean            - Clean build artifacts"
	@echo "  make ai-checks        - Run all checks (format, lint, typecheck, test)"

ai-checks: install typecheck test


# Development
dev:
	@echo "Tip: Run 'make dev-backend' and 'make dev-frontend' in separate terminals for best experience."
	@echo "Starting backend..."
	cd backend && uv run python manage.py runserver & \
	cd mobile && flutter run -d chrome

dev-backend:
	cd backend && uv run python manage.py runserver

dev-frontend:
	cd mobile && flutter run -d chrome

# Build
build: build-frontend

build-backend:
	cd backend && uv build

build-frontend:
	cd mobile && flutter build web --release

# Installation
install: install-backend install-frontend

install-backend:
	cd backend && uv sync

install-frontend:
	cd mobile && flutter pub get

# Format (run first)
format: format-backend format-frontend

format-backend:
	cd backend && uv run black chat underfoot manage.py tests
	cd backend && uv run ruff format chat underfoot manage.py tests

format-frontend:
	cd mobile && dart format .

# Lint (run second)
lint: lint-backend lint-frontend

lint-backend:
	cd backend && uv run ruff check chat underfoot manage.py tests

lint-frontend:
	cd mobile && flutter analyze

# Test (run third) - format and lint before testing
test: format lint test-backend test-frontend

test-backend:
	cd backend && uv run pytest

test-frontend:
	cd mobile && flutter test

# Type checking
typecheck: typecheck-backend typecheck-frontend

typecheck-backend:
	cd backend && uv run mypy chat underfoot manage.py

typecheck-frontend:
	cd mobile && flutter analyze

# Clean
clean: clean-backend clean-frontend

clean-backend:
	cd backend && rm -rf .pytest_cache htmlcov .coverage .ruff_cache
	cd backend && find . -type d -name __pycache__ -exec rm -rf {} +
	cd backend && rm -rf dist

clean-frontend:
	cd mobile && flutter clean
