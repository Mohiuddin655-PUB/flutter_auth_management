import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_entity/entity.dart';
import 'package:object_modifier/object_modifier.dart';

import 'auth.dart';
import 'auth_changes.dart';
import 'auth_provider.dart';
import 'auth_response.dart';
import 'auth_status.dart';
import 'auth_type.dart';
import 'authenticator.dart';
import 'backup.dart';
import 'credential.dart';
import 'delegate.dart';
import 'exception.dart';
import 'messages.dart';
import 'provider.dart';

part '_backup.dart';

typedef OnAuthMode = void Function(BuildContext context);
typedef OnAuthError = void Function(BuildContext context, String error);
typedef OnAuthMessage = void Function(BuildContext context, String message);
typedef OnAuthLoading = void Function(BuildContext context, bool loading);
typedef OnAuthStatus = void Function(BuildContext context, AuthStatus status);
typedef IdentityBuilder = String Function(String uid);
typedef SignByBiometricCallback<T extends Auth> = Future<bool?>? Function(
  T? auth,
);
typedef SignOutCallback = Future Function(Auth authorizer);
typedef UndoAccountCallback = Future<bool> Function(Auth authorizer);
typedef OnAuthChanges<T extends Auth> = void Function(
  BuildContext context,
  AuthChanges<T> changes,
);

class Authorizer<T extends Auth> {
  final AuthMessages msg;
  final AuthDelegate delegate;
  final _Backup<T> _backup;

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

  bool get hasAnonymous => delegate.isAnonymous;

  Authorizer({
    required this.delegate,
    required AuthBackupDelegate<T> backup,
    this.msg = const AuthMessages(),
  }) : _backup = _Backup<T>(backup);

  factory Authorizer.of(BuildContext context) {
    try {
      return AuthProvider.authorizerOf<T>(context);
    } catch (e) {
      throw AuthProviderException(
        "You should call like Authorizer.of<${AuthProvider.type}>(context);",
      );
    }
  }

  static Type? type;

  static Authorizer? _i;

  static Authorizer<T> instanceOf<T extends Auth>() {
    if (_i == null) {
      throw AuthProviderException(
        "You should initialize Authorizer before calling Authorizer.instanceOf<$T>();",
      );
    }
    if (_i is! Authorizer<T>) {
      throw AuthProviderException(
        "You should call like Authorizer.instanceOf<${Authorizer.type}>();",
      );
    }
    return _i as Authorizer<T>;
  }

  static Future<void> init<T extends Auth>({
    required AuthDelegate delegate,
    required AuthBackupDelegate<T> backup,
    AuthMessages msg = const AuthMessages(),
    bool initialCheck = true,
  }) async {
    type = T;
    final auth = Authorizer<T>(delegate: delegate, backup: backup, msg: msg);
    _i = auth;
    await auth.initialize(initialCheck);
  }

  static void attach<T extends Auth>(Authorizer<T> authorizer) {
    type = T;
    _i = authorizer;
  }

  static void dettach<T extends Auth>() {
    try {
      _i?.dispose();
      _i = null;
    } catch (_) {}
  }

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

  Future<Response<T>> get canUseBiometric async {
    try {
      final auth = await _auth;
      final provider = Provider.from(auth?.provider);
      if (auth == null || !auth.isLoggedIn || !provider.isAllowBiometric) {
        return Response(
          status: Status.notSupported,
          error: "User not logged in with email or username!",
        );
      }
      return Response(status: Status.ok, data: auth);
    } catch (error) {
      return Response(status: Status.failure, error: error.toString());
    }
  }

