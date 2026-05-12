import 'dart:async' show StreamSubscription, Completer;

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_entity/entity.dart' show EntityHelper, Response, Status;

import '../delegates/backup.dart' show AuthBackupDelegate;
import '../delegates/delegate.dart' show AuthDelegate;
import '../exceptions/exception.dart' show AuthException;
import '../models/auth.dart' show Auth;
import '../models/auth_response.dart' show AuthResponse;
import '../models/auth_status.dart' show AuthStatus;
import '../models/auth_type.dart' show AuthType;
import '../models/authenticator.dart'
    show
        Authenticator,
        EmailAuthenticator,
        GuestAuthenticator,
        OtpAuthenticator,
        PhoneAuthenticator,
        UsernameAuthenticator;
import '../models/credential.dart' show Credential;
import '../models/key.dart' show AuthKeys;
import '../models/messages.dart' show AuthMessages;

part '_auth_backup.dart';
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
  Authorizer({required super.delegate, required super.backup, super.msg});

  static Authorizer? _i;

  static Future<void>? _ioLock;

  static Authorizer<T> instanceOf<T extends Auth>() {
    final current = _i;
    if (current == null) {
      throw AuthException(
        'Authorizer has not been initialised. '
        'Call Authorizer.init<T>() or attach an instance first.',
      );
    }
    if (current.isDisposed) {
      throw AuthException(
        'Authorizer has been disposed. Re-initialise before use.',
      );
    }
    if (current is! Authorizer<T>) {
      throw AuthException(
        'Type mismatch: expected Authorizer<$T> but the attached instance '
        'is ${current.runtimeType}.',
      );
    }
    return current;
  }

  static Future<void> init<T extends Auth>({
    required AuthDelegate delegate,
    required AuthBackupDelegate<T> backup,
    AuthMessages msg = const AuthMessages(),
    bool initialCheck = true,
    bool listening = false,
  }) async {
    while (_ioLock != null) {
      await _ioLock;
    }
    final completer = Completer<void>();
    _ioLock = completer.future;
    try {
      final prev = _i;
      if (prev != null) {
        try {
          prev.dispose();
        } catch (_) {}
      }
      final created = Authorizer<T>(
        delegate: delegate,
        backup: backup,
        msg: msg,
      );
      _i = created;
      await created.initialize(
        initialCheck: initialCheck,
        listening: listening,
      );
    } finally {
      completer.complete();
      if (_ioLock == completer.future) _ioLock = null;
    }
  }

  static void attach<T extends Auth>(Authorizer<T> authorizer) {
    final prev = _i;
    if (prev != null && !identical(prev, authorizer)) {
      try {
        prev.dispose();
      } catch (_) {}
    }
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
        if (signedIn) {
          try {
            await delegate.signOut();
          } catch (_) {}
        }
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

    final opToken = _beginOp();

    try {
      final response = await delegate.signInAnonymously();

      if (!_isOpAlive(opToken)) {
        return AuthResponse.failure('Cancelled', type: AuthType.none);
      }

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

      if (!_isOpAlive(opToken)) {
        return AuthResponse.failure('Cancelled', type: AuthType.none);
      }

      if (value == null) {
        return _failure(
          msg.authorization,
          type: AuthType.none,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

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
