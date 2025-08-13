#!/bin/bash

# Delete all GitHub Container Registry packages
# This script removes all container packages from the authenticated user's account

set -e

# Load environment variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Load .env file if it exists
if [[ -f "$ROOT_DIR/.env" ]]; then
    source "$ROOT_DIR/.env"
    echo "Loaded environment variables from .env"
fi

# Source common utilities
source "$ROOT_DIR/common/utils.sh"

# Validate required environment variables
if [[ -z "$GITHUB_TOKEN" ]]; then
    log_error "GITHUB_TOKEN environment variable is required"
    log_info "Please set your GitHub token in the .env file"
    exit 1
fi

log_info "Deleting all GitHub Container Registry packages"

# Function to delete a package
delete_package() {
    local package_name="$1"
    local encoded_name
    
    # URL encode the package name (GitHub API requires double encoding for slashes)
    encoded_name=$(printf '%s\n' "$package_name" | sed 's|/|%2F|g')
    
    log_info "Deleting package: $package_name"
    
    # Delete the package using GitHub API
    local response
    response=$(GH_TOKEN="$GITHUB_TOKEN" gh api --method DELETE "/user/packages/container/$encoded_name" 2>&1) 
    local api_result=$?
    
    if [[ $api_result -ne 0 ]]; then
        if echo "$response" | grep -q "delete:packages"; then
            log_error "GitHub token missing required permissions!"
            log_error "Your GitHub token needs 'delete:packages' and 'read:packages' scopes."
            log_error "Please update your token at: https://github.com/settings/tokens"
            log_error "Required scopes: write:packages, read:packages, delete:packages"
            log_error "Cannot continue without proper permissions."
            exit 1  # Exit completely on permission errors
        elif echo "$response" | grep -q "Package not found\|Not Found"; then
            log_warning "Package not found (may have been deleted already): $package_name"
            return 0
        else
            log_error "Failed to delete package: $package_name"
            log_error "Response: $response"
            return 1
        fi
    fi
    
    log_success "Successfully deleted package: $package_name"
    return 0
}

# Function to check token permissions
check_token_permissions() {
    log_info "Checking GitHub token permissions"
    
    # Try to list packages to check read:packages scope
    if ! GH_TOKEN="$GITHUB_TOKEN" gh api "/user/packages?package_type=container" --jq '.[]' >/dev/null 2>&1; then
        log_error "GitHub token missing 'read:packages' scope"
        log_error "Please update your token at: https://github.com/settings/tokens"
        log_error "Required scopes: write:packages, read:packages, delete:packages"
        exit 1
    fi
    
    # Note: We can't directly test delete:packages without actually deleting something
    # The error will be caught during the actual deletion attempt
    
    log_success "Token has required read permissions"
}

# Function to get all container packages
get_packages() {
    GH_TOKEN="$GITHUB_TOKEN" gh api --paginate "/user/packages?package_type=container" --jq '.[].name' 2>/dev/null || true
}

