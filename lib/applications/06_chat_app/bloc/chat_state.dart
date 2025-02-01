// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc.dart';

class ChatState extends Equatable {
  const ChatState({
    required this.messages,
    required this.chatMessage,
    required this.metaData,
  });

  factory ChatState.initial() =>
      const ChatState(messages: [], chatMessage: '', metaData: (null, null));

  final List<String> messages;
  final String chatMessage;
  final (String?, String?) metaData;

  @override
  List<Object> get props => [messages, chatMessage, metaData];

  ChatState copyWith({
    List<String>? messages,
    String? chatMessage,
    (String?, String?)? metaData,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      chatMessage: chatMessage ?? this.chatMessage,
      metaData: metaData ?? this.metaData,
    );
  }
}
