#!/bin/bash

# Enhanced Kubernetes Outside of Docker Profile Script
# This replaces the basic profile script with better error handling and compatibility

# Enhanced error handling
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
