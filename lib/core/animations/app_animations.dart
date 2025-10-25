import 'package:flutter/widgets.dart';
import 'package:scanflow/core/constants/app_constants.dart';

/// Factory helpers for creating controllers with shared defaults.
class AppAnimations {
  const AppAnimations._();

  static AnimationController controller({
    required TickerProvider vsync,
    Duration duration = AppConstants.regular,
  }) {
    return AnimationController(
      vsync: vsync,
      duration: duration,
    );
  }
}
