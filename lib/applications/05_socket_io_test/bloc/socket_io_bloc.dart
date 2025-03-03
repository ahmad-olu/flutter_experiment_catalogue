import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

part 'socket_io_event.dart';
part 'socket_io_state.dart';

class SocketIoBloc extends Bloc<SocketIoEvent, SocketIoState> {
  SocketIoBloc() : super(SocketIoState.initial()) {
    on<InitSocketEvent>((event, emit) async {
      log('Got here');
      //! Normal
      // final socket = io.io(
      //   'http://localhost:3000/custom',
      //   io.OptionBuilder()
      //       .setTransports(['websocket']) // Ensure WebSocket is used
      //       .setExtraHeaders(
      //           {'Content-Type': 'application/json'}) // Optional headers
      //       .build(),
      // );
      // //final socket = io.io('http://localhost:3000/custom');
      // socket
      //   ..onConnect((_) {
      //     log('connect');
      //     socket.emit('msg', 'test');
      //   })
      //   ..on('event', (data) => log(data.toString()))
      //   ..onDisconnect((_) => log('disconnect'))
      //   ..on('fromServer', (a) => log(a.toString()));

      //! With for each
      socket = io.io(
        'http://localhost:3000/custom', // ✔️
        //'http://localhost:3000',// ✔️
        //'http://localhost:3000/a',//❌
        io.OptionBuilder()
            .setTransports(['websocket']) // Ensure WebSocket is used
            .build(),
      );
      socket
        ..onConnect((_) {
          log('Connected to server');
          socket
            ..emit('join-room', 'Room1')
            ..emit('message', '{"foo":"baz"}');
        })
        ..on('message-back', (data) {
          log('Received message: $data');
          _messageController.add(data);
        })
        ..on('return-message', (data) {
          log('return-message: $data');
          _messageController.add(data);
        })
        //..emit('join-room', 'Room1')
       // ..emit('chat', 'test')
        ..onDisconnect((_) {
          log('Disconnected from server');
        });
      await emit.forEach(
        _messageController.stream,
        onData: (message) {
          log('=======> $message');
          return state.copyWith(data: [...state.data, message.toString()]);
        },
      );
    });

    on<ChatSocketEvent>(
      (event, emit) {
        if (socket.connected) {
          socket.emit('chat', event.val);
        } else {
          log('Socket not connected');
        }
      },
      transformer:
          delayTransformer(const Duration(milliseconds: 500)), // Add delay
    );
  }

  EventTransformer<E> delayTransformer<E>(Duration duration) {
    return (events, mapper) {
      return events.debounceTime(duration).switchMap(mapper);
    };
  }

  late io.Socket socket;
  final _messageController = StreamController<dynamic>();
}
