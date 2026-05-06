part of 'authorizer.dart';

mixin _AuthEmailMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T>, _AuthUpdateMixin<T> {
  Future<AuthResponse<T>> signInByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback<T>? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithEmailOrUsername(
      provider: 'EMAIL',
      type: AuthType.login,
      doneMsg: msg.signInWithEmail.done,
      failureMsg: msg.signInWithEmail.failure,
      authenticator: authenticator,
      onBiometric: onBiometric,
      signIn: () => delegate.signInWithEmailNPassword(
        authenticator.email,
        authenticator.password,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signUpByEmail(
    EmailAuthenticator authenticator, {
    SignByBiometricCallback<T>? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithEmailOrUsername(
      provider: 'EMAIL',
      type: AuthType.register,
      doneMsg: msg.signUpWithEmail.done,
      failureMsg: msg.signUpWithEmail.failure,
      authenticator: authenticator,
      onBiometric: onBiometric,
      isSignUp: true,
      signIn: () => delegate.signUpWithEmailNPassword(
        authenticator.email,
        authenticator.password,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signInByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback<T>? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithEmailOrUsername(
      provider: 'USERNAME',
      type: AuthType.login,
      doneMsg: msg.signInWithUsername.done,
      failureMsg: msg.signInWithUsername.failure,
      authenticator: authenticator,
      onBiometric: onBiometric,
      signIn: () => delegate.signInWithUsernameNPassword(
        authenticator.username,
        authenticator.password,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> signUpByUsername(
    UsernameAuthenticator authenticator, {
    SignByBiometricCallback<T>? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return _signInWithEmailOrUsername(
      provider: 'USERNAME',
      type: AuthType.register,
      doneMsg: msg.signUpWithUsername.done,
      failureMsg: msg.signUpWithUsername.failure,
      authenticator: authenticator,
      onBiometric: onBiometric,
      isSignUp: true,
      signIn: () => delegate.signUpWithUsernameNPassword(
        authenticator.username,
        authenticator.password,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }

  Future<AuthResponse<T>> _signInWithEmailOrUsername({
    required String provider,
    required AuthType type,
    required String? doneMsg,
    required String? failureMsg,
    required Authenticator authenticator,
    required _OAuthSignIn signIn,
    SignByBiometricCallback<T>? onBiometric,
    bool isSignUp = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      AuthResponse.loading(type),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final hasAnonymous = this.hasAnonymous;
      final response = await signIn();
      if (!response.isSuccessful) {
        return _failure(
          response.error,
          type: type,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = response.data;
      final uid = result?.uid ?? '';
      if (result == null || uid.isEmpty) {
        return _failure(
          msg.authorization,
          type: type,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final value = await _update(
        id: uid,
        hasAnonymous: hasAnonymous,
        onBiometric: onBiometric,
        updateMode: !isSignUp,
        data: {
          keys.id: uid,
          keys.loggedIn: true,
          keys.loggedInTime: EntityHelper.generateTimeMills,
          keys.provider: provider,
          if (authenticator is EmailAuthenticator) ...{
            keys.email: authenticator.email,
            keys.password: authenticator.password,
          } else if (authenticator is UsernameAuthenticator) ...{
            keys.username: authenticator.username,
            keys.password: authenticator.password,
          }
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: doneMsg,
          type: type,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return _failure(
        failureMsg ?? error.toString(),
        type: type,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }
}
