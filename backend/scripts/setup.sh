#!/usr/bin/env bash
# Local development setup script

set -e

echo "🐍 Setting up Underfoot Python Backend..."

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.12+"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "✅ Python version: $PYTHON_VERSION"

# Install uv if not installed
if ! command -v uv &> /dev/null; then
    echo "📦 Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

echo "✅ uv installed: $(uv --version)"

# Install dependencies
echo "📦 Installing project dependencies..."
uv sync --all-extras --dev

# Copy .env.example if .env doesn't exist
if [ ! -f .env ]; then
    echo "📋 Creating .env from .env.example..."
    cp .env.example .env
    echo "⚠️  Please update .env with your API keys"
fi

# Run tests to verify setup
echo "🧪 Running tests to verify setup..."
uv run pytest tests/unit/ -v

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update .env with your API keys"
echo "2. Run 'uv run python manage.py runserver' to start dev server"
echo "3. Or run 'wrangler dev' for Cloudflare Workers local development"
