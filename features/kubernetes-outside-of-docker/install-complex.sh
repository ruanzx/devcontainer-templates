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

# Detect the container user (prioritize actual user over existing users)
if [ "$(id -u)" = "0" ]; then
    # Running as root
    CONTAINER_USER="root"
elif [ -n "$_REMOTE_USER" ]; then
    CONTAINER_USER="$_REMOTE_USER"
elif [ -n "$REMOTE_USER" ]; then
    CONTAINER_USER="$REMOTE_USER"
elif [ -n "$USER" ]; then
    CONTAINER_USER="$USER"
elif getent passwd vscode >/dev/null 2>&1; then
    CONTAINER_USER="vscode"
elif getent passwd node >/dev/null 2>&1; then
    CONTAINER_USER="node"
else
    CONTAINER_USER="root"
fi

log_info "📋 Detected container user: $CONTAINER_USER"

# Get user home directory
if [ "$CONTAINER_USER" = "root" ]; then
    USER_HOME="/root"
else
    USER_HOME="/home/$CONTAINER_USER"
fi

log_info "📁 User home directory: $USER_HOME"

# Define paths
KUBE_DIR="$USER_HOME/.kube"

# Create .kube directory if it doesn't exist
if [ ! -d "$KUBE_DIR" ]; then
    log_info "📁 Creating .kube directory"
    mkdir -p "$KUBE_DIR"
    if [ "$CONTAINER_USER" != "root" ]; then
        chown -R "$CONTAINER_USER:$CONTAINER_USER" "$KUBE_DIR"
    fi
fi

# Create initialization script that will run when container starts
INIT_SCRIPT="/usr/local/share/kubernetes-init.sh"

log_info "📝 Creating Kubernetes initialization script"

# Create the initialization script with dynamic user detection
cat > "$INIT_SCRIPT" << 'INIT_SCRIPT_EOF'
#!/bin/bash

# Kubernetes initialization script for dev container
# This script runs when the container starts to configure kubectl access

set -e

# Detect the container user (prioritize actual user over existing users)
if [ "$(id -u)" = "0" ]; then
    # Running as root
    CONTAINER_USER="root"
elif [ -n "$_REMOTE_USER" ]; then
    CONTAINER_USER="$_REMOTE_USER"
elif [ -n "$REMOTE_USER" ]; then
    CONTAINER_USER="$REMOTE_USER"
elif [ -n "$USER" ]; then
    CONTAINER_USER="$USER"
elif getent passwd vscode >/dev/null 2>&1; then
    CONTAINER_USER="vscode"
elif getent passwd node >/dev/null 2>&1; then
    CONTAINER_USER="node"
else
    CONTAINER_USER="root"
fi

# Get user home directory
if [ "$CONTAINER_USER" = "root" ]; then
    USER_HOME="/root"
else
    USER_HOME="/home/$CONTAINER_USER"
fi

# Define paths
KUBE_DIR="$USER_HOME/.kube"
HOST_KUBE_MOUNT="/tmp/host-kube"
ORIGINAL_KUBECONFIG="$KUBE_DIR/config"
CONTAINER_KUBECONFIG="$KUBE_DIR/config-container"

echo "🔧 Initializing Kubernetes configuration for dev container..."
echo "📋 Container user: $CONTAINER_USER"
echo "📁 Kube directory: $KUBE_DIR"
echo "📂 Host mount: $HOST_KUBE_MOUNT"

# Create user .kube directory if needed
if [ ! -d "$KUBE_DIR" ]; then
    echo "📁 Creating user .kube directory"
    mkdir -p "$KUBE_DIR"
    if [ "$CONTAINER_USER" != "root" ]; then
        chown -R "$CONTAINER_USER:$CONTAINER_USER" "$KUBE_DIR"
    fi
fi

# Check if host mount directory exists
if [ ! -d "$HOST_KUBE_MOUNT" ]; then
    echo "⚠️  Host .kube directory not mounted at $HOST_KUBE_MOUNT"
    echo "   To use this feature, you need to mount your host .kube directory:"
    echo "   Add this to your devcontainer.json mounts:"
    echo "   {"
    echo "     \"source\": \"\${localEnv:HOME}/.kube\","
    echo "     \"target\": \"/tmp/host-kube\","
    echo "     \"type\": \"bind\""
    echo "   }"
    echo "   For Windows, use \${localEnv:USERPROFILE} instead of \${localEnv:HOME}"
    exit 0
fi

# Copy host kubeconfig if available
if [ -f "$HOST_KUBE_MOUNT/config" ]; then
    echo "📋 Copying host kubeconfig to user directory"
    cp "$HOST_KUBE_MOUNT/config" "$ORIGINAL_KUBECONFIG"
    if [ "$CONTAINER_USER" != "root" ]; then
        chown "$CONTAINER_USER:$CONTAINER_USER" "$ORIGINAL_KUBECONFIG"
    fi
