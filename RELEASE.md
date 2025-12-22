# Release Process

This document describes how to create a new release for the SkipTheBrowse Flutter client.

## Quick Release

Use the release script for a streamlined release process:

```bash
# Simple version bump
./release.sh 1.0.0

# Version with build number
./release.sh 1.0.0+42
```

Or use the Makefile:

```bash
make release VERSION=1.0.0
```

## What the Script Does

1. ✅ **Validates** version format (semantic versioning)
2. ✅ **Checks** for uncommitted changes (fails if any exist)
3. ✅ **Updates** `pubspec.yaml` with new version
4. ✅ **Commits** the version bump
5. ✅ **Creates** an annotated git tag
6. ✅ **Optionally pushes** commit and tag to remote

## Version Format

The script supports Flutter's version format:

```
MAJOR.MINOR.PATCH+BUILD
```

Examples:
- `1.0.0` - Simple semantic version
- `1.0.0+1` - Semantic version with build number
- `2.1.3+42` - Version 2.1.3, build 42

## Manual Release (if needed)

If you prefer to do it manually:

```bash
# 1. Update version in pubspec.yaml
# Edit the version line: version: 1.0.0+1

# 2. Commit the change
git add pubspec.yaml
git commit -m "chore(release): bump version to 1.0.0"

# 3. Create an annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# 4. Push to remote
git push origin main
git push origin v1.0.0
```

## Useful Make Commands

```bash
# Development
make run              # Run app locally
make run-dev          # Run against dev backend
make test             # Run unit/widget tests
make test-integration # Run integration tests
make build            # Generate code (Retrofit, JsonSerializable)
make format           # Format code
make lint             # Analyze code

# Maintenance
make clean            # Clean build artifacts
make deps             # Get dependencies
```

## Pre-Release Checklist

Before creating a release, ensure:

- [ ] All tests pass (`make test`)
- [ ] Code is formatted (`make format`)
- [ ] No linter warnings (`make lint`)
- [ ] Integration tests pass (`make test-integration`)
- [ ] All changes are committed
- [ ] You're on the correct branch (usually `main`)

## Versioning Strategy

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: Backwards-compatible new features
- **PATCH**: Backwards-compatible bug fixes
- **BUILD**: Build number (optional, auto-incremented by CI)

Examples:
- Bug fix: `1.0.0` → `1.0.1`
- New feature: `1.0.1` → `1.1.0`
- Breaking change: `1.1.0` → `2.0.0`
