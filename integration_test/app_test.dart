import 'package:integration_test/integration_test.dart';

import 'discovery_journey_test.dart' as discovery_journey;
import 'auth_lifecycle_journey_test.dart' as auth_journey;
import 'history_management_journey_test.dart' as history_journey;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Optimized for real-world interactions
  binding.testTextInput.register();

  // Run journeys sequentially within the same test session
  discovery_journey.main();
  auth_journey.main();
  history_journey.main();
}
