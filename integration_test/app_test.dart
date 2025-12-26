import 'package:integration_test/integration_test.dart';

import 'conversation_navigation_test.dart' as conversation_navigation_test;
import 'conversation_starters_test.dart' as conversation_starters_test;
import 'home_test.dart' as home_test;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  binding.testTextInput.register();

  home_test.main();
  conversation_navigation_test.main();
  conversation_starters_test.main();
}
