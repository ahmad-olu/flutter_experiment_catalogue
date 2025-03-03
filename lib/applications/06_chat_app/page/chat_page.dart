import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/app/router.gr.dart';
import 'package:flutter/material.dart';

@RoutePage()
class Chat06Page extends StatelessWidget {
  const Chat06Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const Chat06View();
  }
}

class Chat06View extends StatefulWidget {
  const Chat06View({super.key});

  @override
  State<Chat06View> createState() => _Chat06ViewState();
}

class _Chat06ViewState extends State<Chat06View> {
  final usr = TextEditingController(text: 'Felix');
  final trd = TextEditingController(text: 'EEM435');
  @override
  void dispose() {
    usr.dispose();
    trd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHat auth'),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: usr,
              decoration:
                  const InputDecoration(helperText: 'Username ..e.g moris'),
            ),
            TextField(
              controller: trd,
              decoration:
                  const InputDecoration(helperText: 'thread Id.. e.g eer1234'),
            ),
            ElevatedButton(
              onPressed: () {
                if (usr.text.length < 3 && trd.text.length < 4) {
                  return;
                }
                //FIXME:
                //context.router.navigateNamedTo('/chat/messages');

                AutoRouter.of(context).push(
                  Messages06Route(
                    username: usr.text,
                    threadId: trd.text,
                  ),
                );
              },
              child: const Text('Proceed'),
            ),
          ],
        ),
      ),
    );
  }
}
