import 'package:auth_management/core.dart';
import 'package:flutter_entity/entity.dart';

class UserKeys extends AuthKeys {
  final address = "address";
  final contact = "contact";

  const UserKeys._();

  static UserKeys? _i;

  static UserKeys get i => _i ??= const UserKeys._();

  @override
  Iterable<String> get keys => {...super.keys, address, contact};
}

class UserModel extends Auth<UserKeys> {
  final Address? _address;
  final Contact? _contact;

  Address get address => _address ?? Address();

  Contact get contact => _contact ?? Contact();

  UserModel({
    super.id,
    super.timeMills,
    super.accessToken,
    super.biometric,
    super.email,
    super.extra,
    super.idToken,
    super.loggedIn,
    super.loggedInTime,
    super.loggedOutTime,
    super.name,
    super.password,
    super.phone,
    super.photo,
    super.platform,
    super.provider,
    super.token,
    super.username,
    super.verified,
    Address? address,
    Contact? contact,
  })  : _address = address,
        _contact = contact;

  factory UserModel.from(Object? source) {
    if (source is UserModel) return source;
    final key = UserKeys.i;
    final root = Auth.from(source);
    return UserModel(
      // ROOT PROPERTIES
      id: root.idOrNull,
      timeMills: root.timeMillsOrNull,
      accessToken: root.accessToken,
      biometric: root.biometric,
      email: root.email,
      extra: root.extra,
      idToken: root.idToken,
      loggedIn: root.loggedIn,
      loggedInTime: root.loggedInTime,
      loggedOutTime: root.loggedOutTime,
      name: root.name,
      password: root.password,
      phone: root.phone,
      photo: root.photo,
      platform: root.platform,
      provider: root.provider,
      token: root.token,
      username: root.username,
      verified: root.verified,

      // CHILD PROPERTIES
      address: source.entityValue(key.address, Address.from),
      contact: source.entityValue(key.contact, Contact.from),
    );
  }

  @override
  UserModel copy({
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
    return UserModel(
      id: id ?? idOrNull,
      timeMills: timeMills ?? timeMillsOrNull,
      accessToken: accessToken ?? this.accessToken,
      biometric: biometric ?? this.biometric,
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
      platform: platform ?? this.platform,
      provider: provider ?? this.provider,
      token: token ?? this.token,
      username: username ?? this.username,
      verified: verified ?? this.verified,
    );
  }

  @override
  UserKeys makeKey() => UserKeys.i;

  @override
  Iterable<Object?> get props {
    return [
      ...super.props,
      _address,
      _contact,
    ];
  }

  @override
  Map<String, dynamic> get source {
    return {
      ...super.source,
      key.address: _address?.source,
      key.contact: _contact?.source,
    };
  }

  @override
  String toString() => "$UserModel#$hashCode($json)";
}

class Address extends Entity {
  Address();

  factory Address.from(Object? source) {
    return Address();
  }
}

class Contact extends Entity {
  Contact();

  factory Contact.from(Object? source) {
    return Contact();
  }
}
