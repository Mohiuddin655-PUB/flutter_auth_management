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
    super.biometric,
    super.email,
    super.loggedIn,
    super.loggedInTime,
    super.loggedOutTime,
    super.name,
    super.password,
    super.phone,
    super.photo,
    super.provider,
    super.username,
    super.verified,
    Address? address,
    Contact? contact,
  })  : _address = address,
        _contact = contact;

  factory UserModel.from(Object? source) {
    if (source is UserModel) return source;
    final key = UserKeys.i;
    return UserModel(
      // ROOT PROPERTIES
      id: source.entityValue(key.id),
      timeMills: source.entityValue(key.timeMills),
      biometric: source.entityValue(key.biometric),
      email: source.entityValue(key.email),
      loggedIn: source.entityValue(key.loggedIn),
      loggedInTime: source.entityValue(key.loggedInTime),
      loggedOutTime: source.entityValue(key.loggedOutTime),
      name: source.entityValue(key.name),
      password: source.entityValue(key.password),
      phone: source.entityValue(key.phone),
      photo: source.entityValue(key.photo),
      provider: source.entityValue(key.provider),
      username: source.entityValue(key.username),
      verified: source.entityValue(key.verified),

      // CHILD PROPERTIES
      address: source.entityValue(key.address, Address.from),
      contact: source.entityValue(key.contact, Contact.from),
    );
  }

  @override
  UserModel copy({
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
    return UserModel(
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
