#!/bin/bash

# Check if required tools are installed
MISSING_TOOLS=false

if ! command -v gitleaks &> /dev/null; then
  echo "❌ gitleaks is not installed!"
  echo "   Recommended on macOS: brew install gitleaks"
  echo "   Other platforms: see https://github.com/gitleaks/gitleaks for installation options"
  MISSING_TOOLS=true
fi

if ! command -v trufflehog &> /dev/null; then
  echo "❌ trufflehog is not installed!"
  echo "   Recommended on macOS: brew install trufflehog"
  echo "   Other platforms: see https://github.com/trufflesecurity/trufflehog for installation options"
  MISSING_TOOLS=true
fi

if [ "$MISSING_TOOLS" = true ]; then
  echo ""
  echo "🚨 COMMIT ABORTED 🚨"
  echo "Please install the missing security scanning tools and try again."
  exit 1
fi

# Initialize a variable to track if any scanner failed (0 = pass, 1 = fail)
OVERALL_EXIT_CODE=0

echo "--------------------------------------------------------"
echo "👀 STRICT SECRET SCANNING INITIATED"
echo "--------------------------------------------------------"

# --- STEP 1: GITLEAKS ---
echo "Running gitleaks..."
# --staged: Only checks files currently staged for commit
gitleaks protect -v --staged
GITLEAKS_STATUS=$?

if [ $GITLEAKS_STATUS -ne 0 ]; then
  echo "❌ Gitleaks detected potential secrets!"
  OVERALL_EXIT_CODE=1
else
  echo "✅ Gitleaks passed"
fi

echo "--------------------------------------------------------"

# --- STEP 2: TRUFFLEHOG ---
echo "Running trufflehog..."
# file://. -> Scan current folder
# --since-commit HEAD -> Only scan changes since the last commit (staged/working)
# --only-verified -> Only fail on ACTUAL verified credentials (reduces false positives)
# --fail -> Return exit code 1 if secrets are found
# --no-update -> Don't update detectors on every commit (speeds it up)
# The sed command removes ANSI color codes for better compatibility with different hook managers
trufflehog git file://. --since-commit HEAD --only-verified --fail --no-update | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'
TRUFFLEHOG_STATUS=$?

if [ $TRUFFLEHOG_STATUS -ne 0 ]; then
  echo "❌ TruffleHog detected VERIFIED secrets!"
  OVERALL_EXIT_CODE=1
else
  echo "✅ TruffleHog passed"
fi

echo "--------------------------------------------------------"

# --- FINAL DECISION ---
if [ $OVERALL_EXIT_CODE -ne 0 ]; then
  echo "🚨 COMMIT ABORTED 🚨"
  echo "One or more security scanners failed. Please remove the secrets."
  exit 1
else
  echo "🎉 All security checks passed. Committing..."
  exit 0
fi
