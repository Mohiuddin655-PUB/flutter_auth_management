enum BiometricStatus {
  /// Biometric hardware is available and the user has enrolled credentials.
  available,

  /// The device has biometric hardware but no credentials are enrolled.
  notEnrolled,

  /// The device has no biometric hardware.
  unavailable,

  /// Biometric authentication is temporarily locked out (too many failures).
  lockedOut;

  bool get isAvailable => this == BiometricStatus.available;

  bool get isNotEnrolled => this == BiometricStatus.notEnrolled;

  bool get isUnavailable => this == BiometricStatus.unavailable;

  bool get isLockedOut => this == BiometricStatus.lockedOut;
}
