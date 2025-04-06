import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_journals/presentation/views/screens/all_users_screen.dart';
import 'package:pixel_journals/presentation/views/screens/posts_screen.dart';
import 'package:pixel_journals/presentation/views/screens/sign_in_screen.dart';

import '../../../core/colors.dart';
import '../../viewmodels/cubit/auth_cubit/cubit.dart';
import '../../viewmodels/cubit/navigation_cubit/cubit.dart';

import 'chat_screen.dart';
import 'settings_screen.dart';

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  Widget _buildScreen(BuildContext context, AuthState state) {
    if (state is AuthSignedIn) {
      // Check if the user is signed in
      return BottomNavigationScreen();
    } else if (state is AuthError) {
      // Check if there is an error
      return Scaffold(
        body: Center(
          child: Text(
            state.message,
            style: TextStyle(color: AppColors.lightRed, fontSize: 20),
          ),
        ),
      );
    } else {
      // If the user is not signed in, show the sign-in screen
      return SignInScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: _buildScreen,
    ); // Use BlocBuilder to listen to the AuthCubit state changes
  }
}

class BottomNavigationScreen extends StatelessWidget {
  BottomNavigationScreen({super.key});

  final List<IconData> _icons = [
    Icons.photo_size_select_large_outlined,
    Icons.chat_outlined,
    Icons.person_add_outlined,
    Icons.settings_outlined,
  ];

  final List<Widget> _screens = [
    PostsScreen(),
    ChatScreen(),
    AllUsersScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, NavigationState>(
      // Use BlocBuilder to listen to the NavigationCubit state changes
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.05,
            ),
            child:
                _screens[state
                    .selectedItem
                    .index], // Use the selected item index to get the corresponding screen
          ),
          bottomNavigationBar: CurvedNavigationBar(
            height: MediaQuery.of(context).size.height * 0.08,
            index:
                state
                    .selectedItem
                    .index, // Set the initial index to the selected item index
            items:
                _icons
                    .map((icon) => Icon(icon, color: AppColors.white))
                    .toList(),
            color: AppColors.lightRed,
            buttonBackgroundColor: AppColors.lightRed,
            backgroundColor: Colors.transparent,
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 300),
            onTap: (index) {
              context.read<NavigationCubit>().navigate(index);
            },
          ),
          extendBody:
              true, // To make body extend behind the curved navigation bar
        );
      },
    );
  }
}
