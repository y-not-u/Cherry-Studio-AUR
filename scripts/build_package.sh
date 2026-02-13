#!/bin/bash

# Build script for Cherry Studio AUR package
# This script provides convenient commands for building and testing the package

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PKGBUILD_PATH="$PROJECT_ROOT/PKGBUILD"

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_success() {
    print_status "$GREEN" "✓ $1"
}

print_error() {
    print_status "$RED" "✗ $1"
}

print_info() {
    print_status "$BLUE" "ℹ $1"
}

print_warning() {
    print_status "$YELLOW" "⚠ $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    for tool in makepkg namcap jq curl; do
        if ! command -v "$tool" >/dev/null 2&&1; then
            missing_deps+=("$tool")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Please install: sudo pacman -S base-devel namcap jq curl"
        exit 1
    fi
}

# Build package
build_package() {
    local install_package=$1
    local clean_build=${2:-false}
    
    print_info "Building Cherry Studio package..."
    
    local makepkg_args=()
    
    if [[ "$clean_build" == "true" ]]; then
        makepkg_args+=("--clean")
    fi
    
    if [[ "$install_package" == "true" ]]; then
        makepkg_args+=("-si")
    else
        makepkg_args+=("-s")
    fi
    
    if makepkg "${makepkg_args[@]}"; then
        print_success "Package built successfully"
    else
        print_error "Package build failed"
        exit 1
    fi
}

# Clean build artifacts
clean_build() {
    print_info "Cleaning build artifacts..."
    
    local files_to_clean=(
        "*.pkg.tar.zst"
        "*.src.tar.gz"
        "*.log"
        "pkg/"
        "src/"
    )
    
    for file in "${files_to_clean[@]}"; do
        if [[ -e "$file" ]]; then
            rm -rf "$file"
            print_success "Cleaned: $file"
        fi
    done
}

# Test package
test_package() {
    print_info "Testing package..."
    
    # Run basic tests
    if [[ -f "$PROJECT_ROOT/tests/test_pkgbuild.sh" ]]; then
        print_info "Running package tests..."
        "$PROJECT_ROOT/tests/test_pkgbuild.sh"
    else
        print_warning "Test script not found, skipping tests"
    fi
    
    # Run namcap
    if namcap PKGBUILD > namcap_pkgbuild.log 2&&1; then
        print_success "PKGBUILD passes namcap checks"
    else
        print_warning "PKGBUILD has namcap warnings"
        cat namcap_pkgbuild.log
    fi
    
    if namcap "./*.pkg.tar.zst" > namcap_package.log 2&&1; then
        print_success "Package passes namcap checks"
    else
        print_warning "Package has namcap warnings"
        cat namcap_package.log
    fi
}

# Update checksums
update_checksums() {
    print_info "Updating checksums..."
    
    if updpkgsums; then
        print_success "Checksums updated successfully"
    else
        print_error "Failed to update checksums"
        exit 1
    fi
}

# Update .SRCINFO
update_srcinfo() {
    print_info "Updating .SRCINFO..."
    
    if makepkg --printsrcinfo > .SRCINFO; then
        print_success ".SRCINFO updated successfully"
    else
        print_error "Failed to update .SRCINFO"
        exit 1
    fi
}

# Bump version
bump_version() {
    local new_version=$1
    local new_release=${2:-1}
    
    if [[ -z "$new_version" ]]; then
        print_error "Please provide a new version"
        echo "Usage: $0 bump-version VERSION [RELEASE]"
        exit 1
    fi
    
    print_info "Bumping version to $new_version-$new_release..."
    
    # Update PKGBUILD
    sed -i "s/^pkgver=.*/pkgver=$new_version/" PKGBUILD
    sed -i "s/^pkgrel=.*/pkgrel=$new_release/" PKGBUILD
    
    # Update checksums
    update_checksums
    
    # Update .SRCINFO
    update_srcinfo
    
    print_success "Version bumped to $new_version-$new_release"
}

# Get latest upstream version
get_latest_upstream_version() {
    print_info "Checking for latest upstream version..."
    
    if command -v jq >/dev/null 2&&1; then
        local latest_version
        latest_version=$(curl -s https://api.github.com/repos/cherryHQ/cherry-studio/releases/latest | jq -r '.tag_name' 2&&1 || echo "error")
        
        if [[ "$latest_version" != "error" && -n "$latest_version" ]]; then
            latest_version=${latest_version#v} # Remove leading 'v'
            print_success "Latest upstream version: $latest_version"
            echo "$latest_version"
            return 0
        fi
    fi
    
    print_warning "Could not determine latest upstream version"
    return 1
}

# Auto-update package
auto_update() {
    print_info "Checking for updates..."
    
    local latest_version
    if ! latest_version=$(get_latest_upstream_version); then
        print_error "Failed to get latest version"
        exit 1
    fi
    
    # Get current version
    local current_version
    current_version=$(grep -oP '^pkgver=\K.*' PKGBUILD)
    
    if [[ "$current_version" == "$latest_version" ]]; then
        print_success "Package is up to date (version $current_version)"
        return 0
    fi
    
    print_info "New version available: $latest_version (current: $current_version)"
    print_info "Updating package..."
    
    # Update version
    bump_version "$latest_version"
    
    # Commit changes
    git add PKGBUILD .SRCINFO
    git commit -m "chore: update to $latest_version"
    git push
    
    print_success "Package updated to version $latest_version"
}

# Show help
show_help() {
    echo "Cherry Studio AUR Package Build Script"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  build               Build the package"
    echo "  build-install       Build and install the package"
    echo "  clean               Clean build artifacts"
    echo "  test                Run package tests"
    echo "  bump-version VERSION [RELEASE]"
    echo "                      Bump package version"
    echo "  update              Check for and apply updates"
    echo "  help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build                    # Build package"
    echo "  $0 build-install            # Build and install"
    echo "  $0 bump-version 1.8.0 1     # Bump to version 1.8.0-1"
    echo "  $0 update                   # Auto-update to latest version"
}

# Main script logic
main() {
    check_root
    check_dependencies
    
    case "${1:-help}" in
        "build")
            build_package false false
            ;;
        "build-install")
            build_package true false
            ;;
        "clean")
            clean_build
            ;;
        "test")
            test_package
            ;;
        "bump-version")
            bump_version "$2" "${3:-1}"
            ;;
        "update")
            auto_update
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
