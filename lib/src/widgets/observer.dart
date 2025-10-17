import 'package:flutter/material.dart';

import '../core/authorizer.dart';
import '../core/helper.dart';
import '../core/typedefs.dart';
import '../models/auth.dart';
import '../models/auth_changes.dart';
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
        authorizer: context.findAuthorizer<T>(),
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
  final Authorizer<T> authorizer;
  final OnAuthChanges<T>? onChanges;
  final OnAuthError? onError;
  final OnAuthLoading? onLoading;
  final OnAuthMessage? onMessage;
  final OnAuthStatus? onStatus;
  final Widget child;

  const _Observer({
    required this.ids,
    required this.authorizer,
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
    super.initState();
  }

  @override
  void didUpdateWidget(_Observer<T> oldWidget) {
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
  Widget build(BuildContext context) => widget.child;

  void _addListeners(Authorizer<T> authorizer) {
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