# Main deletion process
main() {
    log_info "Starting package deletion process"
    
    # Check if gh CLI is available
    ensure_command "gh"
    ensure_command "jq"
    
    # Check token permissions
    check_token_permissions
    
    # Get all container packages
    log_info "Fetching all container packages"
    local packages
    packages=$(get_packages)
    
    if [[ -z "$packages" ]]; then
        log_info "No container packages found"
        return 0
    fi
    
    log_info "Found the following packages to delete:"
    while IFS= read -r package; do
        if [[ -n "$package" ]]; then
            echo "  - $package"
        fi
    done <<< "$packages"
    
    # Ask for confirmation
    echo ""
    read -p "Are you sure you want to delete ALL these packages? This cannot be undone! (yes/no): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        log_info "Deletion cancelled by user"
        exit 0
    fi
    
    # Delete each package
    local failed_packages=()
    local deleted_count=0
    local total_packages=0
    
    # Count total packages
    while IFS= read -r package_name; do
        if [[ -n "$package_name" ]]; then
            total_packages=$((total_packages + 1))
        fi
    done <<< "$packages"
    
    log_info "Starting deletion of $total_packages packages..."
    
    while IFS= read -r package_name; do
        if [[ -n "$package_name" ]]; then
            current_package=$((deleted_count + ${#failed_packages[@]} + 1))
            log_info "Processing package $current_package of $total_packages"
            if delete_package "$package_name"; then
                deleted_count=$((deleted_count + 1))
                remaining=$((total_packages - deleted_count - ${#failed_packages[@]}))
                log_info "Progress: $deleted_count deleted, ${#failed_packages[@]} failed, $remaining remaining"
            else
                failed_packages+=("$package_name")
                remaining=$((total_packages - deleted_count - ${#failed_packages[@]}))
                log_info "Progress: $deleted_count deleted, ${#failed_packages[@]} failed, $remaining remaining"
            fi
        fi
    done <<< "$packages"
    
    # Report results
    log_info ""
    if [[ ${#failed_packages[@]} -eq 0 ]]; then
        log_success "Successfully deleted all $deleted_count packages!"
    else
        log_warning "Deleted $deleted_count packages successfully"
        log_error "Failed to delete ${#failed_packages[@]} packages: ${failed_packages[*]}"
        exit 1
    fi
}

# Show usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Delete all GitHub Container Registry packages for the authenticated user"
    echo ""
    echo "Environment variables (can be set in .env file):"
    echo "  GITHUB_TOKEN          GitHub personal access token (required)"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  --force              Skip confirmation prompt"
    echo ""
    echo "Examples:"
    echo "  $0                   Delete all packages (with confirmation)"
    echo "  $0 --force           Delete all packages (no confirmation)"
    echo ""
    echo "WARNING: This will permanently delete ALL container packages!"
    echo "This action cannot be undone!"
}

# Parse command line arguments
FORCE_DELETE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --force)
            FORCE_DELETE=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Override confirmation if force flag is set
if [[ "$FORCE_DELETE" == "true" ]]; then
    # Modify main function to skip confirmation
    main_force() {
        log_info "Starting package deletion process (FORCE MODE)"
        
        # Check if gh CLI is available
        ensure_command "gh"
        ensure_command "jq"
        
        # Check token permissions
        check_token_permissions
        
        # Get all container packages
        log_info "Fetching all container packages"
        local packages
        packages=$(get_packages)
        
        if [[ -z "$packages" ]]; then
            log_info "No container packages found"
            return 0
        fi
        
        log_info "Found the following packages to delete:"
        while IFS= read -r package; do
            if [[ -n "$package" ]]; then
                echo "  - $package"
            fi
        done <<< "$packages"
        
        log_warning "FORCE MODE: Deleting without confirmation..."
        
        # Delete each package
        local failed_packages=()
        local deleted_count=0
        local total_packages=0
        
        # Count total packages
        while IFS= read -r package_name; do
            if [[ -n "$package_name" ]]; then
                ((total_packages++))
            fi
        done <<< "$packages"
        
        log_info "Starting deletion of $total_packages packages..."
        
        while IFS= read -r package_name; do
            if [[ -n "$package_name" ]]; then
                log_info "Processing package $((deleted_count + ${#failed_packages[@]} + 1)) of $total_packages"
                if delete_package "$package_name"; then
                    ((deleted_count++))
                    log_info "Progress: $deleted_count deleted, ${#failed_packages[@]} failed, $((total_packages - deleted_count - ${#failed_packages[@]})) remaining"
                else
                    failed_packages+=("$package_name")
                    log_info "Progress: $deleted_count deleted, ${#failed_packages[@]} failed, $((total_packages - deleted_count - ${#failed_packages[@]})) remaining"
                fi
            fi
        done <<< "$packages"
        
        # Report results
        log_info ""
        if [[ ${#failed_packages[@]} -eq 0 ]]; then
            log_success "Successfully deleted all $deleted_count packages!"
        else
            log_warning "Deleted $deleted_count packages successfully"
            log_error "Failed to delete ${#failed_packages[@]} packages: ${failed_packages[*]}"
            exit 1
        fi
    }
    
    main_force
else
    main
fi
