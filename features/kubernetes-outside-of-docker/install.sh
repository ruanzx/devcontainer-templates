#!/bin/bash

# kubernetes-outside-of-docker feature installer
# Simple, clean implementation to access host Kubernetes cluster from dev container

set -euo pipefail  # Enhanced error handling: exit on error, undefined vars, pipe failures

# Add debug logging to track execution
echo "🐛 DEBUG: kubernetes-outside-of-docker feature install script started at $(date)"
echo "🐛 DEBUG: Running as user: $(id)"
echo "🐛 DEBUG: PWD: $(pwd)"
echo "🐛 DEBUG: Script path: ${BASH_SOURCE[0]}"

# Enhanced error handling
trap 'echo "🐛 ERROR: Script failed at line $LINENO with exit code $?" >&2' ERR

# Define logging functions (fallback if utils.sh is not available)
log_info() {
    echo "ℹ️  $1"
}

log_warning() {
    echo "⚠️  $1"
}

log_success() {
    echo "✅ $1"
}

# Source common utilities if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🐛 DEBUG: Script directory: $SCRIPT_DIR"
echo "🐛 DEBUG: Checking for utils.sh files..."

if [[ -f "${SCRIPT_DIR}/utils.sh" ]]; then
    echo "🐛 DEBUG: Found utils.sh in script directory"
    source "${SCRIPT_DIR}/utils.sh"
elif [[ -f "${SCRIPT_DIR}/../../common/utils.sh" ]]; then
    echo "🐛 DEBUG: Found utils.sh in common directory"
    source "${SCRIPT_DIR}/../../common/utils.sh"
else
    echo "🐛 DEBUG: utils.sh not found, using built-in logging functions"
    log_warning "utils.sh not found, using built-in logging functions"
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
HOST_KUBE_MOUNT="/tmp/.kube"
INIT_SCRIPT="/usr/local/share/kubernetes-init.sh"

# Ensure .kube directory exists
mkdir -p "$KUBE_DIR"
if [ "$CONTAINER_USER" != "root" ]; then
    chown -R "$CONTAINER_USER:$CONTAINER_USER" "$KUBE_DIR" 2>/dev/null || true
fi

# Create runtime initialization script for dynamic configuration
log_info "📝 Creating runtime initialization script"

# Ensure the directory exists
mkdir -p "$(dirname "$INIT_SCRIPT")"

# Add debug info to track script creation
echo "🐛 DEBUG: Creating init script at: $INIT_SCRIPT"
cat > "$INIT_SCRIPT" << 'INIT_SCRIPT_EOF'
#!/bin/bash

# Kubernetes runtime initialization script
# This script configures kubectl access when the container starts or when kubectl is run

set -e

# Detect the container user
if [ "$(id -u)" = "0" ]; then
    CONTAINER_USER="root"
    USER_HOME="/root"
elif [ -n "$_REMOTE_USER" ]; then
    CONTAINER_USER="$_REMOTE_USER"
    USER_HOME="/home/$_REMOTE_USER"
elif [ -n "$USER" ]; then
    CONTAINER_USER="$USER"
    USER_HOME="${HOME:-/home/$USER}"
else
    CONTAINER_USER="vscode"
    USER_HOME="/home/vscode"
fi

KUBE_DIR="$USER_HOME/.kube"
HOST_KUBE_MOUNT="/tmp/.kube"

# Ensure .kube directory exists
mkdir -p "$KUBE_DIR"
if [ "$CONTAINER_USER" != "root" ] && command -v chown >/dev/null 2>&1; then
    chown -R "$CONTAINER_USER:$CONTAINER_USER" "$KUBE_DIR" 2>/dev/null || true
fi

