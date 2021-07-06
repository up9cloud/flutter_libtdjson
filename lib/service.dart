import 'dart:async' show Completer;
import 'dart:convert' show json;
import 'dart:math' show Random;
import 'dart:io' show Platform;
import 'dart:isolate';

import './client.dart' show Client, RawClient;
import './error.dart' show Error;

class Service {
  String? _dir;
  String? _file;
  late Client _client;
  Map _callbacks = <int, Completer>{};

  /// timeout (second) for td receive, for the event loop of `receive` stream
  late double timeout;

  /// The maximun random value (0 ~ max) for td function @extra
  late int maxExtra;

  /// Initial tdlibParameters for td function [setTdlibParameters](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1set_tdlib_parameters.html)
  late Map<String, dynamic> tdlibParameters;

  /// Initial new_verbosity_level for td function [setLogVerbosityLevel](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1set_log_verbosity_level.html)
  late int newVerbosityLevel;

  /// Initial encryption_key for td function [checkDatabaseEncryptionKey](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1check_database_encryption_key.html) or new_encryption_key for [setDatabaseEncryptionKey](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1set_database_encryption_key.html)
  late String encryptionKey;

  /// The event fired before sending object to td json client (via function send, sendSync)
  void Function(Map<String, dynamic>)? beforeSend;

  /// The event fired after receiving object from td json client (via receive stream loop, including td error object)
  void Function(Map<String, dynamic>)? afterReceive;

  /// The event fired before sending object to td json client (via function execute)
  void Function(Map<String, dynamic>)? beforeExecute;

  /// The event fired after receiving result object from td json client (via function execute)
  void Function(Map<String, dynamic>)? afterExecute;

  /// The event fired after receiving Error (parsed from td json error object, {"@type": "error", ...})
  void Function(Error)? onReceiveError;

  /// dart Stream(onError) for recevie stream loop
  void Function(dynamic)? onStreamError;

  Service(
      {
      // Parameters for native lib loader
      String? dir,
      String? file,
      // Parameters for handleing client
      this.timeout = 10,
      this.maxExtra = 10000000,

      /// start the recevie stream loop, default is true, set it to false if you want start it later
      start = true,
      // Parameters for td api
      required Map<String, dynamic> tdlibParameters,
      this.encryptionKey = "",
      this.newVerbosityLevel = 1,
      // Event handlers
      this.beforeSend,
      this.afterReceive,
      this.beforeExecute,
      this.afterExecute,
      this.onReceiveError,
      this.onStreamError}) {
    // Check those 5 required parameters before loading json client
    if (!tdlibParameters.containsKey('api_id')) {
      throw ArgumentError("tdlibParameters['api_id'] must be set");
    }
    if (!tdlibParameters.containsKey('api_hash')) {
      throw ArgumentError("tdlibParameters['api_hash'] must be set");
    }
    if (!tdlibParameters.containsKey('system_language_code')) {
      tdlibParameters['system_language_code'] = Platform.localeName;
    }
    if (!tdlibParameters.containsKey('application_version')) {
      tdlibParameters['application_version'] = "0.0.1";
    }
    if (!tdlibParameters.containsKey('device_model')) {
      throw ArgumentError("tdlibParameters['device_model'] must be set");
    }
    tdlibParameters['@type'] = 'tdlibParameters';
    this.tdlibParameters = tdlibParameters;
    if (maxExtra < 10000) {
      throw ArgumentError(
          "For preventing infinity generating extra issue, don't set maxExtra less than 10000");
    }
    _dir = dir;
    _file = file;
    _client = Client(dir: _dir, file: _file);
    if (start) {
      this.start();
    }
  }

  bool _running = false;
  bool get isRunning => _running;
  Isolate? _receiveIsolate;
  ReceivePort? _receivePort;

  static _receive(args) {
    final SendPort sendPortToMain = args[0];
    final String? dir = args[1];
    final String? file = args[2];
    final int clientId = args[3];
    final double timeout = args[4];
    RawClient _rawClient = RawClient(dir: dir, file: file);
    while (true) {
      String s = _rawClient.td_json_client_receive(clientId, timeout);
      sendPortToMain.send(s);
    }
  }

  Future<void> start() async {
    if (_running) {
      return;
    }
    if (_client.clientId == null) {
      _client.create();
      send({
        "@type": "setLogVerbosityLevel",
        "new_verbosity_level": newVerbosityLevel
      });
    }
    _running = true;
    _receivePort = ReceivePort();
    _receiveIsolate = await Isolate.spawn(_receive,
        [_receivePort!.sendPort, _dir, _file, _client.clientId, timeout],
        debugName: "isolated receive");
    _receivePort!.listen(_onIsolateReceive, onError: _onReceiveError);
  }

