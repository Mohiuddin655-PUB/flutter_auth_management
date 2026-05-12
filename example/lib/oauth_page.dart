import 'package:auth_management/core.dart';
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
          ElevatedButton(
            onPressed: () => context.signInWithApple<UserModel>(),
            child: const Text("Continue with Apple"),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.signInByBiometric<UserModel>(),
            child: const Text("Continue with Biometric"),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.signInWithFacebook<UserModel>(),
            child: const Text("Continue with Facebook"),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.signInWithGithub<UserModel>(),
            child: const Text("Continue with Github"),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.signInWithGoogle<UserModel>(),
            child: const Text("Continue with Google"),
          ),
        ],
      ),
    );
  }
}
