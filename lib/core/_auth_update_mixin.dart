part of 'authorizer.dart';

mixin _AuthUpdateMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T> {
  Future<T?> update(
    Map<String, dynamic> data, {
    String? id,
    bool notifiable = true,
    bool lazyRemoteUpdate = true,
  }) async {
    if (data.isEmpty) return _userNotifier.value;
    try {
      final ok = await _backup.update(data, lazyRemoteUpdate);
      if (!ok) return null;
      return _userNotifier.value;
    } catch (error) {
      if (!_disposed && notifiable) _errorNotifier.value = error.toString();
      return null;
    }
  }

  Future<T?> _update({
    required String id,
    Map<String, dynamic> data = const {},
    bool updateMode = false,
    bool hasAnonymous = false,
    SignByBiometricCallback<T>? onBiometric,
  }) async {
    try {
      var finalData = data;
      if (onBiometric != null) {
        final biometric = await onBiometric(
          _backup.build({...?_userNotifier.value?.source, ...data}),
        );
        finalData = {...data, keys.biometric: biometric};
      }

      final encrypted = finalData.map(
        (k, v) => MapEntry(k, _backup.encryptor(k, v)),
      );

      final saved = await _backup.save(
        id: id,
        data: encrypted,
        cacheUpdateMode: updateMode,
        hasAnonymous: hasAnonymous,
      );

      if (!saved) return _userNotifier.value;

      final updated = await _cachedAuth ??
          _backup.build({...?_userNotifier.value?.source, ...finalData});
      if (updated != _userNotifier.value) _emitUser(updated);
      return updated;
    } catch (error) {
      if (!_disposed) _errorNotifier.value = error.toString();
      return null;
    }
  }
}
