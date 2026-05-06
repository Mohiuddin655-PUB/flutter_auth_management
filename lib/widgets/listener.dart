import 'package:flutter/material.dart';

import '../core/authorizer.dart';
import '../exceptions/exception.dart';
import '../models/auth.dart';
import 'provider.dart';

/// Builder signature for [AuthListener].
typedef OnAuthBuilder<T extends Auth> = Widget Function(
    BuildContext context, T? user, Widget? child);

/// Combines a builder (rebuilds on user change) with side-effect callbacks
/// for errors, loading, messages, and status changes.
///
/// Equivalent to a `BlocConsumer` in `flutter_bloc`: the [builder] runs on
/// every user change, while the optional `on*` callbacks fire when their
/// respective notifiers change. Use [child] for parts of the subtree that
/// don't depend on the user — they're built once and forwarded.
///
/// [ids] gates side-effect callbacks: when non-empty, callbacks fire only if
/// the authorizer's current id matches one in the list. The [builder] always
/// runs regardless of [ids].
///
/// ```dart
/// AuthListener<MyUser>(
///   onError: (ctx, msg) => showSnack(ctx, msg),
///   onLoading: (ctx, busy) => loading.value = busy,
///   builder: (ctx, user, _) => user == null ? LoginPage() : HomePage(user),
/// )
/// ```
class AuthListener<T extends Auth> extends StatefulWidget {
  /// Fallback used while the authorizer hasn't produced a user yet.
  final T? initial;

  /// If non-empty, side-effect callbacks fire only when the authorizer's
  /// current id is in this list. Builder rebuilds are not gated.
  final List<String> ids;

  /// Subtree forwarded to [builder]. Built once.
  final Widget? child;

  /// Called when [Authorizer.liveError] changes to a non-empty value.
  final OnAuthError? onError;

  /// Called when [Authorizer.liveLoading] changes.
  final OnAuthLoading? onLoading;

  /// Called when [Authorizer.liveMessage] changes to a non-empty value.
  final OnAuthMessage? onMessage;

  /// Called when [Authorizer.liveStatus] changes. Ignored if [onChanges] is
  /// also set.
  final OnAuthStatus? onStatus;

  /// Rebuilds whenever the authenticated user changes.
  final OnAuthBuilder<T>? builder;

  const AuthListener({
    super.key,
    this.initial,
    this.ids = const [],
    this.child,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onStatus,
    this.builder,
  });

  @override
  State<AuthListener<T>> createState() => _AuthListenerState<T>();
}

class _AuthListenerState<T extends Auth> extends State<AuthListener<T>> {
  Authorizer<T>? _authorizer;

  /// Whether status callbacks should be wired up at all.
  bool get _wantsStatus => widget.onStatus != null;

  /// Whether the current authorizer id passes the [AuthListener.ids] filter.
  bool get _isIdMatched {
    final ids = widget.ids;
    if (ids.isEmpty) return true;
    final id = _authorizer?.id;
    if (id == null || id.isEmpty) return true;
    return ids.contains(id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = _resolveAuthorizer(context);
    if (!identical(next, _authorizer)) {
      _detach(_authorizer);
      _attach(next);
      _authorizer = next;
    }
  }

  @override
  void dispose() {
    _detach(_authorizer);
    _authorizer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.builder == null) return widget.child ?? const SizedBox.shrink();
    final authorizer = _authorizer;
    if (authorizer == null) {
      return widget.builder!(context, widget.initial, widget.child);
    }
    return ValueListenableBuilder<T?>(
      valueListenable: authorizer.liveUser,
      child: widget.child,
      builder: (context, user, child) {
        return widget.builder!(context, user ?? widget.initial, child);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Wiring
  // ---------------------------------------------------------------------------

  Authorizer<T> _resolveAuthorizer(BuildContext context) {
    try {
      return AuthProvider.authorizerOf<T>(context);
    } catch (_) {
      throw AuthProviderException(
        "AuthListener<$T> could not find an Authorizer<$T> in the widget tree. "
        "Wrap your app with AuthProvider<$T>(...) or use "
        "AuthListener<${AuthProvider.type}>().",
      );
    }
  }

  void _attach(Authorizer<T> authorizer) {
    if (widget.onError != null) {
      authorizer.liveError.addListener(_handleError);
    }
    if (widget.onLoading != null) {
      authorizer.liveLoading.addListener(_handleLoading);
    }
    if (widget.onMessage != null) {
      authorizer.liveMessage.addListener(_handleMessage);
    }
    if (_wantsStatus) {
      authorizer.liveStatus.addListener(_handleStatus);
    }
  }

  void _detach(Authorizer<T>? authorizer) {
    if (authorizer == null) return;
    authorizer.liveError.removeListener(_handleError);
    authorizer.liveLoading.removeListener(_handleLoading);
    authorizer.liveMessage.removeListener(_handleMessage);
    authorizer.liveStatus.removeListener(_handleStatus);
  }

  // ---------------------------------------------------------------------------
  // Notifier handlers
  // ---------------------------------------------------------------------------

  void _handleError() {
    if (!mounted || !_isIdMatched) return;
    final value = _authorizer?.errorText ?? '';
    if (value.isEmpty) return;
    widget.onError?.call(context, value);
  }

  void _handleLoading() {
    if (!mounted || !_isIdMatched) return;
    final value = _authorizer?.loading ?? false;
    widget.onLoading?.call(context, value);
  }

  void _handleMessage() {
    if (!mounted || !_isIdMatched) return;
    final value = _authorizer?.message ?? '';
    if (value.isEmpty) return;
    widget.onMessage?.call(context, value);
  }

  void _handleStatus() {
    if (!mounted || !_isIdMatched) return;
    final authorizer = _authorizer;
    if (authorizer == null) return;
    widget.onStatus?.call(context, authorizer.status);
  }
}
