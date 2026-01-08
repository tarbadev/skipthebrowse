import 'package:equatable/equatable.dart';

class StructuredChoice extends Equatable {
  final String id;
  final String displayText;
  final bool acceptsTextInput;
  final String? inputPlaceholder;

  const StructuredChoice({
    required this.id,
    required this.displayText,
    required this.acceptsTextInput,
    this.inputPlaceholder,
  });

  @override
  List<Object?> get props => [
    id,
    displayText,
    acceptsTextInput,
    inputPlaceholder,
  ];
}
