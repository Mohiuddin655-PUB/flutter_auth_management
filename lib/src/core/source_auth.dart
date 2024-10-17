import 'package:auth_management_delegates/auth_management_delegates.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter_entity/flutter_entity.dart';

import '../models/auth.dart';
import '../models/auth_providers.dart';
import '../models/biometric_config.dart';
import '../models/credential.dart';
import 'exceptions.dart';

String? _toMail(String prefix, String suffix, [String type = "com"]) {
  return "$prefix@$suffix.$type";
}

class AuthDataSource {
  final IAppleAuthDelegate? appleAuthDelegate;
  final IBiometricAuthDelegate? biometricAuthDelegate;
  final IFacebookAuthDelegate? facebookAuthDelegate;
  final IGoogleAuthDelegate? googleAuthDelegate;
  final FirebaseAuth? _firebaseAuth;

  const AuthDataSource({
    this.appleAuthDelegate,
    this.biometricAuthDelegate,
    this.facebookAuthDelegate,
    this.googleAuthDelegate,
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth;

  FirebaseAuth get firebaseAuth => _firebaseAuth ?? FirebaseAuth.instance;

  IAppleAuthDelegate get appleAuth {
    if (appleAuthDelegate != null) {
      return appleAuthDelegate!;
    } else {
      throw const AuthDelegateException("IAppleAuthDelegate");
    }
  }

  IFacebookAuthDelegate get facebookAuth {
    if (facebookAuthDelegate != null) {
      return facebookAuthDelegate!;
    } else {
      throw const AuthDelegateException("IFacebookAuthDelegate");
    }
  }

  IBiometricAuthDelegate get localAuth {
    if (biometricAuthDelegate != null) {
      return biometricAuthDelegate!;
    } else {
      throw const AuthDelegateException("IBiometricAuthDelegate");
    }
  }

  IGoogleAuthDelegate get googleAuth {
    if (googleAuthDelegate != null) {
      return googleAuthDelegate!;
    } else {
      throw const AuthDelegateException("IGoogleAuthDelegate");
    }
  }

  User? get user => FirebaseAuth.instance.currentUser;

  Future<Response> get delete async {
    final response = Response();
    if (user != null) {
      try {
        return user!.delete().then((value) {
          return response.withStatus(
            Status.ok,
            message: "Account delete successful!",
          );
        });
      } on FirebaseAuthException catch (error) {
        return response.withException(error.message, status: Status.failure);
      }
    } else {
      return response.withException(
        "User isn't valid!",
        status: Status.invalid,
      );
    }
  }

  Future<bool> isSignIn([AuthProviders? provider]) async {
    if (provider != null) {
      switch (provider) {
        case AuthProviders.apple:
          return false;
        case AuthProviders.facebook:
          return (await facebookAuth.accessToken) != null;
        case AuthProviders.gameCenter:
          return false;
        case AuthProviders.github:
          return false;
        case AuthProviders.google:
          return googleAuth.isSignedIn();
        case AuthProviders.microsoft:
          return false;
        case AuthProviders.playGames:
          return false;
        case AuthProviders.saml:
          return false;
        case AuthProviders.twitter:
          return false;
        case AuthProviders.yahoo:
          return false;
        case AuthProviders.email:
        case AuthProviders.guest:
        case AuthProviders.username:
        case AuthProviders.phone:
          return firebaseAuth.currentUser != null;
        case AuthProviders.biometric:
        case AuthProviders.none:
          return false;
      }
    }
    return firebaseAuth.currentUser != null;
  }

  Future<Response<UserCredential>> signInAnonymously() async {
    final response = Response<UserCredential>();
    try {
      final result = await firebaseAuth.signInAnonymously();
      return response.withData(result, message: "Sign in successful!");
    } on FirebaseAuthException catch (e) {
      if (e.code == "operation-not-allowed") {
        return response.withException(
          "Anonymous auth hasn't been enabled for this project.",
          status: Status.notSupported,
        );
      }
      return response.withException(e.message, status: Status.failure);
    }
  }

  Future<Response<void>> signInWithBiometric({
    BiometricConfig? config,
  }) async {
    final mConfig = config ?? const BiometricConfig();
    try {
      final bool check = await localAuth.canCheckBiometrics;
      final bool isSupportable = check || await localAuth.isDeviceSupported();
      if (!isSupportable) {
        return Response(
          exception: mConfig.deviceException,
          status: Status.notSupported,
        );
      } else {
        if (check) {
          final authenticated = await localAuth.authenticate(
            localizedReason: mConfig.localizedReason,
            authMessages: mConfig.authMessages,
            options: mConfig.options,
          );
          if (authenticated) {
            return Response(status: Status.ok);
          } else {
            return Response(
              exception: mConfig.failureException,
              status: Status.notFound,
            );
          }
        } else {
          return Response(
            exception: mConfig.checkingException,
            status: Status.undetected,
          );
        }
      }
    } catch (error) {
      return Response(exception: error.toString(), status: Status.failure);
    }
  }

  Future<Response<UserCredential>> signInWithCredential({
    required AuthCredential credential,
  }) async {
    final response = Response<UserCredential>();
    try {
      final result = await firebaseAuth.signInWithCredential(credential);
      return response.withData(result, message: "Sign in successful!");
    } on FirebaseAuthException catch (error) {
      return response.withException(error.message, status: Status.failure);
    }
  }

  Future<Response<UserCredential>> signInWithEmailNPassword({
    required String email,
    required String password,
  }) async {
    final response = Response<UserCredential>();
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return response.withData(result, message: "Sign in successful!");
    } on FirebaseAuthException catch (error) {
      return response.withException(error.message, status: Status.failure);
    }
  }

  Future<Response<UserCredential>> signInWithUsernameNPassword({
    required String username,
    required String password,
  }) async {
    var mail = _toMail(username, "user", "org");
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: mail ?? "example@user.org",
        password: password,
      );
      return Response(
        status: Status.ok,
        data: result,
        message: "Sign in successful!",
      );
    } on FirebaseAuthException catch (error) {
      return Response(exception: error.message, status: Status.failure);
    }
  }

  Future<Response<UserCredential>> signUpWithEmailNPassword({
    required String email,
    required String password,
  }) async {
    final response = Response<UserCredential>();
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return response.withData(result, message: "Sign up successful!");
    } on FirebaseAuthException catch (error) {
      return response.withException(error.message, status: Status.failure);
    }
  }

  Future<Response<UserCredential>> signUpWithUsernameNPassword({
    required String username,
    required String password,
  }) async {
    final response = Response<UserCredential>();
    var mail = _toMail(username, "user", "org");
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: mail ?? "example@user.org",
        password: password,
      );
      return response.withData(result, message: "Sign up successful!");
    } on FirebaseAuthException catch (error) {
      return response.withException(error.message, status: Status.failure);
    }
  }

  Future<Response<Auth>> signOut([AuthProviders? provider]) async {
    final response = Response<Auth>();
    var data = Auth.fromUser(user);
    try {
      if (provider != null) {
        switch (provider) {
          // OAUTH
          case AuthProviders.apple:
            break;
          case AuthProviders.facebook:
            await facebookAuth.logOut();
            break;
          case AuthProviders.gameCenter:
            break;
          case AuthProviders.github:
            break;
          case AuthProviders.google:
            if (await googleAuth.isSignedIn()) {
              googleAuth.disconnect();
              googleAuth.signOut();
            }
            break;
          case AuthProviders.microsoft:
            break;
          case AuthProviders.playGames:
            break;
          case AuthProviders.saml:
            break;
          case AuthProviders.twitter:
            break;
          case AuthProviders.yahoo:
            break;
          // CUSTOM
          case AuthProviders.biometric:
          case AuthProviders.guest:
          case AuthProviders.email:
          case AuthProviders.phone:
          case AuthProviders.username:
          case AuthProviders.none:
            break;
        }
      } else {
        if (await googleAuth.isSignedIn()) {
          googleAuth.disconnect();
          googleAuth.signOut();
        }
      }
      await firebaseAuth.signOut();
    } catch (error) {
      return response.withException(error, status: Status.failure);
    }
    return response.withData(data);
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
  }) async {
    final response = Response();
    try {
      firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        multiFactorInfo: multiFactorInfo,
        multiFactorSession: multiFactorSession,
        timeout: timeout,
        verificationCompleted: onComplete,
        verificationFailed: onFailed,
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
      return response;
    } on FirebaseAuthException catch (error) {
      return response.withException(error.message, status: Status.failure);
    }
  }

  // OAUTH

  Future<Response<Credential>> signInWithApple() async {
    final response = Response<Credential>();
    try {
      final result = await appleAuth.getAppleIDCredential(
        scopes: [
          IAppleIDAuthorizationScopes.email,
          IAppleIDAuthorizationScopes.fullName,
        ],
      );

      if (result.identityToken != null) {
        final credential = OAuthProvider("apple.com").credential(
          idToken: result.identityToken,
          accessToken: result.authorizationCode,
        );

        return response.withData(Credential(
          credential: credential,
          accessToken: result.authorizationCode,
          idToken: result.identityToken,
          id: result.userIdentifier,
          email: result.email,
          name: result.givenName ?? result.familyName,
        ));
      } else {
        return response.withException('Token not valid!', status: Status.error);
      }
    } catch (error) {
      return response.withException(error.toString(), status: Status.failure);
    }
  }

  Future<Response<Credential>> signInWithFacebook() async {
    final response = Response<Credential>();
    try {
      final token = await facebookAuth.accessToken;
      IFacebookLoginResult? result;

      result = token == null
          ? await facebookAuth
              .login(permissions: ['publicerrorprofile', 'email'])
          : null;

      final status = result?.status ?? IFacebookLoginStatus.failed;

      if (token != null || status == IFacebookLoginStatus.success) {
        final accessToken = result?.accessToken ?? token;
        if (accessToken != null) {
          final credential = FacebookAuthProvider.credential(
            accessToken.tokenString,
          );
          final fbData = await facebookAuth.getUserData();
          return response.withData(Credential.fromMap(fbData).copy(
            accessToken: accessToken.tokenString,
            credential: credential,
          ));
        } else {
          return response.withException(
            'Token not valid!',
            status: Status.error,
          );
        }
      } else {
        return response.withException('Token not valid!', status: Status.error);
      }
    } catch (error) {
      return response.withException(error.toString(), status: Status.failure);
    }
  }

  Future<Response<Credential>> signInWithGameCenter() async {
    final response = Response<Credential>();
    try {
      return response.withStatus(Status.undefined);
    } catch (error) {
      return response.withException(error, status: Status.failure);
    }
  }

  Future<Response<Credential>> signInWithGithub() async {
    final response = Response<Credential>();
    try {
      return response.withStatus(Status.undefined);
    } catch (error) {
      return response.withException(error, status: Status.failure);
    }
  }

  Future<Response<Credential>> signInWithGoogle() async {
    final response = Response<Credential>();
    try {
      IGoogleSignInAccount? result;
      final auth = googleAuth;
      final isSignedIn = await auth.isSignedIn();
      if (isSignedIn) {
        result = await auth.signInSilently();
      } else {
        result = await auth.signIn();
      }
      if (result != null) {
        final authentication = await result.authentication;
        final idToken = authentication.idToken;
        final accessToken = authentication.accessToken;
        if (accessToken != null || idToken != null) {
          final receivedData = auth.currentUser;
          return response.withData(Credential(
            id: receivedData?.id,
            email: receivedData?.email,
            name: receivedData?.displayName,
            photo: receivedData?.photoUrl,
            accessToken: accessToken,
            idToken: idToken,
            credential: GoogleAuthProvider.credential(
              idToken: idToken,
              accessToken: accessToken,
            ),
          ));
        } else {
          return response.withException(
            'Token not valid!',
            status: Status.error,
          );
        }
      } else {
        return response.withException('Sign in failed!', status: Status.error);
      }
    } catch (error) {
      return response.withException(error.toString(), status: Status.failure);
    }
  }

  Future<Response<Credential>> signInWithMicrosoft() async {
    final response = Response<Credential>();
    try {
      return response.withStatus(Status.undefined);
    } catch (error) {
      return response.withException(error, status: Status.failure);
    }
  }

  Future<Response<Credential>> signInWithPlayGames() async {
    final response = Response<Credential>();
    try {
      return response.withStatus(Status.undefined);
    } catch (error) {
      return response.withException(error, status: Status.failure);
    }
  }

  Future<Response<Credential>> signInWithSAML() async {
    final response = Response<Credential>();
    try {
      return response.withStatus(Status.undefined);
    } catch (error) {
      return response.withException(error, status: Status.failure);
    }
  }

  Future<Response<Credential>> signInWithTwitter() async {
    final response = Response<Credential>();
    try {
      return response.withStatus(Status.undefined);
    } catch (error) {
      return response.withException(error, status: Status.failure);
    }
  }

  Future<Response<Credential>> signInWithYahoo() async {
    final response = Response<Credential>();
    try {
      return response.withStatus(Status.undefined);
    } catch (error) {
      return response.withException(error, status: Status.failure);
    }
  }
}
