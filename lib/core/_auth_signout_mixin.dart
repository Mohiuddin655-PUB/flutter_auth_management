part of 'authorizer.dart';

mixin _AuthSignOutMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T> {
  Future<AuthResponse<T>> signOut({
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      AuthResponse.loading(AuthType.logout),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    final opToken = _beginOp();

    try {
      final response = await delegate.signOut();
      if (!_isOpAlive(opToken)) {
        return AuthResponse.failure('Cancelled', type: AuthType.logout);
      }
      if (!response.isSuccessful) {
        return await _failure(
          response.error,
          type: AuthType.logout,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final cleared = await _clearLocalQuietly();

      if (!_isOpAlive(opToken)) {
        return AuthResponse.failure('Cancelled', type: AuthType.logout);
      }

      return await emit(
        AuthResponse<T>.unauthenticated(
          msg: msg.signOut.done ?? (cleared ? null : 'Signed out'),
          type: AuthType.logout,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return await _failure(
        msg.signOut.failure ?? error.toString(),
        type: AuthType.logout,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> delete({
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(AuthType.delete),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    final opToken = _beginOp();

    final data = await auth;
    if (data == null) {
      return emit(
        AuthResponse.failure(
          msg.loggedIn.failure ?? 'Not logged in',
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }

    try {
      final response = await delegate.delete();
      if (!_isOpAlive(opToken)) {
        return AuthResponse.failure('Cancelled', type: AuthType.delete);
      }
      if (!response.isSuccessful) {
        return await _failure(
          response.error.isNotEmpty
              ? response.error
              : (msg.delete.failure ?? 'Delete failed'),
          type: AuthType.delete,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      try {
        await _backup.onDeleteUser(data.id);
      } catch (_) {}

      try {
        await delegate.signOut();
      } catch (_) {}

      await _clearLocalQuietly();

      if (!_isOpAlive(opToken)) {
        return AuthResponse.failure('Cancelled', type: AuthType.delete);
      }

      return await emit(
        AuthResponse.unauthenticated(
          msg: msg.delete.done,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return await _failure(
        msg.delete.failure ?? error.toString(),
        type: AuthType.delete,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  /// Clears the cached user without the backup's own unauthenticated emit: the caller emits its own.
  Future<bool> _clearLocalQuietly() async {
    final prev = _backupEmitEnabled;
    _backupEmitEnabled = false;
    try {
      return await _clearLocal();
    } finally {
      _backupEmitEnabled = prev;
    }
  }
}
