.PHONY: help dev dev-backend dev-frontend build build-backend build-frontend ai-checks
.PHONY: install install-backend install-frontend
.PHONY: format format-backend format-frontend
.PHONY: lint lint-backend lint-frontend
.PHONY: test test-backend test-frontend
.PHONY: typecheck typecheck-backend typecheck-frontend
.PHONY: clean clean-backend clean-frontend

help:
	@echo "Available targets:"
	@echo "  make dev              - Run frontend dev server"
	@echo "  make dev-backend      - Run backend dev server"
	@echo "  make dev-frontend     - Run frontend dev server"
	@echo "  make install          - Install all dependencies"
	@echo "  make format           - Format all code"
	@echo "  make lint             - Lint all code"
	@echo "  make test             - Run all tests"
	@echo "  make typecheck        - Type check all code"
	@echo "  make clean            - Clean build artifacts"
	@echo "  make ai-checks        - Run all checks (format, lint, test)"

ai-checks: test


# Development
dev: dev-frontend

dev-backend:
	cd backend && uv run python manage.py runserver

dev-frontend:
	npm run -w frontend dev

# Build
build: build-frontend

build-backend:
	cd backend && uv build

build-frontend:
	npm run -w frontend build

# Installation
install: install-backend install-frontend

install-backend:
	cd backend && uv sync

install-frontend:
	npm install

# Format (run first)
format: format-backend format-frontend

format-backend:
	cd backend && uv run black chat underfoot manage.py tests
	cd backend && uv run ruff format chat underfoot manage.py tests

format-frontend:
	npm run format

# Lint (run second)
lint: lint-backend lint-frontend

lint-backend:
	cd backend && uv run ruff check chat underfoot manage.py tests

lint-frontend:
	npm run -w frontend lint

# Test (run third) - format and lint before testing
test: format lint test-backend test-frontend

test-backend:
	cd backend && uv run pytest

test-frontend:
	npm --prefix frontend test

# Type checking
typecheck: typecheck-backend typecheck-frontend

typecheck-backend:
	cd backend && uv run mypy chat underfoot manage.py

typecheck-frontend:
	npm --prefix frontend run typecheck

# Clean
clean: clean-backend clean-frontend

clean-backend:
	cd backend && rm -rf .pytest_cache htmlcov .coverage .ruff_cache
	cd backend && find . -type d -name __pycache__ -exec rm -rf {} +
	cd backend && rm -rf dist

clean-frontend:
	cd frontend && rm -rf node_modules dist coverage playwright-report test-results
