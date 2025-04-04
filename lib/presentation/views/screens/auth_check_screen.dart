import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_journals/presentation/views/screens/posts_screen.dart';
import 'package:pixel_journals/presentation/views/screens/sign_in_screen.dart';

import '../../viewmodels/cubit/auth_cubit/cubit.dart';

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: _buildScreen);
  }

  Widget _buildScreen(BuildContext context, AuthState state) {
    if (state is AuthSignedIn) {
      return PostsScreen();
    } else if (state is AuthSignedOut) {
      return SignInScreen();
    } else if (state is AuthInitial) {
      return CircularProgressIndicator();
    } else {
      return Scaffold(body: Text("App User Interface is yet to build"));
    }
  }
}
