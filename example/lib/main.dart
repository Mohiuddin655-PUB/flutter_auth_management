import 'package:auth_management/core.dart';
import 'package:auth_management_biometric_delegate/auth_management_biometric_delegate.dart';
import 'package:auth_management_google_delegate/auth_management_google_delegate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'backup_delegate.dart';
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

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthProvider<UserModel>(
      initialCheck: true,
      authorizer: Authorizer(
        authRepository: AuthRepository.create(
          // appleAuthDelegate: AppleAuthDelegate(),
          biometricAuthDelegate: BiometricAuthDelegate(),
          // facebookAuthDelegate: FacebookAuthDelegate(),
          googleAuthDelegate: GoogleAuthDelegate(
            googleSignIn: GoogleSignIn(scopes: [
              'email',
            ]),
          ),
        ),
        backupRepository: BackupRepository.create(
          key: "_local_user_key_",
          delegate: UserBackupDelegate(),
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
      ),
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
  final data = settings.arguments;
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
