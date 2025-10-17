import 'package:flutter/material.dart';

import '../core/authorizer.dart';
import '../models/auth.dart';
import '../utils/auth_response.dart';
import '../utils/errors.dart';

class AuthProvider<T extends Auth> extends InheritedWidget {
  final bool initialCheck;
  final Authorizer<T> authorizer;

  AuthProvider({
    super.key,
    this.initialCheck = false,
    required this.authorizer,
    required Widget child,
  }) : super(
          child: _Support<T>(
            authorizer: authorizer,
            initialCheck: initialCheck,
            child: child,
          ),
        ) {
    type = T;
  }

  static Type? type;

  static AuthProvider<T> of<T extends Auth>(BuildContext context) {
    final x = context.dependOnInheritedWidgetOfExactType<AuthProvider<T>>();
    if (x != null) {
      return x;
    } else {
      throw AuthProviderException(
        "You should call like of<${AuthProvider.type}>();",
      );
    }
  }

  static Authorizer<T> authorizerOf<T extends Auth>(BuildContext context) {
    try {
      return of<T>(context).authorizer;
    } catch (_) {
      throw AuthProviderException(
        "You should call like authorizerOf<${AuthProvider.type}>();",
      );
    }
  }

  @override
  bool updateShouldNotify(covariant AuthProvider<T> oldWidget) {
    return authorizer != oldWidget.authorizer;
  }

  void notify(AuthResponse<T> value) => authorizer.emit(value);
}

class _Support<T extends Auth> extends StatefulWidget {
  final bool initialCheck;
  final Authorizer<T> authorizer;
  final Widget child;

  const _Support({
    this.initialCheck = false,
    required this.child,
    required this.authorizer,
  });

  @override
  State<_Support<T>> createState() => _SupportState<T>();
}

class _SupportState<T extends Auth> extends State<_Support<T>> {
  @override
  void initState() {
    widget.authorizer.initialize(widget.initialCheck);
    super.initState();
  }

  @override
  void dispose() {
    widget.authorizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