# Check if host mount directory exists
if [ ! -d "$HOST_KUBE_MOUNT" ]; then
    echo "⚠️  Host .kube directory not mounted at $HOST_KUBE_MOUNT"
    echo "   Add this mount to your devcontainer.json:"
    echo '   {
     "source": "${localEnv:HOME}/.kube",
     "target": "/tmp/.kube",
     "type": "bind"
   }'
    echo "   For Windows, use \${localEnv:USERPROFILE} instead of \${localEnv:HOME}"
    return 0 2>/dev/null || exit 0
fi

# Copy and fix host kubeconfig if available
if [ -f "$HOST_KUBE_MOUNT/config" ]; then
    echo "📋 Configuring kubectl for container access..."
    
    # Copy the original config first
    cp "$HOST_KUBE_MOUNT/config" "$KUBE_DIR/config"
    
    # Detect Kubernetes distribution for appropriate IP selection
    KUBE_CONTEXT=""
    KUBE_CLUSTER=""
    if grep -q "rancher-desktop" "$HOST_KUBE_MOUNT/config" 2>/dev/null; then
        echo "🐄 Detected Rancher Desktop"
        KUBE_CONTEXT="rancher-desktop"
        KUBE_CLUSTER="rancher-desktop"
    elif grep -q "docker-desktop" "$HOST_KUBE_MOUNT/config" 2>/dev/null; then
        echo "🐳 Detected Docker Desktop"
        KUBE_CONTEXT="docker-desktop"
        KUBE_CLUSTER="docker-desktop"
    fi
    
    # Get gateway IP for fallback
    GATEWAY_IP=$(ip route show default 2>/dev/null | awk '/default/ {print $3}' | head -n1)
    if [ -z "$GATEWAY_IP" ]; then
        GATEWAY_IP="172.17.0.1"
    fi
    
    TARGET_IP=""
    
    # For Rancher Desktop, use certificate-valid IPs
    if [ "$KUBE_CONTEXT" = "rancher-desktop" ]; then
        echo "🔍 Testing Rancher Desktop certificate-valid IPs..."
        
        # Test connectivity to certificate-valid IPs for Rancher Desktop
        # Certificate is valid for: 10.43.0.1, 127.0.0.1, 192.168.127.2, 192.168.143.1, ::1
        for test_ip in "192.168.127.2" "192.168.143.1" "10.43.0.1"; do
            echo "  Testing $test_ip:6443..."
            if timeout 2 bash -c "echo >/dev/tcp/$test_ip/6443" 2>/dev/null; then
                TARGET_IP="$test_ip"
                echo "  ✅ $test_ip:6443 is reachable and certificate-valid"
                break
            else
                echo "  ❌ $test_ip:6443 is not reachable"
            fi
        done
        
        if [ -z "$TARGET_IP" ]; then
            echo "⚠️  No certificate-valid IPs found for Rancher Desktop, using gateway IP"
            TARGET_IP="$GATEWAY_IP"
        fi
    
    # For Docker Desktop, try the known working IP that matches certificates
    elif [ "$KUBE_CONTEXT" = "docker-desktop" ]; then
        DOCKER_DESKTOP_IP="192.168.65.3"
        if timeout 2 bash -c "echo >/dev/tcp/$DOCKER_DESKTOP_IP/6443" 2>/dev/null; then
            TARGET_IP="$DOCKER_DESKTOP_IP"
            echo "🐳 Using Docker Desktop IP: $TARGET_IP"
        else
            TARGET_IP="$GATEWAY_IP"
            echo "🌐 Docker Desktop IP not reachable, using gateway IP: $TARGET_IP"
        fi
    
    # For other distributions, use gateway IP
    else
        TARGET_IP="$GATEWAY_IP"
        echo "🌐 Using gateway IP: $TARGET_IP"
    fi
    
    # Replace only localhost and 127.0.0.1 with target IP
    # Leave kubernetes.docker.internal as-is since it resolves correctly and matches the certificate
    sed -i "s|server: https://127\.0\.0\.1[:/]|server: https://$TARGET_IP:|g" "$KUBE_DIR/config"
    sed -i "s|server: https://localhost[:/]|server: https://$TARGET_IP:|g" "$KUBE_DIR/config"
    sed -i "s|server: http://127\.0\.0\.1[:/]|server: http://$TARGET_IP:|g" "$KUBE_DIR/config"
    sed -i "s|server: http://localhost[:/]|server: http://$TARGET_IP:|g" "$KUBE_DIR/config"
    sed -i "s|server: https://127\.0\.0\.1$|server: https://$TARGET_IP:6443|g" "$KUBE_DIR/config"
    sed -i "s|server: https://localhost$|server: https://$TARGET_IP:6443|g" "$KUBE_DIR/config"
    sed -i "s|server: http://127\.0\.0\.1$|server: http://$TARGET_IP:8080|g" "$KUBE_DIR/config"
    sed -i "s|server: http://localhost$|server: http://$TARGET_IP:8080|g" "$KUBE_DIR/config"
    
    # Note: kubernetes.docker.internal is left unchanged as it resolves correctly in containers
    
    # Set ownership
    if [ "$CONTAINER_USER" != "root" ] && command -v chown >/dev/null 2>&1; then
        chown "$CONTAINER_USER:$CONTAINER_USER" "$KUBE_DIR/config" 2>/dev/null || true
    fi
    
    echo "✅ Kubernetes configuration updated for container access"
