# Flutter Client Codebase Analysis Report

**Generated:** 2026-01-17
**Project:** SkipTheBrowse Flutter Client
**Analysis Scope:** Architecture, Security, Code Duplication, Error Handling, Edge Cases

---

## Executive Summary

This report identifies **25 issues** across 5 categories found in the Flutter client codebase:
- **1 Critical Security Issue** (unencrypted token storage)
- **3 High Priority Issues** (null safety, race conditions, state management)
- **12 Medium Priority Issues** (architecture, error handling, code duplication)
- **9 Low Priority Issues** (minor improvements, optimizations)

---

## Priority 1: CRITICAL (Must Fix Immediately)

### 🔴 C-1: Unencrypted Token Storage

**Severity:** Critical
**Category:** Security
**Files:** `lib/features/auth/data/repositories/api_auth_repository.dart:36-48`

**Issue:**
```dart
Future<void> saveSession(AuthSession session) async {
  await _prefs.setString(_tokenKey, session.token.accessToken);  // Line 37
  await _prefs.setString(_tokenTypeKey, session.token.tokenType);  // Line 38
  await _prefs.setString(_userKey, jsonEncode({...}));  // Lines 39-46
}
```

Authentication tokens and user data are stored in **plain text** in SharedPreferences without encryption.

**Risk:**
- Tokens accessible to any app with file system access on rooted devices
- No protection against device theft or malicious apps
- Sensitive user data (username, email, ID) stored unencrypted
- Could lead to account takeover or data breach

**Recommendation:**
```dart
// Replace SharedPreferences with flutter_secure_storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _secureStorage = const FlutterSecureStorage();

Future<void> saveSession(AuthSession session) async {
  await _secureStorage.write(key: _tokenKey, value: session.token.accessToken);
  await _secureStorage.write(key: _tokenTypeKey, value: session.token.tokenType);
  await _secureStorage.write(key: _userKey, value: jsonEncode({...}));
}
```

**Effort:** 4-6 hours (including dependency update, migration, testing)

---

## Priority 2: HIGH (Fix Within Sprint)

### 🟠 H-1: Null Safety Violation in List Operations

**Severity:** High
**Category:** Edge Cases / Error Handling
**Files:** `lib/features/search/domain/state/search_session_notifier.dart:38-47`

**Issue:**
```dart
final selectedChoice = currentSession
    .interactions
    .last  // ❌ Throws StateError if interactions is empty
    .assistantPrompt
    .choices
    .firstWhere(
      (c) => c.id == choiceId,
      orElse: () =>
          currentSession.interactions.last.assistantPrompt.choices.first,
    );
```

**Risk:**
- App crashes if `interactions` list is empty
- Also crashes in `orElse` if `choices` is empty
- No defensive programming for edge cases

**Recommendation:**
```dart
Future<void> addInteraction(String sessionId, String choiceId, {String? customInput}) async {
  final currentSession = state.value;
  if (currentSession == null || currentSession.interactions.isEmpty) {
    state = AsyncValue.error('Invalid session state', StackTrace.current);
    return;
  }

  final lastInteraction = currentSession.interactions.last;
  if (lastInteraction.assistantPrompt.choices.isEmpty) {
    state = AsyncValue.error('No choices available', StackTrace.current);
    return;
  }

  final selectedChoice = lastInteraction.assistantPrompt.choices.firstWhere(
    (c) => c.id == choiceId,
    orElse: () => lastInteraction.assistantPrompt.choices.first,
  );
  // ... rest of implementation
}
```

**Effort:** 2-3 hours (add guards, unit tests, edge case testing)

---

### 🟠 H-2: Race Condition in Message Queue

**Severity:** High
**Category:** Edge Cases / Concurrency
**Files:** `lib/features/conversation/domain/services/pending_message_queue.dart:38-65`

**Issue:**
```dart
Future<void> remove(PendingMessage message) async {
  final messages = await getAll();  // State read
  messages.removeWhere(
    (msg) =>
        msg.conversationId == message.conversationId &&
        msg.content == message.content &&
        msg.timestamp == message.timestamp,  // ❌ Relies on exact timestamp match
  );
  await _saveQueue(messages);  // State write - race condition window
}
```

