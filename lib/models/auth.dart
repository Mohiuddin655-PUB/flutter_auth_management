import 'dart:convert';

import 'package:flutter_entity/flutter_entity.dart';

import '../utils/platform.dart';
import 'provider.dart';

/// Current platform identifier. Safe across web, mobile, and desktop.
final String kPlatform = currentPlatform;

/// ## Create an authorized key class for User:
///
/// ```dart
/// class UserKeys extends AuthKeys {
///   final address = "address";
///   final contact = "contact";
///
///   const UserKeys._();
///
///   static UserKeys? _i;
///
///   static UserKeys get i => _i ??= const UserKeys._();
/// }
/// ```
class AuthKeys extends EntityKey {
  static const key = "__uid__";

  final accessToken = "access_token";
  final age = "age";
  final anonymous = "anonymous";
  final biometric = "biometric";
  final email = "email";
  final extra = "extra";
  final gender = "gender";
  final loggedIn = "logged_in";
  final loggedInTime = "logged_in_time";
  final loggedOutTime = "logged_out_time";
  final idToken = "id_token";
  final name = "name";
  final online = "online";
  final lastOnline = "last_online";
  final password = "password";
  final path = "path";
  final phone = "phone";
  final photo = "photo";
  final platform = "platform";
  final provider = "provider";
  final random = "random";
  final token = "token";
  final username = "username";
  final verified = "verified";

  const AuthKeys({super.id, super.timeMills});

  static AuthKeys? _i;

  static AuthKeys get i => _i ??= const AuthKeys();

  @override
  Iterable<String> get keys {
    return [
      id,
      timeMills,
      accessToken,
      age,
      anonymous,
      biometric,
      email,
      extra,
      gender,
      idToken,
      loggedIn,
      loggedInTime,
      loggedOutTime,
      name,
      online,
      lastOnline,
      password,
      path,
      phone,
      photo,
      platform,
      provider,
      random,
      token,
      username,
      verified,
    ];
  }
}

class Auth<K extends AuthKeys> extends Entity<K> {
  final String? accessToken;
  final int? age;
  final bool? anonymous;
  final bool? biometric;
  final String? email;
  final Map<String, dynamic>? extra;
  final String? gender;
  final String? idToken;
  final bool? loggedIn;
  final int? loggedInTime;
  final int? loggedOutTime;
  final String? name;
  final bool? online;
  final int? _lastOnline;
  final String? password;
  final String? path;
  final String? phone;
  final String? photo;
  final String? platform;
  final Provider? provider;
  final double? random;
  final String? token;
  final String? username;
  final bool? verified;

  bool get isAnonymous => anonymous ?? false;

  bool get isAuthenticated => true;

  bool get isBiometric => biometric ?? false;

  bool get isLoggedIn => loggedIn ?? false;

  bool get isOnline => online ?? false;

  bool get isVerified => verified ?? provider?.isVerified ?? false;

  int? get lastOnlineMillis => _lastOnline;

  DateTime? get lastOnline {
    final ms = _lastOnline;
    if (ms == null || ms <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Duration get lastOnlineInDuration {
    final value = lastOnline;
    if (value == null) return Duration.zero;
    return DateTime.now().difference(value);
  }

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
    this.accessToken,
    this.age,
    this.anonymous,
    this.biometric,
    this.email,
    this.extra,
    this.gender,
    this.idToken,
    this.loggedIn,
    this.loggedInTime,
    this.loggedOutTime,
    this.name,
    this.online,
    int? lastOnline,
    this.password,
    this.path,
    this.phone,
    this.photo,
    String? platform,
    this.provider,
    this.random,
    this.token,
    this.username,
    this.verified,
  })  : platform = platform ?? kPlatform,
        _lastOnline = lastOnline;

  Auth<K> copy({
    String? id,
    int? timeMills,
    String? accessToken,
    int? age,
    bool? anonymous,
    bool? biometric,
    String? email,
    Map<String, dynamic>? extra,
    String? gender,
    String? idToken,
    bool? loggedIn,
    int? loggedInTime,
    int? loggedOutTime,
    int? lastOnline,
    String? name,
    bool? online,
    String? password,
    String? path,
    String? phone,
    String? photo,
    String? platform,
    Provider? provider,
    double? random,
    String? token,
    String? username,
    bool? verified,
  }) {
    return Auth<K>(
      id: id ?? idOrNull,
      timeMills: timeMills ?? timeMillsOrNull,
      accessToken: accessToken ?? this.accessToken,
      age: age ?? this.age,
      anonymous: anonymous ?? this.anonymous,
      biometric: biometric ?? this.biometric,
      email: email ?? this.email,
      extra: extra ?? this.extra,
      gender: gender ?? this.gender,
      idToken: idToken ?? this.idToken,
      loggedIn: loggedIn ?? this.loggedIn,
      loggedInTime: loggedInTime ?? this.loggedInTime,
      loggedOutTime: loggedOutTime ?? this.loggedOutTime,
      lastOnline: lastOnline ?? _lastOnline,
      name: name ?? this.name,
      online: online ?? this.online,
      password: password ?? this.password,
      path: path ?? this.path,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      platform: platform ?? this.platform,
      provider: provider ?? this.provider,
      random: random ?? this.random,
      token: token ?? this.token,
      username: username ?? this.username,
      verified: verified ?? this.verified,
    );
  }

