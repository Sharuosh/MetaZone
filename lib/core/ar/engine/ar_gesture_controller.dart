class ARGestureController {
  const ARGestureController();

  double normalizeRotation(double angle) {
    var value = angle % 360;

    if (value < 0) {
      value += 360;
    }

    return value;
  }

  double normalizeScale(
      double scale, {
        double min = .1,
        double max = 10,
      }) {
    if (scale < min) return min;

    if (scale > max) return max;

    return scale;
  }
}