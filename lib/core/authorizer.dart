import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_entity/entity.dart';

import '../delegates/backup.dart';
import '../delegates/delegate.dart';
import '../exceptions/exception.dart';
import '../models/auth.dart';
import '../models/auth_response.dart';
import '../models/auth_status.dart';
import '../models/auth_type.dart';
import '../models/authenticator.dart';
import '../models/credential.dart';
import '../models/key.dart' show AuthKeys;
import '../models/messages.dart';
import '../widgets/provider.dart';

part '_auth_biometric_mixin.dart';
part '_auth_email_mixin.dart';
part '_auth_emit_mixin.dart';
part '_auth_lifecycle_mixin.dart';
part '_auth_oauth_mixin.dart';
part '_auth_phone_mixin.dart';
part '_auth_signout_mixin.dart';
part '_auth_state_mixin.dart';
part '_auth_update_mixin.dart';
part '_authorizer_base.dart';
part '_auth_backup.dart';

typedef OnAuthMode = void Function(BuildContext context);
typedef OnAuthError = void Function(BuildContext context, String error);
typedef OnAuthMessage = void Function(BuildContext context, String message);
typedef OnAuthLoading = void Function(BuildContext context, bool loading);
typedef OnAuthStatus = void Function(BuildContext context, AuthStatus status);
typedef IdentityBuilder = String Function(String uid);
typedef SignByBiometricCallback<T extends Auth> = Future<bool?>? Function(
    T? auth);
typedef SignOutCallback = Future Function(Auth authorizer);
typedef UndoAccountCallback = Future<bool> Function(Auth authorizer);
typedef _OAuthSignIn = Future<Response<Credential>> Function();

class Authorizer<T extends Auth> extends _AuthorizerBase<T>
    with
        _AuthEmitMixin<T>,
        _AuthStateMixin<T>,
        _AuthLifecycleMixin<T>,
        _AuthUpdateMixin<T>,
        _AuthBiometricMixin<T>,
        _AuthEmailMixin<T>,
        _AuthPhoneMixin<T>,
        _AuthOAuthMixin<T>,
        _AuthSignOutMixin<T> {
  Authorizer({
    required super.delegate,
    required super.backup,
    super.msg,
  });

  static Authorizer? _i;

  factory Authorizer.of(BuildContext context) {
    try {
      return AuthProvider.authorizerOf<T>(context);
    } catch (e) {
      throw AuthProviderException(
        'No Authorizer<${AuthProvider.type}> found. '
        'Ensure AuthProvider<${AuthProvider.type}> wraps the widget tree. (cause: $e)',
      );
    }
  }

  static Authorizer<T> instanceOf<T extends Auth>() {
    if (_i == null) {
      throw AuthProviderException(
        'Authorizer has not been initialised. '
        'Call Authorizer.init<T>() or attach an instance first.',
      );
    }
    if (_i is! Authorizer<T>) {
      throw AuthProviderException(
        'Type mismatch: expected Authorizer<T> '
        'but the attached instance is ${_i.runtimeType}.',
      );
    }
    return _i as Authorizer<T>;
  }

  static Future<void> init<T extends Auth>({
    required AuthDelegate delegate,
    required AuthBackupDelegate<T> backup,
    AuthMessages msg = const AuthMessages(),
    bool initialCheck = true,
    bool listening = false,
  }) async {
    _i = Authorizer<T>(delegate: delegate, backup: backup, msg: msg);
    await _i!.initialize(initialCheck: initialCheck, listening: listening);
  }

  static void attach<T extends Auth>(Authorizer<T> authorizer) {
    _i = authorizer;
  }

  static void detach<T extends Auth>() {
    final current = _i;
    _i = null;
    if (current != null) {
      try {
        current.dispose();
      } catch (_) {}
    }
  }

  Future<AuthResponse<T>> isSignIn() async {
    try {
      final signedIn = await delegate.isSignIn();
      final data = signedIn ? await auth : null;
      if (data == null) {
        if (signedIn) await delegate.signOut();
        return AuthResponse.unauthenticated(type: AuthType.signedIn);
      }
      return AuthResponse.authenticated(data, type: AuthType.signedIn);
    } catch (error) {
      return AuthResponse.failure(
        msg.loggedIn.failure ?? error.toString(),
        type: AuthType.signedIn,
      );
    }
  }

  Future<AuthResponse<T>> signInAnonymously({
    GuestAuthenticator? authenticator,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(AuthType.none),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final response = await delegate.signInAnonymously();
      if (!response.isSuccessful) {
        return _failure(
          response.error,
          type: AuthType.none,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = response.data;
      final uid = result?.uid;
      if (result == null || uid == null || uid.isEmpty) {
        return _failure(
          msg.authorization,
          type: AuthType.none,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final value = await _update(
        id: uid,
        data: {
          keys.id: uid,
          keys.loggedIn: true,
          keys.loggedInTime: EntityHelper.generateTimeMills,
          keys.provider: 'GUEST',
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithEmail.done,
          type: AuthType.none,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return _failure(
        msg.signInWithEmail.failure ?? error.toString(),
        type: AuthType.none,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }
}
