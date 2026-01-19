part of 'authorizer.dart';

class _Backup<T extends Auth> {
  final AuthBackupDelegate<T> delegate;

  const _Backup(this.delegate);

  Future<T?> get cache async {
    try {
      return delegate.cache;
    } catch (error) {
      return null;
    }
  }

  E? encryptor<E extends Object?>(String key, E? value) {
    return delegate.encryptor(key, value);
  }

  Future<T?> get([bool remotely = false]) {
    return cache.then((value) {
      if (value == null || !value.isLoggedIn) return null;
      if (!remotely) return value;
      return delegate.onFetchUser(value.id);
    });
  }

  Future<bool> set(T? data) async {
    if (data == null) return false;
    return update(data.filtered);
  }

  Future<bool> setAsLocal(T? data) {
    return cache.then((value) {
      return delegate.set(data ?? value).onError((_, __) => false);
    });
  }

  Future<bool> update(Map<String, dynamic> data) async {
    if (data.isEmpty) return false;
    return cache.then((local) {
      if (local == null || !local.isLoggedIn || local.id.isEmpty) return false;
      onUpdateUser(local.id, data, false);
      final merged = ObjectModifier.mergeMap(
        data,
        local.source,
        delegate.nonEncodableObjectParser,
      );
      final mergedObject = build(merged);
      return setAsLocal(mergedObject);
    });
  }

  Future<bool> save({
    required String id,
    required bool hasAnonymous,
    Map<String, dynamic> initials = const {},
    Map<String, dynamic> updates = const {},
    bool cacheUpdateMode = false,
  }) async {
    if (id.isEmpty) return false;
    if (cacheUpdateMode) return delegate.update(updates);
    final remote = await onFetchUser(id);
    if (remote == null || !remote.isAuthenticated) {
      final user = build(initials);
      await onCreateUser(user);
      return delegate.set(user);
    }
    await onUpdateUser(id, updates, hasAnonymous);
    Map<String, dynamic> current = Map.from(remote.filtered);
    current.addAll(updates);
    return delegate.set(build(current));
  }

  Future<bool> clear() async {
    try {
      return delegate.clear();
    } catch (error) {
      return false;
    }
  }

  Future<T?> onFetchUser(String id) => delegate.onFetchUser(id);

  Future<void> onCreateUser(T data) => delegate.onCreateUser(data);

  Future<void> onUpdateUser(
    String id,
    Map<String, dynamic> data,
    bool hasAnonymous,
  ) {
    return delegate.onUpdateUser(id, data, hasAnonymous);
  }

  Future<void> onDeleteUser(String id) {
    return delegate.onDeleteUser(id);
  }

  T build(Map source) => delegate.build(source);
}
