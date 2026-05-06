import 'package:flutter_entity/entity.dart' show Entity;

import 'key.dart' show AuthKeys;

class Auth<K extends AuthKeys> extends Entity<K> {
  final bool? biometric;
  final bool? loggedIn;
  final bool? verified;

  final int? loggedInTime;
  final int? loggedOutTime;

  final String? email;
  final String? name;
  final String? password;
  final String? phone;
  final String? photo;
  final String? provider;
  final String? username;

  bool get isAuthenticated => true;

  bool get isBiometric => biometric ?? false;

  bool get isLoggedIn => loggedIn ?? false;

  bool get isVerified => verified ?? false;

  DateTime get lastLoggedInDate {
    return DateTime.fromMillisecondsSinceEpoch(loggedInTime ?? 0);
  }

  DateTime get lastLoggedOutDate {
    return DateTime.fromMillisecondsSinceEpoch(loggedOutTime ?? 0);
  }

  Duration get lastLoggedInTime {
    return DateTime.now().difference(lastLoggedInDate);
  }

  Duration get lastLoggedOutTime {
    return DateTime.now().difference(lastLoggedOutDate);
  }

  Auth({
    super.id = "",
    super.timeMills,
    this.biometric,
    this.email,
    this.loggedIn,
    this.loggedInTime,
    this.loggedOutTime,
    this.name,
    this.password,
    this.phone,
    this.photo,
    this.provider,
    this.username,
    this.verified,
  });

  Auth<K> copy({
    String? id,
    int? timeMills,
    bool? biometric,
    String? email,
    bool? loggedIn,
    int? loggedInTime,
    int? loggedOutTime,
    String? name,
    String? password,
    String? phone,
    String? photo,
    String? provider,
    String? username,
    bool? verified,
  }) {
    return Auth<K>(
      id: id ?? idOrNull,
      timeMills: timeMills ?? timeMillsOrNull,
      biometric: biometric ?? this.biometric,
      email: email ?? this.email,
      loggedIn: loggedIn ?? this.loggedIn,
      loggedInTime: loggedInTime ?? this.loggedInTime,
      loggedOutTime: loggedOutTime ?? this.loggedOutTime,
      name: name ?? this.name,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      provider: provider ?? this.provider,
      username: username ?? this.username,
      verified: verified ?? this.verified,
    );
  }

  @override
  Map<String, dynamic> get source {
    return {
      ...super.source,
      key.biometric: biometric,
      key.email: email,
      key.loggedIn: loggedIn,
      key.loggedInTime: loggedInTime,
      key.loggedOutTime: loggedOutTime,
      key.name: name,
      key.password: password,
      key.phone: phone,
      key.photo: photo,
      key.provider: provider,
      key.username: username,
      key.verified: verified,
    };
  }

  @override
  Iterable<Object?> get props {
    return [
      ...super.props,
      biometric,
      email,
      loggedIn,
      loggedInTime,
      loggedOutTime,
      name,
      password,
      phone,
      photo,
      provider,
      username,
      verified,
    ];
  }

  @override
  String toString() => "$Auth#$hashCode($json)";
}
