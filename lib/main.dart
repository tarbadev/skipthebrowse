import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/route_provider.dart';

void main() {
  runApp(const ProviderScope(child: SkipTheBrowse()));
}

class SkipTheBrowse extends ConsumerWidget {
  const SkipTheBrowse({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MaterialApp.router(routerConfig: router),
    );
  }
}
