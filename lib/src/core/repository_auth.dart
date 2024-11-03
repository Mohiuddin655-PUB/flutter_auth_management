import 'package:auth_management/core.dart';
import 'package:auth_management_delegates/auth_management_delegates.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_entity/flutter_entity.dart';

class AuthRepository {
  final AuthDataSource source;

  const AuthRepository(this.source);

  factory AuthRepository.create({
    IAppleAuthDelegate? appleAuthDelegate,
    IBiometricAuthDelegate? biometricAuthDelegate,
    IFacebookAuthDelegate? facebookAuthDelegate,
    IGoogleAuthDelegate? googleAuthDelegate,
  }) {
    return AuthRepository(AuthDataSource(
      appleAuthDelegate: appleAuthDelegate,
      biometricAuthDelegate: biometricAuthDelegate,
      facebookAuthDelegate: facebookAuthDelegate,
      googleAuthDelegate: googleAuthDelegate,
    ));
  }

  User? get user => source.user;

  Future<Response> get delete {
    return source.delete.onError((e, __) => Response(error: "$e"));
  }

  Future<bool> isSignIn([AuthProviders? provider]) {
    try {
      return source.isSignIn(provider).onError((_, __) => false);
    } catch (_) {
      return Future.value(false);
    }
  }

  Future<Response<UserCredential>> signInAnonymously() {
    try {
      return source
          .signInAnonymously()
          .onError((e, __) => Response<UserCredential>(error: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(error: "$e"));
    }
  }

  Future<Response<void>> signInWithBiometric({
    BiometricConfig? config,
  }) {
    try {
      return source.signInWithBiometric(config: config).onError((e, __) {
        return Response<bool>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<bool>(error: "$e"));
    }
  }

  Future<Response<UserCredential>> signInWithCredential({
    required AuthCredential credential,
  }) async {
    try {
      return source
          .signInWithCredential(credential: credential)
          .onError((e, __) => Response<UserCredential>(error: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(error: "$e"));
    }
  }

  Future<Response<UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) {
    try {
      return source
          .signInWithEmailNPassword(email: email, password: password)
          .onError((e, __) => Response<UserCredential>(error: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(error: "$e"));
    }
  }

  Future<Response<UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    try {
      return source
          .signInWithUsernameNPassword(username: username, password: password)
          .onError((e, __) => Response<UserCredential>(error: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(error: "$e"));
    }
  }

  Future<Response<UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) {
    try {
      return source
          .signUpWithEmailNPassword(email: email, password: password)
          .onError((e, __) => Response<UserCredential>(error: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(error: "$e"));
    }
  }

  Future<Response<UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    try {
      return source
          .signUpWithUsernameNPassword(username: username, password: password)
          .onError((e, __) => Response<UserCredential>(error: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(error: "$e"));
    }
  }

  Future<Response<Auth>> signOut([AuthProviders? provider]) {
    try {
      return source.signOut(provider).onError((e, __) {
        return Response<Auth>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<Auth>(error: "$e"));
    }
  }

  Future<Response<void>> verifyPhoneNumber({
    String? phoneNumber,
    int? forceResendingToken,
    PhoneMultiFactorInfo? multiFactorInfo,
    MultiFactorSession? multiFactorSession,
    Duration timeout = const Duration(seconds: 30),
    required void Function(PhoneAuthCredential credential) onComplete,
    required void Function(FirebaseAuthException exception) onFailed,
    required void Function(String verId, int? forceResendingToken) onCodeSent,
    required void Function(String verId) onCodeAutoRetrievalTimeout,
  }) {
    try {
      return source
          .verifyPhoneNumber(
            phoneNumber: phoneNumber,
            forceResendingToken: forceResendingToken,
            multiFactorInfo: multiFactorInfo,
            multiFactorSession: multiFactorSession,
            timeout: timeout,
            onComplete: onComplete,
            onFailed: onFailed,
            onCodeSent: onCodeSent,
            onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
          )
          .onError((e, __) => Response(error: "$e"));
    } catch (e) {
      return Future.value(Response(error: "$e"));
    }
  }

  // OAUTH

  Future<Response<Credential>> signInWithApple() {
    try {
      return source.signInWithApple().onError((e, __) {
        return Response<Credential>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(error: "$e"));
    }
  }

  Future<Response<Credential>> signInWithFacebook() {
    try {
      return source.signInWithFacebook().onError((e, __) {
        return Response<Credential>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(error: "$e"));
    }
  }

  Future<Response<Credential>> signInWithGameCenter() {
    try {
      return source.signInWithGameCenter().onError((e, __) {
        return Response<Credential>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(error: "$e"));
    }
  }

  Future<Response<Credential>> signInWithGithub() {
    try {
      return source.signInWithGithub().onError((e, __) {
        return Response<Credential>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(error: "$e"));
    }
  }

  Future<Response<Credential>> signInWithGoogle() {
    try {
      return source.signInWithGoogle().onError((e, __) {
        return Response<Credential>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(error: "$e"));
    }
  }

  Future<Response<Credential>> signInWithMicrosoft() {
    try {
      return source.signInWithMicrosoft().onError((e, __) {
        return Response<Credential>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(error: "$e"));
    }
  }

  Future<Response<Credential>> signInWithPlayGames() {
    try {
      return source.signInWithPlayGames().onError((e, __) {
        return Response<Credential>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(error: "$e"));
    }
  }

  Future<Response<Credential>> signInWithSAML() {
    try {
      return source.signInWithSAML().onError((e, __) {
        return Response<Credential>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(error: "$e"));
    }
  }

  Future<Response<Credential>> signInWithTwitter() {
    try {
      return source.signInWithTwitter().onError((e, __) {
        return Response<Credential>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(error: "$e"));
    }
  }

  Future<Response<Credential>> signInWithYahoo() {
    try {
      return source.signInWithYahoo().onError((e, __) {
        return Response<Credential>(error: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(error: "$e"));
    }
  }
}
