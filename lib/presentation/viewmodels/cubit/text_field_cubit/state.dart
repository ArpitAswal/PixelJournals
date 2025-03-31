import 'package:equatable/equatable.dart';

class TextFieldState extends Equatable {
  // Equatable is used to compare the state objects
  const TextFieldState({
    this.isPasswordVisible = false,
    this.isEmailFocused = false,
    this.isPasswordFocused = false,
    this.isUserNameFocused = false,
  });

  final bool isEmailFocused;
  final bool isPasswordFocused;
  final bool isPasswordVisible;
  final bool isUserNameFocused;

  @override
  List<Object> get props => [
    // List of properties to compare
    isPasswordVisible,
    isEmailFocused,
    isPasswordFocused,
    isUserNameFocused,
  ];

  TextFieldState copyWith({
    // copyWith is used to create a new instance of the state with updated values
    bool? isPasswordVisible,
    bool? isEmailFocused,
    bool? isPasswordFocused,
    bool? isUserNameFocused,
  }) {
    return TextFieldState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isEmailFocused: isEmailFocused ?? this.isEmailFocused,
      isPasswordFocused: isPasswordFocused ?? this.isPasswordFocused,
      isUserNameFocused: isUserNameFocused ?? this.isUserNameFocused,
    );
  }
}
