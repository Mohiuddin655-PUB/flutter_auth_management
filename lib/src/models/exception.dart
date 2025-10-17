class AuthException {
  final String msg;
  final String? code;

  const AuthException(this.msg, [this.code]);

  @override
  String toString() => "$AuthException(code: $code, msg: $msg)";
}
