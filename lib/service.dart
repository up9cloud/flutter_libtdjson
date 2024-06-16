import 'dart:async' show Completer;
import 'dart:convert' show json;
import 'dart:math' show Random;
import 'dart:io' show Platform;
import 'dart:isolate';
import 'dart:ffi';

import './client.dart' show Client, RawClient;
import './error.dart' show Error;
import './typedef.dart' as def;

/// The raw client only handles the stream loop for td receive function
class RawService {
  final String? dir;
  final String? file;
  late Client _client;

  /// Timeout (second) for event loop of `receive` stream. (td receive), it only works when calling the start fn
  late double timeout;

  /// Initial new_verbosity_level for td function [setLogVerbosityLevel](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1set_log_verbosity_level.html)
  int? newVerbosityLevel;

  /// dart Stream(onError) for receive stream loop
  void Function(dynamic)? onStreamError;

  /// The event fired after service handling receiving `raw` string result from td json client (via receive stream loop)
  void Function(String)? onReceive;

  RawService({
    // Parameters for native lib loader
    this.dir,
    this.file,
    // Parameters for handling client
    this.timeout = 30,
    // Parameters for td api
    int? this.newVerbosityLevel,
    // Event handlers
    this.onStreamError,
    this.onReceive,
  }) {
    _client = Client(dir: dir, file: file);
  }

  bool _starting = false;
  Completer? _stopping;
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
      String? s = _rawClient.td_json_client_receive(clientId, timeout);
      if (s == null) {
        continue;
      }
      // Custom event for closing the receive loop
      if (s == '{"@type":"error","code":9527,"message":""}') {
        sendPortToMain.send(true);
        return;
      }
      sendPortToMain.send(s);
    }
  }

  void _onReceiveFromIsolate(dynamic data) {
    if (data is bool) {
      _stopping?.complete();
      return;
    }
    if (onReceive != null) {
      onReceive!(data);
    }
  }

  void _onReceiveErrorFromIsolate(dynamic e) {
    if (onStreamError != null) {
      onStreamError!(e);
    }
  }

  Future<void> _initIsolate() async {
    _receivePort = ReceivePort();
    _receivePort!
        .listen(_onReceiveFromIsolate, onError: _onReceiveErrorFromIsolate);
    _receiveIsolate = await Isolate.spawn(_receive,
        [_receivePort!.sendPort, dir, file, _client.clientId, timeout],
        debugName: "isolated receive");
  }

  _killIsolate() {
    _receiveIsolate?.kill(priority: Isolate.immediate);
    _receiveIsolate = null;
    _receivePort?.close();
    _receivePort = null;
  }

  /// Start receiving messages from native td json client
  Future<void> start() async {
    if (_running) {
      return;
    }
    if (_starting) {
      return;
    }
    _starting = true;
    if (_client.clientId == null) {
      _client.create();
    }
    if (newVerbosityLevel != null) {
      _client.send({
        "@type": "setLogVerbosityLevel",
        "new_verbosity_level": newVerbosityLevel
      });
    }
    await _initIsolate();
    _starting = false;
    _running = true;
  }

  /// Stop receiving messages from native td json client, use this wisely
  Future<void> stop() async {
    if (!_running) {
      return;
    }
    if (_stopping != null) {
      return;
    }
    _stopping = Completer();
    // Need to wait isolate finishing last receive loop to prevent the error: [Client.cpp:277] Receive is called after Client destroy, or simultaneously from different threads
    // Flows:
    // - main send custom event to td native, must use `testReturnError` as event, because others like `testSquareInt` can't be send after `authorizationStateClosed`
    // - isolate receive the event
    // - isolate send special type to main
    // - isolate break the loop
    // - main receive the type
    // - main kill isolate
    _client.send({
      "@type": "testReturnError",
      "error": {
        // should prevent conflicts with td's error code, but there is no code list in official doc, so here's using just a big number.
        "code": 9527
      }
    });
    await _stopping;
    _killIsolate();
    _stopping = null;
    _running = false;
  }
}

class Service extends RawService {
  Map _callbacks = <int, Completer>{};

  /// The maximum random value (0 ~ maxExtra) for td function @extra
  late int maxExtra;

  /// Initial tdlibParameters for td function [setTdlibParameters](https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1set_tdlib_parameters.html)
  late Map<String, dynamic> tdlibParameters;

  /// The event fired after receiving Error, the error parsed from td json raw string result: {"@type": "error", ...}
  void Function(Error)? onReceiveError;

