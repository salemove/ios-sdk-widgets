#!/bin/bash

# Setup Git Hooks
# This script configures git to use the .git-hooks directory for git hooks

set -e

# Parse command line arguments
QUIET=false
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -q|--quiet) QUIET=true ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
  shift
done

# Quiet mode can also be enabled via environment variable
if [ "$QUIET_MODE" = "true" ]; then
  QUIET=true
fi

# Helper function for logging
log() {
  if [ "$QUIET" = false ]; then
    echo "$@"
  fi
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

cd "$PROJECT_ROOT"

# Get current git hooks configuration
CURRENT_HOOKS_PATH=$(git config --get core.hooksPath 2>/dev/null || echo "")

# Skip if it runs in a Bitrise CI environment
if [ "$BITRISE_IO" = "true" ]; then
  log "⚠️  Detected Bitrise CI environment, skipping git hooks setup"
  exit 0
fi

# Check if git hooks setup should be skipped
if [ "$IOS_WIDGETS_SDK_SKIP_GIT_HOOKS" = "true" ]; then
  # Check if core.hooksPath is currently configured to .git-hooks
  if [ "$CURRENT_HOOKS_PATH" = ".git-hooks" ]; then
    log "⚠️  Unsetting git hooks configuration (IOS_WIDGETS_SDK_SKIP_GIT_HOOKS is set)"
    git config --unset core.hooksPath
    log "🚮 Git hooks configuration removed"
  else
    log "ℹ️  Git hooks not configured to .git-hooks, nothing to unset"
  fi
  exit 0
fi

# Check if git hooks are already configured
if [ "$CURRENT_HOOKS_PATH" = ".git-hooks" ]; then
  log "✅ Git hooks already configured correctly"
  exit 0
fi

log "Setting up git hooks..."

# Configure git to use .git-hooks directory
git config core.hooksPath .git-hooks

log "✅ Git hooks configured successfully! Hooks path: .git-hooks"
