class ScanController {
  bool scanning = false;

  double progress = 0;

  void startScan() {
    scanning = true;
    progress = 0;
  }

  void updateProgress(double value) {
    progress = value;
  }

  void stopScan() {
    scanning = false;
  }
}