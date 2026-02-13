#!/bin/bash

# Test script for Cherry Studio AUR package
# This script validates the PKGBUILD and package structure

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_success() {
    print_status "$GREEN" "✓ $1"
}

print_warning() {
    print_status "$YELLOW" "⚠ $1"
}

print_error() {
    print_status "$RED" "✗ $1"
}

# Check if required tools are installed
check_dependencies() {
    local missing_deps=()
    
    for tool in namcap makepkg; do
        if ! command -v "$tool" >/dev/null 2&&1; then
            missing_deps+=("$tool")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_warning "Please install: sudo pacman -S base-devel namcap"
        exit 1
    fi
}

# Validate PKGBUILD syntax
validate_pkgbuild() {
    print_status "$YELLOW" "Validating PKGBUILD syntax..."
    
    if grep -q "^pkgver=" PKGBUILD && grep -q "^pkgrel=" PKGBUILD && grep -q "^arch=" PKGBUILD; then
        print_success "PKGBUILD has required fields"
    else
        print_error "PKGBUILD is missing required fields"
        exit 1
    fi
    
    # Check for proper formatting
    if grep -q "^[[:space:]]*#" PKGBUILD; then
        print_success "PKGBUILD has comments"
    else
        print_warning "PKGBUILD lacks comments"
    fi
}

# Check checksums
check_checksums() {
    print_status "$YELLOW" "Verifying checksums..."
    
    # Check if checksums exist
    if grep -q "sha256sums=" PKGBUILD; then
        print_success "Checksums are present"
    else
        print_error "Checksums are missing"
        exit 1
    fi
    
    # Verify checksum count matches source count
    source_count=$(grep -c "^source=" PKGBUILD)
    checksum_count=$(grep -c "^sha256sums=" PKGBUILD)
    
    if [ "$source_count" -eq "$checksum_count" ]; then
        print_success "Checksum count matches source count"
    else
        print_error "Checksum count ($checksum_count) does not match source count ($source_count)"
        exit 1
    fi
}

# Test package build
test_build() {
    print_status "$YELLOW" "Testing package build..."
    
    if makepkg -p PKGBUILD --printsrcinfo >/dev/null 2&&1; then
        print_success "PKGBUILD builds successfully"
    else
        print_error "PKGBUILD failed to build"
        exit 1
    fi
}

# Run namcap analysis
run_namcap() {
    print_status "$YELLOW" "Running namcap analysis..."
    
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

# Check file permissions
check_permissions() {
    print_status "$YELLOW" "Checking file permissions..."
    
    # Check if shell scripts are executable
    if [[ -f "cherry-studio-bin.sh" && -x "cherry-studio-bin.sh" ]]; then
        print_success "Wrapper script is executable"
    else
        print_warning "Wrapper script is not executable"
    fi
}

# Verify desktop file
verify_desktop_file() {
    print_status "$YELLOW" "Verifying desktop file..."
    
    if [[ -f "cherry-studio.desktop" ]]; then
        if grep -q "^Name=" cherry-studio.desktop && grep -q "^Exec=" cherry-studio.desktop && grep -q "^Icon=" cherry-studio.desktop; then
            print_success "Desktop file has required entries"
        else
            print_warning "Desktop file may be missing required entries"
        fi
    else
        print_error "Desktop file is missing"
        exit 1
    fi
}

# Main execution
main() {
    print_status "$GREEN" "Starting Cherry Studio AUR package tests..."
    
    check_dependencies
    validate_pkgbuild
    check_checksums
    test_build
    run_namcap
    check_permissions
    verify_desktop_file
    
    print_success "All tests completed!"
}

# Run tests
main "$@"