**Risk:**
- Multiple concurrent `remove()` calls could corrupt queue state
- Timestamp-based matching is fragile (millisecond precision)
- If two identical messages have same timestamp, both get removed
- State changes between read and write not prevented

**Recommendation:**
```dart
// Add message ID for reliable identification
@freezed
class PendingMessage with _$PendingMessage {
  const factory PendingMessage({
    required String id,  // ✅ Add unique ID
    required String conversationId,
    required String content,
    required DateTime timestamp,
  }) = _PendingMessage;
}

// Use mutex/lock for atomic operations
Future<void> remove(PendingMessage message) async {
  await _lock.synchronized(() async {  // ✅ Prevent race conditions
    final messages = await getAll();
    messages.removeWhere((msg) => msg.id == message.id);  // ✅ ID-based removal
    await _saveQueue(messages);
  });
}
```

**Effort:** 4-6 hours (refactor with IDs, add locking, migration, testing)

---

### 🟠 H-3: Missing Error Type Differentiation

**Severity:** High
**Category:** Error Handling
**Files:** `lib/features/conversation/domain/state/conversation_notifier.dart:59-71`

**Issue:**
```dart
try {
  final conversation = await repository.addMessage(id, messageContent);
  await pendingQueue.remove(pendingMessage);
  state = AsyncValue.data(conversation);
} catch (err) {  // ❌ Catches ALL errors without differentiation
  final failedMessage = userMessage.copyWith(status: MessageStatus.failed);
  // Same treatment for timeout, 500 error, no network, etc.
  final failedConversation = Conversation(...);
  state = AsyncValue.data(failedConversation);
}
```

**Risk:**
- Network timeout treated same as 400 validation error
- No retry logic for transient failures (500, timeout)
- User gets same error message regardless of cause
- No offline queue for network failures

**Recommendation:**
```dart
try {
  final conversation = await repository.addMessage(id, messageContent);
  await pendingQueue.remove(pendingMessage);
  state = AsyncValue.data(conversation);
} on DioException catch (err) {
  if (err.type == DioExceptionType.connectionTimeout ||
      err.type == DioExceptionType.receiveTimeout ||
      err.response?.statusCode == 500 ||
      err.response?.statusCode == 503) {
    // Transient error - keep in queue for retry
    final retryMessage = userMessage.copyWith(status: MessageStatus.pending);
    state = AsyncValue.data(currentConversation.copyWith(
      messages: [...currentConversation.messages, retryMessage]
    ));
  } else if (err.response?.statusCode == 400 || err.response?.statusCode == 422) {
    // Validation error - mark as failed permanently
    final failedMessage = userMessage.copyWith(status: MessageStatus.failed);
    await pendingQueue.remove(pendingMessage);
    state = AsyncValue.data(currentConversation.copyWith(
      messages: [...currentConversation.messages, failedMessage]
    ));
  } else {
    // Unknown error
    state = AsyncValue.error(err, StackTrace.current);
  }
} catch (err, stack) {
  state = AsyncValue.error(err, stack);
}
```

**Effort:** 6-8 hours (implement error categorization, retry logic, testing)

---

## Priority 3: MEDIUM (Address This Quarter)

### 🟡 M-1: State Management Pattern Duplication

**Severity:** Medium
**Category:** Architecture / Code Quality
**Files:**
- `lib/features/auth/domain/state/auth_notifier.dart`
- `lib/features/conversation/domain/state/conversation_notifier.dart`
- `lib/features/search/domain/state/search_session_notifier.dart`

**Issue:**
All StateNotifier classes repeat identical error handling boilerplate:
```dart
state = const AsyncValue.loading();
try {
  // ... operation
  state = AsyncValue.data(result);
} catch (err, stack) {
  state = AsyncError<Type?>(err, stack);
}
```

