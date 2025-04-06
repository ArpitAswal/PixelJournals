import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/chat_model.dart';
import '../../../data/repositories/post_repository.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble(this.chatModel, {super.key});

  final ChatModel chatModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(15),
          topRight: const Radius.circular(15),
          bottomLeft:
              chatModel.userID ==
                      context.read<PostsRepository>().auth.currentUser!.uid
                  ? const Radius.circular(15)
                  : Radius.zero,
          bottomRight:
              chatModel.userID ==
                      context.read<PostsRepository>().auth.currentUser!.uid
                  ? Radius.zero
                  : const Radius.circular(15),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            chatModel.userID ==
                    context.read<PostsRepository>().auth.currentUser!.uid
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
        children: [
          Text(
            "By ${chatModel.username}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(chatModel.message, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
