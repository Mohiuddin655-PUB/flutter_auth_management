import 'package:flutter/material.dart' show BuildContext;

import '../core/authorizer.dart' show SignByBiometricCallback;
import '../models/auth.dart' show Auth;
import '../models/auth_button_type.dart' show AuthButtonType;
import '../models/authenticator.dart'
    show
        Authenticator,
        EmailAuthenticator,
        GuestAuthenticator,
        UsernameAuthenticator,
        OtpAuthenticator,
        OAuthAuthenticator;
import '../utils/helper.dart' show AuthHelper;
import 'actions.dart'
    show
        OAuthSignInAction,
        AuthAction,
        BiometricEnableAction,
        SignInByBiometricAction,
        DeleteAccountAction,
        UpdateAccountAction,
        SignOutAction,
        SignInAnonymouslyAction,
        SignInByEmailAction,
        SignUpByEmailAction,
        SignInByUsernameAction,
        SignUpByUsernameAction,
        VerifyPhoneByOtpAction;

/// Validates [authenticator] is of type [R] and returns it, or throws a
/// descriptive [ArgumentError].
R _requireAuthenticator<R extends Authenticator>(
  Authenticator? authenticator,
  AuthButtonType type,
) {
  if (authenticator is! R) {
    throw ArgumentError(
      '${type.name} requires a $R authenticator, '
      'but got ${authenticator.runtimeType}.',
    );
  }
  return authenticator;
}

/// Constructs the correct [AuthAction] for a given [AuthButtonType].
///
/// All validation is centralised here, keeping [AuthButton] free of
/// type-checking logic.
class AuthActionFactory {
  const AuthActionFactory._();

