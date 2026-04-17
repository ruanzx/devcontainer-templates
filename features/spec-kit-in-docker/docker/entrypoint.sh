#!/usr/bin/env bash
set -e

# Spec-Kit Docker Entrypoint
# Installs or reuses spec-kit at the version specified by SPECKIT_VERSION,
# then executes the requested command.

SPECKIT_VERSION="${SPECKIT_VERSION:-latest}"
MARKER_DIR="/root/.local/share/uv/tools"
MARKER_FILE="${MARKER_DIR}/.speckit-installed-version"

install_speckit() {
    local version="$1"
    if [[ "$version" == "latest" ]]; then
        uv tool install specify-cli \
            --force \
            --from git+https://github.com/github/spec-kit.git \
            2>/dev/null
    else
        uv tool install specify-cli \
            --force \
            --from "git+https://github.com/github/spec-kit.git@${version}" \
            2>/dev/null
    fi
    mkdir -p "$(dirname "$MARKER_FILE")"
    echo "$version" > "$MARKER_FILE"
}

# Determine whether a full install is needed
NEED_INSTALL=true
if [[ -f "$MARKER_FILE" ]]; then
    INSTALLED_VERSION="$(cat "$MARKER_FILE")"
    if [[ "$INSTALLED_VERSION" == "$SPECKIT_VERSION" ]] && command -v specify >/dev/null 2>&1; then
        # Already installed at the requested version and symlink exists
        NEED_INSTALL=false
    fi
fi

if [[ "$NEED_INSTALL" == "true" ]]; then
    echo "Installing spec-kit (${SPECKIT_VERSION})..." >&2
    if ! install_speckit "$SPECKIT_VERSION"; then
        echo "Warning: Failed to install spec-kit ${SPECKIT_VERSION}, attempting fallback..." >&2
        if command -v specify >/dev/null 2>&1; then
            echo "Using previously installed version." >&2
        else
            echo "Error: No spec-kit version available." >&2
            exit 1
        fi
    fi
fi

exec "$@"
