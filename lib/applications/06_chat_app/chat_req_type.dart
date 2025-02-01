import 'dart:convert';
import 'package:equatable/equatable.dart';

enum MessageType {
  init('Init'),
  message('Message');

  const MessageType(this.name);
  final String name;
}

class ChatReqType extends Equatable {
  const ChatReqType({
    required this.typed,
    this.message,
    this.username,
    this.thread,
  });
  factory ChatReqType.fromMap(Map<String, dynamic> map) {
    return ChatReqType(
      typed: map['typed'] as String,
      username: map['username'] != null ? map['username'] as String : null,
      thread: map['thread'] != null ? map['thread'] as String : null,
      message: map['message'] != null ? map['message'] as String : null,
    );
  }

  final String typed;
  final String? username;
  final String? thread;
  final String? message;

  ChatReqType copyWith({
    String? typed,
    String? username,
    String? thread,
    String? message,
  }) {
    return ChatReqType(
      typed: typed ?? this.typed,
      username: username ?? this.username,
      thread: thread ?? this.thread,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'typed': typed,
      'username': username,
      'thread': thread,
      'message': message,
    };
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [typed, username, thread, message];

  String toJson() => json.encode(toMap());

  factory ChatReqType.fromJson(String source) =>
      ChatReqType.fromMap(json.decode(source) as Map<String, dynamic>);
}
