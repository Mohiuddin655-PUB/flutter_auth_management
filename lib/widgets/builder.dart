import 'package:flutter/material.dart';

import '../core/authorizer.dart';
import '../exceptions/exception.dart';
import '../models/auth.dart';
import 'provider.dart';

typedef OnAuthUserBuilder<T extends Auth> = Widget Function(
    BuildContext context, T? user, Widget? child);

class AuthBuilder<T extends Auth> extends StatelessWidget {
  final T? initial;
  final Widget? child;
  final OnAuthUserBuilder<T> builder;

  const AuthBuilder({
    super.key,
    this.initial,
    this.child,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final Authorizer<T> authorizer;
    try {
      authorizer = AuthProvider.authorizerOf<T>(context);
    } catch (_) {
      throw AuthProviderException(
        "AuthBuilder<$T> could not find an Authorizer<$T> in the widget tree. "
        "Wrap your app with AuthProvider<$T>(...) or use "
        "AuthBuilder<${AuthProvider.type}>().",
      );
    }

    return ValueListenableBuilder<T?>(
      valueListenable: authorizer.liveUser,
      child: child,
      builder: (context, user, child) {
        return builder(context, user ?? initial, child);
      },
    );
  }
}
