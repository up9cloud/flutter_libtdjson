class LogService {
  static build(String key, [void Function(dynamic data)? fn]) {
    return (dynamic data) {
      print("$key: $data");
      if (fn != null) {
        fn(data);
      }
    };
  }
}