**Recommendation:**
```dart
// Create base class or mixin
mixin StateNotifierErrorHandling<T> on StateNotifier<AsyncValue<T>> {
  Future<void> runAsync(Future<T> Function() operation) async {
    state = const AsyncValue.loading();
    try {
      final result = await operation();
      state = AsyncValue.data(result);
    } catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
}

// Usage in notifiers
class AuthNotifier extends StateNotifier<AsyncValue<AuthState?>>
    with StateNotifierErrorHandling<AuthState?> {

  Future<void> login(String email, String password) async {
    await runAsync(() => repository.login(email, password));
  }
}
```

**Effort:** 4-6 hours (create mixin, refactor 3 notifiers, test)

---

### 🟡 M-2: HTTP Client Configuration Duplication

**Severity:** Medium
**Category:** Architecture
**Files:**
- `lib/features/conversation/domain/providers/dio_provider.dart:8-51`
- `lib/features/search/data/repositories/search_rest_client.dart`

**Issue:**
Two Dio providers created with near-identical configuration:
```dart
// Lines 8-25
final baseDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
  return dio;
});

// Lines 27-51 - duplicate timeouts, different interceptors
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),  // ❌ Duplicated
    receiveTimeout: const Duration(seconds: 30),  // ❌ Duplicated
  ));
  // ...
});
```

**Recommendation:**
```dart
// Single source of truth for HTTP config
class ApiConfig {
  static const connectTimeout = Duration(seconds: 10);  // Reduced from 30s
  static const receiveTimeout = Duration(seconds: 15);

  static BaseOptions get defaultOptions => BaseOptions(
    baseUrl: EnvConfig.apiBaseUrl,
    connectTimeout: connectTimeout,
    receiveTimeout: receiveTimeout,
  );
}

// Use in provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(ApiConfig.defaultOptions);
  // Add interceptors
  return dio;
});
```

**Effort:** 2-3 hours

---

### 🟡 M-3: Tight Repository-RestClient Coupling

**Severity:** Medium
**Category:** Architecture
**Files:**
- `lib/features/conversation/domain/providers/conversation_providers.dart:22-27`
- `lib/features/search/domain/providers/search_providers.dart:12`

**Issue:**
```dart
final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final restClient = RestClient(dio, baseUrl: dio.options.baseUrl);  // ❌ Created inline
  return ApiConversationRepository(restClient: restClient);
});
```

**Recommendation:**
```dart
// Separate RestClient into its own provider
final conversationRestClientProvider = Provider<RestClient>((ref) {
  final dio = ref.watch(dioProvider);
  return RestClient(dio, baseUrl: dio.options.baseUrl);
});

final conversationRepositoryProvider = Provider<ConversationRepository>((ref) {
  final restClient = ref.watch(conversationRestClientProvider);
  return ApiConversationRepository(restClient: restClient);
});
```

**Effort:** 2-3 hours (refactor providers, update tests)

---

### 🟡 M-4: State Loss in Pagination Error Handling

**Severity:** Medium
**Category:** Error Handling
**Files:** `lib/features/conversation/domain/state/conversation_list_notifier.dart:135-137`

**Issue:**
```dart
} catch (e, stack) {
  state = AsyncValue.error(e, stack);  // ❌ Loses previous conversations
}
```

When pagination fails, user loses visibility of already-loaded conversations.

**Recommendation:**
```dart
} catch (e, stack) {
  // Preserve existing data, just mark pagination as failed
  state = AsyncValue.data(currentState.copyWith(
    isLoadingMore: false,
    hasError: true,
    errorMessage: e.toString(),
  ));
}
```

**Effort:** 2 hours

---

### 🟡 M-5: Widget Styling Duplication

**Severity:** Medium
**Category:** Code Duplication
**Files:**
- `conversation_screen.dart:159-186`
- `search_session_screen.dart:145-174`
- `recommendation_history_screen.dart`

**Issue:**
Identical responsive padding patterns repeated across 3+ screens:
```dart
padding: EdgeInsets.only(
  top: responsive.responsive(
    mobile: 100.0,
    tablet: 110.0,
    desktop: 120.0,
  ),
  bottom: 20,
),
```

