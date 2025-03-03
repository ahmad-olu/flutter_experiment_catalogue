import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/applications/05_socket_io_test/bloc/socket_io_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SocketTest05Page extends StatelessWidget {
  const SocketTest05Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SocketIoBloc()..add(InitSocketEvent()),
      child: const SocketTest05View(),
    );
  }
}

class SocketTest05View extends StatelessWidget {
  const SocketTest05View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocketIoBloc, SocketIoState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: Column(
            children: [
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: state.data.length,
                  itemBuilder: (context, index) {
                    final msg = state.data[index];
                    return Text(msg);
                  },
                ),
              ),
              TextField(
                onChanged: (value) => context.read<SocketIoBloc>()
                  ..add(ChatSocketEvent(val: value)),
              ),
            ],
          ),
        );
      },
    );
  }
}
