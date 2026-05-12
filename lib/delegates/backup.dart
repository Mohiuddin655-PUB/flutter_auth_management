import 'dart:convert' show jsonDecode, jsonEncode;

import '../models/auth.dart' show Auth;
import '../models/key.dart' show AuthKeys;

typedef Backup = Map<String, dynamic>;
typedef BackupReader = Future<String?> Function(String key);
typedef BackupWriter = Future<bool> Function(String key, String? value);

abstract class AuthBackupDelegate<T extends Auth> {
  final String key;
  final BackupReader reader;
  final BackupWriter writer;

  const AuthBackupDelegate({
    this.key = AuthKeys.key,
    required this.reader,
    required this.writer,
  });

  Future<T?> get cache async {
    final value = await _r(key);
    if (value.isEmpty) return null;
    try {
      return build(value);
    } catch (_) {
      return null;
    }
  }

  Future<Backup> _r(String key) async {
    try {
      final root = await reader(key);
      if (root == null || root.isEmpty) return {};
      final output = jsonDecode(root);
      if (output is Backup) return output;
      if (output is Map) {
        return output.map((key, value) => MapEntry(key.toString(), value));
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<bool> _w(String key, Backup? snapshot) async {
    try {
      if (snapshot == null || snapshot.isEmpty) return false;
      final value = jsonEncode(snapshot);
      if (value.isEmpty) return false;
      return writer(key, value);
    } catch (_) {
      return false;
    }
  }

  E? encryptor<E extends Object?>(String key, E? value) => value;

  E? decryptor<E extends Object?>(String key, E? value) => value;

  Future<bool> set(T? data) => _w(key, data?.source);

  Future<bool> update(Map<String, dynamic> data) async {
    final value = await cache;
    if (value == null) return false;
    final current = value.source..addAll(data);
    return _w(key, current);
  }

  Future<bool> clear() async {
    try {
      return await writer(key, null);
    } catch (_) {
      return false;
    }
  }

  Future<T?> onFetchUser(String id);

  Stream<T?> onListenUser(String id);

  Future<void> onCreateUser(T data);

  Future<void> onDeleteUser(String id);

  Future<void> onUpdateUser(
    String id,
    Map<String, dynamic> data,
    bool hasAnonymous,
  );

  Object? nonEncodableObjectParser(Object? current, Object? old) {
    return current;
  }

  T build(Map source);
}
