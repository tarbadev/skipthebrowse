# Commit Message Convention

This project uses [Conventional Commits](https://www.conventionalcommits.org/) to automatically generate release notes.

## Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

## Types

### Included in Release Notes

- **feat**: New feature
  - Example: `feat(auth): add Google OAuth login`
  - Shows as: ✨ **New Features**

- **fix**: Bug fix
  - Example: `fix(ui): correct button alignment on mobile`
  - Shows as: 🐛 **Bug Fixes**

- **perf**: Performance improvement
  - Example: `perf(api): cache movie recommendations`
  - Shows as: ⚡ **Performance**

- **refactor**: Code refactoring (no functional change)
  - Example: `refactor(auth): simplify token validation`
  - Shows as: ♻️ **Refactoring**

- **revert**: Revert a previous commit
  - Example: `revert: revert feat(auth): add Google OAuth`
  - Shows as: ⏪ **Reverts**

### Excluded from Release Notes

- **build**: Build system or dependencies
  - Example: `build(deps): update flutter to 3.35.7`

- **ci**: CI configuration changes
  - Example: `ci: add Android build workflow`

- **docs**: Documentation only
  - Example: `docs: update API documentation`

- **style**: Code style (formatting, semicolons, etc.)
  - Example: `style: format code with dart format`

- **test**: Adding or updating tests
  - Example: `test: add integration tests for login`

- **chore**: Maintenance tasks
  - Example: `chore: update .gitignore`

## Scopes (Optional)

Use scopes to indicate which part of the app is affected:

- **auth**: Authentication
- **ui**: User interface
- **api**: API integration
- **db**: Database
- **nav**: Navigation
- **settings**: Settings
- **onboarding**: Onboarding flow
- **conversation**: Conversation feature
- **recommendations**: Recommendation feature

## Breaking Changes

For breaking changes, add `BREAKING CHANGE:` in the footer or use `!` after type:

```
feat(api)!: change session response format

BREAKING CHANGE: Session response now includes user preferences.
Previous integrations need to be updated.
```

## Examples

### Good Commit Messages

```bash
feat(conversation): add initial message suggestions
fix(ui): prevent keyboard overlap on chat input
perf(recommendations): implement caching layer
refactor(auth): extract token service
docs: add architecture decision records
test(conversation): add unit tests for message validation
```

### Bad Commit Messages

```bash
# ❌ Too vague
fix: bug fix

# ❌ No type
add login feature

# ❌ Not descriptive
update code

# ❌ Mixing changes
feat: add login and fix navigation bug
```

## Release Note Preview

When you create a release tag, commits will be grouped like this:

```markdown
## ✨ New Features
- **conversation**: add initial message suggestions (#123)
- **auth**: implement OAuth login (#124)

## 🐛 Bug Fixes
- **ui**: prevent keyboard overlap on chat input (#125)
- **api**: handle network timeout errors (#126)

## ⚡ Performance
- **recommendations**: implement caching layer (#127)

## ♻️ Refactoring
- **auth**: extract token service (#128)
```

## Setting Up Commit Template (Optional)

Create a commit message template locally:

```bash
# Create template file
cat > ~/.gitmessage << 'EOF'
# <type>(<scope>): <subject>
#
# <body>
#
# <footer>
#
# Types: feat, fix, perf, refactor, revert, build, ci, docs, style, test, chore
# Scopes: auth, ui, api, db, nav, settings, onboarding, conversation, recommendations
#
# Examples:
#   feat(conversation): add message suggestions
#   fix(ui): correct button alignment
#   perf(api): cache recommendations
EOF

# Configure git to use it
git config --global commit.template ~/.gitmessage
```

## Commitlint (Optional)

To enforce conventional commits, install commitlint:

```bash
# Add to package.json (if using)
npm install --save-dev @commitlint/cli @commitlint/config-conventional
echo "module.exports = {extends: ['@commitlint/config-conventional']}" > commitlint.config.js

# Add to .git/hooks/commit-msg
npx commitlint --edit $1
```
