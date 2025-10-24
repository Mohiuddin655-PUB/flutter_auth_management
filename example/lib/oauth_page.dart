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
          OauthButton<UserModel>(
            type: OauthButtonType.apple,
            builder: (context, callback) {
              return ElevatedButton(
                onPressed: callback,
                child: const Text("Continue with Apple"),
              );
            },
          ),
          const SizedBox(height: 12),
          OauthButton<UserModel>(
            type: OauthButtonType.biometric,
            builder: (context, callback) {
              return ElevatedButton(
                onPressed: callback,
                child: const Text("Continue with Biometric"),
              );
            },
          ),
          const SizedBox(height: 12),
          OauthButton<UserModel>(
            type: OauthButtonType.facebook,
            builder: (context, callback) {
              return ElevatedButton(
                onPressed: callback,
                child: const Text("Continue with Facebook"),
              );
            },
          ),
          const SizedBox(height: 12),
          OauthButton<UserModel>(
            type: OauthButtonType.github,
            builder: (context, callback) {
              return ElevatedButton(
                onPressed: callback,
                child: const Text("Continue with Github"),
              );
            },
          ),
          const SizedBox(height: 12),
          OauthButton<UserModel>(
            type: OauthButtonType.google,
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
