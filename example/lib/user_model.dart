import 'package:auth_management/core.dart';
import 'package:flutter_entity/entity.dart';

class UserKeys extends AuthKeys {
  final address = "address";
  final contact = "contact";

  const UserKeys._();

  static UserKeys? _i;

  static UserKeys get i => _i ??= const UserKeys._();
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
    super.provider,
    super.username,
    super.verified,
    Address? address,
    Contact? contact,
  })  : _address = address,
        _contact = contact;

  factory UserModel.from(Object? source) {
    final key = UserKeys.i;
    final root = Auth.from(source);
    return UserModel(
      // ROOT PROPERTIES
      id: root.id,
      timeMills: root.timeMills,
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
      provider: root.provider,
      username: root.username,
      verified: root.verified,

      // CHILD PROPERTIES
      address: source.entityValue(key.address, Address.from),
      contact: source.entityValue(key.address, Contact.from),
    );
  }

  @override
  UserModel copy({
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
    Address? address,
    Contact? contact,
  }) {
    return UserModel(
      id: id ?? this.id,
      timeMills: timeMills ?? this.timeMills,
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
      provider: provider ?? this.provider,
      username: username ?? this.username,
      verified: verified ?? this.verified,
      address: address ?? this.address,
      contact: contact ?? this.contact,
    );
  }

  @override
  UserKeys makeKey() => UserKeys.i;

  @override
  Map<String, dynamic> get source {
    return super.source
      ..addAll({
        key.address: _address?.source,
        key.contact: _contact?.source,
      });
  }
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
