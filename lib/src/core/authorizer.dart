import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_entity/entity.dart';

import '../delegates/auth.dart';
import '../delegates/backup.dart';
import '../enums/auth_status.dart';
import '../enums/auth_type.dart';
import '../enums/biometric_status.dart';
import '../enums/provider.dart';
import '../models/auth.dart';
import '../models/credential.dart';
import '../models/exception.dart';
import '../models/messages.dart';
import '../utils/auth_response.dart';
import '../utils/authenticator.dart';
import '../utils/biometric_config.dart';
import 'typedefs.dart';

part 'backup.dart';

class Authorizer<T extends Auth> {
  final AuthMessages _msg;
  final AuthDelegate _delegate;
  final _BackupRepository<T> _backup;

  final _errorNotifier = ValueNotifier("");
  final _loadingNotifier = ValueNotifier(false);
  final _messageNotifier = ValueNotifier("");
  final _userNotifier = ValueNotifier<T?>(null);
  final _statusNotifier = ValueNotifier(AuthStatus.unauthenticated);

  Object? _args;

  String? _id;

  Object? get args => _args;

  String? get id => _id;

  Future<T?> get _auth => _backup.cache;

  Authorizer({
    required AuthDelegate delegate,
    required AuthBackupDelegate<T> backup,
    AuthMessages msg = const AuthMessages(),
  })  : _msg = msg,
        _delegate = delegate,
        _backup = _BackupRepository<T>(backup);

  Future<T?> get auth async {
    try {
      final value = await _auth;
      if (value == null || !value.isLoggedIn) return null;
      return value;
    } catch (error) {
      return null;
    }
  }

  String get errorText => _errorNotifier.value;

  Future<bool> get isBiometricEnabled async {
    try {
      final value = await _auth;
      return value != null && value.isBiometric;
    } catch (error) {
      _errorNotifier.value = error.toString();
      return false;
    }
  }

  Future<bool> get isLoggedIn async {
    final value = await auth;
    return value != null && value.isLoggedIn;
  }

  ValueNotifier<String> get liveError => _errorNotifier;

  ValueNotifier<bool> get liveLoading => _loadingNotifier;

  ValueNotifier<String> get liveMessage => _messageNotifier;

  ValueNotifier<AuthStatus> get liveStatus => _statusNotifier;

  ValueNotifier<T?> get liveUser => _userNotifier;

  bool get loading => _loadingNotifier.value;

  String get message => _messageNotifier.value;

  AuthStatus get status => _statusNotifier.value;

  T? get user => _userNotifier.value;

  Future<Response<T>> addBiometric({
    SignByBiometricCallback? callback,
    BiometricConfig? config,
  }) async {
    try {
      final auth = await _auth;
      final provider = Provider.from(auth?.provider);
      if (auth == null || !auth.isLoggedIn || !provider.isAllowBiometric) {
        return Response(
          status: Status.notSupported,
          error: "User not logged in with email or username!",
        );
      }

      final response = await _delegate.signInWithBiometric(config);
      if (!response.isSuccessful) {
        return Response(status: response.status, error: response.error);
      }

      final biometric = callback != null
          ? await callback(auth.biometric)
          : BiometricStatus.activated;
      final value = await _update(
        id: auth.id,
        updateMode: true,
        updates: {
          AuthKeys.i.biometric: biometric?.name,
        },
      );

      return Response(status: Status.ok, data: value);
    } catch (error) {
      return Response(
        status: Status.failure,
        error: error.toString(),
      );
    }
  }

  Future<Response<T>> biometricEnable(bool enabled) async {
    final auth = await _auth;
    final provider = Provider.from(auth?.provider);
    final permission = auth != null &&
        auth.isLoggedIn &&
        !auth.biometric.isInitial &&
        provider.isAllowBiometric;

    if (!permission) {
      return Response(
        status: Status.undefined,
        error: "Biometric not initialized yet!",
      );
    }

    try {
      final activated = BiometricStatus.value(enabled);
      final value = await _update(
        id: auth.id,
        updateMode: true,
        updates: {
          AuthKeys.i.biometric: activated.name,
        },
      );

      return Response(status: Status.ok, data: value);
    } catch (error) {
      return Response(
        status: Status.failure,
        error: error.toString(),
      );
    }
  }

