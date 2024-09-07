import 'package:auth_management/core.dart';
import 'package:auth_management_biometric_delegate/auth_management_biometric_delegate.dart';
import 'package:auth_management_google_delegate/auth_management_google_delegate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      controller: AuthController.getInstance<UserModel>(
        backup: UserBackupDelegate(),
        auth: AuthDelegate(
          // appleAuthDelegate: AppleAuthDelegate(),
          biometricAuthDelegate: BiometricAuthDelegate(),
          // facebookAuthDelegate: FacebookAuthDelegate(),
          googleAuthDelegate: GoogleAuthDelegate(
            googleSignIn: GoogleSignIn(scopes: [
              'email',
            ]),
          ),
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