elif [ ! -f "$ORIGINAL_KUBECONFIG" ]; then
    echo "ℹ️  No kubeconfig found in host mount at $HOST_KUBE_MOUNT/config"
    echo "   To use this feature, you need to mount your host .kube directory:"
    echo "   Add this to your devcontainer.json mounts:"
    echo "   {"
    echo "     \"source\": \"\${localEnv:HOME}/.kube\","
    echo "     \"target\": \"/tmp/host-kube\","
    echo "     \"type\": \"bind\""
    echo "   }"
    echo "   For Windows, use \${localEnv:USERPROFILE} instead of \${localEnv:HOME}"
    exit 0
fi

# Only proceed if we have a kubeconfig to work with
if [ ! -f "$ORIGINAL_KUBECONFIG" ]; then
    echo "ℹ️  No kubeconfig available for processing"
    exit 0
fi

echo "📁 Found kubeconfig at $ORIGINAL_KUBECONFIG"

# Create backup if it doesn't exist
if [ ! -f "${ORIGINAL_KUBECONFIG}.backup" ]; then
    echo "💾 Creating backup of original kubeconfig"
    cp "$ORIGINAL_KUBECONFIG" "${ORIGINAL_KUBECONFIG}.backup"
fi

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
    echo "🏷️  Detected standard Kubernetes cluster"
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
if [ "$CONTAINER_USER" != "root" ]; then
    chown "$CONTAINER_USER:$CONTAINER_USER" "$CONTAINER_KUBECONFIG"
fi

# Export KUBECONFIG for the session
export KUBECONFIG="$CONTAINER_KUBECONFIG"

# Configure kubectl to skip TLS verification for container use
echo "🔐 Configuring TLS settings..."
if command -v kubectl >/dev/null 2>&1; then
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
else
    echo "⚠️  kubectl not found - skipping connection test"
    echo "   kubectl should be installed by the kubectl feature dependency"
fi

# Set up environment for shell sessions
echo "🔧 Setting up environment for shell sessions..."

# Export KUBECONFIG for current session
export KUBECONFIG="$CONTAINER_KUBECONFIG"
echo "🔧 KUBECONFIG set to: $KUBECONFIG"

# Function to add KUBECONFIG to shell profile
add_to_profile() {
    local profile="$1"
    if [ -f "$profile" ] && ! grep -q "KUBECONFIG.*config-container" "$profile" 2>/dev/null; then
        echo "" >> "$profile"
        echo "# Dev container Kubernetes configuration" >> "$profile"
        echo "export KUBECONFIG=$USER_HOME/.kube/config-container" >> "$profile"
    fi
}

# Add to various shell profiles
add_to_profile "$USER_HOME/.bashrc"
add_to_profile "$USER_HOME/.zshrc"
add_to_profile "$USER_HOME/.profile"

# Set proper ownership for all created files
if [ "$CONTAINER_USER" != "root" ]; then
    chown -R "$CONTAINER_USER:$CONTAINER_USER" "$KUBE_DIR" 2>/dev/null || true
    chown "$CONTAINER_USER:$CONTAINER_USER" "$USER_HOME/.bashrc" 2>/dev/null || true
    chown "$CONTAINER_USER:$CONTAINER_USER" "$USER_HOME/.zshrc" 2>/dev/null || true
    chown "$CONTAINER_USER:$CONTAINER_USER" "$USER_HOME/.profile" 2>/dev/null || true
fi

echo ""
echo "🎉 Kubernetes configuration completed!"
echo ""
echo "📋 Configuration summary:"
echo "  • Container user: $CONTAINER_USER"
echo "  • Original kubeconfig: $ORIGINAL_KUBECONFIG (unchanged)"
echo "  • Container kubeconfig: $CONTAINER_KUBECONFIG"
echo "  • Server URL: $SERVER_URL"
echo "  • TLS verification: disabled for container use"
echo ""
echo "💡 The KUBECONFIG environment variable is set for new shell sessions"
INIT_SCRIPT_EOF

# Make the initialization script executable
chmod +x "$INIT_SCRIPT"

# Create a symlink to match the entrypoint specified in devcontainer-feature.json
ln -sf "$INIT_SCRIPT" "/usr/local/share/docker-init.sh"

