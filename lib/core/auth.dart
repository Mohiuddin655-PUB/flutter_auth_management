import 'dart:convert';

import 'package:flutter_entity/flutter_entity.dart';

import 'provider.dart';

/// ## Create an authorized key class for User:
///
/// ```dart
/// class AuthKeys extends AuthKeys {
///   final address = "address";
///   final contact = "contact";
///
///   const AuthKeys._();
///
///   static AuthKeys? _i;
///
///   static AuthKeys get i => _i ??= const AuthKeys._();
/// }
///```
class AuthKeys extends EntityKey {
  static const key = "__uid__";

  final accessToken = "access_token";
  final biometric = "biometric";
  final email = "email";
  final extra = "extra";
  final idToken = "id_token";
  final loggedIn = "logged_in";
  final loggedInTime = "logged_in_time";
  final loggedOutTime = "logged_out_time";
  final name = "name";
  final password = "password";
  final phone = "phone";
  final photo = "photo";
  final provider = "provider";
  final username = "username";
  final verified = "verified";

  const AuthKeys({
    super.id,
    super.timeMills,
  });

  static AuthKeys? _i;

  static AuthKeys get i => _i ??= const AuthKeys();

  @override
  Iterable<String> get keys {
    return [
      id,
      timeMills,
      accessToken,
      biometric,
      email,
      extra,
      idToken,
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
}

/// ## Create an authorized model class for User:
///
/// ```dart
/// class AuthKeys extends AuthKeys {
///   final address = "address";
///   final contact = "contact";
///
///   const AuthKeys._();
///
///   static AuthKeys? _i;
///
///   static AuthKeys get i => _i ??= const AuthKeys._();
/// }
///
/// class UserModel extends Auth<AuthKeys> {
///   final Address? _address;
///   final Contact? _contact;
///
///   Address get address => _address ?? Address();
///
///   Contact get contact => _contact ?? Contact();
///
///   UserModel({
///     super.id,
///     super.timeMills,
///     super.accessToken,
///     super.biometric,
///     super.email,
///     super.extra,
///     super.idToken,
///     super.loggedIn,
///     super.name,
///     super.password,
///     super.phone,
///     super.photo,
///     super.provider,
///     super.username,
///     Address? address,
///     Contact? contact,
///   })  : _address = address,
///         _contact = contact;
///
///   factory UserModel.from(Object? source) {
///     final key = AuthKeys.i;
///     final root = Auth.from(source);
///     return UserModel(
///       // ROOT PROPERTIES
///       id: root.id,
///       timeMills: root.timeMills,
///       accessToken: root.accessToken,
///       biometric: root.biometric,
///       email: root.email,
///       extra: root.extra,
///       idToken: root.idToken,
///       loggedIn: root.loggedIn,
///       name: root.name,
///       password: root.password,
///       phone: root.phone,
///       photo: root.photo,
///       provider: root.provider,
///       username: root.username,
///
///       // CHILD PROPERTIES
///       address: source.entityObject(key.address, Address.from),
///       contact: source.entityObject(key.address, Contact.from),
///     );
///   }
///
///   @override
///   UserModel copy({
///     String? id,
///     int? timeMills,
///     String? accessToken,
///     String? biometric,
///     String? email,
///     Map<String, dynamic>? extra,
///     String? idToken,
///     bool? loggedIn,
///     String? name,
///     String? password,
///     String? phone,
///     String? photo,
///     String? provider,
///     String? username,
///     Address? address,
///     Contact? contact,
///   }) {
///     return UserModel(
///       id: id ?? this.id,
///       timeMills: timeMills ?? this.timeMills,
///       accessToken: accessToken ?? this.accessToken,
///       biometric: biometric ?? this.biometric,
///       email: email ?? this.email,
///       extra: extra ?? this.extra,
///       idToken: idToken ?? this.idToken,
///       loggedIn: loggedIn ?? this.loggedIn,
///       name: name ?? this.name,
///       password: password ?? this.password,
///       phone: phone ?? this.phone,
///       photo: photo ?? this.photo,
///       provider: provider ?? this.provider,
///       username: username ?? this.username,
///       address: address ?? this.address,
///       contact: contact ?? this.contact,
///     );
///   }
///
///   @override
///   AuthKeys makeKey() => AuthKeys.i;
///
///   @override
///   Map<String, dynamic> get source {
///     return super.source.attach({
///       key.address: _address?.source,
///       key.contact: _contact?.source,
///     });
///   }
/// }
///
/// class Address extends Entity {
///   Address();
///
///   factory Address.from(Object? source) {
///     return Address();
///   }
/// }
///
/// class Contact extends Entity {
///   Contact();
///
///   factory Contact.from(Object? source) {
///     return Contact();
///   }
/// }
/// ```
class Auth<Key extends AuthKeys> extends Entity<Key> {
  final String? accessToken;
  final bool? _biometric;
  final String? idToken;
  final String? email;
  final Map<String, dynamic>? extra;
  final bool? loggedIn;
  final int? loggedInTime;
  final int? loggedOutTime;
  final String? name;
  final String? password;
  final String? phone;
  final String? photo;
  final Provider? _provider;
  final String? username;
  final bool? verified;

  bool get biometric => _biometric ?? false;

  Provider? get provider => _provider;

  bool get isAuthenticated => true;

  bool get isLoggedIn => loggedIn ?? false;

  bool get isVerified => verified ?? provider?.isVerified ?? false;

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
    this.email,
    this.extra,
    this.idToken,
    this.loggedIn,
    this.loggedInTime,
    this.loggedOutTime,
    this.name,
    this.password,
    this.phone,
    this.photo,
    this.username,
    this.verified,
    bool? biometric,
    Provider? provider,
  })  : _biometric = biometric,
        _provider = provider;

