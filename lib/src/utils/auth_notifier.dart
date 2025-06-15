import 'package:flutter/foundation.dart';

class AuthNotifier<T> extends ValueNotifier<T> {
  AuthNotifier(super.value);

  set notifiable(T current) {
    if (value == current) {
      notifyListeners();
    } else {
      super.value = current;
    }
  }
}
