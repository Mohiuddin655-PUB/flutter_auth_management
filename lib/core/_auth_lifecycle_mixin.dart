part of 'authorizer.dart';

mixin _AuthLifecycleMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T> {
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    _errorNotifier.dispose();
    _loadingNotifier.dispose();
    _messageNotifier.dispose();
    _statusNotifier.dispose();
    _userNotifier.dispose();
  }

  Future<void> initialize({
    bool initialCheck = true,
    bool listening = false,
  }) async {
    if (_disposed || _initializing) return;
    _initializing = true;

    try {
      final cached = await _backup.cache;
      if (_disposed) return;

      final isCachedLoggedIn = cached != null && cached.isLoggedIn;
      if (initialCheck && isCachedLoggedIn) {
        _statusNotifier.value = AuthStatus.authenticated;
        _emitUser(cached);
      }

      final rawUid = await delegate.rawUid;
      if (_disposed) return;

      if (rawUid == null || rawUid.isEmpty) {
        if (isCachedLoggedIn) await _clearLocal();
        if (_disposed) return;
        _emitUser(null);
        _statusNotifier.value = AuthStatus.unauthenticated;
        return;
      }

      final remote = await _backup.onFetchUser(rawUid);
      if (_disposed) return;

      if (remote != null) {
        if (remote.isLoggedIn) {
          await _backup.setAsLocal(remote);
          if (_disposed) return;
          _statusNotifier.value = AuthStatus.authenticated;
          _emitUser(remote);
        } else {
          await _clearLocal();
          if (_disposed) return;
          _emitUser(null);
          _statusNotifier.value = AuthStatus.unauthenticated;
        }
      }

      if (listening) {
        await _subscription?.cancel();
        if (_disposed) return;
        _subscription = _backup.onListenUser(rawUid).listen(
          (remote) async {
            if (_disposed) return;
            if (remote != null && remote.isLoggedIn) {
              await _backup.setAsLocal(remote);
              if (_disposed) return;
              _statusNotifier.value = AuthStatus.authenticated;
              _emitUser(remote);
            } else {
              await _clearLocal();
              if (_disposed) return;
              _emitUser(null);
              _statusNotifier.value = AuthStatus.unauthenticated;
            }
          },
          onError: (e) {
            if (!_disposed) _errorNotifier.value = e.toString();
          },
        );
      }
    } finally {
      _initializing = false;
    }
  }
}
