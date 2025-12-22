.PHONY: help release release-github test build clean run format lint

# Default target
help:
	@echo "SkipTheBrowse Client - Available Commands:"
	@echo ""
	@echo "  make release VERSION=1.0.0         - Create a new release (updates version, commits, tags)"
	@echo "  make release-github VERSION=1.0.0  - Create GitHub release (requires gh CLI)"
	@echo "  make test                          - Run all tests"
	@echo "  make build                         - Generate code (build_runner)"
	@echo "  make clean                         - Clean build artifacts"
	@echo "  make run                           - Run the app in debug mode"
	@echo "  make run-dev                       - Run against dev backend"
	@echo "  make format                        - Format code"
	@echo "  make lint                          - Analyze code"
	@echo ""

# Create a new release (local)
release:
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Error: VERSION is required"; \
		echo "Usage: make release VERSION=1.0.0"; \
		exit 1; \
	fi
	@./release.sh $(VERSION)

# Create GitHub release (requires gh CLI)
release-github:
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Error: VERSION is required"; \
		echo "Usage: make release-github VERSION=1.0.0"; \
		exit 1; \
	fi
	@./create-release.sh $(VERSION)

# Run tests
test:
	@echo "Running tests..."
	@flutter test

# Generate code with build_runner
build:
	@echo "Generating code..."
	@dart run build_runner build --delete-conflicting-outputs

# Watch mode for build_runner
build-watch:
	@echo "Watching for changes..."
	@dart run build_runner watch --delete-conflicting-outputs

# Clean build artifacts
clean:
	@echo "Cleaning..."
	@flutter clean
	@rm -rf .dart_tool/
	@rm -rf build/

# Run app in debug mode
run:
	@echo "Running app (local backend)..."
	@flutter run

# Run app against dev backend
run-dev:
	@echo "Running app (dev backend)..."
	@flutter run \
		--dart-define=API_BASE_URL=https://skipthebrowse-backend.onrender.com \
		--dart-define=ENVIRONMENT=dev

# Format code
format:
	@echo "Formatting code..."
	@dart format lib/ test/

# Analyze code
lint:
	@echo "Analyzing code..."
	@flutter analyze

# Get dependencies
deps:
	@echo "Getting dependencies..."
	@flutter pub get

# Run integration tests
test-integration:
	@echo "Running integration tests..."
	@flutter test integration_test \
		--dart-define=API_BASE_URL=https://skipthebrowse-backend.onrender.com \
		--dart-define=ENVIRONMENT=dev
