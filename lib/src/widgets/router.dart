import 'package:flutter/material.dart';

import '../core/helper.dart';
import '../enums/auth_status.dart';
import '../models/auth.dart';

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.isSignIn<T>(),
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
