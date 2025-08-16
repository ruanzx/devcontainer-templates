#!/bin/bash

# Create installation marker to verify the feature was installed
INSTALL_MARKER="/usr/local/share/kubernetes-outside-docker-installed"

# Create marker file with installation details
cat > "$INSTALL_MARKER" << EOF
# kubernetes-outside-of-docker feature installation marker
# Created: $(date)
# User: $(id)
# PWD: $(pwd)
# Feature version: 2.0.4
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
EOF

chmod +x "$INSTALL_MARKER"

echo "🐛 DEBUG: Installation marker created at: $INSTALL_MARKER"
