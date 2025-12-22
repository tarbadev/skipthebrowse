# Release Notes - v0.0.1

## ✨ New Features

- Add conversation list and navigation
- Add quick reply buttons for tap-to-respond UX
- Add provider logos to recommendation cards
- Add possibility to add a message to a conversation
- Make minimum message in conversation to be 3 instead of 10
- Implement type-safe routes with GoRouter
- Add environment configuration support
- Add input validation for conversation creation
- Implement error handling with AsyncValue and StateNotifier
- Add initial ConversationScreen layout

## 🐛 Bug Fixes

- Show user-facing error when URL fails to launch
- Reduce minimum message length from 10 to 1 character
- Remove hardcoded baseUrl from RestApi annotation
- Fix new frame being created at each message
- Pass Dio baseUrl to RestClient to respect environment config
- Update HomePageTester to work with StateNotifier pattern

## ♻️ Refactoring

- Use ConversationResponse code to mock adding a message via API
- Rename integration_test to e2e_test
- Refactor component create_conversation into add_message

---

**Full Changelog**: https://github.com/tarbadev/skipthebrowse/commits/v0.0.1
