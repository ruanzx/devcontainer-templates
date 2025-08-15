#!/bin/bash

# Comprehensive validation script for kubernetes-outside-of-docker feature
# This script can be used to validate the feature with a real Kubernetes cluster

set -e

echo "🔍 Kubernetes Outside of Docker - Comprehensive Validation"
echo "========================================================="

# Function to print test status
print_status() {
    local status="$1"
    local message="$2"
    case $status in
        "pass") echo "   ✅ $message" ;;
        "fail") echo "   ❌ $message" ;;
        "warn") echo "   ⚠️  $message" ;;
        "info") echo "   ℹ️  $message" ;;
    esac
}

# Test 1: Feature Installation
echo ""
echo "🧪 Test 1: Feature Installation"
echo "-------------------------------"

if [ -f "/usr/local/share/kubernetes-init.sh" ]; then
    print_status "pass" "Initialization script exists"
else
    print_status "fail" "Initialization script missing"
    exit 1
fi

if [ -x "/usr/local/share/kubernetes-init.sh" ]; then
    print_status "pass" "Script is executable"
else
    print_status "fail" "Script is not executable"
    exit 1
fi

if [ -L "/usr/local/share/docker-init.sh" ]; then
    print_status "pass" "Entrypoint symlink exists"
else
    print_status "fail" "Entrypoint symlink missing"
    exit 1
fi

# Test 2: Directory Structure
echo ""
echo "🧪 Test 2: Directory Structure"
echo "------------------------------"

if [ -d "/home/vscode/.kube" ]; then
    print_status "pass" ".kube directory exists"
    
    # Check ownership
    if [ "$(stat -c %U /home/vscode/.kube)" = "vscode" ]; then
        print_status "pass" ".kube directory ownership correct"
    else
        print_status "warn" ".kube directory ownership incorrect"
    fi
else
    print_status "fail" ".kube directory missing"
    exit 1
fi

# Test 3: Environment Configuration
echo ""
echo "🧪 Test 3: Environment Configuration"
echo "-----------------------------------"

if [ -n "$KUBECONFIG" ]; then
    print_status "pass" "KUBECONFIG environment variable set: $KUBECONFIG"
    
    # Check if the configured kubeconfig path is the container one
    if [[ "$KUBECONFIG" == *"config-container"* ]]; then
        print_status "pass" "KUBECONFIG points to container-specific config"
    else
        print_status "warn" "KUBECONFIG not pointing to container config"
    fi
else
    print_status "warn" "KUBECONFIG not set (will be set by initialization script)"
fi

# Test 4: kubectl Availability
echo ""
echo "🧪 Test 4: kubectl Availability"
echo "-------------------------------"

if command -v kubectl >/dev/null 2>&1; then
    print_status "pass" "kubectl command available"
    
    # Get kubectl version
    kubectl_version=$(kubectl version --client --short 2>/dev/null | grep "Client Version" || echo "unknown")
    print_status "info" "kubectl version: $kubectl_version"
else
    print_status "fail" "kubectl command not found"
    print_status "info" "kubectl should be installed by the kubectl feature dependency"
fi

# Test 5: Host Kubeconfig Detection
echo ""
echo "🧪 Test 5: Host Kubeconfig Detection"
echo "-----------------------------------"

host_kubeconfig="/home/vscode/.kube/config"
if [ -f "$host_kubeconfig" ]; then
    print_status "pass" "Host kubeconfig found"
    
    # Check if it's readable
    if [ -r "$host_kubeconfig" ]; then
        print_status "pass" "Host kubeconfig is readable"
        
        # Check if it contains cluster configuration
        if grep -q "clusters:" "$host_kubeconfig" 2>/dev/null; then
            print_status "pass" "Host kubeconfig contains cluster configuration"
            
            # Show cluster info from config
            clusters=$(grep -A 5 "clusters:" "$host_kubeconfig" | grep "name:" | head -3)
            print_status "info" "Configured clusters: $(echo $clusters | tr '\n' ' ')"
        else
            print_status "warn" "Host kubeconfig appears invalid or empty"
        fi
    else
        print_status "fail" "Host kubeconfig is not readable"
    fi
else
    print_status "warn" "Host kubeconfig not found (mount your .kube directory)"
    print_status "info" "Add this to your devcontainer.json:"
    print_status "info" '  "mounts": [{"source": "${localEnv:HOME}/.kube", "target": "/home/vscode/.kube", "type": "bind"}]'
