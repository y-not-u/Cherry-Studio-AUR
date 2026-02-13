# Cherry Studio AUR Package

[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux)](https://archlinux.org/)
[![AUR](https://img.shields.io/aur/version/cherry-studio-bin)](https://aur.archlinux.org/packages/cherry-studio-bin)

An AUR package for [Cherry Studio](https://github.com/cherryHQ/cherry-studio) - a powerful desktop client that supports multiple LLM providers. This package provides a binary distribution using AppImage for seamless installation on Arch Linux.

## Features

- Easy installation via AUR helpers or manual build
- Pre-built AppImage from official Cherry Studio releases
- Automatic architecture detection (x86_64, aarch64)
- User-configurable flags via `~/.config/cherry-studio-flags.conf`
- Desktop integration with application menu entry

## System Requirements

- **Arch Linux** or Arch-based distribution
- **fuse2** package (installed automatically as dependency)
- AppImage support enabled on your system

## Installation

### Using AUR Helper (Recommended)

```bash
# Using yay
yay -S cherry-studio-bin

# Using paru
paru -S cherry-studio-bin
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://aur.archlinux.org/cherry-studio-bin.git
cd cherry-studio-bin
```

2. Build and install the package:
```bash
makepkg -si
```

## Build and Test Commands

```bash
# Build the package only
makepkg -s

# Build and install (without dependency check)
makepkg -i

# Test build without installing
makepkg -t

# Clean build artifacts
makepkg -c

# Check package validity with namcap
namcap PKGBUILD
namcap *.pkg.tar.zst
```

## Package Details

- **Package name**: `cherry-studio-bin`
- **Installation path**: `/opt/cherry-studio-bin/`
- **Wrapper script**: `/usr/bin/cherry-studio`
- **Desktop file**: `/usr/share/applications/cherry-studio.desktop`
- **Icon**: `/usr/share/icons/hicolor/256x256/apps/cherry-studio.png`

## Configuration

Cherry Studio supports custom command-line flags through a configuration file:

1. Create the config file:
```bash
mkdir -p ~/.config
touch ~/.config/cherry-studio-flags.conf
```

2. Add your flags (one per line, comments with `#`):
```bash
# ~/.config/cherry-studio-flags.conf
# Example: Disable hardware acceleration
--disable-gpu

# Example: Enable debug logging
--enable-logging
--v=1
```

3. Launch Cherry Studio normally - your flags will be applied automatically.

## Supported Architectures

- `x86_64` (64-bit Intel/AMD)
- `aarch64` (ARM64 - Raspberry Pi 4/5, ARM laptops)

## Troubleshooting

### AppImage won't launch
- Ensure `fuse2` is installed: `pacman -S fuse2`
- Check that AppImage execution is permitted on your system

### Permission denied
- Make sure the AppImage is executable: the package handles this automatically
- If issues persist, try running manually: `/opt/cherry-studio-bin/cherry-studio.AppImage`

### Flags not applying
- Verify your config file exists at `~/.config/cherry-studio-flags.conf`
- Check the syntax - one flag per line, no quotes needed

## Updating

This package tracks Cherry Studio releases. To update:

1. Update the PKGBUILD with new version and checksums
2. Regenerate `.SRCINFO`:
```bash
makepkg --printsrcinfo > .SRCINFO
```
3. Commit and push changes to AUR

## Contributing

Found a bug or have a suggestion? Please:

1. Check existing [AUR issues](https://aur.archlinux.org/packages/cherry-studio-bin)
2. Open a new issue with detailed information
3. Submit PKGBUILD improvements via AUR requests

## License

- **Package**: MIT (see [LICENSE](LICENSE) if available)
- **Cherry Studio**: [AGPL-3.0](https://www.gnu.org/licenses/agpl-3.0.html)

## Acknowledgments

- [Cherry Studio](https://github.com/cherryHQ/cherry-studio) - Original application
- Arch Linux AUR community
- All contributors and testers

---

Maintained by [vogan](https://aur.archlinux.org/account Packages?vogan)
