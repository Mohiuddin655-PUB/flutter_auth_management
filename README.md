# flutter_auth_management

## Auth Management Properties

### Import the library

```dart
import 'package:auth_management/core.dart';
```

### Create authorized user key (OPTIONAL)

```dart
class UserKeys extends AuthKeys {
  final address = "address";
  final contact = "contact";

  const UserKeys._();

  static UserKeys? _i;

  static UserKeys get i => _i ??= const UserKeys._();
}
```

### Create authorized user model (OPTIONAL)

```dart
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
  })
      : _address = address,
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
      address: source.entityObject(key.address, Address.from),
      contact: source.entityObject(key.address, Contact.from),
    );
  }

  @override
  UserModel copy({
    String? id,
    int? timeMills,
    String? accessToken,
    String? biometric,
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
    String? provider,
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
  Future<Response<void>> signInWithBiometric([BiometricConfig? config]) {
    // implement signInWithBiometric
    return super.signInWithBiometric(config);
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
class MyAuthBackupDelegate extends BackupDelegate<UserModel> {
  const MyAuthBackupDelegate({
    super.key,
    required super.reader,
    required super.writer,
  });

  @override
  UserModel build(Map<String, dynamic> source) => UserModel.from(source);

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
  Future<void> onUpdateUser(String id, Map<String, dynamic> data) async {
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
import 'package:auth_management/core.dart';
import 'package:auth_management_biometric_delegate/auth_management_biometric_delegate.dart';
import 'package:auth_management_google_delegate/auth_management_google_delegate.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          msg: const AuthMessages()
      ),
      child: MaterialApp(),
    );
  }
}
```

### Apply on  Startup screen

```dart
import 'package:auth_management/core.dart';

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

  void _status(BuildContext context, AuthState state, UserModel? user) {
    log("AUTH STATUS : $state");
    if (state.isAuthenticated) {
      Navigator.pushNamedAndRemoveUntil(context, "home", (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthObserver<UserModel>(
      onError: _showError,
      onMessage: _showMessage,
      onLoading: _showLoading,
      onStatus: _status,
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
                  Navigator.pushNamed(context, "login");
                },
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Apply on Login/Register screen

```dart
import 'package:auth_management/core.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final etName = TextEditingController();
  final etEmail = TextEditingController();
  final etPhone = TextEditingController();
  final etPassword = TextEditingController();
  final etOTP = TextEditingController();
  String? token;

  void signInByEmail() async {
    final email = etEmail.text;
    final password = etPassword.text;
    context.signInByEmail<UserModel>(EmailAuthenticator(
      email: email,
      password: password,
    ));
  }

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

  void signInByUsername() {
    final name = etName.text;
    final password = etPassword.text;
    context.signInByUsername<UserModel>(UsernameAuthenticator(
      username: name,
      password: password,
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

  void signInByPhone() async {
    final name = etName.text;
    final phone = etPhone.text;
    context.signInByPhone<UserModel>(
      PhoneAuthenticator(phone: phone, name: name),
      onCodeSent: (verId, refreshTokenId) {
        token = verId;
      },
    );
  }

  void signInByOtp() async {
    final name = etName.text;
    final phone = etPhone.text;
    final code = etOTP.text;
    context.signInByOtp<UserModel>(OtpAuthenticator(
      token: token ?? "",
      smsCode: code,
      name: name,
      phone: phone,
    ));
  }

  void signInByApple() {
    context.signInByApple<UserModel>();
  }

  void signInByBiometric() {
    context.signInByBiometric<UserModel>();
  }

  void signInByFacebook() {
    context.signInByFacebook<UserModel>();
  }

  void signInByGithub() {
    context.signInByGithub<UserModel>();
  }

  void signInByGoogle() {
    context.signInByGoogle<UserModel>();
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
              child: const Text("Login (Email)"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signUpByEmail,
              child: const Text("Sign Up (Email)"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByUsername,
              child: const Text("Login (Username)"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signUpByUsername,
              child: const Text("Sign Up (Username)"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByPhone,
              child: const Text("Phone"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByOtp,
              child: const Text("OTP"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              runAlignment: WrapAlignment.center,
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: signInByApple,
                  child: const Text("Apple"),
                ),
                ElevatedButton(
                  onPressed: signInByBiometric,
                  child: const Text("Biometric"),
                ),
                ElevatedButton(
                  onPressed: signInByFacebook,
                  child: const Text("Facebook"),
                ),
                ElevatedButton(
                  onPressed: signInByGithub,
                  child: const Text("Github"),
                ),
                ElevatedButton(
                  onPressed: signInByGoogle,
                  child: const Text("Google"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
```

### Apply on  Home screen

```dart
import 'package:auth_management/core.dart';

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
      UserKeys.i.name: "Updated name",
    });
  }

  void _biometricEnable(bool? value) {
    context.biometricEnable<UserModel>(value ?? false).then((value) {
      log("Biometric enable status : ${value.exception}");
    });
  }

  void _biometricChange(BuildContext context) {
    context.addBiometric<UserModel>(
      config: const BiometricConfig(
        signInTitle: "Biometric",
        localizedReason: "Scan your face or fingerprint",
      ),
      callback: (value) =>
          showDialog<BiometricStatus>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Biometric permission from user!"),
                actions: [
                  ElevatedButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context, BiometricStatus.initial);
                    },
                  ),
                  ElevatedButton(
                    child: const Text("Inactivate"),
                    onPressed: () {
                      Navigator.pop(context, BiometricStatus.inactivated);
                    },
                  ),
                  ElevatedButton(
                    child: const Text("Activate"),
                    onPressed: () {
                      Navigator.pop(context, BiometricStatus.activated);
                    },
                  ),
                ],
              );
            },
          ),
    ).then((value) {
      log("Add biometric status : ${value.exception}");
    });
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _showLoading(BuildContext context, bool loading) {}

  void _status(BuildContext context, AuthState state, UserModel? user) {
    if (state.isUnauthenticated) {
      Navigator.pushNamedAndRemoveUntil(context, "login", (route) => false);
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
                        color: Colors.black.withOpacity(0.1),
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
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      value?.email ?? "",
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium,
                    ),
                    Text(
                      "Account created at ".join(
                        DateProvider.toRealtime(value?.timeMills ?? 0),
                      ),
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: value?.mBiometric.isInitial ?? false ? 0.5 : 1,
                      child: SwitchListTile.adaptive(
                        value: value?.isBiometric ?? false,
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
                        onPressed: () => _biometricChange(context),
                        child: const Text("Add biometric"),
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
