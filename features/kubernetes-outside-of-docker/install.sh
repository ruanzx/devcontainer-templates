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
trap 'echo "🐛 ERROR: Script failed at line $LINENO with exit code $?" >&2; handle_mount_errors' ERR

# Function to handle mount-related errors
handle_mount_errors() {
    local exit_code=$?
    
    echo "🔍 Checking for common mount issues..."
    
    # Check for Wayland socket mount errors (common on Windows)
    if docker logs $(hostname) 2>&1 | grep -q "wayland.*does not exist" 2>/dev/null; then
        echo "❌ Detected Wayland socket mount error"
        echo "💡 This is a common issue on Windows with WSL"
        echo "💡 This error can usually be ignored for CLI-only development"
        echo ""
        echo "🔧 To fix this issue:"
        echo "1. Disable GUI forwarding in VS Code settings:"
        echo "   - File > Preferences > Settings"
        echo "   - Search for 'devcontainer gui'"
        echo "   - Disable 'Dev > Containers: Forward GUI'"
        echo ""
        echo "2. Or add this to your devcontainer.json:"
        echo '   "runArgs": ["--security-opt", "label=disable"]'
        echo ""
    fi
    
    # Check for .kube mount issues  
    if [[ ! -d "$HOST_KUBE_MOUNT" ]]; then
        echo "❌ Kubernetes configuration mount missing"
        echo "💡 Add this mount to your devcontainer.json:"
        echo '{
  "mounts": [
    {
      "source": "${localEnv:USERPROFILE}/.kube",
      "target": "/tmp/.kube",
      "type": "bind"
    }
  ]
}'
    fi
    
    return $exit_code
}

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
    
    # Function to extract certificate IPs from kubeconfig
    extract_cert_ips() {
        local config_file="$1"
        local cert_ips=()
        
        # Extract certificate-authority-data and decode it
        if command -v yq >/dev/null 2>&1; then
            # Use yq if available for better YAML parsing
            local cert_data=$(yq eval '.clusters[0].cluster.certificate-authority-data' "$config_file" 2>/dev/null)
        else
            # Fallback to grep/awk
            local cert_data=$(grep -A 10 "certificate-authority-data:" "$config_file" | head -n 1 | awk '{print $2}' 2>/dev/null)
        fi
        
        if [ -n "$cert_data" ] && [ "$cert_data" != "null" ] && command -v openssl >/dev/null 2>&1; then
            # Decode base64 certificate and extract Subject Alternative Names
            local san_ips=$(echo "$cert_data" | base64 -d 2>/dev/null | openssl x509 -noout -text 2>/dev/null | \
                grep -A 1 "Subject Alternative Name:" | tail -n 1 | \
                grep -oE "IP Address:[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | \
                sed 's/IP Address://' | tr '\n' ' ')
            
            if [ -n "$san_ips" ]; then
                echo "$san_ips"
                return 0
            fi
        fi
        
        # Fallback: return empty string if extraction fails
        echo ""
    }
    
    # Function to test certificate-valid IPs
    test_cert_ips() {
        local cert_ips="$1"
        local context_name="$2"
        
        if [ -n "$cert_ips" ]; then
            echo "🔍 Testing certificate-valid IPs for $context_name..."
            echo "   Certificate IPs found: $cert_ips"
            
            for test_ip in $cert_ips; do
                # Skip IPv6 and localhost addresses for container connectivity
                if [[ "$test_ip" =~ ^127\. ]] || [[ "$test_ip" =~ : ]]; then
                    continue
                fi
                
                echo "  Testing $test_ip:6443..."
                if timeout 2 bash -c "echo >/dev/tcp/$test_ip/6443" 2>/dev/null; then
                    echo "  ✅ $test_ip:6443 is reachable and certificate-valid"
                    echo "$test_ip"
                    return 0
                else
                    echo "  ❌ $test_ip:6443 is not reachable"
                fi
            done
        fi
        
        echo ""
        return 1
    }
    
    # Detect Kubernetes distribution for appropriate IP selection
    KUBE_CONTEXT=""
    if grep -q "rancher-desktop" "$HOST_KUBE_MOUNT/config" 2>/dev/null; then
        echo "🐄 Detected Rancher Desktop"
        KUBE_CONTEXT="rancher-desktop"
    elif grep -q "docker-desktop" "$HOST_KUBE_MOUNT/config" 2>/dev/null; then
        echo "🐳 Detected Docker Desktop"
        KUBE_CONTEXT="docker-desktop"
    else
        # Try to detect context name from kubeconfig
        local detected_context=""
        if command -v yq >/dev/null 2>&1; then
            detected_context=$(yq eval '.current-context' "$HOST_KUBE_MOUNT/config" 2>/dev/null)
        else
            detected_context=$(grep "current-context:" "$HOST_KUBE_MOUNT/config" | awk '{print $2}' 2>/dev/null)
        fi
        
        if [ -n "$detected_context" ] && [ "$detected_context" != "null" ]; then
            echo "🔧 Detected Kubernetes context: $detected_context"
            KUBE_CONTEXT="$detected_context"
        else
            echo "🔧 Generic Kubernetes cluster detected"
            KUBE_CONTEXT="generic"
        fi
    fi
    
    # Get gateway IP for fallback
    GATEWAY_IP=$(ip route show default 2>/dev/null | awk '/default/ {print $3}' | head -n1)
    if [ -z "$GATEWAY_IP" ]; then
        GATEWAY_IP="172.17.0.1"
    fi
    
    TARGET_IP=""
    
    # For known distributions, try their specific IPs first, then certificate IPs
    if [ "$KUBE_CONTEXT" = "docker-desktop" ]; then
        # Docker Desktop specific IP
        DOCKER_DESKTOP_IP="192.168.65.3"
        echo "🔍 Testing Docker Desktop specific IP..."
        if timeout 2 bash -c "echo >/dev/tcp/$DOCKER_DESKTOP_IP/6443" 2>/dev/null; then
            TARGET_IP="$DOCKER_DESKTOP_IP"
            echo "  ✅ Docker Desktop IP $TARGET_IP:6443 is reachable"
        fi
    fi
    
    # If no specific IP worked, try certificate-extracted IPs for all contexts
    if [ -z "$TARGET_IP" ]; then
        CERT_IPS=$(extract_cert_ips "$HOST_KUBE_MOUNT/config")
        if [ -n "$CERT_IPS" ]; then
            TARGET_IP=$(test_cert_ips "$CERT_IPS" "$KUBE_CONTEXT")
        fi
    fi
    
    # If certificate IPs didn't work, try common Kubernetes IPs
    if [ -z "$TARGET_IP" ]; then
        echo "🔍 Testing common Kubernetes cluster IPs..."
        COMMON_IPS="10.43.0.1 192.168.127.2 192.168.143.1 192.168.65.3 192.168.1.1 10.0.0.1"
        
        for test_ip in $COMMON_IPS; do
            echo "  Testing $test_ip:6443..."
            if timeout 2 bash -c "echo >/dev/tcp/$test_ip/6443" 2>/dev/null; then
                TARGET_IP="$test_ip"
                echo "  ✅ $test_ip:6443 is reachable"
                break
            else
                echo "  ❌ $test_ip:6443 is not reachable"
            fi
        done
    fi
    
    # Final fallback to gateway IP
    if [ -z "$TARGET_IP" ]; then
        echo "⚠️  No certificate-valid or common IPs found, using gateway IP"
        TARGET_IP="$GATEWAY_IP"
    fi
    
    echo "� Selected target IP: $TARGET_IP"
    
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
# Enhanced Kubernetes Outside of Docker Profile Script
# Provides better error handling and compatibility

# Enhanced error handling for profile scripts
set +e  # Don't exit on errors in profile scripts

# Debug control
KUBE_DEBUG="${KUBE_DEBUG:-false}"

debug_log() {
    if [[ "$KUBE_DEBUG" == "true" ]]; then
        echo "🐛 DEBUG: $*" >&2
    fi
}

debug_log "Loading enhanced kubernetes-outside-docker profile script"

# Set KUBECONFIG based on user
if [ "$(id -u)" = "0" ]; then
    export KUBECONFIG="/root/.kube/config"
    debug_log "Set KUBECONFIG for root user: $KUBECONFIG"
else
    export KUBECONFIG="$HOME/.kube/config"
    debug_log "Set KUBECONFIG for non-root user: $KUBECONFIG"
fi

# Function to run kubernetes initialization if needed
ensure_kubectl_config() {
    debug_log "ensure_kubectl_config called"
    
    # Check if config already exists and is recent
    if [ -f "$KUBECONFIG" ]; then
        debug_log "KUBECONFIG file already exists: $KUBECONFIG"
        return 0
    fi
    
    # Check if initialization script exists
    if [ ! -f "/usr/local/share/kubernetes-init.sh" ]; then
        debug_log "kubernetes-init.sh not found, skipping initialization"
        return 0
    fi
    
    debug_log "Running kubernetes initialization..."
    if bash /usr/local/share/kubernetes-init.sh 2>/dev/null; then
        debug_log "Kubernetes initialization completed successfully"
    else
        debug_log "Kubernetes initialization failed or skipped"
    fi
}

# Run initialization automatically when profile loads (but not in subshells)
if [ -z "$KUBE_PROFILE_LOADED" ]; then
    export KUBE_PROFILE_LOADED=1
    debug_log "First time loading profile, running initialization"
    ensure_kubectl_config 2>/dev/null || true
else
    debug_log "Profile already loaded in parent shell, skipping initialization"
fi

# Enhanced kubectl wrapper function
if command -v kubectl >/dev/null 2>&1; then
    kubectl() {
        debug_log "kubectl wrapper called with args: $*"
        
        # Ensure config exists before running kubectl
        ensure_kubectl_config 2>/dev/null || true
        
        # Run the actual kubectl command
        command kubectl "$@"
    }
    
    # Export for bash
    if [ -n "$BASH_VERSION" ]; then
        export -f kubectl
        debug_log "kubectl function exported for bash"
    fi
    
    # For zsh compatibility
    if [ -n "$ZSH_VERSION" ]; then
        debug_log "Setting up kubectl for zsh"
    fi
fi

# Add completion for kubectl if available
if command -v kubectl >/dev/null 2>&1 && [ -n "$BASH_VERSION" ]; then
    if kubectl completion bash >/dev/null 2>&1; then
        # shellcheck disable=SC1090
        source <(kubectl completion bash 2>/dev/null) || true
        debug_log "kubectl bash completion loaded"
    fi
fi

debug_log "kubernetes-outside-docker profile script loaded successfully"
debug_log "KUBECONFIG=$KUBECONFIG"
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

# Create installation marker inline
INSTALL_MARKER="/usr/local/share/kubernetes-outside-docker-installed"

echo "🐛 DEBUG: Creating installation marker"
cat > "$INSTALL_MARKER" << MARKER_EOF
# kubernetes-outside-of-docker feature installation marker
# Created: $(date)
# User: $(id)
# PWD: $(pwd)
# Feature version: 2.0.8
# Install script: ${BASH_SOURCE[0]}

# Files that should exist after installation:
EXPECTED_FILES=(
    "/usr/local/share/kubernetes-init.sh"
    "/etc/profile.d/kubernetes-outside-docker.sh"
)

# Validation function
validate_installation() {
    local all_good=true
    
    for file in "\${EXPECTED_FILES[@]}"; do
        if [[ ! -f "\$file" ]]; then
            echo "ERROR: Missing file: \$file" >&2
            all_good=false
        else
            echo "OK: Found file: \$file"
        fi
    done
    
    if [[ "\$all_good" == "true" ]]; then
        echo "✅ kubernetes-outside-of-docker feature installation validated"
        return 0
    else
        echo "❌ kubernetes-outside-of-docker feature installation validation failed"
        return 1
    fi
}

# Export validation function
export -f validate_installation
MARKER_EOF

chmod +x "$INSTALL_MARKER"
echo "🐛 DEBUG: Installation marker created at: $INSTALL_MARKER"

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
