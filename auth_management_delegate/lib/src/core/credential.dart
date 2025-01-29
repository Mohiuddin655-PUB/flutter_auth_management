class Metadata {
  final DateTime? creationTime;
  final DateTime? lastSignInTime;

  const Metadata({
    this.creationTime,
    this.lastSignInTime,
  });

  Map<String, dynamic> get source {
    return {
      "creationTime": creationTime?.millisecondsSinceEpoch,
      "lastSignInTime": lastSignInTime?.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() => '$Metadata($source)';
}

class Info {
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String? photoURL;
  final String providerId;
  final String? uid;

  const Info({
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoURL,
    required this.providerId,
    this.uid,
  });

  Map<String, dynamic> get source {
    return {
      "displayName": displayName,
      "email": email,
      "phoneNumber": phoneNumber,
      "photoURL": photoURL,
      "providerId": providerId,
      "uid": uid,
    };
  }

  @override
  String toString() => '$Info($source)';
}

class AdditionalInfo {
  final bool isNewUser;
  final Map<String, dynamic>? profile;
  final String? providerId;
  final String? username;
  final String? authorizationCode;

  const AdditionalInfo({
    required this.isNewUser,
    this.profile,
    this.providerId,
    this.username,
    this.authorizationCode,
  });

  @override
  String toString() => '$AdditionalInfo('
      'isNewUser: $isNewUser, '
      'profile: $profile, '
      'providerId: $providerId, '
      'username: $username, '
      'authorizationCode: $authorizationCode'
      ')';
}

class Credential {
  final String? accessToken;
  final AdditionalInfo? additionalUserInfo;
  final Object? credential;
  final String? displayName;
  final String? email;
  final bool? emailVerified;
  final String? idToken;
  final bool? isAnonymous;
  final Metadata? metadata;
  final Object? multiFactor;
  final String? phoneNumber;
  final String? photoURL;
  final List<Info>? providerData;
  final String? providerId;
  final String? refreshToken;
  final String? signInMethod;
  final String? smsCode;
  final String? tenantId;
  final String? uid;
  final String? verificationId;

  const Credential({
    this.accessToken,
    this.additionalUserInfo,
    this.credential,
    this.displayName,
    this.email,
    this.emailVerified,
    this.idToken,
    this.isAnonymous,
    this.metadata,
    this.multiFactor,
    this.phoneNumber,
    this.photoURL,
    this.providerData,
    this.providerId,
    this.refreshToken,
    this.signInMethod,
    this.smsCode,
    this.tenantId,
    this.uid,
    this.verificationId,
  });

  factory Credential.fromFbData(Map<String, dynamic> map) {
    String? id = map['id'];
    String? email = map['email'];
    String? name = map['name'];
    String? photo;
    try {
      photo = map['picture']['data']['url'];
    } catch (_) {
      photo = '';
    }
    return Credential(
      uid: id,
      email: email,
      displayName: name,
      photoURL: photo,
    );
  }

  Credential copyWith({
    String? accessToken,
    AdditionalInfo? additionalUserInfo,
    Object? credential,
    String? displayName,
    String? email,
    bool? emailVerified,
    String? idToken,
    bool? isAnonymous,
    Metadata? metadata,
    Object? multiFactor,
    String? phoneNumber,
    String? photoURL,
    List<Info>? providerData,
    String? providerId,
    String? refreshToken,
    String? signInMethod,
    String? smsCode,
    String? tenantId,
    String? uid,
    String? verificationId,
  }) {
    return Credential(
      accessToken: accessToken ?? this.accessToken,
      additionalUserInfo: additionalUserInfo ?? this.additionalUserInfo,
      credential: credential ?? this.credential,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      idToken: idToken ?? this.idToken,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      metadata: metadata ?? this.metadata,
      multiFactor: multiFactor ?? this.multiFactor,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      providerData: providerData ?? this.providerData,
      providerId: providerId ?? this.providerId,
      refreshToken: refreshToken ?? this.refreshToken,
      signInMethod: signInMethod ?? this.signInMethod,
      smsCode: smsCode ?? this.smsCode,
      tenantId: tenantId ?? this.tenantId,
      uid: uid ?? this.uid,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  @override
  String toString() => "$Credential($uid)";
}
