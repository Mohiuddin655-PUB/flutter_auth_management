part of 'authorizer.dart';

mixin _AuthStateMixin<T extends Auth> on _AuthorizerBase<T> {
  Object? get args => _args;

  String? get id => _id;

  String get errorText => _errorNotifier.value;

  bool get loading => _loadingNotifier.value;

  String get message => _messageNotifier.value;

  AuthStatus get status => _statusNotifier.value;

  T? get user => _userNotifier.value;

  ValueNotifier<String> get liveError => _errorNotifier;

  ValueNotifier<bool> get liveLoading => _loadingNotifier;

  ValueNotifier<String> get liveMessage => _messageNotifier;

  ValueNotifier<AuthStatus> get liveStatus => _statusNotifier;

  ValueNotifier<T?> get liveUser => _userNotifier;

  Future<bool> get isLoggedIn async {
    final value = await auth;
    return value != null && value.isLoggedIn;
  }

  Future<bool> get isBiometricEnabled async {
    try {
      final value = await _cachedAuth;
      return value != null && value.isBiometric;
    } catch (error) {
      _errorNotifier.value = error.toString();
      return false;
    }
  }
}
