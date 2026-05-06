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
import '../models/messages.dart';
import '../models/provider.dart';
import '../utils/auth_changes.dart';
import '../widgets/provider.dart';

part '_backup.dart';

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
typedef OnAuthChanges<T extends Auth> = void Function(
    BuildContext context, AuthChanges<T> changes);

typedef _OAuthSignIn = Future<Response<Credential>> Function();

class Authorizer<T extends Auth> {
  final AuthMessages msg;
  final AuthDelegate delegate;
  late final _Backup<T> _backup;

  final _errorNotifier = ValueNotifier('');
  final _loadingNotifier = ValueNotifier(false);
  final _messageNotifier = ValueNotifier('');
  final _userNotifier = ValueNotifier<T?>(null);
  final _statusNotifier = ValueNotifier(AuthStatus.unauthenticated);

  Object? _args;
  String? _id;
  StreamSubscription? _subscription;
  bool _disposed = false;
  bool _initializing = false;
  bool _backupEmitEnabled = true;

  Object? get args => _args;

  String? get id => _id;

  Future<T?> get _auth => _backup.cache;

  bool get hasAnonymous => delegate.isAnonymous;

  Authorizer({
    required this.delegate,
    required AuthBackupDelegate<T> backup,
    this.msg = const AuthMessages(),
  }) {
    _backup = _Backup<T>(backup, _emitFromBackup);
  }

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

  static Authorizer? _i;

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

  // --------------------------------------------------------------------------
  // Public state
  // --------------------------------------------------------------------------

