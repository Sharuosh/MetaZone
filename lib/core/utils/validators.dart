import 'package:flutter/foundation.dart';

/// Collection of reusable validation helpers.
///
/// These methods are intentionally lightweight and have
/// no dependency on Flutter widgets or forms.
abstract final class Validators {
  const Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^\+?[0-9]{7,15}$',
  );

  static final RegExp _usernameRegex = RegExp(
    r'^[a-zA-Z0-9._]{3,20}$',
  );

  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');

  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');

  static final RegExp _numberRegex = RegExp(r'[0-9]');

  static final RegExp _specialRegex = RegExp(
    r'[!@#$%^&*(),.?":{}|<>]',
  );

  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  static bool isNotNullOrEmpty(String? value) {
    return !isNullOrEmpty(value);
  }

  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  static bool isValidPhone(String phone) {
    return _phoneRegex.hasMatch(phone.trim());
  }

  static bool isValidUsername(String username) {
    return _usernameRegex.hasMatch(username.trim());
  }

  static bool isValidPassword(
      String password, {
        int minLength = 8,
      }) {
    return password.length >= minLength;
  }

  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
        _uppercaseRegex.hasMatch(password) &&
        _lowercaseRegex.hasMatch(password) &&
        _numberRegex.hasMatch(password) &&
        _specialRegex.hasMatch(password);
  }

  static bool hasMinLength(
      String value,
      int length,
      ) {
    return value.length >= length;
  }

  static bool hasMaxLength(
      String value,
      int length,
      ) {
    return value.length <= length;
  }

  static bool isBetweenLength(
      String value, {
        required int min,
        required int max,
      }) {
    return value.length >= min && value.length <= max;
  }

  @visibleForTesting
  static void reset() {}
}