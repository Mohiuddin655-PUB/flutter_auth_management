import 'package:flutter/material.dart';

import '../core/auth.dart';
import '../core/authenticator.dart';
import '../core/authorizer.dart';
import '../core/helper.dart';

enum AuthButtonType {
  biometricEnable,
  deleteAccount,
  updateAccount,
  signInAnonymously,
  signInWithApple,
  signInWithFacebook,
  signInWithGameCenter,
  signInWithGithub,
  signInWithGoogle,
  signInWithMicrosoft,
  signInWithPlayGames,
  signInWithSAML,
  signInWithTwitter,
  signInWithYahoo,
  signInByBiometric,
  signInByEmail,
  signInByUsername,
  signOut,
  signUpByEmail,
  signUpByUsername,
  verifyPhoneByOtp,
}

class AuthButton<T extends Auth> extends StatelessWidget {
  final Object? args;
  final String? id;
  final bool notifiable;
  final AuthButtonType type;
  final Authenticator? authenticator;
  final bool storeToken;
  final Map<String, dynamic>? updates;
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
    this.updates,
    this.onBiometric,
  });

  void _biometricEnable(BuildContext context) async {
    final biometricSupport = await context.canUseBiometric();
    if (!biometricSupport.isSuccessful) {
      throw Exception('Biometric authentication is not available.');
    }
    if (!context.mounted) return;
    bool? biometric;
    if (onBiometric == null) return;
    biometric = await onBiometric!(biometricSupport.data);
    if (!context.mounted) return;
    context.biometricEnable<T>(biometric ?? false);
  }

  void _callback(BuildContext context) {
    final authenticator = this.authenticator;
    switch (type) {
      case AuthButtonType.biometricEnable:
        _biometricEnable(context);
        break;
      case AuthButtonType.deleteAccount:
        context.deleteAccount<T>(args: args, notifiable: notifiable, id: id);
        break;
      case AuthButtonType.updateAccount:
        if (updates == null) {
          throw Exception('Updates cannot be null for updateAccount.');
        }
        context.updateAccount<T>(updates!, notifiable: notifiable, id: id);
        break;
      case AuthButtonType.signInAnonymously:
        context.signInAnonymously<T>(
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator:
              authenticator is GuestAuthenticator ? authenticator : null,
        );
        break;
      case AuthButtonType.signInWithApple:
        context.signInWithApple<T>(
          id: id,
          args: args,
          notifiable: notifiable,
          storeToken: storeToken,
          authenticator:
              authenticator is OAuthAuthenticator ? authenticator : null,
        );
        break;
      case AuthButtonType.signInWithFacebook:
        context.signInWithFacebook<T>(
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator:
              authenticator is OAuthAuthenticator ? authenticator : null,
        );
        break;
      case AuthButtonType.signInWithGameCenter:
        context.signInWithGameCenter<T>(
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator:
              authenticator is OAuthAuthenticator ? authenticator : null,
        );
        break;
      case AuthButtonType.signInWithGithub:
        context.signInWithGithub<T>(
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator:
              authenticator is OAuthAuthenticator ? authenticator : null,
        );
        break;
      case AuthButtonType.signInWithGoogle:
        context.signInWithGoogle<T>(
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator:
              authenticator is OAuthAuthenticator ? authenticator : null,
        );
        break;
      case AuthButtonType.signInWithMicrosoft:
        context.signInWithMicrosoft<T>(
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator:
              authenticator is OAuthAuthenticator ? authenticator : null,
        );
        break;
      case AuthButtonType.signInWithPlayGames:
        context.signInWithPlayGames<T>(
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator:
              authenticator is OAuthAuthenticator ? authenticator : null,
        );
        break;
      case AuthButtonType.signInWithSAML:
        context.signInWithSAML<T>(
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator:
              authenticator is OAuthAuthenticator ? authenticator : null,
        );
        break;
      case AuthButtonType.signInWithTwitter:
        context.signInWithTwitter<T>(
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator:
              authenticator is OAuthAuthenticator ? authenticator : null,
        );
        break;
      case AuthButtonType.signInWithYahoo:
        context.signInWithYahoo<T>(
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator:
              authenticator is OAuthAuthenticator ? authenticator : null,
        );
        break;
      case AuthButtonType.signInByBiometric:
        context.signInByBiometric<T>(
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case AuthButtonType.signInByEmail:
        context.signInByEmail<T>(
          authenticator as EmailAuthenticator,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case AuthButtonType.signInByUsername:
        context.signInByUsername<T>(
          authenticator as UsernameAuthenticator,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case AuthButtonType.signOut:
        context.signOut<T>();
        break;
      case AuthButtonType.signUpByEmail:
        context.signUpByEmail<T>(
          authenticator as EmailAuthenticator,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case AuthButtonType.signUpByUsername:
        context.signUpByUsername<T>(
          authenticator as UsernameAuthenticator,
          onBiometric: onBiometric,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case AuthButtonType.verifyPhoneByOtp:
        context.verifyPhoneByOtp<T>(authenticator as OtpAuthenticator);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, () => _callback(context));
  }
}
