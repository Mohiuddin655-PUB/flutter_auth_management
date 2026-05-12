part of 'authorizer.dart';

mixin _AuthLifecycleMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T> {
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    try {
      _subscription?.cancel();
    } catch (_) {}
    _subscription = null;

    for (final disposer in [
      () => _errorNotifier.dispose(),
      () => _loadingNotifier.dispose(),
      () => _messageNotifier.dispose(),
      () => _statusNotifier.dispose(),
      () => _userNotifier.dispose(),
    ]) {
      try {
        disposer();
      } catch (_) {}
    }
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
        _emitStatus(AuthResponse.authenticated(cached));
        _emitUser(cached);
      }

      String? rawUid;
      try {
        rawUid = await delegate.rawUid;
      } catch (_) {
        rawUid = null;
      }
      if (_disposed) return;

      if (rawUid == null || rawUid.isEmpty) {
        if (isCachedLoggedIn) await _clearLocal();
        if (_disposed) return;
        _emitUser(null);
        _emitStatus(const AuthResponse.unauthenticated());
        return;
      }

      T? remote;
      try {
        remote = await _backup.onFetchUser(rawUid);
      } catch (_) {
        remote = null;
      }
      if (_disposed) return;

      if (remote != null) {
        if (remote.isLoggedIn) {
          await _backup.setAsLocal(remote);
          if (_disposed) return;
          _emitStatus(AuthResponse.authenticated(remote));
          _emitUser(remote);
        } else {
          await _clearLocal();
          if (_disposed) return;
          _emitUser(null);
          _emitStatus(const AuthResponse.unauthenticated());
        }
      } else {
        if (isCachedLoggedIn) {
          _emitStatus(AuthResponse.authenticated(cached));
          _emitUser(cached);
        } else {
          await _clearLocal();
          if (_disposed) return;
          _emitUser(null);
          _emitStatus(const AuthResponse.unauthenticated());
        }
      }

      if (listening) {
        try {
          await _subscription?.cancel();
        } catch (_) {}
        if (_disposed) return;
        _subscription = _backup.onListenUser(rawUid).listen(
          (remote) async {
            if (_disposed) return;
            if (remote != null && remote.isLoggedIn) {
              await _backup.setAsLocal(remote);
              if (_disposed) return;
              _emitStatus(AuthResponse.authenticated(remote));
              _emitUser(remote);
            } else if (remote != null && !remote.isLoggedIn) {
              await _clearLocal();
              if (_disposed) return;
              _emitUser(null);
              _emitStatus(const AuthResponse.unauthenticated());
            }
          },
          onError: (e) {
            if (!_disposed) _errorNotifier.value = e.toString();
          },
          cancelOnError: false,
        );
      }
    } finally {
      _initializing = false;
    }
  }
}