**Recommendation:**
```dart
// lib/core/theme/spacing.dart
class AppSpacing {
  static const topPadding = ResponsiveValue(
    mobile: 100.0,
    tablet: 110.0,
    desktop: 120.0,
  );
  static const bottomPadding = 20.0;
}

// Usage
padding: EdgeInsets.only(
  top: responsive.responsive(AppSpacing.topPadding),
  bottom: AppSpacing.bottomPadding,
),
```

**Effort:** 3-4 hours

---

### 🟡 M-6: Message Bubble Display Duplication

**Severity:** Medium
**Category:** Code Duplication
**Files:** `search_session_screen.dart:161-313`, `conversation_screen.dart`

**Issue:**
Identical bubble styling code appears twice in same file (lines 177-209, 264-300).

**Recommendation:**
```dart
// Extract to reusable widget
class MessageBubbleWidget extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF6366F1) : Colors.grey[200],
        borderRadius: _getBorderRadius(),
      ),
      child: Text(text),
    );
  }
}
```

**Effort:** 3-4 hours

---

### 🟡 M-7: Error State Display Duplication

**Severity:** Medium
**Category:** Code Duplication
**Files:**
- `conversation_list_screen.dart:243-325`
- `recommendation_history_screen.dart`

**Issue:**
Nearly identical error UI across multiple screens.

**Recommendation:**
```dart
// lib/core/widgets/error_state_widget.dart
class ErrorStateWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Something went wrong'),
          Text(error.toString(), style: TextStyle(color: Colors.grey)),
          SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text('Retry')),
        ],
      ),
    );
  }
}
```

**Effort:** 2-3 hours

---

### 🟡 M-8: No SSL Certificate Pinning

**Severity:** Medium
**Category:** Security
**Files:** `lib/features/conversation/domain/providers/dio_provider.dart`

**Issue:**
Dio client created without SSL certificate pinning.

**Risk:**
- Vulnerable to man-in-the-middle attacks on untrusted networks
- No validation of server certificate authenticity

**Recommendation:**
```dart
// Add certificate pinning for production
import 'package:dio/adapter.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(ApiConfig.defaultOptions);

  if (EnvConfig.environment == 'prod') {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) => false;
      // Add certificate pinning
      SecurityContext context = SecurityContext();
      context.setTrustedCertificates('assets/certs/skipthebrowse.pem');
      return HttpClient(context: context);
    };
  }

  return dio;
});
```

**Effort:** 6-8 hours (obtain certs, configure, test)

---

### 🟡 M-9: Missing Empty Collection Checks

**Severity:** Medium
**Category:** Edge Cases
**Files:**
- `conversation_screen.dart:73-75`
- `search_session_notifier.dart:54-76`

**Issue:**
No handling if both conversation state and widget parameter are null.

**Recommendation:**
Add null checks and empty state UI where collections are accessed.

**Effort:** 2-3 hours

---

### 🟡 M-10: Unimplemented Search Feature

**Severity:** Medium
**Category:** UX / Edge Cases
**Files:** `lib/features/conversation/presentation/screens/conversation_list_screen.dart:63`

**Issue:**
```dart
onChanged: (value) {
  // TODO: Implement search for sessions  // ❌ Search UI present but non-functional
  setState(() {});
},
```

**Risk:**
Users expect search to work based on UI affordance.

**Recommendation:**
Either implement search or hide the UI element until ready.

**Effort:** 8-12 hours (implement) or 1 hour (hide UI)

---

### 🟡 M-11: No Timeout Differentiation

**Severity:** Medium
**Category:** Error Handling / UX
**Files:** `lib/features/conversation/domain/providers/dio_provider.dart:12-13`

**Issue:**
```dart
connectTimeout: const Duration(seconds: 30),  // ❌ Too long for mobile
receiveTimeout: const Duration(seconds: 30),
```

**Risk:**
30 seconds before failure provides poor mobile UX.

**Recommendation:**
```dart
connectTimeout: const Duration(seconds: 10),  // Shorter connect timeout
receiveTimeout: const Duration(seconds: 20),  // Longer for large responses
```

**Effort:** 1 hour

---

