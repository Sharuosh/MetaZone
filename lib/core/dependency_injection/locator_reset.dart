import 'extensions/get_it_extensions.dart';
import 'service_locator.dart';

Future<void> resetLocator() async {
  await locator.resetLocator();
}