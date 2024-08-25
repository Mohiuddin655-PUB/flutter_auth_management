import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_entity/flutter_entity.dart';

import '../../core/messages.dart';
import '../../core/typedefs.dart';
import '../../data/controllers/controller.dart';
import '../../delegates/backup.dart';
import '../../delegates/oauth.dart';
import '../../models/auth.dart';
import '../../models/auth_providers.dart';
import '../../models/auth_state.dart';
import '../../models/biometric_config.dart';
import '../../utils/auth_notifier.dart';
import '../../utils/auth_response.dart';
import '../../utils/authenticator_email.dart';
import '../../utils/authenticator_guest.dart';
import '../../utils/authenticator_oauth.dart';
import '../../utils/authenticator_otp.dart';
import '../../utils/authenticator_phone.dart';
import '../../utils/authenticator_username.dart';

abstract class AuthController<T extends Auth> {
  static AuthController? _i;

  static AuthController<T> getInstance<T extends Auth>({
    OAuthDelegates? oauth,
    BackupDelegate<T>? backup,
    AuthMessages? messages,
  }) {
    if (_i is AuthController<T>) {
      return _i as AuthController<T>;
    } else {
      _i = AuthControllerImpl<T>(
        auth: oauth,
        backup: backup,
        messages: messages,
      );
      return _i as AuthController<T>;
    }
  }

  Object? get args;

  Future<T?> get auth;

  String get errorText;

  Future<bool> get isBiometricEnabled;

  Future<bool> get isLoggedIn;

  AuthNotifier<String> get liveError;

  AuthNotifier<bool> get liveLoading;

  AuthNotifier<String> get liveMessage;

  AuthNotifier<AuthState> get liveState;

  AuthNotifier<T?> get liveUser;

  bool get loading;

  String get message;

  AuthState get state;

  T? get user;

  User? get firebaseUser;

  Stream<User?> get firebaseAuthChanges;

  Stream<User?> get firebaseIdTokenChanges;

  Stream<User?> get firebaseUserChanges;

  Future<Response<bool>> addBiometric({
    SignByBiometricCallback? callback,
    BiometricConfig? config,
  });

  Future<Response<bool>> biometricEnable(bool enabled);

  Future<AuthResponse<T>> delete({
    Object? args,
    bool notifiable = true,
  });

  void dispose();

  Future<AuthResponse<T>> emit(
    AuthResponse<T> data, {
    Object? args,
    bool notifiable = true,
  });

  Future<T?> initialize([
    bool initialCheck = true,
  ]);

  Future<AuthResponse<T>> isSignIn({
    AuthProviders? provider,
  });

  Future<AuthResponse<T>> signInAnonymously({
    GuestAuthenticator? authenticator,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInByBiometric({
    BiometricConfig? config,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInByPhone(
    PhoneAuthenticator authenticator, {
    PhoneMultiFactorInfo? multiFactorInfo,
    MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(minutes: 2),
    void Function(PhoneAuthCredential credential)? onComplete,
    void Function(FirebaseAuthException exception)? onFailed,
    void Function(String verId, int? forceResendingToken)? onCodeSent,
    void Function(String verId)? onCodeAutoRetrievalTimeout,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInByOtp(
    OtpAuthenticator authenticator, {
    bool storeToken = false,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signUpByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signUpByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signOut({
    AuthProviders? provider,
    Object? args,
    bool notifiable = true,
  });

  Future<T?> update(
    Map<String, dynamic> data, {
    bool notifiable = true,
  });

  Future<AuthResponse> verifyPhoneByOtp(OtpAuthenticator authenticator);

  // OAUTH
  Future<AuthResponse<T>> signInWithApple({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInWithFacebook({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInWithGameCenter({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInWithGithub({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInWithGoogle({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInWithMicrosoft({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInWithPlayGames({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInWithSAML({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInWithTwitter({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    bool notifiable = true,
  });

  Future<AuthResponse<T>> signInWithYahoo({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    bool notifiable = true,
  });
}
