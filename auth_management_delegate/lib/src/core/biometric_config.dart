import '../biometric/delegate.dart';

class BiometricConfig {
  final String deviceException;
  final String failureException;
  final String checkingException;
  final String localizedReason;
  final IBiometricOptions options;

  // Android
  final String? biometricHint;
  final String? biometricNotRecognized;
  final String? biometricRequiredTitle;
  final String? biometricSuccess;
  final String? deviceCredentialsRequiredTitle;
  final String? deviceCredentialsSetupDescription;
  final String? signInTitle;

  AndroidBiometricMessages get androidAuthMessages {
    return AndroidBiometricMessages(
      biometricHint: biometricHint,
      biometricNotRecognized: biometricNotRecognized,
      biometricRequiredTitle: biometricRequiredTitle,
      biometricSuccess: biometricSuccess,
      cancelButton: cancelButton,
      deviceCredentialsRequiredTitle: deviceCredentialsRequiredTitle,
      deviceCredentialsSetupDescription: deviceCredentialsSetupDescription,
      goToSettingsButton: goToSettingsButton,
      goToSettingsDescription: goToSettingsDescription,
      signInTitle: signInTitle,
    );
  }

  // IOS
  final String? lockOut;
  final String? goToSettingsButton;
  final String? goToSettingsDescription;
  final String? cancelButton;
  final String? localizedFallbackTitle;

  IOSBiometricMessages get iosAuthMessages {
    return IOSBiometricMessages(
      lockOut: lockOut,
      goToSettingsButton: goToSettingsButton,
      goToSettingsDescription: goToSettingsDescription,
      cancelButton: cancelButton,
      localizedFallbackTitle: localizedFallbackTitle,
    );
  }

  // Windows
  WindowsBiometricMessages get windowsAuthMessages {
    return const WindowsBiometricMessages();
  }

  List<IBiometricMessages> get authMessages {
    return [
      androidAuthMessages,
      iosAuthMessages,
      windowsAuthMessages,
    ];
  }

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
    this.options = const IBiometricOptions(
      stickyAuth: true,
      biometricOnly: true,
    ),
  });
}