else
    echo "ℹ️  No kubeconfig found at $HOST_KUBE_MOUNT/config"
fi

# Set KUBECONFIG environment variable
export KUBECONFIG="$KUBE_DIR/config"
INIT_SCRIPT_EOF

chmod +x "$INIT_SCRIPT"

echo "🐛 DEBUG: Init script created and made executable"
ls -la "$INIT_SCRIPT"

# Create symlink for compatibility with existing documentation
ln -sf "$INIT_SCRIPT" "/usr/local/share/docker-init.sh"

echo "🐛 DEBUG: Symlink created"
ls -la "/usr/local/share/docker-init.sh"

# Check if host mount exists for initial setup
if [ ! -d "$HOST_KUBE_MOUNT" ]; then
    log_warning "⚠️  Host .kube directory not mounted at $HOST_KUBE_MOUNT"
    log_info "Add this mount to your devcontainer.json:"
    echo '{
  "mounts": [
    {
      "source": "${localEnv:HOME}/.kube",
      "target": "/tmp/.kube",
      "type": "bind"
    }
  ]
}'
fi

# Run initial configuration if host mount is available
if [ -d "$HOST_KUBE_MOUNT" ]; then
    log_info "� Running initial configuration..."
    bash "$INIT_SCRIPT"
fi

# Set up environment variables for shell sessions
log_info "🔧 Setting up environment variables..."

# Ensure the directory exists
mkdir -p /etc/profile.d

echo "🐛 DEBUG: Creating profile script at: /etc/profile.d/kubernetes-outside-docker.sh"
cat > /etc/profile.d/kubernetes-outside-docker.sh << 'PROFILE_EOF'
#!/bin/bash
# Kubernetes outside-of-docker environment setup

# Debug logging (can be disabled by setting KUBE_DEBUG=false)
if [[ "${KUBE_DEBUG:-true}" == "true" ]]; then
    echo "🐛 DEBUG: Loading kubernetes-outside-docker profile script"
fi

# Set KUBECONFIG based on user
if [ "$(id -u)" = "0" ]; then
    export KUBECONFIG="/root/.kube/config"
else
    export KUBECONFIG="$HOME/.kube/config"
fi

# Function to run kubernetes initialization if needed
ensure_kubectl_config() {
    if [ ! -f "$KUBECONFIG" ] && [ -f "/usr/local/share/kubernetes-init.sh" ]; then
        echo "🔧 Initializing Kubernetes configuration..."
        bash /usr/local/share/kubernetes-init.sh
    fi
}

