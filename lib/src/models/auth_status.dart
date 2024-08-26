enum AuthStatus {
  guest,
  authenticated,
  unauthenticated,
  unauthorized;

  factory AuthStatus.from(String? source) {
    if (source == guest.name) {
      return AuthStatus.guest;
    } else if (source == authenticated.name) {
      return AuthStatus.authenticated;
    } else if (source == unauthenticated.name) {
      return AuthStatus.unauthenticated;
    } else {
      return AuthStatus.unauthorized;
    }
  }

  bool get isGuest => this == AuthStatus.guest;

  bool get isAuthenticated => this == AuthStatus.authenticated;

  bool get isUnauthenticated => this == AuthStatus.unauthenticated;

  bool get isUnauthorized => this == AuthStatus.unauthorized;
}
