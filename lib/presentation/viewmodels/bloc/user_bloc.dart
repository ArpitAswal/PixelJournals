import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

abstract class UserEvent {}

class LoadUsers extends UserEvent {}

class ToggleFollowUser extends UserEvent {
  ToggleFollowUser(this.targetUser);

  final UserModel targetUser;
}

class UserUpdated extends UserEvent {
  UserUpdated(this.followUsers, {required this.users});

  final List<UserModel> followUsers;
  final List<UserModel> users;
}

class ErrorEvent extends UserEvent {
  ErrorEvent(this.message);

  final String message;
}

abstract class UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  UserLoaded(this.followUsers, {required this.users});

  final List<UserModel> followUsers;
  final List<UserModel> users;
}

class UserError extends UserState {
  UserError(this.message);

  final String message;
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(UserLoading()) {
    // Initial state of the bloc
    on<LoadUsers>(_onLoadUsers); // Load users event
    on<ToggleFollowUser>(_onToggleFollowUser); // Toggle follow user event
    on<UserUpdated>(_onUserUpdated); // User updated event
    on<ErrorEvent>(_onErrorEvent); // Error event
  }

  StreamSubscription?
  _followingSubscription; // Subscription to the following users stream
  final UserRepository _userRepository;
  StreamSubscription?
  _usersSubscription; // Subscription to the all users stream

  @override
  Future<void> close() {
    // Close the bloc and cancel subscriptions
    _usersSubscription?.cancel();
    _followingSubscription?.cancel();
    return super.close();
  }

  void _onLoadUsers(LoadUsers event, Emitter<UserState> emit) {
    emit(UserLoading()); // Emit loading state when loading users
    try {
      // Cancel previous subscriptions if any
      _usersSubscription?.cancel();
      _followingSubscription?.cancel();

      _usersSubscription = _userRepository.getAllUsers().listen(
        (users) {
          // Listen to the all users stream
          _followingSubscription = _userRepository.getFollowingUsers().listen(
            (
              // Listen to the following users stream
              followingIds,
            ) {
              add(
                UserUpdated(users: users, followingIds),
              ); // Add user updated event with the list of users and following users
            },
            onError: (e) {
              add(
                ErrorEvent(e.toString()),
              ); // Emit error event if any error occurs, while listening following users
            },
          );
        },
        onError: (e) {
          add(
            ErrorEvent(e.toString()),
          ); // Emit error event if any error occurs, while listening all users
        },
      );
    } catch (e) {
      emit(UserError(e.toString())); // Emit error state if any error occurs
    }
  }

  void _onToggleFollowUser(
    ToggleFollowUser event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserLoaded) {
      // Check if the current state is UserLoaded
      final currentState = state as UserLoaded;
      try {
        final follow = await _userRepository.toggleFollow(
          event.targetUser,
        ); // Toggle follow status of the target user
        List<UserModel> updatedFollowUsers = List.from(
          // Create a new list of followed users
          currentState.followUsers,
        );

        if (follow) {
          // If the user is followed, by tapping on button
          updatedFollowUsers.add(event.targetUser);
          emit(UserLoaded(updatedFollowUsers, users: currentState.users));
        } else {
          // Remove user from following list
          updatedFollowUsers.removeWhere(
            (user) => user.userId == event.targetUser.userId,
          );
          emit(UserLoaded(updatedFollowUsers, users: currentState.users));
        }
      } catch (e) {
        // If an error occurs while toggling follow status
        emit(UserError(e.toString()));
      }
    }
  }

  FutureOr<void> _onUserUpdated(UserUpdated event, Emitter<UserState> emit) {
    emit(UserLoaded(event.followUsers, users: event.users));
  }

  FutureOr<void> _onErrorEvent(ErrorEvent event, Emitter<UserState> emit) {
    emit(UserError(event.message));
  }
}
