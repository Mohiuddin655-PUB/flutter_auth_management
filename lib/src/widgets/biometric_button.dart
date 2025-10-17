import 'package:flutter/material.dart';

import '../core/helper.dart';
import '../models/auth.dart';
import '../utils/biometric_config.dart';

typedef BiometricButtonCallback = void Function(BuildContext context);

class BiometricButton<T extends Auth> extends StatelessWidget {
  final BiometricConfig? configs;

  final Widget Function(
    BuildContext context,
    BiometricButtonCallback callback,
  ) builder;

  const BiometricButton({
    super.key,
    required this.builder,
    this.configs,
  });

  void _callback(BuildContext context) {
    context.signInByBiometric<T>(config: configs);
  }

  @override
  Widget build(BuildContext context) {
    return builder(context, _callback);
  }
}
