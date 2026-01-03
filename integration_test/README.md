# Integration Tests (E2E)

This directory contains true end-to-end integration tests that run on real devices/simulators and make real API calls to the backend.

## Prerequisites

1. **Backend server must be running**
   ```bash
   cd ../skipthebrowse-backend
   poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

2. **Device or simulator must be available**
   - Android: Start an Android emulator or connect a physical device
   - iOS: Start an iOS simulator or connect a physical device
   - Check with: `flutter devices`

## Running E2E Tests

### Run all integration tests
```bash
flutter test integration_test
```

### Run with specific environment
```bash
# Local backend (default)
flutter test integration_test --dart-define=API_BASE_URL=http://localhost:8000 --dart-define=ENVIRONMENT=local

# Development backend
flutter test integration_test --dart-define=API_BASE_URL=https://skipthebrowse-backend-dev.onrender.com --dart-define=ENVIRONMENT=dev

# Production backend
flutter test integration_test --dart-define=API_BASE_URL=https://skipthebrowse-backend.onrender.com --dart-define=ENVIRONMENT=prod
```

### Run specific test file
```bash
flutter test integration_test/auth_e2e_test.dart
```

### Run on specific device
```bash
flutter test integration_test -d <device-id>

# Example for Android
flutter test integration_test -d emulator-5554

# Example for iOS
flutter test integration_test -d "iPhone 15 Pro"
```

## Test Coverage

### Authentication E2E Tests (`auth_e2e_test.dart`)
- **Automatic authentication**: Verifies that the app automatically creates an anonymous user on first launch
- **Token persistence**: Verifies that auth tokens and user data are stored in SharedPreferences
- **Authenticated requests**: Verifies that API requests succeed with authentication (proves Authorization header is working)
- **End-to-end conversation flow**: Verifies that the entire flow from auth to conversation creation works

## Test Structure

E2E tests differ from unit tests:
- **No mocks**: Use real implementations (RestClient, SharedPreferences, etc.)
- **Real API calls**: Make actual HTTP requests to the backend
- **Device required**: Must run on a real device or simulator
- **Longer timeouts**: Network requests and LLM responses can take time

## Troubleshooting

### Tests timing out
- Increase timeout in test: `timeout: const Timeout(Duration(seconds: 60))`
- Check that backend is running and accessible
- Verify network connectivity on device/simulator

### Connection refused errors
- For Android emulator, use `10.0.2.2` instead of `localhost`:
  ```bash
  flutter test integration_test --dart-define=API_BASE_URL=http://10.0.2.2:8000
  ```
- For iOS simulator, `localhost` should work

### SharedPreferences not clearing
- Each test has a setUp that clears SharedPreferences
- If tests interfere with each other, run them individually

### Backend auth errors
- Make sure backend has the correct SECRET_KEY in .env
- Check backend logs for auth-related errors
- Verify that the anonymous user endpoint is working:
  ```bash
  curl -X POST http://localhost:8000/api/v1/auth/anonymous \
    -H "Content-Type: application/json" \
    -d '{"username": "test-user-1234"}'
  ```

## Notes

- These tests will create real data in the backend database
- Tests clean up SharedPreferences between runs
- Consider using a test database for backend when running E2E tests
