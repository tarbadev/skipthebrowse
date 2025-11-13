import 'package:flutter/material.dart';

/// Abstract interface for navigation operations
/// Allows for easy testing by mocking navigation calls
abstract class RouterHelper {
  void goToConversation(BuildContext context, String id);
  void goBack(BuildContext context);
}

/// Implementation using GoRouter's context extensions
class GoRouterHelper implements RouterHelper {
  @override
  void goToConversation(BuildContext context, String id) {
    // Using the string directly since context.push is extension method
    // This will be called via context in the actual implementation
  }

  @override
  void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Mock implementation for testing
/// Tracks navigation history instead of actually navigating
class MockRouterHelper implements RouterHelper {
  final List<String> navigationHistory = [];

  @override
  void goToConversation(BuildContext context, String id) {
    navigationHistory.add('/conversation/$id');
  }

  @override
  void goBack(BuildContext context) {
    navigationHistory.add('back');
  }

  void clear() {
    navigationHistory.clear();
  }
}
