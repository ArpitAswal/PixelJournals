import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/post_repository.dart';
import '../../../views/screens/chat_screen.dart';

import 'state.dart';

// Cubit for managing post like/share states
class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit({required PostsRepository repository})
    : _repository = repository, // initializing the repository
      super(PostDetailState());

  final PostsRepository _repository;

  // Check if already liked
  Future<void> checkLiked(String postId) async {
    bool like = await _repository.isPostLiked(postId);
    emit(state.copyWith(isLiked: like));
  }

  // Dummy share function to navigate to ChatScreen with selected users
  void sharePost(BuildContext context, String imageUrl) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen()));
  }

  void toggleExpand(bool expand) {
    // toggle the expandm whether to displaying the full text or not.
    emit(state.copyWith(isExpand: !expand));
  }

  void toggleLiked(String postId) async {
    await _repository.postLiked(
      !state.isLiked,
      postId,
    ); // if before post is not liked, then it will like at this time & will be save on Firestore Firebase.
    emit(state.copyWith(isLiked: !state.isLiked));
  }
}
