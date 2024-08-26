import 'dart:async';

import 'package:flutter/material.dart';

import '../models/auth.dart';
import '../models/auth_changes.dart';
import '../models/auth_status.dart';
import '../models/biometric_status.dart';

typedef OnAuthMode = void Function(BuildContext context);
typedef OnAuthError = void Function(BuildContext context, String error);
typedef OnAuthMessage = void Function(BuildContext context, String message);
typedef OnAuthLoading = void Function(BuildContext context, bool loading);
typedef OnAuthStatus = void Function(BuildContext context, AuthStatus status);
typedef OnAuthChanges<T extends Auth> = void Function(
  BuildContext context,
  AuthChanges<T> changes,
);
typedef IdentityBuilder = String Function(String uid);
typedef SignByBiometricCallback = Future<BiometricStatus?>? Function(
  BiometricStatus? status,
);
typedef SignOutCallback = Future Function(Auth authorizer);
typedef UndoAccountCallback = Future<bool> Function(Auth authorizer);
