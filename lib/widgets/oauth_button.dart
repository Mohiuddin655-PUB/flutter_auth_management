import 'package:flutter/material.dart';

import '../core/auth.dart';
import '../core/authenticator.dart';
import '../core/authorizer.dart';
import '../core/helper.dart';

enum OauthButtonType {
  apple,
  biometric,
  facebook,
  gameCenter,
  github,
  google,
  microsoft,
  playGames,
  saml,
  twitter,
  yahoo,
}

class OauthButton<T extends Auth> extends StatelessWidget {
  final Object? args;
  final String? id;
  final bool notifiable;
  final OauthButtonType type;
  final OAuthAuthenticator? authenticator;
  final bool storeToken;
  final SignByBiometricCallback? onBiometric;

  final Widget Function(BuildContext context, VoidCallback callback) builder;

  const OauthButton({
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
      case OauthButtonType.apple:
        context.signInWithApple<T>(
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator: authenticator,
          storeToken: storeToken,
        );
        break;
      case OauthButtonType.biometric:
        context.signInByBiometric<T>(
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case OauthButtonType.facebook:
        context.signInWithFacebook<T>(
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case OauthButtonType.gameCenter:
        context.signInWithGameCenter<T>(
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case OauthButtonType.github:
        context.signInWithGithub<T>(
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case OauthButtonType.google:
        context.signInWithGoogle<T>(
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case OauthButtonType.microsoft:
        context.signInWithMicrosoft<T>(
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case OauthButtonType.playGames:
        context.signInWithPlayGames<T>(
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case OauthButtonType.saml:
        context.signInWithSAML<T>(
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case OauthButtonType.twitter:
        context.signInWithTwitter<T>(
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
      case OauthButtonType.yahoo:
        context.signInWithYahoo<T>(
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, () => _callback(context));
  }
}
