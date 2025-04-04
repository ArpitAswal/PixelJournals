import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pixel_journals/presentation/viewmodels/bloc/posts_bloc.dart';

import '../../../data/models/post_model.dart';
import '../../viewmodels/cubit/auth_cubit/cubit.dart';

class PostItem extends StatelessWidget {
  const PostItem(this.post, {super.key});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    final time = formatTimestamp(post.postTimeStamp);

    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24.0,
                  backgroundImage: context.read<AuthCubit>().authInst.currentUser!.photoURL != null
                      ? NetworkImage(
                      context.read<AuthCubit>().authInst.currentUser!.photoURL!)
                      : AssetImage("assets/images/pixel_journals.png"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.read<AuthCubit>().authInst.currentUser!.displayName!,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(time, style: Theme.of(context).textTheme.labelLarge,),
                          const SizedBox(width: 8),
                          Icon(Icons.timer_outlined)
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(onPressed: (){
                  context.read<PostsBloc>().add(DeletePost(post));
                }, icon: Icon(Icons.delete_outline_outlined))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0).copyWith(bottom: 6.0),
            child: Text(
              post.postDescription,
              maxLines: 2,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                overflow: TextOverflow.ellipsis
              ),
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.0,
              child: CachedNetworkImage(
                imageUrl: post.postUrl,
                imageBuilder: (context, imageProvider) =>
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: imageProvider,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.0))
                  ),
                ),
                placeholder: (context, url) =>
                    Center(child: SizedBox(
                        height: MediaQuery.of(context).size.width / 4,
                        width: MediaQuery.of(context).size.width / 4,
                        child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),
        ],
      ),
    );
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
        return '${difference.inMinutes}m${difference.inMinutes > 1
            ? 's'
            : ''}';
      } else {
        return '${difference.inSeconds}s${difference.inSeconds > 1
            ? 's'
            : ''}';
      }
    }

}
