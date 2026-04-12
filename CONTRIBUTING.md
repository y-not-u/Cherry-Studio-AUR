# Contributing to Cherry Studio AUR Package

We welcome contributions to this AUR package! Please read the following guidelines before contributing.

## Getting Started

This AUR package provides a binary distribution of Cherry Studio using AppImage for Arch Linux.

### Prerequisites

- An Arch Linux system or Arch-based distribution
- Git for version control
- A text editor
- Basic understanding of PKGBUILD and AUR packaging

### Development Environment

1. Clone the repository:
   ```bash
   git clone https://aur.archlinux.org/cherry-studio-bin.git
   cd cherry-studio-bin
   ```

2. Install build dependencies:
   ```bash
   sudo pacman -S --needed base-devel
   ```

## How to Contribute

### Reporting Issues

If you encounter any problems with the package:

1. Check existing [AUR issues](https://aur.archlinux.org/packages/cherry-studio-bin) to see if the issue has already been reported.
2. If not, create a new issue with:
   - A clear and descriptive title
   - Steps to reproduce the issue
   - Expected behavior vs actual behavior
   - Your system information (architecture, kernel version, etc.)
   - Relevant log output or error messages

### Submitting Changes

#### 1. Fork and Clone

1. Fork this repository on AUR.
2. Clone your fork:
   ```bash
   git clone ssh://aur@aur.archlinux.org/cherry-studio-bin.git
   cd cherry-studio-bin
   ```

#### 2. Create a Branch

```bash
git checkout -b feature/description
```

#### 3. Make Your Changes

- Edit the PKGBUILD file for package changes
- Update checksums if source files change
- Regenerate .SRCINFO after PKGBUILD changes:
  ```bash
  makepkg --printsrcinfo > .SRCINFO
  ```

#### 4. Test Your Changes

```bash
# Build the package
makepkg -si

# Test installation
cherry-studio --version

# Check package validity
namcap PKGBUILD
namcap *.pkg.tar.zst
```

#### 5. Commit and Push

```bash
git add PKGBUILD .SRCINFO
git commit -m "feat: description of changes"
git push origin feature/description
```

#### 6. Create a Pull Request

- Go to your fork on AUR
- Create a new package request
- Provide a clear description of your changes

## Package Maintenance

### Updating to New Versions

When a new version of Cherry Studio is released:

1. Update PKGBUILD version:
   ```bash
   sed -i 's/^pkgver=.*/pkgver=NEW_VERSION/' PKGBUILD
   sed -i 's/^pkgrel=.*/pkgrel=1/' PKGBUILD
   ```

2. Download new AppImages and calculate checksums:
   ```bash
   curl -fL -o "cherry-studio-NEW_VERSION-x86_64.AppImage" "https://github.com/cherryHQ/cherry-studio/releases/download/vNEW_VERSION/Cherry-Studio-NEW_VERSION-x86_64.AppImage"
   curl -fL -o "cherry-studio-NEW_VERSION-arm64.AppImage" "https://github.com/cherryHQ/cherry-studio/releases/download/vNEW_VERSION/Cherry-Studio-NEW_VERSION-arm64.AppImage"
   
   x86_checksum=$(sha256sum "cherry-studio-NEW_VERSION-x86_64.AppImage" | awk '{print $1}')
   arm64_checksum=$(sha256sum "cherry-studio-NEW_VERSION-arm64.AppImage" | awk '{print $1}')
   ```

3. Update checksums in PKGBUILD and regenerate .SRCINFO.

### Best Practices

- Always test the package before submitting
- Keep the package as close to the upstream source as possible
- Follow Arch Linux packaging standards
- Document any non-standard changes in PKGBUILD comments
- Use `namcap` to check for common packaging issues

## Code of Conduct

This project follows the Arch Linux Code of Conduct. Please be respectful and constructive in all interactions.

## License

This project is licensed under the AGPL-3.0 license. See [LICENSE](LICENSE) for details.

---

**Thank you for contributing to Cherry Studio AUR package!**
