SHELL := /bin/bash

.PHONY: help dev dev-backend dev-frontend dev-mobile build build-backend build-frontend build-mobile ai-checks
.PHONY: install install-backend install-frontend install-mobile
.PHONY: format format-backend format-frontend format-mobile
.PHONY: lint lint-backend lint-frontend lint-mobile
.PHONY: test test-backend test-frontend test-mobile
.PHONY: typecheck typecheck-backend typecheck-frontend typecheck-mobile
.PHONY: clean clean-backend clean-frontend clean-mobile

help:
	@echo "Available targets:"
	@echo "  make dev              - Run frontend (web) dev server"
	@echo "  make dev-backend      - Run backend dev server"
	@echo "  make dev-frontend     - Run frontend (web) dev server"
	@echo "  make dev-mobile       - Run backend + mobile (Flutter) dev servers"
	@echo "  make install          - Install all dependencies"
	@echo "  make format           - Format all code"
	@echo "  make lint             - Lint all code"
	@echo "  make test             - Run all tests"
	@echo "  make typecheck        - Type check all code"
	@echo "  make clean            - Clean build artifacts"
	@echo "  make ai-checks        - Run all checks (format, lint, typecheck, test)"

ai-checks: install typecheck test


# Development
dev: dev-frontend

dev-backend:
	cd backend && uv run python manage.py runserver

dev-frontend:
	npm run -w frontend dev

dev-mobile:
	@trap 'kill $$(jobs -p) 2>/dev/null' EXIT; \
	cd backend && uv run python manage.py runserver & \
	cd mobile && flutter run -d chrome

# Build
build: build-frontend

build-backend:
	cd backend && uv build

build-frontend:
	npm run -w frontend build

build-mobile:
	cd mobile && flutter build web --release

# Installation
install: install-backend install-frontend install-mobile

install-backend:
	cd backend && uv sync

install-frontend:
	npm install

install-mobile:
	cd mobile && flutter pub get

# Format (run first)
format: format-backend format-frontend format-mobile

format-backend:
	cd backend && uv run black chat underfoot manage.py tests
	cd backend && uv run ruff format chat underfoot manage.py tests

format-frontend:
	npm run format

format-mobile:
	cd mobile && dart format .

# Lint (run second)
lint: lint-backend lint-frontend lint-mobile

lint-backend:
	cd backend && uv run ruff check chat underfoot manage.py tests

lint-frontend:
	npm run -w frontend lint

lint-mobile:
	cd mobile && flutter analyze

# Test (run third) - format and lint before testing
test: format lint test-backend test-frontend test-mobile

test-backend:
	cd backend && uv run pytest

test-frontend:
	npm --prefix frontend test

test-mobile:
	cd mobile && flutter test

# Type checking
typecheck: typecheck-backend typecheck-frontend typecheck-mobile

typecheck-backend:
	cd backend && uv run mypy chat underfoot manage.py

typecheck-frontend:
	npm --prefix frontend run typecheck

typecheck-mobile:
	cd mobile && flutter analyze

# Clean
clean: clean-backend clean-frontend clean-mobile

clean-backend:
	cd backend && rm -rf .pytest_cache htmlcov .coverage .ruff_cache
	cd backend && find . -type d -name __pycache__ -exec rm -rf {} +
	cd backend && rm -rf dist

clean-frontend:
	cd frontend && rm -rf node_modules dist coverage playwright-report test-results

clean-mobile:
	cd mobile && flutter clean
