part of 'authorizer.dart';

typedef _SignIn = Future<Response<Credential>> Function(bool Function() alive);

/// The one sign-in flow every method shares: loading, the delegate's sign-in, the user saved
/// through the backup, then authenticated or a failure. A newer operation cancels this one.
mixin _AuthSignInMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T>, _AuthUpdateMixin<T> {
  /// [signIn] gets whether this operation is still alive, to stop between its own steps.
  /// [data] is what is saved for the signed-in user. [linksAnonymous] passes on whether an
  /// anonymous user was signed in before.
  Future<AuthResponse<T>> _signIn({
    required AuthType type,
    required _SignIn signIn,
    required Map<String, dynamic> Function(String uid, Credential result) data,
    required String? doneMsg,
    required String? failureMsg,
    bool linksAnonymous = true,
    SignByBiometricCallback<T>? onBiometric,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    Future<AuthResponse<T>> fail(Object? error) {
      return _failure(
        error,
        type: type,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }

    emit(AuthResponse.loading(type),
        args: args, id: id, notifiable: notifiable);

    final opToken = _beginOp();
    bool alive() => _isOpAlive(opToken);
    final cancelled = AuthResponse<T>.failure('Cancelled', type: type);

    try {
      final hasAnonymous = linksAnonymous && this.hasAnonymous;
      final response = await signIn(alive);
      if (!alive()) return cancelled;
      if (!response.isSuccessful) return await fail(response.error);

      final result = response.data;
      final uid = result?.uid ?? '';
      if (result == null || uid.isEmpty) return await fail(msg.authorization);

      final value = await _update(
        id: uid,
        hasAnonymous: hasAnonymous,
        onBiometric: onBiometric,
        data: data(uid, result),
      );
      if (!alive()) return cancelled;
      if (value == null) return await fail(msg.authorization);

      return await emit(
        AuthResponse.authenticated(value, msg: doneMsg, type: type),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return await fail(failureMsg ?? error.toString());
    }
  }
}
