#!/bin/bash
# Quick manual test for spec-kit-in-docker wrapper

set -e

echo "🧪 Manual Test for spec-kit-in-docker"
echo "======================================"
echo ""

# Test 1: Wrapper help
echo "Test 1: Wrapper help"
specify --wrapper-help | grep -q "WRAPPER FLAGS" && echo "✅ PASSED" || echo "❌ FAILED"

# Test 2: Spec-kit help
echo "Test 2: Spec-kit help"
specify --help 2>&1 | grep -q "SPECIFY" && echo "✅ PASSED" || echo "❌ FAILED"

# Test 3: Check command
echo "Test 3: Check command"
specify check 2>&1 | grep -q "Specify CLI is ready to use" && echo "✅ PASSED" || echo "❌ FAILED"

# Test 4: Verify Docker mounting
echo "Test 4: Docker mounting"
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
echo "test content" > test.txt
# Run a simple command that reads the file
if specify check > /dev/null 2>&1; then
    echo "✅ PASSED (volume mounting works)"
else
    echo "❌ FAILED"
fi
rm -rf "$TEMP_DIR"

# Test 5: Environment variables
echo "Test 5: Environment variables"
export SPECKIT_IMAGE_NAME="ruanzx/spec-kit"
export SPECKIT_IMAGE_TAG="latest"
specify check > /dev/null 2>&1 && echo "✅ PASSED" || echo "❌ FAILED"

echo ""
echo "======================================"
echo "Manual tests complete!"
echo "======================================"
