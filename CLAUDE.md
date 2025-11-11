# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an AUR (Arch User Repository) package for Cherry Studio - a desktop client that supports multiple LLM providers. The package provides a binary distribution using an AppImage.

## Package Structure

- **PKGBUILD**: Main package build script defining dependencies, sources, and installation logic
- **cherry-studio-bin.sh**: Wrapper script that handles user configuration flags and launches the AppImage
- **cherry-studio.desktop**: Desktop entry file for application integration
- **cherry-studio.png**: Application icon
- **.SRCINFO**: Package metadata for AUR submission

## Development Commands

### Building and Testing
```bash
# Build the package
makepkg -s

# Build and install
makepkg -si

# Test package installation (without installing)
makepkg -i

# Clean build artifacts
makepkg -c
```

### Package Management
```bash
# Update .SRCINFO file (required after PKGBUILD changes)
makepkg --printsrcinfo > .SRCINFO

# Check package validity
namcap PKGBUILD
namcap *.pkg.tar.zst
```

### Installation Methods
```bash
# Using yay (recommended)
yay -S cherry-studio-bin

# Manual installation from cloned repo
makepkg -si
```

## Package Architecture

This is a binary package (`-bin` suffix) that downloads a pre-built AppImage from GitHub releases. The package:

1. Downloads the AppImage from the official Cherry Studio releases
2. Installs it to `/opt/cherry-studio-bin/`
3. Creates a wrapper script at `/usr/bin/cherry-studio` that:
   - Reads user flags from `~/.config/cherry-studio-flags.conf`
   - Executes the AppImage with proper arguments
4. Provides desktop integration via `.desktop` file

## Key Files and Their Roles

- **PKGBUILD:24-40**: Package installation logic - creates directories and installs files
- **cherry-studio-bin.sh:6-8**: User configuration handling - reads flags from config file
- **cherry-studio.desktop**: Desktop integration - defines application metadata

## Dependencies

- `fuse2`: Required for AppImage execution
- Conflicts with `cherry-studio` (source package)

## Version Management

Package version (`pkgver`) should match the upstream Cherry Studio release version. Update the following when bumping versions:

1. `pkgver` in PKGBUILD
2. AppImage download URL in PKGBUILD
3. SHA256 checksums for all source files
4. `.SRCINFO` file (regenerate after PKGBUILD changes)