import 'dart:async';
import 'dart:ffi';
import 'dart:io' show Directory, Platform;

import 'package:ffi/ffi.dart';

import 'package:flutter/material.dart' show ChangeNotifier, Navigator;
import 'package:global_configuration/global_configuration.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, getTemporaryDirectory;

import 'package:libtdjson/typedef.dart' as def;
import 'package:libtdjson/libtdjson.dart' show Service;

import './mod.dart' show NavigationService, LogService;

class TelegramService extends ChangeNotifier {
  Service? _service;
  Function(dynamic s) _log = LogService.build('TelegramService');
  Function(dynamic) _logWrapper(String key, [void Function(dynamic obj)? fn]) {
    return LogService.build('TelegramService:$key', fn);
  }

  TelegramService() {
    _init();
  }

  _init() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    Directory tempDir = await getTemporaryDirectory();
    if (Platform.isAndroid || Platform.isIOS) {
      PermissionStatus perm = await Permission.storage.request();
      if (!perm.isGranted) {
        _log('Permission.storage.request(): $perm');
      }
    }
    _service = Service(
      start: false,
      newVerbosityLevel: 3,
      tdlibParameters: {
        // 'use_test_dc': true,
        'api_id': GlobalConfiguration().getValue<int>("telegram_api_id"),
        'api_hash': GlobalConfiguration().getValue<String>("telegram_api_hash"),
        'device_model': 'Unknown',
        'database_directory': appDir.path,
        'files_directory': tempDir.path,
        'enable_storage_optimizer': true,
      },
      beforeSend: _logWrapper('beforeSend'),
      afterReceive: _afterReceive,
      beforeExecute: _logWrapper('beforeExecute'),
      afterExecute: _logWrapper('afterExecute'),
      onReceiveError: _logWrapper('onReceiveError', (e) {
        // debugger(when: true);
      }),
    );
  }

  bool get isRunning => _service == null ? false : _service!.isRunning;
  start() async {
    if (!isRunning) {
      await _service?.start();
    }
  }

  stop() async {
    if (isRunning) {
      await _service?.stop();
    }
  }

  static void _logMessageCallback(int verbosity_level, Pointer<Utf8> message) {
    print(
        'TelegramService:setLogMessageCallback: verbosity_level:$verbosity_level, message:${message.toDartString()}');
  }

  int verbosity_level = 6;

  void setLogMessageCallback() {
    _logWrapper("verbosity_level")(verbosity_level);
    NativeCallable<def.td_log_message_callback> cb =
        NativeCallable.listener(_logMessageCallback);
    _service?.setLogMessageCallback(verbosity_level, cb);
    verbosity_level++;
    if (verbosity_level > 6) {
      verbosity_level = 0;
    }
  }

  _afterReceive(Map<String, dynamic> event) {
    switch (event['@type']) {
      case 'updateAuthorizationState':
        _logWrapper("_afterReceive")(event);
        _handleAuth(event['authorization_state']);
        break;
    }
  }

  // https://github.com/tdlib/td/blob/master/td/generate/scheme/td_api.tl#L77
  _handleAuth(Map<String, dynamic> state) {
    String route;
    switch (state['@type']) {
      case 'authorizationStateWaitTdlibParameters': // handled by service
        return;
      case 'authorizationStateWaitPhoneNumber':
        route = NavigationService.LOGIN;
        break;
      case 'authorizationStateWaitEmailAddress': // TODO:
        return;
      case 'authorizationStateWaitEmailCode': // TODO:
        return;
      case 'authorizationStateWaitCode':
        route = NavigationService.CODE;
        break;
      case 'authorizationStateWaitOtherDeviceConfirmation': // skip
        return;
      case 'authorizationStateWaitRegistration': // skip
        return;
      case 'authorizationStateWaitPassword': // TODO:
        return;
      case 'authorizationStateReady':
        route = NavigationService.END;
        break;
      case 'authorizationStateLoggingOut':
      case 'authorizationStateClosing':
        return;
      case 'authorizationStateClosed':
        route = Navigator.defaultRouteName;
        break;
      default:
        return;
    }
    GetIt.I<NavigationService>().goTo(route);
  }

  Future setTdlibParameters() async {
    await _service?.send({
      '@type': 'setTdlibParameters',
      ..._service!.tdlibParameters,
    });
  }

  Future setAuthenticationPhoneNumber(String phoneNumber) async {
    await _service?.sendSync({
      '@type': 'setAuthenticationPhoneNumber',
      'phone_number': phoneNumber,
      'settings': {
        'allow_flash_call': false,
        'is_current_phone_number': false,
        'allow_sms_retriever_api': false,
      }
    });
  }

  Future checkAuthenticationCode(String code) async {
    await _service
        ?.sendSync({'@type': 'checkAuthenticationCode', 'code': code});
  }

  Future checkAuthenticationPassword(String password) async {
    await _service?.sendSync(
        {'@type': 'checkAuthenticationPassword', 'password': password});
  }

  Future logOut() async {
    await _service?.sendSync({'@type': 'logOut'});
  }
}
