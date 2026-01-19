import 'package:flutter/material.dart';
import 'package:skipthebrowse/core/utils/responsive_utils.dart';
import 'package:skipthebrowse/features/search/domain/entities/interaction_prompt.dart';

class InteractionPromptWidget extends StatefulWidget {
  final InteractionPrompt prompt;
  final Function(String choiceId, String? customInput) onSubmit;
  final bool isEnabled;
  final VoidCallback? onChoiceSelected;

  const InteractionPromptWidget({
    super.key,
    required this.prompt,
    required this.onSubmit,
    this.isEnabled = true,
    this.onChoiceSelected,
  });

  @override
  State<InteractionPromptWidget> createState() =>
      _InteractionPromptWidgetState();
}

class _InteractionPromptWidgetState extends State<InteractionPromptWidget> {
  String? _selectedChoiceId;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleChoiceSelected(String choiceId) {
    setState(() {
      _selectedChoiceId = choiceId;
      _textController.clear();
    });

    // Trigger scroll callback after state is updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChoiceSelected?.call();
    });
  }

  void _handleSubmit() {
    if (_selectedChoiceId == null) return;

    final selectedChoice = widget.prompt.choices.firstWhere(
      (c) => c.id == _selectedChoiceId,
      orElse: () => widget.prompt.choices.first,
    );

    final customInput =
        selectedChoice.acceptsTextInput && _textController.text.isNotEmpty
        ? _textController.text
        : null;

    widget.onSubmit(_selectedChoiceId!, customInput);

    setState(() {
      _selectedChoiceId = null;
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final selectedChoice = _selectedChoiceId != null
        ? widget.prompt.choices.firstWhere(
            (c) => c.id == _selectedChoiceId,
            orElse: () => widget.prompt.choices.first,
          )
        : null;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: responsive.responsive(
          mobile: 16.0,
          tablet: 20.0,
          desktop: 24.0,
        ),
        vertical: responsive.responsive(
          mobile: 8.0,
          tablet: 10.0,
          desktop: 12.0,
        ),
      ),
      padding: EdgeInsets.all(
        responsive.responsive(mobile: 16.0, tablet: 18.0, desktop: 20.0),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(responsive.borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prompt prefix
          Text(
            widget.prompt.promptPrefix,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: responsive.fontSize(15),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          SizedBox(
            height: responsive.responsive(
              mobile: 12.0,
              tablet: 14.0,
              desktop: 16.0,
            ),
          ),

          // Choice buttons
          Wrap(
            spacing: responsive.responsive(
              mobile: 8.0,
              tablet: 10.0,
              desktop: 12.0,
            ),
            runSpacing: responsive.responsive(
              mobile: 8.0,
              tablet: 10.0,
              desktop: 12.0,
            ),
            children: widget.prompt.choices.map((choice) {
              final isSelected = _selectedChoiceId == choice.id;
              return _ChoiceButton(
                choice: choice,
                isSelected: isSelected,
                isEnabled: widget.isEnabled,
                onPressed: () => _handleChoiceSelected(choice.id),
              );
            }).toList(),
          ),

          // Optional text input
          if (selectedChoice != null && selectedChoice.acceptsTextInput) ...[
            SizedBox(
              height: responsive.responsive(
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              ),
            ),
            TextField(
              controller: _textController,
              enabled: widget.isEnabled,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.fontSize(15),
              ),
              decoration: InputDecoration(
                hintText:
                    selectedChoice.inputPlaceholder ??
                    'Tell us more... (optional)',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(responsive.borderRadius),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(responsive.borderRadius),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(responsive.borderRadius),
                  borderSide: const BorderSide(
                    color: Color(0xFF6366F1),
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ],

          // Submit button
          if (_selectedChoiceId != null) ...[
            SizedBox(
              height: responsive.responsive(
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isEnabled ? _handleSubmit : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: responsive.responsive(
                      mobile: 14.0,
                      tablet: 16.0,
                      desktop: 18.0,
                    ),
                  ),
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      responsive.borderRadius,
                    ),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: responsive.fontSize(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final dynamic choice;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _ChoiceButton({
    required this.choice,
    required this.isSelected,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.responsive(
            mobile: 16.0,
            tablet: 18.0,
            desktop: 20.0,
          ),
          vertical: responsive.responsive(
            mobile: 12.0,
            tablet: 13.0,
            desktop: 14.0,
          ),
        ),
        backgroundColor: isSelected
            ? const Color(0xFF6366F1)
            : Colors.white.withValues(alpha: 0.05),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.borderRadius),
        ),
      ),
      child: Text(
        choice.displayText,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: responsive.fontSize(14),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
