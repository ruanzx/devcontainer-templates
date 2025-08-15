#!/bin/bash

# Fix Kubernetes connection for dev container
# This script creates a container-specific kubeconfig without modifying the original

set -e

echo "🔧 Fixing Kubernetes configuration for dev container..."

# Define paths
ORIGINAL_KUBECONFIG="/home/vscode/.kube/config"
CONTAINER_KUBECONFIG="/home/vscode/.kube/config-container"

# Check if original kubeconfig exists
if [ ! -f "$ORIGINAL_KUBECONFIG" ]; then
    echo "❌ Original kubeconfig not found at $ORIGINAL_KUBECONFIG"
    echo "   Make sure Docker Desktop Kubernetes is enabled and the .kube directory is mounted"
    exit 1
fi

echo "📁 Found original kubeconfig at $ORIGINAL_KUBECONFIG"

# Backup original config if container config doesn't exist
if [ ! -f "${ORIGINAL_KUBECONFIG}.backup" ]; then
    echo "💾 Creating backup of original kubeconfig"
    cp "$ORIGINAL_KUBECONFIG" "${ORIGINAL_KUBECONFIG}.backup"
fi

# Detect the Docker gateway IP (should be 172.17.0.1 in most cases)
GATEWAY_IP=$(ip route show default | awk '/default/ {print $3}' | head -n1)
if [ -z "$GATEWAY_IP" ]; then
    GATEWAY_IP="172.17.0.1"
fi

echo "🌐 Using gateway IP: $GATEWAY_IP"

# Detect the kind cluster port by inspecting the kubeconfig
KIND_PORT=""
if [ -f "$ORIGINAL_KUBECONFIG" ]; then
    # Extract the port from the server URL in kubeconfig
    KIND_PORT=$(grep -o 'server: https://[^:]*:\([0-9]\+\)' "$ORIGINAL_KUBECONFIG" | sed 's/.*://' | head -n1)
fi

# Fallback to common ports if not detected
if [ -z "$KIND_PORT" ]; then
    KIND_PORT="6443"
fi

echo "🔍 Detected Kubernetes API port: $KIND_PORT"

# For kind clusters, we need to use host.docker.internal since they're typically bound to localhost
# Check if this looks like a kind cluster by examining the server URL
if grep -q "127.0.0.1:" "$ORIGINAL_KUBECONFIG" 2>/dev/null; then
    echo "🏷️  Detected kind cluster (localhost binding)"
    GATEWAY_IP="host.docker.internal"
    echo "🌐 Using host.docker.internal for kind cluster access"
else
    echo "🌐 Using gateway IP: $GATEWAY_IP"
fi

# Create container-specific kubeconfig
echo "📝 Creating container-specific kubeconfig..."

# Copy original config and modify for container use
cp "$ORIGINAL_KUBECONFIG" "$CONTAINER_KUBECONFIG"

# Replace server URLs with the best gateway IP and detected port for container-to-host connectivity
sed -i "s|server: https://kubernetes.docker.internal:6443|server: https://$GATEWAY_IP:$KIND_PORT|g" "$CONTAINER_KUBECONFIG"
sed -i "s|server: https://localhost:6443|server: https://$GATEWAY_IP:$KIND_PORT|g" "$CONTAINER_KUBECONFIG"
sed -i "s|server: https://127.0.0.1:6443|server: https://$GATEWAY_IP:$KIND_PORT|g" "$CONTAINER_KUBECONFIG"
sed -i "s|server: https://host.docker.internal:6443|server: https://$GATEWAY_IP:$KIND_PORT|g" "$CONTAINER_KUBECONFIG"
# Handle the dynamic port format (127.0.0.1:PORT)
sed -i "s|server: https://127.0.0.1:[0-9]\+|server: https://$GATEWAY_IP:$KIND_PORT|g" "$CONTAINER_KUBECONFIG"

# Set KUBECONFIG environment variable for current session
export KUBECONFIG="$CONTAINER_KUBECONFIG"

# Also update the shell environment for immediate use
echo "🔧 Setting KUBECONFIG for current session..."
echo "export KUBECONFIG=\"$CONTAINER_KUBECONFIG\"" > /tmp/kubeconfig_env.sh
source /tmp/kubeconfig_env.sh

# Configure kubectl to skip TLS verification (since certificate won't match gateway IP)
echo "🔐 Configuring TLS settings..."
kubectl config set-cluster docker-desktop --insecure-skip-tls-verify=true 2>/dev/null || true

# Test kubectl connection
echo "🧪 Testing kubectl connection..."
if kubectl get nodes &>/dev/null; then
    echo "✅ kubectl is working correctly!"
    echo ""
    echo "📊 Cluster information:"
    kubectl get nodes
else
    echo "❌ kubectl connection failed"
    echo ""
    echo "🔍 Diagnosing the issue..."
    
    # Check if this is a localhost-bound kind cluster
    if grep -q "127.0.0.1:" "$ORIGINAL_KUBECONFIG" 2>/dev/null; then
        echo "⚠️  The kind cluster is bound to localhost (127.0.0.1) on the host machine."
        echo "   This makes it inaccessible from containers."
        echo ""
        echo "🛠️  To fix this, you need to recreate the kind cluster with proper networking:"
        echo ""
        echo "   1. Delete the current cluster:"
        echo "      kind delete cluster --name=\$(kubectl config current-context | sed 's/kind-//')"
        echo ""
        echo "   2. Create a new cluster with proper networking:"
        echo "      cat <<EOF | kind create cluster --config=-"
        echo "      kind: Cluster"
        echo "      apiVersion: kind.x-k8s.io/v1alpha4"
        echo "      networking:"
        echo "        apiServerAddress: \"0.0.0.0\""
        echo "        apiServerPort: 6443"
        echo "      EOF"
        echo ""
        echo "   3. Rerun this script: ./dev-container-kind-kube-config.sh"
        echo ""
    fi
    
    echo "💡 Alternatively, you can:"
    echo "   - Use Docker Desktop's built-in Kubernetes instead of kind"
    echo "   - Or run kubectl commands directly from the host machine"
    echo ""
    exit 1
fi

# Add environment variable to shell profiles
echo "🔧 Setting up environment for future sessions..."

# Add to bashrc if not already present
if ! grep -q "KUBECONFIG.*config-container" ~/.bashrc 2>/dev/null; then
    echo "" >> ~/.bashrc
    echo "# Dev container Kubernetes configuration" >> ~/.bashrc
    echo "export KUBECONFIG=/home/vscode/.kube/config-container" >> ~/.bashrc
fi

# Add to zshrc if zsh is available and not already present
if [ -f ~/.zshrc ] && ! grep -q "KUBECONFIG.*config-container" ~/.zshrc 2>/dev/null; then
    echo "" >> ~/.zshrc
    echo "# Dev container Kubernetes configuration" >> ~/.zshrc
    echo "export KUBECONFIG=/home/vscode/.kube/config-container" >> ~/.zshrc
fi

echo ""
echo "🎉 Kubernetes configuration fixed successfully!"
echo ""
echo "📋 Summary:"
echo "  • Original kubeconfig: $ORIGINAL_KUBECONFIG (unchanged)"
echo "  • Container kubeconfig: $CONTAINER_KUBECONFIG"
echo "  • Gateway IP: $GATEWAY_IP"
echo "  • TLS verification: disabled for container use"
echo ""
echo "💡 To use in current session: export KUBECONFIG=$CONTAINER_KUBECONFIG"
echo "💡 New terminal sessions will use the container config automatically"
echo ""
echo "🔄 To restore original config: export KUBECONFIG=$ORIGINAL_KUBECONFIG"
