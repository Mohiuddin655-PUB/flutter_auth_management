import 'package:flutter/material.dart'
    show BuildContext, Widget, VoidCallback, StatefulWidget, State;

import '../core/authorizer.dart' show SignByBiometricCallback;
import '../models/auth.dart' show Auth;
import '../models/auth_button_type.dart' show AuthButtonType;
import '../models/authenticator.dart' show Authenticator;
import 'action_factory.dart' show AuthActionFactory;
import 'actions.dart' show AuthAction;

/// Callback signature for the button builder.
///
/// [callback] triggers the auth action. It is `null` while an action is in
/// progress, letting callers disable or style the button accordingly.
typedef AuthButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback? callback,
);

/// A stateful widget that wires an [AuthButtonType] to a builder-pattern UI.
///
/// Responsibilities:
/// - Resolves the correct [AuthAction] via [AuthActionFactory].
/// - Manages loading state so callers can disable the button while busy.
/// - Surfaces errors through the optional [onError] callback instead of
///   swallowing or crashing.
///
/// Example:
/// ```dart
/// AuthButton<AppUser>(
///   type: AuthButtonType.signInWithGoogle,
///   storeToken: true,
///   onError: (e) => showSnackBar(context, e.toString()),
///   builder: (context, callback) => ElevatedButton(
///     onPressed: callback,
///     child: const Text('Sign in with Google'),
///   ),
/// )
/// ```
class AuthButton<T extends Auth> extends StatefulWidget {
  final Object? args;
  final String? id;
  final bool notifiable;
  final AuthButtonType type;
  final Authenticator? authenticator;
  final bool storeToken;
  final Map<String, dynamic>? updates;
  final SignByBiometricCallback? onBiometric;

  /// Called with any error thrown during [AuthAction.execute].
  /// If null, errors are rethrown.
  final void Function(Object error)? onError;

  /// Builder receives a nullable [VoidCallback]:
  /// - non-null  → idle, safe to press
  /// - null      → loading, should disable the button
  final AuthButtonBuilder builder;

  const AuthButton({
    super.key,
    this.args,
    this.id,
    this.notifiable = true,
    required this.type,
    required this.builder,
    this.authenticator,
    this.storeToken = false,
    this.updates,
    this.onBiometric,
    this.onError,
  });

  @override
  State<AuthButton<T>> createState() => _AuthButtonState<T>();
}

class _AuthButtonState<T extends Auth> extends State<AuthButton<T>> {
  bool _loading = false;

  Future<void> _handleTap() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final action = AuthActionFactory.build<T>(
        type: widget.type,
        authenticator: widget.authenticator,
        updates: widget.updates,
        onBiometric: widget.onBiometric,
        storeToken: widget.storeToken,
        id: widget.id,
        args: widget.args,
        notifiable: widget.notifiable,
      );
      await action.execute(context);
    } catch (error) {
      final handler = widget.onError;
      if (handler != null) {
        handler(error);
      } else {
        rethrow;
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _loading ? null : _handleTap,
    );
  }
}
