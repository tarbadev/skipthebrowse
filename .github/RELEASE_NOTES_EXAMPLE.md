# Release Notes Example

This shows how your release notes will look when following conventional commits.

---

## v1.2.0 (2025-11-09)

### ✨ New Features

- **conversation**: add suggested initial prompts for new users ([#45](https://github.com/user/repo/pull/45))
- **recommendations**: implement platform filtering (Netflix, Hulu, etc.) ([#46](https://github.com/user/repo/pull/46))
- **ui**: add dark mode toggle in settings ([#47](https://github.com/user/repo/pull/47))
- **auth**: implement Google OAuth login ([#48](https://github.com/user/repo/pull/48))

### 🐛 Bug Fixes

- **ui**: prevent keyboard overlap on chat input field ([#49](https://github.com/user/repo/pull/49))
- **conversation**: fix message history not persisting on app restart ([#50](https://github.com/user/repo/pull/50))
- **api**: handle network timeout errors gracefully ([#51](https://github.com/user/repo/pull/51))
- **recommendations**: correct rating display for TV shows ([#52](https://github.com/user/repo/pull/52))

### ⚡ Performance

- **recommendations**: implement caching layer for faster results ([#53](https://github.com/user/repo/pull/53))
- **api**: reduce initial load time by 40% ([#54](https://github.com/user/repo/pull/54))

### ♻️ Refactoring

- **auth**: extract token service into separate module ([#55](https://github.com/user/repo/pull/55))
- **conversation**: simplify message state management ([#56](https://github.com/user/repo/pull/56))

---

## Downloads

### Mobile
- **Android APK** - Direct installation for Android devices
- **Android App Bundle (AAB)** - For Google Play Store deployment
- **iOS IPA** - For iOS devices (requires proper signing/provisioning)

### Desktop
- **macOS** - Native macOS application (Apple Silicon & Intel)
- **Linux x64** - Tarball for Linux distributions
- **Windows x64** - ZIP archive for Windows 10/11

### Web
- **Web Bundle** - Static files for web hosting

---

## Installation

See individual platform instructions in the release assets.

---

## How This Works

1. **Commit with conventional format:**
   ```bash
   git commit -m "feat(conversation): add suggested prompts"
   ```

2. **Create a release tag:**
   ```bash
   git tag -a v1.2.0 -m "Release v1.2.0"
   git push origin v1.2.0
   ```

3. **GitHub Actions automatically:**
   - Parses all commits since last tag
   - Groups by type (feat, fix, perf, refactor)
   - Generates structured release notes
   - Attaches all platform binaries

4. **Result:**
   Beautiful, organized release notes that are easy to read!

---

## Comparison: Before vs After

### ❌ Before (Manual)
```
Release v1.2.0

- Added some features
- Fixed bugs
- Improved performance
```

### ✅ After (Automated)
```
## v1.2.0

### ✨ New Features (4)
- Detailed feature list with links

### 🐛 Bug Fixes (4)
- Specific bug fixes with links

### ⚡ Performance (2)
- Performance improvements with links

### ♻️ Refactoring (2)
- Code improvements with links
```

---

## Tips for Great Release Notes

1. **Be specific in commits:**
   - ❌ `fix: bug fix`
   - ✅ `fix(ui): prevent keyboard overlap on chat input`

2. **Use scopes consistently:**
   - Groups related changes together
   - Makes it easy to see what changed where

3. **Link issues/PRs:**
   - Include `(#123)` or `closes #123` in commit message
   - Automatically links in release notes

4. **Describe impact, not implementation:**
   - ❌ `feat: add new TextField widget`
   - ✅ `feat(conversation): add message suggestions for faster input`

5. **Test your commits locally:**
   ```bash
   # See what your release notes would look like
   git log v1.1.0..HEAD --oneline
   ```
