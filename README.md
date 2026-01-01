# flutter_auth_management

## Auth Management Properties

### Import the library

```dart
import 'package:auth_management/core.dart';
```

### Create authorized user model (OPTIONAL)

```dart
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
    super.age,
    super.anonymous,
    super.biometric,
    super.email,
    super.extra,
    super.gender,
    super.idToken,
    super.loggedIn,
    super.loggedInTime,
    super.loggedOutTime,
    super.name,
    super.online,
    super.password,
    super.path,
    super.phone,
    super.photo,
    super.platform,
    super.provider,
    super.random,
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
      age: root.age,
      anonymous: root.anonymous,
      biometric: root.biometric,
      email: root.email,
      extra: root.extra,
      gender: root.gender,
      idToken: root.idToken,
      loggedIn: root.loggedIn,
      loggedInTime: root.loggedInTime,
      loggedOutTime: root.loggedOutTime,
      name: root.name,
      online: root.online,
      password: root.password,
      path: root.path,
      phone: root.phone,
      photo: root.photo,
      platform: root.platform,
      provider: root.provider,
      random: root.random,
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
    String? name,
    int? online,
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

  @override
  UserModel update({
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
    Modifier<String>? name,
    Modifier<int>? online,
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
    Modifier<Address>? address,
    Modifier<Contact>? contact,
  }) {
    return UserModel(
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
      address: modify(address, _address),
      contact: modify(contact, _contact),
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
```

### Create auth delegate

```dart
class MyAuthDelegate extends AuthDelegate {
  @override
  Future<bool> isSignIn([Provider? provider]) {
    // implement isSignIn
    return super.isSignIn(provider);
  }

  @override
  Future<Response<void>> delete() {
    // implement delete
    return super.delete();
  }

  @override
  Object credential(Provider provider, Credential credential) {
    // implement credential
    return super.credential(provider, credential);
  }

  @override
  Future<Response<Credential>> signInAnonymously() {
    // implement signInAnonymously
    return super.signInAnonymously();
  }

  @override
  Future<Response<Credential>> signInWithApple() {
    // implement signInWithApple
    return super.signInWithApple();
  }

  @override
  Future<Response<void>> signInWithBiometric() {
    // implement signInWithBiometric
    return super.signInWithBiometric();
  }

  @override
  Future<Response<Credential>> signInWithCredential(Object credential) {
    // implement signInWithCredential
    return super.signInWithCredential(credential);
  }

  @override
  Future<Response<Credential>> signInWithEmailNPassword(
      String email, String password) {
    // implement signInWithEmailNPassword
    return super.signInWithEmailNPassword(email, password);
  }

  @override
  Future<Response<Credential>> signInWithFacebook() {
    // implement signInWithFacebook
    return super.signInWithFacebook();
  }

  @override
  Future<Response<Credential>> signInWithGameCenter() {
    // implement signInWithGameCenter
    return super.signInWithGameCenter();
  }

  @override
  Future<Response<Credential>> signInWithGithub() {
    // implement signInWithGithub
    return super.signInWithGithub();
  }

  @override
  Future<Response<Credential>> signInWithGoogle() {
    // implement signInWithGoogle
    return super.signInWithGoogle();
  }

  @override
  Future<Response<Credential>> signInWithMicrosoft() {
    // implement signInWithMicrosoft
    return super.signInWithMicrosoft();
  }

  @override
  Future<Response<Credential>> signInWithPlayGames() {
    // implement signInWithPlayGames
    return super.signInWithPlayGames();
  }

  @override
  Future<Response<Credential>> signInWithSAML() {
    // implement signInWithSAML
    return super.signInWithSAML();
  }

  @override
  Future<Response<Credential>> signInWithTwitter() {
    // implement signInWithTwitter
    return super.signInWithTwitter();
  }

  @override
  Future<Response<Credential>> signInWithUsernameNPassword(
    String username,
    String password,
  ) {
    // implement signInWithUsernameNPassword
    return super.signInWithUsernameNPassword(username, password);
  }

  @override
  Future<Response<Credential>> signInWithYahoo() {
    // implement signInWithYahoo
    return super.signInWithYahoo();
  }

  @override
  Future<Response<void>> signOut([Provider? provider]) {
    // implement signOut
    return super.signOut(provider);
  }

  @override
  Future<Response<Credential>> signUpWithEmailNPassword(
    String email,
    String password,
  ) {
    // implement signUpWithEmailNPassword
    return super.signUpWithEmailNPassword(email, password);
  }

  @override
  Future<Response<Credential>> signUpWithUsernameNPassword(
    String username,
    String password,
  ) {
    // implement signUpWithUsernameNPassword
    return super.signUpWithUsernameNPassword(username, password);
  }

  @override
  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    int? forceResendingToken,
    Object? multiFactorInfo,
    Object? multiFactorSession,
    Duration timeout = const Duration(seconds: 30),
    required void Function(Credential credential) onComplete,
    required void Function(AuthException exception) onFailed,
    required void Function(String verId, int? forceResendingToken) onCodeSent,
    required void Function(String verId) onCodeAutoRetrievalTimeout,
  }) {
    // implement verifyPhoneNumber
    return super.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      multiFactorInfo: multiFactorInfo,
      multiFactorSession: multiFactorSession,
      timeout: timeout,
      onComplete: onComplete,
      onFailed: onFailed,
      onCodeSent: onCodeSent,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
    );
  }
}
```

