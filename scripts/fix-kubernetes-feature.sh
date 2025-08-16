#!/bin/bash

# Kubernetes Outside of Docker Feature Fix Script
# This script ensures the kubernetes-outside-of-docker feature is properly installed and configured

set -e

echo "🔧 Kubernetes Outside of Docker Feature Fix Script"
echo "================================================="

# Check if the feature was already installed
if [ -f "/usr/local/share/kubernetes-init.sh" ] && [ -f "/etc/profile.d/kubernetes-outside-docker.sh" ]; then
    echo "✅ Feature appears to be already installed"
    
    # Validate installation
    if [ -f "/usr/local/share/kubernetes-outside-docker-installed" ]; then
        echo "✅ Installation marker found"
        source /usr/local/share/kubernetes-outside-docker-installed
        validate_installation || {
            echo "❌ Installation validation failed, reinstalling..."
            rm -f /usr/local/share/kubernetes-outside-docker-installed
        }
    fi
else
    echo "❌ Feature not properly installed"
fi

# Install/reinstall if needed
if [ ! -f "/usr/local/share/kubernetes-outside-docker-installed" ] || ! validate_installation 2>/dev/null; then
    echo "🔧 Installing/reinstalling kubernetes-outside-of-docker feature..."
    
    # Find the feature directory
    FEATURE_DIR=""
    if [ -d "/workspaces/devcontainer-templates/features/kubernetes-outside-of-docker" ]; then
        FEATURE_DIR="/workspaces/devcontainer-templates/features/kubernetes-outside-of-docker"
    elif [ -d "/usr/local/share/features/kubernetes-outside-of-docker" ]; then
        FEATURE_DIR="/usr/local/share/features/kubernetes-outside-of-docker"
    elif [ -d "$(pwd)/features/kubernetes-outside-of-docker" ]; then
        FEATURE_DIR="$(pwd)/features/kubernetes-outside-of-docker"
    fi
    
    if [ -n "$FEATURE_DIR" ] && [ -f "$FEATURE_DIR/install.sh" ]; then
        echo "📁 Found feature at: $FEATURE_DIR"
        cd "$FEATURE_DIR"
        bash install.sh
        echo "✅ Feature installation completed"
    else
        echo "❌ Could not find feature installation script"
        echo "🔍 Searched in:"
        echo "  - /workspaces/devcontainer-templates/features/kubernetes-outside-of-docker"
        echo "  - /usr/local/share/features/kubernetes-outside-of-docker"
        echo "  - $(pwd)/features/kubernetes-outside-of-docker"
        exit 1
    fi
fi

# Test the installation
echo ""
echo "🧪 Testing installation..."

if [ -f "/usr/local/share/kubernetes-init.sh" ]; then
    echo "✅ kubernetes-init.sh found"
else
    echo "❌ kubernetes-init.sh missing"
fi

if [ -f "/etc/profile.d/kubernetes-outside-docker.sh" ]; then
    echo "✅ profile script found"
else
    echo "❌ profile script missing"
fi

# Test environment loading
echo "🔄 Testing environment loading..."
source /etc/profile.d/kubernetes-outside-docker.sh 2>/dev/null || echo "⚠️ Could not source profile script"

if [ -n "$KUBECONFIG" ]; then
    echo "✅ KUBECONFIG is set to: $KUBECONFIG"
else
    echo "❌ KUBECONFIG not set"
fi

# Check mount
if [ -d "/tmp/host-kube" ]; then
    echo "✅ Host mount directory exists"
    if [ -f "/tmp/host-kube/config" ]; then
        echo "✅ Host kubeconfig found"
    else
        echo "⚠️ Host kubeconfig not found (this may be expected if not mounted)"
    fi
else
    echo "⚠️ Host mount directory not found (this may be expected if not mounted)"
fi

echo ""
echo "🎉 Feature fix script completed!"
echo "💡 To test: try running 'kubectl version --client' or 'kubectl get nodes'"
