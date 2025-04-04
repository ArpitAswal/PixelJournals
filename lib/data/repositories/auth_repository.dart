import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../presentation/viewmodels/cubit/auth_cubit/cubit.dart';
import '../models/user_model.dart';
import '../../core/constants.dart';

class AuthRepository {
  AuthRepository()
    : _auth = FirebaseAuth.instance, // FirebaseAuth instance
      _firestore = FirebaseFirestore.instance; // FirebaseFirestore instance

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authInstance() {
    return _auth.authStateChanges();
  }


  Future<AuthState> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        // Create user with email and password
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(username); // Update display name
      await credential.user?.sendEmailVerification(); // Send email verification

      final user = UserModel(
        userId: credential.user!.uid,
        userEmail: credential.user!.email!,
        userName: username,
      );
      saveUserInfo(user, password);
      return AuthSignedUp(user); // Return signed up state
    } on FirebaseAuthException catch (e) {
      return AuthError(
        _mapFirebaseError(e.code),
      ); // Handle FirebaseAuthException
    } catch (e) {
      return AuthError(
        'An unexpected error occurred: ${e.toString()}',
      ); // Handle other exceptions
    }
  }

  Future<AuthState> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        // Sign in with email and password
        email: email,
        password: password,
      );

      final user = UserModel(
        userId: credential.user!.uid,
        userEmail: credential.user!.email!,
        userName: credential.user!.displayName ?? 'NA',
        isEmailVerified: credential.user!.emailVerified,
      );
      saveUserInfo(user);
      return AuthSignedIn(user); // Return signed in state
    } on FirebaseAuthException catch (e) {
      return AuthError(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthError('An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<AuthState> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
      ); // Send password reset email
      return AuthInitial(); // Return initial state
    } on FirebaseAuthException catch (e) {
      return AuthError(_mapFirebaseError(e.code));
    } catch (e) {
      return AuthError('An unexpected error occurred: ${e.toString()}');
    }
  }

  void saveUserInfo(UserModel user, [String? pass]) {
    // Save user info to Firestore
    Map<String, dynamic> userData = {
      'userId': user.userId,
      'userEmail': user.userEmail,
      'userName': user.userName,
      'isEmailVerified': user.isEmailVerified,
      'token': user.deviceToken,
    };

    if (pass != null) {
      userData['userPassword'] = pass; // Save password if provided
    }
    _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.userId)
        .set(userData);
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Please enter a stronger password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Invalid password';
      case 'invalid-credential':
        return 'Invalid credential, Check again';
      default:
        return 'An error occurred. Please try again';
    }
  }

}
