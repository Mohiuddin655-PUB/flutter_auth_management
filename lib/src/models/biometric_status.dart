enum BiometricStatus {
  initial(id: "INITIAL", name: "Initial"),
  activated(id: "ACTIVATED", name: "Activated"),
  deactivated(id: "DEACTIVATED", name: "Deactivated");

  final String id;
  final String name;

  bool get isInitial => this == initial;

  bool get isActivated => this == activated;

  bool get isDeactivated => this == deactivated;

  const BiometricStatus({
    required this.id,
    required this.name,
  });

  factory BiometricStatus.from(Object? source) {
    final key = source?.toString().trim().toUpperCase();
    if (key == BiometricStatus.activated.id) {
      return BiometricStatus.activated;
    } else if (key == BiometricStatus.deactivated.id) {
      return BiometricStatus.deactivated;
    } else {
      return BiometricStatus.initial;
    }
  }

  factory BiometricStatus.value(bool value) {
    return value ? BiometricStatus.activated : BiometricStatus.deactivated;
  }
}
