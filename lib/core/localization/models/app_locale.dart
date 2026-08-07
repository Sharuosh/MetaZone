import 'package:flutter/material.dart';

final class AppLocale {
  const AppLocale({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
    this.isRTL = false,
  });

  final String code;
  final String name;
  final String nativeName;
  final Locale locale;
  final bool isRTL;

  static const english = AppLocale(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    locale: Locale('en'),
  );

  static const arabic = AppLocale(
    code: 'ar',
    name: 'Arabic',
    nativeName: 'العربية',
    locale: Locale('ar'),
    isRTL: true,
  );

  AppLocale copyWith({
    String? code,
    String? name,
    String? nativeName,
    Locale? locale,
    bool? isRTL,
  }) {
    return AppLocale(
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      locale: locale ?? this.locale,
      isRTL: isRTL ?? this.isRTL,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppLocale && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}