### Create authorized user backup delegate

```dart
class MyAuthBackupDelegate extends AuthBackupDelegate<UserModel> {
  const MyAuthBackupDelegate({
    super.key,
    required super.reader,
    required super.writer,
  });

  @override
  Object? nonEncodableObjectParser(Object? current, Object? old) {
    return old;
  }

  @override
  UserModel build(Map source) => UserModel.from(source);

  @override
  Future<void> onCreateUser(UserModel data) async {
    // Store authorized user data in remote server
    log("Authorized user data : $data");
  }

  @override
  Future<void> onDeleteUser(String id) async {
    // Clear unauthorized user data from remote server
    log("Unauthorized user id : $id");
  }

  @override
  Future<UserModel?> onFetchUser(String id) async {
    // fetch authorized user data from remote server
    log("Authorized user id : $id");
    return null;
  }

  @override
  Future<void> onUpdateUser(
    String id,
    Map<String, dynamic> data,
    bool hasAnonymous,
  ) async {
    // Update authorized user data in remote server
    log("Authorized user data : $data");
  }
}
```

### Initialize firebase app and widget bindings in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Application());
}
```

### Add auth provider in root level

```dart
class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthProvider<UserModel>(
      initialCheck: true,
      authorizer: Authorizer(
          delegate: MyAuthDelegate(),
          backup: MyAuthBackupDelegate(
            key: "_local_user_key_",
            reader: (key) async {
              final db = await SharedPreferences.getInstance();
              // get from any local db [Hive, SharedPreferences, etc]
              return db.getString(key);
            },
            writer: (key, value) async {
              final db = await SharedPreferences.getInstance();
              if (value == null) {
                // remove from any local db [Hive, SharedPreferences, etc]
                return db.remove(key);
              }
              // save to any local db [Hive, SharedPreferences, etc]
              return db.setString(key, value);
            },
          ),
          msg: const AuthMessages(),
      ),
      child: MaterialApp(),
    );
  }
}
```

### Apply on Startup screen

```dart
import 'dart:developer';

import 'package:auth_management/core.dart';
import 'package:auth_management/widgets.dart';
import 'package:flutter/material.dart';

