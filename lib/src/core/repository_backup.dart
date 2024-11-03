import 'package:auth_management/core.dart';

class BackupRepository<T extends Auth> {
  final BackupDataSource<T> source;

  const BackupRepository(this.source);

  factory BackupRepository.create({
    String key = AuthKeys.key,
    required BackupReader reader,
    required BackupWriter writer,
    BackupDelegate<T>? delegate,
  }) {
    return BackupRepository(BackupDataSource(
      key: key,
      reader: reader,
      writer: writer,
      delegate: delegate,
    ));
  }

  Future<T?> get cache async {
    try {
      return source.cache;
    } catch (error) {
      return null;
    }
  }

  Future<T?> get([bool remotely = false]) {
    return cache.then((value) {
      if (value == null || !value.isLoggedIn) return null;
      if (!remotely) return value;
      return source.onFetchUser(value.id);
    });
  }

  Future<bool> set(T? data) async {
    if (data == null) return false;
    return update(data.filtered);
  }

  Future<bool> setAsLocal(T? data) {
    return cache.then((value) {
      return source.set(data ?? value).onError((_, __) => false);
    });
  }

  Future<bool> update(Map<String, dynamic> data) async {
    if (data.isEmpty) return false;
    return cache.then((local) {
      if (local == null || !local.isLoggedIn || local.id.isEmpty) return false;
      onUpdateUser(local.id, data);
      final x = local.filtered..addAll(data);
      final y = build(x);
      return setAsLocal(y);
    });
  }

  Future<bool> save({
    required String id,
    Map<String, dynamic> initials = const {},
    Map<String, dynamic> updates = const {},
    bool cacheUpdateMode = false,
  }) async {
    if (id.isEmpty) return false;
    if (cacheUpdateMode) return source.update(updates);
    final remote = await onFetchUser(id);
    if (remote != null) {
      await onUpdateUser(id, updates);
      Map<String, dynamic> current = Map.from(remote.filtered);
      current.addAll(updates);
      return source.set(build(current));
    }

    final cachedUser = await cache;
    if (cachedUser != null) return source.update(updates);
    final user = build(initials);
    await onCreateUser(user);
    return source.set(user);
  }

  Future<bool> clear() async {
    try {
      return source.clear();
    } catch (error) {
      return false;
    }
  }

  Future<T?> onFetchUser(String id) => source.onFetchUser(id);

  Future<void> onCreateUser(T data) {
    return source.onCreateUser(data);
  }

  Future<void> onUpdateUser(String id, Map<String, dynamic> data) {
    return source.onUpdateUser(id, data);
  }

  Future<void> onDeleteUser(String id) {
    return source.onDeleteUser(id);
  }

  T build(Map<String, dynamic> source) => this.source.build(source);
}