  Auth copy({
    String? id,
    int? timeMills,
    String? accessToken,
    bool? biometric,
    String? email,
    Map<String, dynamic>? extra,
    String? idToken,
    bool? loggedIn,
    int? loggedInTime,
    int? loggedOutTime,
    String? name,
    String? password,
    String? phone,
    String? photo,
    Provider? provider,
    String? username,
    bool? verified,
  }) {
    return Auth(
      id: id ?? this.id,
      timeMills: timeMills ?? this.timeMills,
      accessToken: accessToken ?? this.accessToken,
      biometric: biometric ?? _biometric,
      email: email ?? this.email,
      extra: extra ?? this.extra,
      idToken: idToken ?? this.idToken,
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

  factory Auth.from(Object? source) {
    final key = AuthKeys.i;
    return Auth(
      id: source.entityValue(key.id),
      timeMills: source.entityValue(key.timeMills),
      accessToken: source.entityValue(key.accessToken),
      biometric: source.entityValue(key.biometric),
      loggedIn: source.entityValue(key.loggedIn),
      loggedInTime: source.entityValue(key.loggedInTime),
      loggedOutTime: source.entityValue(key.loggedOutTime),
      idToken: source.entityValue(key.idToken),
      email: source.entityValue(key.email),
      name: source.entityValue(key.name),
      password: source.entityValue(key.password),
      phone: source.entityValue(key.phone),
      photo: source.entityValue(key.photo),
      provider: source.entityValue(key.provider),
      username: source.entityValue(key.username),
      verified: source.entityValue(key.verified),
      extra: source.entityValue(key.extra, (value) {
        return value is Map<String, dynamic> ? value : {};
      }),
    );
  }

  @override
  Key makeKey() {
    try {
      return const AuthKeys() as Key;
    } catch (_) {
      return throw UnimplementedError(
        "You must override makeKey() and return the current key from sub-entity class.",
      );
    }
  }

  @override
  Map<String, dynamic> get source {
    return {
      ...super.source,
      AuthKeys.i.accessToken: accessToken,
      AuthKeys.i.biometric: _biometric,
      AuthKeys.i.email: email,
      AuthKeys.i.extra: extra,
      AuthKeys.i.idToken: idToken,
      AuthKeys.i.loggedIn: loggedIn,
      AuthKeys.i.loggedInTime: loggedInTime,
      AuthKeys.i.loggedOutTime: loggedOutTime,
      AuthKeys.i.name: name,
      AuthKeys.i.password: password,
      AuthKeys.i.phone: phone,
      AuthKeys.i.photo: photo,
      AuthKeys.i.provider: _provider?.id,
      AuthKeys.i.username: username,
      AuthKeys.i.verified: verified,
    };
  }

  @override
  String get json => jsonEncode(source);

  @override
  String toString() => "$Auth($json)";
}
