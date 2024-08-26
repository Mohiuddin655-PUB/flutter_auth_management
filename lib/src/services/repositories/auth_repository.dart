import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_entity/flutter_entity.dart';

import '../../delegates/user.dart';
import '../../models/auth.dart';
import '../../models/auth_providers.dart';
import '../../models/biometric_config.dart';
import '../../models/credential.dart';
import '../sources/auth_data_source.dart';

abstract class AuthRepository {
  final AuthDataSource source;

  const AuthRepository(this.source);

  auth.User? get user;

  IUserDelegate get userDelegate;

  Future<bool> isSignIn([AuthProviders? provider]);

  Future<Response<auth.UserCredential>> signInAnonymously();

  Future<Response<void>> signInWithBiometric({
    BiometricConfig? config,
  });

  Future<Response<auth.UserCredential>> signInWithCredential({
    required auth.AuthCredential credential,
  });

  Future<Response<auth.UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  });

  Future<Response<auth.UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  });

  Future<Response<auth.UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  });

  Future<Response<auth.UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  });

  Future<Response<Auth>> signOut([AuthProviders? provider]);

  Future<Response<void>> verifyPhoneNumber({
    String? phoneNumber,
    int? forceResendingToken,
    auth.PhoneMultiFactorInfo? multiFactorInfo,
    auth.MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(seconds: 30),
    required void Function(auth.PhoneAuthCredential credential) onComplete,
    required void Function(auth.FirebaseAuthException exception) onFailed,
    required void Function(String verId, int? forceResendingToken) onCodeSent,
    required void Function(String verId) onCodeAutoRetrievalTimeout,
  });

  Future<Response<Credential>> signInWithApple();

  Future<Response<Credential>> signInWithFacebook();

  Future<Response<Credential>> signInWithGameCenter();

  Future<Response<Credential>> signInWithGithub();

  Future<Response<Credential>> signInWithGoogle();

  Future<Response<Credential>> signInWithMicrosoft();

  Future<Response<Credential>> signInWithPlayGames();

  Future<Response<Credential>> signInWithSAML();

  Future<Response<Credential>> signInWithTwitter();

  Future<Response<Credential>> signInWithYahoo();
}
