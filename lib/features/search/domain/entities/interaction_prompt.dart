import 'package:equatable/equatable.dart';
import 'structured_choice.dart';

class InteractionPrompt extends Equatable {
  final String promptPrefix;
  final List<StructuredChoice> choices;
  final bool allowSkip;

  const InteractionPrompt({
    required this.promptPrefix,
    required this.choices,
    required this.allowSkip,
  });

  @override
  List<Object?> get props => [promptPrefix, choices, allowSkip];
}
