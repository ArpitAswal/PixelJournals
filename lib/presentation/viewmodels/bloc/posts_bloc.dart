import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';

// Post Events
abstract class PostsEvent {}

class LoadPosts
    extends
        PostsEvent {} // Load posts event emit when the app is opened or while the user is logged in

class Logout extends PostsEvent {}

class QueryPosts extends PostsEvent {
  // Query posts event emit when the user searches for a post by writing the post description
  QueryPosts(this.query);

  final String query;
}

class _UpdatePosts extends PostsEvent {
  // This event is used to update the posts list when the user searches for a post by writing the post description or when the all posts are loaded
  _UpdatePosts(this.posts);

  final List<PostModel> posts;
}

class _ErrorPosts extends PostsEvent {
  // This event is used to handle errors while loading the posts
  _ErrorPosts(this.message);

  final String message;
}

class DeletePost extends PostsEvent {
  // This event is used to delete a post from the posts list
  DeletePost(this.post);

  final PostModel post;
}

// Posts States
abstract class PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  // This state is used to show the posts list when the user is logged in and the posts are loaded successfully
  PostsLoaded(this.posts);

  final List<PostModel> posts;
}

class PostsError extends PostsState {
  // This state is used to show the error message when the posts are not loaded successfully
  PostsError(this.message);

  final String message;
}

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  // This class is used to manage the posts list and handle the events and states of the posts
  PostsBloc(this._postRepository) : super(PostsLoading()) {
    on<LoadPosts>((event, emit) {
      emit(
        PostsLoading(),
      ); // Show loading state when the posts are being loaded
      try {
        _postsSubscription?.cancel(); // Cancel any existing subscription

        _postsSubscription = _postRepository.getPosts().listen(
          // Listen to the posts stream and update the posts list when the posts are loaded successfully or handle the error when the posts are not loaded successfully
          (posts) => add(_UpdatePosts(posts)),
          onError: (error) => add(_ErrorPosts(error)),
        );
      } catch (e) {
        emit(
          PostsError(e.toString()),
        ); // Show error message when the posts are not loaded successfully
      }
    });

    on<_UpdatePosts>((event, emit) {
      // This event is used to update the posts list when the user searches for a post by writing the post description or when the all posts are loaded
      emit(PostsLoaded(event.posts));
    });

    on<_ErrorPosts>((event, emit) {
      // This event is used to handle errors while loading the posts
      emit(PostsError(event.message));
    });

    on<QueryPosts>((event, emit) {
      // This event is used to search for a post by writing the post description
      try {
        emit(PostsLoading());
        _postsSubscription?.cancel();
        _postsSubscription = _postRepository
            .queryPosts(event.query)
            .listen(
              // Listen to the posts stream and update the posts list when the user searches for a post by writing the post description or handle the error when the posts are not loaded successfully
              (posts) => add(_UpdatePosts(posts)),
              onError: (error) => add(_ErrorPosts(error)),
            );
      } catch (e) {
        emit(PostsError(e.toString()));
      }
    });

    on<DeletePost>((event, emit) {
      // This event is used to delete a post from the posts list
      _postRepository.deletePost(event.post.postId);
    });

    on<Logout>((event, emit) async {
      // This event is used to logout the user from the app
      await _postRepository.logout();
      _postsSubscription?.cancel();
    });
  }

  final PostsRepository _postRepository;
  StreamSubscription<List<PostModel>>? _postsSubscription;

  @override
  Future<void> close() {
    // This method is used to close the posts subscription when the app is closed
    _postsSubscription?.cancel();
    return super.close();
  }
}
