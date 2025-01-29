import 'package:auth_management_delegates/auth_management_delegates.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

String? _toMail(String prefix, String suffix, [String type = "com"]) {
  return "$prefix@$suffix.$type";
}

class FirebaseAuthDelegate extends AuthDelegate {
  final IAppleAuthDelegate? appleAuthDelegate;
  final IBiometricAuthDelegate? biometricAuthDelegate;
  final IFacebookAuthDelegate? facebookAuthDelegate;
  final IGoogleAuthDelegate? googleAuthDelegate;
  final FirebaseAuth? _firebaseAuth;

  const FirebaseAuthDelegate({
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
      throw const AuthException("IAppleAuthDelegate");
    }
  }

  IFacebookAuthDelegate get facebookAuth {
    if (facebookAuthDelegate != null) {
      return facebookAuthDelegate!;
    } else {
      throw const AuthException("IFacebookAuthDelegate");
    }
  }

  IBiometricAuthDelegate get localAuth {
    if (biometricAuthDelegate != null) {
      return biometricAuthDelegate!;
    } else {
      throw const AuthException("IBiometricAuthDelegate");
    }
  }

  IGoogleAuthDelegate get googleAuth {
    if (googleAuthDelegate != null) {
      return googleAuthDelegate!;
    } else {
      throw const AuthException("IGoogleAuthDelegate");
    }
  }

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Object credential(Provider provider, Credential credential) {
    final token = credential.accessToken;
    final idToken = credential.idToken;
    switch (provider) {
      case Provider.apple:
        return OAuthProvider("apple.com").credential(
          idToken: idToken,
          accessToken: token,
        );
      case Provider.facebook:
        return FacebookAuthProvider.credential(token ?? "");
      case Provider.google:
        return GoogleAuthProvider.credential(
          idToken: idToken,
          accessToken: token,
        );
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<Response<void>> delete() async {
    if (user != null) {
      try {
        return user!.delete().then((value) {
          return Response(
            status: Status.ok,
            message: "Account delete successful!",
          );
        });
      } on FirebaseAuthException catch (error) {
        return Response(status: Status.failure, error: error.message);
      }
    } else {
      return Response(status: Status.invalid, error: "User isn't valid!");
    }
  }

  @override
  Future<bool> isSignIn([Provider? provider]) async {
    if (provider != null) {
      switch (provider) {
        case Provider.apple:
          return false;
        case Provider.facebook:
          return (await facebookAuth.accessToken) != null;
        case Provider.gameCenter:
          return false;
        case Provider.github:
          return false;
        case Provider.google:
          return googleAuth.isSignedIn();
        case Provider.microsoft:
          return false;
        case Provider.playGames:
          return false;
        case Provider.saml:
          return false;
        case Provider.twitter:
          return false;
        case Provider.yahoo:
          return false;
        case Provider.email:
        case Provider.guest:
        case Provider.username:
        case Provider.phone:
          return firebaseAuth.currentUser != null;
        case Provider.biometric:
        case Provider.none:
          return false;
      }
    }
    return firebaseAuth.currentUser != null;
  }

  @override
  Future<Response<Credential>> signInAnonymously() async {
    try {
      final result = await firebaseAuth.signInAnonymously();
      return Response(
        status: Status.ok,
        data: result._credential,
        message: "Sign in successful!",
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == "operation-not-allowed") {
        return Response(
          status: Status.notSupported,
          error: "Anonymous auth hasn't been enabled for this project.",
        );
      }
      return Response(status: Status.failure, error: e.message);
    }
  }

  @override
  Future<Response<void>> signInWithBiometric([BiometricConfig? config]) async {
    final mConfig = config ?? const BiometricConfig();
    try {
      final bool check = await localAuth.canCheckBiometrics;
      final bool isSupportable = check || await localAuth.isDeviceSupported();
      if (!isSupportable) {
        return Response(
          error: mConfig.deviceException,
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
              error: mConfig.failureException,
              status: Status.notFound,
            );
          }
        } else {
          return Response(
            error: mConfig.checkingException,
            status: Status.undetected,
          );
        }
      }
    } catch (error) {
      return Response(error: error.toString(), status: Status.failure);
    }
  }

  @override
  Future<Response<Credential>> signInWithCredential(Object credential) async {
    if (credential is! AuthCredential) {
      return Response(error: "Credential exception!");
    }
    try {
      final result = await firebaseAuth.signInWithCredential(credential);
      return Response(
        status: Status.ok,
        data: result._credential,
        message: "Sign in successful!",
      );
    } on FirebaseAuthException catch (error) {
      return Response(status: Status.failure, error: error.message);
    }
  }