### 🟡 M-12: Missing Enum Validation

**Severity:** Medium
**Category:** Error Handling
**Files:** `lib/features/search/data/repositories/api_search_repository.dart:99-110`

**Issue:**
```dart
String _statusToString(RecommendationStatus status) {
  switch (status) {
    case RecommendationStatus.proposed: return 'proposed';
    case RecommendationStatus.seen: return 'seen';
    case RecommendationStatus.willWatch: return 'will_watch';
    case RecommendationStatus.declined: return 'declined';
    // ❌ No default case - silent failure if enum extended
  }
}
```

**Recommendation:**
```dart
String _statusToString(RecommendationStatus status) {
  switch (status) {
    case RecommendationStatus.proposed: return 'proposed';
    case RecommendationStatus.seen: return 'seen';
    case RecommendationStatus.willWatch: return 'will_watch';
    case RecommendationStatus.declined: return 'declined';
  }
  // Dart 3 enforces exhaustiveness, but add assertion for safety
  throw ArgumentError('Unknown status: $status');
}
```

**Effort:** 1 hour

---

## Priority 4: LOW (Nice to Have)

### 🟢 L-1: Test Setup Code Duplication

**Severity:** Low
**Category:** Code Quality / Testing
**Files:** Multiple test files

**Issue:**
Mock setup boilerplate repeated across test files.

**Recommendation:**
Extract common mock setup to test helpers.

**Effort:** 2-3 hours

---

### 🟢 L-2: Loading State Duplication

**Severity:** Low
**Category:** Code Duplication
**Files:** Multiple screens

**Issue:**
`CircularProgressIndicator` with identical styling repeated.

**Recommendation:**
Create `LoadingStateWidget`.

**Effort:** 1-2 hours

---

### 🟢 L-3: Timestamp Formatting Duplication

**Severity:** Low
**Category:** Code Duplication
**Files:** `conversation_list_screen.dart:608-638`

**Issue:**
`_formatTimestamp()` duplicated across screens.

**Recommendation:**
```dart
// lib/core/utils/date_utils.dart
extension DateTimeFormatting on DateTime {
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
```

**Effort:** 2 hours

---

### 🟢 L-4: Username Input Validation

**Severity:** Low
**Category:** Security / Input Validation
**Files:** `lib/features/auth/data/interceptors/auth_interceptor.dart:54-58`

**Issue:**
```dart
final username = (currentUsername != null && currentUsername.isNotEmpty)
    ? currentUsername  // ❌ No length/format validation
    : _generateValidUsername();
```

**Recommendation:**
```dart
final username = (currentUsername != null &&
                 currentUsername.isNotEmpty &&
                 currentUsername.length <= 50 &&
                 RegExp(r'^[a-zA-Z0-9-_]+$').hasMatch(currentUsername))
    ? currentUsername
    : _generateValidUsername();
```

**Effort:** 1 hour

---

### 🟢 L-5: User Data in Error Logs

**Severity:** Low
**Category:** Security / Privacy
**Files:** `lib/features/auth/data/interceptors/auth_interceptor.dart:40-46`

**Issue:**
```dart
scope.setContexts('user_auth', {
  'is_anonymous': isAnonymous,  // Could leak info
  'has_token': prefs.getString(_tokenKey) != null,
});
```

**Recommendation:**
Remove `has_token` field from error context.

**Effort:** 30 minutes

---

### 🟢 L-6: Message Input Sanitization

**Severity:** Low
**Category:** Security
**Files:** `lib/features/conversation/presentation/widgets/add_message_widget.dart:39-47`

**Issue:**
Only length validation, no XSS prevention.

**Recommendation:**
If backend doesn't sanitize, add HTML escaping:
```dart
import 'package:html_escape/html_escape.dart';

String _sanitizeInput(String input) {
  return HtmlEscape().convert(input);
}
```

**Effort:** 1-2 hours (if needed)

---

### 🟢 L-7: Pagination Race Condition Prevention

**Severity:** Low
**Category:** Edge Cases
**Files:** `conversation_list_notifier.dart:104-138`

