class Error {
  Error({required this.code, required this.message, this.extra});
  int code;
  String message;
  dynamic extra;
  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] ?? 0,
      message: json['message'] ?? "",
      extra: json['@extra'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "@type": "error",
      "code": this.code,
      "message": this.message,
      "@extra": this.extra
    };
  }

  @override
  String toString() {
    return "Instance of 'Error': " + toJson().toString();
  }
}
