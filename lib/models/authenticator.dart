abstract class Authenticator {
  const Authenticator();
}

class EmailAuthenticator extends Authenticator {
  final String email;
  final String password;

  const EmailAuthenticator({
    required this.email,
    required this.password,
  });
}

class GuestAuthenticator extends Authenticator {
  const GuestAuthenticator();
}

class OAuthAuthenticator extends Authenticator {
  final String token;

  const OAuthAuthenticator({required this.token});
}

class OtpAuthenticator extends Authenticator {
  final String token;
  final String code;
  final String value;
  final String type;

  bool get isEmail => type == 'email';

  bool get isPhone => type == 'phone';

  const OtpAuthenticator.email({
    required this.token,
    required this.code,
    required String email,
  })  : type = 'email',
        value = email;

  const OtpAuthenticator.phone({
    required this.token,
    required this.code,
    required String phone,
  })  : type = 'phone',
        value = phone;
}

class PhoneAuthenticator extends Authenticator {
  final String phone;
  final String? resendToken;

  const PhoneAuthenticator({required this.phone, this.resendToken});
}

class UsernameAuthenticator extends Authenticator {
  final String username;
  final String password;

  const UsernameAuthenticator({required this.username, required this.password});
}
