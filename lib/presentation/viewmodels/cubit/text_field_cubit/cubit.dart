import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class TextFieldCubit extends Cubit<TextFieldState> {
  // Cubit class to manage the state of text fields
  TextFieldCubit() : super(const TextFieldState());

  void togglePasswordVisibility() {
    emit(
      state.copyWith(isPasswordVisible: !state.isPasswordVisible),
    ); // Toggle password visibility
  }

  void setEmailFocus(bool focused) {
    // Set focus state for email field
    emit(state.copyWith(isEmailFocused: focused));
  }

  void setPasswordFocus(bool focused) {
    // Set focus state for password field
    emit(state.copyWith(isPasswordFocused: focused));
  }

  void setUserNameFocus(bool hasFocus) {
    // Set focus state for username field
    emit(state.copyWith(isUserNameFocused: hasFocus));
  }
}
