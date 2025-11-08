#!/usr/bin/env bash
# Test script for spec-kit Docker image

set -e

echo "🧪 Testing Spec-Kit Docker Image"
echo "================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

test_passed() {
    echo -e "${GREEN}✅ PASSED:${NC} $1"
    ((TESTS_PASSED++))
}

test_failed() {
    echo -e "${RED}❌ FAILED:${NC} $1"
    ((TESTS_FAILED++))
}

# Test 1: Build image
echo "Test 1: Building Docker image..."
if docker build -t spec-kit:test -f Dockerfile . > /dev/null 2>&1; then
    test_passed "Image builds successfully"
else
    test_failed "Image failed to build"
    exit 1
fi

# Test 2: Run help command
echo "Test 2: Testing help command..."
if docker run --rm spec-kit:test specify --help | grep -q "SPECIFY"; then
    test_passed "Help command works"
else
    test_failed "Help command failed"
fi

# Test 3: Run check command
echo "Test 3: Testing check command..."
if docker run --rm spec-kit:test specify check | grep -q "Specify CLI is ready to use"; then
    test_passed "Check command works"
else
    test_failed "Check command failed"
fi

# Test 4: Verify Git is installed
echo "Test 4: Checking Git installation..."
if docker run --rm spec-kit:test git --version > /dev/null 2>&1; then
    test_passed "Git is installed"
else
    test_failed "Git is not installed"
fi

# Test 5: Verify Python is installed
echo "Test 5: Checking Python installation..."
if docker run --rm spec-kit:test python --version | grep -q "Python 3"; then
    test_passed "Python 3 is installed"
else
    test_failed "Python 3 is not installed"
fi

# Test 6: Verify uv is installed
echo "Test 6: Checking UV installation..."
if docker run --rm spec-kit:test /root/.local/bin/uv --version > /dev/null 2>&1; then
    test_passed "UV package manager is installed"
else
    test_failed "UV package manager is not installed"
fi

# Test 7: Verify working directory
echo "Test 7: Checking working directory..."
if docker run --rm spec-kit:test pwd | grep -q "/workspace"; then
    test_passed "Working directory is set correctly"
else
    test_failed "Working directory is incorrect"
fi

# Test 8: Test volume mounting
echo "Test 8: Testing volume mounting..."
TEMP_DIR=$(mktemp -d)
if docker run --rm -v "$TEMP_DIR:/workspace" spec-kit:test ls /workspace > /dev/null 2>&1; then
    test_passed "Volume mounting works"
    rm -rf "$TEMP_DIR"
else
    test_failed "Volume mounting failed"
    rm -rf "$TEMP_DIR"
fi

# Test 9: Verify specify is in PATH
echo "Test 9: Checking specify in PATH..."
if docker run --rm spec-kit:test which specify | grep -q "specify"; then
    test_passed "Specify is in PATH"
else
    test_failed "Specify is not in PATH"
fi

# Test 10: Test file creation in workspace
echo "Test 10: Testing file operations..."
TEMP_DIR=$(mktemp -d)
if docker run --rm -v "$TEMP_DIR:/workspace" spec-kit:test bash -c "echo 'test' > /workspace/test.txt" && \
   [ -f "$TEMP_DIR/test.txt" ]; then
    test_passed "File operations work"
    rm -rf "$TEMP_DIR"
else
    test_failed "File operations failed"
    rm -rf "$TEMP_DIR"
fi

# Clean up test image
echo ""
echo "Cleaning up test image..."
docker rmi spec-kit:test > /dev/null 2>&1

# Summary
echo ""
echo "================================="
echo "Test Results Summary"
echo "================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo "The spec-kit Docker image is ready for use."
    exit 0
else
    echo -e "${RED}❌ Some tests failed.${NC}"
    echo "Please review the errors above."
    exit 1
fi
