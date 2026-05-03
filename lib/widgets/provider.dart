import 'package:flutter/material.dart';

import '../core/authorizer.dart';
import '../exceptions/exception.dart';
import '../models/auth.dart';

/// Provides an [Authorizer] to the widget tree.
///
/// IMPORTANT: [authorizer] কে AuthProvider এর বাইরে State এ তৈরি করো।
/// build() এর ভেতরে new Authorizer() করলে rebuild এ নতুন instance হয়।
///
/// ```dart
/// // ✅ সঠিক — State এ তৈরি
/// class _MyState extends State<MyWidget> {
///   late final _authorizer = Authorizer<User>(...);
///
///   Widget build(BuildContext context) {
///     return AuthProvider<User>(authorizer: _authorizer, child: ...);
///   }
/// }
///
/// // ❌ ভুল — build() এ তৈরি
/// Widget build(BuildContext context) {
///   return AuthProvider<User>(
///     authorizer: Authorizer<User>(...), // প্রতি rebuild এ নতুন instance!
///     child: ...,
///   );
/// }
/// ```
class AuthProvider<T extends Auth> extends StatefulWidget {
  /// Widget tree এ expose করার Authorizer।
  /// State এ তৈরি করা instance pass করো।
  final Authorizer<T> authorizer;

  /// Cold start এ cache থেকে user emit করবে কিনা।
  /// true রাখো — hot reload এ user null আসবে না।
  final bool initialCheck;

  /// Realtime auth state changes listen করবে কিনা।
  final bool listening;

  /// true হলে global singleton হিসেবে register করে।
  /// সাধারণত false রাখো — Root এ নিজে dispose করো।
  final bool createInstance;

  final Widget child;

  const AuthProvider({
    super.key,
    required this.authorizer,
    required this.child,
    this.initialCheck = true,
    this.listening = false,
    this.createInstance = false,
  });

  static Type? type;

  static AuthProvider<T>? maybeOf<T extends Auth>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AuthScope<T>>()?.owner;
  }

  static AuthProvider<T> of<T extends Auth>(BuildContext context) {
    final owner = maybeOf<T>(context);
    if (owner == null) {
      throw AuthProviderException(
        'No AuthProvider<$T> found in the widget tree. '
        'Ensure that AuthProvider<$T>(...) wraps the widget calling this.',
      );
    }
    return owner;
  }

  static Authorizer<T>? maybeAuthorizerOf<T extends Auth>(
    BuildContext context,
  ) {
    return maybeOf<T>(context)?.authorizer;
  }

  static Authorizer<T> authorizerOf<T extends Auth>(BuildContext context) {
    return of<T>(context).authorizer;
  }

  @override
  State<AuthProvider<T>> createState() => _AuthProviderState<T>();
}

class _AuthProviderState<T extends Auth> extends State<AuthProvider<T>> {
  @override
  void initState() {
    super.initState();

    AuthProvider.type = T;

    if (widget.createInstance) {
      Authorizer.attach<T>(widget.authorizer);
    }

    widget.authorizer.initialize(
      initialCheck: widget.initialCheck,
      listening: widget.listening,
    );
  }

  @override
  void didUpdateWidget(covariant AuthProvider<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.authorizer, oldWidget.authorizer)) {
      if (widget.createInstance) {
        Authorizer.attach<T>(widget.authorizer);
      }
      widget.authorizer.initialize(
        initialCheck: widget.initialCheck,
        listening: widget.listening,
      );
    }
  }

  @override
  void dispose() {
    if (widget.createInstance) {
      Authorizer.detach<T>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScope<T>(owner: widget, child: widget.child);
  }
}

class _AuthScope<T extends Auth> extends InheritedWidget {
  final AuthProvider<T> owner;

  const _AuthScope({required this.owner, required super.child});

  @override
  bool updateShouldNotify(covariant _AuthScope<T> oldWidget) {
    return !identical(owner.authorizer, oldWidget.owner.authorizer);
  }
}
