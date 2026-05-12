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
        return _failure(
          response.error,
          type: AuthType.logout,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final prev = _backupEmitEnabled;
      _backupEmitEnabled = false;
      bool cleared;
      try {
        cleared = await _clearLocal();
      } finally {
        _backupEmitEnabled = prev;
      }

      if (!_isOpAlive(opToken)) {
        return AuthResponse.failure('Cancelled', type: AuthType.logout);
      }

      final response2 = AuthResponse<T>.unauthenticated(
        msg: cleared ? msg.signOut.done : (msg.signOut.done ?? 'Signed out'),
        type: AuthType.logout,
      );
      return emit(response2, args: args, id: id, notifiable: notifiable);
    } catch (error) {
      return _failure(
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
        return _failure(
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

      final prev = _backupEmitEnabled;
      _backupEmitEnabled = false;
      try {
        await _clearLocal();
      } finally {
        _backupEmitEnabled = prev;
      }

      if (!_isOpAlive(opToken)) {
        return AuthResponse.failure('Cancelled', type: AuthType.delete);
      }

      return emit(
        AuthResponse.unauthenticated(
          msg: msg.delete.done,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return _failure(
        msg.delete.failure ?? error.toString(),
        type: AuthType.delete,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }
}
