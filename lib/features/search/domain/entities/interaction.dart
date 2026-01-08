import 'package:equatable/equatable.dart';
import 'interaction_prompt.dart';

class Interaction extends Equatable {
  final String id;
  final String? userInput;
  final InteractionPrompt assistantPrompt;
  final DateTime timestamp;

  const Interaction({
    required this.id,
    required this.userInput,
    required this.assistantPrompt,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userInput, assistantPrompt, timestamp];
}
