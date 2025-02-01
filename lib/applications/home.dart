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
              "Welcome",
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
              onPressed: () => context.router.push(const Chat06Route()),
              text: '06 Chat App',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '07 Music Player',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '09 Notes',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '10 Canvas',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '11 News',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '12 Location tracker',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '13 Fitness tracker',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '14 Language leaning',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '15 E commerce',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '16 Video Streaming',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '17 Travel App',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '18 Tic Tac Toe',
            ),
            HomeNavButton(
              onPressed: () {},
              text: '19 Data and graphs',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeNavButton extends StatelessWidget {
  const HomeNavButton({super.key, this.onPressed, required this.text});
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
            surfaceTintColor: Colors.amber,
            shadowColor: Colors.yellow,
            elevation: 10,
            child: Center(child: Text(text)),
          ),
        ),
      ),
    );
  }
}
