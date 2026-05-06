part of 'authorizer.dart';

abstract class _AuthorizerBase<T extends Auth> {
  final AuthKeys keys;
  final AuthMessages msg;
  final AuthDelegate delegate;
  late final _AuthBackup<T> _backup;

  final _errorNotifier = ValueNotifier('');
  final _loadingNotifier = ValueNotifier(false);
  final _messageNotifier = ValueNotifier('');
  final _userNotifier = ValueNotifier<T?>(null);
  final _statusNotifier = ValueNotifier(AuthStatus.unauthenticated);

  Object? _args;
  String? _id;
  StreamSubscription? _subscription;
  bool _disposed = false;
  bool _initializing = false;
  bool _backupEmitEnabled = true;

  _AuthorizerBase({
    required this.delegate,
    required AuthBackupDelegate<T> backup,
    this.keys = const AuthKeys(),
    this.msg = const AuthMessages(),
  }) {
    _backup = _AuthBackup<T>(backup, _emitFromBackup);
  }

  /// Raw cached auth — may be null or logged-out.
  Future<T?> get _cachedAuth => _backup.cache;

  /// Filtered auth — returns null if not currently logged in.
  Future<T?> get auth async {
    try {
      final value = await _cachedAuth;
      if (value == null || !value.isLoggedIn) return null;
      return value;
    } catch (_) {
      return null;
    }
  }

  bool get hasAnonymous => delegate.isAnonymous;

  /// Clears local cached auth and surfaces errors silently.
  Future<bool> _clearLocal() async {
    try {
      return await _backup.clear();
    } catch (error) {
      if (!_disposed) _errorNotifier.value = error.toString();
      return false;
    }
  }

  /// Implemented by [_AuthEmitMixin].
  void _emitFromBackup(AuthResponse<T> data);
}
