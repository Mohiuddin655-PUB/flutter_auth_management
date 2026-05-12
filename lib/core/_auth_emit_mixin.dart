part of 'authorizer.dart';

mixin _AuthEmitMixin<T extends Auth> on _AuthorizerBase<T> {
  Future<AuthResponse<T>> emit(
    AuthResponse<T> data, {
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    if (_disposed) return data;

    _args = args;
    _id = id;

    if (data.isLoading) {
      if (notifiable) _emitLoading(true);
      return data;
    }

    if (notifiable) _emitLoading(false);

    if (data.hasStatus) {
      _emitStatus(data);
      if (data.status == AuthStatus.unauthenticated) {
        _emitUser(null);
      } else if (data.data != null) {
        _emitUser(data.data);
      }
    } else if (data.data != null) {
      _emitUser(data.data);
    }

    if (notifiable) {
      if (data.isError) {
        _emitError(data);
      } else {
        _clearError();
      }
      if (data.isMessage) _emitMessage(data);
    }

    return data;
  }

  @override
  void _emitFromBackup(AuthResponse<T> data) {
    if (_disposed || !_backupEmitEnabled) return;

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
    if (_disposed) return;
    if (data.isError) _errorNotifier.value = data.error;
  }

  void _clearError() {
    if (_disposed) return;
    if (_errorNotifier.value.isNotEmpty) _errorNotifier.value = '';
  }

  void _emitLoading(bool value) {
    if (_disposed) return;
    if (_loadingNotifier.value != value) _loadingNotifier.value = value;
  }

  void _emitMessage(AuthResponse<T> data) {
    if (_disposed) return;
    if (data.isMessage) _messageNotifier.value = data.message;
  }

  void _emitStatus(AuthResponse<T> data) {
    if (_disposed) return;
    if (_statusNotifier.value != data.status) {
      _statusNotifier.value = data.status;
    }
  }

  T? _emitUser(T? data) {
    if (_disposed) return data;
    if (_userNotifier.value != data) _userNotifier.value = data;
    return data;
  }

  Future<AuthResponse<T>> _failure(
    Object? msgOrError, {
    required AuthType type,
    Object? args,
    String? id,
    bool notifiable = true,
  }) {
    final text = msgOrError?.toString().trim() ?? '';
    return emit(
      AuthResponse.failure(
        text.isEmpty ? 'An unexpected error occurred.' : text,
        type: type,
      ),
      args: args,
      id: id,
      notifiable: notifiable,
    );
  }
}
