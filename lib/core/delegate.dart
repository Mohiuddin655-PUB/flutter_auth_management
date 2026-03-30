import 'package:flutter_entity/entity.dart';

import 'credential.dart';
import 'exception.dart';
import 'provider.dart';

abstract class AuthDelegate {
  const AuthDelegate();

  bool get isAnonymous;

  bool get isAuthenticated;

  Future<String?> get rawUid;

  /// Create the auth credential using a provided credential info.
  Object credential(Provider provider, Credential credential);

  /// Deletes the current user's credential.
  Future<Response<void>> delete();

  /// Checks if a user is currently signed in.
  Future<bool> isSignIn([Provider? provider]);

  /// Signs in the user anonymously.
  Future<Response<Credential>> signInAnonymously();

  /// Signs in the user using biometric authentication.
  Future<Response<void>> signInWithBiometric();

  /// Signs in the user using a provided credential.
  Future<Response<Credential>> signInWithCredential(Object credential);

  /// Signs in the user using email and password.
  Future<Response<Credential>> signInWithEmailNPassword(
    String email,
    String password,
  );

  /// Signs in the user using username and password.
  Future<Response<Credential>> signInWithUsernameNPassword(
    String username,
    String password,
  );

  /// Signs in the user with an Apple account.
  Future<Response<Credential>> signInWithApple();

  /// Signs in the user with a Facebook account.
  Future<Response<Credential>> signInWithFacebook();

  /// Signs in the user with Game Center credentials.
  Future<Response<Credential>> signInWithGameCenter();

  /// Signs in the user with a GitHub account.
  Future<Response<Credential>> signInWithGithub();

  /// Signs in the user with a Google account.
  Future<Response<Credential>> signInWithGoogle();

  /// Signs in the user with a Microsoft account.
  Future<Response<Credential>> signInWithMicrosoft();

  /// Signs in the user with Play Games credentials.
  Future<Response<Credential>> signInWithPlayGames();

  /// Signs in the user using SAML authentication.
  Future<Response<Credential>> signInWithSAML();

  /// Signs in the user with a Twitter account.
  Future<Response<Credential>> signInWithTwitter();

  /// Signs in the user with a Yahoo account.
  Future<Response<Credential>> signInWithYahoo();

  /// Signs up the user using email and password.
  Future<Response<Credential>> signUpWithEmailNPassword(
    String email,
    String password,
  );

  /// Signs up the user using username and password.
  Future<Response<Credential>> signUpWithUsernameNPassword(
    String username,
    String password,
  );

  /// Signs out the user from the specified provider or all providers if none is specified.
  Future<Response<void>> signOut([Provider? provider]);

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
  });
}
