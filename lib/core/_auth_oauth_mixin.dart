part of 'authorizer.dart';

mixin _AuthOAuthMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T>, _AuthUpdateMixin<T> {
  Future<AuthResponse<T>> signInWithApple({
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithOAuth(
      provider: Provider.apple,
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
      provider: Provider.facebook,
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
      provider: Provider.gameCenter,
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
      provider: Provider.github,
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
      provider: Provider.google,
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
      provider: Provider.microsoft,
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
      provider: Provider.playGames,
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
      provider: Provider.saml,
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
      provider: Provider.twitter,
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
      provider: Provider.yahoo,
      doneMsg: msg.signInWithYahoo.done,
      failureMsg: msg.signInWithYahoo.failure,
      signIn: () => delegate.signInWithYahoo(),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> _signInWithOAuth({
    required Provider provider,
    required String? doneMsg,
    required String? failureMsg,
    required _OAuthSignIn signIn,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      AuthResponse.loading(provider, AuthType.oauth),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final hasAnonymous = this.hasAnonymous;
      final response = await signIn();
      final raw = response.data;
      if (raw == null || raw.credential == null) {
        return _failure(
          response.error,
          provider: provider,
          type: AuthType.oauth,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final current = await delegate.signInWithCredential(raw.credential!);
      if (!current.isSuccessful) {
        return _failure(
          current.error,
          provider: provider,
          type: AuthType.oauth,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = current.data;
      final uid = result?.uid ?? '';
      if (result == null || uid.isEmpty) {
        return _failure(
          msg.authorization,
          provider: provider,
          type: AuthType.oauth,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final value = await _update(
        id: uid,
        hasAnonymous: hasAnonymous,
        data: {
          keys.id: uid,
          keys.loggedIn: true,
          keys.loggedInTime: EntityHelper.generateTimeMills,
          keys.provider: provider.id,
          keys.verified: true,
          if ((result.email ?? '').isNotEmpty) keys.email: result.email,
          if ((result.displayName ?? '').isNotEmpty)
            keys.name: result.displayName,
          if ((result.photoURL ?? '').isNotEmpty) keys.photo: result.photoURL,
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: doneMsg,
          provider: provider,
          type: AuthType.oauth,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return _failure(
        failureMsg ?? error.toString(),
        provider: provider,
        type: AuthType.oauth,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }
}
