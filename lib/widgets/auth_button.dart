import 'package:flutter/material.dart';

import '../core/auth.dart';
import '../core/authenticator.dart';
import '../core/authorizer.dart';
import '../core/helper.dart';

enum AuthButtonType {
  loginWithEmail,
  loginWithUsername,
  logout,
  registerWithEmail,
  registerWithUsername,
  verifyPhoneNumber,
}

class AuthButton<T extends Auth> extends StatelessWidget {
  final Object? args;
  final String? id;
  final bool notifiable;
  final AuthButtonType type;
  final OAuthAuthenticator? authenticator;
  final bool storeToken;
  final SignByBiometricCallback? onBiometric;

  final Widget Function(BuildContext context, VoidCallback callback) builder;

  const AuthButton({
    super.key,
    this.args,
    this.id,
    this.notifiable = true,
    required this.type,
    required this.builder,
    this.authenticator,
    this.storeToken = false,
    this.onBiometric,
  });

  void _callback(BuildContext context) {
    switch (type) {
      case AuthButtonType.loginWithEmail:
        context.signInByEmail<T>(
          authenticator as EmailAuthenticator,
          onBiometric: onBiometric,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case AuthButtonType.loginWithUsername:
        context.signInByUsername<T>(
          authenticator as UsernameAuthenticator,
          onBiometric: onBiometric,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case AuthButtonType.registerWithEmail:
        context.signUpByEmail<T>(
          authenticator as EmailAuthenticator,
          onBiometric: onBiometric,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case AuthButtonType.registerWithUsername:
        context.signUpByUsername<T>(
          authenticator as UsernameAuthenticator,
          onBiometric: onBiometric,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case AuthButtonType.verifyPhoneNumber:
        context.verifyPhoneByOtp<T>(authenticator as OtpAuthenticator);
        break;
      case AuthButtonType.logout:
        context.signOut<T>();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, () => _callback(context));
  }
}
