class BiometricConfig {
  final String deviceException;
  final String failureException;
  final String checkingException;
  final String localizedReason;
  final Object? options;

  // Android
  final String? biometricHint;
  final String? biometricNotRecognized;
  final String? biometricRequiredTitle;
  final String? biometricSuccess;
  final String? deviceCredentialsRequiredTitle;
  final String? deviceCredentialsSetupDescription;
  final String? signInTitle;

  // IOS
  final String? lockOut;
  final String? goToSettingsButton;
  final String? goToSettingsDescription;
  final String? cancelButton;
  final String? localizedFallbackTitle;

  const BiometricConfig({
    // Ios
    this.lockOut,
    this.goToSettingsButton,
    this.goToSettingsDescription,
    this.cancelButton,
    this.localizedFallbackTitle,
    // Android
    this.biometricHint,
    this.biometricNotRecognized,
    this.biometricRequiredTitle,
    this.biometricSuccess,
    this.deviceCredentialsRequiredTitle,
    this.deviceCredentialsSetupDescription,
    this.signInTitle,
    // Base
    this.deviceException = "Device isn't supported!",
    this.failureException = "Biometric matching failed!",
    this.checkingException = "Can not check biometrics!",
    this.localizedReason = "Please authenticate to show account balance",
    this.options,
  });
}
