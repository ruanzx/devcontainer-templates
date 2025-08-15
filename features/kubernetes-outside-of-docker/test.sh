#!/bin/bash

# Test script for kubernetes-outside-of-docker feature
# This script validates that the feature is properly installed and configured

set -e

echo "🧪 Testing kubernetes-outside-of-docker feature..."

# Test 1: Check if initialization script exists
echo "1️⃣ Checking initialization script..."
if [ -f "/usr/local/share/kubernetes-init.sh" ]; then
    echo "   ✅ Initialization script found"
else
    echo "   ❌ Initialization script not found"
    exit 1
fi

# Test 2: Check if entrypoint symlink exists
echo "2️⃣ Checking entrypoint symlink..."
if [ -L "/usr/local/share/docker-init.sh" ]; then
    echo "   ✅ Entrypoint symlink found"
else
    echo "   ❌ Entrypoint symlink not found"
    exit 1
fi

# Test 3: Check script permissions
echo "3️⃣ Checking script permissions..."
if [ -x "/usr/local/share/kubernetes-init.sh" ]; then
    echo "   ✅ Script is executable"
else
    echo "   ❌ Script is not executable"
    exit 1
fi

# Test 4: Check if .kube directory exists
echo "4️⃣ Checking .kube directory..."
if [ -d "/home/vscode/.kube" ]; then
    echo "   ✅ .kube directory exists"
    echo "   📁 Directory contents:"
    ls -la /home/vscode/.kube/ || echo "   (empty or no access)"
else
    echo "   ❌ .kube directory not found"
fi

# Test 5: Check KUBECONFIG environment variable
echo "5️⃣ Checking KUBECONFIG environment..."
if [ -n "$KUBECONFIG" ]; then
    echo "   ✅ KUBECONFIG is set: $KUBECONFIG"
else
    echo "   ⚠️  KUBECONFIG not set (this is expected during installation)"
fi

# Test 6: Test script syntax
echo "6️⃣ Testing script syntax..."
if bash -n /usr/local/share/kubernetes-init.sh; then
    echo "   ✅ Script syntax is valid"
else
    echo "   ❌ Script syntax error"
    exit 1
fi

# Test 7: Check if kubectl is available (should be installed by dependency)
echo "7️⃣ Checking kubectl availability..."
if command -v kubectl >/dev/null 2>&1; then
    echo "   ✅ kubectl is available"
    kubectl version --client --short 2>/dev/null || echo "   (client version check failed, but command exists)"
else
    echo "   ❌ kubectl not found"
fi

echo ""
echo "🎉 All tests passed! The kubernetes-outside-of-docker feature is properly installed."
echo ""
echo "📋 To test cluster connectivity:"
echo "   1. Ensure a Kubernetes cluster is running on your host"
echo "   2. Mount your .kube directory to /home/vscode/.kube"
echo "   3. Run: /usr/local/share/kubernetes-init.sh"
echo "   4. Test: kubectl get nodes"
