import 'package:flutter/material.dart' show BuildContext;

import '../core/authorizer.dart' show SignByBiometricCallback;
import '../models/auth.dart' show Auth;
import '../models/authenticator.dart'
    show
        GuestAuthenticator,
        EmailAuthenticator,
        UsernameAuthenticator,
        OtpAuthenticator,
        OAuthAuthenticator;
import 'helper.dart' show AuthHelper;

/// Contract for every auth action.
/// Each [AuthButtonType] maps to exactly one [AuthAction] subclass.
abstract class AuthAction<T extends Auth> {
  const AuthAction();

  Future<void> execute(BuildContext context);
}

// ---------------------------------------------------------------------------
// Biometric
// ---------------------------------------------------------------------------

class BiometricEnableAction<T extends Auth> extends AuthAction<T> {
  final SignByBiometricCallback? onBiometric;

  const BiometricEnableAction({this.onBiometric});

  @override
  Future<void> execute(BuildContext context) async {
    final result = await context.canUseBiometric();
    if (!result.isSuccessful) {
      throw const AuthActionException(
          'Biometric authentication is not available.');
    }
    if (!context.mounted) return;

    final callback = onBiometric;
    if (callback == null) return;

    final enabled = await callback(result.data);
    if (!context.mounted) return;

    context.biometricEnable<T>(enabled ?? false);
  }
}

class SignInByBiometricAction<T extends Auth> extends AuthAction<T> {
  final String? id;
  final Object? args;
  final bool notifiable;

  const SignInByBiometricAction({this.id, this.args, this.notifiable = true});

  @override
  Future<void> execute(BuildContext context) async {
    context.signInByBiometric<T>(id: id, args: args, notifiable: notifiable);
  }
}

// ---------------------------------------------------------------------------
// Account management
// ---------------------------------------------------------------------------

class DeleteAccountAction<T extends Auth> extends AuthAction<T> {
  final String? id;
  final Object? args;
  final bool notifiable;

  const DeleteAccountAction({this.id, this.args, this.notifiable = true});

  @override
  Future<void> execute(BuildContext context) async {
    context.deleteAccount<T>(args: args, notifiable: notifiable, id: id);
  }
}

class UpdateAccountAction<T extends Auth> extends AuthAction<T> {
  final Map<String, dynamic> updates;
  final String? id;
  final bool notifiable;

  const UpdateAccountAction({
    required this.updates,
    this.id,
    this.notifiable = true,
  });

  @override
  Future<void> execute(BuildContext context) async {
    context.updateAccount<T>(updates, notifiable: notifiable, id: id);
  }
}

class SignOutAction<T extends Auth> extends AuthAction<T> {
  const SignOutAction();

  @override
  Future<void> execute(BuildContext context) async {
    context.signOut<T>();
  }
}

// ---------------------------------------------------------------------------
// Guest
// ---------------------------------------------------------------------------

class SignInAnonymouslyAction<T extends Auth> extends AuthAction<T> {
  final String? id;
  final Object? args;
  final bool notifiable;
  final GuestAuthenticator? authenticator;

  const SignInAnonymouslyAction({
    this.id,
    this.args,
    this.notifiable = true,
    this.authenticator,
  });

  @override
  Future<void> execute(BuildContext context) async {
    context.signInAnonymously<T>(
      id: id,
      args: args,
      notifiable: notifiable,
      authenticator: authenticator,
    );
  }
}

// ---------------------------------------------------------------------------
// Email / Username credential auth
// ---------------------------------------------------------------------------

class SignInByEmailAction<T extends Auth> extends AuthAction<T> {
  final EmailAuthenticator authenticator;
  final String? id;
  final Object? args;
  final bool notifiable;

  const SignInByEmailAction({
    required this.authenticator,
    this.id,
    this.args,
    this.notifiable = true,
  });

  @override
  Future<void> execute(BuildContext context) async {
    context.signInByEmail<T>(authenticator,
        id: id, args: args, notifiable: notifiable);
  }
}

class SignUpByEmailAction<T extends Auth> extends AuthAction<T> {
  final EmailAuthenticator authenticator;
  final String? id;
  final Object? args;
  final bool notifiable;

  const SignUpByEmailAction({
    required this.authenticator,
    this.id,
    this.args,
    this.notifiable = true,
  });

  @override
  Future<void> execute(BuildContext context) async {
    context.signUpByEmail<T>(authenticator,
        id: id, args: args, notifiable: notifiable);
  }
}

class SignInByUsernameAction<T extends Auth> extends AuthAction<T> {
  final UsernameAuthenticator authenticator;
  final String? id;
  final Object? args;
  final bool notifiable;

  const SignInByUsernameAction({
    required this.authenticator,
    this.id,
    this.args,
    this.notifiable = true,
  });

  @override
  Future<void> execute(BuildContext context) async {
    context.signInByUsername<T>(authenticator,
        id: id, args: args, notifiable: notifiable);
  }
}

class SignUpByUsernameAction<T extends Auth> extends AuthAction<T> {
  final UsernameAuthenticator authenticator;
  final String? id;
  final Object? args;
  final bool notifiable;
  final SignByBiometricCallback? onBiometric;

  const SignUpByUsernameAction({
    required this.authenticator,
    this.id,
    this.args,
    this.notifiable = true,
    this.onBiometric,
  });

  @override
  Future<void> execute(BuildContext context) async {
    context.signUpByUsername<T>(
      authenticator,
      onBiometric: onBiometric,
      id: id,
      args: args,
      notifiable: notifiable,
    );
  }
}

// ---------------------------------------------------------------------------
// OTP
// ---------------------------------------------------------------------------

class VerifyPhoneByOtpAction<T extends Auth> extends AuthAction<T> {
  final OtpAuthenticator authenticator;

  const VerifyPhoneByOtpAction({required this.authenticator});

  @override
  Future<void> execute(BuildContext context) async {
    context.verifyPhoneByOtp<T>(authenticator);
  }
}

// ---------------------------------------------------------------------------
// OAuth — single reusable action, provider resolved by the context extension
// ---------------------------------------------------------------------------

typedef OAuthContextCall<T extends Auth> = void Function(
  BuildContext context, {
  required bool storeToken,
  String? id,
  Object? args,
  required bool notifiable,
  OAuthAuthenticator? authenticator,
});

class OAuthSignInAction<T extends Auth> extends AuthAction<T> {
  final OAuthContextCall<T> _contextCall;
  final OAuthAuthenticator? authenticator;
  final bool storeToken;
  final String? id;
  final Object? args;
  final bool notifiable;

  const OAuthSignInAction({
    required OAuthContextCall<T> contextCall,
    this.authenticator,
    this.storeToken = false,
    this.id,
    this.args,
    this.notifiable = true,
  }) : _contextCall = contextCall;

  @override
  Future<void> execute(BuildContext context) async {
    _contextCall(
      context,
      storeToken: storeToken,
      id: id,
      args: args,
      notifiable: notifiable,
      authenticator: authenticator,
    );
  }
}

// ---------------------------------------------------------------------------
// Shared exception type
// ---------------------------------------------------------------------------

class AuthActionException implements Exception {
  final String message;

  const AuthActionException(this.message);

  @override
  String toString() => 'AuthActionException: $message';
}
