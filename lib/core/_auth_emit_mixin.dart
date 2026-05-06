part of 'authorizer.dart';

mixin _AuthEmitMixin<T extends Auth> on _AuthorizerBase<T> {
  Future<AuthResponse<T>> emit(
    AuthResponse<T> data, {
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    _args = args;
    _id = id;

    if (notifiable) {
      if (data.isLoading) {
        _emitLoading(true);
      } else {
        _emitLoading(false);
        _emitError(data);
        _emitMessage(data);
        _emitStatus(data);
        if (data.data != null) {
          _emitUser(data.data);
        } else if (data.status == AuthStatus.unauthenticated) {
          _emitUser(null);
        }
      }
    } else {
      if (!data.isLoading && data.data != null) _emitUser(data.data);
    }

    return data;
  }

  @override
  void _emitFromBackup(AuthResponse<T> data) {
    if (_disposed || !_backupEmitEnabled) return;

    if (data.isLoading) {
      _emitLoading(true);
      return;
    }

    _emitLoading(false);

    if (data.hasStatus) {
      _emitStatus(data);
      if (data.status == AuthStatus.unauthenticated) {
        _emitUser(null);
        return;
      }
    }

    if (data.data != null) _emitUser(data.data);
  }

  void _emitError(AuthResponse<T> data) {
    if (data.isError) _errorNotifier.value = data.error;
  }

  void _emitLoading(bool value) {
    if (_loadingNotifier.value != value) _loadingNotifier.value = value;
  }

  void _emitMessage(AuthResponse<T> data) {
    if (data.isMessage) _messageNotifier.value = data.message;
  }

  void _emitStatus(AuthResponse<T> data) {
    _statusNotifier.value = data.status;
  }

  T? _emitUser(T? data) {
    if (_disposed) return data;
    _userNotifier.value = data;
    return data;
  }

  Future<AuthResponse<T>> _failure(
    Object? msgOrError, {
    required AuthType type,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    return emit(
      AuthResponse.failure(
        msgOrError?.toString() ?? 'An unexpected error occurred.',
        type: type,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }
}
