import 'auth.dart';
import 'auth_status.dart';
import 'auth_type.dart';
import 'provider.dart';

class AuthResponse<T extends Auth> {
  final bool? _initial;
  final bool? _loading;
  final String? _error;
  final String? _message;
  final T? data;
  final Provider? _provider;
  final AuthStatus? _state;
  final AuthType? _type;

  bool get isInitial => _initial ?? false;

  bool get isLoading => _loading ?? false;

  bool get isError => error.isNotEmpty;

  bool get isMessage => message.isNotEmpty;

  bool get isState => _state != null;

  String get error => _error ?? "";

  String get message => _message ?? "";

  Provider get provider => _provider ?? Provider.email;

  AuthStatus get status => _state ?? AuthStatus.unauthenticated;

  AuthType get type => _type ?? AuthType.none;

  bool isCurrentProvider(Provider value) => provider == value;

  const AuthResponse.initial({
    dynamic msg,
    Provider? provider,
    AuthType? type,
  }) : this._(initial: true, msg: msg, provider: provider, type: type);

  const AuthResponse.loading([Provider? provider, AuthType? type])
      : this._(loading: true, provider: provider, type: type);

  const AuthResponse.guest(
    T? data, {
    dynamic msg,
    Provider? provider,
    AuthType? type,
  }) : this._(
          state: AuthStatus.guest,
          data: data,
          msg: msg,
          provider: provider,
          type: type,
        );

  const AuthResponse.authenticated(
    T? data, {
    dynamic msg,
    Provider? provider,
    AuthType? type,
  }) : this._(
          state: AuthStatus.authenticated,
          data: data,
          msg: msg,
          provider: provider,
          type: type,
        );

  const AuthResponse.unauthenticated({
    dynamic msg,
    Provider? provider,
    AuthType? type,
  }) : this._(
          state: AuthStatus.unauthenticated,
          msg: msg,
          provider: provider,
          type: type,
        );

  const AuthResponse.unauthorized({
    dynamic msg,
    Provider? provider,
    AuthType? type,
  }) : this._(
          state: AuthStatus.unauthorized,
          error: msg,
          provider: provider,
          type: type,
        );

  const AuthResponse.message(
    dynamic msg, {
    Provider? provider,
    AuthType? type,
  }) : this._(msg: msg, provider: provider, type: type);

  const AuthResponse.failure(
    dynamic msg, {
    Provider? provider,
    AuthType? type,
  }) : this._(error: msg, provider: provider, type: type);

  const AuthResponse.rollback(
    T? data, {
    dynamic msg,
    Provider? provider,
    AuthType? type,
  }) : this._(data: data, msg: msg, provider: provider, type: type);

  const AuthResponse._({
    this.data,
    bool? initial,
    bool? loading,
    dynamic error,
    dynamic msg,
    Provider? provider,
    AuthStatus? state,
    AuthType? type,
  })  : _initial = initial,
        _loading = loading,
        _error = error != null ? "$error" : null,
        _message = msg != null ? "$msg" : null,
        _provider = provider,
        _state = state,
        _type = type;

  Map<String, dynamic> get _source {
    return {
      "isInitial": isInitial,
      "isLoading": isLoading,
      "isError": isError,
      "error": _error,
      "message": _message,
      "data": data,
      "provider": _provider,
      "status": _state,
      "type": _type,
    };
  }

  @override
  String toString() => "AuthResponse($_source)";
}
