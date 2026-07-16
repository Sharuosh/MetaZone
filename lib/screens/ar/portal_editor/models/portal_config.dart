// File: portal_config.dart
// MetaZone – Unified Portal Configuration (2025 FINAL PRO VERSION)

import 'dart:convert';

class PortalConfig {
  // ============================================================
  // BASIC PROPERTIES
  // ============================================================
  String shape;
  String surface;
  String coreType;
  String teleportDestination;

  // ============================================================
  // COMPLEX PANELS — FULL MAP DATA
  // ============================================================
  Map<String, dynamic> environment;   // fog / lighting / skybox
  Map<String, dynamic> fx;            // effects panel
  Map<String, dynamic> physics;       // physics panel
  Map<String, dynamic> animation;     // animation panel
  Map<String, dynamic> sound;         // sound panel
  Map<String, dynamic> color;         // color panel
  Map<String, dynamic> presets;       // saved templates

  // NEW PANELS
  Map<String, dynamic> lighting;      // LightingPanel
  Map<String, dynamic> transform;     // TransformPanel

  // ============================================================
  // CONSTRUCTOR
  // ============================================================
  PortalConfig({
    this.shape = "circle",
    this.surface = "neon",
    this.coreType = "vortex",
    this.teleportDestination = "none",

    Map<String, dynamic>? environment,
    Map<String, dynamic>? fx,
    Map<String, dynamic>? physics,
    Map<String, dynamic>? animation,
    Map<String, dynamic>? sound,
    Map<String, dynamic>? color,
    Map<String, dynamic>? presets,

    Map<String, dynamic>? lighting,
    Map<String, dynamic>? transform,
  })  :
        environment = environment ?? defaultEnvironment(),
        fx = fx ?? defaultFX(),
        physics = physics ?? defaultPhysics(),
        animation = animation ?? defaultAnimation(),
        sound = sound ?? defaultSound(),
        color = color ?? defaultColor(),
        presets = presets ?? {},

  // NEW DEFAULTS
        lighting = lighting ?? defaultLighting(),
        transform = transform ?? defaultTransform();

  // ============================================================
  // DEFAULTS
  // ============================================================
  static Map<String, dynamic> defaultEnvironment() => {
    "fogDensity": 0.0,
    "fogDistance": 15.0,
    "ambientLight": 0.6,
    "directionalLight": 0.8,
    "lightRotation": 45.0,
    "environmentTemp": 6500,
    "skybox": "Nebula",
  };

  static Map<String, dynamic> defaultFX() => {
    "glow": 0.6,
    "outline": 0.4,
    "distortion": 0.3,
    "hologramNoise": 0.5,
    "particles": 0.4,
    "vortex": 0.2,
    "warpField": 0.35,
    "chroma": 0.25,
    "animSpeed": 1.0,
  };

  static Map<String, dynamic> defaultPhysics() => {
    "mass": 1.0,
    "gravityScale": 1.0,
    "linearDamping": 0.05,
    "angularDamping": 0.05,
    "collisionEnabled": true,
    "collisionShape": "Convex Mesh",
  };

  static Map<String, dynamic> defaultAnimation() => {
    "speed": 1.0,
    "opening": "expand",
    "closing": "shrink",
  };

  static Map<String, dynamic> defaultSound() => {
    "ambient": "portal_hum",
    "volume": 0.6,
  };

  static Map<String, dynamic> defaultColor() => {
    "mode": "solid",
    "solid": 0xFF00FFFF,
    "opacity": 1.0,
    "gradient": [
      0xFF9C27B0,
      0xFF2196F3,
    ],
    "glowIntensity": 0.6,
    "holoTint": 0xFF2196F3,
  };

  // NEW PANEL DEFAULTS
  static Map<String, dynamic> defaultLighting() => {
    "globalLight": 0.8,
    "rimLight": 0.4,
    "bloom": 0.3,
    "shadowSoftness": 0.6,
    "ambientOcclusion": 0.5,
    "lightTemperature": 6500,
  };

  static Map<String, dynamic> defaultTransform() => {
    "posX": 0.0,
    "posY": 0.0,
    "posZ": 0.0,
    "rotX": 0.0,
    "rotY": 0.0,
    "rotZ": 0.0,
    "scale": 1.0,
  };

  // ============================================================
  // COPY-WITH
  // ============================================================
  PortalConfig copyWith({
    String? shape,
    String? surface,
    String? coreType,
    String? teleportDestination,
    Map<String, dynamic>? environment,
    Map<String, dynamic>? fx,
    Map<String, dynamic>? physics,
    Map<String, dynamic>? animation,
    Map<String, dynamic>? sound,
    Map<String, dynamic>? color,
    Map<String, dynamic>? presets,

    Map<String, dynamic>? lighting,
    Map<String, dynamic>? transform,
  }) {
    return PortalConfig(
      shape: shape ?? this.shape,
      surface: surface ?? this.surface,
      coreType: coreType ?? this.coreType,
      teleportDestination: teleportDestination ?? this.teleportDestination,

      environment: environment ?? this.environment,
      fx: fx ?? this.fx,
      physics: physics ?? this.physics,
      animation: animation ?? this.animation,
      sound: sound ?? this.sound,
      color: color ?? this.color,
      presets: presets ?? this.presets,

      lighting: lighting ?? this.lighting,
      transform: transform ?? this.transform,
    );
  }

  // ============================================================
  // JSON
  // ============================================================
  Map<String, dynamic> toJson() => {
    "shape": shape,
    "surface": surface,
    "coreType": coreType,
    "teleportDestination": teleportDestination,
    "environment": environment,
    "fx": fx,
    "physics": physics,
    "animation": animation,
    "sound": sound,
    "color": color,
    "presets": presets,
    "lighting": lighting,
    "transform": transform,
  };

  factory PortalConfig.fromJson(Map<String, dynamic> json) {
    return PortalConfig(
      shape: json["shape"] ?? "circle",
      surface: json["surface"] ?? "neon",
      coreType: json["coreType"] ?? "vortex",
      teleportDestination: json["teleportDestination"] ?? "none",

      environment: json["environment"] ?? defaultEnvironment(),
      fx: json["fx"] ?? defaultFX(),
      physics: json["physics"] ?? defaultPhysics(),
      animation: json["animation"] ?? defaultAnimation(),
      sound: json["sound"] ?? defaultSound(),
      color: json["color"] ?? defaultColor(),
      presets: json["presets"] ?? {},

      lighting: json["lighting"] ?? defaultLighting(),
      transform: json["transform"] ?? defaultTransform(),
    );
  }

  String encode() => jsonEncode(toJson());
  static PortalConfig decode(String data) => PortalConfig.fromJson(jsonDecode(data));
}