  Future<Response<T>> biometricEnable(bool enabled) async {
    try {
      final auth = await _auth;
      final provider = Provider.from(auth?.provider);
      if (auth == null || !auth.isLoggedIn || !provider.isAllowBiometric) {
        return Response(
          status: Status.notSupported,
          error: "User not logged in with email or username!",
        );
      }

      if (enabled) {
        final response = await delegate.signInWithBiometric();
        if (!response.isSuccessful) {
          return Response(status: response.status, error: response.error);
        }
      }

      final value = await _update(
        id: auth.id,
        updateMode: true,
        updates: {AuthKeys.i.biometric: enabled},
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
          msg: msg.loggedIn.failure,
          provider: Provider.none,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }

    try {
      final response = await delegate.delete();
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
          msg: msg.delete.done,
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
          msg: msg.delete.failure ?? error,
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
      final signedIn = await delegate.isSignIn(provider);
      final data = signedIn ? await auth : null;
      if (data == null) {
        if (signedIn) await delegate.signOut(provider);
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
        msg.loggedIn.failure ?? error,
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

      final response = await delegate.signInAnonymously();
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
            msg.authorization,
            provider: Provider.guest,
            type: AuthType.none,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final user = (authenticator ?? Authenticator.guest()).update(
        id: Modifier(result.uid),
        email: Modifier(result.email),
        name: Modifier(result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(result.photoURL),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
      );
      final value = await _update(
        id: user.id,
        initials: user.filtered,
        updates: {
          if (authenticator?.extra != null) ...authenticator!.extra!,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator?.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.guest.id,
          AuthKeys.i.username: authenticator?.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );
      return emit(
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithEmail.done,
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
          msg.signInWithEmail.failure ?? error,
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
            msg: msg.signInWithBiometric.failure ?? errorText,
            provider: Provider.biometric,
            type: AuthType.biometric,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final response = await delegate.signInWithBiometric();
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
          current = await delegate.signInWithEmailNPassword(
            user.email ?? "",
            user.password ?? "",
          );
        } else if (provider.isUsername) {
          current = await delegate.signInWithUsernameNPassword(
            user.username ?? "",
            user.password ?? "",
          );
        }
      } else if ((token ?? user.idToken ?? "").isNotEmpty) {
        current = await delegate.signInWithCredential(Credential(
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
        AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
      });

      return emit(
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithBiometric.done,
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
          msg.signInWithBiometric.failure ?? error,
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
    SignByBiometricCallback<T>? onBiometric,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithEmailNPassword(
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
            msg.authorization,
            provider: Provider.email,
            type: AuthType.login,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final user = authenticator.update(
        id: Modifier(result.uid),
        email: Modifier(result.email),
        name: Modifier(result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(result.photoURL),
        provider: Modifier(Provider.email),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
      );

      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        onBiometric: onBiometric,
        initials: user.filtered,
        updates: {
          if (authenticator.extra != null) ...authenticator.extra!,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.email.id,
          AuthKeys.i.username: authenticator.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithEmail.done,
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
          msg.signInWithEmail.failure ?? error,
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
      delegate.verifyPhoneNumber(
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
          msg.signOut.failure ?? error,
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
      final hasAnonymous = this.hasAnonymous;
      final credential = delegate.credential(
        Provider.phone,
        Credential(
          smsCode: authenticator.smsCode,
          verificationId: authenticator.verificationId,
        ),
      );

      final response = await delegate.signInWithCredential(credential);

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
            msg.authorization,
            provider: Provider.phone,
            type: AuthType.phone,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final user = authenticator.update(
        id: Modifier(result.uid),
        accessToken:
            storeToken ? Modifier(result.accessToken) : Modifier.nullable(),
        idToken: storeToken ? Modifier(result.idToken) : Modifier.nullable(),
        email: Modifier(result.email),
        name: Modifier(result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(result.photoURL),
        provider: Modifier(Provider.phone),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );

      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        initials: user.filtered,
        updates: {
          if (authenticator.extra != null) ...authenticator.extra!,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.phone.id,
          AuthKeys.i.username: authenticator.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithPhone.done,
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
          msg.signInWithPhone.failure ?? error,
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
    Object? args,
    String? id,
    SignByBiometricCallback<T>? onBiometric,
    bool notifiable = true,
  }) async {
    emit(
      args: args,
      id: id,
      notifiable: notifiable,
      const AuthResponse.loading(Provider.username, AuthType.login),
    );

    try {
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithUsernameNPassword(
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

      final user = authenticator.update(
        id: Modifier(result.uid),
        email: Modifier(result.email),
        name: Modifier(result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(result.photoURL),
        provider: Modifier(Provider.username),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
      );

      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        onBiometric: onBiometric,
        initials: user.filtered,
        updates: {
          if (authenticator.extra != null) ...authenticator.extra!,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.username.id,
          AuthKeys.i.username: authenticator.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );
      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithUsername.done,
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
          msg.signInWithUsername.failure ?? error,
          provider: Provider.username,
          type: AuthType.login,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signUpByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback<T>? onBiometric,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signUpWithEmailNPassword(
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
            msg.authorization,
            provider: Provider.email,
            type: AuthType.register,
          ),
        );
      }

      final creationTime = EntityHelper.generateTimeMills;
      final user = authenticator.update(
        id: Modifier(result.uid),
        email: Modifier(result.email),
        name: Modifier(result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(result.photoURL),
        provider: Modifier(Provider.email),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(creationTime),
        timeMills: Modifier(creationTime),
      );

      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        onBiometric: onBiometric,
        initials: user.filtered,
        updates: {
          if (authenticator.extra != null) ...authenticator.extra!,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.email.id,
          AuthKeys.i.username: authenticator.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signUpWithEmail.done,
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
          msg.signUpWithEmail.failure ?? error,
          provider: Provider.email,
          type: AuthType.register,
        ),
      );
    }
  }

  Future<AuthResponse<T>> signUpByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback<T>? onBiometric,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signUpWithUsernameNPassword(
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
            msg.authorization,
            provider: Provider.username,
            type: AuthType.register,
          ),
        );
      }

      final creationTime = EntityHelper.generateTimeMills;
      final user = authenticator.update(
        id: Modifier(result.uid),
        email: Modifier(result.email),
        name: Modifier(result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(result.photoURL),
        provider: Modifier(Provider.username),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(creationTime),
        timeMills: Modifier(creationTime),
      );

      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        onBiometric: onBiometric,
        initials: user.filtered,
        updates: {
          if (authenticator.extra != null) ...authenticator.extra!,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.username.id,
          AuthKeys.i.username: authenticator.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signUpWithUsername.done,
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
          msg.signUpWithUsername.failure ?? error,
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
      final response = await delegate.signOut(provider);
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
            msg: msg.signOut.done,
            provider: provider,
            type: AuthType.logout,
          ),
        );
      }

      await update({
        AuthKeys.i.loggedIn: false,
        AuthKeys.i.loggedOutTime: EntityHelper.generateTimeMills,
      });

      if (data.isBiometric) {
        await _update(
          hasAnonymous: false,
          id: data.id,
          updates: {
            ...data.extra ?? {},
            AuthKeys.i.loggedIn: false,
            AuthKeys.i.loggedOutTime: EntityHelper.generateTimeMills,
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
          msg: msg.signOut.done,
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
          msg.signOut.failure ?? error,
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
    bool hasAnonymous = false,
    SignByBiometricCallback<T>? onBiometric,
  }) async {
    try {
      if (onBiometric != null) {
        final biometric = await onBiometric(
          _backup.build({...user?.source ?? {}, ...initials, ...updates}),
        );
        initials = {...initials, AuthKeys.i.biometric: biometric};
        updates = {...updates, AuthKeys.i.biometric: biometric};
      }
      await _backup.save(
        id: id,
        initials: initials.map((k, v) => MapEntry(k, _backup.encryptor(k, v))),
        cacheUpdateMode: updateMode,
        updates: updates.map((k, v) => MapEntry(k, _backup.encryptor(k, v))),
        hasAnonymous: hasAnonymous,
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
      final credential = delegate.credential(
        Provider.phone,
        Credential(
          smsCode: authenticator.smsCode,
          verificationId: authenticator.verificationId,
        ),
      );

      final response = await delegate.signInWithCredential(credential);
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
          msg.authorization,
          provider: Provider.phone,
          type: AuthType.phone,
        );
      }

      final user = authenticator.update(
        id: Modifier(result.uid),
        accessToken: Modifier(result.accessToken),
        idToken: Modifier(result.idToken),
        email: Modifier(result.email),
        name: Modifier(result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(result.photoURL),
        provider: Modifier(Provider.phone),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );

      return AuthResponse.authenticated(
        user,
        msg: msg.signInWithPhone.done,
        provider: Provider.phone,
        type: AuthType.phone,
      );
    } catch (error) {
      return AuthResponse.failure(
        msg.signInWithPhone.failure ?? error,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithApple();
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

      final current = await delegate.signInWithCredential(raw.credential!);

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
            msg.authorization,
            provider: Provider.apple,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).update(
        id: Modifier(result.uid),
        accessToken:
            storeToken ? Modifier(raw.accessToken) : Modifier.nullable(),
        idToken: storeToken ? Modifier(raw.idToken) : Modifier.nullable(),
        email: Modifier(raw.email ?? result.email),
        name: Modifier(raw.displayName ?? result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(raw.photoURL ?? result.photoURL),
        provider: Modifier(Provider.apple),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );
      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        initials: user.filtered,
        updates: {
          ...authenticator?.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator?.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.apple.id,
          AuthKeys.i.username: authenticator?.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithApple.done,
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
          msg.signInWithApple.failure ?? error,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithFacebook();
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

      final current = await delegate.signInWithCredential(raw.credential!);

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
            msg.authorization,
            provider: Provider.facebook,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).update(
        id: Modifier(result.uid),
        accessToken:
            storeToken ? Modifier(raw.accessToken) : Modifier.nullable(),
        idToken: storeToken ? Modifier(raw.idToken) : Modifier.nullable(),
        email: Modifier(raw.email ?? result.email),
        name: Modifier(raw.displayName ?? result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(raw.photoURL ?? result.photoURL),
        provider: Modifier(Provider.facebook),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );
      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        initials: user.filtered,
        updates: {
          ...authenticator?.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator?.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.facebook.id,
          AuthKeys.i.username: authenticator?.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithFacebook.done,
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
          msg.signInWithFacebook.failure ?? error,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithGameCenter();
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

      final current = await delegate.signInWithCredential(raw.credential!);

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
            msg.authorization,
            provider: Provider.gameCenter,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).update(
        id: Modifier(result.uid),
        accessToken:
            storeToken ? Modifier(raw.accessToken) : Modifier.nullable(),
        idToken: storeToken ? Modifier(raw.idToken) : Modifier.nullable(),
        email: Modifier(raw.email ?? result.email),
        name: Modifier(raw.displayName ?? result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(raw.photoURL ?? result.photoURL),
        provider: Modifier(Provider.gameCenter),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );
      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        initials: user.filtered,
        updates: {
          ...authenticator?.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator?.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.gameCenter.id,
          AuthKeys.i.username: authenticator?.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
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
          msg.signInWithGithub.failure ?? error,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithGithub();
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

      final current = await delegate.signInWithCredential(raw.credential!);
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
            msg.authorization,
            provider: Provider.github,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).update(
        id: Modifier(result.uid),
        accessToken:
            storeToken ? Modifier(raw.accessToken) : Modifier.nullable(),
        idToken: storeToken ? Modifier(raw.idToken) : Modifier.nullable(),
        email: Modifier(raw.email ?? result.email),
        name: Modifier(raw.displayName ?? result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(raw.photoURL ?? result.photoURL),
        provider: Modifier(Provider.github),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );
      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        initials: user.filtered,
        updates: {
          ...authenticator?.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator?.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.github.id,
          AuthKeys.i.username: authenticator?.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
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
          msg.signInWithGithub.failure ?? error,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithGoogle();
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

      final current = await delegate.signInWithCredential(raw.credential!);
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
            msg.authorization,
            provider: Provider.google,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).update(
        id: Modifier(result.uid),
        accessToken:
            storeToken ? Modifier(raw.accessToken) : Modifier.nullable(),
        idToken: storeToken ? Modifier(raw.idToken) : Modifier.nullable(),
        email: Modifier(raw.email ?? result.email),
        name: Modifier(raw.displayName ?? result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(raw.photoURL ?? result.photoURL),
        provider: Modifier(Provider.google),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );
      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        initials: user.filtered,
        updates: {
          ...authenticator?.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator?.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.google.id,
          AuthKeys.i.username: authenticator?.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGoogle.done,
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
          msg.signInWithGoogle.failure ?? error,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithMicrosoft();
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

      final current = await delegate.signInWithCredential(raw.credential!);
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
            msg.authorization,
            provider: Provider.microsoft,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).update(
        id: Modifier(result.uid),
        accessToken:
            storeToken ? Modifier(raw.accessToken) : Modifier.nullable(),
        idToken: storeToken ? Modifier(raw.idToken) : Modifier.nullable(),
        email: Modifier(raw.email ?? result.email),
        name: Modifier(raw.displayName ?? result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(raw.photoURL ?? result.photoURL),
        provider: Modifier(Provider.microsoft),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );
      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        initials: user.filtered,
        updates: {
          ...authenticator?.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator?.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.microsoft.id,
          AuthKeys.i.username: authenticator?.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
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
          msg.signInWithGithub.failure ?? error,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithPlayGames();
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

      final current = await delegate.signInWithCredential(raw.credential!);
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
            msg.authorization,
            provider: Provider.playGames,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).update(
        id: Modifier(result.uid),
        accessToken:
            storeToken ? Modifier(raw.accessToken) : Modifier.nullable(),
        idToken: storeToken ? Modifier(raw.idToken) : Modifier.nullable(),
        email: Modifier(raw.email ?? result.email),
        name: Modifier(raw.displayName ?? result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(raw.photoURL ?? result.photoURL),
        provider: Modifier(Provider.playGames),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );

      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        initials: user.filtered,
        updates: {
          ...authenticator?.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator?.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.playGames.id,
          AuthKeys.i.username: authenticator?.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
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
          msg.signInWithGithub.failure ?? error,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithSAML();
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

      final current = await delegate.signInWithCredential(raw.credential!);
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
            msg.authorization,
            provider: Provider.saml,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).update(
        id: Modifier(result.uid),
        accessToken:
            storeToken ? Modifier(raw.accessToken) : Modifier.nullable(),
        idToken: storeToken ? Modifier(raw.idToken) : Modifier.nullable(),
        email: Modifier(raw.email ?? result.email),
        name: Modifier(raw.displayName ?? result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(raw.photoURL ?? result.photoURL),
        provider: Modifier(Provider.saml),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );

      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        initials: user.filtered,
        updates: {
          ...authenticator?.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator?.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.saml.id,
          AuthKeys.i.username: authenticator?.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
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
          msg.signInWithGithub.failure ?? error,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithTwitter();
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

      final current = await delegate.signInWithCredential(raw.credential!);
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
            msg.authorization,
            provider: Provider.twitter,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).update(
        id: Modifier(result.uid),
        accessToken:
            storeToken ? Modifier(raw.accessToken) : Modifier.nullable(),
        idToken: storeToken ? Modifier(raw.idToken) : Modifier.nullable(),
        email: Modifier(raw.email ?? result.email),
        name: Modifier(raw.displayName ?? result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(raw.photoURL ?? result.photoURL),
        provider: Modifier(Provider.twitter),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );

      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        initials: user.filtered,
        updates: {
          ...authenticator?.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator?.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.twitter.id,
          AuthKeys.i.username: authenticator?.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
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
          msg.signInWithGithub.failure ?? error,
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
      final hasAnonymous = this.hasAnonymous;
      final response = await delegate.signInWithYahoo();
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

      final current = await delegate.signInWithCredential(raw.credential!);
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
            msg.authorization,
            provider: Provider.yahoo,
            type: AuthType.oauth,
          ),
        );
      }

      final user = (authenticator ?? Authenticator.oauth()).update(
        id: Modifier(result.uid),
        accessToken:
            storeToken ? Modifier(raw.accessToken) : Modifier.nullable(),
        idToken: storeToken ? Modifier(raw.idToken) : Modifier.nullable(),
        email: Modifier(raw.email ?? result.email),
        name: Modifier(raw.displayName ?? result.displayName),
        phone: Modifier(result.phoneNumber),
        photo: Modifier(raw.photoURL ?? result.photoURL),
        provider: Modifier(Provider.yahoo),
        loggedIn: Modifier(true),
        loggedInTime: Modifier(EntityHelper.generateTimeMills),
        verified: Modifier(true),
      );
      final value = await _update(
        id: user.id,
        hasAnonymous: hasAnonymous,
        initials: user.filtered,
        updates: {
          ...authenticator?.extra ?? {},
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.anonymous: result.isAnonymous,
          AuthKeys.i.email: result.email,
          AuthKeys.i.name: result.displayName,
          AuthKeys.i.password: authenticator?.password,
          AuthKeys.i.phone: result.phoneNumber,
          AuthKeys.i.photo: result.photoURL,
          AuthKeys.i.provider: Provider.yahoo.id,
          AuthKeys.i.username: authenticator?.username,
          AuthKeys.i.verified: result.emailVerified,
        },
      );

      return emit(
        args: args,
        id: id,
        notifiable: notifiable,
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithGithub.done,
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
          msg.signInWithGithub.failure ?? error,
          provider: Provider.yahoo,
          type: AuthType.oauth,
        ),
      );
    }
  }
}
