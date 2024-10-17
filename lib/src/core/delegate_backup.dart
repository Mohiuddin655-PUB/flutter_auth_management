import '../models/auth.dart';

abstract class BackupDelegate<T extends Auth> {
  Future<void> create(T data);

  Future<void> delete(String id);

  Future<T?> get(String id);

  Future<void> update(String id, Map<String, dynamic> data);

  T build(Map<String, dynamic> source);
}
