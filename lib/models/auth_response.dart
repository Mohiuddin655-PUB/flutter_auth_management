import 'auth.dart';
import 'auth_status.dart';
import 'auth_type.dart';

class AuthResponse<T extends Auth> {
  final bool? _initial;
  final bool? _loading;
  final String? _error;
  final String? _message;
  final T? data;
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

  AuthStatus get status => _state ?? AuthStatus.unauthenticated;

  AuthType get type => _type ?? AuthType.none;

  // ------------------------------------------------------------------
  // Named constructors
  // ------------------------------------------------------------------

  const AuthResponse.initial({String? msg, AuthType? type})
      : this._(initial: true, msg: msg, type: type);

  const AuthResponse.loading([AuthType? type])
      : this._(loading: true, type: type);

  const AuthResponse.guest(T? data, {String? msg, AuthType? type})
      : this._(state: AuthStatus.guest, data: data, msg: msg, type: type);

  const AuthResponse.authenticated(T? data, {String? msg, AuthType? type})
      : this._(
            state: AuthStatus.authenticated, data: data, msg: msg, type: type);

  const AuthResponse.unauthenticated({String? msg, AuthType? type})
      : this._(state: AuthStatus.unauthenticated, msg: msg, type: type);

  const AuthResponse.unauthorized({String? msg, AuthType? type})
      : this._(state: AuthStatus.unauthorized, error: msg, type: type);

  const AuthResponse.message(String msg, {AuthType? type})
      : this._(msg: msg, type: type);

  const AuthResponse.failure(String msg, {AuthType? type})
      : this._(error: msg, type: type);

  const AuthResponse.data(
    T? data, {
    AuthStatus? state,
    String? msg,
    AuthType? type,
  }) : this._(data: data, state: state, msg: msg, type: type);

  // ------------------------------------------------------------------
  // Private canonical constructor
  // ------------------------------------------------------------------

  const AuthResponse._({
    this.data,
    bool? initial,
    bool? loading,
    String? error,
    String? msg,
    AuthStatus? state,
    AuthType? type,
  })  : _initial = initial,
        _loading = loading,
        _error = error,
        _message = msg,
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
        'type: ${_type?.name}, '
        'data: $data'
        ')';
  }
}
