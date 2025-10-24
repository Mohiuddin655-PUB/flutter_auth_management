import 'package:flutter/material.dart';

import '../core/auth.dart';
import '../core/auth_response.dart';
import '../core/auth_status.dart';
import '../core/authorizer.dart';

class AuthRouter<T extends Auth> extends StatelessWidget {
  final String initialRoute;
  final String authenticatedRoute;
  final String unauthenticatedRoute;
  final Widget Function(BuildContext context, String route) builder;

  const AuthRouter({
    super.key,
    required this.builder,
    required this.initialRoute,
    required this.authenticatedRoute,
    required this.unauthenticatedRoute,
  });

  Future<AuthResponse<T>> isAuthenticated(BuildContext context) async {
    try {
      return Authorizer<T>.of(context).isSignIn();
    } catch (_) {
      return AuthResponse.unauthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isAuthenticated(context),
      builder: (context, snapshot) {
        final state = snapshot.data?.status ?? AuthStatus.unauthorized;
        if (state.isAuthenticated) {
          return builder(context, authenticatedRoute);
        } else if (state.isUnauthenticated) {
          return builder(context, unauthenticatedRoute);
        } else {
          return builder(context, initialRoute);
        }
      },
    );
  }
}
