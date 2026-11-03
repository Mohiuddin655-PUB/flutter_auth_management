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
      final hasCache = cached != null && cached.isLoggedIn;
      if (initialCheck && hasCache) _signedInAs(cached);

      String? rawUid;
      try {
        rawUid = await delegate.rawUid;
      } catch (_) {
        rawUid = null;
      }
      if (_disposed) return;

      if (rawUid == null || rawUid.isEmpty) {
        await _signedOutLocally(clear: hasCache);
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
        await _applyRemote(remote);
      } else if (hasCache) {
        _signedInAs(cached);
      } else {
        await _signedOutLocally();
      }
      if (_disposed || !listening) return;

      try {
        await _subscription?.cancel();
      } catch (_) {}
      if (_disposed) return;
      _subscription = _backup.onListenUser(rawUid).listen(
        (remote) {
          if (!_disposed && remote != null) _applyRemote(remote);
        },
        onError: (e) {
          if (!_disposed) _errorNotifier.value = e.toString();
        },
        cancelOnError: false,
      );
    } finally {
      _initializing = false;
    }
  }

  /// The user as the server has it: kept and signed in, or signed out when it says so.
  Future<void> _applyRemote(T remote) async {
    if (!remote.isLoggedIn) return _signedOutLocally();
    await _backup.setAsLocal(remote);
    if (!_disposed) _signedInAs(remote);
  }

  void _signedInAs(T user) {
    _emitStatus(AuthResponse.authenticated(user));
    _emitUser(user);
  }

  Future<void> _signedOutLocally({bool clear = true}) async {
    if (clear) await _clearLocal();
    if (_disposed) return;
    _emitUser(null);
    _emitStatus(const AuthResponse.unauthenticated());
  }
}
