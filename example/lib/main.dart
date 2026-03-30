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
  Object credential(Provider provider, Credential credential) {
    // TODO: implement credential
    throw UnimplementedError();
  }

  @override
  Future<Response<void>> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  // TODO: implement isAnonymous
  bool get isAnonymous => throw UnimplementedError();

  @override
  // TODO: implement isAuthenticated
  bool get isAuthenticated => throw UnimplementedError();

  @override
  Future<bool> isSignIn([Provider? provider]) {
    // TODO: implement isSignIn
    throw UnimplementedError();
  }

  @override
  // TODO: implement rawUid
  Future<String?> get rawUid => throw UnimplementedError();

  @override
  Future<Response<Credential>> signInAnonymously() {
    // TODO: implement signInAnonymously
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithApple() {
    // TODO: implement signInWithApple
    throw UnimplementedError();
  }

  @override
  Future<Response<void>> signInWithBiometric() {
    // TODO: implement signInWithBiometric
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithCredential(Object credential) {
    // TODO: implement signInWithCredential
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithEmailNPassword(
      String email, String password) {
    // TODO: implement signInWithEmailNPassword
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithFacebook() {
    // TODO: implement signInWithFacebook
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithGameCenter() {
    // TODO: implement signInWithGameCenter
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithGithub() {
    // TODO: implement signInWithGithub
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithGoogle() {
    // TODO: implement signInWithGoogle
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithMicrosoft() {
    // TODO: implement signInWithMicrosoft
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithPlayGames() {
    // TODO: implement signInWithPlayGames
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithSAML() {
    // TODO: implement signInWithSAML
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithTwitter() {
    // TODO: implement signInWithTwitter
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithUsernameNPassword(
      String username, String password) {
    // TODO: implement signInWithUsernameNPassword
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signInWithYahoo() {
    // TODO: implement signInWithYahoo
    throw UnimplementedError();
  }

  @override
  Future<Response<void>> signOut([Provider? provider]) {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signUpWithEmailNPassword(
      String email, String password) {
    // TODO: implement signUpWithEmailNPassword
    throw UnimplementedError();
  }

  @override
  Future<Response<Credential>> signUpWithUsernameNPassword(
      String username, String password) {
    // TODO: implement signUpWithUsernameNPassword
    throw UnimplementedError();
  }

  @override
  Future<void> verifyPhoneNumber(
      {String? phoneNumber,
      int? forceResendingToken,
      Object? multiFactorInfo,
      Object? multiFactorSession,
      Duration timeout = const Duration(seconds: 30),
      required void Function(Credential credential) onComplete,
      required void Function(AuthException exception) onFailed,
      required void Function(String verId, int? forceResendingToken) onCodeSent,
      required void Function(String verId) onCodeAutoRetrievalTimeout}) {
    // TODO: implement verifyPhoneNumber
    throw UnimplementedError();
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
  Stream<UserModel?> onListenUser(String id) async* {
    // listen authorized user data from remote server
    log("Authorized user id : $id");
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
