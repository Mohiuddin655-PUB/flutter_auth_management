part of 'authorizer.dart';

mixin _AuthSignOutMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T> {
  Future<AuthResponse<T>> signOut({
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    try {
      emit(
        AuthResponse.loading(AuthType.logout),
        args: args,
        id: id,
        notifiable: notifiable,
      );

      final response = await delegate.signOut();
      if (!response.isSuccessful) {
        return _failure(
          response.error,
          type: AuthType.logout,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      _backupEmitEnabled = false;
      try {
        await _clearLocal();
      } finally {
        _backupEmitEnabled = true;
      }

      return emit(
        AuthResponse.unauthenticated(
          msg: msg.signOut.done,
          type: AuthType.logout,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      _backupEmitEnabled = true;
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

    final data = await auth;
    if (data == null) {
      return emit(
        AuthResponse.data(
          data,
          msg: msg.loggedIn.failure,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }

    try {
      final response = await delegate.delete();
      if (!response.isSuccessful) {
        return emit(
          AuthResponse.data(
            data,
            msg: response.message,
            type: AuthType.delete,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      await _clearLocal();
      await _backup.onDeleteUser(data.id);
      await delegate.signOut();

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
      return emit(
        AuthResponse.data(
          data,
          msg: msg.delete.failure ?? error.toString(),
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }
}
