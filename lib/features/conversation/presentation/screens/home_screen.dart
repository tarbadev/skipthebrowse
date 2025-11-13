import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/conversation.dart';
import '../widgets/create_conversation_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('SkipTheBrowse'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Looking for something to watch?',
              key: Key('home_page_title'),
            ),
            CreateConversationWidget(
              callback: (Conversation conversation) =>
                  context.push('/conversation', extra: conversation),
            ),
          ],
        ),
      ),
    );
  }
}
