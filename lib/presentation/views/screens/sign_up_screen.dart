import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_journals/presentation/viewmodels/cubit/auth_cubit/cubit.dart';
import 'package:pixel_journals/core/colors.dart';

import '../../viewmodels/cubit/text_field_cubit/cubit.dart';
import '../widgets/text_field.dart';

/// SignUpScreen handles new user registration
/// Provides form validation and error handling through BLoC pattern
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const String routeName = "/sign_up_screen";

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Form controllers for better memory management
  late final TextEditingController _emailController;

  late final FocusNode _emailFocusNode;
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _passwordController;
  late final FocusNode _passwordFocusNode;
  late final TextEditingController _usernameController;
  // Focus nodes for field navigation
  late final FocusNode _usernameFocusNode;

  @override
  void dispose() {
    // dispose of controllers and focus nodes
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _passwordFocusNode.removeListener(_onPassFocusChange);
    _usernameFocusNode.removeListener(_onUserNameFocusChange);
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _emailFocusNode.addListener(_onEmailFocusChange);
    _passwordFocusNode.addListener(_onPassFocusChange);
    _usernameFocusNode.addListener(_onUserNameFocusChange);
  }

  // listener methods for focus changes
  void _onEmailFocusChange() {
    context.read<TextFieldCubit>().setEmailFocus(_emailFocusNode.hasFocus);
  }

  void _onPassFocusChange() {
    context.read<TextFieldCubit>().setPasswordFocus(
      _passwordFocusNode.hasFocus,
    );
  }

  void _onUserNameFocusChange() {
    context.read<TextFieldCubit>().setUserNameFocus(
      _usernameFocusNode.hasFocus,
    );
  }

  /// Validates and submits the registration form
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().signUpWithEmail(
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  /// Handles different authentication states
  void _handleAuthStateChanges(BuildContext context, AuthState state) {
    if (state is AuthError) {
      _showErrorSnackBar(context, state.message);
    } else if (state is AuthSignedUp) {
      _showErrorSnackBar(
        context,
        "Email verification link has been sent to your email...",
      );
      Navigator.pushNamed(context, '/email_verified_screen');
      // After successful sign-up, navigate to the email verification screen for authenticate email
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

  Widget _buildResponsiveForm(
    BuildContext context,
    AuthState state,
    Size size,
  ) {
    final isSmallScreen = size.height < 600;
    final padding = size.width * 0.06; // 6% of screen width
    final fieldSpacing = size.height * 0.02; // 2% of screen height

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: size.height * 0.03,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EmailTextField(
            controller: _usernameController,
            labelText: "Enter username",
            focusNode: _usernameFocusNode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please provide username...";
              }
              if (value.length < 5) {
                return "Please provide longer username...";
              }
              return null;
            },
            prefixIcon: Icons.verified_user_outlined,
          ),
          SizedBox(height: fieldSpacing),
          EmailTextField(
            controller: _emailController,
            labelText: "Enter email",
            focusNode: _emailFocusNode,
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
            prefixIcon: Icons.email_outlined,
          ),
          SizedBox(height: fieldSpacing),
          PasswordTextField(
            controller: _passwordController,
            labelText: "Enter password",
            focusNode: _passwordFocusNode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please provide password...";
              }
              if (value.length < 6) {
                return "Please provide longer password...";
              }
              return null;
            },
          ),
          // Flexible spacing that adapts to screen size
          SizedBox(height: size.height * (isSmallScreen ? 0.15 : 0.3)),

          ElevatedButton(
            onPressed: () => _submit(),
            child:
                (state is AuthLoading)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Account"),
          ),
          SizedBox(height: fieldSpacing),
          RichText(
            text: TextSpan(
              text: "Already have an account? ",
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.grey),
              children: [
                TextSpan(
                  text: "Login",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.lightRed),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/sign_in_screen',
                          );
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Image
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.asset(
                          "assets/images/signup_bg.png",
                          height: size.height * (isSmallScreen ? 0.25 : 0.3),
                          width: size.width,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                        Positioned(
                          bottom: size.height * 0.02,
                          left: size.width * 0.04,
                          child: Text(
                            "Sign Up",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                      ],
                    ),
                    // Form
                    Form(
                      key: _formKey,
                      child: BlocConsumer<AuthCubit, AuthState>(
                        listener: _handleAuthStateChanges,
                        builder:
                            (context, state) =>
                                _buildResponsiveForm(context, state, size),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
