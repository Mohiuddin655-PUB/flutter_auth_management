part of 'authorizer.dart';

class _Backup<T extends Auth> {
  final AuthBackupDelegate<T> delegate;

  final void Function(AuthResponse<T>) _emit;

  int _updateGeneration = 0;

  _Backup(this.delegate, this._emit);

  Future<T?> get cache async {
    try {
      return await delegate.cache;
    } catch (_) {
      return null;
    }
  }

  E? encryptor<E extends Object?>(String key, E? value) {
    return delegate.encryptor(key, value);
  }

  Future<T?> get([bool remotely = false]) async {
    final value = await cache;
    if (value == null || !value.isLoggedIn) return null;
    if (!remotely) return value;
    return delegate.onFetchUser(value.id);
  }

  Future<bool> set(T? data) async {
    if (data == null) return false;
    return setAsLocal(data);
  }

  Future<bool> setAsLocal(T? data) async {
    final current = await cache;
    final target = data ?? current;
    if (target == null) return false;

    final ok = await delegate.set(target).onError((_, __) => false);
    if (ok) _emit(AuthResponse.data(target));
    return ok;
  }

  Future<bool> update(Map<String, dynamic> data) async {
    if (data.isEmpty) return false;

    final generation = ++_updateGeneration;
    bool isCurrent() => _updateGeneration == generation;

    final local = await cache;
    if (!isCurrent()) return false;

    if (local == null || !local.isLoggedIn || local.id.isEmpty) return false;

    final old = local.filtered;
    final parsed = data.map((key, value) {
      if (_isPrimitive(value)) return MapEntry(key, value);
      return MapEntry(key, delegate.nonEncodableObjectParser(value, old[key]));
    });

    final merged = {...old, ...parsed}..removeWhere((_, v) => v == null);
    final updated = build(merged);

    final localOk = await setAsLocal(updated);
    if (!isCurrent()) return false;
    if (!localOk) return false;

    try {
      await onUpdateUser(local.id, data, false);
      if (!isCurrent()) return false;
      return true;
    } catch (_) {
      if (isCurrent()) {
        _emit(AuthResponse.loading());
        await setAsLocal(local);
      }
      return false;
    }
  }

  Future<bool> save({
    required String id,
    required bool hasAnonymous,
    Map<String, dynamic> initials = const {},
    Map<String, dynamic> updates = const {},
    bool cacheUpdateMode = false,
  }) async {
    if (id.isEmpty) return false;

    if (cacheUpdateMode) {
      final ok = await delegate.update(updates);
      if (ok) {
        final refreshed = await cache;
        if (refreshed != null) _emit(AuthResponse.data(refreshed));
      }
      return ok;
    }

    final remote = await onFetchUser(id);

    if (remote == null || !remote.isAuthenticated) {
      if (initials.isEmpty) return false;
      final user = build(initials);
      try {
        await onCreateUser(user);
      } catch (_) {
        return false;
      }
      return setAsLocal(user);
    }

    try {
      await onUpdateUser(id, updates, hasAnonymous);
    } catch (_) {
      return false;
    }

    final current = {...remote.filtered, ...updates};
    return setAsLocal(build(current));
  }

  Future<bool> clear() async {
    try {
      final ok = await delegate.clear();
      if (ok) _emit(AuthResponse.unauthenticated());
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<T?> onFetchUser(String id) => delegate.onFetchUser(id);

  Stream<T?> onListenUser(String id) => delegate.onListenUser(id);

  Future<void> onCreateUser(T data) => delegate.onCreateUser(data);

  Future<void> onUpdateUser(
    String id,
    Map<String, dynamic> data,
    bool hasAnonymous,
  ) =>
      delegate.onUpdateUser(id, data, hasAnonymous);

  Future<void> onDeleteUser(String id) => delegate.onDeleteUser(id);

  T build(Map<dynamic, dynamic> source) => delegate.build(source);

  static bool _isPrimitive(Object? value) {
    return value == null ||
        value is num ||
        value is bool ||
        value is String ||
        value is List ||
        value is Map;
  }
}