  Future<T?> get auth async {
    try {
      final value = await _auth;
      if (value == null || !value.isLoggedIn) return null;
      return value;
    } catch (_) {
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

  // --------------------------------------------------------------------------
  // Biometric
  // --------------------------------------------------------------------------

  Future<Response<T>> _checkBiometricEligibility() async {
    final auth = await _auth;
    final provider = Provider.from(auth?.provider);
    if (auth == null || !auth.isLoggedIn || !provider.isAllowBiometric) {
      return Response(
        status: Status.notSupported,
        error: 'User not logged in with email or username!',
      );
    }
    return Response(status: Status.ok, data: auth);
  }

  Future<Response<T>> get canUseBiometric async {
    try {
      return await _checkBiometricEligibility();
    } catch (error) {
      return Response(status: Status.failure, error: error.toString());
    }
  }

  Future<Response<T>> biometricEnable(bool enabled) async {
    try {
      final eligibility = await _checkBiometricEligibility();
      if (!eligibility.isSuccessful) return eligibility;
      final auth = eligibility.data!;
      if (enabled) {
        final response = await delegate.signInWithBiometric();
        if (!response.isSuccessful) {
          return Response(status: response.status, error: response.error);
        }
      }
      final value = await _update(
        id: auth.id,
        updateMode: true,
        data: {AuthKeys.i.biometric: enabled},
      );
      return Response(status: Status.ok, data: value);
    } catch (error) {
      return Response(status: Status.failure, error: error.toString());
    }
  }

  // --------------------------------------------------------------------------
  // Lifecycle
  // --------------------------------------------------------------------------

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    _errorNotifier.dispose();
    _loadingNotifier.dispose();
    _messageNotifier.dispose();
    _statusNotifier.dispose();
    _userNotifier.dispose();
  }

  Future<void> initialize({
    bool initialCheck = true,
    bool listening = false,
  }) async {
    if (_disposed || _initializing) return;
    _initializing = true;

    try {
      final cached = await _backup.cache;
      if (_disposed) return;

      final isCachedLoggedIn = cached != null && cached.isLoggedIn;
      if (initialCheck && isCachedLoggedIn) {
        _statusNotifier.value = AuthStatus.authenticated;
        _emitUser(cached);
      }

      final rawUid = await delegate.rawUid;
      if (_disposed) return;

      if (rawUid == null || rawUid.isEmpty) {
        if (isCachedLoggedIn) await _clearLocal();
        if (_disposed) return;
        _emitUser(null);
        _statusNotifier.value = AuthStatus.unauthenticated;
        return;
      }

      final remote = await _backup.onFetchUser(rawUid);
      if (_disposed) return;

      if (remote != null) {
        if (remote.isLoggedIn) {
          await _backup.setAsLocal(remote);
          if (_disposed) return;
          _statusNotifier.value = AuthStatus.authenticated;
          _emitUser(remote);
        } else {
          await _clearLocal();
          if (_disposed) return;
          _emitUser(null);
          _statusNotifier.value = AuthStatus.unauthenticated;
        }
      }

      if (listening) {
        await _subscription?.cancel();
        if (_disposed) return;
        _subscription = _backup.onListenUser(rawUid).listen(
          (remote) async {
            if (_disposed) return;
            if (remote != null && remote.isLoggedIn) {
              await _backup.setAsLocal(remote);
              if (_disposed) return;
              _statusNotifier.value = AuthStatus.authenticated;
              _emitUser(remote);
            } else {
              await _clearLocal();
              if (_disposed) return;
              _emitUser(null);
              _statusNotifier.value = AuthStatus.unauthenticated;
            }
          },
          onError: (e) {
            if (!_disposed) _errorNotifier.value = e.toString();
          },
        );
      }
    } finally {
      _initializing = false;
    }
  }

  // --------------------------------------------------------------------------
  // Emission
  // --------------------------------------------------------------------------

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
        if (data.data != null) {
          _emitUser(data.data);
        } else if (data.status == AuthStatus.unauthenticated) {
          _emitUser(null);
        }
      }
    } else {
      if (!data.isLoading && data.data != null) _emitUser(data.data);
    }

    return data;
  }

  void _emitFromBackup(AuthResponse<T> data) {
    if (_disposed || !_backupEmitEnabled) return;

    if (data.isLoading) {
      _emitLoading(true);
      return;
    }
    _emitLoading(false);
    if (data.hasStatus) {
      _emitStatus(data);
      if (data.status == AuthStatus.unauthenticated) {
        _emitUser(null);
        return;
      }
    }

    if (data.data != null) _emitUser(data.data);
  }

  void _emitError(AuthResponse<T> data) {
    if (data.isError) _errorNotifier.value = data.error;
  }

  void _emitLoading(bool data) {
    if (loading != data) _loadingNotifier.value = data;
  }

  void _emitMessage(AuthResponse<T> data) {
    if (data.isMessage) _messageNotifier.value = data.message;
  }

  void _emitStatus(AuthResponse<T> data) {
    _statusNotifier.value = data.status;
  }

  T? _emitUser(T? data) {
    if (_disposed) return data;
    _userNotifier.value = data;
    return data;
  }

  // --------------------------------------------------------------------------
  // Sign-in status check
  // --------------------------------------------------------------------------

  Future<AuthResponse<T>> isSignIn({Provider? provider}) async {
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
        msg.loggedIn.failure ?? error.toString(),
        provider: provider,
        type: AuthType.signedIn,
      );
    }
  }

  // --------------------------------------------------------------------------
  // Account deletion
  // --------------------------------------------------------------------------

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
        AuthResponse.data(
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
          AuthResponse.data(
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

      await _clearLocal();
      await _backup.onDeleteUser(data.id);
      await delegate.signOut();

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
        AuthResponse.data(
          data,
          msg: msg.delete.failure ?? error.toString(),
          provider: Provider.none,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<bool> _clearLocal() async {
    try {
      return await _backup.clear();
    } catch (error) {
      if (!_disposed) _errorNotifier.value = error.toString();
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // Anonymous sign-in
  // --------------------------------------------------------------------------

  Future<AuthResponse<T>> signInAnonymously({
    GuestAuthenticator? authenticator,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(Provider.guest, AuthType.none),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final response = await delegate.signInAnonymously();
      if (!response.isSuccessful) {
        return _failure(
          response.error,
          provider: Provider.guest,
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
          provider: Provider.guest,
          type: AuthType.none,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final value = await _update(
        id: uid,
        data: {
          AuthKeys.i.id: uid,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.provider: Provider.guest.id,
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
      return _failure(
        msg.signInWithEmail.failure ?? error.toString(),
        provider: Provider.guest,
        type: AuthType.none,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  // --------------------------------------------------------------------------
  // Biometric sign-in
  // --------------------------------------------------------------------------

  Future<AuthResponse<T>> signInByBiometric({
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(Provider.biometric, AuthType.biometric),
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
        return _failure(
          response.error,
          provider: Provider.biometric,
          type: AuthType.biometric,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final provider = Provider.from(user.provider);
      var current = Response<Credential>();

      if ((user.email ?? user.username ?? '').isNotEmpty &&
          (user.password ?? '').isNotEmpty) {
        if (provider.isEmail) {
          current = await delegate.signInWithEmailNPassword(
            user.email ?? '',
            user.password ?? '',
          );
        } else if (provider.isUsername) {
          current = await delegate.signInWithUsernameNPassword(
            user.username ?? '',
            user.password ?? '',
          );
        }
      }

      if (!current.isSuccessful) {
        return _failure(
          current.error,
          provider: Provider.biometric,
          type: AuthType.biometric,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final value = await _update(
        id: user.id,
        data: {
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
        },
      );

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
      return _failure(
        msg.signInWithBiometric.failure ?? error.toString(),
        provider: Provider.biometric,
        type: AuthType.biometric,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  // --------------------------------------------------------------------------
  // Email / Username sign-in & sign-up
  // --------------------------------------------------------------------------

  Future<AuthResponse<T>> signInByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback<T>? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithEmailOrUsername(
      provider: Provider.email,
      type: AuthType.login,
      doneMsg: msg.signInWithEmail.done,
      failureMsg: msg.signInWithEmail.failure,
      authenticator: authenticator,
      onBiometric: onBiometric,
      signIn: () => delegate.signInWithEmailNPassword(
        authenticator.email,
        authenticator.password,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback<T>? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithEmailOrUsername(
      provider: Provider.username,
      type: AuthType.login,
      doneMsg: msg.signInWithUsername.done,
      failureMsg: msg.signInWithUsername.failure,
      authenticator: authenticator,
      onBiometric: onBiometric,
      signIn: () => delegate.signInWithUsernameNPassword(
        authenticator.username,
        authenticator.password,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signUpByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback<T>? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithEmailOrUsername(
      provider: Provider.email,
      type: AuthType.register,
      doneMsg: msg.signUpWithEmail.done,
      failureMsg: msg.signUpWithEmail.failure,
      authenticator: authenticator,
      onBiometric: onBiometric,
      isSignUp: true,
      signIn: () => delegate.signUpWithEmailNPassword(
        authenticator.email,
        authenticator.password,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signUpByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback<T>? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithEmailOrUsername(
      provider: Provider.username,
      type: AuthType.register,
      doneMsg: msg.signUpWithUsername.done,
      failureMsg: msg.signUpWithUsername.failure,
      authenticator: authenticator,
      onBiometric: onBiometric,
      isSignUp: true,
      signIn: () => delegate.signUpWithUsernameNPassword(
        authenticator.username,
        authenticator.password,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> _signInWithEmailOrUsername({
    required Provider provider,
    required AuthType type,
    required String? doneMsg,
    required String? failureMsg,
    required Authenticator authenticator,
    required _OAuthSignIn signIn,
    SignByBiometricCallback<T>? onBiometric,
    bool isSignUp = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      AuthResponse.loading(provider, type),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final hasAnonymous = this.hasAnonymous;
      final response = await signIn();
      if (!response.isSuccessful) {
        return _failure(
          response.error,
          provider: provider,
          type: type,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = response.data;
      final uid = result?.uid ?? '';
      if (result == null || uid.isEmpty) {
        return _failure(
          msg.authorization,
          provider: provider,
          type: type,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final value = await _update(
        id: uid,
        hasAnonymous: hasAnonymous,
        onBiometric: onBiometric,
        updateMode: !isSignUp,
        data: {
          AuthKeys.i.id: uid,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.provider: provider.id,
          if (authenticator is EmailAuthenticator) ...{
            AuthKeys.i.email: authenticator.email,
          } else if (authenticator is UsernameAuthenticator) ...{
            AuthKeys.i.username: authenticator.username,
          },
          AuthKeys.i.password: _passwordOf(authenticator),
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: doneMsg,
          provider: provider,
          type: type,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return _failure(
        failureMsg ?? error.toString(),
        provider: provider,
        type: type,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  // --------------------------------------------------------------------------
  // Phone / OTP
  // --------------------------------------------------------------------------

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
        forceResendingToken: int.tryParse(authenticator.resendToken ?? ''),
        multiFactorInfo: multiFactorInfo,
        multiFactorSession: multiFactorSession,
        timeout: timeout,
        onComplete: (credential) async {
          if (onComplete != null) {
            emit(
              const AuthResponse.message(
                'Verification done!',
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
              await signInByOtp(
                OtpAuthenticator.phone(
                  token: verId,
                  code: code,
                  phone: authenticator.phone,
                ),
                args: args,
                id: id,
                notifiable: notifiable,
              );
            } else {
              emit(
                const AuthResponse.failure(
                  'Verification token or otp code not valid!',
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
              'Code sent to your device!',
              provider: Provider.phone,
              type: AuthType.otp,
            ),
            args: args,
            id: id,
            notifiable: notifiable,
          );
          onCodeSent?.call(verId, forceResendingToken);
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
          onFailed?.call(exception);
        },
        onCodeAutoRetrievalTimeout: (String verId) {
          emit(
            const AuthResponse.failure(
              'Auto retrieval code timeout!',
              provider: Provider.phone,
              type: AuthType.otp,
            ),
            args: args,
            id: id,
            notifiable: notifiable,
          );
          onCodeAutoRetrievalTimeout?.call(verId);
        },
      );
      return emit(
        const AuthResponse.loading(Provider.phone, AuthType.otp),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return _failure(
        msg.signOut.failure ?? error.toString(),
        provider: Provider.phone,
        type: AuthType.otp,
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
          smsCode: authenticator.code,
          verificationId: authenticator.token,
        ),
      );

      final response = await delegate.signInWithCredential(credential);
      if (!response.isSuccessful) {
        return _failure(
          response.error,
          provider: Provider.phone,
          type: AuthType.phone,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = response.data;
      final uid = result?.uid ?? '';
      if (result == null || uid.isEmpty) {
        return _failure(
          msg.authorization,
          provider: Provider.phone,
          type: AuthType.phone,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final value = await _update(
        id: uid,
        hasAnonymous: hasAnonymous,
        data: {
          AuthKeys.i.id: uid,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.provider: Provider.phone.id,
          AuthKeys.i.phone: authenticator.value,
          AuthKeys.i.verified: true,
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
      return _failure(
        msg.signInWithPhone.failure ?? error.toString(),
        provider: Provider.phone,
        type: AuthType.phone,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> verifyPhoneByOtp(
    OtpAuthenticator authenticator,
  ) async {
    try {
      final credential = delegate.credential(
        Provider.phone,
        Credential(
          smsCode: authenticator.code,
          verificationId: authenticator.token,
        ),
      );

      final response = await delegate.signInWithCredential(credential);
      if (!response.isSuccessful) {
        return AuthResponse.failure(
          response.error.isEmpty ? msg.authorization : response.error,
          provider: Provider.phone,
          type: AuthType.phone,
        );
      }

      final result = response.data;
      final uid = result?.uid ?? '';
      if (result == null || uid.isEmpty) {
        return AuthResponse.failure(
          msg.authorization,
          provider: Provider.phone,
          type: AuthType.phone,
        );
      }

      final source = {
        AuthKeys.i.id: uid,
        AuthKeys.i.loggedIn: true,
        AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
        AuthKeys.i.provider: Provider.phone.id,
        AuthKeys.i.phone: result.phoneNumber,
        AuthKeys.i.verified: true,
      };

      return AuthResponse<T>.authenticated(
        _backup.build(source),
        msg: msg.signInWithPhone.done,
        provider: Provider.phone,
        type: AuthType.phone,
      );
    } catch (error) {
      return AuthResponse.failure(
        msg.signInWithPhone.failure ?? error.toString(),
        provider: Provider.phone,
        type: AuthType.phone,
      );
    }
  }

  // --------------------------------------------------------------------------
  // OAuth
  // --------------------------------------------------------------------------

  Future<AuthResponse<T>> signInWithApple({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: Provider.apple,
      doneMsg: msg.signInWithApple.done,
      failureMsg: msg.signInWithApple.failure,
      signIn: () => delegate.signInWithApple(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithFacebook({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: Provider.facebook,
      doneMsg: msg.signInWithFacebook.done,
      failureMsg: msg.signInWithFacebook.failure,
      signIn: () => delegate.signInWithFacebook(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithGameCenter({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: Provider.gameCenter,
      doneMsg: msg.signInWithGameCenter.done,
      failureMsg: msg.signInWithGameCenter.failure,
      signIn: () => delegate.signInWithGameCenter(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithGithub({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: Provider.github,
      doneMsg: msg.signInWithGithub.done,
      failureMsg: msg.signInWithGithub.failure,
      signIn: () => delegate.signInWithGithub(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithGoogle({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: Provider.google,
      doneMsg: msg.signInWithGoogle.done,
      failureMsg: msg.signInWithGoogle.failure,
      signIn: () => delegate.signInWithGoogle(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithMicrosoft({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: Provider.microsoft,
      doneMsg: msg.signInWithMicrosoft.done,
      failureMsg: msg.signInWithMicrosoft.failure,
      signIn: () => delegate.signInWithMicrosoft(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithPlayGames({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: Provider.playGames,
      doneMsg: msg.signInWithPlayGames.done,
      failureMsg: msg.signInWithPlayGames.failure,
      signIn: () => delegate.signInWithPlayGames(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithSAML({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: Provider.saml,
      doneMsg: msg.signInWithSAML.done,
      failureMsg: msg.signInWithSAML.failure,
      signIn: () => delegate.signInWithSAML(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithTwitter({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: Provider.twitter,
      doneMsg: msg.signInWithTwitter.done,
      failureMsg: msg.signInWithTwitter.failure,
      signIn: () => delegate.signInWithTwitter(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithYahoo({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: Provider.yahoo,
      doneMsg: msg.signInWithYahoo.done,
      failureMsg: msg.signInWithYahoo.failure,
      signIn: () => delegate.signInWithYahoo(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> _signInWithOAuth({
    required Provider provider,
    required String? doneMsg,
    required String? failureMsg,
    required _OAuthSignIn signIn,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      AuthResponse.loading(provider, AuthType.oauth),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final hasAnonymous = this.hasAnonymous;
      final response = await signIn();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return _failure(
          response.error,
          provider: provider,
          type: AuthType.oauth,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final current = await delegate.signInWithCredential(raw.credential!);
      if (!current.isSuccessful) {
        return _failure(
          current.error,
          provider: provider,
          type: AuthType.oauth,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = current.data;
      final uid = result?.uid ?? '';
      if (result == null || uid.isEmpty) {
        return _failure(
          msg.authorization,
          provider: provider,
          type: AuthType.oauth,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final email = result.email ?? '';
      final name = result.displayName ?? '';
      final photo = result.photoURL ?? '';

      final value = await _update(
        id: uid,
        hasAnonymous: hasAnonymous,
        data: {
          AuthKeys.i.id: uid,
          AuthKeys.i.loggedIn: true,
          AuthKeys.i.loggedInTime: EntityHelper.generateTimeMills,
          AuthKeys.i.provider: provider.id,
          AuthKeys.i.verified: true,
          if (email.isNotEmpty) AuthKeys.i.email: email,
          if (name.isNotEmpty) AuthKeys.i.name: name,
          if (photo.isNotEmpty) AuthKeys.i.photo: photo,
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: doneMsg,
          provider: provider,
          type: AuthType.oauth,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return _failure(
        failureMsg ?? error.toString(),
        provider: provider,
        type: AuthType.oauth,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  // --------------------------------------------------------------------------
  // Sign out
  // --------------------------------------------------------------------------

  Future<AuthResponse<T>> signOut({
    Provider? provider,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    try {
      provider ??= (await _auth)?.provider;
      emit(
        AuthResponse.loading(provider, AuthType.logout),
        args: args,
        id: id,
        notifiable: notifiable,
      );

      final response = await delegate.signOut(provider);
      if (!response.isSuccessful) {
        return _failure(
          response.error,
          provider: provider,
          type: AuthType.logout,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      _backupEmitEnabled = false;
      try {
        await _clearLocal();
      } finally {
        _backupEmitEnabled = true;
      }

      return emit(
        AuthResponse.unauthenticated(
          msg: msg.signOut.done,
          provider: provider,
          type: AuthType.logout,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      _backupEmitEnabled = true;
      return _failure(
        msg.signOut.failure ?? error.toString(),
        provider: provider,
        type: AuthType.logout,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  // --------------------------------------------------------------------------
  // Update / persistence
  // --------------------------------------------------------------------------

  Future<T?> update(
    Map<String, dynamic> data, {
    String? id,
    bool notifiable = true,
  }) async {
    try {
      final prevBackupEmit = _backupEmitEnabled;
      _backupEmitEnabled = notifiable;
      final ok = await _backup.update(data);
      _backupEmitEnabled = prevBackupEmit;
      if (!ok) return null;
      return _userNotifier.value;
    } catch (error) {
      if (!_disposed) _errorNotifier.value = error.toString();
      return null;
    }
  }

  Future<T?> _update({
    required String id,
    Map<String, dynamic> data = const {},
    bool updateMode = false,
    bool hasAnonymous = false,
    SignByBiometricCallback<T>? onBiometric,
  }) async {
    try {
      var finalData = data;
      if (onBiometric != null) {
        final biometric = await onBiometric(
          _backup.build({...?user?.source, ...data}),
        );
        finalData = {...data, AuthKeys.i.biometric: biometric};
      }

      final saved = await _backup.save(
        id: id,
        data: finalData.map((k, v) => MapEntry(k, _backup.encryptor(k, v))),
        cacheUpdateMode: updateMode,
        hasAnonymous: hasAnonymous,
      );

      if (!saved) return user;

      final updated =
          await _auth ?? _backup.build({...?user?.source, ...finalData});
      if (updated != _userNotifier.value) _emitUser(updated);
      return updated;
    } catch (error) {
      if (!_disposed) _errorNotifier.value = error.toString();
      return null;
    }
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  static String? _passwordOf(Authenticator authenticator) =>
      switch (authenticator) {
        EmailAuthenticator(:final password) => password,
        UsernameAuthenticator(:final password) => password,
        _ => null,
      };

  Future<AuthResponse<T>> _failure(
    Object? msgOrError, {
    required Provider? provider,
    required AuthType type,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return emit(
      AuthResponse.failure(
        msgOrError?.toString() ?? 'An unexpected error occurred.',
        provider: provider,
        type: type,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }
}
