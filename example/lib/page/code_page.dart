import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart' show GetIt;

import 'package:libtdjson/libtdjson.dart' show Error;

import '../service/mod.dart' show TelegramService;

class CodePage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<CodePage> {
  final int _codeLength = 5;
  final TextEditingController _codeController = TextEditingController();
  bool _showNextButton = false;
  String? _errorText;
  bool _loading = false;

  void _codeListener() {
    if (_codeController.text.length == _codeLength) {
      setState(() => _showNextButton = true);
    } else {
      setState(() => _showNextButton = false);
    }
  }

  @override
  void initState() {
    _codeController.addListener(_codeListener);
    super.initState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: TextField(
            maxLength: _codeLength,
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: BorderSide(),
              ),
              labelText: "Passcode",
              errorText: _errorText,
            ),
            onSubmitted: _next,
            autofocus: true,
          ),
        ),
      ),
      floatingActionButton: _showNextButton
          ? FloatingActionButton(
              onPressed: () => _next(_codeController.text),
              child: _loading
                  ? CircularProgressIndicator()
                  : Icon(Icons.navigate_next),
            )
          : null,
    );
  }

  void _next(String passcode) async {
    setState(() {
      _loading = true;
    });
    try {
      await GetIt.I<TelegramService>().checkAuthenticationCode(passcode);
    } on Error catch (e) {
      setState(() {
        _loading = false;
        _errorText = e.message;
      });
    }
  }
}
