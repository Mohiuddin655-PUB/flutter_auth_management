part of 'authorizer.dart';

class _AuthBackup<T extends Auth> {
  final AuthBackupDelegate<T> delegate;

  final void Function(AuthResponse<T>) _emit;

  int _updateGeneration = 0;

  _AuthBackup(this.delegate, this._emit);

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

  E? decryptor<E extends Object?>(String key, E? value) {
    return delegate.decryptor(key, value);
  }

  Future<T?> get([bool remotely = false]) async {
    final value = await cache;
    if (value == null || !value.isLoggedIn) return null;
    if (!remotely) return value;
    try {
      return await delegate.onFetchUser(value.id);
    } catch (_) {
      return value;
    }
  }

  Future<bool> set(T? data) async {
    if (data == null) return false;
    return setAsLocal(data);
  }

  Future<bool> setAsLocal(T? data) async {
    final current = await cache;
    final target = data ?? current;
    if (target == null) return false;
    return await delegate.set(target).onError((e, st) => false);
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
      _emit(AuthResponse.data(updated));
      return true;
    } catch (_) {
      if (isCurrent()) {
        await setAsLocal(local);
        if (isCurrent()) _emit(AuthResponse.data(local));
      }
      return false;
    }
  }

  Future<bool> save({
    required String id,
    required bool hasAnonymous,
    Map<String, dynamic> data = const {},
    bool cacheUpdateMode = false,
  }) async {
    if (id.isEmpty) return false;

    final hasCache = (await cache) != null;
    final useCacheUpdate = cacheUpdateMode && hasCache;

    if (useCacheUpdate) {
      bool ok;
      try {
        ok = await delegate.update(data);
      } catch (_) {
        ok = false;
      }
      if (ok) {
        final refreshed = await cache;
        if (refreshed != null) _emit(AuthResponse.data(refreshed));
      }
      return ok;
    }

    T? remote;
    try {
      remote = await onFetchUser(id);
    } catch (_) {
      remote = null;
    }

    if (remote == null) {
      if (data.isEmpty) return false;
      final user = build(data);
      try {
        await onCreateUser(user);
      } catch (_) {
        return false;
      }
      return setAsLocal(user);
    }

    try {
      await onUpdateUser(id, data, hasAnonymous);
    } catch (_) {
      return false;
    }

    return setAsLocal(build({...remote.filtered, ...data}));
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
  ) {
    return delegate.onUpdateUser(id, data, hasAnonymous);
  }

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
