#!/bin/bash

# kubernetes-outside-of-docker feature installer
# Simple, clean implementation to access host Kubernetes cluster from dev container

set -e

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "${SCRIPT_DIR}/utils.sh" ]]; then
    source "${SCRIPT_DIR}/utils.sh"
elif [[ -f "${SCRIPT_DIR}/../../common/utils.sh" ]]; then
    source "${SCRIPT_DIR}/../../common/utils.sh"
else
    echo "Error: Could not find utils.sh"
    exit 1
fi

log_info "🔧 Setting up Kubernetes access from dev container..."

# Simple user detection
if [ "$(id -u)" = "0" ]; then
    CONTAINER_USER="root"
    USER_HOME="/root"
else
    CONTAINER_USER="${USER:-vscode}"
    USER_HOME="${HOME:-/home/$CONTAINER_USER}"
fi

log_info "📋 Container user: $CONTAINER_USER"
log_info "📁 User home: $USER_HOME"

KUBE_DIR="$USER_HOME/.kube"
HOST_KUBE_MOUNT="/tmp/host-kube"

# Ensure .kube directory exists
mkdir -p "$KUBE_DIR"
if [ "$CONTAINER_USER" != "root" ]; then
    chown -R "$CONTAINER_USER:$CONTAINER_USER" "$KUBE_DIR" 2>/dev/null || true
fi

# Check if host mount exists
if [ ! -d "$HOST_KUBE_MOUNT" ]; then
    log_warning "⚠️  Host .kube directory not mounted at $HOST_KUBE_MOUNT"
    log_info "Add this mount to your devcontainer.json:"
    echo '{
  "mounts": [
    {
      "source": "${localEnv:HOME}/.kube",
      "target": "/tmp/host-kube",
      "type": "bind"
    }
  ]
}'
    exit 0
fi

# Copy host kubeconfig if available
if [ -f "$HOST_KUBE_MOUNT/config" ]; then
    log_info "📋 Copying host kubeconfig"
    cp "$HOST_KUBE_MOUNT/config" "$KUBE_DIR/config"
    if [ "$CONTAINER_USER" != "root" ]; then
        chown "$CONTAINER_USER:$CONTAINER_USER" "$KUBE_DIR/config"
    fi
else
    log_warning "⚠️  No kubeconfig found at $HOST_KUBE_MOUNT/config"
    exit 0
fi

# Create simple initialization script
cat > "$KUBE_DIR/init-k8s.sh" << 'EOF'
#!/bin/bash
# Simple Kubernetes configuration for dev container

KUBE_CONFIG="$HOME/.kube/config"
CONTAINER_CONFIG="$HOME/.kube/config-container"

# Exit if no config
if [ ! -f "$KUBE_CONFIG" ]; then
    echo "No kubeconfig found"
    exit 0
fi

# Create container-specific config if it doesn't exist
if [ ! -f "$CONTAINER_CONFIG" ]; then
    echo "🔧 Creating container-specific kubeconfig..."
    
    # Copy original config
    cp "$KUBE_CONFIG" "$CONTAINER_CONFIG"
    
    # Get gateway IP for host connectivity
    GATEWAY_IP=$(ip route show default | awk '/default/ {print $3}' | head -n1)
    if [ -z "$GATEWAY_IP" ]; then
        GATEWAY_IP="172.17.0.1"
    fi
    
    echo "🌐 Using gateway IP: $GATEWAY_IP"
    
    # Update server URLs to use gateway IP
    sed -i "s|server: https://127.0.0.1:|server: https://$GATEWAY_IP:|g" "$CONTAINER_CONFIG"
    sed -i "s|server: https://localhost:|server: https://$GATEWAY_IP:|g" "$CONTAINER_CONFIG"
    
    # Disable certificate verification for container use
    kubectl config set-cluster --kubeconfig="$CONTAINER_CONFIG" \
        $(kubectl config current-context --kubeconfig="$CONTAINER_CONFIG") \
        --insecure-skip-tls-verify=true 2>/dev/null || true
        
    echo "✅ Container kubeconfig ready"
fi

# Set KUBECONFIG environment variable
export KUBECONFIG="$CONTAINER_CONFIG"
EOF

chmod +x "$KUBE_DIR/init-k8s.sh"

# Simple environment setup - just one file
cat > /etc/profile.d/kubernetes-simple.sh << 'EOF'
#!/bin/bash
# Simple Kubernetes environment setup

# Set KUBECONFIG to container-specific config
if [ "$(id -u)" = "0" ]; then
    export KUBECONFIG="/root/.kube/config-container"
else
    export KUBECONFIG="$HOME/.kube/config-container"
fi

# Initialize if needed
if [ ! -f "$KUBECONFIG" ] && [ -f "$HOME/.kube/init-k8s.sh" ]; then
    bash "$HOME/.kube/init-k8s.sh"
fi
EOF

chmod +x /etc/profile.d/kubernetes-simple.sh

# Run initialization now
log_info "🔄 Running initial setup..."
if [ "$CONTAINER_USER" = "root" ]; then
    export HOME="/root"
else
    export HOME="$USER_HOME"
fi

bash "$KUBE_DIR/init-k8s.sh"

# Set KUBECONFIG for current session
if [ -f "$KUBE_DIR/config-container" ]; then
    export KUBECONFIG="$KUBE_DIR/config-container"
    log_success "✅ KUBECONFIG set to: $KUBECONFIG"
    
    # Test kubectl if available
    if command -v kubectl >/dev/null 2>&1; then
        log_info "🧪 Testing kubectl connection..."
        if kubectl cluster-info --request-timeout=5s >/dev/null 2>&1; then
            log_success "✅ kubectl is working!"
            kubectl get nodes 2>/dev/null | head -n 5 || true
        else
            log_warning "⚠️  kubectl connection test failed (this is normal during installation)"
        fi
    fi
fi

log_success "🎉 Kubernetes outside-of-docker feature setup complete!"
log_info "💡 Restart your shell or container to ensure all environment variables are loaded"
