import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/app/router.gr.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeView();
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            HomeNavButton(
              onPressed: () => context.router.push(const Todo01Route()),
              text: '01 Todo Page',
            ),
            HomeNavButton(
              onPressed: () => context.router.push(const Weather02Route()),
              text: '02 Weather',
            ),
            HomeNavButton(
              onPressed: () => context.router.push(const BmiCalc03Route()),
              text: '03 Bmi Calc',
            ),
            HomeNavButton(
              onPressed: () => context.router.push(const Quiz04Route()),
              text: '04 Quiz',
            ),
            HomeNavButton(
              onPressed: () => context.router.push(const SocketTest05Route()),
              text: '05 Socket Io Test',
            ),
            HomeNavButton(
              onPressed: () => context.router.push(const Chat06Route()),
              text: '06 Chat App',
            ),
            const HomeNavButton(
              text: '07 Music Player',
            ),
            const HomeNavButton(
              text: '09 Notes',
            ),
            const HomeNavButton(
              text: '10 Canvas',
            ),
            const HomeNavButton(
              text: '11 News',
            ),
            const HomeNavButton(
              text: '12 Location tracker',
            ),
            const HomeNavButton(
              text: '13 Fitness tracker',
            ),
            const HomeNavButton(
              text: '14 Language leaning',
            ),
            const HomeNavButton(
              text: '15 E commerce',
            ),
            const HomeNavButton(
              text: '16 Video Streaming',
            ),
            const HomeNavButton(
              text: '17 Travel App',
            ),
            const HomeNavButton(
              text: '18 Tic Tac Toe',
            ),
            const HomeNavButton(
              text: '19 Data and graphs',
            ),
            const HomeNavButton(
              text: '20 Webrtc',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeNavButton extends StatelessWidget {
  const HomeNavButton({required this.text, super.key, this.onPressed});
  final void Function()? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          height: 100,
          child: Card(
            surfaceTintColor:onPressed != null?  Colors.amber:Colors.blueGrey,
            shadowColor:onPressed != null? Colors.yellow: Colors.black,
            elevation: 10,
            child: Center(child: Text(text)),
          ),
        ),
      ),
    );
  }
}
