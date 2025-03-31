part of 'cubit.dart';

abstract class AuthState extends Equatable {
  // Equatable is a package that helps to compare objects based on their properties.
  const AuthState();

  @override
  List<Object> get props => []; // This method returns an empty list of objects, which means that by default, two instances of AuthState are considered equal if they have the same properties.
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSignedUp extends AuthState {
  // This class represents the state when a user has signed up successfully.
  const AuthSignedUp(this.user);

  final UserModel user;

  @override
  List<Object> get props => [user]; // This method returns a list containing the user object, which means that two instances of AuthSignedUp are considered equal if they have the same user object.
}

class AuthSignedIn extends AuthState {
  // This class represents the state when a user has signed in successfully.
  const AuthSignedIn(this.user);

  final UserModel user;

  @override
  List<Object> get props => [user]; // This method returns a list containing the user object, which means that two instances of AuthSignedIn are considered equal if they have the same user object.
}

class LoadingState extends AuthState {}

class AuthSignedOut extends AuthState {}

class AuthError extends AuthState {
  // This class represents the state when there is an error during authentication.
  const AuthError(this.message);

  final String message;

  @override
  List<Object> get props => [message]; // This method returns a list containing the message object, which means that two instances of AuthError are considered equal if they have the same message object.
}
