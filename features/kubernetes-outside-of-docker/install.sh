#!/bin/bash

# kubernetes-outside-of-docker feature installer
# Configures kubectl to access the host Kubernetes cluster from within the dev container

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to source utils.sh from multiple locations
if [[ -f "${SCRIPT_DIR}/utils.sh" ]]; then
    source "${SCRIPT_DIR}/utils.sh"
elif [[ -f "${SCRIPT_DIR}/../../common/utils.sh" ]]; then
    source "${SCRIPT_DIR}/../../common/utils.sh"
else
    echo "Error: Could not find utils.sh"
    exit 1
fi

log_info "🔧 Configuring Kubernetes access from dev container..."

# Define paths
KUBE_DIR="/home/vscode/.kube"
ORIGINAL_KUBECONFIG="$KUBE_DIR/config"
CONTAINER_KUBECONFIG="$KUBE_DIR/config-container"

# Create .kube directory if it doesn't exist
if [ ! -d "$KUBE_DIR" ]; then
    log_info "📁 Creating .kube directory"
    mkdir -p "$KUBE_DIR"
    chown -R vscode:vscode "$KUBE_DIR"
fi

# Create initialization script that will run when container starts
INIT_SCRIPT="/usr/local/share/kubernetes-init.sh"

log_info "� Creating Kubernetes initialization script"

cat > "$INIT_SCRIPT" << 'EOF'
#!/bin/bash

# Kubernetes initialization script for dev container
# This script runs when the container starts to configure kubectl access

set -e

# Define paths
KUBE_DIR="/home/vscode/.kube"
ORIGINAL_KUBECONFIG="$KUBE_DIR/config"
CONTAINER_KUBECONFIG="$KUBE_DIR/config-container"

echo "🔧 Initializing Kubernetes configuration for dev container..."

# Function to detect Docker gateway IP
detect_gateway_ip() {
    local gateway_ip
    
    # Try to get the default gateway
    gateway_ip=$(ip route show default 2>/dev/null | awk '/default/ {print $3}' | head -n1)
    
    # Fallback to common Docker gateway
    if [ -z "$gateway_ip" ]; then
        gateway_ip="172.17.0.1"
    fi
    
    echo "$gateway_ip"
}

# Function to detect Kubernetes API port
detect_k8s_port() {
    local port="6443"  # Default
    
    if [ -f "$ORIGINAL_KUBECONFIG" ]; then
        # Extract port from server URL
        local detected_port
        detected_port=$(grep -o 'server: https://[^:]*:\([0-9]\+\)' "$ORIGINAL_KUBECONFIG" 2>/dev/null | sed 's/.*://' | head -n1)
        if [ -n "$detected_port" ]; then
            port="$detected_port"
        fi
    fi
    
    echo "$port"
}

# Function to check if kubeconfig looks like a kind cluster
is_kind_cluster() {
    if [ -f "$ORIGINAL_KUBECONFIG" ]; then
        grep -q "127.0.0.1:" "$ORIGINAL_KUBECONFIG" 2>/dev/null
    else
        false
    fi
}

# Only proceed if original kubeconfig exists (mounted from host)
if [ ! -f "$ORIGINAL_KUBECONFIG" ]; then
    echo "ℹ️  No kubeconfig found at $ORIGINAL_KUBECONFIG"
    echo "   Mount your .kube directory to access the host Kubernetes cluster"
    echo "   Example: \"mounts\": [{\"source\": \"\${localEnv:HOME}/.kube\", \"target\": \"/home/vscode/.kube\", \"type\": \"bind\"}]"
    exit 0
fi

echo "📁 Found kubeconfig at $ORIGINAL_KUBECONFIG"

# Create backup if it doesn't exist
if [ ! -f "${ORIGINAL_KUBECONFIG}.backup" ]; then
    echo "💾 Creating backup of original kubeconfig"
    cp "$ORIGINAL_KUBECONFIG" "${ORIGINAL_KUBECONFIG}.backup"
fi

# Detect network configuration
GATEWAY_IP=$(detect_gateway_ip)
K8S_PORT=$(detect_k8s_port)

echo "🌐 Gateway IP: $GATEWAY_IP"
echo "🔍 Kubernetes API port: $K8S_PORT"

# Determine the best server URL for container access
if is_kind_cluster; then
    echo "🏷️  Detected kind cluster"
    SERVER_URL="https://host.docker.internal:$K8S_PORT"
else
    echo "�️  Detected standard Kubernetes cluster"
    SERVER_URL="https://$GATEWAY_IP:$K8S_PORT"
fi

echo "🔗 Using server URL: $SERVER_URL"

# Create container-specific kubeconfig
echo "📝 Creating container-specific kubeconfig..."
cp "$ORIGINAL_KUBECONFIG" "$CONTAINER_KUBECONFIG"