  static AuthAction<T> build<T extends Auth>({
    required AuthButtonType type,
    Authenticator? authenticator,
    Map<String, dynamic>? updates,
    SignByBiometricCallback? onBiometric,
    bool storeToken = false,
    String? id,
    Object? args,
    bool notifiable = true,
  }) {
    switch (type) {
      // ── Biometric ────────────────────────────────────────────────────────
      case AuthButtonType.biometricEnable:
        return BiometricEnableAction<T>(onBiometric: onBiometric);

      case AuthButtonType.signInByBiometric:
        return SignInByBiometricAction<T>(
            id: id, args: args, notifiable: notifiable);

      // ── Account management ───────────────────────────────────────────────
      case AuthButtonType.deleteAccount:
        return DeleteAccountAction<T>(
            id: id, args: args, notifiable: notifiable);

      case AuthButtonType.updateAccount:
        if (updates == null) {
          throw ArgumentError(
              'updates must be provided for AuthButtonType.updateAccount.');
        }
        return UpdateAccountAction<T>(
            updates: updates, id: id, notifiable: notifiable);

      case AuthButtonType.signOut:
        return SignOutAction<T>();

      // ── Anonymous ────────────────────────────────────────────────────────
      case AuthButtonType.signInAnonymously:
        return SignInAnonymouslyAction<T>(
          id: id,
          args: args,
          notifiable: notifiable,
          authenticator:
              authenticator is GuestAuthenticator ? authenticator : null,
        );

      // ── Email ────────────────────────────────────────────────────────────
      case AuthButtonType.signInByEmail:
        return SignInByEmailAction<T>(
          authenticator:
              _requireAuthenticator<EmailAuthenticator>(authenticator, type),
          id: id,
          args: args,
          notifiable: notifiable,
        );

      case AuthButtonType.signUpByEmail:
        return SignUpByEmailAction<T>(
          authenticator:
              _requireAuthenticator<EmailAuthenticator>(authenticator, type),
          id: id,
          args: args,
          notifiable: notifiable,
        );

      // ── Username ─────────────────────────────────────────────────────────
      case AuthButtonType.signInByUsername:
        return SignInByUsernameAction<T>(
          authenticator:
              _requireAuthenticator<UsernameAuthenticator>(authenticator, type),
          id: id,
          args: args,
          notifiable: notifiable,
        );

      case AuthButtonType.signUpByUsername:
        return SignUpByUsernameAction<T>(
          authenticator:
              _requireAuthenticator<UsernameAuthenticator>(authenticator, type),
          onBiometric: onBiometric,
          id: id,
          args: args,
          notifiable: notifiable,
        );

      // ── OTP ──────────────────────────────────────────────────────────────
      case AuthButtonType.verifyPhoneByOtp:
        return VerifyPhoneByOtpAction<T>(
          authenticator:
              _requireAuthenticator<OtpAuthenticator>(authenticator, type),
        );

      // ── OAuth providers ──────────────────────────────────────────────────
      case AuthButtonType.signInWithApple:
        return _oauth<T>(
          contextCall: (ctx,
                  {required storeToken,
                  id,
                  args,
                  required notifiable,
                  authenticator}) =>
              ctx.signInWithApple<T>(
                  storeToken: storeToken,
                  id: id,
                  args: args,
                  notifiable: notifiable,
                  authenticator: authenticator),
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );

      case AuthButtonType.signInWithFacebook:
        return _oauth<T>(
          contextCall: (ctx,
                  {required storeToken,
                  id,
                  args,
                  required notifiable,
                  authenticator}) =>
              ctx.signInWithFacebook<T>(
                  storeToken: storeToken,
                  id: id,
                  args: args,
                  notifiable: notifiable,
                  authenticator: authenticator),
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );

      case AuthButtonType.signInWithGameCenter:
        return _oauth<T>(
          contextCall: (ctx,
                  {required storeToken,
                  id,
                  args,
                  required notifiable,
                  authenticator}) =>
              ctx.signInWithGameCenter<T>(
                  storeToken: storeToken,
                  id: id,
                  args: args,
                  notifiable: notifiable,
                  authenticator: authenticator),
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );

      case AuthButtonType.signInWithGithub:
        return _oauth<T>(
          contextCall: (ctx,
                  {required storeToken,
                  id,
                  args,
                  required notifiable,
                  authenticator}) =>
              ctx.signInWithGithub<T>(
                  storeToken: storeToken,
                  id: id,
                  args: args,
                  notifiable: notifiable,
                  authenticator: authenticator),
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );

      case AuthButtonType.signInWithGoogle:
        return _oauth<T>(
          contextCall: (ctx,
                  {required storeToken,
                  id,
                  args,
                  required notifiable,
                  authenticator}) =>
              ctx.signInWithGoogle<T>(
                  storeToken: storeToken,
                  id: id,
                  args: args,
                  notifiable: notifiable,
                  authenticator: authenticator),
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );

      case AuthButtonType.signInWithMicrosoft:
        return _oauth<T>(
          contextCall: (ctx,
                  {required storeToken,
                  id,
                  args,
                  required notifiable,
                  authenticator}) =>
              ctx.signInWithMicrosoft<T>(
                  storeToken: storeToken,
                  id: id,
                  args: args,
                  notifiable: notifiable,
                  authenticator: authenticator),
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );

      case AuthButtonType.signInWithPlayGames:
        return _oauth<T>(
          contextCall: (ctx,
                  {required storeToken,
                  id,
                  args,
                  required notifiable,
                  authenticator}) =>
              ctx.signInWithPlayGames<T>(
                  storeToken: storeToken,
                  id: id,
                  args: args,
                  notifiable: notifiable,
                  authenticator: authenticator),
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );

      case AuthButtonType.signInWithSAML:
        return _oauth<T>(
          contextCall: (ctx,
                  {required storeToken,
                  id,
                  args,
                  required notifiable,
                  authenticator}) =>
              ctx.signInWithSAML<T>(
                  storeToken: storeToken,
                  id: id,
                  args: args,
                  notifiable: notifiable,
                  authenticator: authenticator),
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );

      case AuthButtonType.signInWithTwitter:
        return _oauth<T>(
          contextCall: (ctx,
                  {required storeToken,
                  id,
                  args,
                  required notifiable,
                  authenticator}) =>
              ctx.signInWithTwitter<T>(
                  storeToken: storeToken,
                  id: id,
                  args: args,
                  notifiable: notifiable,
                  authenticator: authenticator),
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );

      case AuthButtonType.signInWithYahoo:
        return _oauth<T>(
          contextCall: (ctx,
                  {required storeToken,
                  id,
                  args,
                  required notifiable,
                  authenticator}) =>
              ctx.signInWithYahoo<T>(
                  storeToken: storeToken,
                  id: id,
                  args: args,
                  notifiable: notifiable,
                  authenticator: authenticator),
          authenticator: authenticator,
          storeToken: storeToken,
          id: id,
          args: args,
          notifiable: notifiable,
        );
    }
  }

  static OAuthSignInAction<T> _oauth<T extends Auth>({
    required void Function(
      BuildContext, {
      required bool storeToken,
      String? id,
      Object? args,
      required bool notifiable,
      OAuthAuthenticator? authenticator,
    }) contextCall,
    Authenticator? authenticator,
    bool storeToken = false,
    String? id,
    Object? args,
    bool notifiable = true,
  }) {
    return OAuthSignInAction<T>(
      contextCall: contextCall,
      authenticator: authenticator is OAuthAuthenticator ? authenticator : null,
      storeToken: storeToken,
      id: id,
      args: args,
      notifiable: notifiable,
    );
  }
}
