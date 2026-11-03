part of 'authorizer.dart';

mixin _AuthOAuthMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T>, _AuthSignInMixin<T> {
  Future<AuthResponse<T>> signInWithApple({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: 'APPLE',
      doneMsg: msg.signInWithApple.done,
      failureMsg: msg.signInWithApple.failure,
      signIn: () => delegate.signInWithApple(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithFacebook({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: 'FACEBOOK',
      doneMsg: msg.signInWithFacebook.done,
      failureMsg: msg.signInWithFacebook.failure,
      signIn: () => delegate.signInWithFacebook(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithGameCenter({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: 'GAME_CENTER',
      doneMsg: msg.signInWithGameCenter.done,
      failureMsg: msg.signInWithGameCenter.failure,
      signIn: () => delegate.signInWithGameCenter(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithGithub({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: 'GITHUB',
      doneMsg: msg.signInWithGithub.done,
      failureMsg: msg.signInWithGithub.failure,
      signIn: () => delegate.signInWithGithub(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithGoogle({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: 'GOOGLE',
      doneMsg: msg.signInWithGoogle.done,
      failureMsg: msg.signInWithGoogle.failure,
      signIn: () => delegate.signInWithGoogle(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithMicrosoft({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: 'MICROSOFT',
      doneMsg: msg.signInWithMicrosoft.done,
      failureMsg: msg.signInWithMicrosoft.failure,
      signIn: () => delegate.signInWithMicrosoft(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithPlayGames({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: 'PLAY_GAMES',
      doneMsg: msg.signInWithPlayGames.done,
      failureMsg: msg.signInWithPlayGames.failure,
      signIn: () => delegate.signInWithPlayGames(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithSAML({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: 'SAML',
      doneMsg: msg.signInWithSAML.done,
      failureMsg: msg.signInWithSAML.failure,
      signIn: () => delegate.signInWithSAML(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithTwitter({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: 'TWITTER',
      doneMsg: msg.signInWithTwitter.done,
      failureMsg: msg.signInWithTwitter.failure,
      signIn: () => delegate.signInWithTwitter(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInWithYahoo({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: 'YAHOO',
      doneMsg: msg.signInWithYahoo.done,
      failureMsg: msg.signInWithYahoo.failure,
      signIn: () => delegate.signInWithYahoo(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> _signInWithOAuth({
    required String provider,
    required String? doneMsg,
    required String? failureMsg,
    required _OAuthSignIn signIn,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signIn(
      type: AuthType.oauth,
      doneMsg: doneMsg,
      failureMsg: failureMsg,
      signIn: (alive) async {
        final response = await signIn();
        final credential = response.data?.credential;
        if (credential == null) {
          return Response(status: Status.failure, error: response.error);
        }
        if (!alive()) return response;
        return delegate.signInWithCredential(credential);
      },
      data: (uid, result) => {
        keys.id: uid,
        keys.loggedIn: true,
        keys.loggedInTime: EntityHelper.generateTimeMills,
        keys.provider: provider,
        keys.verified: true,
        if ((result.email ?? '').isNotEmpty) keys.email: result.email,
        if ((result.displayName ?? '').isNotEmpty)
          keys.name: result.displayName,
        if ((result.photoURL ?? '').isNotEmpty) keys.photo: result.photoURL,
      },
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }
}
