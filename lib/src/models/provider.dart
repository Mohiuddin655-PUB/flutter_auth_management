enum Provider {
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

  const Provider({
    required this.id,
    required this.name,
  });

  factory Provider.from(Object? source) {
    final key = source?.toString().trim().toUpperCase();
    if (key == apple.id) {
      return Provider.apple;
    } else if (key == facebook.id) {
      return Provider.facebook;
    } else if (key == gameCenter.id) {
      return Provider.gameCenter;
    } else if (key == github.id) {
      return Provider.github;
    } else if (key == google.id) {
      return Provider.google;
    } else if (key == microsoft.id) {
      return Provider.microsoft;
    } else if (key == playGames.id) {
      return Provider.playGames;
    } else if (key == saml.id) {
      return Provider.saml;
    } else if (key == twitter.id) {
      return Provider.twitter;
    } else if (key == yahoo.id) {
      return Provider.yahoo;
    } else if (key == biometric.id) {
      return Provider.biometric;
    } else if (key == email.id) {
      return Provider.email;
    } else if (key == guest.id) {
      return Provider.guest;
    } else if (key == phone.id) {
      return Provider.phone;
    } else if (key == username.id) {
      return Provider.username;
    } else {
      return Provider.none;
    }
  }

  // OAUTH
  bool get isApple => this == Provider.apple;

  bool get isFacebook => this == Provider.facebook;

  bool get isGameCenter => this == Provider.gameCenter;

  bool get isGithub => this == Provider.github;

  bool get isGoogle => this == Provider.google;

  bool get isMicrosoft => this == Provider.microsoft;

  bool get isPlayGames => this == Provider.playGames;

  bool get isSAML => this == Provider.saml;

  bool get isTwitter => this == Provider.twitter;

  bool get isYahoo => this == Provider.yahoo;

  bool get isBiometric => this == Provider.biometric;

  bool get isEmail => this == Provider.email;

  bool get isGuest => this == Provider.guest;

  bool get isPhone => this == Provider.phone;

  bool get isUsername => this == Provider.username;

  bool get isNone => this == Provider.none;

  bool get isAllowBiometric => isEmail || isUsername;

  bool get isVerified => !(isNone || isEmail || isUsername);
}
