import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:libtdjson/libtdjson.dart' show Error;

import '../service/mod.dart' show TelegramService;

class LoginPage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<LoginPage> {
  final _phoneNumberController = TextEditingController(text: '+');
  bool _showNextButton = false;
  String? _errorText;
  bool _loading = false;

  void _phoneNumberListener() {
    if (_phoneNumberController.text.length < 2) {
      if (_showNextButton) {
        setState(() => _showNextButton = false);
      }
    } else {
      if (!_showNextButton) {
        setState(() => _showNextButton = true);
      }
    }
  }

  @override
  void initState() {
    _phoneNumberController.addListener(_phoneNumberListener);
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: TextField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: "Phone number",
              errorText: _errorText,
            ),
            onSubmitted: _next,
          ),
        ),
      ),
      floatingActionButton: _showNextButton
          ? FloatingActionButton(
              onPressed: () => _next(_phoneNumberController.text),
              child: _loading
                  ? CircularProgressIndicator()
                  : Icon(Icons.navigate_next),
            )
          : null,
    );
  }

  void _next(String value) async {
    setState(() {
      _loading = true;
    });
    try {
      await GetIt.I<TelegramService>().setAuthenticationPhoneNumber(value);
    } on Error catch (e) {
      setState(() {
        _loading = false;
        _errorText = e.message;
      });
    }
  }
}
