import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

// https://core.telegram.org/tdlib/docs/td__json__client_8h.html
typedef ffi.Int32 td_create_client_id();
typedef ffi.Void td_send(ffi.Int32 client_id, ffi.Pointer<Utf8> request);
typedef ffi.Pointer<Utf8> td_receive(ffi.Double timeout);
typedef ffi.Pointer<Utf8> td_execute(ffi.Pointer<Utf8> request);
typedef ffi.Void td_log_message_callback(
    ffi.Int32 verbosity_level, ffi.Pointer<Utf8> message);
typedef td_log_message_callback_ptr
    = ffi.Pointer<ffi.NativeFunction<td_log_message_callback>>;
typedef ffi.Void td_set_log_message_callback(
    ffi.Int32 max_verbosity_level, td_log_message_callback_ptr callback);

typedef ffi.Pointer<ffi.Void> td_json_client_create();
typedef ffi.Void td_json_client_send(
    ffi.Pointer client, ffi.Pointer<Utf8> request);
typedef ffi.Pointer<Utf8> td_json_client_receive(
    ffi.Pointer client, ffi.Double timeout);
typedef ffi.Pointer<Utf8> td_json_client_execute(
    ffi.Pointer client, ffi.Pointer<Utf8> request);
typedef ffi.Void td_json_client_destroy(ffi.Pointer client);
