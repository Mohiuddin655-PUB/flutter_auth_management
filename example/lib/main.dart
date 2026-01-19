import 'dart:developer';

import 'package:auth_management/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_entity/entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'oauth_page.dart';
import 'register_page.dart';
import 'startup.dart';
import 'user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Application());
}

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
  Stream<UserModel?> onListenUser(String id) {
    // listen authorized user data from remote server
    log("Authorized user id : $id");
    return Stream.value(null);
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

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthProvider<UserModel>(
      initialCheck: true,
      authorizer: Authorizer(
          realtime: true,
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
          msg: const AuthMessages()),
      child: MaterialApp(
        title: 'Auth Management',
        theme: ThemeData(
          primaryColor: Colors.deepOrange,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            primary: Colors.deepOrange,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          )),
        ),
        initialRoute: "startup",
        onGenerateRoute: routes,
      ),
    );
  }
}

Route<T>? routes<T>(RouteSettings settings) {
  final name = settings.name;
  if (name == "home") {
    return MaterialPageRoute(
      builder: (_) {
        return const HomePage();
      },
    );
  } else if (name == "login") {
    return MaterialPageRoute(
      builder: (_) {
        return const LoginPage();
      },
    );
  } else if (name == "register") {
    return MaterialPageRoute(
      builder: (_) {
        return const RegisterPage();
      },
    );
  } else if (name == "oauth") {
    return MaterialPageRoute(
      builder: (_) {
        return const OAuthPage();
      },
    );
  } else if (name == "startup") {
    return MaterialPageRoute(
      builder: (_) {
        return const StartupPage();
      },
    );
  }
  return null;
}
