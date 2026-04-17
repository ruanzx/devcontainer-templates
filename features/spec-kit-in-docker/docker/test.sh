#!/usr/bin/env bash
# Test script for spec-kit Docker image

set -e

echo "Testing Spec-Kit Docker Image"
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
    echo -e "${GREEN}PASSED:${NC} $1"
    ((TESTS_PASSED++))
}

test_failed() {
    echo -e "${RED}FAILED:${NC} $1"
    ((TESTS_FAILED++))
}

# Shared volume for tool installs across tests
SPECKIT_VOLUME="speckit-test-uv-tools"
docker volume rm "$SPECKIT_VOLUME" >/dev/null 2>&1 || true
docker volume create "$SPECKIT_VOLUME" >/dev/null 2>&1

# Test 1: Build image
echo "Test 1: Building Docker image..."
if docker build -t spec-kit:test -f Dockerfile . > /dev/null 2>&1; then
    test_passed "Image builds successfully"
else
    test_failed "Image failed to build"
    exit 1
fi

# Test 2: Verify Git is installed
echo "Test 2: Checking Git installation..."
if docker run --rm --entrypoint git spec-kit:test --version > /dev/null 2>&1; then
    test_passed "Git is installed"
else
    test_failed "Git is not installed"
fi

# Test 3: Verify Python is installed
echo "Test 3: Checking Python installation..."
if docker run --rm --entrypoint python spec-kit:test --version 2>&1 | grep -q "Python 3"; then
    test_passed "Python 3 is installed"
else
    test_failed "Python 3 is not installed"
fi

# Test 4: Verify uv is installed
echo "Test 4: Checking UV installation..."
if docker run --rm --entrypoint /root/.local/bin/uv spec-kit:test --version > /dev/null 2>&1; then
    test_passed "UV package manager is installed"
else
    test_failed "UV package manager is not installed"
fi

# Test 5: Verify working directory
echo "Test 5: Checking working directory..."
if docker run --rm --entrypoint pwd spec-kit:test | grep -q "/workspace"; then
    test_passed "Working directory is set correctly"
else
    test_failed "Working directory is incorrect"
fi

# Test 6: Test volume mounting
echo "Test 6: Testing volume mounting..."
TEMP_DIR=$(mktemp -d)
if docker run --rm --entrypoint ls -v "$TEMP_DIR:/workspace" spec-kit:test /workspace > /dev/null 2>&1; then
    test_passed "Volume mounting works"
    rm -rf "$TEMP_DIR"
else
    test_failed "Volume mounting failed"
    rm -rf "$TEMP_DIR"
fi

# Test 7: Entrypoint installs spec-kit and runs help
echo "Test 7: Testing entrypoint installs spec-kit (this may take a moment)..."
if docker run --rm -v "$SPECKIT_VOLUME:/root/.local/share/uv/tools" spec-kit:test specify --help 2>&1 | grep -iq "specify\|usage\|spec"; then
    test_passed "Entrypoint installs spec-kit and help command works"
else
    test_failed "Entrypoint spec-kit installation or help failed"
fi

# Test 8: Verify specify is available after entrypoint
echo "Test 8: Checking specify in PATH after install..."
if docker run --rm -v "$SPECKIT_VOLUME:/root/.local/share/uv/tools" spec-kit:test which specify 2>&1 | grep -q "specify"; then
    test_passed "Specify is in PATH"
else
    test_failed "Specify is not in PATH"
fi

# Test 9: Test file creation in workspace
echo "Test 9: Testing file operations..."
TEMP_DIR=$(mktemp -d)
if docker run --rm -v "$TEMP_DIR:/workspace" -v "$SPECKIT_VOLUME:/root/.local/share/uv/tools" spec-kit:test bash -c "echo 'test' > /workspace/test.txt" && \
   [ -f "$TEMP_DIR/test.txt" ]; then
    test_passed "File operations work"
    rm -rf "$TEMP_DIR"
else
    test_failed "File operations failed"
    rm -rf "$TEMP_DIR"
fi

# Test 10: Test version pinning via SPECKIT_VERSION env var
echo "Test 10: Testing SPECKIT_VERSION environment variable pass-through..."
if docker run --rm -e SPECKIT_VERSION=latest -v "$SPECKIT_VOLUME:/root/.local/share/uv/tools" spec-kit:test specify --help 2>&1 | grep -iq "specify\|usage\|spec"; then
    test_passed "SPECKIT_VERSION pass-through works"
else
    test_failed "SPECKIT_VERSION pass-through failed"
fi

# Clean up
echo ""
echo "Cleaning up..."
docker rmi spec-kit:test > /dev/null 2>&1 || true
docker volume rm "$SPECKIT_VOLUME" > /dev/null 2>&1 || true

# Summary
echo ""
echo "================================="
echo "Test Results Summary"
echo "================================="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    echo "The spec-kit Docker image is ready for use."
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    echo "Please review the errors above."
    exit 1
fi
