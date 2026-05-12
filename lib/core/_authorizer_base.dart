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

  int _opGeneration = 0;

  _AuthorizerBase({
    required this.delegate,
    required AuthBackupDelegate<T> backup,
    this.keys = const AuthKeys(),
    this.msg = const AuthMessages(),
  }) {
    _backup = _AuthBackup<T>(backup, _emitFromBackup);
  }

  int _beginOp() => ++_opGeneration;

  bool _isOpAlive(int token) => !_disposed && _opGeneration == token;

  bool get isDisposed => _disposed;

  Future<T?> get _cachedAuth => _backup.cache;

  Future<T?> get auth async {
    try {
      final value = await _cachedAuth;
      if (value == null || !value.isLoggedIn) return null;
      return value;
    } catch (_) {
      return null;
    }
  }

  bool get hasAnonymous {
    try {
      return delegate.isAnonymous;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _clearLocal() async {
    try {
      return await _backup.clear();
    } catch (error) {
      if (!_disposed) _errorNotifier.value = error.toString();
      return false;
    }
  }

  void _emitFromBackup(AuthResponse<T> data);
}
