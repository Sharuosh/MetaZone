enum AppEnvironment {
  development,
  staging,
  production;

  bool get isDevelopment =>
      this == AppEnvironment.development;

  bool get isStaging =>
      this == AppEnvironment.staging;

  bool get isProduction =>
      this == AppEnvironment.production;
}