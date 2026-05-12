import 'package:flutter_entity/entity.dart' show EntityKey;

class AuthKeys extends EntityKey {
  static const key = "__uid__";

  final String biometric;
  final String email;
  final String loggedIn;
  final String loggedInTime;
  final String loggedOutTime;
  final String name;
  final String password;
  final String phone;
  final String photo;
  final String provider;
  final String username;
  final String verified;

  const AuthKeys({
    super.id,
    super.timeMills,
    this.biometric = "biometric",
    this.email = "email",
    this.loggedIn = "logged_in",
    this.loggedInTime = "logged_in_time",
    this.loggedOutTime = "logged_out_time",
    this.name = "name",
    this.password = "password",
    this.phone = "phone",
    this.photo = "photo",
    this.provider = "provider",
    this.username = "username",
    this.verified = "verified",
  });

  @override
  Iterable<String> get keys {
    return [
      id,
      timeMills,
      biometric,
      email,
      loggedIn,
      loggedInTime,
      loggedOutTime,
      name,
      password,
      phone,
      photo,
      provider,
      username,
      verified,
    ];
  }
}