  Auth<K> update({
    Modifier<String>? id,
    Modifier<int>? timeMills,
    Modifier<String>? accessToken,
    Modifier<int>? age,
    Modifier<bool>? anonymous,
    Modifier<bool>? biometric,
    Modifier<String>? email,
    Modifier<Map<String, dynamic>>? extra,
    Modifier<String>? gender,
    Modifier<String>? idToken,
    Modifier<bool>? loggedIn,
    Modifier<int>? loggedInTime,
    Modifier<int>? loggedOutTime,
    Modifier<int>? lastOnline,
    Modifier<String>? name,
    Modifier<bool>? online,
    Modifier<String>? password,
    Modifier<String>? path,
    Modifier<String>? phone,
    Modifier<String>? photo,
    Modifier<String>? platform,
    Modifier<Provider>? provider,
    Modifier<double>? random,
    Modifier<String>? token,
    Modifier<String>? username,
    Modifier<bool>? verified,
  }) {
    return Auth<K>(
      id: modify(id, idOrNull),
      timeMills: modify(timeMills, timeMillsOrNull),
      accessToken: modify(accessToken, this.accessToken),
      age: modify(age, this.age),
      anonymous: modify(anonymous, this.anonymous),
      biometric: modify(biometric, this.biometric),
      email: modify(email, this.email),
      extra: modify(extra, this.extra),
      gender: modify(gender, this.gender),
      idToken: modify(idToken, this.idToken),
      loggedIn: modify(loggedIn, this.loggedIn),
      loggedInTime: modify(loggedInTime, this.loggedInTime),
      loggedOutTime: modify(loggedOutTime, this.loggedOutTime),
      lastOnline: modify(lastOnline, _lastOnline),
      name: modify(name, this.name),
      online: modify(online, this.online),
      password: modify(password, this.password),
      path: modify(path, this.path),
      phone: modify(phone, this.phone),
      photo: modify(photo, this.photo),
      platform: modify(platform, this.platform),
      provider: modify(provider, this.provider),
      random: modify(random, this.random),
      token: modify(token, this.token),
      username: modify(username, this.username),
      verified: modify(verified, this.verified),
    );
  }

  factory Auth.from(Object? source) {
    if (source is Auth<K>) return source;
    final key = AuthKeys.i;
    return Auth<K>(
      id: source.entityValue(key.id),
      timeMills: source.entityValue(key.timeMills),
      accessToken: source.entityValue(key.accessToken),
      age: source.entityValue(key.age),
      anonymous: source.entityValue(key.anonymous),
      biometric: source.entityValue(key.biometric),
      email: source.entityValue(key.email),
      extra: _readMap(source, key.extra),
      gender: source.entityValue(key.gender),
      idToken: source.entityValue(key.idToken),
      loggedIn: source.entityValue(key.loggedIn),
      loggedInTime: source.entityValue(key.loggedInTime),
      loggedOutTime: source.entityValue(key.loggedOutTime),
      lastOnline: source.entityValue(key.lastOnline),
      name: source.entityValue(key.name),
      online: source.entityValue(key.online),
      password: source.entityValue(key.password),
      path: source.entityValue(key.path),
      phone: source.entityValue(key.phone),
      photo: source.entityValue(key.photo),
      platform: source.entityValue(key.platform),
      provider: _readProvider(source, key.provider),
      random: source.entityValue(key.random),
      token: source.entityValue(key.token),
      username: source.entityValue(key.username),
      verified: source.entityValue(key.verified),
    );
  }

  static Map<String, dynamic>? _readMap(Object? source, String key) {
    final raw = source.entityValue(key);
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  static Provider? _readProvider(Object? source, String key) {
    final raw = source.entityValue(key);
    if (raw == null) return null;
    if (raw is Provider) return raw;
    if (raw is String) return Provider.from(raw);
    return null;
  }

  @override
  K makeKey() {
    try {
      return AuthKeys.i as K;
    } catch (_) {
      throw UnimplementedError(
        "You must override makeKey() and return the current key from sub-entity class.",
      );
    }
  }

  @override
  Map<String, dynamic> get source {
    return {
      ...super.source,
      key.accessToken: accessToken,
      key.age: age,
      key.anonymous: anonymous,
      key.biometric: biometric,
      key.email: email,
      key.extra: extra,
      key.gender: gender,
      key.idToken: idToken,
      key.loggedIn: loggedIn,
      key.loggedInTime: loggedInTime,
      key.loggedOutTime: loggedOutTime,
      key.lastOnline: _lastOnline,
      key.name: name,
      key.online: online,
      key.password: password,
      key.path: path,
      key.phone: phone,
      key.photo: photo,
      key.platform: platform,
      key.provider: provider?.id,
      key.random: random,
      key.token: token,
      key.username: username,
      key.verified: verified,
    };
  }

  @override
  String get json => jsonEncode(source);

  @override
  Iterable<Object?> get props {
    return [
      ...super.props,
      accessToken,
      age,
      anonymous,
      biometric,
      email,
      extra,
      gender,
      idToken,
      loggedIn,
      loggedInTime,
      loggedOutTime,
      _lastOnline,
      name,
      online,
      password,
      path,
      phone,
      photo,
      platform,
      provider,
      random,
      token,
      username,
      verified,
    ];
  }

  @override
  String toString() => "$Auth#$hashCode($json)";
}
