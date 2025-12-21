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
    _controller.clear();
    setState(() {
      _message = '';
      _validationError = null;
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: TextField(
              key: Key('add_message_text_box'),
              controller: _controller,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText:
                    'Enter a brief description of what you would like to watch',
                filled: true,
              ),
              onChanged: _updateMessage,
              enabled: !widget.isLoading,
            ),
          ),
          if (widget.isLoading)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              key: Key('add_message_button'),
              icon: Icon(Icons.send),
              onPressed: _message.isNotEmpty ? _addMessage : null,
            ),
        ],
      ),
      if (_validationError != null)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _validationError!,
            key: Key('add_message_validation_error'),
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
        ),
    ],
  );
}
