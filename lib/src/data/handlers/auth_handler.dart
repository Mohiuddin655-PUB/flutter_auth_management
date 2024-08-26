import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_entity/flutter_entity.dart';

import '../../models/auth.dart';
import '../../models/auth_providers.dart';
import '../../models/biometric_config.dart';
import '../../models/credential.dart';
import '../../services/handlers/auth_handler.dart';
import '../../services/sources/auth_data_source.dart';
import '../repositories/auth_repository.dart';

class AuthHandlerImpl extends AuthHandler {
  AuthHandlerImpl(AuthDataSource source)
      : super(AuthRepositoryImpl(source: source));

  const AuthHandlerImpl.fromRepository(super.repository);

  @override
  User? get user => repository.user;

  @override
  Future<Response> get delete {
    return repository.delete.onError((e, __) => Response(exception: "$e"));
  }

  @override
  Future<bool> isSignIn([AuthProviders? provider]) {
    try {
      return repository.isSignIn(provider).onError((_, __) => false);
    } catch (_) {
      return Future.value(false);
    }
  }

  @override
  Future<Response<UserCredential>> signInAnonymously() {
    try {
      return repository
          .signInAnonymously()
          .onError((e, __) => Response<UserCredential>(exception: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(exception: "$e"));
    }
  }

  @override
  Future<Response<void>> signInWithBiometric({
    BiometricConfig? config,
  }) {
    try {
      return repository.signInWithBiometric(config: config).onError((e, __) {
        return Response<bool>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<bool>(exception: "$e"));
    }
  }

  @override
  Future<Response<UserCredential>> signInWithCredential({
    required AuthCredential credential,
  }) async {
    try {
      return repository
          .signInWithCredential(credential: credential)
          .onError((e, __) => Response<UserCredential>(exception: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(exception: "$e"));
    }
  }

  @override
  Future<Response<UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) {
    try {
      return repository
          .signInWithEmailNPassword(email: email, password: password)
          .onError((e, __) => Response<UserCredential>(exception: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(exception: "$e"));
    }
  }

  @override
  Future<Response<UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    try {
      return repository
          .signInWithUsernameNPassword(username: username, password: password)
          .onError((e, __) => Response<UserCredential>(exception: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(exception: "$e"));
    }
  }

  @override
  Future<Response<UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) {
    try {
      return repository
          .signUpWithEmailNPassword(email: email, password: password)
          .onError((e, __) => Response<UserCredential>(exception: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(exception: "$e"));
    }
  }

  @override
  Future<Response<UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) {
    try {
      return repository
          .signUpWithUsernameNPassword(username: username, password: password)
          .onError((e, __) => Response<UserCredential>(exception: "$e"));
    } catch (e) {
      return Future.value(Response<UserCredential>(exception: "$e"));
    }
  }

  @override
  Future<Response<Auth>> signOut([AuthProviders? provider]) {
    try {
      return repository.signOut(provider).onError((e, __) {
        return Response<Auth>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<Auth>(exception: "$e"));
    }
  }

  @override
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
      return repository
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
          .onError((e, __) => Response(exception: "$e"));
    } catch (e) {
      return Future.value(Response(exception: "$e"));
    }
  }

  // OAUTH
  @override
  Future<Response<Credential>> signInWithApple() {
    try {
      return repository.signInWithApple().onError((e, __) {
        return Response<Credential>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(exception: "$e"));
    }
  }

  @override
  Future<Response<Credential>> signInWithFacebook() {
    try {
      return repository.signInWithFacebook().onError((e, __) {
        return Response<Credential>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(exception: "$e"));
    }
  }

  @override
  Future<Response<Credential>> signInWithGameCenter() {
    try {
      return repository.signInWithGameCenter().onError((e, __) {
        return Response<Credential>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(exception: "$e"));
    }
  }

  @override
  Future<Response<Credential>> signInWithGithub() {
    try {
      return repository.signInWithGithub().onError((e, __) {
        return Response<Credential>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(exception: "$e"));
    }
  }

  @override
  Future<Response<Credential>> signInWithGoogle() {
    try {
      return repository.signInWithGoogle().onError((e, __) {
        return Response<Credential>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(exception: "$e"));
    }
  }

  @override
  Future<Response<Credential>> signInWithMicrosoft() {
    try {
      return repository.signInWithMicrosoft().onError((e, __) {
        return Response<Credential>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(exception: "$e"));
    }
  }

  @override
  Future<Response<Credential>> signInWithPlayGames() {
    try {
      return repository.signInWithPlayGames().onError((e, __) {
        return Response<Credential>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(exception: "$e"));
    }
  }

  @override
  Future<Response<Credential>> signInWithSAML() {
    try {
      return repository.signInWithSAML().onError((e, __) {
        return Response<Credential>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(exception: "$e"));
    }
  }

  @override
  Future<Response<Credential>> signInWithTwitter() {
    try {
      return repository.signInWithTwitter().onError((e, __) {
        return Response<Credential>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(exception: "$e"));
    }
  }

  @override
  Future<Response<Credential>> signInWithYahoo() {
    try {
      return repository.signInWithYahoo().onError((e, __) {
        return Response<Credential>(exception: "$e");
      });
    } catch (e) {
      return Future.value(Response<Credential>(exception: "$e"));
    }
  }
}
