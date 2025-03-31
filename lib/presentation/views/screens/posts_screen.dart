import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../viewmodels/cubit/auth_cubit/cubit.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});
  static const String routeName = "/posts_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSignedOut) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/sign_in_screen',
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return InkWell(
            onTap: () {
              context.read<AuthCubit>().signOut();
            },
            child: Center(
              child: Text(
                "Sign Out",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          );
        },
      ),
    );
  }
}
