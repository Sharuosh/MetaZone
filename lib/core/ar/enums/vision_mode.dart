enum VisionMode {
  camera,

  ar,

  mixed,

  navigation,

  creator,

  debug,
}

extension VisionModeX on VisionMode {
  bool get usesCamera =>
      this != VisionMode.debug;

  bool get isAR =>
      this == VisionMode.ar;

  bool get isCreator =>
      this == VisionMode.creator;

  bool get isNavigation =>
      this == VisionMode.navigation;
}