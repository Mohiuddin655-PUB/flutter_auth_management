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

  Future<T?> get cache => source.cache.onError((_, __) => null);

  Future<T?> get([bool remotely = false]) {
    return cache.then((value) {
      if (value != null && value.isLoggedIn) {
        if (remotely) {
          return source.onFetchUser(value.id);
        } else {
          return value;
        }
      } else {
        return null;
      }
    });
  }

  Future<bool> set(T? data) async {
    if (data == null) return false;
    return update(data.source);
  }

  Future<bool> setAsLocal(T? data) {
    return cache.then((value) {
      return source.set(data ?? value).onError((_, __) => false);
    });
  }

  Future<bool> update(Map<String, dynamic> data) async {
    if (data.isEmpty) return false;
    try {
      return cache.then((local) async {
        if (local != null && local.isLoggedIn && local.id.isNotEmpty) {
          await onUpdateUser(local.id, data);
          return onFetchUser(local.id).then((value) {
            if (value != null) {
              return source.set(value);
            } else {
              return source.update(data);
            }
          });
        } else {
          return false;
        }
      });
    } catch (_) {
      return false;
    }
  }

  Future<bool> save({
    required String id,
    Map<String, dynamic> initials = const {},
    Map<String, dynamic> updates = const {},
    bool cacheUpdateMode = false,
  }) async {
    if (id.isEmpty) return false;
    try {
      if (cacheUpdateMode) {
        return source.update(updates);
      } else {
        final remote = await onFetchUser(id);
        if (remote != null) {
          await onUpdateUser(id, updates);
          Map<String, dynamic> current = Map.from(remote.source);
          current.addAll(updates);
          return source.set(build(current));
        } else {
          final cachedUser = await cache;
          if (cachedUser == null) {
            final user = build(initials);
            await onCreateUser(user);
            return source.set(user);
          } else {
            return source.update(updates);
          }
        }
      }
    } catch (_) {
      return false;
    }
  }

  Future<bool> clear() {
    return source.clear();
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
