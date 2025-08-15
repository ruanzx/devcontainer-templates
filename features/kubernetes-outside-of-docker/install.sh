#!/bin/bash

# kubernetes-outside-of-docker feature installer
# Super simple implementation to access host Kubernetes cluster from dev container

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
    log_info "📋 Copying and fixing host kubeconfig"
    
    # Get gateway IP for host connectivity
    GATEWAY_IP=$(ip route show default | awk '/default/ {print $3}' | head -n1)
    if [ -z "$GATEWAY_IP" ]; then
        GATEWAY_IP="172.17.0.1"
    fi
    log_info "🌐 Using gateway IP: $GATEWAY_IP"
    
    # Copy and immediately fix the kubeconfig
    cp "$HOST_KUBE_MOUNT/config" "$KUBE_DIR/config"
    
    # Show original content for debugging
    log_info "🔍 Original server URLs:"
    grep "server:" "$KUBE_DIR/config" || log_warning "No server entries found in kubeconfig"
    
    # Replace ALL localhost, 127.0.0.1, and kubernetes.docker.internal references with gateway IP
    # More comprehensive patterns to catch various formats
    sed -i "s|server: https://127\.0\.0\.1[:/]|server: https://$GATEWAY_IP:|g" "$KUBE_DIR/config"
    sed -i "s|server: https://localhost[:/]|server: https://$GATEWAY_IP:|g" "$KUBE_DIR/config"
    sed -i "s|server: http://127\.0\.0\.1[:/]|server: http://$GATEWAY_IP:|g" "$KUBE_DIR/config"
    sed -i "s|server: http://localhost[:/]|server: http://$GATEWAY_IP:|g" "$KUBE_DIR/config"
    sed -i "s|server: https://127\.0\.0\.1$|server: https://$GATEWAY_IP:6443|g" "$KUBE_DIR/config"
    sed -i "s|server: https://localhost$|server: https://$GATEWAY_IP:6443|g" "$KUBE_DIR/config"
    sed -i "s|server: http://127\.0\.0\.1$|server: http://$GATEWAY_IP:8080|g" "$KUBE_DIR/config"
    sed -i "s|server: http://localhost$|server: http://$GATEWAY_IP:8080|g" "$KUBE_DIR/config"
    
    # Handle Docker Desktop's kubernetes.docker.internal
    sed -i "s|server: https://kubernetes\.docker\.internal[:/]|server: https://$GATEWAY_IP:|g" "$KUBE_DIR/config"
    sed -i "s|server: http://kubernetes\.docker\.internal[:/]|server: http://$GATEWAY_IP:|g" "$KUBE_DIR/config"
    sed -i "s|server: https://kubernetes\.docker\.internal$|server: https://$GATEWAY_IP:6443|g" "$KUBE_DIR/config"
    sed -i "s|server: http://kubernetes\.docker\.internal$|server: http://$GATEWAY_IP:8080|g" "$KUBE_DIR/config"
    
    # Show updated content for debugging
    log_info "🔧 Updated server URLs:"
    grep "server:" "$KUBE_DIR/config" || log_warning "No server entries found after replacement"
    
    # Set ownership
    if [ "$CONTAINER_USER" != "root" ]; then
        chown "$CONTAINER_USER:$CONTAINER_USER" "$KUBE_DIR/config"
    fi
    
    log_info "🔧 Kubeconfig server URLs updated to use $GATEWAY_IP"
else
    log_warning "⚠️  No kubeconfig found at $HOST_KUBE_MOUNT/config"
    log_info "💡 Creating a minimal kubeconfig to prevent kubectl from defaulting to localhost:8080"
    
    # Create a basic kubeconfig that will fail gracefully instead of defaulting to localhost:8080
    cat > "$KUBE_DIR/config" << EOF
apiVersion: v1
kind: Config
current-context: ""
contexts: []
clusters: []
users: []
EOF
    
    if [ "$CONTAINER_USER" != "root" ]; then
        chown "$CONTAINER_USER:$CONTAINER_USER" "$KUBE_DIR/config"
    fi
    
    log_warning "⚠️  No host cluster configuration available"
    exit 0
fi

# Simple environment setup - ensure KUBECONFIG is always set
cat > /etc/profile.d/kubernetes-outside-docker.sh << EOF
# Set KUBECONFIG environment variable for kubernetes-outside-of-docker feature
if [ "\$(id -u)" = "0" ]; then
    export KUBECONFIG="/root/.kube/config"
else
    export KUBECONFIG="\$HOME/.kube/config"
fi

# Ensure kubeconfig exists and is readable
if [ ! -f "\$KUBECONFIG" ]; then
    echo "Warning: KUBECONFIG file \$KUBECONFIG not found" >&2
fi
EOF

chmod +x /etc/profile.d/kubernetes-outside-docker.sh

# Set KUBECONFIG for current session
export KUBECONFIG="$KUBE_DIR/config"
log_success "✅ KUBECONFIG set to: $KUBECONFIG"

# Test kubectl if available
if command -v kubectl >/dev/null 2>&1; then
    log_info "🧪 Testing kubectl configuration..."
    
    # Verify KUBECONFIG is properly set and file exists
    if [ -f "$KUBECONFIG" ]; then
        log_info "✅ KUBECONFIG file exists: $KUBECONFIG"
        
        # Show current context info
        if kubectl config current-context --request-timeout=2s >/dev/null 2>&1; then
            CURRENT_CONTEXT=$(kubectl config current-context)
            log_info "📋 Current context: $CURRENT_CONTEXT"
        else
            log_warning "⚠️  No current context set or invalid configuration"
        fi
        
        # Test actual connection with short timeout
        if kubectl cluster-info --request-timeout=3s >/dev/null 2>&1; then
            log_success "✅ kubectl connection successful!"
            kubectl get nodes --request-timeout=3s 2>/dev/null | head -n 3 || true
        else
            log_warning "⚠️  kubectl connection test failed"
            log_info "💡 This may be normal if the cluster requires authentication or is not accessible"
            log_info "💡 Try running 'kubectl get nodes' manually to test connectivity"
        fi
    else
        log_error "❌ KUBECONFIG file not found: $KUBECONFIG"
    fi
else
    log_info "ℹ️  kubectl not found - install kubectl feature first"
fi

log_success "🎉 Kubernetes outside-of-docker setup complete!"
log_info "💡 KUBECONFIG is now set to use the gateway IP ($GATEWAY_IP) for host cluster access"
