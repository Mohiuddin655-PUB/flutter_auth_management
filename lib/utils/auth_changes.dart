import '../models/auth.dart';
import '../models/auth_status.dart';

final class AuthChanges<T extends Auth> {
  final Object? args;
  final AuthStatus status;
  final T? user;

  const AuthChanges({
    required this.args,
    required this.status,
    required this.user,
  });
}
