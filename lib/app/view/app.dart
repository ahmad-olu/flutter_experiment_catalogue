import 'package:experiment_catalogue/app/router.dart';
import 'package:experiment_catalogue/app/view/example/example_editor.dart';
import 'package:experiment_catalogue/app/view/first+try/main.dart';
import 'package:experiment_catalogue/app/view/permission_table.dart';
import 'package:experiment_catalogue/l10n/l10n.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final _appRouter = AppRouter();
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _appRouter.config(),
    );

    //!
    // return MaterialApp(
    //   theme: ThemeData(
    //     appBarTheme: const AppBarTheme(
    //       backgroundColor: Colors.brown,
    //     ),
    //     scaffoldBackgroundColor: Colors.grey.shade400,
    //     // brightness: Brightness.dark,
    //     useMaterial3: true,
    //   ),
    //   //themeMode: ThemeMode.light,
    //   localizationsDelegates: AppLocalizations.localizationsDelegates,
    //   supportedLocales: AppLocalizations.supportedLocales,
    //   home: const FirstTryEditor(),
    //   //home: PermissionTable(),
    // );
  }
}
