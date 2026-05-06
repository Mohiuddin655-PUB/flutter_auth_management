part of 'authorizer.dart';

mixin _AuthBiometricMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T>, _AuthUpdateMixin<T> {
  Future<Response<T>> get canUseBiometric async {
    try {
      return await _checkBiometricEligibility();
    } catch (error) {
      return Response(status: Status.failure, error: error.toString());
    }
  }

  Future<Response<T>> biometricEnable(bool enabled) async {
    try {
      final eligibility = await _checkBiometricEligibility();
      if (!eligibility.isSuccessful) return eligibility;
      final auth = eligibility.data!;
      if (enabled) {
        final response = await delegate.signInWithBiometric();
        if (!response.isSuccessful) {
          return Response(status: response.status, error: response.error);
        }
      }
      final value = await _update(
        id: auth.id,
        updateMode: true,
        data: {keys.biometric: enabled},
      );
      return Response(status: Status.ok, data: value);
    } catch (error) {
      return Response(status: Status.failure, error: error.toString());
    }
  }

  Future<AuthResponse<T>> signInByBiometric({
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(Provider.biometric, AuthType.biometric),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final user = await _cachedAuth;
      if (user == null || !user.isBiometric) {
        return emit(
          AuthResponse.unauthorized(
            msg: msg.signInWithBiometric.failure ?? _errorNotifier.value,
            provider: Provider.biometric,
            type: AuthType.biometric,
          ),
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final response = await delegate.signInWithBiometric();
      if (!response.isSuccessful) {
        return _failure(
          response.error,
          provider: Provider.biometric,
          type: AuthType.biometric,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final provider = Provider.from(user.provider);
      var current = Response<Credential>();

      final hasCredentials = (user.email ?? user.username ?? '').isNotEmpty &&
          (user.password ?? '').isNotEmpty;

      if (hasCredentials) {
        if (provider.isEmail) {
          current = await delegate.signInWithEmailNPassword(
            user.email ?? '',
            user.password ?? '',
          );
        } else if (provider.isUsername) {
          current = await delegate.signInWithUsernameNPassword(
            user.username ?? '',
            user.password ?? '',
          );
        }
      }

      if (!current.isSuccessful) {
        return _failure(
          current.error,
          provider: Provider.biometric,
          type: AuthType.biometric,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final value = await _update(
        id: user.id,
        data: {
          keys.loggedIn: true,
          keys.loggedInTime: EntityHelper.generateTimeMills,
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithBiometric.done,
          provider: Provider.biometric,
          type: AuthType.biometric,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return _failure(
        msg.signInWithBiometric.failure ?? error.toString(),
        provider: Provider.biometric,
        type: AuthType.biometric,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<Response<T>> _checkBiometricEligibility() async {
    final auth = await _cachedAuth;
    final provider = Provider.from(auth?.provider);
    if (auth == null || !auth.isLoggedIn || !provider.isAllowBiometric) {
      return Response(
        status: Status.notSupported,
        error: 'User not logged in with email or username!',
      );
    }
    return Response(status: Status.ok, data: auth);
  }
}
