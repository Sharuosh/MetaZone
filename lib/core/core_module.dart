import 'package:get_it/get_it.dart';

import 'network/network_info.dart';

abstract final class CoreModule {
  const CoreModule._();

  static void register(GetIt getIt) {
    if (!getIt.isRegistered<NetworkInfo>()) {
      getIt.registerLazySingleton<NetworkInfo>(
        NetworkInfo.new,
      );
    }
  }
}