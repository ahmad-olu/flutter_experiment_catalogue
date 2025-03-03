import 'package:experiment_catalogue/app/app.dart';
import 'package:experiment_catalogue/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

//pocketbase serve
//dart run build_runner build

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // HydratedBloc.storage = await HydratedStorage.build(
  //   storageDirectory: await getApplicationDocumentsDirectory(),

  //   // storageDirectory: kIsWeb
  //   //     ? HydratedStorageDirectory.web
  //   //     : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  // );
  await bootstrap(() => const App());
}
