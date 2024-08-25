import 'package:auth_management/core.dart';
import 'package:auth_management/src/utils/errors.dart';
import 'package:flutter/material.dart';

typedef OnAuthBuilder<T extends Auth> = Widget Function(
  BuildContext context,
  T? data,
);

class AuthBuilder<T extends Auth> extends StatelessWidget {
  final T? initial;
  final OnAuthErrorListener? onError;
  final OnAuthLoadingListener? onLoading;
  final OnAuthMessageListener? onMessage;
  final OnAuthStateChangeListener<T>? onStatus;
  final OnAuthBuilder<T> builder;

  const AuthBuilder({
    super.key,
    this.initial,
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
        onError: onError,
        onLoading: onLoading,
        onMessage: onMessage,
        onState: onStatus,
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
  final AuthController<T> controller;
  final OnAuthErrorListener? onError;
  final OnAuthLoadingListener? onLoading;
  final OnAuthMessageListener? onMessage;
  final OnAuthStateChangeListener<T>? onState;
  final OnAuthBuilder<T> builder;

  const _Child({
    required this.controller,
    this.initial,
    this.onError,
    this.onLoading,
    this.onMessage,
    this.onState,
    required this.builder,
  });

  @override
  State<_Child<T>> createState() => _ChildState<T>();
}

class _ChildState<T extends Auth> extends State<_Child<T>> {
  T? _data;

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
    if (widget.onState != null) {
      controller.liveState.addListener(_changeState);
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
    if (widget.onState != null) {
      controller.liveState.removeListener(_changeState);
    }
  }

  void _change([T? data]) {
    setState(() => _data = data ?? widget.controller.liveUser.value);
  }

  void _changeError() {
    if (widget.onError != null) {
      final value = widget.controller.errorText;
      if (value.isNotEmpty) {
        widget.onError?.call(context, value, widget.controller.args);
      }
    }
  }

  void _changeLoading() {
    if (widget.onLoading != null) {
      final value = widget.controller.loading;
      widget.onLoading?.call(context, value, widget.controller.args);
    }
  }

  void _changeMessage() {
    if (widget.onMessage != null) {
      final value = widget.controller.message;
      if (value.isNotEmpty) {
        widget.onMessage?.call(context, value, widget.controller.args);
      }
    }
  }

  void _changeState() {
    if (widget.onState != null) {
      final value = widget.controller.state;
      widget.onState?.call(
        context,
        value,
        _data ?? widget.controller.user,
        widget.controller.args,
      );
    }
  }
}
