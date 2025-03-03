part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

final class ChatEventGetMessages extends ChatEvent {}

final class ChatEventSendInitialMessage extends ChatEvent {
  const ChatEventSendInitialMessage({
    required this.username,
    required this.threadId,
  });

  final String username;
  final String threadId;
}

final class ChatEventSendMessageStr extends ChatEvent {
  const ChatEventSendMessageStr({required this.message});

  final String message;
}

final class ChatEventSendMessage extends ChatEvent {}
