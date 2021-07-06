import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

// https://core.telegram.org/tdlib/docs/td__json__client_8h.html
typedef ffi.Pointer<ffi.Void> td_json_client_create();
typedef ffi.Void td_json_client_send(
    ffi.Pointer client, ffi.Pointer<Utf8> request);
typedef ffi.Pointer<Utf8> td_json_client_receive(
    ffi.Pointer client, ffi.Double timeout);
typedef ffi.Pointer<Utf8> td_json_client_execute(
    ffi.Pointer client, ffi.Pointer<Utf8> request);
typedef ffi.Void td_json_client_destroy(ffi.Pointer client);
typedef ffi.Int32 td_create_client_id();
typedef ffi.Void td_send(ffi.Int32 client_id, ffi.Pointer<Utf8> request);
typedef ffi.Pointer<Utf8> td_receive(ffi.Double timeout);
typedef ffi.Pointer<Utf8> td_execute(ffi.Pointer<Utf8> request);
