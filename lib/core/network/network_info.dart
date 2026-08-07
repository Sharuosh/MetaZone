import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final class NetworkInfo {
  NetworkInfo({
    InternetConnection? checker,
  }) : _checker = checker ?? InternetConnection();

  final InternetConnection _checker;

  Future<bool> get isConnected {
    return _checker.hasInternetAccess;
  }

  Stream<InternetStatus> get onStatusChange {
    return _checker.onStatusChange;
  }
}