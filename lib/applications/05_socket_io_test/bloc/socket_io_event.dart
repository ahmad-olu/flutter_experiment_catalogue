part of 'socket_io_bloc.dart';

sealed class SocketIoEvent extends Equatable {
  const SocketIoEvent();

  @override
  List<Object> get props => [];
}

final class InitSocketEvent extends SocketIoEvent {}

final class ChatSocketEvent extends SocketIoEvent {
  const ChatSocketEvent({required this.val});

  final String val;
}
