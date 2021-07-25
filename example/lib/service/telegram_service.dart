import 'dart:async';
import 'dart:io' show Directory, Platform;

import 'package:flutter/material.dart' show ChangeNotifier, Navigator;
import 'package:global_configuration/global_configuration.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, getTemporaryDirectory;

import 'package:libtdjson/libtdjson.dart' show Service;

import './mod.dart' show NavigationService, LogService;

class TelegramService extends ChangeNotifier {
  Service? _service;
  Function(dynamic s) _log = LogService.build('TelegramService');

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
      // newVerbosityLevel: 3,
      tdlibParameters: {
        // 'use_test_dc': true,
        'api_id': GlobalConfiguration().getValue<int>("telegram_api_id"),
        'api_hash': GlobalConfiguration().getValue<String>("telegram_api_hash"),
        'device_model': 'Unknown',
        'database_directory': appDir.path,
        'files_directory': tempDir.path,
        'enable_storage_optimizer': true,
      },
      beforeSend: _logWapper('beforeSend'),
      afterReceive: _afterReceive,
      beforeExecute: _logWapper('beforeExecute'),
      afterExecute: _logWapper('afterExecute'),
      onReceiveError: _logWapper('onReceiveError', (e) {
        // debugger(when: true);
      }),
    );
  }

  bool get isRunning => _service == null ? false : _service!.isRunning;
  start() async {
    if (!_service!.isRunning) {
      await _service?.start();
    }
  }

  stop() async {
    if (_service!.isRunning) {
      await _service?.stop();
    }
  }

  Function(dynamic) _logWapper(String key, [void Function(dynamic obj)? fn]) {
    return LogService.build('TelegramService:$key', fn);
  }

  _afterReceive(Map<String, dynamic> event) {
    switch (event['@type']) {
      case 'updateAuthorizationState':
        _logWapper("_afterReceive")(event);
        _handleAuth(event['authorization_state']);
        break;
    }
  }

  _handleAuth(Map<String, dynamic> state) {
    String route;
    switch (state['@type']) {
      case 'authorizationStateWaitTdlibParameters':
      case 'authorizationStateWaitEncryptionKey':
      case 'authorizationStateClosed':
        route = Navigator.defaultRouteName;
        break;
      case 'authorizationStateWaitPhoneNumber':
        route = NavigationService.LOGIN;
        break;
      case 'authorizationStateWaitCode':
        route = NavigationService.CODE;
        break;
      case 'authorizationStateReady':
        route = NavigationService.END;
        break;
      case 'authorizationStateWaitPassword':
      case 'authorizationStateWaitOtherDeviceConfirmation':
      case 'authorizationStateWaitRegistration':
      case 'authorizationStateLoggingOut':
      case 'authorizationStateClosing':
        return;
      default:
        return;
    }
    GetIt.I<NavigationService>().goTo(route);
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
