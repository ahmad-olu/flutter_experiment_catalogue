// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'socket_io_bloc.dart';

class SocketIoState extends Equatable {
  const SocketIoState({required this.data});
  final List<String> data;

  factory SocketIoState.initial() => const SocketIoState(data: []);

  @override
  List<Object> get props => [data];

  SocketIoState copyWith({
    List<String>? data,
  }) {
    return SocketIoState(
      data: data ?? this.data,
    );
  }
}
