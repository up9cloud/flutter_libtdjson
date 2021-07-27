import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart' show GetIt;

import '../service/mod.dart' show TelegramService, NavigationService;

class HomePage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<HomePage> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    bool isRunning = GetIt.I<TelegramService>().isRunning;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text('Home page, route: ${ModalRoute.of(context)?.settings.name}'),
          const SizedBox(height: 10),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: isRunning ? Colors.red : Colors.cyanAccent,
              primary: Colors.black,
            ),
            onPressed: () async {
              setState(() {
                _loading = true;
              });
              if (isRunning) {
                await GetIt.I<TelegramService>().stop();
              } else {
                await GetIt.I<TelegramService>().start();
              }
              setState(() {
                _loading = false;
              });
            },
            label: Container(
                child: Text(isRunning ? 'Stop receiving' : 'Start receiving'),
                margin: EdgeInsets.only(right: 10)),
            icon: Container(
              child: _loading
                  ? CircularProgressIndicator(strokeWidth: 2.0)
                  : Icon(Icons.navigate_next, size: 15.0),
              margin: EdgeInsets.only(left: 10),
              height: 15.0,
              width: 15.0,
            ),
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
