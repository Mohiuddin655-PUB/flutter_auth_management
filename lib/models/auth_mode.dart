/// Where sign-in happens: [online] on a server (Firebase and the like),
/// [offline] on the phone only, with no network or database
/// ([OfflineAuthDelegate]).
enum AuthMode {
  online,
  offline;

  bool get isOnline => this == online;

  bool get isOffline => this == offline;
}
