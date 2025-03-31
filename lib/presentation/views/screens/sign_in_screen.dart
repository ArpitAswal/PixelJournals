import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_journals/presentation/viewmodels/cubit/auth_cubit/cubit.dart';
import 'package:pixel_journals/core/colors.dart';

import '../../viewmodels/cubit/text_field_cubit/cubit.dart';
import '../widgets/text_field.dart';
import 'forgot_screen.dart';

/// SignUpScreen handles new user registration
/// Provides form validation and error handling through BLoC pattern
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String routeName = "/sign_in_screen";

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Form controllers for better memory management
  late final TextEditingController _emailController;

  // Focus nodes for field navigation
  late final FocusNode _emailFocusNode;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _passwordController;
  late final FocusNode _passwordFocusNode;

  @override
  void dispose() {
    // dispose of controllers and focus nodes
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _passwordFocusNode.removeListener(_onPassFocusChange);
    _passwordFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize controllers and focus nodes
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _emailFocusNode.addListener(_onEmailFocusChange);
    _passwordFocusNode.addListener(_onPassFocusChange);
  }

  // Handles focus changes for email and password fields
  void _onEmailFocusChange() {
    context.read<TextFieldCubit>().setEmailFocus(_emailFocusNode.hasFocus);
  }

  void _onPassFocusChange() {
    context.read<TextFieldCubit>().setPasswordFocus(
      _passwordFocusNode.hasFocus,
    );
  }

  /// Validates and submits the registration form
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  /// Handles different authentication states
  void _handleAuthStateChanges(BuildContext context, AuthState state) {
    if (state is AuthError) {
      _showErrorSnackBar(context, state.message);
    } else if (state is AuthSignedIn) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/posts_screen',
        (rooute) => false,
      ); // After successful login, navigate to posts screen
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

  Widget _buildForm(BuildContext context, AuthState state, Size size) {
    final isSmallScreen = size.height < 600;
    final padding = size.width * 0.06; // 6% of screen width
    final fieldSpacing = size.height * 0.02; // 2% of screen height

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: size.height * 0.03,
      ),
      child: Column(
        children: [
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: true,
                    checkColor: AppColors.white,
                    activeColor: AppColors.lightRed,
                    focusColor: AppColors.darkRed,
                    side: const BorderSide(color: AppColors.grey),
                    splashRadius: 6,
                    onChanged: (bool? value) {},
                  ),
                  Text("Remember me"),
                ],
              ),
              TextButton(
                onPressed: () {
                  // Navigate to Forgot Password screen to get password reset link
                  Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
                },
                child: Text(
                  "Forgot password?",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.lightRed),
                ),
              ),
            ],
          ),

          // Flexible spacing that adapts to screen size
          SizedBox(height: size.height * (isSmallScreen ? 0.1 : 0.2)),

          ElevatedButton(
            onPressed: () => _submit(),
            child:
                (state is AuthLoading)
                    ? CircularProgressIndicator(color: AppColors.white)
                    : Text("Login"),
          ),
          SizedBox(height: fieldSpacing),

          RichText(
            text: TextSpan(
              text: "Don't have an Account? ",
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.grey),
              children: [
                TextSpan(
                  text: "Sign up",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.lightRed),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/sign_up_screen',
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
                    Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.asset(
                          "assets/images/signin_bg.png",
                          height: size.height * (isSmallScreen ? 0.3 : 0.43),
                          width: size.width,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                        Positioned(
                          bottom: size.height * 0.02,
                          left: size.width * 0.04,
                          child: Text(
                            "Sign In",
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
                                _buildForm(context, state, size),
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
