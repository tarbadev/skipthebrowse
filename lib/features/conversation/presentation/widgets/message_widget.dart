import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final String text;

  const MessageWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}
