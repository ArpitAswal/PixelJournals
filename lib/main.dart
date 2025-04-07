import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_journals/data/repositories/auth_repository.dart';
import 'package:pixel_journals/data/repositories/post_repository.dart';
import 'package:pixel_journals/presentation/viewmodels/bloc/chat_bloc.dart';
import 'package:pixel_journals/presentation/viewmodels/bloc/create_post_bloc.dart';
import 'package:pixel_journals/presentation/viewmodels/bloc/posts_bloc.dart';
import 'package:pixel_journals/presentation/viewmodels/cubit/auth_cubit/cubit.dart';
import 'package:pixel_journals/core/colors.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:pixel_journals/presentation/views/screens/auth_check_screen.dart';
import 'package:pixel_journals/presentation/views/screens/chat_screen.dart';
import 'package:pixel_journals/presentation/views/screens/create_post_screen.dart';
import 'package:pixel_journals/presentation/views/screens/forgot_screen.dart';

import 'data/repositories/user_repository.dart';
import 'presentation/viewmodels/bloc/user_bloc.dart';
import 'presentation/viewmodels/cubit/navigation_cubit/cubit.dart';
import 'presentation/viewmodels/cubit/post_cubit/cubit.dart';
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
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]); // Set the preferred orientations to portrait up
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  ); // Set the system UI mode to immersive sticky
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

  void _initialization() async {
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove(); // Remove the splash screen after initialization
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // Using MultiBlocProvider to provide multiple blocs to the widget tree
      providers: [
        BlocProvider(create: (context) => TextFieldCubit()),
        BlocProvider(
          create: (context) => AuthCubit(authRepository: AuthRepository()),
        ),
        BlocProvider(
          create: (context) => PostsBloc(PostsRepository())..add(LoadPosts()),
        ),
        BlocProvider(create: (context) => ChatBloc(PostsRepository())),
        BlocProvider(create: (context) => CreatePostBloc(PostsRepository())),
        BlocProvider(
          create:
              (context) =>
                  UserBloc(userRepository: UserRepository())..add(LoadUsers()),
        ),
        BlocProvider(create: (context) => NavigationCubit()),
        BlocProvider(
          create: (context) => PostDetailCubit(repository: PostsRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Pixel Journals',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Theme data for the app
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.lightRed,
            centerTitle: true,
            foregroundColor: AppColors.white,
          ),
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
              minimumSize: Size(MediaQuery.of(context).size.width, 40),
              elevation: 8.0,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              textStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        home: AuthCheckScreen(),
        routes: {
          // Define all the routes for the app
          SignUpScreen.routeName: (context) => const SignUpScreen(),
          SignInScreen.routeName: (context) => const SignInScreen(),
          ForgotPasswordScreen.routeName:
              (context) => const ForgotPasswordScreen(),
          EmailVerifiedScreen.routeName:
              (context) => const EmailVerifiedScreen(),
          PostsScreen.routeName: (context) => PostsScreen(),
          WelcomeScreen.routeName: (context) => const WelcomeScreen(),
          CreatePostScreen.routeName: (context) => const CreatePostScreen(),
          ChatScreen.routeName: (context) => const ChatScreen(),
        },
      ),
    );
  }
}
