# CI/CD Guide for SkipTheBrowse Flutter App

This document explains the GitHub Actions CI/CD pipeline for the SkipTheBrowse Flutter application.

## 📋 Overview

The CI/CD pipeline automatically:
- ✅ Analyzes code quality
- ✅ Runs unit tests
- ✅ Builds for all platforms (Android, iOS, Web, Linux, macOS, Windows)
- ✅ Runs integration tests on all platforms
- ✅ Creates release artifacts
- ✅ Publishes releases on tagged commits

## 🔄 Workflows

### 1. Main CI/CD Workflow (`.github/workflows/ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual trigger via workflow_dispatch

**Jobs:**

#### `analyze-and-test` (Ubuntu)
- Runs first, all other jobs depend on it
- Checks code formatting with `dart format`
- Analyzes code with `flutter analyze`
- Runs unit tests with coverage
- Uploads coverage to Codecov

#### `android` (Ubuntu)
- Builds release APK
- Builds release App Bundle (AAB)
- Runs integration tests on Android emulator (API 34)
- Uploads build artifacts

#### `ios` (macOS)
- Builds iOS app (no codesign for CI)
- Creates IPA package
- Runs integration tests on iOS Simulator (iPhone 15 Pro, iOS 18.1)
- Uploads build artifacts

#### `macos` (macOS)
- Builds macOS desktop app
- Creates DMG installer
- Runs integration tests natively on macOS
- Uploads build artifacts

#### `linux` (Ubuntu)
- Installs Linux desktop dependencies
- Builds Linux desktop app
- Creates tarball
- Runs integration tests with Xvfb
- Uploads build artifacts

#### `windows` (Windows)
- Builds Windows desktop app
- Creates ZIP archive
- Runs integration tests natively on Windows
- Uploads build artifacts

#### `web` (Ubuntu)
- Builds web app with CanvasKit renderer
- Uploads build artifacts
- Note: Integration tests require browser setup (not included by default)

#### `release` (Ubuntu)
- Only runs on tagged commits (e.g., `v1.0.0`)
- Downloads all platform artifacts
- Creates GitHub release with all binaries
- Auto-generates release notes

### 2. Dependabot Auto-merge (`.github/workflows/dependabot-auto-merge.yml`)

**Triggers:**
- Dependabot pull requests

**Behavior:**
- Auto-merges patch and minor version updates
- Requires CI to pass first
- Major updates require manual review

### 3. Dependabot Configuration (`.github/dependabot.yml`)

**Updates:**
- Flutter/Dart packages: Weekly
- GitHub Actions: Weekly
- Auto-labels PRs
- Uses conventional commit messages

## 🚀 Usage

### Running Tests Locally

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# With coverage
flutter test --coverage
```

### Building Locally

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release --no-codesign

# Web
flutter build web --release

# Desktop (requires platform enabled)
flutter build macos --release
flutter build linux --release
flutter build windows --release
```

### Creating a Release

1. **Tag your commit:**
   ```bash
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

2. **GitHub Actions will automatically:**
   - Run all tests
   - Build for all platforms
   - Create GitHub release
   - Upload all artifacts

3. **Download binaries from:**
   - GitHub Releases page
   - Or individual workflow run artifacts

## 📊 Artifacts

Each platform job uploads artifacts that are kept for 7 days:

| Platform | Artifact Name | Contents |
|----------|--------------|----------|
| Android | `android-apk` | app-release.apk |
| Android | `android-aab` | app-release.aab |
| iOS | `ios-ipa` | app-release.ipa |
| macOS | `macos-app` | skipthebrowse.app |
| macOS | `macos-dmg` | SkipTheBrowse.dmg |
| Linux | `linux-x64` | skipthebrowse-linux-x64.tar.gz |
| Windows | `windows-x64` | skipthebrowse-windows-x64.zip |
| Web | `web-build` | Complete web build |

## ⚙️ Configuration

### Flutter Version

Update in `.github/workflows/ci.yml`:
```yaml
env:
  FLUTTER_VERSION: '3.27.1'
```

### Branch Protection

Recommended branch protection rules for `main`:
- ✅ Require pull request reviews
- ✅ Require status checks to pass:
  - `analyze-and-test`
  - `android`
  - `ios`
  - `macos`
  - `linux`
  - `windows`
  - `web`
- ✅ Require branches to be up to date
- ✅ Require linear history

### Secrets Required

For full functionality, configure these GitHub secrets:

| Secret | Purpose | Required |
|--------|---------|----------|
| `GITHUB_TOKEN` | Automatic (built-in) | ✅ |
| `CODECOV_TOKEN` | Code coverage uploads | Optional |

For production releases, you may need:
- `ANDROID_KEYSTORE` - Android signing key
- `IOS_CERTIFICATE` - iOS signing certificate
- `IOS_PROVISIONING_PROFILE` - iOS provisioning profile

## 🐛 Troubleshooting

### Android Emulator Issues
- The workflow uses AVD caching for faster runs
- API level 34 (Android 14) is used
- KVM acceleration is enabled on Ubuntu runners

### iOS Simulator Issues
- Uses iPhone 15 Pro with iOS 18.1
- Simulator is created fresh for each run
- No codesigning for CI builds

### macOS DMG Creation
- Uses `create-dmg` from Homebrew
- Failure is non-fatal (continues without DMG)
- App bundle is still uploaded

### Linux Display Issues
- Integration tests use Xvfb (virtual display)
- GTK3 dependencies are required

### Windows Issues
- Uses PowerShell for archiving
- Path separators are handled automatically

## 📈 Optimization Tips

1. **Caching:**
   - Flutter SDK is cached per runner
   - Gradle dependencies are cached (Android)
   - AVD snapshots are cached (Android)

2. **Parallelization:**
   - All platform builds run in parallel
   - Only `analyze-and-test` blocks other jobs

3. **Timeout Protection:**
   - Each job has reasonable timeouts
   - Prevents stuck jobs from blocking queue

4. **Artifact Retention:**
   - 7 days for PR artifacts
   - Permanent for tagged releases

## 🔗 Related Documentation

- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter Build Modes](https://docs.flutter.dev/testing/build-modes)
