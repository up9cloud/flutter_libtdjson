import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

import './typedef.dart' as def;

// https://core.telegram.org/tdlib/docs/td__json__client_8h.html
typedef int td_create_client_id();
typedef void td_send(int client_id, ffi.Pointer<Utf8> request);
typedef ffi.Pointer<Utf8> td_receive(double timeout);
typedef ffi.Pointer<Utf8> td_execute(ffi.Pointer<Utf8> request);
typedef void td_log_message_callback(
    int verbosity_level, ffi.Pointer<Utf8> message);
typedef td_log_message_callback_ptr
    = ffi.Pointer<ffi.NativeFunction<td_log_message_callback>>;
typedef void td_set_log_message_callback(
    int max_verbosity_level, def.td_log_message_callback_ptr callback);

typedef ffi.Pointer td_json_client_create();
typedef void td_json_client_send(ffi.Pointer client, ffi.Pointer<Utf8> request);
typedef ffi.Pointer<Utf8> td_json_client_receive(
    ffi.Pointer client, double timeout);
typedef ffi.Pointer<Utf8> td_json_client_execute(
    ffi.Pointer client, ffi.Pointer<Utf8> request);
typedef void td_json_client_destroy(ffi.Pointer client);
