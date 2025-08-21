#!/bin/bash

# Enhanced Zephyr environment setup script
# Automatically creates virtual environment if it doesn't exist
# Usage: source ./setup-env.sh  OR  . ./setup-env.sh

# Only exit on error if running as script, not when sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -e
    echo "Warning: Script should be sourced, not executed directly"
    echo "Use: . ./setup-env.sh  or  source ./setup-env.sh"
    exit 1
fi

VENV_DIR="zephyr-env"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PATH="$SCRIPT_DIR/$VENV_DIR"

echo "Setting up Zephyr development environment..."

# Check if virtual environment exists
if [ ! -d "$VENV_PATH" ]; then
  echo "Virtual environment '$VENV_DIR' not found. Creating new environment..."
  
  # Create virtual environment
  if ! python3 -m venv "$VENV_PATH"; then
    echo "✗ Failed to create virtual environment"
    return 1
  fi
  
  echo "✓ Virtual environment created successfully"
  
  # Activate the new environment
  source "$VENV_PATH/bin/activate"
  
  echo "Installing required packages for Zephyr development..."
  
  # Upgrade pip first (suppress output for cleaner display)
  if ! pip3 install --upgrade pip --quiet; then
    echo "⚠ Warning: Failed to upgrade pip, continuing anyway..."
  fi
  
  # Install essential Zephyr requirements with error handling
  echo "Installing west..."
  pip3 install west --quiet || echo "⚠ Warning: Failed to install west"
  
  echo "Installing pyelftools (required for Zephyr build)..."
  pip3 install pyelftools --quiet || echo "⚠ Warning: Failed to install pyelftools"
  
  # Install additional common Zephyr dependencies
  echo "Installing additional dependencies..."
  pip3 install intelhex pyyaml canopen packaging progress psutil cryptography --quiet || echo "⚠ Warning: Some packages failed to install"
  
  echo "✓ Essential packages installed"
  echo "✓ Virtual environment setup complete"
  
else
  echo "✓ Virtual environment '$VENV_DIR' found"
  # Activate existing environment
  source "$VENV_PATH/bin/activate"
fi

# Set Zephyr-specific environment variables
# Look for Zephyr in parent directory structure
if [ -d "$SCRIPT_DIR/../../zephyr" ]; then
    export ZEPHYR_BASE="$SCRIPT_DIR/../../zephyr"
elif [ -d "$SCRIPT_DIR/../zephyr" ]; then
    export ZEPHYR_BASE="$SCRIPT_DIR/../zephyr"
else
    export ZEPHYR_BASE="$SCRIPT_DIR/zephyr"
fi

# Verify west is available
if ! command -v west >/dev/null 2>&1; then
  echo "⚠ Warning: West tool not found. Installing..."
  pip3 install west --quiet || echo "⚠ Warning: Failed to install west"
fi

# Verify pyelftools is available (critical for Zephyr builds)
if ! python3 -c "import elftools" >/dev/null 2>&1; then
  echo "⚠ Warning: pyelftools not found. Installing..."
  pip3 install pyelftools --quiet || echo "⚠ Warning: Failed to install pyelftools"
fi

# Check if Zephyr source exists and source its environment
if [ -d "$ZEPHYR_BASE" ]; then
  if [ -f "$ZEPHYR_BASE/zephyr-env.sh" ]; then
    source "$ZEPHYR_BASE/zephyr-env.sh"
    echo "✓ Sourced Zephyr environment from $ZEPHYR_BASE"
  fi
else
  echo "⚠ Warning: Zephyr source directory not found at $ZEPHYR_BASE"
  echo "   You may need to run: west init -m https://github.com/zephyrproject-rtos/zephyr --mr main zephyrproject"
fi

# Display environment info
echo ""
echo "Environment Status:"
echo "  Virtual Env: $VIRTUAL_ENV"
echo "  Python: $(which python3)"
echo "  West: $(which west 2>/dev/null || echo 'Not found')"
echo "  Zephyr Base: $ZEPHYR_BASE"
echo ""
echo "Zephyr development environment is ready!"
echo "Use 'deactivate' to exit the virtual environment when done."
