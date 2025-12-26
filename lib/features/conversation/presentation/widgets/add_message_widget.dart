import 'package:flutter/material.dart';

typedef OnSubmitCallback = Future<void> Function(String);

class AddMessageWidget extends StatefulWidget {
  final OnSubmitCallback onSubmit;
  final bool isLoading;
  final int minLength;

  const AddMessageWidget({
    super.key,
    required this.onSubmit,
    required this.isLoading,
    this.minLength = 2,
  });

  @override
  State<StatefulWidget> createState() {
    return _AddMessageWidgetState();
  }
}

class _AddMessageWidgetState extends State<AddMessageWidget> {
  final TextEditingController _controller = TextEditingController();
  String _message = '';
  String? _validationError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateMessage(String message) => setState(() {
    _message = message;
    _validationError = null;
  });

  String? _validateMessage(String message) {
    if (message.length < widget.minLength) {
      return 'Message must be at least ${widget.minLength} characters';
    }
    if (message.length > 500) {
      return 'Message must not exceed 500 characters';
    }
    return null;
  }

  Future<void> _addMessage() async {
    final error = _validateMessage(_message);
    if (error != null) {
      setState(() {
        _validationError = error;
      });
      return;
    }

    await widget.onSubmit(_message);

    // Clear the text field after successful submission
    if (mounted) {
      _controller.clear();
      setState(() {
        _message = '';
        _validationError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF242424),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('add_message_text_box'),
                controller: _controller,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: 'Describe what you\'re looking for...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                onChanged: _updateMessage,
                enabled: !widget.isLoading,
                onSubmitted: (_) => _message.isNotEmpty ? _addMessage() : null,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _message.isNotEmpty
                    ? const Color(0xFF6366F1)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                key: const Key('add_message_button'),
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  color: _message.isNotEmpty
                      ? Colors.white
                      : Colors.white.withOpacity(0.2),
                ),
                onPressed: _message.isNotEmpty ? _addMessage : null,
              ),
            ),
          ],
        ),
      ),
      if (_validationError != null)
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 4),
          child: Text(
            _validationError!,
            key: const Key('add_message_validation_error'),
            style: TextStyle(
              color: const Color(0xFFEF4444).withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
    ],
  );
}