  /// The event fired after service handling receiving td object, including td error object
  void Function(Map<String, dynamic>)? afterReceive;

  /// The event fired before sending object to td json client (via function send, sendSync)
  void Function(Map<String, dynamic>)? beforeSend;

  /// The event fired before sending object to td json client (via function execute)
  void Function(Map<String, dynamic>)? beforeExecute;

  /// The event fired after receiving result object from td json client (via function execute)
  void Function(Map<String, dynamic>)? afterExecute;

  Service({
    // Parameters for native lib loader
    super.dir,
    super.file,
    // Parameters for handling client
    super.timeout = 10,
    this.maxExtra = 10000000,
    // Parameters for td api
    super.newVerbosityLevel,
    required Map<String, dynamic> tdlibParameters,

    // Event handlers
    super.onStreamError,
    super.onReceive,
    this.onReceiveError,
    this.afterReceive,
    this.beforeSend,
    this.beforeExecute,
    this.afterExecute,

    /// start the receive stream loop, default is true, set it to false if you want start it later
    start = true,
  }) {
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
    this.tdlibParameters = tdlibParameters;
    if (maxExtra < 10000) {
      throw ArgumentError(
          "To prevent infinity generating @extra, don't set maxExtra less than 10000");
    }
    _client = Client(dir: dir, file: file);
    if (start) {
      super.start();
    }
  }

  @override
  void _onReceiveFromIsolate(dynamic data) {
    if (data is bool) {
      _stopping?.complete();
      return;
    }
    String s = data;
    if (onReceive != null) {
      onReceive!(s);
    }
    Map<String, dynamic> j = json.decode(s);
    _afterReceive(j);
  }

  void _afterReceive(Map<String, dynamic> obj) async {
    if (obj['@type'] == 'error') {
      _handleError(Error.fromJson(obj));
    } else {
      await _handleObject(obj);
    }
    if (afterReceive != null) {
      afterReceive!(obj);
    }
  }

  _handleError(Error e) {
    if (e.extra != null) {
      final int extra = e.extra;
      if (_callbacks.containsKey(extra)) {
        Completer fut = _callbacks.remove(extra);
        fut.completeError(e);
        return;
      }
    }
    if (onReceiveError != null) {
      onReceiveError!(e);
    }
  }

  Future _handleObject(Map<String, dynamic> obj) async {
    if (obj['@type'] == "updates") {
      await Future.wait(
          (obj['updates'] ?? []).map((update) => _handleEventObject(update)));
    } else {
      await _handleEventObject(obj);
    }
    if (obj.containsKey('@extra')) {
      final int extra = obj['@extra'];
      if (_callbacks.containsKey(extra)) {
        Completer fut = _callbacks.remove(extra);
        fut.complete(obj);
      }
    }
  }

  _handleEventObject(Map<String, dynamic> eventObj) async {
    switch (eventObj['@type']) {
      case 'updateAuthorizationState':
        await _handleAuthObject(eventObj['authorization_state']);
        break;
    }
  }

  // https://github.com/tdlib/td/blob/master/td/generate/scheme/td_api.tl#L77
  _handleAuthObject(Map<String, dynamic> authObj) async {
    switch (authObj['@type']) {
      case 'authorizationStateWaitTdlibParameters':
        send({'@type': 'setTdlibParameters', ...tdlibParameters});
        break;
      // To prevent someone send {"@type": "logOut"}
      case 'authorizationStateClosed':
        await stop();
        _client.clientId = null; // force recreate client
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

  Completer<Map<String, dynamic>> _send(Map<String, dynamic> obj) {
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
    return completer;
  }

  /// Asynchronously send td function
  Future send(Map<String, dynamic> obj) async {
    _send(obj);
    return Future.value();
  }

  /// Synchronously send td function (it will wait until get the result)
  /// This is handled by dart side service, not by native td execute function
  /// Because td client doesn't allow some functions executing synchronously
  Future<Map<String, dynamic>> sendSync(Map<String, dynamic> obj) {
    final completer = _send(obj);
    return completer.future;
  }

  /// Synchronously execute td function
  /// Handled by native td execute function
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

  NativeCallable<def.td_log_message_callback>? _logMessageCallback = null;

  void setLogMessageCallback(int max_verbosity_level,
      NativeCallable<def.td_log_message_callback> callback) {
    if (_logMessageCallback != null) {
      _logMessageCallback!.close();
    }
    _client.set_log_message_callback(max_verbosity_level, callback);
    _logMessageCallback = callback;
  }
}
