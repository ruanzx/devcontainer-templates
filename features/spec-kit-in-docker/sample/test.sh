#!/bin/bash

# Test script for spec-kit-in-docker feature

set -e

echo "🧪 Testing spec-kit-in-docker feature"
echo "======================================"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

test_passed() {
    echo -e "${GREEN}✅ PASSED:${NC} $1"
}

test_failed() {
    echo -e "${RED}❌ FAILED:${NC} $1"
    exit 1
}

test_info() {
    echo -e "${YELLOW}ℹ️  INFO:${NC} $1"
}

# Test 1: Check if specify command exists
echo ""
echo "Test 1: Checking if specify command is available..."
if command -v specify &> /dev/null; then
    test_passed "specify command is available"
else
    test_failed "specify command not found"
fi

# Test 2: Check if Docker is available
echo ""
echo "Test 2: Checking if Docker is available..."
if docker info &> /dev/null; then
    test_passed "Docker is running"
else
    test_failed "Docker is not available"
fi

# Test 3: Check if Docker image can be pulled
echo ""
echo "Test 3: Checking spec-kit Docker image..."
if docker image inspect ruanzx/spec-kit:latest &> /dev/null; then
    test_passed "Docker image is available locally"
else
    test_info "Pulling Docker image..."
    if docker pull ruanzx/spec-kit:latest; then
        test_passed "Docker image pulled successfully"
    else
        test_failed "Failed to pull Docker image"
    fi
fi

# Test 4: Test specify help command
echo ""
echo "Test 4: Testing specify --help..."
if specify --help 2>&1 | grep -q "SPECIFY"; then
    test_passed "specify --help works"
else
    test_failed "specify --help failed"
fi

# Test 5: Test wrapper help
echo ""
echo "Test 5: Testing wrapper help..."
if specify --wrapper-help | grep -q "WRAPPER FLAGS"; then
    test_passed "specify --wrapper-help works"
else
    test_failed "specify --wrapper-help failed"
fi

# Test 6: Test specify check command
echo ""
echo "Test 6: Testing specify check..."
if specify check 2>&1 | grep -q "Specify CLI is ready to use"; then
    test_passed "specify check works"
else
    test_failed "specify check failed"
fi

# Test 7: Test project initialization in temp directory
echo ""
echo "Test 7: Testing specify init..."
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
test_info "Created temp directory: $TEMP_DIR"

if specify init --here --ai copilot --ignore-agent-tools 2>&1; then
    if [ -d ".specify" ]; then
        test_passed "specify init created .specify directory"
    else
        test_failed "specify init did not create .specify directory"
    fi
else
    test_failed "specify init command failed"
fi

# Test 8: Verify .specify structure
echo ""
echo "Test 8: Verifying .specify directory structure..."
if [ -d ".specify/templates" ] && [ -d ".specify/scripts" ]; then
    test_passed ".specify directory has correct structure"
else
    test_failed ".specify directory structure is incorrect"
fi

# Test 9: Check if scripts are executable
echo ""
echo "Test 9: Checking script permissions..."
if [ -x ".specify/scripts/bash/check-prerequisites.sh" ]; then
    test_passed "Scripts are executable"
else
    test_failed "Scripts are not executable"
fi

# Test 10: Test wrapper upgrade flag
echo ""
echo "Test 10: Testing wrapper upgrade..."
if specify --wrapper-upgrade 2>&1 | grep -q "upgraded successfully"; then
    test_passed "specify --wrapper-upgrade works"
else
    test_failed "specify --wrapper-upgrade failed"
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"
test_info "Cleaned up temp directory"

# Summary
echo ""
echo "======================================"
echo -e "${GREEN}✅ All tests passed!${NC}"
echo "spec-kit-in-docker feature is working correctly"
echo "======================================"
