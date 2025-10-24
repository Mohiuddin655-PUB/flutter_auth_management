enum AuthType {
  biometric,
  oauth,
  delete,
  login,
  logout,
  register,
  otp,
  phone,
  signedIn,
  none;

  bool get isBiometric => this == biometric;

  bool get isOAuth => this == oauth;

  bool get isDelete => this == delete;

  bool get isLogin => this == login;

  bool get isLogout => this == logout;

  bool get isOTP => this == otp;

  bool get isPhone => this == phone;

  bool get isRegister => this == register;

  bool get isSignedIn => this == signedIn;

  bool get isNone => this == none;
}
