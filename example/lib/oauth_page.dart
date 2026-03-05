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
