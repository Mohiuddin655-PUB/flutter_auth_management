import 'package:flutter/material.dart';

import '../core/auth.dart';
import '../core/auth_provider.dart';
import '../core/authorizer.dart';

typedef OnAuthUserBuilder<T extends Auth> = Widget Function(
  BuildContext context,
  T? value,
);

class AuthConsumer<T extends Auth> extends StatelessWidget {
  final T? initial;
  final OnAuthUserBuilder<T> builder;

  const AuthConsumer({
    super.key,
    this.initial,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return _Support<T>(
        authorizer: AuthProvider.authorizerOf<T>(context),
        initial: initial,
        builder: builder,
      );
    } catch (_) {
      throw AuthProviderException(
        "You should apply like AuthConsumer<${AuthProvider.type}>();",
      );
    }
  }
}

class _Support<T extends Auth> extends StatefulWidget {
  final T? initial;
  final Authorizer<T> authorizer;
  final OnAuthUserBuilder<T> builder;

  const _Support({
    super.key,
    this.initial,
    required this.authorizer,
    required this.builder,
  });

  @override
  State<_Support<T>> createState() => _SupportState<T>();
}

class _SupportState<T extends Auth> extends State<_Support<T>> {
  T? _data;

  void _change([T? data]) {
    setState(() => _data = data ?? widget.authorizer.liveUser.value);
  }

  @override
  void initState() {
    super.initState();
    widget.authorizer.auth.then(_change);
    widget.authorizer.liveUser.addListener(_change);
  }

  @override
  void didUpdateWidget(_Support<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authorizer != widget.authorizer) {
      oldWidget.authorizer.liveUser.removeListener(_change);
      widget.authorizer.liveUser.addListener(_change);
      widget.authorizer.auth.then(_change);
    }
  }

  @override
  void dispose() {
    widget.authorizer.liveUser.removeListener(_change);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _data ?? widget.initial);
  }
}
