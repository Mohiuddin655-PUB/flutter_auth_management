part of 'authorizer.dart';

mixin _AuthPhoneMixin<T extends Auth>
    on _AuthorizerBase<T>, _AuthEmitMixin<T>, _AuthUpdateMixin<T> {
  Future<AuthResponse<T>> signInByPhone(
    PhoneAuthenticator authenticator, {
    Object? multiFactorInfo,
    Object? multiFactorSession,
    Duration timeout = const Duration(minutes: 2),
    void Function(Credential credential)? onComplete,
    void Function(AuthException exception)? onFailed,
    void Function(String verId, int? forceResendingToken)? onCodeSent,
    void Function(String verId)? onCodeAutoRetrievalTimeout,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    try {
      delegate.verifyPhoneNumber(
        phoneNumber: authenticator.phone,
        forceResendingToken: int.tryParse(authenticator.resendToken ?? ''),
        multiFactorInfo: multiFactorInfo,
        multiFactorSession: multiFactorSession,
        timeout: timeout,
        onComplete: (credential) async {
          if (onComplete != null) {
            emit(
              const AuthResponse.message(
                'Verification done!',
                type: AuthType.otp,
              ),
              args: args,
              id: id,
              notifiable: notifiable,
            );
            onComplete(credential);
          } else {
            final verId = credential.verificationId;
            final code = credential.smsCode;
            if (verId != null && code != null) {
              await signInByOtp(
                OtpAuthenticator.phone(
                  token: verId,
                  code: code,
                  phone: authenticator.phone,
                ),
                args: args,
                id: id,
                notifiable: notifiable,
              );
            } else {
              emit(
                const AuthResponse.failure(
                  'Verification token or otp code not valid!',
                  type: AuthType.otp,
                ),
                args: args,
                id: id,
                notifiable: notifiable,
              );
            }
          }
        },
        onCodeSent: (verId, forceResendingToken) {
          emit(
            const AuthResponse.message(
              'Code sent to your device!',
              type: AuthType.otp,
            ),
            args: args,
            id: id,
            notifiable: notifiable,
          );
          onCodeSent?.call(verId, forceResendingToken);
        },
        onFailed: (exception) {
          emit(
            AuthResponse.failure(
              exception.msg,
              type: AuthType.otp,
            ),
            args: args,
            id: id,
            notifiable: notifiable,
          );
          onFailed?.call(exception);
        },
        onCodeAutoRetrievalTimeout: (verId) {
          emit(
            const AuthResponse.failure(
              'Auto retrieval code timeout!',
              type: AuthType.otp,
            ),
            args: args,
            id: id,
            notifiable: notifiable,
          );
          onCodeAutoRetrievalTimeout?.call(verId);
        },
      );
      return emit(
        const AuthResponse.loading(AuthType.otp),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return _failure(
        msg.signOut.failure ?? error.toString(),
        type: AuthType.otp,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> signInByOtp(
    OtpAuthenticator authenticator, {
    bool storeToken = false,
    Object? args,
    String? id,
    bool notifiable = true,
  }) async {
    emit(
      const AuthResponse.loading(AuthType.phone),
      args: args,
      id: id,
      notifiable: notifiable,
    );

    try {
      final hasAnonymous = this.hasAnonymous;
      final credential = delegate.credential(
        Credential(
          smsCode: authenticator.code,
          verificationId: authenticator.token,
        ),
      );

      final response = await delegate.signInWithCredential(credential);
      if (!response.isSuccessful) {
        return _failure(
          response.error,
          type: AuthType.phone,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final result = response.data;
      final uid = result?.uid ?? '';
      if (result == null || uid.isEmpty) {
        return _failure(
          msg.authorization,
          type: AuthType.phone,
          args: args,
          id: id,
          notifiable: notifiable,
        );
      }

      final value = await _update(
        id: uid,
        hasAnonymous: hasAnonymous,
        data: {
          keys.id: uid,
          keys.loggedIn: true,
          keys.loggedInTime: EntityHelper.generateTimeMills,
          keys.provider: 'PHONE_NUMBER',
          keys.phone: authenticator.value,
          keys.verified: true,
        },
      );

      return emit(
        AuthResponse.authenticated(
          value,
          msg: msg.signInWithPhone.done,
          type: AuthType.phone,
        ),
        args: args,
        id: id,
        notifiable: notifiable,
      );
    } catch (error) {
      return _failure(
        msg.signInWithPhone.failure ?? error.toString(),
        type: AuthType.phone,
        args: args,
        id: id,
        notifiable: notifiable,
      );
    }
  }

  Future<AuthResponse<T>> verifyPhoneByOtp(
    OtpAuthenticator authenticator,
  ) async {
    try {
      final credential = delegate.credential(
        Credential(
          smsCode: authenticator.code,
          verificationId: authenticator.token,
        ),
      );

      final response = await delegate.signInWithCredential(credential);
      if (!response.isSuccessful) {
        return AuthResponse.failure(
          response.error.isEmpty ? msg.authorization : response.error,
          type: AuthType.phone,
        );
      }

      final result = response.data;
      final uid = result?.uid ?? '';
      if (result == null || uid.isEmpty) {
        return AuthResponse.failure(
          msg.authorization,
          type: AuthType.phone,
        );
      }

      return AuthResponse<T>.authenticated(
        _backup.build({
          keys.id: uid,
          keys.loggedIn: true,
          keys.loggedInTime: EntityHelper.generateTimeMills,
          keys.provider: 'PHONE_NUMBER',
          keys.phone: result.phoneNumber,
          keys.verified: true,
        }),
        msg: msg.signInWithPhone.done,
        type: AuthType.phone,
      );
    } catch (error) {
      return AuthResponse.failure(
        msg.signInWithPhone.failure ?? error.toString(),
        type: AuthType.phone,
      );
    }
  }
}
