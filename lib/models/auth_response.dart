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

  // ------------------------------------------------------------------
  // Getters
  // ------------------------------------------------------------------

  bool get isInitial => _initial ?? false;

  bool get isLoading => _loading ?? false;

  bool get isError => error.isNotEmpty;

  bool get isMessage => message.isNotEmpty;

  bool get hasStatus => _state != null;

  String get error => _error ?? '';

  String get message => _message ?? '';

  Provider get provider => _provider ?? Provider.email;

  AuthStatus get status => _state ?? AuthStatus.unauthenticated;

  AuthType get type => _type ?? AuthType.none;

  bool isCurrentProvider(Provider value) => provider == value;

  // ------------------------------------------------------------------
  // Named constructors
  // ------------------------------------------------------------------

  const AuthResponse.initial({String? msg, Provider? provider, AuthType? type})
      : this._(initial: true, msg: msg, provider: provider, type: type);

  const AuthResponse.loading([Provider? provider, AuthType? type])
      : this._(loading: true, provider: provider, type: type);

  const AuthResponse.guest(
    T? data, {
    String? msg,
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
    String? msg,
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
    String? msg,
    Provider? provider,
    AuthType? type,
  }) : this._(
          state: AuthStatus.unauthenticated,
          msg: msg,
          provider: provider,
          type: type,
        );

  const AuthResponse.unauthorized({
    String? msg,
    Provider? provider,
    AuthType? type,
  }) : this._(
          state: AuthStatus.unauthorized,
          error: msg,
          provider: provider,
          type: type,
        );

  const AuthResponse.message(String msg, {Provider? provider, AuthType? type})
      : this._(msg: msg, provider: provider, type: type);

  const AuthResponse.failure(String msg, {Provider? provider, AuthType? type})
      : this._(error: msg, provider: provider, type: type);

  const AuthResponse.data(
    T? data, {
    AuthStatus? state,
    String? msg,
    Provider? provider,
    AuthType? type,
  }) : this._(
          data: data,
          state: state,
          msg: msg,
          provider: provider,
          type: type,
        );

  // ------------------------------------------------------------------
  // Private canonical constructor
  // ------------------------------------------------------------------

  const AuthResponse._({
    this.data,
    bool? initial,
    bool? loading,
    String? error,
    String? msg,
    Provider? provider,
    AuthStatus? state,
    AuthType? type,
  })  : _initial = initial,
        _loading = loading,
        _error = error,
        _message = msg,
        _provider = provider,
        _state = state,
        _type = type;

  // ------------------------------------------------------------------
  // Debug
  // ------------------------------------------------------------------

  @override
  String toString() {
    return 'AuthResponse('
        'status: ${_state?.name}, '
        'isInitial: $isInitial, '
        'isLoading: $isLoading, '
        'error: $_error, '
        'message: $_message, '
        'provider: ${_provider?.name}, '
        'type: ${_type?.name}, '
        'data: $data'
        ')';
  }
}
