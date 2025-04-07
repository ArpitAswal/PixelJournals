import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pixel_journals/presentation/viewmodels/bloc/posts_bloc.dart';

import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../viewmodels/cubit/auth_cubit/cubit.dart';
import '../../viewmodels/cubit/post_cubit/cubit.dart';
import '../screens/post_detail_screen.dart';
import 'cache_network_image.dart';

class PostItem extends StatefulWidget {
  const PostItem(this.post, {super.key});

  final PostModel post;

  @override
  State<PostItem> createState() => _PostItemState();
}

enum UserProfileState { initial, loaded, failed }

class _PostItemState extends State<PostItem> {
  late UserModel? _postUser; // hold the post user detail
  late ValueNotifier<UserProfileState>
  _profileState; // hold the state of user profile fetching

  @override
  void initState() {
    super.initState();
    _profileState = ValueNotifier(UserProfileState.initial);
    _fetchUser();
  }

  String formatTimestamp(Timestamp timestamp) {
    final nowTimestamp = Timestamp.now();

    // Convert Timestamps to DateTime for easier difference calculation
    final postDateTime = timestamp.toDate();
    final nowDateTime = nowTimestamp.toDate();

    final difference = nowDateTime.difference(postDateTime);

    if (difference.inSeconds < 0) {
      return 'Invalid timestamp (future time)';
    }

    if (difference.inDays >= 7) {
      return DateFormat('d-M-y').format(postDateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return '${difference.inSeconds}s${difference.inSeconds > 1 ? 's' : ''}';
    }
  }

  Future<void> _fetchUser() async {
    _postUser = await context.read<PostsBloc>().postUser(widget.post.userId);
    if (_postUser == null) {
      // if there is an error on fetching user detail
      _profileState.value = UserProfileState.failed;
    } else {
      // if successfully, user detail loaded
      _profileState.value = UserProfileState.loaded;
    }
  }

  Widget _buildImage(BuildContext context) {
    return Expanded(
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 5.0,
        child: CacheNetworkImage().buildNetworkImage(
          context,
          imgUrl: widget.post.postUrl,
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }

  _buildPostProfile(BuildContext context, UserModel user) {
    final time = formatTimestamp(
      widget.post.postTimeStamp,
    ); // Format the timestamp

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24.0,
          backgroundImage:
              user.userProfile != null ? NetworkImage(user.userProfile!) : null,
          child: Icon(
            Icons.person_rounded,
            size: MediaQuery.of(context).size.width * 0.1,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.userName,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(time, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(width: 5),
                  Icon(Icons.timer_outlined),
                ],
              ),
            ],
          ),
        ),
        if (widget.post.userId ==
            context
                .read<AuthCubit>()
                .authInst
                .currentUser!
                .uid) // if the current post is uploaded by auth user then the post delete option is available
          _deleteBtn(context),
      ],
    );
  }

  _errorPostProfile(BuildContext context, {required String msg}) {
    final time = formatTimestamp(
      widget.post.postTimeStamp,
    ); // Format the timestamp
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: null,
          tooltip: msg,
          padding: const EdgeInsets.all(0),
          iconSize: MediaQuery.of(context).size.width * 0.1,
          splashColor: Colors.transparent,
          icon: Icon(Icons.error_outline_outlined, color: Colors.red),
          enableFeedback: true,
          autofocus: true,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Not Identified",
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(time, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(width: 8),
                  Icon(Icons.timer_outlined),
                ],
              ),
            ],
          ),
        ),
        if (widget.post.userId ==
            context.read<AuthCubit>().authInst.currentUser!.uid)
          _deleteBtn(context),
      ],
    );
  }

  _deleteBtn(BuildContext context) {
    return IconButton(
      onPressed: () {
        PanaraConfirmDialog.show(
          context,
          title: "Delete Post",
          message: "Are you sure you want to delete this post?",
          panaraDialogType: PanaraDialogType.warning,
          confirmButtonText: 'YES',
          cancelButtonText: 'NO',
          onTapConfirm: () {
            context.read<PostsBloc>().add(DeletePost(widget.post));
            Navigator.of(context).pop(); // Close the dialog
          },
          onTapCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
      icon: Icon(Icons.delete_outline_rounded),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<PostDetailCubit>().checkLiked(
          widget.post.postId,
        ); // initial status of photo, whether it is liked by current auth user or not.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    PostDetailsOverlay(post: widget.post, user: _postUser!),
          ),
        );
      },
      child: Card(
        elevation: 8.0,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ValueListenableBuilder(
                valueListenable: _profileState,
                builder: (context, value, child) {
                  if (value == UserProfileState.failed) {
                    return _errorPostProfile(
                      context,
                      msg: "Failed to load user profile",
                    );
                  } else if (value == UserProfileState.loaded) {
                    return _buildPostProfile(context, _postUser!);
                  } else {
                    return Text("Profile User is loading");
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ).copyWith(bottom: 6.0),
              child: Text(
                widget.post.postDescription,
                maxLines: 2,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            _buildImage(context),
          ],
        ),
      ),
    );
  }
}
