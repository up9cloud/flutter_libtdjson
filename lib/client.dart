import 'dart:ffi';
import "dart:io" show Platform;
import 'dart:convert' show json;

import 'package:ffi/ffi.dart';
import "package:path/path.dart" as path;
// import 'package:flutter/foundation.dart' show kIsWeb;

import './typedef.dart' as def;
import './typedef_dart.dart' as defDart;

class NativeClient {
  late final DynamicLibrary libtdjson;
  late final defDart.td_json_client_create td_json_client_create;
  late final defDart.td_json_client_send td_json_client_send;
  late final defDart.td_json_client_receive td_json_client_receive;
  late final defDart.td_json_client_execute td_json_client_execute;
  late final defDart.td_json_client_destroy td_json_client_destroy;
  late final defDart.td_create_client_id td_create_client_id;
  late final defDart.td_send td_send;
  late final defDart.td_receive td_receive;
  late final defDart.td_execute td_execute;

  NativeClient({String? dir, String? file}) {
    _load(dir: dir, file: file);
  }

  static DynamicLibrary loadLibrary({String? dir, String? file}) {
    if (file == null) {
      if (Platform.isMacOS || Platform.isIOS) {
        file = 'libtdjson.dylib';
      } else if (Platform.isWindows) {
        file = 'tdjson.dll';
      } else {
        file = 'libtdjson.so';
      }
    }
    if (dir == null) {
      return DynamicLibrary.open(file);
    }
    return DynamicLibrary.open(path.join(dir, file));
  }

  // https://github.com/tdlib/td/pull/708/commits/237060abd4c205768153180e9f814298d1aa9d49
  _load({String? dir, String? file}) {
    libtdjson = loadLibrary(dir: dir, file: file);
    td_json_client_create = libtdjson
        .lookup<NativeFunction<def.td_json_client_create>>(
            'td_json_client_create')
        .asFunction();
    td_json_client_send = libtdjson
        .lookup<NativeFunction<def.td_json_client_send>>('td_json_client_send')
        .asFunction();
    td_json_client_receive = libtdjson
        .lookup<NativeFunction<def.td_json_client_receive>>(
            'td_json_client_receive')
        .asFunction();
    td_json_client_execute = libtdjson
        .lookup<NativeFunction<def.td_json_client_execute>>(
            'td_json_client_execute')
        .asFunction();
    td_json_client_destroy = libtdjson
        .lookup<NativeFunction<def.td_json_client_destroy>>(
            'td_json_client_destroy')
        .asFunction();
    td_create_client_id = libtdjson
        .lookup<NativeFunction<def.td_create_client_id>>('td_create_client_id')
        .asFunction();
    td_send =
        libtdjson.lookup<NativeFunction<def.td_send>>('td_send').asFunction();
    td_receive = libtdjson
        .lookup<NativeFunction<def.td_receive>>('td_receive')
        .asFunction();
    td_execute = libtdjson
        .lookup<NativeFunction<def.td_execute>>('td_execute')
        .asFunction();
  }
}

class RawClient {
  late final NativeClient _nativeClient;

  RawClient({String? dir, String? file}) {
    _nativeClient = NativeClient(dir: dir, file: file);
  }
  int td_json_client_create() {
    return _nativeClient.td_json_client_create().address;
  }

  td_json_client_send(int clientId, String request) {
    _nativeClient.td_json_client_send(
        Pointer.fromAddress(clientId), request.toNativeUtf8());
  }

  String td_json_client_receive(int clientId, double timeout) {
    Pointer<Utf8> raw = _nativeClient.td_json_client_receive(
        Pointer.fromAddress(clientId), timeout);
    // If timed out, it would return nullptr, and dart .toDartString doesn't allow nullptr, so
    if (raw.address == nullptr.address) {
      return "";
    }
    return raw.toDartString();
  }

  String td_json_client_execute(int clientId, String request) {
    Pointer<Utf8> raw = _nativeClient.td_json_client_execute(
        Pointer.fromAddress(clientId), request.toNativeUtf8());
    return raw.toDartString();
  }

  td_json_client_destroy(int clientId) {
    _nativeClient.td_json_client_destroy(Pointer.fromAddress(clientId));
  }

  int td_create_client_id() {
    return _nativeClient.td_create_client_id();
  }

  td_send(int clientId, String request) {
    _nativeClient.td_send(clientId, request.toNativeUtf8());
  }

  String td_receive(double timeout) {
    Pointer<Utf8> raw = _nativeClient.td_receive(timeout);
    if (raw.address == nullptr.address) {
      return "";
    }
    return raw.toDartString();
  }

  String td_execute(String request) {
    Pointer<Utf8> raw = _nativeClient.td_execute(request.toNativeUtf8());
    return raw.toDartString();
  }
}

class Client {
  late final RawClient _rawClient;
  int? clientId;

  Client({String? dir, String? file}) {
    _rawClient = RawClient(dir: dir, file: file);
  }

  /// Create native client instance, have to call it at least once before using other methods
  void create() {
    clientId = _rawClient.td_json_client_create();
  }

  /// Call td json receive, convert result to json object
  /// It will response null if receive empty string (timeout)
  Map<String, dynamic>? receive([double timeout = 10]) {
    String s = _rawClient.td_json_client_receive(clientId!, timeout);
    if (s.isEmpty) {
      return null;
    }
    Map<String, dynamic> j = json.decode(s);
    return j;
  }

  /// Encode json object then send it to td json client
  send(Map<String, dynamic> obj) {
    _rawClient.td_json_client_send(clientId!, json.encode(obj));
  }

  /// Encode json object, send it to td json client, and then response the decoded json result
  Map<String, dynamic> execute(Map<String, dynamic> obj) {
    String s = _rawClient.td_json_client_execute(clientId!, json.encode(obj));
    return json.decode(s);
  }
}
