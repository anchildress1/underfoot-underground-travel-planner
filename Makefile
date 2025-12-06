.PHONY: help dev dev-backend dev-frontend build build-backend build-frontend
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

# Development
dev: dev-frontend

dev-backend:
	cd backend && poetry run uvicorn src.workers.chat_worker:app --reload --port 8000

dev-frontend:
	npm run -w frontend dev

# Build
build: build-frontend

build-backend:
	cd backend && poetry build

build-frontend:
	npm run -w frontend build

# Installation
install: install-backend install-frontend

install-backend:
	cd backend && poetry install

install-frontend:
	npm install

# Format (run first)
format: format-backend format-frontend

format-backend:
	cd backend && poetry run black src tests
	cd backend && poetry run ruff format src tests

format-frontend:
	npm run format

# Lint (run second)
lint: lint-backend lint-frontend

lint-backend:
	cd backend && poetry run ruff check src tests

lint-frontend:
	npm run -w frontend lint

# Test (run third) - format and lint before testing
test: format lint test-backend test-frontend

test-backend:
	cd backend && poetry run pytest

test-frontend:
	npm --prefix frontend test

# Type checking
typecheck: typecheck-backend typecheck-frontend

typecheck-backend:
	cd backend && poetry run mypy src

typecheck-frontend:
	npm --prefix frontend run typecheck

# Clean
clean: clean-backend clean-frontend

clean-backend:
	cd backend && rm -rf .pytest_cache htmlcov .coverage .ruff_cache
	cd backend && find . -type d -name __pycache__ -exec rm -rf {} +

clean-frontend:
	cd frontend && rm -rf node_modules dist coverage playwright-report test-results
