import 'package:flutter/material.dart';

import '../core/auth.dart';
import '../core/auth_changes.dart';
import '../core/auth_provider.dart';
import '../core/authorizer.dart';

typedef OnAuthBuilder<T extends Auth> = Widget Function(
  BuildContext context,
  T? data,
);

class AuthBuilder<T extends Auth> extends StatelessWidget {
  final T? initial;
  final List<String> ids;
  final OnAuthChanges<T>? onChanges;
  final OnAuthError? onError;
  final OnAuthLoading? onLoading;
  final OnAuthMessage? onMessage;
  final OnAuthStatus? onStatus;
  final OnAuthBuilder<T> builder;

  const AuthBuilder({
    super.key,
    this.initial,
    this.ids = const [],
    this.onChanges,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onStatus,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return _Child<T>(
        authorizer: AuthProvider.authorizerOf<T>(context),
        initial: initial,
        ids: ids,
        onChanges: onChanges,
        onError: onError,
        onLoading: onLoading,
        onMessage: onMessage,
        onStatus: onStatus,
        builder: builder,
      );
    } catch (_) {
      throw AuthProviderException(
        "You should apply like AuthBuilder<${AuthProvider.type}>()",
      );
    }
  }
}

class _Child<T extends Auth> extends StatefulWidget {
  final T? initial;
  final List<String> ids;
  final Authorizer<T> authorizer;
  final OnAuthChanges<T>? onChanges;
  final OnAuthError? onError;
  final OnAuthLoading? onLoading;
  final OnAuthMessage? onMessage;
  final OnAuthStatus? onStatus;
  final OnAuthBuilder<T> builder;

  const _Child({
    required this.authorizer,
    required this.initial,
    required this.ids,
    required this.onChanges,
    required this.onError,
    required this.onLoading,
    required this.onMessage,
    required this.onStatus,
    required this.builder,
  });

  @override
  State<_Child<T>> createState() => _ChildState<T>();
}

class _ChildState<T extends Auth> extends State<_Child<T>> {
  T? _data;

  bool get isNotifiable {
    final id = widget.authorizer.id;
    if (widget.ids.isEmpty || id == null || id.isEmpty) {
      return true;
    }
    return widget.ids.contains(id);
  }

  bool get isStatusMode => widget.onStatus != null || widget.onChanges != null;

  @override
  void initState() {
    _addListeners(widget.authorizer);
    widget.authorizer.auth.then(_change);
    super.initState();
  }

  @override
  void didUpdateWidget(_Child<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authorizer != widget.authorizer) {
      _removeListeners(oldWidget.authorizer);
      _addListeners(widget.authorizer);
    }
  }

  @override
  void dispose() {
    _removeListeners(widget.authorizer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _data ?? widget.initial,
    );
  }

  void _addListeners(Authorizer<T> authorizer) {
    authorizer.liveUser.addListener(_change);
    if (widget.onError != null) {
      authorizer.liveError.addListener(_changeError);
    }
    if (widget.onLoading != null) {
      authorizer.liveLoading.addListener(_changeLoading);
    }
    if (widget.onMessage != null) {
      authorizer.liveMessage.addListener(_changeMessage);
    }
    if (isStatusMode) {
      authorizer.liveStatus.addListener(_changeStatus);
    }
  }

  void _removeListeners(Authorizer<T> authorizer) {
    authorizer.liveUser.removeListener(_change);
    if (widget.onError != null) {
      authorizer.liveError.removeListener(_changeError);
    }
    if (widget.onLoading != null) {
      authorizer.liveLoading.removeListener(_changeLoading);
    }
    if (widget.onMessage != null) {
      authorizer.liveMessage.removeListener(_changeMessage);
    }
    if (isStatusMode) {
      authorizer.liveStatus.removeListener(_changeStatus);
    }
  }

  void _change([T? data]) {
    setState(() => _data = data ?? widget.authorizer.liveUser.value);
  }

  void _changeError() {
    if (!isNotifiable) return;
    if (widget.onError != null) {
      final value = widget.authorizer.errorText;
      if (value.isNotEmpty) {
        widget.onError?.call(context, value);
      }
    }
  }

  void _changeLoading() {
    if (!isNotifiable) return;
    if (widget.onLoading != null) {
      final value = widget.authorizer.loading;
      widget.onLoading?.call(context, value);
    }
  }

  void _changeMessage() {
    if (!isNotifiable) return;
    if (widget.onMessage != null) {
      final value = widget.authorizer.message;
      if (value.isNotEmpty) {
        widget.onMessage?.call(context, value);
      }
    }
  }

  void _changeStatus() {
    if (!isNotifiable) return;
    final value = widget.authorizer.status;
    if (widget.onChanges != null) {
      widget.onChanges!(
        context,
        AuthChanges(
          args: widget.authorizer.args,
          status: value,
          user: widget.authorizer.user,
        ),
      );
      return;
    }
    if (widget.onStatus != null) {
      widget.onStatus!(context, value);
    }
  }
}
