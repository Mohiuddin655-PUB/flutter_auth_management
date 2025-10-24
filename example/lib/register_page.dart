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
