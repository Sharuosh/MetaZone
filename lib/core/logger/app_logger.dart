import 'dart:developer' as developer;

import '../errors/app_exception.dart';

/// Central logger for the application.
///
/// Replace its implementation later with Firebase Crashlytics
/// without affecting the rest of the project.
abstract final class AppLogger {
  const AppLogger._();

  static void debug(
      String message, {
        Object? data,
      }) {
    developer.log(
      message,
      name: 'MetaZone',
      error: data,
    );
  }

  static void info(
      String message, {
        Object? data,
      }) {
    developer.log(
      message,
      name: 'MetaZone',
      error: data,
    );
  }

  static void warning(
      String message, {
        Object? data,
      }) {
    developer.log(
      message,
      name: 'MetaZone',
      error: data,
    );
  }

  static void error(
      Object error, {
        StackTrace? stackTrace,
      }) {
    developer.log(
      error.toString(),
      name: 'MetaZone',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void exception(
      AppException exception,
      ) {
    developer.log(
      exception.message,
      name: 'MetaZone',
      error: exception,
      stackTrace: exception.stackTrace,
    );
  }
}