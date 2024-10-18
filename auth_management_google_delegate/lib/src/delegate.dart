import 'dart:async';

import 'package:auth_management_delegates/auth_management_delegates.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

class GoogleAuthDelegate extends IGoogleAuthDelegate {
  final GoogleSignIn googleSignIn;

  GoogleAuthDelegate({
    GoogleSignIn? googleSignIn,
  }) : googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email']);

  @override
  Future<bool> canAccessScopes(
    List<String> scopes, {
    String? accessToken,
  }) {
    return googleSignIn.canAccessScopes(scopes, accessToken: accessToken);
  }

  @override
  IGoogleSignInAccount? get currentUser => _account(googleSignIn.currentUser);

  @override
  Future<IGoogleSignInAccount?> disconnect() {
    return googleSignIn.disconnect().then(_account);
  }

  @override
  Future<bool> isSignedIn() => googleSignIn.isSignedIn();

  @override
  Stream<IGoogleSignInAccount?> get onCurrentUserChanged {
    final controller = StreamController<IGoogleSignInAccount?>();
    googleSignIn.onCurrentUserChanged.listen((event) {
      controller.add(_account(event));
    });
    return controller.stream;
  }

  @override
  Future<bool> requestScopes(List<String> scopes) {
    return googleSignIn.requestScopes(scopes);
  }

  @override
  Future<IGoogleSignInAccount?> signIn() {
    return googleSignIn.signIn().then(_account);
  }

  @override
  Future<IGoogleSignInAccount?> signInSilently({
    bool suppressErrors = true,
    bool reAuthenticate = false,
  }) {
    return googleSignIn
        .signInSilently(
            suppressErrors: suppressErrors, reAuthenticate: reAuthenticate)
        .then(_account);
  }

  @override
  Future<IGoogleSignInAccount?> signOut() {
    return googleSignIn.signOut().then((value) {
      return _account(value);
    });
  }

  IGoogleSignInAccount? _account(
    GoogleSignInAccount? value,
  ) {
    if (value != null) {
      final data = IGoogleSignInUserData(
        email: value.email,
        id: value.id,
        displayName: value.displayName,
        photoUrl: value.photoUrl,
        serverAuthCode: value.serverAuthCode,
      );
      return IGoogleSignInAccount(
        data,
        currentUser: null,
        authentication: value.authentication.then(_authentication),
        authHeaders: value.authHeaders,
        getTokens: _tokens,
        onClearAuthCache: GoogleSignInPlatform.instance.clearAuthCache,
      );
    } else {
      return null;
    }
  }

  Future<IGoogleSignInTokenData> _tokens({
    required String email,
    bool? shouldRecoverAuth,
  }) {
    return GoogleSignInPlatform.instance
        .getTokens(email: email, shouldRecoverAuth: shouldRecoverAuth)
        .then((value) {
      return IGoogleSignInTokenData(
        idToken: value.idToken,
        accessToken: value.accessToken,
        serverAuthCode: value.serverAuthCode,
      );
    });
  }

  IGoogleSignInAuthentication _authentication(
    GoogleSignInAuthentication value,
  ) {
    return IGoogleSignInAuthentication(_token(value));
  }

  IGoogleSignInTokenData _token(GoogleSignInAuthentication value) {
    return IGoogleSignInTokenData(
      idToken: value.idToken,
      accessToken: value.accessToken,
    );
  }
}
