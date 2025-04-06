import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_journals/data/repositories/post_repository.dart';

import '../../viewmodels/bloc/chat_bloc.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const String routeName = "/chat_screen";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _msgCtrl;

  @override
  dispose() {
    // Dispose of any resources or listeners here
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize any necessary data or state here
    _msgCtrl = TextEditingController();
  }

  void _handleListener(BuildContext context, ChatState state) {
    if (state is ChatLoading) {
      // Clear the message input field after sending a message
      _msgCtrl.text = "";
    } else if (state is ChatError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final String postID = ModalRoute.of(context)!.settings.arguments as String;
    return BlocProvider(
      create:
          (context) =>
              ChatBloc(PostsRepository())
                ..add(LoadChatMessages(postID)), // Load chat messages
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: BlocConsumer<ChatBloc, ChatState>(
            listener: _handleListener,
            builder: (context, state) {
              if (state is ChatLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ChatLoaded) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment:
                                    state.messages[index].userID ==
                                            context
                                                .read<PostsRepository>()
                                                .auth
                                                .currentUser!
                                                .uid
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                child: ChatBubble(state.messages[index]),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Enter Message",
                                ),
                                onChanged: (value) {
                                  _msgCtrl.text = value.trim();
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (_msgCtrl.text.isNotEmpty) {
                                  context.read<ChatBloc>().add(
                                    SendMessage(postID, _msgCtrl.text),
                                  );
                                }
                              },
                              icon: const Icon(Icons.arrow_forward_ios),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is ChatError) {
                return Center(child: Text(state.message));
              } else {
                return const Center(child: Text("Unexpected State"));
              }
            },
          ),
        ),
      ),
    );
  }
}
