#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Check if version argument is provided
if [ -z "$1" ]; then
    print_error "Usage: ./release.sh <version>"
    echo "Example: ./release.sh 1.0.0"
    echo "Example: ./release.sh 1.0.0+42"
    exit 1
fi

NEW_VERSION="$1"

# Validate version format (semantic versioning with optional build number)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(\+[0-9]+)?$ ]]; then
    print_error "Invalid version format. Use semantic versioning: MAJOR.MINOR.PATCH or MAJOR.MINOR.PATCH+BUILD"
    echo "Examples: 1.0.0, 1.2.3+42"
    exit 1
fi

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not a git repository"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_error "You have uncommitted changes. Please commit or stash them first."
    git status --short
    exit 1
fi

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}')
print_info "Current version: $CURRENT_VERSION"
print_info "New version: $NEW_VERSION"

# Confirm with user
echo ""
read -p "Do you want to create release v$NEW_VERSION? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Release cancelled"
    exit 0
fi

# Update version in pubspec.yaml
print_info "Updating pubspec.yaml..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
else
    # Linux
    sed -i "s/^version: .*/version: $NEW_VERSION/" pubspec.yaml
fi

# Verify the change
NEW_VERSION_CHECK=$(grep "^version:" pubspec.yaml | awk '{print $2}')
if [ "$NEW_VERSION_CHECK" != "$NEW_VERSION" ]; then
    print_error "Failed to update version in pubspec.yaml"
    exit 1
fi

print_success "Updated pubspec.yaml to version $NEW_VERSION"

# Git commit
print_info "Creating git commit..."
git add pubspec.yaml
git commit -m "chore(release): bump version to $NEW_VERSION"
print_success "Created commit"

# Create annotated tag
print_info "Creating git tag v$NEW_VERSION..."
git tag -a "v$NEW_VERSION" -m "Release version $NEW_VERSION"
print_success "Created tag v$NEW_VERSION"

# Ask if user wants to push
echo ""
read -p "Push commit and tag to remote? (y/N) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Pushing to remote..."

    # Get current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    # Push commit
    git push origin "$CURRENT_BRANCH"
    print_success "Pushed commit to $CURRENT_BRANCH"

    # Push tag
    git push origin "v$NEW_VERSION"
    print_success "Pushed tag v$NEW_VERSION"

    echo ""
    print_success "Release v$NEW_VERSION completed and pushed!"
else
    echo ""
    print_info "Commit and tag created locally. To push later, run:"
    echo "  git push origin $(git rev-parse --abbrev-ref HEAD)"
    echo "  git push origin v$NEW_VERSION"
fi

echo ""
print_success "✨ Release process complete!"
