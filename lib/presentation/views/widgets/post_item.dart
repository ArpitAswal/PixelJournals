import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pixel_journals/presentation/viewmodels/bloc/posts_bloc.dart';

import '../../../core/constants.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../viewmodels/cubit/auth_cubit/cubit.dart';

class PostItem extends StatelessWidget {
  const PostItem(this.post, {super.key});

  final PostModel post;

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

  Stream<UserModel?> _getUserStream(BuildContext context) {
    return FirebaseFirestore.instance
        .collection(FirebaseConstants.usersCollection)
        .doc(post.userId)
        .snapshots()
        .map((doc) {
          try {
            if (!doc.exists) {
              // Check if the document exists
              return null;
            }
            return UserModel.fromDocument(
              doc,
            ); // Parse the user data from the document
          } catch (e) {
            return null;
          }
        });
  }

  Widget _buildImage(BuildContext context) {
    return Expanded(
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 5.0,
        child: CachedNetworkImage(
          imageUrl: post.postUrl,
          imageBuilder: _buildImageContainer,
          placeholder: _buildLoadingPlaceholder,
          errorWidget: (_, __, ___) => const Center(child: Icon(Icons.error)),
        ),
      ),
    );
  }

  Widget _buildImageContainer(
    BuildContext context,
    ImageProvider imageProvider,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12.0),
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context, String url) {
    final size = MediaQuery.of(context).size.width / 4;
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  _buildPostProfile(BuildContext context) {
    final time = formatTimestamp(post.postTimeStamp); // Format the timestamp

    return StreamBuilder<UserModel?>(
      stream: _getUserStream(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            radius: 24.0,
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return _errorPostProfile(context, msg: snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data == null) {
          return _errorPostProfile(context, msg: "User not found");
        } else {
          final user = snapshot.data!;
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24.0,
                backgroundImage:
                    user.userProfile != null
                        ? NetworkImage(user.userProfile!)
                        : null,
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
                        Text(
                          time,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.timer_outlined),
                      ],
                    ),
                  ],
                ),
              ),
              if (post.userId ==
                  context.read<AuthCubit>().authInst.currentUser!.uid)
                _deleteBtn(context),
            ],
          );
        }
      },
    );
  }

  _errorPostProfile(BuildContext context, {required String msg}) {
    final time = formatTimestamp(post.postTimeStamp); // Format the timestamp
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
        if (post.userId == context.read<AuthCubit>().authInst.currentUser!.uid)
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
            context.read<PostsBloc>().add(DeletePost(post));
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
        Navigator.of(context).pushNamed('/postDetailsScreen', arguments: post);
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
              child: _buildPostProfile(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
              ).copyWith(bottom: 6.0),
              child: Text(
                post.postDescription,
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
