part of 'authorizer.dart';

mixin _AuthSignOutMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T> {
  Future<AuthResponse<T>> signOut({
    Provider? provider,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    try {
      emit(
        AuthResponse.loading(provider, AuthType.logout),
        args: args,
        id: id,
        notifiable: notifiable,
      );

      final response = await delegate.signOut(provider);
      if (!response.isSuccessful) {
        return _failure(
          response.error,
          provider: provider,
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
          provider: provider,
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
        provider: provider,
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
      const AuthResponse.loading(Provider.none, AuthType.delete),
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
          provider: Provider.none,
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
            provider: Provider.none,
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
          provider: Provider.none,
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
          provider: Provider.none,
          type: AuthType.delete,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }
}
