import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_entity/entity.dart';

import '../enums/auth_status.dart';
import '../enums/provider.dart';
import '../models/auth.dart';
import '../models/credential.dart';
import '../models/exception.dart';
import '../utils/auth_response.dart';
import '../utils/authenticator.dart';
import '../utils/biometric_config.dart';
import '../utils/errors.dart';
import '../widgets/provider.dart';
import 'authorizer.dart';
import 'typedefs.dart';

extension AuthHelper on BuildContext {
  Authorizer<T> _i<T extends Auth>(
    String name, [
    List<String> updaters = const [],
  ]) {
    try {
      return findAuthorizer<T>(updaters);
    } catch (_) {
      throw AuthProviderException(
        "You should call like $name<${AuthProvider.type}>()",
      );
    }
  }

  AuthProvider<T>? findAuthProvider<T extends Auth>([
    List<String> updaters = const [],
  ]) {
    try {
      return AuthProvider.of<T>(this);
    } catch (_) {
      throw AuthProviderException(
        "You should call like findAuthProvider<${AuthProvider.type}>()",
      );
    }
  }

  Authorizer<T> findAuthorizer<T extends Auth>([
    List<String> updaters = const [],
  ]) {
    try {
      return AuthProvider.authorizerOf<T>(this);
    } catch (_) {
      throw AuthProviderException(
        "You should call like findAuthorizer<${AuthProvider.type}>()",
      );
    }
  }

  Future<T?> auth<T extends Auth>() => _i<T>("auth").auth;

  String errorText<T extends Auth>() => _i<T>("error").errorText;

  Future<bool> isBiometricEnabled<T extends Auth>() {
    return _i<T>("isBiometricEnabled").isBiometricEnabled;
  }

  Future<bool> isLoggedIn<T extends Auth>() {
    return _i<T>("isLoggedIn").isLoggedIn;
  }

  ValueNotifier<String> liveError<T extends Auth>() {
    return _i<T>("liveError").liveError;
  }

  ValueNotifier<bool> liveLoading<T extends Auth>() {
    return _i<T>("liveLoading").liveLoading;
  }

  ValueNotifier<String> liveMessage<T extends Auth>() {
    return _i<T>("liveMessage").liveMessage;
  }

  ValueNotifier<AuthStatus> liveStatus<T extends Auth>() {
    return _i<T>("liveStatus").liveStatus;
  }

  ValueNotifier<T?> liveUser<T extends Auth>() {
    return _i<T>("liveUser").liveUser;
  }

  bool authLoading<T extends Auth>() => _i<T>("authLoading").loading;

  String authMessage<T extends Auth>() => _i<T>("authMessage").message;

  AuthStatus authStatus<T extends Auth>() => _i<T>("authStatus").status;

  T? user<T extends Auth>() => _i<T>("user").user;

  Future<Response<void>> addBiometric<T extends Auth>({
    SignByBiometricCallback? callback,
    BiometricConfig? config,
  }) {
    return _i<T>("addBiometric").addBiometric(
      callback: callback,
      config: config,
    );
  }

  Future<Response<void>> biometricEnable<T extends Auth>(bool enabled) {
    return _i<T>("biometricEnable").biometricEnable(enabled);
  }

  Future<AuthResponse<T>> deleteAccount<T extends Auth>({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("deleteAccount").delete(
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  void disposeAuthController<T extends Auth>() {
    return _i<T>("disposeAuthController").dispose();
  }

  Future<AuthResponse<T>> emitAuthResponse<T extends Auth>(
    AuthResponse<T> data, {
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("emitAuthResponse").emit(
      data,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<T?> initializeAuth<T extends Auth>([bool initialCheck = true]) {
    return _i<T>("initializeAuth").initialize(initialCheck);
  }

  Future<AuthResponse<T>> isSignIn<T extends Auth>({
    Provider? provider,
  }) {
    return _i<T>("isSignIn").isSignIn(provider: provider);
  }

  Future<AuthResponse<T>> signInAnonymously<T extends Auth>({
    GuestAuthenticator? authenticator,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInAnonymously").signInAnonymously(
      authenticator: authenticator,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInByBiometric<T extends Auth>({
    BiometricConfig? config,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInByBiometric").signInByBiometric(
      config: config,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInByEmail<T extends Auth>(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInByEmail").signInByEmail(
      authenticator,
      onBiometric: onBiometric,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInByPhone<T extends Auth>(
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
  }) {
    return _i<T>("signInByPhone").signInByPhone(
      authenticator,
      multiFactorInfo: multiFactorInfo,
      multiFactorSession: multiFactorSession,
      timeout: timeout,
      onComplete: onComplete,
      onFailed: onFailed,
      onCodeSent: onCodeSent,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInByOtp<T extends Auth>(
    OtpAuthenticator authenticator, {
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInByOtp").signInByOtp(
      authenticator,
      storeToken: storeToken,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInByUsername<T extends Auth>(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInByUsername").signInByUsername(
      authenticator,
      onBiometric: onBiometric,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signUpByEmail<T extends Auth>(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signUpByEmail").signUpByEmail(
      authenticator,
      onBiometric: onBiometric,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signUpByUsername<T extends Auth>(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signUpByUsername").signUpByUsername(
      authenticator,
      onBiometric: onBiometric,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signOut<T extends Auth>({
    Provider? provider,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signOut").signOut(
      provider: provider,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<T?> updateAccount<T extends Auth>(
    Map<String, dynamic> data, {
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("updateAccount").update(
      data,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse> verifyPhoneByOtp<T extends Auth>(
    OtpAuthenticator authenticator,
  ) {
    return _i<T>("verifyPhoneByOtp").verifyPhoneByOtp(authenticator);
  }

  Future<AuthResponse<T>> signInWithApple<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInWithApple").signInWithApple(
      authenticator: authenticator,
      storeToken: storeToken,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithFacebook<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInWithFacebook").signInWithFacebook(
      authenticator: authenticator,
      storeToken: storeToken,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithGameCenter<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInWithGameCenter").signInWithGameCenter(
      authenticator: authenticator,
      storeToken: storeToken,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithGithub<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInWithGithub").signInWithGithub(
      authenticator: authenticator,
      storeToken: storeToken,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithGoogle<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInWithGoogle").signInWithGoogle(
      authenticator: authenticator,
      storeToken: storeToken,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithMicrosoft<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInWithMicrosoft").signInWithMicrosoft(
      authenticator: authenticator,
      storeToken: storeToken,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithPlayGames<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInWithPlayGames").signInWithPlayGames(
      authenticator: authenticator,
      storeToken: storeToken,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithSAML<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInWithSAML").signInWithSAML(
      authenticator: authenticator,
      storeToken: storeToken,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithTwitter<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInWithTwitter").signInWithTwitter(
      authenticator: authenticator,
      storeToken: storeToken,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithYahoo<T extends Auth>({
    OAuthAuthenticator? authenticator,
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _i<T>("signInWithYahoo").signInWithYahoo(
      authenticator: authenticator,
      storeToken: storeToken,
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }
}

extension AuthLoadingExtension<T extends Auth> on Future<AuthResponse<T>> {
  Future<AuthResponse<T>> onAuthLoading(
    void Function(bool loading) callback,
  ) async {
    callback(true);
    final data = await this;
    callback(false);
    return data;
  }
}
