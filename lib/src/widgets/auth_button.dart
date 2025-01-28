import 'package:flutter/material.dart';

import '../core/helper.dart';
import '../core/typedefs.dart';
import '../models/auth.dart';
import '../utils/authenticator.dart';

typedef AuthButtonCallback = void Function(BuildContext context);

class AuthButton<T extends Auth> extends StatelessWidget {
  final AuthButtonType type;
  final Authenticator? authenticator;
  final SignByBiometricCallback? onBiometric;

  final Widget Function(
    BuildContext context,
    AuthButtonCallback callback,
  ) builder;

  const AuthButton({
    super.key,
    required this.type,
    required this.builder,
    this.authenticator,
    this.onBiometric,
  });

  void _callback(BuildContext context) {
    switch (type) {
      case AuthButtonType.loginWithEmail:
        context.signInByEmail<T>(
          authenticator as EmailAuthenticator,
          onBiometric: onBiometric,
        );
        break;
      case AuthButtonType.loginWithUsername:
        context.signInByUsername<T>(
          authenticator as UsernameAuthenticator,
          onBiometric: onBiometric,
        );
        break;
      case AuthButtonType.registerWithEmail:
        context.signUpByEmail<T>(
          authenticator as EmailAuthenticator,
          onBiometric: onBiometric,
        );
        break;
      case AuthButtonType.registerWithUsername:
        context.signUpByUsername<T>(
          authenticator as UsernameAuthenticator,
          onBiometric: onBiometric,
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
    return builder(context, _callback);
  }
}

enum AuthButtonType {
  loginWithEmail,
  loginWithUsername,
  logout,
  registerWithEmail,
  registerWithUsername,
  verifyPhoneNumber,
}
