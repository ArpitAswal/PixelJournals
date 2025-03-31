import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodels/cubit/text_field_cubit/cubit.dart';
import '../../viewmodels/cubit/text_field_cubit/state.dart';
import '../../../core/colors.dart';

// This widget is a custom text field for entering email addresses.
class EmailTextField extends StatelessWidget {
  const EmailTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.validator,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final IconData prefixIcon;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TextFieldCubit, TextFieldState>(
      // Listen to the TextFieldCubit state changes and rebuild the widget accordingly. for instance when the text field is focused or unfocused on either email or username.
      builder: (context, state) {
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          focusNode: focusNode,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          autocorrect: false,
          cursorColor: AppColors.lightRed,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color:
                labelText == "Enter email"
                    ? state.isEmailFocused
                        ? AppColors.lightRed
                        : Colors.grey
                    : state.isUserNameFocused
                    ? AppColors.lightRed
                    : Colors.grey,
          ),
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(prefixIcon),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightRed),
            ),
            prefixIconColor:
                labelText == "Enter email"
                    ? state.isEmailFocused
                        ? AppColors.lightRed
                        : Colors.grey
                    : state.isUserNameFocused
                    ? AppColors.lightRed
                    : Colors.grey,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color:
                  labelText == "Enter email"
                      ? state.isEmailFocused
                          ? AppColors.lightRed
                          : Colors.grey
                      : state.isUserNameFocused
                      ? AppColors.lightRed
                      : Colors.grey,
            ),
          ),
          validator: validator,
        );
      },
    );
  }
}

// This widget is a custom text field for entering passwords.
class PasswordTextField extends StatelessWidget {
  const PasswordTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    this.validator,
  });

  final String? Function(String?)? validator;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TextFieldCubit, TextFieldState>(
      // Listen to the TextFieldCubit state changes and rebuild the widget accordingly.
      builder: (context, state) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: !state.isPasswordVisible,
          validator: validator,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.none,
          autocorrect: false,
          cursorColor: AppColors.lightRed,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: state.isPasswordFocused ? AppColors.lightRed : Colors.grey,
          ),
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                state.isPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              color: state.isPasswordFocused ? AppColors.lightRed : Colors.grey,
              onPressed:
                  () =>
                      context.read<TextFieldCubit>().togglePasswordVisibility(),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.lightRed),
            ),
            prefixIconColor:
                state.isPasswordFocused ? AppColors.lightRed : Colors.grey,
            suffixIconColor:
                state.isPasswordFocused ? AppColors.lightRed : Colors.grey,
            labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: state.isPasswordFocused ? AppColors.lightRed : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}