  @override
  Future<Response<Credential>> signInWithEmailNPassword(
      String email, String password) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Response(
        status: Status.ok,
        data: result._credential,
        message: "Sign in successful!",
      );
    } on FirebaseAuthException catch (error) {
      return Response(status: Status.failure, error: error.message);
    }
  }

  @override
  Future<Response<Credential>> signInWithUsernameNPassword(
    String username,
    String password,
  ) async {
    var mail = _toMail(username, "user", "org");
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: mail ?? "example@user.org",
        password: password,
      );
      return Response(
        status: Status.ok,
        data: result._credential,
        message: "Sign in successful!",
      );
    } on FirebaseAuthException catch (error) {
      return Response(error: error.message, status: Status.failure);
    }
  }

  @override
  Future<Response<Credential>> signUpWithEmailNPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Response(
        status: Status.ok,
        data: result._credential,
        message: "Sign up successful!",
      );
    } on FirebaseAuthException catch (error) {
      return Response(status: Status.failure, error: error.message);
    }
  }

  @override
  Future<Response<Credential>> signUpWithUsernameNPassword(
    String username,
    String password,
  ) async {
    var mail = _toMail(username, "user", "org");
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: mail ?? "example@user.org",
        password: password,
      );
      return Response(
        status: Status.ok,
        data: result._credential,
        message: "Sign up successful!",
      );
    } on FirebaseAuthException catch (error) {
      return Response(status: Status.failure, error: error.message);
    }
  }

  @override
  Future<Response<void>> signOut([Provider? provider]) async {
    try {
      if (provider != null) {
        switch (provider) {
          case Provider.apple:
            break;
          case Provider.facebook:
            await facebookAuth.logOut();
            break;
          case Provider.gameCenter:
            break;
          case Provider.github:
            break;
          case Provider.google:
            if (await googleAuth.isSignedIn()) {
              await googleAuth.disconnect();
              await googleAuth.signOut();
            }
            break;
          case Provider.microsoft:
            break;
          case Provider.playGames:
            break;
          case Provider.saml:
            break;
          case Provider.twitter:
            break;
          case Provider.yahoo:
            break;
          case Provider.biometric:
          case Provider.guest:
          case Provider.email:
          case Provider.phone:
          case Provider.username:
          case Provider.none:
            break;
        }
      } else {
        if (await googleAuth.isSignedIn()) {
          await googleAuth.disconnect();
          await googleAuth.signOut();
        }
      }
      await firebaseAuth.signOut();
    } catch (error) {
      return Response(status: Status.failure, error: error.toString());
    }
    return Response(status: Status.ok);
  }

  @override
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
  }) async {
    try {
      firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        multiFactorInfo:
            multiFactorInfo is PhoneMultiFactorInfo ? multiFactorInfo : null,
        multiFactorSession: multiFactorSession is MultiFactorSession
            ? multiFactorSession
            : null,
        timeout: timeout,
        verificationCompleted: (credential) => onComplete(Credential(
          providerId: credential.providerId,
          verificationId: credential.verificationId,
          signInMethod: credential.signInMethod,
          smsCode: credential.smsCode,
          accessToken: credential.token.toString(),
        )),
        verificationFailed: (e) => onFailed(AuthException(
          e.message ?? "",
          e.code,
        )),
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      );
    } catch (error) {
      throw AuthException(error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithApple() async {
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

        return Response(
          status: Status.ok,
          data: Credential(
            providerId: credential.providerId,
            signInMethod: credential.signInMethod,
            accessToken: result.authorizationCode,
            idToken: result.identityToken,
            credential: credential,
            uid: result.userIdentifier,
            email: result.email,
            displayName: result.givenName ?? result.familyName,
          ),
        );
      } else {
        return Response(status: Status.error, error: 'Token not valid!');
      }
    } catch (error) {
      return Response(status: Status.failure, error: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithFacebook() async {
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
          return Response(
            status: Status.ok,
            data: Credential.fromFbData(fbData).copyWith(
              accessToken: accessToken.tokenString,
              credential: credential,
            ),
          );
        } else {
          return Response(status: Status.error, error: 'Token not valid!');
        }
      } else {
        return Response(status: Status.error, error: 'Token not valid!');
      }
    } catch (error) {
      return Response(status: Status.failure, error: error.toString());
    }
  }

  @override
  Future<Response<Credential>> signInWithGoogle() async {
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
          return Response(
            status: Status.ok,
            data: Credential(
              uid: receivedData?.id ?? result.id,
              email: receivedData?.email ?? result.email,
              displayName: receivedData?.displayName ?? result.displayName,
              photoURL: receivedData?.photoUrl ?? result.photoUrl,
              accessToken: accessToken,
              signInMethod:
                  receivedData?.serverAuthCode ?? result.serverAuthCode,
              idToken: idToken,
              credential: GoogleAuthProvider.credential(
                idToken: idToken,
                accessToken: accessToken,
              ),
            ),
          );
        } else {
          return Response(status: Status.error, error: 'Token not valid!');
        }
      } else {
        return Response(status: Status.error, error: 'Sign in failed!');
      }
    } catch (error) {
      return Response(status: Status.failure, error: error.toString());
    }
  }
}

extension on UserCredential {
  Credential get _credential {
    final ai = additionalUserInfo;
    final meta = user?.metadata;
    return Credential(
      accessToken: credential?.accessToken,
      additionalUserInfo: ai != null
          ? AdditionalInfo(
              isNewUser: ai.isNewUser,
              authorizationCode: ai.authorizationCode,
              profile: ai.profile,
              providerId: ai.providerId,
              username: ai.username,
            )
          : null,
      credential: credential,
      displayName: user?.displayName,
      email: user?.email,
      emailVerified: user?.emailVerified,
      idToken: credential?.token.toString(),
      isAnonymous: user?.isAnonymous,
      metadata: meta != null
          ? Metadata(
              creationTime: meta.creationTime,
              lastSignInTime: meta.lastSignInTime,
            )
          : null,
      multiFactor: user?.multiFactor,
      phoneNumber: user?.phoneNumber,
      photoURL: user?.photoURL,
      providerId: credential?.providerId,
      providerData: user?.providerData.map((e) {
        return Info(
          providerId: e.providerId,
          displayName: e.displayName,
          email: e.email,
          phoneNumber: e.phoneNumber,
          photoURL: e.photoURL,
          uid: e.uid,
        );
      }).toList(),
      refreshToken: user?.refreshToken,
      tenantId: user?.tenantId,
      uid: user?.uid ?? '',
    );
  }
}
