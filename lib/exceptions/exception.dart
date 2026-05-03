class AuthException {
  final String msg;
  final String? code;

  const AuthException(this.msg, [this.code]);

  @override
  String toString() => "$AuthException(code: $code, msg: $msg)";
}

class AuthProviderException implements Exception {
  final String message;

  const AuthProviderException(this.message);

  @override
  String toString() => 'AuthProviderException: $message';
}