# Update server URLs for container-to-host connectivity
sed -i "s|server: https://kubernetes.docker.internal:[0-9]\+|server: $SERVER_URL|g" "$CONTAINER_KUBECONFIG"
sed -i "s|server: https://localhost:[0-9]\+|server: $SERVER_URL|g" "$CONTAINER_KUBECONFIG"
sed -i "s|server: https://127.0.0.1:[0-9]\+|server: $SERVER_URL|g" "$CONTAINER_KUBECONFIG"
sed -i "s|server: https://host.docker.internal:[0-9]\+|server: $SERVER_URL|g" "$CONTAINER_KUBECONFIG"

# Set proper ownership
chown vscode:vscode "$CONTAINER_KUBECONFIG"

# Export KUBECONFIG for the session
export KUBECONFIG="$CONTAINER_KUBECONFIG"

# Configure kubectl to skip TLS verification for container use
echo "� Configuring TLS settings..."
kubectl config set-cluster docker-desktop --insecure-skip-tls-verify=true 2>/dev/null || true

# Get the current context name and configure it
CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "")
if [ -n "$CURRENT_CONTEXT" ]; then
    # Get cluster name from context
    CLUSTER_NAME=$(kubectl config view -o jsonpath="{.contexts[?(@.name=='$CURRENT_CONTEXT')].context.cluster}" 2>/dev/null || echo "")
    if [ -n "$CLUSTER_NAME" ]; then
        kubectl config set-cluster "$CLUSTER_NAME" --insecure-skip-tls-verify=true 2>/dev/null || true
    fi
fi

# Test kubectl connection
echo "🧪 Testing kubectl connection..."
if timeout 10 kubectl get nodes &>/dev/null; then
    echo "✅ kubectl is working correctly!"
    echo ""
    echo "📊 Cluster information:"
    kubectl get nodes 2>/dev/null || echo "Could not retrieve node information"
else
    echo "❌ kubectl connection failed"
    echo ""
    if is_kind_cluster; then
        echo "⚠️  This appears to be a kind cluster bound to localhost."
        echo "   For dev container access, consider recreating the cluster with:"
        echo ""
        echo "   kind create cluster --config - <<EOF"
        echo "   kind: Cluster"
        echo "   apiVersion: kind.x-k8s.io/v1alpha4"
        echo "   networking:"
        echo "     apiServerAddress: \"0.0.0.0\""
        echo "     apiServerPort: 6443"
        echo "   EOF"
        echo ""
    else
        echo "💡 Troubleshooting steps:"
        echo "   - Ensure the Kubernetes cluster is running on the host"
        echo "   - Check that the .kube directory is properly mounted"
        echo "   - Verify network connectivity between container and host"
    fi
fi

# Set up environment for shell sessions
echo "🔧 Setting up environment for shell sessions..."

# Function to add KUBECONFIG to shell profile
add_to_profile() {
    local profile="$1"
    if [ -f "$profile" ] && ! grep -q "KUBECONFIG.*config-container" "$profile" 2>/dev/null; then
        echo "" >> "$profile"
        echo "# Dev container Kubernetes configuration" >> "$profile"
        echo "export KUBECONFIG=/home/vscode/.kube/config-container" >> "$profile"
    fi
}

# Add to various shell profiles
add_to_profile "/home/vscode/.bashrc"
add_to_profile "/home/vscode/.zshrc"
add_to_profile "/home/vscode/.profile"

echo ""
echo "🎉 Kubernetes configuration completed!"
echo ""
echo "📋 Configuration summary:"
echo "  • Original kubeconfig: $ORIGINAL_KUBECONFIG (unchanged)"
echo "  • Container kubeconfig: $CONTAINER_KUBECONFIG"
echo "  • Server URL: $SERVER_URL"
echo "  • TLS verification: disabled for container use"
echo ""
echo "💡 The KUBECONFIG environment variable is set for new shell sessions"
EOF

# Make the initialization script executable
chmod +x "$INIT_SCRIPT"

# Create a symlink to match the entrypoint specified in devcontainer-feature.json
ln -sf "$INIT_SCRIPT" "/usr/local/share/docker-init.sh"

log_success "✅ Kubernetes configuration feature installed successfully!"
log_info "📋 Next steps:"
log_info "  1. Mount your .kube directory in devcontainer.json:"
log_info "     \"mounts\": [{\"source\": \"\${localEnv:HOME}/.kube\", \"target\": \"/home/vscode/.kube\", \"type\": \"bind\"}]"
log_info "  2. Rebuild your dev container"
log_info "  3. The initialization script will run automatically on container start"

log_info "🔄 Running initialization script now..."
bash "$INIT_SCRIPT"
