import 'dart:developer';

import 'package:auth_management/core.dart';
import 'package:flutter/material.dart';

import 'user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final etName = TextEditingController(text: "Mr. Abc");
  final etEmail = TextEditingController(text: "abc@gmail.com");
  final etPhone = TextEditingController(text: "");
  final etPassword = TextEditingController(text: "123456");
  final etOTP = TextEditingController();
  String? token;

  void signInByEmail() async {
    log("AUTH : login");
    final email = etEmail.text;
    final password = etPassword.text;
    context.signInByEmail<UserModel>(EmailAuthenticator(
      email: email,
      password: password,
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

  void signInByPhone() async {
    final name = etName.text;
    final phone = etPhone.text;
    context.signInByPhone<UserModel>(
      PhoneAuthenticator(phone: phone, name: name),
      onCodeSent: (verId, refreshTokenId) {
        token = verId;
        log(verId);
      },
    );
  }

  void signInByOtp() async {
    final name = etName.text;
    final phone = etPhone.text;
    final code = etOTP.text;
    final token = this.token;
    context.signInByOtp<UserModel>(OtpAuthenticator(
      token: token ?? "",
      smsCode: code,
      name: name,
      phone: phone,
    ));
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
              child: const Text("Login with Email"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByUsername,
              child: const Text("Login with Username"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByPhone,
              child: const Text("Login with Phone number"),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: signInByOtp,
              child: const Text("Verify OTP"),
            ),
          ),
        ],
      ),
    );
  }
}
