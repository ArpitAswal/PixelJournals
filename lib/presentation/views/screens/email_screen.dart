import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewmodels/cubit/auth_cubit/cubit.dart';
import '../../../core/colors.dart';

class EmailVerifiedScreen extends StatelessWidget {
  const EmailVerifiedScreen({super.key});

  static const String routeName = "/email_verified_screen";

  Widget _buildEmail(BuildContext context, AuthState state) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            "assets/images/email_verify.jpg",
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Text(
            "Verify your email address!",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Text(
            context.read<AuthCubit>().authInst.currentUser!.email.toString(),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.grey),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          ElevatedButton(
            onPressed: () => _confirm(context),
            child:
                (state is LoadingState)
                    ? const CircularProgressIndicator(color: AppColors.white)
                    : const Text("Continue"),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ElevatedButton(
            onPressed: () => _resend(context),
            style: ElevatedButton.styleFrom().copyWith(
              backgroundColor: WidgetStateProperty.all<Color>(AppColors.white),
              foregroundColor: WidgetStateProperty.all<Color>(
                AppColors.lightRed,
              ),
            ),
            child: Text("Resend"),
          ),
        ],
      ),
    );
  }

  // Handles the state of the AuthCubit
  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthError) {
      _showErrorSnackBar(context, state.message);
    } else if (state is AuthSignedIn) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/welcome_screen',
        (route) => false,
      ); // After email verification, navigate to welcome screen
    }
  }

  /// Shows error message in a SnackBar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
  }

  void _confirm(BuildContext context) {
    // Check if the email is verified, if it is, navigate to the welcome screen
    context.read<AuthCubit>().emailVerify();
  }

  void _resend(BuildContext context) {
    // Resend the email verification link to the user email
    context.read<AuthCubit>().resendEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: _handleState,
                builder: (context, state) => _buildEmail(context, state),
              ),
            );
          },
        ),
      ),
    );
  }
}
