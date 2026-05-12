class Credential {
  final Object? credential;
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String? photoURL;
  final String? smsCode;
  final String? uid;
  final String? verificationId;

  const Credential({
    this.credential,
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoURL,
    this.smsCode,
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
    Object? credential,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? photoURL,
    String? smsCode,
    String? uid,
    String? verificationId,
  }) {
    return Credential(
      credential: credential ?? this.credential,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoURL: photoURL ?? this.photoURL,
      smsCode: smsCode ?? this.smsCode,
      uid: uid ?? this.uid,
      verificationId: verificationId ?? this.verificationId,
    );
  }

  @override
  String toString() => "$Credential($uid)";
}
