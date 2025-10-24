import 'package:flutter/material.dart';

import '../core/auth.dart';
import '../core/auth_response.dart';
import '../core/authorizer.dart';

class AuthProviderException {
  final String exception;

  const AuthProviderException(this.exception);

  bool get isInitialized => AuthProvider.type != null;

  String get message {
    if (isInitialized) {
      return exception;
    } else {
      return "AuthProvider not initialization.";
    }
  }

  @override
  String toString() => message;
}

class AuthProvider<T extends Auth> extends InheritedWidget {
  final bool initialCheck;
  final Authorizer<T> authorizer;

  AuthProvider({
    super.key,
    this.initialCheck = false,
    required this.authorizer,
    required Widget child,
  }) : super(
          child: _Internal<T>(
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
        "You should call like of${AuthProvider.type}();",
      );
    }
  }

  static Authorizer<T> authorizerOf<T extends Auth>(BuildContext context) {
    try {
      return of<T>(context).authorizer;
    } catch (_) {
      throw AuthProviderException(
        "You should call like authorizerOf${AuthProvider.type}();",
      );
    }
  }

  @override
  bool updateShouldNotify(covariant AuthProvider<T> oldWidget) {
    return authorizer != oldWidget.authorizer;
  }

  void notify(AuthResponse<T> value) => authorizer.emit(value);
}

class _Internal<T extends Auth> extends StatefulWidget {
  final bool initialCheck;
  final Authorizer<T> authorizer;
  final Widget child;

  const _Internal({
    this.initialCheck = false,
    required this.child,
    required this.authorizer,
  });

  @override
  State<_Internal<T>> createState() => _InternalState<T>();
}

class _InternalState<T extends Auth> extends State<_Internal<T>> {
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