  Future<AuthResponse<T>> delete({
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(Provider.none, AuthType.delete),
      args: args,
      id: id,
      notifiable: notifiable,
    );
    final data = await auth;
    if (data == null) {
      return emit(
        AuthResponse.rollback(
          data,
          msg: _msg.loggedIn.failure,
          provider: Provider.none,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }

    try {
      final response = await _delegate.delete();
      if (!response.isSuccessful) {
        return emit(
          AuthResponse.rollback(
            data,
            msg: response.message,
            provider: Provider.none,
            type: AuthType.delete,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      await _delete();
      await _backup.onDeleteUser(data.id);

      return emit(
        AuthResponse.unauthenticated(
          msg: _msg.delete.done,
          provider: Provider.none,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.rollback(
          data,
          msg: _msg.delete.failure ?? error,
          provider: Provider.none,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<bool> _delete() async {
    try {
      final cleared = await _backup.clear();
      if (cleared) _emitUser(null);
      return cleared;
    } catch (error) {
      _errorNotifier.value = error.toString();
      return false;
    }
  }

  void dispose() {
    _errorNotifier.dispose();
    _loadingNotifier.dispose();
    _messageNotifier.dispose();
    _statusNotifier.dispose();
    _userNotifier.dispose();
  }

  Future<AuthResponse<T>> emit(
    AuthResponse<T> data, {
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    _args = args;
    _id = id;
    if (notifiable) {
      if (data.isLoading) {
        _emitLoading(true);
      } else {
        _emitLoading(false);
        _emitError(data);
        _emitMessage(data);
        _emitStatus(data);
        _emitUser(data.data);
      }
    } else {
      if (!data.isLoading) _emitUser(data.data);
    }

    return data;
  }

  void _emitError(AuthResponse<T> data) {
    if (data.isError) {
      _errorNotifier.value = data.error;
    }
  }

  void _emitLoading(bool data) {
    if (loading != data) {
      _loadingNotifier.value = data;
    }
  }

  void _emitMessage(AuthResponse<T> data) {
    if (data.isMessage) {
      _errorNotifier.value = data.error;
    }
  }

  void _emitStatus(AuthResponse<T> data) {
    _statusNotifier.value = data.status;
  }

  T? _emitUser(T? data) {
    if (data != null) _userNotifier.value = data;
    return _userNotifier.value;
  }

  Future<T?> initialize([bool initialCheck = true]) async {
    final value = await auth;
    if (value == null) return null;
    if (initialCheck) {
      if (value.isLoggedIn) {
        _statusNotifier.value = AuthStatus.authenticated;
      }
    }
    final remote = await _backup.onFetchUser(value.id);
    _userNotifier.value = remote;
    await _backup.setAsLocal(remote ?? value);
    return remote ?? value;
  }

  Future<AuthResponse<T>> isSignIn({
    Provider? provider,
  }) async {
    try {
      final signedIn = await _delegate.isSignIn(provider);
      final data = signedIn ? await auth : null;
      if (data == null) {
        if (signedIn) await _delegate.signOut(provider);
        return AuthResponse.unauthenticated(
          provider: provider,
          type: AuthType.signedIn,
        );
      }

      return AuthResponse.authenticated(
        data,
        provider: provider,
        type: AuthType.signedIn,
      );
    } catch (error) {
      return AuthResponse.failure(
        _msg.loggedIn.failure ?? error,
        provider: provider,
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
    try {
      emit(
        const AuthResponse.loading(Provider.email, AuthType.login),
        args: args,
        id: id,
        notifiable: notifiable,
      );

      final response = await _delegate.signInAnonymously();
      if (!response.isSuccessful) {
        return emit(
          AuthResponse.failure(
            response.error,
            provider: Provider.guest,
            type: AuthType.none,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = response.data;
      if (result == null) {
        return emit(
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.guest,
            type: AuthType.none,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final user = (authenticator ?? Authenticator.guest()).copy(
        id: result.uid,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );
      return emit(
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithEmail.done,
          provider: Provider.guest,
          type: AuthType.none,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.failure(
          _msg.signInWithEmail.failure ?? error,
          provider: Provider.guest,
          type: AuthType.none,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> signInByBiometric({
    BiometricConfig? config,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(
        Provider.biometric,
        AuthType.biometric,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final user = await _auth;
      if (user == null || !user.isBiometric) {
        return emit(
          AuthResponse.unauthorized(
            msg: _msg.signInWithBiometric.failure ?? errorText,
            provider: Provider.biometric,
            type: AuthType.biometric,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final response = await _delegate.signInWithBiometric(config);
      if (!response.isSuccessful) {
        return emit(
          AuthResponse.failure(
            response.error,
            provider: Provider.biometric,
            type: AuthType.biometric,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final token = user.accessToken;
      final provider = Provider.from(user.provider);
      var current = Response<Credential>();
      if ((user.email ?? user.username ?? "").isNotEmpty &&
          (user.password ?? '').isNotEmpty) {
        if (provider.isEmail) {
          current = await _delegate.signInWithEmailNPassword(
            user.email ?? "",
            user.password ?? "",
          );
        } else if (provider.isUsername) {
          current = await _delegate.signInWithUsernameNPassword(
            user.username ?? "",
            user.password ?? "",
          );
        }
      } else if ((token ?? user.idToken ?? "").isNotEmpty) {
        current = await _delegate.signInWithCredential(Credential(
          uid: user.id,
          providerId: provider.id,
          idToken: user.idToken,
          accessToken: token,
        ));
      }
      if (!current.isSuccessful) {
        return emit(
          AuthResponse.failure(
            current.error,
            provider: Provider.biometric,
            type: AuthType.biometric,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final value = await _update(id: user.id, updates: {
        AuthKeys.i.loggedIn: true,
        AuthKeys.i.loggedInTime: Entity.generateTimeMills,
      });

      return emit(
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithBiometric.done,
          provider: Provider.biometric,
          type: AuthType.biometric,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.failure(
          _msg.signInWithBiometric.failure ?? error,
          provider: Provider.biometric,
          type: AuthType.biometric,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> signInByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(Provider.email, AuthType.login),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final response = await _delegate.signInWithEmailNPassword(
        authenticator.email,
        authenticator.password,
      );
      if (!response.isSuccessful) {
        return emit(
          AuthResponse.failure(
            response.error,
            provider: Provider.email,
            type: AuthType.login,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = response.data;
      if (result == null) {
        return emit(
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.email,
            type: AuthType.login,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final user = authenticator.copy(
        id: result.uid,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: Provider.email,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
      );

      BiometricStatus? biometric;
      if (onBiometric != null) biometric = await onBiometric(user.biometric);

      final value = await _update(
        id: user.id,
        initials:
            (biometric != null ? user.copy(biometric: biometric) : user).source,
        updates: {
          ...user.extra ?? {},
          if (biometric != null) AuthKeys.i.biometric: biometric.id,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithEmail.done,
          provider: Provider.email,
          type: AuthType.login,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.failure(
          _msg.signInWithEmail.failure ?? error,
          provider: Provider.email,
          type: AuthType.login,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> signInByPhone(
    PhoneAuthenticator authenticator, {
    Object? multiFactorInfo,
    Object? multiFactorSession,
    Duration timeout = const Duration(minutes: 2),
    void Function(Credential credential)? onComplete,
    void Function(AuthException exception)? onFailed,
    void Function(String verId, int? forceResendingToken)? onCodeSent,
    void Function(String verId)? onCodeAutoRetrievalTimeout,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    try {
      _delegate.verifyPhoneNumber(
        phoneNumber: authenticator.phone,
        forceResendingToken: int.tryParse(authenticator.accessToken ?? ""),
        multiFactorInfo: multiFactorInfo,
        multiFactorSession: multiFactorSession,
        timeout: timeout,
        onComplete: (credential) async {
          if (onComplete != null) {
            emit(
              const AuthResponse.message(
                "Verification done!",
                provider: Provider.phone,
                type: AuthType.otp,
              ),
              args: args,
              id: id,
              notifiable: notifiable,
            );
            onComplete(credential);
          } else {
            final verId = credential.verificationId;
            final code = credential.smsCode;
            if (verId != null && code != null) {
              signInByOtp(
                authenticator.otp(
                  token: verId,
                  smsCode: code,
                ),
              );
            } else {
              emit(
                const AuthResponse.failure(
                  "Verification token or otp code not valid!",
                  provider: Provider.phone,
                  type: AuthType.otp,
                ),
                args: args,
                id: id,
                notifiable: notifiable,
              );
            }
          }
        },
        onCodeSent: (String verId, int? forceResendingToken) {
          emit(
            const AuthResponse.message(
              "Code sent to your device!",
              provider: Provider.phone,
              type: AuthType.otp,
            ),
            args: args,
            id: id,
            notifiable: notifiable,
          );
          if (onCodeSent != null) onCodeSent(verId, forceResendingToken);
        },
        onFailed: (exception) {
          emit(
            AuthResponse.failure(
              exception.msg,
              provider: Provider.phone,
              type: AuthType.otp,
            ),
            args: args,
            id: id,
            notifiable: notifiable,
          );
          if (onFailed != null) onFailed(exception);
        },
        onCodeAutoRetrievalTimeout: (String verId) {
          emit(
            const AuthResponse.failure(
              "Auto retrieval code timeout!",
              provider: Provider.phone,
              type: AuthType.otp,
            ),
            args: args,
            id: id,
            notifiable: notifiable,
          );
          if (onCodeAutoRetrievalTimeout != null) {
            onCodeAutoRetrievalTimeout(verId);
          }
        },
      );
      return emit(
        const AuthResponse.loading(
          Provider.phone,
          AuthType.otp,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.failure(
          _msg.signOut.failure ?? error,
          provider: Provider.phone,
          type: AuthType.otp,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> signInByOtp(
    OtpAuthenticator authenticator, {
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(Provider.phone, AuthType.phone),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final credential = _delegate.credential(
        Provider.phone,
        Credential(
          smsCode: authenticator.smsCode,
          verificationId: authenticator.token,
        ),
      );

      final response = await _delegate.signInWithCredential(credential);

      if (!response.isSuccessful) {
        return emit(
          AuthResponse.failure(
            response.error,
            provider: Provider.phone,
            type: AuthType.phone,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = response.data;
      if (result == null) {
        return emit(
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.phone,
            type: AuthType.phone,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final user = authenticator.copy(
        id: result.uid,
        accessToken: storeToken ? result.accessToken : null,
        idToken: storeToken ? result.idToken : null,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: Provider.phone,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );

      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithPhone.done,
          provider: Provider.phone,
          type: AuthType.phone,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return emit(
        AuthResponse.failure(
          _msg.signInWithPhone.failure ?? error,
          provider: Provider.phone,
          type: AuthType.phone,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> signInByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.username, AuthType.login),
    );

    try {
      final response = await _delegate.signInWithUsernameNPassword(
        authenticator.username,
        authenticator.password,
      );
      if (!response.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.username,
            type: AuthType.login,
          ),
        );
      }

      final result = response.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.username,
            type: AuthType.login,
          ),
        );
      }

      final user = authenticator.copy(
        id: result.uid,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: Provider.username,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
      );

      BiometricStatus? biometric;
      if (onBiometric != null) biometric = await onBiometric(user.biometric);

      final value = await _update(
        id: user.id,
        initials:
            (biometric != null ? user.copy(biometric: biometric) : user).source,
        updates: {
          ...user.extra ?? {},
          if (biometric != null) AuthKeys.i.biometric: biometric.id,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithUsername.done,
          provider: Provider.username,
          type: AuthType.login,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signInWithUsername.failure ?? error,
          provider: Provider.username,
          type: AuthType.login,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signUpByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.email, AuthType.register),
    );
    try {
      final response = await _delegate.signUpWithEmailNPassword(
        authenticator.email,
        authenticator.password,
      );
      if (!response.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.email,
            type: AuthType.register,
          ),
        );
      }

      final result = response.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.email,
            type: AuthType.register,
          ),
        );
      }

      final creationTime = Entity.generateTimeMills;
      final user = authenticator.copy(
        id: result.uid,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: Provider.email,
        loggedIn: true,
        loggedInTime: creationTime,
        timeMills: creationTime,
      );

      BiometricStatus? biometric;
      if (onBiometric != null) biometric = await onBiometric(user.biometric);

      final value = await _update(
        id: user.id,
        initials:
            (biometric != null ? user.copy(biometric: biometric) : user).source,
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signUpWithEmail.done,
          provider: Provider.email,
          type: AuthType.register,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signUpWithEmail.failure ?? error,
          provider: Provider.email,
          type: AuthType.register,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signUpByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.username, AuthType.register),
    );

    try {
      final response = await _delegate.signUpWithUsernameNPassword(
        authenticator.username,
        authenticator.password,
      );
      if (!response.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.username,
            type: AuthType.register,
          ),
        );
      }

      final result = response.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.username,
            type: AuthType.register,
          ),
        );
      }

      final creationTime = Entity.generateTimeMills;
      final user = authenticator.copy(
        id: result.uid,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: Provider.username,
        loggedIn: true,
        loggedInTime: creationTime,
        timeMills: creationTime,
      );

      BiometricStatus? biometric;
      if (onBiometric != null) biometric = await onBiometric(user.biometric);

      final value = await _update(
        id: user.id,
        initials:
            (biometric != null ? user.copy(biometric: biometric) : user).source,
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signUpWithUsername.done,
          provider: Provider.username,
          type: AuthType.register,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signUpWithUsername.failure ?? error,
          provider: Provider.username,
          type: AuthType.register,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signOut({
    Provider? provider,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    try {
      provider ??= (await _auth)?.provider;
      emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.loading(provider, AuthType.logout),
      );
      final response = await _delegate.signOut(provider);
      if (!response.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: provider,
            type: AuthType.logout,
          ),
        );
      }

      final data = await _auth;
      if (data == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.unauthenticated(
            msg: _msg.signOut.done,
            provider: provider,
            type: AuthType.logout,
          ),
        );
      }

      await update({
        AuthKeys.i.loggedIn: false,
        AuthKeys.i.loggedOutTime: Entity.generateTimeMills,
      });

      if (data.isBiometric) {
        await _update(
          id: data.id,
          updates: {
            ...data.extra ?? {},
            AuthKeys.i.loggedIn: false,
            AuthKeys.i.loggedOutTime: Entity.generateTimeMills,
          },
        );
      } else {
        await _delete();
      }

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.unauthenticated(
          msg: _msg.signOut.done,
          provider: provider,
          type: AuthType.logout,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signOut.failure ?? error,
          provider: provider,
          type: AuthType.logout,
        ),
      );
    }
  }

  Future<T?> update(
    Map<String, dynamic> data, {
    String? id,
    bool notifiable = true,
  }) async {
    try {
      await _backup.update(data);
      final updated = await auth;
      if (notifiable) _emitUser(updated);
      return updated;
    } catch (error) {
      _errorNotifier.value = error.toString();
      return null;
    }
  }

  Future<T?> _update({
    required String id,
    Map<String, dynamic> initials = const {},
    Map<String, dynamic> updates = const {},
    bool updateMode = false,
  }) async {
    try {
      await _backup.save(
        id: id,
        initials: initials,
        cacheUpdateMode: updateMode,
        updates: updates,
      );
      final updated = await _auth;
      _emitUser(updated);
      return updated;
    } catch (error) {
      _errorNotifier.value = error.toString();
      return null;
    }
  }

  Future<AuthResponse> verifyPhoneByOtp(OtpAuthenticator authenticator) async {
    try {
      final credential = _delegate.credential(
        Provider.phone,
        Credential(
          smsCode: authenticator.smsCode,
          verificationId: authenticator.token,
        ),
      );

      final response = await _delegate.signInWithCredential(credential);
      if (!response.isSuccessful) {
        return AuthResponse.failure(
          response.error,
          provider: Provider.phone,
          type: AuthType.phone,
        );
      }

      final result = response.data;
      if (result == null) {
        return AuthResponse.failure(
          _msg.authorization,
          provider: Provider.phone,
          type: AuthType.phone,
        );
      }

      final user = authenticator.copy(
        id: result.uid,
        accessToken: result.accessToken,
        idToken: result.idToken,
        email: result.email,
        name: result.displayName,
        phone: result.phoneNumber,
        photo: result.photoURL,
        provider: Provider.phone,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );

      return AuthResponse.authenticated(
        user,
        msg: _msg.signInWithPhone.done,
        provider: Provider.phone,
        type: AuthType.phone,
      );
    } catch (error) {
      return AuthResponse.failure(
        _msg.signInWithPhone.failure ?? error,
        provider: Provider.phone,
        type: AuthType.phone,
      );
    }
  }

  Future<AuthResponse<T>> signInWithApple({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.apple, AuthType.oauth),
    );

    try {
      final response = await _delegate.signInWithApple();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.apple,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await _delegate.signInWithCredential(raw.credential!);

      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: Provider.apple,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.apple,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.displayName ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photoURL ?? result.photoURL,
        provider: Provider.apple,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithApple.done,
          provider: Provider.apple,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signInWithApple.failure ?? error,
          provider: Provider.apple,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithFacebook({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.facebook, AuthType.oauth),
    );

    try {
      final response = await _delegate.signInWithFacebook();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.facebook,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await _delegate.signInWithCredential(raw.credential!);

      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: Provider.facebook,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.facebook,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.displayName ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photoURL ?? result.photoURL,
        provider: Provider.facebook,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithFacebook.done,
          provider: Provider.facebook,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signInWithFacebook.failure ?? error,
          provider: Provider.facebook,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithGameCenter({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(
        Provider.gameCenter,
        AuthType.oauth,
      ),
    );

    try {
      final response = await _delegate.signInWithGameCenter();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.gameCenter,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await _delegate.signInWithCredential(raw.credential!);

      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: Provider.gameCenter,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.gameCenter,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.displayName ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photoURL ?? result.photoURL,
        provider: Provider.gameCenter,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithGithub.done,
          provider: Provider.gameCenter,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signInWithGithub.failure ?? error,
          provider: Provider.gameCenter,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithGithub({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.github, AuthType.oauth),
    );

    try {
      final response = await _delegate.signInWithGithub();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.github,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await _delegate.signInWithCredential(raw.credential!);
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: Provider.github,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.github,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.displayName ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photoURL ?? result.photoURL,
        provider: Provider.github,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithGithub.done,
          provider: Provider.github,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signInWithGithub.failure ?? error,
          provider: Provider.github,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithGoogle({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.google, AuthType.oauth),
    );

    try {
      final response = await _delegate.signInWithGoogle();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.google,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await _delegate.signInWithCredential(raw.credential!);
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: Provider.google,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.google,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.displayName ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photoURL ?? result.photoURL,
        provider: Provider.google,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithGoogle.done,
          provider: Provider.google,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signInWithGoogle.failure ?? error,
          provider: Provider.google,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithMicrosoft({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.microsoft, AuthType.oauth),
    );

    try {
      final response = await _delegate.signInWithMicrosoft();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.microsoft,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await _delegate.signInWithCredential(raw.credential!);
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: Provider.microsoft,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.microsoft,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.displayName ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photoURL ?? result.photoURL,
        provider: Provider.microsoft,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithGithub.done,
          provider: Provider.microsoft,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signInWithGithub.failure ?? error,
          provider: Provider.microsoft,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithPlayGames({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.playGames, AuthType.oauth),
    );

    try {
      final response = await _delegate.signInWithPlayGames();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.playGames,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await _delegate.signInWithCredential(raw.credential!);
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: Provider.playGames,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.playGames,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.displayName ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photoURL ?? result.photoURL,
        provider: Provider.playGames,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );

      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithGithub.done,
          provider: Provider.playGames,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signInWithGithub.failure ?? error,
          provider: Provider.playGames,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithSAML({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.saml, AuthType.oauth),
    );

    try {
      final response = await _delegate.signInWithSAML();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.saml,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await _delegate.signInWithCredential(raw.credential!);
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: Provider.saml,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.saml,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.displayName ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photoURL ?? result.photoURL,
        provider: Provider.saml,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );

      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithGithub.done,
          provider: Provider.saml,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signInWithGithub.failure ?? error,
          provider: Provider.saml,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithTwitter({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.twitter, AuthType.oauth),
    );

    try {
      final response = await _delegate.signInWithTwitter();
      final raw = response.data;

      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.twitter,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await _delegate.signInWithCredential(raw.credential!);
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: Provider.twitter,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.twitter,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.displayName ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photoURL ?? result.photoURL,
        provider: Provider.twitter,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );

      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithGithub.done,
          provider: Provider.twitter,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signInWithGithub.failure ?? error,
          provider: Provider.twitter,
          type: AuthType.oauth,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signInWithYahoo({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.yahoo, AuthType.oauth),
    );

    try {
      final response = await _delegate.signInWithYahoo();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            response.error,
            provider: Provider.yahoo,
            type: AuthType.oauth,
          ),
        );
      }

      final current = await _delegate.signInWithCredential(raw.credential!);
      if (!current.isSuccessful) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            current.error,
            provider: Provider.yahoo,
            type: AuthType.oauth,
          ),
        );
      }

      final result = current.data;
      if (result == null) {
        return emit(
          args: args,
          id: id,
          notifiable: notifiable,
          AuthResponse.failure(
            _msg.authorization,
            provider: Provider.yahoo,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).copy(
        id: result.uid,
        accessToken: storeToken ? raw.accessToken : null,
        idToken: storeToken ? raw.idToken : null,
        email: raw.email ?? result.email,
        name: raw.displayName ?? result.displayName,
        phone: result.phoneNumber,
        photo: raw.photoURL ?? result.photoURL,
        provider: Provider.yahoo,
        loggedIn: true,
        loggedInTime: Entity.generateTimeMills,
        verified: true,
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          ...user.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: Entity.generateTimeMills,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: _msg.signInWithGithub.done,
          provider: Provider.yahoo,
          type: AuthType.oauth,
        ),
      );
    } catch (error) {
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.failure(
          _msg.signInWithGithub.failure ?? error,
          provider: Provider.yahoo,
          type: AuthType.oauth,
        ),
      );
    }
  }
}
