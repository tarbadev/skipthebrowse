#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_section() {
    echo -e "${BLUE}$1${NC}"
}

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    print_error "GitHub CLI (gh) is not installed"
    echo ""
    echo "Install it with:"
    echo "  macOS:   brew install gh"
    echo "  Linux:   See https://github.com/cli/cli#installation"
    echo "  Windows: See https://github.com/cli/cli#installation"
    echo ""
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    print_error "Not authenticated with GitHub CLI"
    echo ""
    echo "Run: gh auth login"
    echo ""
    exit 1
fi

# Get version from argument or pubspec.yaml
if [ -n "$1" ]; then
    VERSION="$1"
else
    VERSION=$(grep "^version:" pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)
fi

TAG="v$VERSION"

print_section "==================================================="
print_section "  Creating GitHub Release for $TAG"
print_section "==================================================="
echo ""

# Check if tag exists
if ! git tag -l | grep -q "^$TAG$"; then
    print_error "Tag $TAG does not exist"
    echo ""
    echo "Create the tag first with:"
    echo "  ./release.sh $VERSION"
    echo "  or"
    echo "  make release VERSION=$VERSION"
    exit 1
fi

# Check if tag is pushed
if ! git ls-remote --tags origin | grep -q "refs/tags/$TAG$"; then
    print_error "Tag $TAG is not pushed to remote"
    echo ""
    echo "Push the tag with:"
    echo "  git push origin $TAG"
    exit 1
fi

# Check if release notes file exists
NOTES_FILE="RELEASE_NOTES_$TAG.md"
if [ ! -f "$NOTES_FILE" ]; then
    print_error "Release notes file not found: $NOTES_FILE"
    echo ""
    echo "Create the file or the release will use auto-generated notes."
    read -p "Continue without release notes file? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    NOTES_FILE=""
fi

print_info "Tag: $TAG"
print_info "Release notes: ${NOTES_FILE:-Auto-generated}"
echo ""

# Create the release
print_info "Creating GitHub release..."

if [ -n "$NOTES_FILE" ]; then
    gh release create "$TAG" \
        --title "Release $TAG" \
        --notes-file "$NOTES_FILE"
else
    gh release create "$TAG" \
        --title "Release $TAG" \
        --generate-notes
fi

print_success "GitHub release created successfully!"
echo ""
print_info "View the release at:"
REPO_URL=$(git config --get remote.origin.url | sed 's/\.git$//' | sed 's|git@github.com:|https://github.com/|')
echo "  $REPO_URL/releases/tag/$TAG"
