import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_journals/data/repositories/auth_repository.dart';

import '../../../../data/models/user_model.dart';

part 'state.dart';

class AuthCubit extends Cubit<AuthState> {
  // AuthState is an abstract class that extends Equatable
  AuthCubit({required AuthRepository authRepository})
    : _authRepository =
          authRepository, // initialize the _authRepository variable with the authRepository parameter
      authInst =
          FirebaseAuth
              .instance, // initialize the authInst variable with an instance of FirebaseAuth
      super(AuthInitial()) {
    // initialize the state to AuthInitial
    _currentUserState();
  }

  final FirebaseAuth authInst;

  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authUser;

  @override
  Future<void> close() {
    _authUser?.cancel();
    return super.close();
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(AuthLoading()); // emit the loading state

    final result = await _authRepository.signUpWithEmail(
      email: email,
      password: password,
      username: username,
    );

    if (result is AuthSignedUp) {
      // check if the result is of type AuthSignedUp
      emit(AuthSignedUp(result.user));
    } else if (result is AuthError) {
      // check if the result is of type AuthError
      emit(AuthError(result.message));
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await _authRepository.signInWithEmail(
      email: email,
      password: password,
    );

    if (result is AuthSignedIn) {
      emit(AuthSignedIn(result.user)); // emit the signed in state with the user
    } else if (result is AuthError) {
      emit(
        AuthError(result.message),
      ); // emit the error state with the error message
    }
  }

  Future<void> resetPassword({required String email}) async {
    emit(LoadingState());
    final result = await _authRepository.resetPassword(email: email);
    if (result is AuthInitial) {
      emit(AuthInitial()); // emit the initial state
    } else if (result is AuthError) {
      emit(AuthError(result.message));
    }
  }

  Future<void> emailVerify() async {
    emit(LoadingState());
    await Future.delayed(const Duration(seconds: 1));
    if (authInst.currentUser != null) {
      // check if the current user is not null
      await authInst.currentUser?.reload(); // reload the current user
      if (authInst.currentUser!.emailVerified) {
        // check if the email is verified
        final user = UserModel(
          userId: authInst.currentUser!.uid,
          userEmail: authInst.currentUser!.email!,
          userName: authInst.currentUser!.displayName ?? 'NA',
          isEmailVerified: authInst.currentUser!.emailVerified,
        );
        emit(AuthSignedIn(user)); // emit the signed in state with the user
        _authRepository.saveUserInfo(
          user,
        ); // save the user info to the repository
      } else {
        emit(AuthError("Email not verified yet!"));
      }
    } else {
      emit(
        AuthError("User not found!"),
      ); // emit the error state if the user is not found
    }
  }

  void resendEmail() async {
    await authInst.currentUser
        ?.sendEmailVerification(); // send email verification
    emit(
      AuthError("Email verification link has been sent to your email..."),
    ); // emit the error state with the message
  }

  void _currentUserState() {
    _authUser?.cancel();
    _authRepository.authInstance().listen(
      (user) {
        if (user != null) {
          emit(
            AuthSignedIn(
              UserModel(
                userId: user.uid,
                userName: user.displayName ?? "NA",
                isEmailVerified: user.emailVerified,
                userEmail: user.email ?? "NA",
                userProfile: user.photoURL,
              ),
            ),
          );
        } else {
          emit(AuthSignedOut());
        }
      },
      onError: (e) {
        emit(AuthError(e.toString()));
      },
    );
  }
}
