// lib/features/posts/presentation/bloc/chat_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/chat_model.dart';
import '../../../data/repositories/post_repository.dart';

//Events
abstract class ChatEvent {}

class LoadChatMessages extends ChatEvent {
  LoadChatMessages(this.postId);

  final String postId;
}

class SendMessage extends ChatEvent {
  SendMessage(this.postId, this.message);

  final String message;
  final String postId;
}

//States
abstract class ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  ChatLoaded(this.messages);

  final List<ChatModel> messages;
}

class ChatError extends ChatState {
  ChatError(this.message);

  final String message;
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._postRepository) : super(ChatLoading()) {
    on<LoadChatMessages>((event, emit) async {
      emit(ChatLoading());
      try {
        final messages =
            await _postRepository.getChatMessages(event.postId).first;
        emit(ChatLoaded(messages));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });

    on<SendMessage>((event, emit) async {
      await _postRepository.sendMessage(event.postId, event.message);
      // reload chat messages
      add(LoadChatMessages(event.postId));
    });
  }

  final PostsRepository _postRepository;
}