fi

# Test 6: Initialization Script Test
echo ""
echo "🧪 Test 6: Initialization Script Test"
echo "------------------------------------"

print_status "info" "Testing initialization script..."
if bash -n /usr/local/share/kubernetes-init.sh; then
    print_status "pass" "Script syntax is valid"
else
    print_status "fail" "Script syntax error"
    exit 1
fi

# If host kubeconfig exists, run initialization
if [ -f "$host_kubeconfig" ]; then
    print_status "info" "Running initialization script..."
    if /usr/local/share/kubernetes-init.sh; then
        print_status "pass" "Initialization script completed successfully"
    else
        print_status "warn" "Initialization script completed with warnings"
    fi
else
    print_status "info" "Skipping initialization (no host kubeconfig)"
fi

# Test 7: Container Kubeconfig
echo ""
echo "🧪 Test 7: Container Kubeconfig"
echo "------------------------------"

container_kubeconfig="/home/vscode/.kube/config-container"
if [ -f "$container_kubeconfig" ]; then
    print_status "pass" "Container kubeconfig created"
    
    if [ -r "$container_kubeconfig" ]; then
        print_status "pass" "Container kubeconfig is readable"
        
        # Check if server URLs have been modified for container access
        if grep -q "host.docker.internal\|172.17.0.1" "$container_kubeconfig" 2>/dev/null; then
            print_status "pass" "Container kubeconfig has container-appropriate server URLs"
        else
            print_status "warn" "Container kubeconfig may not have proper server URLs"
        fi
    else
        print_status "fail" "Container kubeconfig is not readable"
    fi
else
    print_status "warn" "Container kubeconfig not created (needs host kubeconfig)"
fi

# Test 8: Cluster Connectivity (if possible)
echo ""
echo "🧪 Test 8: Cluster Connectivity"
echo "------------------------------"

if command -v kubectl >/dev/null 2>&1 && [ -f "$container_kubeconfig" ]; then
    export KUBECONFIG="$container_kubeconfig"
    
    print_status "info" "Testing cluster connectivity..."
    if timeout 10 kubectl cluster-info >/dev/null 2>&1; then
        print_status "pass" "Cluster connectivity successful"
        
        # Get node information
        node_count=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
        print_status "pass" "Cluster has $node_count node(s)"
        
        # Test basic operations
        if kubectl get namespaces >/dev/null 2>&1; then
            print_status "pass" "Can list namespaces"
        else
            print_status "warn" "Cannot list namespaces (permission issue?)"
        fi
        
    else
        print_status "fail" "Cannot connect to cluster"
        print_status "info" "Possible causes:"
        print_status "info" "  - Cluster not running on host"
        print_status "info" "  - Network connectivity issues"
        print_status "info" "  - TLS certificate problems"
        print_status "info" "  - For kind: cluster may be bound to localhost only"
    fi
else
    if ! command -v kubectl >/dev/null 2>&1; then
        print_status "warn" "Cannot test connectivity: kubectl not available"
    elif [ ! -f "$container_kubeconfig" ]; then
        print_status "warn" "Cannot test connectivity: no container kubeconfig"
    fi
fi

# Test Results Summary
echo ""
echo "📋 Validation Summary"
echo "===================="

if [ -f "/usr/local/share/kubernetes-init.sh" ] && [ -x "/usr/local/share/kubernetes-init.sh" ]; then
    print_status "pass" "Feature is properly installed"
else
    print_status "fail" "Feature installation incomplete"
    exit 1
fi

if [ -f "$host_kubeconfig" ]; then
    print_status "pass" "Host kubeconfig available"
    if [ -f "$container_kubeconfig" ]; then
        print_status "pass" "Container configuration created"
    else
        print_status "warn" "Run initialization to create container config"
    fi
else
    print_status "warn" "Mount .kube directory to enable cluster access"
fi

echo ""
echo "🎉 Validation completed!"
echo ""
echo "💡 Next steps:"
if [ ! -f "$host_kubeconfig" ]; then
    echo "   1. Mount your .kube directory in devcontainer.json"
    echo "   2. Rebuild the container"
fi
echo "   3. Ensure a Kubernetes cluster is running on your host"
echo "   4. Test with: kubectl get nodes"
