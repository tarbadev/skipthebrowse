# Environment Configuration

This project uses compile-time environment variables via `--dart-define` for configuration.

## Available Environments

- **local** (default): Development against local backend (`http://localhost:8080`)
- **dev**: Development environment (`https://skipthebrowse-backend.onrender.com`)
- **prod**: Production environment (TBD)

## Environment Variables

- `API_BASE_URL`: The base URL for the backend API (default: `http://localhost:8080`)
- `ENVIRONMENT`: The environment name (default: `local`)

## Usage

### Running the App

**Local development (default):**
```bash
flutter run
```

**Development environment:**
```bash
flutter run --dart-define=API_BASE_URL=https://skipthebrowse-backend.onrender.com --dart-define=ENVIRONMENT=dev
```

**Custom API URL:**
```bash
flutter run --dart-define=API_BASE_URL=http://custom-url.com --dart-define=ENVIRONMENT=custom
```

### Running Tests

**Unit tests** (use mocks, no environment needed):
```bash
flutter test
```

**Integration tests** against dev environment:
```bash
flutter test integration_test --dart-define=API_BASE_URL=https://skipthebrowse-backend.onrender.com --dart-define=ENVIRONMENT=dev
```

### Building

**Development build:**
```bash
flutter build apk --dart-define=API_BASE_URL=https://skipthebrowse-backend.onrender.com --dart-define=ENVIRONMENT=dev
```

**Production build:**
```bash
flutter build apk --dart-define=API_BASE_URL=https://prod-url.com --dart-define=ENVIRONMENT=prod
```

## CI/CD

The CI pipeline automatically runs integration tests against the dev environment using the configuration defined in `.github/workflows/ci.yml`.

## Implementation Details

Environment configuration is handled by:
- `lib/core/config/env_config.dart` - Environment configuration class
- `lib/features/conversation/domain/providers/dio_provider.dart` - Uses EnvConfig for API base URL
