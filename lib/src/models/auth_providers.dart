enum AuthProviders {
  apple(id: "APPLE", name: "Apple"),
  facebook(id: "FACEBOOK", name: "facebook"),
  gameCenter(id: "GAME_CENTER", name: "Game Center"),
  github(id: "GITHUB", name: "Github"),
  google(id: "GOOGLE", name: "Google"),
  microsoft(id: "MICROSOFT", name: "Microsoft"),
  playGames(id: "PLAY_GAMES", name: "Play Games"),
  saml(id: "SAML", name: "SAML"),
  twitter(id: "TWITTER", name: "Twitter"),
  yahoo(id: "YAHOO", name: "YAHOO"),
  biometric(id: "BIOMETRIC", name: "Biometric"),
  email(id: "EMAIL", name: "Email"),
  guest(id: "GUEST", name: "Guest"),
  phone(id: "PHONE_NUMBER", name: "Phone Number"),
  username(id: "USERNAME", name: "Username"),
  none(id: "NONE", name: "None");

  final String id;
  final String name;

  const AuthProviders({
    required this.id,
    required this.name,
  });

  factory AuthProviders.from(Object? source) {
    final key = source?.toString().trim().toUpperCase();
    if (key == apple.id) {
      return AuthProviders.apple;
    } else if (key == facebook.id) {
      return AuthProviders.facebook;
    } else if (key == gameCenter.id) {
      return AuthProviders.gameCenter;
    } else if (key == github.id) {
      return AuthProviders.github;
    } else if (key == google.id) {
      return AuthProviders.google;
    } else if (key == microsoft.id) {
      return AuthProviders.microsoft;
    } else if (key == playGames.id) {
      return AuthProviders.playGames;
    } else if (key == saml.id) {
      return AuthProviders.saml;
    } else if (key == twitter.id) {
      return AuthProviders.twitter;
    } else if (key == yahoo.id) {
      return AuthProviders.yahoo;
    } else if (key == biometric.id) {
      return AuthProviders.biometric;
    } else if (key == email.id) {
      return AuthProviders.email;
    } else if (key == guest.id) {
      return AuthProviders.guest;
    } else if (key == phone.id) {
      return AuthProviders.phone;
    } else if (key == username.id) {
      return AuthProviders.username;
    } else {
      return AuthProviders.none;
    }
  }

  // OAUTH
  bool get isApple => this == AuthProviders.apple;

  bool get isFacebook => this == AuthProviders.facebook;

  bool get isGameCenter => this == AuthProviders.gameCenter;

  bool get isGithub => this == AuthProviders.github;

  bool get isGoogle => this == AuthProviders.google;

  bool get isMicrosoft => this == AuthProviders.microsoft;

  bool get isPlayGames => this == AuthProviders.playGames;

  bool get isSAML => this == AuthProviders.saml;

  bool get isTwitter => this == AuthProviders.twitter;

  bool get isYahoo => this == AuthProviders.yahoo;

  // CUSTOM
  bool get isBiometric => this == AuthProviders.biometric;

  bool get isEmail => this == AuthProviders.email;

  bool get isGuest => this == AuthProviders.guest;

  bool get isPhone => this == AuthProviders.phone;

  bool get isUsername => this == AuthProviders.username;

  bool get isNone => this == AuthProviders.none;

  bool get isAllowBiometric => isEmail || isUsername;

  bool get isVerified => !(isNone || isEmail || isUsername);
}