import 'user_model.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  void _showError(BuildContext context, String error) {
    log("AUTH ERROR : $error");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }

  void _showLoading(BuildContext context, bool loading) {
    log("AUTH LOADING : $loading");
  }

  void _showMessage(BuildContext context, String message) {
    log("AUTH MESSAGE : $message");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _changes(
    BuildContext context,
    AuthChanges<UserModel> changes,
  ) {
    log("AUTH STATUS : $changes");
    if (changes.status.isAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthObserver<UserModel>(
      onError: _showError,
      onMessage: _showMessage,
      onLoading: _showLoading,
      onChanges: _changes,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "login");
                },
                child: const Text("Login"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "register");
                },
                child: const Text("Register"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "oauth");
                },
                child: const Text("OAuth"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.signInAnonymously<UserModel>(
                    authenticator: GuestAuthenticator(
                      name: "Omie talukdar",
                    ),
                  );
                },
                child: const Text("Guest"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.signOut<UserModel>();
                },
                child: const Text("Sign out"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.updateAccount<UserModel>({AuthKeys.i.name: "XYZ"});
                },
                child: const Text("Update account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Apply on Login screen

```dart
import 'dart:developer';

import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';

import 'user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final etName = TextEditingController(text: "Mr. Abc");
  final etEmail = TextEditingController(text: "abc@gmail.com");
  final etPhone = TextEditingController(text: "");
  final etPassword = TextEditingController(text: "123456");
  final etOTP = TextEditingController();
  String? token;

  void signInByEmail() async {
    log("AUTH : login");
    final email = etEmail.text;
    final password = etPassword.text;
    context.signInByEmail<UserModel>(EmailAuthenticator(
      email: email,
      password: password,
    ));
  }

  void signInByUsername() {
    final name = etName.text;
    final password = etPassword.text;
    context.signInByUsername<UserModel>(UsernameAuthenticator(
      username: name,
      password: password,
    ));
  }

  void signInByPhone() async {
    final name = etName.text;
    final phone = etPhone.text;
    context.signInByPhone<UserModel>(
      PhoneAuthenticator(phone: phone, name: name),
      onCodeSent: (verId, refreshTokenId) {
        token = verId;
        log(verId);
      },
    );
  }

  void signInByOtp() async {
    final name = etName.text;
    final phone = etPhone.text;
    final code = etOTP.text;
    final token = this.token;
    context.signInByOtp<UserModel>(OtpAuthenticator(
      token: token ?? "",
      smsCode: code,
      name: name,
      phone: phone,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LOGIN",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          TextField(
            controller: etEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Email",
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: etName,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              hintText: "Name",
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: etPassword,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Password",
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: etPhone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: "Phone",
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: etOTP,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "OTP",
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByEmail,
              child: const Text("Login with Email"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByUsername,
              child: const Text("Login with Username"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByPhone,
              child: const Text("Login with Phone number"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByOtp,
              child: const Text("Verify OTP"),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Apply on Register screen

```dart
import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';

import 'user_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final etName = TextEditingController();
  final etEmail = TextEditingController();
  final etPassword = TextEditingController();

  void signUpByEmail() async {
    final name = etName.text;
    final email = etEmail.text;
    final password = etPassword.text;
    context.signUpByEmail<UserModel>(EmailAuthenticator(
      email: email,
      password: password,
      name: name, // Optional
    ));
  }

  void signUpByUsername() {
    final name = etName.text;
    final password = etPassword.text;
    context.signUpByUsername<UserModel>(UsernameAuthenticator(
      username: name,
      password: password,
      name: name, // Optional
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "REGISTER",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          TextField(
            controller: etEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Email",
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: etName,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(
              hintText: "Name",
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: etPassword,
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Password",
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signUpByEmail,
              child: const Text("Register with Email"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signUpByUsername,
              child: const Text("Register with Username"),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Apply on Oauth screen

```dart
import 'package:auth_management/widgets.dart';
import 'package:flutter/material.dart';

import 'user_model.dart';

class OAuthPage extends StatelessWidget {
  const OAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "OAuth",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
          vertical: 50,
        ),
        children: [
          AuthButton<UserModel>(
            type: AuthButtonType.signInWithApple,
            builder: (context, callback) {
              return ElevatedButton(
                onPressed: callback,
                child: const Text("Continue with Apple"),
              );
            },
          ),
          const SizedBox(height: 12),
          AuthButton<UserModel>(
            type: AuthButtonType.biometricEnable,
            builder: (context, callback) {
              return ElevatedButton(
                onPressed: callback,
                child: const Text("Continue with Biometric"),
              );
            },
          ),
          const SizedBox(height: 12),
          AuthButton<UserModel>(
            type: AuthButtonType.signInWithFacebook,
            builder: (context, callback) {
              return ElevatedButton(
                onPressed: callback,
                child: const Text("Continue with Facebook"),
              );
            },
          ),
          const SizedBox(height: 12),
          AuthButton<UserModel>(
            type: AuthButtonType.signInWithGithub,
            builder: (context, callback) {
              return ElevatedButton(
                onPressed: callback,
                child: const Text("Continue with Github"),
              );
            },
          ),
          const SizedBox(height: 12),
          AuthButton<UserModel>(
            type: AuthButtonType.signInWithGoogle,
            builder: (context, callback) {
              return ElevatedButton(
                onPressed: callback,
                child: const Text("Continue with Google"),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### Apply on Home screen

```dart
import 'dart:developer';

import 'package:auth_management/core.dart';
import 'package:auth_management/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_andomie/core.dart';

import 'user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _signOut() {
    context.signOut<UserModel>();
  }

  void _updateUser() {
    context.updateAccount<UserModel>({
      UserKeys.i.name: "Omie ${RandomProvider.integer(max: 50)}",
    });
  }

  void _biometricEnable(bool? value) {
    context.biometricEnable<UserModel>(value ?? false).then((value) {
      log("Biometric enable status : ${value.error}");
    });
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showLoading(BuildContext context, bool loading) {}

  void _status(BuildContext context, AuthStatus status) {
    if (status.isUnauthenticated) {
      Navigator.pushNamedAndRemoveUntil(context, "startup", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AuthObserver<UserModel>(
          onError: _showSnackBar,
          onMessage: _showSnackBar,
          onLoading: _showLoading,
          onStatus: _status,
          child: AuthConsumer<UserModel>(
            builder: (context, value) {
              return Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.1),
                      ),
                      child: value?.photo == null
                          ? null
                          : Image.network(
                              value?.photo ?? "",
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      value?.name ?? "",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      value?.email ?? "",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      "Account created at ".join(
                        DateHelper.toRealtime(value?.timeMills ?? 0),
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: value?.biometric ?? false ? 1 : 0.5,
                      child: SwitchListTile.adaptive(
                        value: value?.biometric ?? false,
                        onChanged: _biometricEnable,
                        title: const Text("Biometric mode"),
                        contentPadding: const EdgeInsets.only(
                          left: 24,
                          right: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateUser,
                        child: const Text("Update"),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _signOut,
                        child: const Text("Logout"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

## Project required properties :

### Biometric login

#### Activity changes

```java
import io.flutter.embedding.android.FlutterFragmentActivity;

public class MainActivity extends FlutterFragmentActivity {
// ...
}
```

#### Add Permissions

```xml

<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.example.app">

    <uses-permission android:name="android.permission.USE_BIOMETRIC" />

</manifest>
```

### Add app level gradle defaultConfig properties

```groovy
android {
    //...
    defaultConfig {
        //...
        minSdkVersion 23
    }
    //...
}
```
