import 'package:flutter/material.dart';

import '../core/extensions.dart';
import '../core/typedefs.dart';
import '../models/auth.dart';
import '../models/auth_changes.dart';
import '../services/controllers/controller.dart';
import '../utils/errors.dart';
import '../widgets/provider.dart';

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
        controller: context.findAuthController<T>(),
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
  final AuthController<T> controller;
  final OnAuthChanges<T>? onChanges;
  final OnAuthError? onError;
  final OnAuthLoading? onLoading;
  final OnAuthMessage? onMessage;
  final OnAuthStatus? onStatus;
  final OnAuthBuilder<T> builder;

  const _Child({
    required this.controller,
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
    final id = widget.controller.id;
    if (widget.ids.isEmpty || id == null || id.isEmpty) {
      return true;
    }
    return widget.ids.contains(id);
  }

  bool get isStatusMode => widget.onStatus != null || widget.onChanges != null;

  @override
  void initState() {
    _addListeners(widget.controller);
    widget.controller.auth.then(_change);
    super.initState();
  }

  @override
  void didUpdateWidget(_Child<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _removeListeners(oldWidget.controller);
      _addListeners(widget.controller);
    }
  }

  @override
  void dispose() {
    _removeListeners(widget.controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _data ?? widget.initial,
    );
  }

  void _addListeners(AuthController<T> controller) {
    controller.liveUser.addListener(_change);
    if (widget.onError != null) {
      controller.liveError.addListener(_changeError);
    }
    if (widget.onLoading != null) {
      controller.liveLoading.addListener(_changeLoading);
    }
    if (widget.onMessage != null) {
      controller.liveMessage.addListener(_changeMessage);
    }
    if (isStatusMode) {
      controller.liveStatus.addListener(_changeStatus);
    }
  }

  void _removeListeners(AuthController<T> controller) {
    controller.liveUser.removeListener(_change);
    if (widget.onError != null) {
      controller.liveError.removeListener(_changeError);
    }
    if (widget.onLoading != null) {
      controller.liveLoading.removeListener(_changeLoading);
    }
    if (widget.onMessage != null) {
      controller.liveMessage.removeListener(_changeMessage);
    }
    if (isStatusMode) {
      controller.liveStatus.removeListener(_changeStatus);
    }
  }

  void _change([T? data]) {
    setState(() => _data = data ?? widget.controller.liveUser.value);
  }

  void _changeError() {
    if (!isNotifiable) return;
    if (widget.onError != null) {
      final value = widget.controller.errorText;
      if (value.isNotEmpty) {
        widget.onError?.call(context, value);
      }
    }
  }

  void _changeLoading() {
    if (!isNotifiable) return;
    if (widget.onLoading != null) {
      final value = widget.controller.loading;
      widget.onLoading?.call(context, value);
    }
  }

  void _changeMessage() {
    if (!isNotifiable) return;
    if (widget.onMessage != null) {
      final value = widget.controller.message;
      if (value.isNotEmpty) {
        widget.onMessage?.call(context, value);
      }
    }
  }

  void _changeStatus() {
    if (!isNotifiable) return;
    final value = widget.controller.status;
    if (widget.onChanges != null) {
      widget.onChanges!(
        context,
        AuthChanges(
          args: widget.controller.args,
          status: value,
          user: widget.controller.user,
        ),
      );
      return;
    }
    if (widget.onStatus != null) {
      widget.onStatus!(context, value);
    }
  }
}
