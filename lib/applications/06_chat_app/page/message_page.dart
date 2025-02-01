import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/applications/06_chat_app/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class Messages06Page extends StatelessWidget {
  const Messages06Page({
    required this.username,
    required this.threadId,
    super.key,
  });
  final String username;
  final String threadId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc()
        ..add(ChatEventGetMessages())
        ..add(
          ChatEventSendInitialMessage(
            username: username,
            threadId: threadId,
          ),
        ),
      child: const Messages06View(),
    );
  }
}

class Messages06View extends StatelessWidget {
  const Messages06View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      return Text(msg);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              onChanged: (v) => context
                                  .read<ChatBloc>()
                                  .add(ChatEventSendMessageStr(message: v)),
                            ),
                          ),
                          ChatNormalButton(
                            onPressed: () {
                              context
                                  .read<ChatBloc>()
                                  .add(ChatEventSendMessage());
                            },
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ChatNormalButton extends StatelessWidget {
  const ChatNormalButton({
    super.key,
    this.onPressed,
    required this.child,
  });
  final void Function()? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(side: const BorderSide()),
      child: child,
    );
  }
}
