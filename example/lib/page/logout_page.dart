import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:libtdjson/libtdjson.dart' show Error;

import '../service/mod.dart' show TelegramService;

class LogoutPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<LogoutPage> {
  String? _errorText;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('End page, route: ${ModalRoute.of(context)?.settings.name}'),
            Text(_errorText ?? ""),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _next(),
        label: const Text('Logout'),
        icon:
            _loading ? CircularProgressIndicator() : Icon(Icons.navigate_next),
      ),
    );
  }

  void _next() async {
    setState(() {
      _loading = true;
    });
    try {
      await GetIt.I<TelegramService>().logOut();
    } on Error catch (e) {
      setState(() {
        _loading = false;
        _errorText = e.message;
      });
    }
  }
}
