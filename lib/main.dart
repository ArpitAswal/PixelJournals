import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_journals/data/repositories/auth_repository.dart';
import 'package:pixel_journals/presentation/viewmodels/cubit/auth_cubit/cubit.dart';
import 'package:pixel_journals/core/colors.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pixel_journals/presentation/views/screens/forgot_screen.dart';

import 'presentation/viewmodels/cubit/text_field_cubit/cubit.dart';
import 'presentation/views/screens/email_screen.dart';
import 'presentation/views/screens/posts_screen.dart';
import 'presentation/views/screens/sign_in_screen.dart';
import 'presentation/views/screens/sign_up_screen.dart';

import 'firebase_options.dart';
import 'presentation/views/screens/welcome_screen.dart';

void main() async {
  WidgetsBinding binding =
      WidgetsFlutterBinding.ensureInitialized(); // Ensures that the binding is initialized before using it
  FlutterNativeSplash.preserve(
    widgetsBinding: binding,
  ); // Preserve the splash screen
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase with the default options
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    // Initialize Firebase and other services here if needed
    _initialization();
  }

  // Checks authState
  Widget _buildMainScreen() {
    return FutureBuilder<User?>(
      future: _getUser(), // Fetch user with latest data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        final user = snapshot.data;
        if (user == null) {
          return const SignInScreen();
        }

        return user.emailVerified
            ? const PostsScreen()
            : const EmailVerifiedScreen();
      },
    );
  }

  Future<User?> _getUser() async {
    return FirebaseAuth.instance.currentUser; // Get the current instance user
  }

  void _initialization() async {
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove(); // Remove the splash screen after initialization
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => TextFieldCubit()),
        BlocProvider(
          create: (context) => AuthCubit(authRepository: AuthRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Pixel Journals',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Theme data for the app
          scaffoldBackgroundColor: AppColors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.black,
            primary: AppColors.lightRed,
            secondary: AppColors.white,
            error: AppColors.darkRed,
          ),
          textTheme: const TextTheme(
            labelLarge: TextStyle(fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontWeight: FontWeight.bold),
            headlineLarge: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightRed,
              foregroundColor: AppColors.white,
              minimumSize: Size(MediaQuery.of(context).size.width, 50),
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              textStyle: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        home: _buildMainScreen(),
        routes: {
          // Define all the routes for the app
          SignUpScreen.routeName: (context) => const SignUpScreen(),
          SignInScreen.routeName: (context) => const SignInScreen(),
          ForgotPasswordScreen.routeName:
              (context) => const ForgotPasswordScreen(),
          EmailVerifiedScreen.routeName:
              (context) => const EmailVerifiedScreen(),
          PostsScreen.routeName: (context) => const PostsScreen(),
          WelcomeScreen.routeName: (context) => const WelcomeScreen(),
          //CreatePostScreen.routeName: (context) => const CreatePostScreen(),
          //ChatScreen.routeName: (context) => const ChatScreen(),
        },
      ),
    );
  }
}
