import 'package:flutter/material.dart';

import '../core/extensions.dart';
import '../core/typedefs.dart';
import '../models/auth.dart';
import '../models/auth_changes.dart';
import '../services/controllers/controller.dart';
import '../utils/errors.dart';
import '../widgets/provider.dart';

class AuthObserver<T extends Auth> extends StatelessWidget {
  final List<String> ids;
  final bool liveAsBackground;
  final OnAuthChanges<T>? onChanges;
  final OnAuthError? onError;
  final OnAuthLoading? onLoading;
  final OnAuthMessage? onMessage;
  final OnAuthStatus? onStatus;
  final Widget child;

  const AuthObserver({
    super.key,
    this.ids = const [],
    this.liveAsBackground = false,
    this.onChanges,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onStatus,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    try {
      return _Observer<T>(
        controller: context.findAuthController<T>(),
        ids: ids,
        liveAsBackground: liveAsBackground,
        onChanges: onChanges,
        onError: onError,
        onLoading: onLoading,
        onMessage: onMessage,
        onStatus: onStatus,
        child: child,
      );
    } catch (_) {
      throw AuthProviderException(
        "You should apply like AuthObserver<${AuthProvider.type}>()",
      );
    }
  }
}

class _Observer<T extends Auth> extends StatefulWidget {
  final List<String> ids;
  final bool liveAsBackground;
  final AuthController<T> controller;
  final OnAuthChanges<T>? onChanges;
  final OnAuthError? onError;
  final OnAuthLoading? onLoading;
  final OnAuthMessage? onMessage;
  final OnAuthStatus? onStatus;
  final Widget child;

  const _Observer({
    required this.ids,
    required this.controller,
    required this.liveAsBackground,
    required this.onChanges,
    required this.onError,
    required this.onLoading,
    required this.onMessage,
    required this.onStatus,
    required this.child,
  });

  @override
  State<_Observer<T>> createState() => _ObserverState<T>();
}

class _ObserverState<T extends Auth> extends State<_Observer<T>> {
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
    super.initState();
  }

  @override
  void didUpdateWidget(_Observer<T> oldWidget) {
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
  Widget build(BuildContext context) => widget.child;

  void _addListeners(AuthController<T> controller) {
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