**Issue:**
No lock mechanism to prevent concurrent pagination requests.

**Recommendation:**
```dart
bool _isPaginationInProgress = false;

Future<void> loadMoreConversations() async {
  if (_isPaginationInProgress) return;
  _isPaginationInProgress = true;

  try {
    // ... pagination logic
  } finally {
    _isPaginationInProgress = false;
  }
}
```

**Effort:** 1 hour

---

### 🟢 L-8: Repository Error Handling

**Severity:** Low
**Category:** Architecture
**Files:** `api_conversation_repository.dart:9-61`

**Issue:**
All errors bubble up unhandled; no repository-level error transformation.

**Recommendation:**
Create custom exception types:
```dart
class RepositoryException implements Exception {
  final String message;
  final Object? originalError;
  RepositoryException(this.message, [this.originalError]);
}

@override
Future<Conversation> createConversation(String question) async {
  try {
    final request = CreateConversationRequest(message: question, region: 'US');
    final response = await restClient.createConversation(request);
    return response.toConversation();
  } on DioException catch (e) {
    throw RepositoryException('Failed to create conversation', e);
  }
}
```

**Effort:** 4-6 hours (create exception hierarchy, update all repositories)

---

### 🟢 L-9: Optimistic Update Edge Case

**Severity:** Low
**Category:** Edge Cases
**Files:** `search_session_notifier.dart:54-76`

**Issue:**
If `updatedInteractions` is empty, optimistic update crashes.

**Recommendation:**
Add guard clause before `updatedInteractions.last`.

**Effort:** 30 minutes

---

## Summary Statistics

| Priority | Count | Categories |
|----------|-------|------------|
| Critical | 1 | Security |
| High | 3 | Edge Cases, Concurrency, Error Handling |
| Medium | 12 | Architecture, Code Duplication, Security, UX |
| Low | 9 | Code Quality, Testing, Minor Improvements |
| **Total** | **25** | |

---

## Recommended Action Plan

### Sprint 1 (Week 1-2): Critical & High Priority
1. **C-1**: Implement `flutter_secure_storage` for tokens (6 hrs)
2. **H-1**: Add null safety checks in list operations (3 hrs)
3. **H-2**: Fix message queue race condition (6 hrs)
4. **H-3**: Implement error type differentiation (8 hrs)

**Total:** ~23 hours

### Sprint 2 (Week 3-4): Medium Priority Architecture
1. **M-1**: Extract state management patterns (6 hrs)
2. **M-2**: Centralize HTTP configuration (3 hrs)
3. **M-3**: Decouple repository providers (3 hrs)
4. **M-4**: Preserve state in pagination errors (2 hrs)
5. **M-8**: Implement SSL pinning (8 hrs)

**Total:** ~22 hours

### Sprint 3 (Week 5-6): Medium Priority Code Quality
1. **M-5, M-6, M-7**: Extract reusable widgets (10 hrs)
2. **M-10**: Implement or hide search feature (8 hrs)
3. **M-11, M-12**: Timeout & enum validation (2 hrs)

**Total:** ~20 hours

### Ongoing: Low Priority Improvements
Address during maintenance cycles or when touching related code.

---

## Risk Assessment

| Issue | Likelihood | Impact | Risk Score |
|-------|------------|--------|------------|
| C-1: Token theft | High | Critical | 🔴 9/10 |
| H-1: Null crash | Medium | High | 🟠 7/10 |
| H-2: Queue corruption | Medium | High | 🟠 7/10 |
| H-3: Poor error UX | High | Medium | 🟡 6/10 |
| M-8: MITM attack | Low | High | 🟡 5/10 |

---

## Testing Requirements

For each fix, ensure:
1. **Unit tests** covering edge cases
2. **Widget tests** for UI changes
3. **Integration tests** for flows
4. **Manual testing** on iOS & Android
5. **Performance testing** for state management changes

---

## Notes

- **Architecture patterns** should be established before implementing new features
- **Security fixes** should be backported to production immediately
- **Code duplication** cleanup can be done incrementally
- **Error handling improvements** will significantly improve user experience

---

**End of Report**