log_success "✅ Kubernetes configuration feature installed successfully!"
log_info "📋 Configuration details:"
log_info "  • Container user: $CONTAINER_USER"
log_info "  • Kube directory: $KUBE_DIR"
log_info "  • Initialization script: $INIT_SCRIPT"
log_info ""
log_info "💡 The feature will automatically:"
log_info "  1. Mount host .kube directory from \${localEnv:HOME}/.kube to /tmp/host-kube"
log_info "  2. Copy kubeconfig to user directory during initialization"
log_info "  3. Configure kubectl for container-to-host connectivity"
log_info "  4. Run initialization script on container start via entrypoint"

log_info "🔄 Running initialization script now..."
bash "$INIT_SCRIPT"

# Set KUBECONFIG environment variable for current session
if [ "$CONTAINER_USER" = "root" ]; then
    CONTAINER_KUBECONFIG="/root/.kube/config-container"
else
    CONTAINER_KUBECONFIG="/home/$CONTAINER_USER/.kube/config-container"
fi

if [ -f "$CONTAINER_KUBECONFIG" ]; then
    export KUBECONFIG="$CONTAINER_KUBECONFIG"
    log_success "🔧 KUBECONFIG set to: $KUBECONFIG"
    
    # Create a global environment file that can be sourced
    mkdir -p /etc/environment.d
    echo "export KUBECONFIG=\"$CONTAINER_KUBECONFIG\"" > /etc/environment.d/99-kubernetes.conf
    echo "export KUBECONFIG=\"$CONTAINER_KUBECONFIG\"" >> /etc/environment
fi

# Create a kubectl wrapper to ensure config is loaded
cat > /usr/local/bin/kubectl-wrapper << 'KUBECTL_WRAPPER_EOF'
#!/bin/bash
# Ensure Kubernetes configuration is loaded before running kubectl

# Detect user and set KUBECONFIG if not already set
if [ -z "$KUBECONFIG" ]; then
    if [ "$(id -u)" = "0" ]; then
        # Running as root
        export KUBECONFIG="/root/.kube/config-container"
    elif [ -n "$HOME" ]; then
        export KUBECONFIG="$HOME/.kube/config-container"
    else
        export KUBECONFIG="/home/vscode/.kube/config-container"
    fi
fi

# Run the initialization script if config doesn't exist
if [ ! -f "$KUBECONFIG" ] && [ -f "/usr/local/share/kubernetes-init.sh" ]; then
    echo "🔧 Running Kubernetes initialization..."
    bash /usr/local/share/kubernetes-init.sh
fi

# Verify KUBECONFIG is set and file exists
if [ -z "$KUBECONFIG" ] || [ ! -f "$KUBECONFIG" ]; then
    echo "❌ Error: No valid kubeconfig found. Please ensure:"
    echo "   1. Host .kube directory is mounted to /tmp/host-kube"
    echo "   2. Host kubeconfig exists and is accessible"
    exit 1
fi

# Run the original kubectl command
exec /usr/local/bin/kubectl-orig "$@"
KUBECTL_WRAPPER_EOF

# Backup original kubectl and replace with wrapper
if [ -f "/usr/local/bin/kubectl" ]; then
    mv /usr/local/bin/kubectl /usr/local/bin/kubectl-orig
    mv /usr/local/bin/kubectl-wrapper /usr/local/bin/kubectl
    chmod +x /usr/local/bin/kubectl
    log_success "🔧 kubectl wrapper installed"
fi

# Also create a kubectl function that ensures KUBECONFIG is set
cat > /etc/profile.d/kubernetes.sh << 'KUBECTL_PROFILE_EOF'
#!/bin/bash
# Ensure KUBECONFIG is always set for kubectl

# Function to set KUBECONFIG
set_kubeconfig() {
    if [ "$(id -u)" = "0" ]; then
        export KUBECONFIG="/root/.kube/config-container"
    elif [ -n "$HOME" ]; then
        export KUBECONFIG="$HOME/.kube/config-container"
    else
        export KUBECONFIG="/home/vscode/.kube/config-container"
    fi
}

# Set KUBECONFIG when profile is loaded
set_kubeconfig

# Create kubectl function that ensures config is set
kubectl() {
    # Ensure KUBECONFIG is set
    if [ -z "$KUBECONFIG" ]; then
        set_kubeconfig
    fi
    
    # Run initialization if needed
    if [ ! -f "$KUBECONFIG" ] && [ -f "/usr/local/share/kubernetes-init.sh" ]; then
        echo "🔧 Running Kubernetes initialization..."
        bash /usr/local/share/kubernetes-init.sh
    fi
    
    # Call the original kubectl
    command kubectl "$@"
}
KUBECTL_PROFILE_EOF

chmod +x /etc/profile.d/kubernetes.sh
log_success "🔧 kubectl profile script installed"

log_success "🎉 Kubernetes outside-of-docker feature setup complete!"
