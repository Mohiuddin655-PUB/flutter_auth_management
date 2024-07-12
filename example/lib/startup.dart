import 'dart:developer';

import 'package:auth_management/core.dart';
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
                  context.signInAnonymously<UserModel>(GuestAuthenticator(
                    name: "Omie talukdar",
                  ));
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
