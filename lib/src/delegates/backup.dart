import 'dart:convert';
import 'dart:core';

import '../models/auth.dart';

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

  Future<T?> get cache {
    return _r(key).then((value) {
      if (value.isNotEmpty) {
        return build(value);
      } else {
        return null;
      }
    });
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
    } catch (error) {
      return {};
    }
  }

  Future<bool> _w(String key, Backup? snapshot) async {
    try {
      if (snapshot == null || snapshot.isEmpty) return false;
      final value = jsonEncode(snapshot);
      if (value.isEmpty) return false;
      return writer(key, value);
    } catch (error) {
      return false;
    }
  }

  Future<bool> set(T? data) => _w(key, data?.source);

  Future<bool> update(Map<String, dynamic> data) {
    return cache.then((value) {
      if (value != null) {
        final current = value.source..addAll(data);
        return _w(key, current);
      } else {
        return false;
      }
    });
  }

  Future<bool> clear() => writer(key, null);

  Future<T?> onFetchUser(String id);

  Future<void> onCreateUser(T data);

  Future<void> onDeleteUser(String id);

  Future<void> onUpdateUser(String id, Map<String, dynamic> data);

  T build(Map<String, dynamic> source);
}
