import 'auth.dart';
import 'provider.dart';

class Authenticator extends Auth {
  Authenticator.empty() : super();

  Authenticator.email({
    required String email,
    required String password,
    super.id,
    super.timeMills,
    super.name,
    super.phone,
    super.photo,
    super.username,
    super.extra,
  }) : super(provider: Provider.email, email: email, password: password);

  Authenticator.guest({
    super.id,
    super.timeMills,
    super.name,
    super.email,
    super.phone,
    super.photo,
    super.username,
    super.extra,
  }) : super(provider: Provider.guest);

  Authenticator.oauth({
    super.id,
    super.timeMills,
    super.accessToken,
    super.idToken,
    super.name,
    super.email,
    super.phone,
    super.photo,
    super.provider,
    super.username,
    super.extra,
  }) : super();

  Authenticator.otp({
    required String idToken,
    required String accessToken,
    super.id,
    super.timeMills,
    super.name,
    super.email,
    super.phone,
    super.photo,
    super.provider,
    super.username,
    super.extra,
  }) : super(idToken: idToken, accessToken: accessToken);

  Authenticator.phone({
    required String phone,
    super.id,
    super.timeMills,
    super.name,
    super.email,
    super.photo,
    super.username,
    super.extra,
  }) : super(provider: Provider.phone, phone: phone);

  Authenticator.username({
    required String username,
    required String password,
    super.id,
    super.timeMills,
    super.name,
    super.email,
    super.phone,
    super.photo,
    super.extra,
  }) : super(
          provider: Provider.username,
          username: username,
          password: password,
        );
}

class EmailAuthenticator extends Authenticator {
  EmailAuthenticator({
    required super.email,
    required super.password,
    super.id,
    super.timeMills,
    super.name,
    super.phone,
    super.photo,
    super.username,
    super.extra,
  }) : super.email();

  @override
  String get email => super.email ?? "example@gmail.com";

  @override
  String get password => super.password ?? "123456";
}

class GuestAuthenticator extends Authenticator {
  GuestAuthenticator({
    super.id,
    super.timeMills,
    super.name,
    super.email,
    super.phone,
    super.photo,
    super.username,
    super.extra,
  }) : super.guest();
}

class OAuthAuthenticator extends Authenticator {
  OAuthAuthenticator({
    super.id,
    super.timeMills,
    super.accessToken,
    super.idToken,
    super.name,
    super.email,
    super.phone,
    super.photo,
    super.provider,
    super.username,
    super.extra,
  }) : super.oauth();
}

enum OtpType {
  email,
  phone;

  bool get isEmail => this == email;

  bool get isPhone => this == phone;
}

class OtpAuthenticator extends Authenticator {
  final OtpType type;

  OtpAuthenticator({
    required String token,
    required String smsCode,
    this.type = OtpType.phone,
    super.email,
    super.id,
    super.timeMills,
    super.name,
    super.phone,
    super.photo,
    super.provider,
    super.username,
    super.extra,
  }) : super.otp(idToken: token, accessToken: smsCode);

  String get token => super.idToken ?? "";

  String get smsCode => super.accessToken ?? "";
}

class PhoneAuthenticator extends Authenticator {
  PhoneAuthenticator({
    required super.phone,
    String? token,
    super.id,
    super.timeMills,
    super.email,
    super.name,
    super.photo,
    super.username,
    super.extra,
  }) : super.phone();

  OtpAuthenticator otp({
    required String token,
    required String smsCode,
  }) {
    return OtpAuthenticator(
      token: token,
      smsCode: smsCode,
      email: email,
      extra: extra,
      id: id,
      name: name,
      phone: phone,
      photo: photo,
      provider: provider,
      timeMills: timeMills,
      username: username,
    );
  }

  @override
  String get phone => super.phone ?? "";
}

class UsernameAuthenticator extends Authenticator {
  UsernameAuthenticator({
    required super.username,
    required super.password,
    super.id,
    super.timeMills,
    super.email,
    super.name,
    super.phone,
    super.photo,
    super.extra,
  }) : super.username();

  @override
  String get username => super.username ?? "username";

  @override
  String get password => super.password ?? "123456";
}
