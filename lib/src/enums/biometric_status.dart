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

  static BiometricStatus? from(Object? source) {
    return values.where((e) {
      if (e == source) return true;
      if (e.id == source) return true;
      if (e.name == source) return true;
      return false;
    }).firstOrNull;
  }

  factory BiometricStatus.value(bool value) {
    return value ? BiometricStatus.activated : BiometricStatus.deactivated;
  }
}
