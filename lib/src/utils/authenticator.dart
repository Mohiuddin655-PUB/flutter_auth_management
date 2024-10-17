import '../models/auth.dart';
import '../models/auth_providers.dart';

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
  }) : super(provider: AuthProviders.email, email: email, password: password);

  Authenticator.guest({
    super.id,
    super.timeMills,
    super.name,
    super.email,
    super.phone,
    super.photo,
    super.username,
    super.extra,
  }) : super(provider: AuthProviders.guest);

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
  }) : super(provider: AuthProviders.phone, phone: phone);

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
          provider: AuthProviders.username,
          username: username,
          password: password,
        );
}
