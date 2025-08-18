#!/bin/bash
# DevContainer Mount Validator
# Handles missing mounts gracefully and provides helpful error messages

set -e

echo "🔧 DevContainer Mount Validator starting..."

# Check critical mounts
CRITICAL_MOUNTS=(
    "/tmp/.kube:Kubernetes configuration directory"
    "/var/run/docker.sock:/var/run/docker-host.sock:Docker socket"
)

OPTIONAL_MOUNTS=(
    "/tmp/vscode-wayland-*.sock:Wayland socket for GUI support"
)

missing_critical=0
missing_optional=0

echo "📋 Checking critical mounts..."
for mount_info in "${CRITICAL_MOUNTS[@]}"; do
    IFS=':' read -r mount_path description <<< "$mount_info"
    
    if [[ ! -e "$mount_path" ]]; then
        echo "❌ Missing critical mount: $mount_path ($description)"
        missing_critical=$((missing_critical + 1))
    else
        echo "✅ Found: $mount_path"
    fi
done

echo "📋 Checking optional mounts..."
for mount_info in "${OPTIONAL_MOUNTS[@]}"; do
    IFS=':' read -r mount_pattern description <<< "$mount_info"
    
    # Use glob pattern to check for files
    if ! ls $mount_pattern >/dev/null 2>&1; then
        echo "⚠️  Missing optional mount: $mount_pattern ($description)"
        missing_optional=$((missing_optional + 1))
    else
        echo "✅ Found: $mount_pattern"
    fi
done

# Provide guidance for missing mounts
if [[ $missing_critical -gt 0 ]]; then
    echo ""
    echo "🔴 Critical mounts are missing!"
    echo "Please ensure your devcontainer.json includes:"
    echo '{
  "mounts": [
    {
      "source": "${localEnv:USERPROFILE}/.kube",
      "target": "/tmp/.kube", 
      "type": "bind"
    }
  ]
}'
    echo ""
    echo "For Windows users: Use \${localEnv:USERPROFILE} instead of \${localEnv:HOME}"
    exit 1
fi

if [[ $missing_optional -gt 0 ]]; then
    echo ""
    echo "🟡 Some optional mounts are missing, but this won't affect core functionality."
    echo "Missing optional mounts are typically related to GUI support and can be ignored for CLI-only work."
fi

echo ""
echo "✅ Mount validation completed successfully!"
