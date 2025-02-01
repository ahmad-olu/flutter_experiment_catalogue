import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:experiment_catalogue/applications/06_chat_app/chat_req_type.dart';
import 'package:web_socket_client/web_socket_client.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatState.initial()) {
    _websocket = WebSocket(Uri.parse('ws://localhost:3000/ws'));

    on<ChatEventGetMessages>((event, emit) async {
      await emit.forEach(
        _websocket.messages,
        onData: (data) {
          final msg = data as String;
          return state.copyWith(messages: [...state.messages, msg]);
        },
      );
    });
    on<ChatEventSendInitialMessage>((event, emit) async {
      await Future.delayed(const Duration(milliseconds: 500), () {});
      final data = ChatReqType(
        typed: MessageType.init.name,
        username: event.username,
        thread: event.threadId,
      );
      emit(state.copyWith(metaData: (event.username, event.threadId)));
      if (_websocket.connection.state == const Connected()) {
        _websocket.send(data.toJson());
      }
    });
    on<ChatEventSendMessageStr>(
        (event, emit) => emit(state.copyWith(chatMessage: event.message)));
    on<ChatEventSendMessage>((event, emit) {
      if (_websocket.connection.state == const Connected()) {
        final data = ChatReqType(
          typed: MessageType.message.name,
          username: state.metaData.$1,
          thread: state.metaData.$2,
          message: state.chatMessage,
        );
        _websocket.send(data.toJson());
      }
    });
  }

  late final WebSocket _websocket;
}

//ChatEventSendMessageStr