  Future<void> stop() async {
    if (!_running) {
      return;
    }
    _receivePort?.close();
    _receivePort = null;
    _receiveIsolate?.kill(priority: Isolate.immediate);
    _receiveIsolate = null;
    _running = false;
  }

  void _onIsolateReceive(dynamic data) {
    String s = data;
    if (s.isEmpty) {
      return;
    }
    Map<String, dynamic> j = json.decode(s);
    _onReceive(j);
  }

  void _onReceive(Map<String, dynamic> obj) {
    if (afterReceive != null) {
      afterReceive!(obj);
    }
    if (obj['@type'] == 'error') {
      _handleError(Error.fromJson(obj));
    } else {
      _handleObject(obj);
    }
  }

  _onReceiveError(dynamic e) {
    if (onStreamError != null) {
      onStreamError!(e);
    }
  }

  _handleObject(Map<String, dynamic> obj) async {
    if (obj['@type'] == "updates") {
      (obj['updates'] ?? []).map((update) => _handleEvent(update));
    } else {
      _handleEvent(obj);
    }
    if (obj.containsKey('@extra')) {
      final int extra = obj['@extra'];
      if (_callbacks.containsKey(extra)) {
        Completer fut = _callbacks.remove(extra);
        fut.complete(obj);
      }
    }
  }

  _handleError(Error e) {
    if (onReceiveError != null) {
      onReceiveError!(e);
    }
    if (e.extra != null) {
      final int extra = e.extra;
      if (_callbacks.containsKey(extra)) {
        Completer fut = _callbacks.remove(extra);
        fut.completeError(e);
      }
    }
  }

  _handleEvent(Map<String, dynamic> event) async {
    switch (event['@type']) {
      case 'updateAuthorizationState':
        await _handleAuth(event['authorization_state']);
        break;
    }
  }

  _handleAuth(Map<String, dynamic> event) async {
    switch (event['@type']) {
      case 'authorizationStateWaitTdlibParameters':
        send({'@type': 'setTdlibParameters', 'parameters': tdlibParameters});
        break;
      case 'authorizationStateWaitEncryptionKey':
        final bool isEncrypted = event['is_encrypted'] ?? false;
        if (isEncrypted) {
          send({
            '@type': 'checkDatabaseEncryptionKey',
            'encryption_key': encryptionKey
          });
        } else {
          send({
            '@type': 'setDatabaseEncryptionKey',
            'new_encryption_key': encryptionKey
          });
        }
        break;
      // TODO: block methods calling until closed.
      // case 'authorizationStateLoggingOut':
      // To prevent someone send {"@type": "logOut"} to destory native client
      case 'authorizationStateClosed':
        await stop();
        _client.create();
        break;
    }
  }

  int _generateExtra() {
    return Random().nextInt(maxExtra);
  }

  int _generateUniqueExtra() {
    int extra = _generateExtra();
    if (_callbacks.containsKey(extra)) {
      return _generateUniqueExtra();
    }
    return extra;
  }

  /// Asynchronously send td function
  Future send(Map<String, dynamic> obj) async {
    // it's not neccecery adding @extra for send, but helpful for debug
    int extra;
    if (obj.containsKey('@extra')) {
      extra = obj['@extra'];
    } else {
      extra = _generateUniqueExtra();
      obj['@extra'] = extra;
    }
    final completer = Completer<Map<String, dynamic>>();
    _callbacks[extra] = completer;
    if (beforeSend != null) {
      beforeSend!(obj);
    }
    _client.send(obj);
    return Future.value();
  }

  /// Synchronously send td function (wait until get the result)
  /// This is handled by this service (dart side), not native td execute api
  /// Because td client don't allow some functions executing synchronously
  Future<Map<String, dynamic>> sendSync(Map<String, dynamic> obj) {
    int extra;
    if (obj.containsKey('@extra')) {
      extra = obj['@extra'];
    } else {
      extra = _generateUniqueExtra();
      obj['@extra'] = extra;
    }
    final completer = Completer<Map<String, dynamic>>();
    _callbacks[extra] = completer;
    if (beforeSend != null) {
      beforeSend!(obj);
    }
    _client.send(obj);
    return completer.future;
  }

  /// Synchronously execute td function
  /// Handled by native td execute api
  Future<Map<String, dynamic>> execute(Map<String, dynamic> obj) async {
    if (beforeExecute != null) {
      beforeExecute!(obj);
    }
    Map<String, dynamic> r = _client.execute(obj);
    if (afterExecute != null) {
      afterExecute!(r);
    }
    if (r['@type'] == 'error') {
      Error e = Error.fromJson(r);
      _handleError(e);
      return Future.error(e);
    }
    return Future.value(r);
  }
}
