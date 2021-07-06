import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:global_configuration/global_configuration.dart';

import './service/mod.dart' show registerAll, NavigationService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("app");
  registerAll();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: GetIt.I<NavigationService>().navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      onGenerateRoute: NavigationService.onGenerateRoute,
    );
  }
}
