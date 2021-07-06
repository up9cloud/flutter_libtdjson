import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart' show GetIt;

import '../service/mod.dart' show TelegramService, NavigationService;

class HomePage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    bool isRunning = GetIt.I<TelegramService>().isRunning;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text('Home page, route: ${ModalRoute.of(context)?.settings.name}'),
          const SizedBox(height: 10),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: isRunning ? Colors.red : Colors.cyanAccent,
              primary: Colors.black,
            ),
            onPressed: () async {
              if (isRunning) {
                await GetIt.I<TelegramService>().stop();
              } else {
                await GetIt.I<TelegramService>().start();
              }
              setState(() {});
            },
            child: Text(isRunning ? 'Stop receiving' : 'Start receiving'),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            GetIt.I<NavigationService>().goTo(NavigationService.LOGIN),
        label: const Text('Login page'),
        icon: const Icon(Icons.navigate_next),
      ),
    );
  }
}
