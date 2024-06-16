import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:package_info_plus/package_info_plus.dart';

import '../service/mod.dart' show TelegramService, NavigationService;

class HomePage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<HomePage> {
  bool _loading = false;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Widget _infoTile(String title, String? subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle ?? 'N/A'),
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return TextButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.black,
    );
  }

  Widget _buttonLabel(String s) {
    return Container(child: Text(s), margin: EdgeInsets.only(right: 10));
  }

  Widget _buttonIcon() {
    return Container(
      child: _loading
          ? CircularProgressIndicator(strokeWidth: 2.0)
          : Icon(Icons.navigate_next, size: 15.0),
      margin: EdgeInsets.only(left: 10),
      height: 15.0,
      width: 15.0,
    );
  }

  Widget _button(
      {required Color color,
      Future<void> Function()? onPressed,
      required String label}) {
    return TextButton.icon(
      style: _buttonStyle(color),
      onPressed: () async {
        if (onPressed != null) {
          try {
            setState(() {
              _loading = true;
            });
            await onPressed();
          } finally {
            setState(() {
              _loading = false;
            });
          }
        }
      },
      label: _buttonLabel(label),
      icon: _buttonIcon(),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isRunning = GetIt.I<TelegramService>().isRunning;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Text('Home page, route: ${ModalRoute.of(context)?.settings.name}'),
          _infoTile('App name', _packageInfo.appName),
          _infoTile('Package name', _packageInfo.packageName),
          _infoTile('App version', _packageInfo.version),
          _infoTile('Build number', _packageInfo.buildNumber),
          _infoTile('Build signature', _packageInfo.buildSignature),
          _infoTile(
            'Installer store',
            _packageInfo.installerStore,
          ),
          const SizedBox(height: 10),
          isRunning
              ? _button(
                  color: Colors.red,
                  onPressed: () async {
                    await GetIt.I<TelegramService>().stop();
                  },
                  label: 'Stop receiving')
              : _button(
                  color: Colors.cyanAccent,
                  onPressed: () async {
                    await GetIt.I<TelegramService>().start();
                  },
                  label: 'Start receiving'),
          _button(
              color: Colors.cyanAccent,
              onPressed: GetIt.I<TelegramService>().setTdlibParameters,
              label: 'setTdlibParameters'),
          Column(
            children: [
              _button(
                  color: Colors.cyanAccent,
                  onPressed: () async {
                    GetIt.I<TelegramService>().setLogMessageCallback();
                  },
                  label:
                      'setLogMessageCallback with level: ${GetIt.I<TelegramService>().verbosity_level}'),
            ],
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            GetIt.I<NavigationService>().goTo(NavigationService.LOGIN),
        label: const Text('Login page'),
        icon: const Icon(Icons.navigate_next),
        backgroundColor: isRunning ? Colors.cyanAccent : Colors.grey,
      ),
    );
  }
}
