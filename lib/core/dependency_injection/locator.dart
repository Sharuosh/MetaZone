import 'locator_initializer.dart';

/// ================================================================
/// MetaZone Dependency Locator
/// ================================================================
///
/// This is the single public entry point used to initialize the
/// application's dependency graph.
///
/// Example:
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   await setupLocator();
///
///   runApp(const MetaZoneApp());
/// }
///
/// ================================================================

bool _isLocatorInitialized = false;

/// Initializes the application's dependency graph.
///
/// Safe to call multiple times.
Future<void> setupLocator() async {
  if (_isLocatorInitialized) {
    return;
  }

  final initializer = LocatorInitializer();

  await initializer.initialize();

  _isLocatorInitialized = true;
}

/// Returns whether the locator has already been initialized.
bool get isLocatorInitialized => _isLocatorInitialized;