# Run initialization automatically when profile loads
ensure_kubectl_config 2>/dev/null || true

# Create kubectl function that ensures config is properly initialized
if command -v kubectl >/dev/null 2>&1; then
    kubectl() {
        # Ensure initialization runs before kubectl commands
        ensure_kubectl_config 2>/dev/null || true
        command kubectl "$@"
    }
    export -f kubectl
fi

# Also set up for zsh if present
if [ -n "$ZSH_VERSION" ]; then
    if command -v kubectl >/dev/null 2>&1; then
        kubectl() {
            ensure_kubectl_config 2>/dev/null || true
            command kubectl "$@"
        }
    fi
fi

if [[ "${KUBE_DEBUG:-true}" == "true" ]]; then
    echo "🐛 DEBUG: kubernetes-outside-docker profile script loaded, KUBECONFIG=$KUBECONFIG"
fi
PROFILE_EOF

chmod +x /etc/profile.d/kubernetes-outside-docker.sh

echo "🐛 DEBUG: Profile script created and made executable"
ls -la /etc/profile.d/kubernetes-outside-docker.sh

# Also add to bashrc for non-login shells
echo "🐛 DEBUG: Adding to bashrc for non-login shells"
echo '# Source kubernetes configuration for non-login shells' >> /etc/bash.bashrc
echo 'if [ -f /etc/profile.d/kubernetes-outside-docker.sh ]; then' >> /etc/bash.bashrc
echo '    . /etc/profile.d/kubernetes-outside-docker.sh' >> /etc/bash.bashrc
echo 'fi' >> /etc/bash.bashrc

echo "🐛 DEBUG: bashrc updated"
tail -n 5 /etc/bash.bashrc

# Set KUBECONFIG for current session
export KUBECONFIG="$KUBE_DIR/config"
log_success "✅ KUBECONFIG set to: $KUBECONFIG"

echo "🐛 DEBUG: kubernetes-outside-of-docker feature install script completed successfully at $(date)"

# Create installation marker
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/install-marker.sh" ]]; then
    echo "🐛 DEBUG: Creating installation marker"
    bash "$SCRIPT_DIR/install-marker.sh"
fi

# Final validation
if [[ -f /usr/local/share/kubernetes-init.sh ]] && [[ -f /etc/profile.d/kubernetes-outside-docker.sh ]]; then
    echo "🐛 DEBUG: ✅ All required files created successfully"
else
    echo "🐛 DEBUG: ❌ Some required files are missing!"
    echo "🐛 DEBUG: kubernetes-init.sh exists: $(test -f /usr/local/share/kubernetes-init.sh && echo 'YES' || echo 'NO')"
    echo "🐛 DEBUG: profile script exists: $(test -f /etc/profile.d/kubernetes-outside-docker.sh && echo 'YES' || echo 'NO')"
fi

# Test kubectl if available and configuration exists
if command -v kubectl >/dev/null 2>&1; then
    log_info "🧪 Testing kubectl configuration..."
    
    # Verify KUBECONFIG file exists
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
        log_warning "⚠️  KUBECONFIG file not found: $KUBECONFIG"
        log_info "💡 Configuration will be created when container starts with proper mount"
    fi
else
    log_info "ℹ️  kubectl not found - install kubectl feature first"
fi

log_success "🎉 Kubernetes outside-of-docker setup complete!"
log_info ""
log_info "� Setup summary:"
log_info "  • Runtime initialization script: $INIT_SCRIPT"
log_info "  • Mount host .kube directory to: $HOST_KUBE_MOUNT"
log_info "  • Configuration will be automatically updated on container start"
log_info "  • KUBECONFIG will be set to use container-accessible IPs"
log_info ""
log_info "💡 Next steps:"
log_info "  1. Ensure your devcontainer.json mounts the host .kube directory"
log_info "  2. Start your devcontainer"
log_info "  3. Run 'kubectl get nodes' to test connectivity"
