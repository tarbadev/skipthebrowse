import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(routes: routes, debugLogDiagnostics: true);
});
