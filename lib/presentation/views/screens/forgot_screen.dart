import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewmodels/cubit/auth_cubit/cubit.dart';
import '../../viewmodels/cubit/text_field_cubit/cubit.dart';
import '../widgets/text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String routeName = "/forgot_password_screen";

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController
  _emailController; // Form controller for better memory management

  late final FocusNode _emailFocusNode; // Focus nodes for field navigation
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailFocusNode = FocusNode();
    _emailFocusNode.addListener(_onEmailFocusChange);
  }

  //  Listens to focus changes on the email field
  void _onEmailFocusChange() {
    context.read<TextFieldCubit>().setEmailFocus(_emailFocusNode.hasFocus);
  }

  /// Handles different authentication states
  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthError) {
      _showErrorSnackBar(context, state.message);
    } else if (state is AuthInitial) {
      _showErrorSnackBar(context, "Check your email for password reset link");
      Navigator.of(context).pop();
      // here AuthInitialState represent that link is successfully sent to the user without any error.
    }
  }

  /// Shows error message in a SnackBar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          duration: Duration(seconds: 3),
        ),
      );
  }

  /// Validates and submits the registration form
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().resetPassword(
      email: _emailController.text.trim(),
    );
  }

  Widget _buildForm(BuildContext context, AuthState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Forgot Password",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),

          EmailTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            labelText: "Enter email",
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Invalid email address';
              }
              return null;
            },
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          ElevatedButton(
            onPressed: () => _submit(),
            child:
                (state is LoadingState)
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/common_bg.png",
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
              Form(
                key: _formKey,
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: _handleState,
                  builder: _buildForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
