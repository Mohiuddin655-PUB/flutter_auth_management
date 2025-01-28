import 'package:flutter/material.dart';

import '../core/helper.dart';
import '../models/auth.dart';
import '../utils/authenticator.dart';

typedef OauthButtonCallback = void Function(BuildContext context);

class OauthButton<T extends Auth> extends StatelessWidget {
  final OauthButtonType type;
  final OAuthAuthenticator? authenticator;
  final bool storeToken;

  final Widget Function(
    BuildContext context,
    OauthButtonCallback callback,
  ) builder;

  const OauthButton({
    super.key,
    required this.type,
    required this.builder,
    this.authenticator,
    this.storeToken = false,
  });

  void _callback(BuildContext context) {
    switch (type) {
      case OauthButtonType.apple:
        context.signInWithApple<T>(
          authenticator: authenticator,
          storeToken: storeToken,
        );
        break;
      case OauthButtonType.facebook:
        context.signInWithFacebook<T>(
          authenticator: authenticator,
          storeToken: storeToken,
        );
        break;
      case OauthButtonType.gameCenter:
        context.signInWithGameCenter<T>(
          authenticator: authenticator,
          storeToken: storeToken,
        );
        break;
      case OauthButtonType.github:
        context.signInWithGithub<T>(
          authenticator: authenticator,
          storeToken: storeToken,
        );
        break;
      case OauthButtonType.google:
        context.signInWithGoogle<T>(
          authenticator: authenticator,
          storeToken: storeToken,
        );
        break;
      case OauthButtonType.microsoft:
        context.signInWithMicrosoft<T>(
          authenticator: authenticator,
          storeToken: storeToken,
        );
        break;
      case OauthButtonType.playGames:
        context.signInWithPlayGames<T>(
          authenticator: authenticator,
          storeToken: storeToken,
        );
        break;
      case OauthButtonType.saml:
        context.signInWithSAML<T>(
          authenticator: authenticator,
          storeToken: storeToken,
        );
        break;
      case OauthButtonType.twitter:
        context.signInWithTwitter<T>(
          authenticator: authenticator,
          storeToken: storeToken,
        );
        break;
      case OauthButtonType.yahoo:
        context.signInWithYahoo<T>(
          authenticator: authenticator,
          storeToken: storeToken,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, _callback);
  }
}

enum OauthButtonType {
  apple,
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
