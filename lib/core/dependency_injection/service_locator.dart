import 'package:get_it/get_it.dart';

/// ================================================================
/// MetaZone Service Locator
/// ================================================================
///
/// Central GetIt instance used across the entire application.
///
/// Rules:
/// - Never create another GetIt instance.
/// - Never register services outside registration files.
/// - Access dependencies only through [locator].
///
/// ================================================================

typedef ServiceLocator = GetIt;

/// Global application locator.
final ServiceLocator locator = GetIt.instance;