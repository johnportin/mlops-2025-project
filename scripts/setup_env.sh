#!/usr/bin/env bash
set -e

# 1. Check for Python 3.12
if ! python3.12 --version &>/dev/null; then
    echo "Python 3.12 is required. Please install Python 3.12 and try again."
    exit 1
fi

# 2. Create virtual environment
python3.12 -m venv .venv
source .venv/bin/activate

# 3. Install uv if not present
if ! command -v uv &>/dev/null; then
    echo "Installing uv..."
    pip install uv
fi

# 4. Install dependencies with uv
uv pip install -r requirements.txt

# 5. Reminder to activate
echo "\nEnvironment setup complete! Activate with:"
echo "  source .venv/bin/activate"
