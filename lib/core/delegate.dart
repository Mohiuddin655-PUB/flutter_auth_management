import 'package:flutter_entity/entity.dart';

import 'credential.dart';
import 'exception.dart';
import 'provider.dart';

abstract class AuthDelegate {
  const AuthDelegate();

  bool get isAnonymous {
    throw UnimplementedError(
      "Getter isAnonymous is not yet implemented.",
    );
  }

  bool get isAuthenticated {
    throw UnimplementedError(
      "Getter isAuthenticated is not yet implemented.",
    );
  }

  /// Create the auth credential using a provided credential info.
  Object credential(Provider provider, Credential credential) {
    throw UnimplementedError(
      "Method createCredential() is not yet implemented.",
    );
  }

  /// Deletes the current user's credential.
  Future<Response<void>> delete() {
    throw UnimplementedError(
      "Method delete() is not yet implemented.",
    );
  }

  /// Checks if a user is currently signed in.
  Future<bool> isSignIn([Provider? provider]) {
    throw UnimplementedError(
      "Method isSignIn() is not yet implemented.",
    );
  }

  /// Signs in the user anonymously.
  Future<Response<Credential>> signInAnonymously() {
    throw UnimplementedError(
      "Method signInAnonymously() is not yet implemented.",
    );
  }

  /// Signs in the user using biometric authentication.
  Future<Response<void>> signInWithBiometric() {
    throw UnimplementedError(
      "Method signInWithBiometric() is not yet implemented.",
    );
  }

  /// Signs in the user using a provided credential.
  Future<Response<Credential>> signInWithCredential(
    Object credential,
  ) {
    throw UnimplementedError(
      "Method signInWithCredential() is not yet implemented.",
    );
  }

  /// Signs in the user using email and password.
  Future<Response<Credential>> signInWithEmailNPassword(
    String email,
    String password,
  ) {
    throw UnimplementedError(
      "Method signInWithEmailNPassword() is not yet implemented.",
    );
  }

  /// Signs in the user using username and password.
  Future<Response<Credential>> signInWithUsernameNPassword(
    String username,
    String password,
  ) {
    throw UnimplementedError(
      "Method signInWithUsernameNPassword() is not yet implemented.",
    );
  }

  /// Signs in the user with an Apple account.
  Future<Response<Credential>> signInWithApple() {
    throw UnimplementedError(
      "Method signInWithApple() is not yet implemented.",
    );
  }

  /// Signs in the user with a Facebook account.
  Future<Response<Credential>> signInWithFacebook() {
    throw UnimplementedError(
      "Method signInWithFacebook() is not yet implemented.",
    );
  }

  /// Signs in the user with Game Center credentials.
  Future<Response<Credential>> signInWithGameCenter() {
    throw UnimplementedError(
      "Method signInWithGameCenter() is not yet implemented.",
    );
  }

  /// Signs in the user with a GitHub account.
  Future<Response<Credential>> signInWithGithub() {
    throw UnimplementedError(
      "Method signInWithGithub() is not yet implemented.",
    );
  }

  /// Signs in the user with a Google account.
  Future<Response<Credential>> signInWithGoogle() {
    throw UnimplementedError(
      "Method signInWithGoogle() is not yet implemented.",
    );
  }

  /// Signs in the user with a Microsoft account.
  Future<Response<Credential>> signInWithMicrosoft() {
    throw UnimplementedError(
      "Method signInWithMicrosoft() is not yet implemented.",
    );
  }

  /// Signs in the user with Play Games credentials.
  Future<Response<Credential>> signInWithPlayGames() {
    throw UnimplementedError(
      "Method signInWithPlayGames() is not yet implemented.",
    );
  }

  /// Signs in the user using SAML authentication.
  Future<Response<Credential>> signInWithSAML() {
    throw UnimplementedError(
      "Method signInWithSAML() is not yet implemented.",
    );
  }

  /// Signs in the user with a Twitter account.
  Future<Response<Credential>> signInWithTwitter() {
    throw UnimplementedError(
      "Method signInWithTwitter() is not yet implemented.",
    );
  }

  /// Signs in the user with a Yahoo account.
  Future<Response<Credential>> signInWithYahoo() {
    throw UnimplementedError(
      "Method signInWithYahoo() is not yet implemented.",
    );
  }

  /// Signs up the user using email and password.
  Future<Response<Credential>> signUpWithEmailNPassword(
    String email,
    String password,
  ) {
    throw UnimplementedError(
      "Method signUpWithEmailNPassword() is not yet implemented.",
    );
  }

  /// Signs up the user using username and password.
  Future<Response<Credential>> signUpWithUsernameNPassword(
    String username,
    String password,
  ) {
    throw UnimplementedError(
      "Method signUpWithUsernameNPassword() is not yet implemented.",
    );
  }

  /// Signs out the user from the specified provider or all providers if none is specified.
  Future<Response<void>> signOut([Provider? provider]) {
    throw UnimplementedError(
      "Method signOut() is not yet implemented.",
    );
  }

  /// Verifies the user's phone number.
  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    int? forceResendingToken,
    Object? multiFactorInfo,
    Object? multiFactorSession,
    Duration timeout = const Duration(seconds: 30),
    required void Function(Credential credential) onComplete,
    required void Function(AuthException exception) onFailed,
    required void Function(String verId, int? forceResendingToken) onCodeSent,
    required void Function(String verId) onCodeAutoRetrievalTimeout,
  }) {
    throw UnimplementedError(
      "Method verifyPhoneNumber() is not yet implemented.",
    );
  }
}
