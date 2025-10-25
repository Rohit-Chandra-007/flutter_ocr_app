import 'package:flutter/widgets.dart';
import 'package:scanflow/core/animations/animation_specs.dart';
import 'package:scanflow/core/core.dart';

/// Groups all animations the splash screen needs so the widget tree stays lean.
class SplashAnimationBundle {
  SplashAnimationBundle({
    required this.controller,
    required this.fade,
    required this.scale,
    required this.slide,
    required this.rotate,
    required this.taglineFade,
  });

  final AnimationController controller;
  final Animation<double> fade;
  final Animation<double> scale;
  final Animation<double> slide;
  final Animation<double> rotate;
  final Animation<double> taglineFade;

  void dispose() => controller.dispose();
}

class SplashAnimations {
  const SplashAnimations._();

  static SplashAnimationBundle build(TickerProvider vsync) {
    final controller = AppAnimations.controller(
      vsync: vsync,
      duration: AppConstants.splashIntro,
    );

    final fade = const AnimationSpec(
      begin: 0,
      end: 1,
      interval: Interval(0.0, 0.5, curve: Curves.easeOut),
    ).drive(controller);

    final scale = const AnimationSpec(
      begin: 0.5,
      end: 1.0,
      interval: Interval(0.0, 0.6, curve: Curves.elasticOut),
    ).drive(controller);

    final slide = const AnimationSpec(
      begin: 50.0,
      end: 0.0,
      interval: Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    ).drive(controller);

    final rotate = const AnimationSpec(
      begin: -0.1,
      end: 0.0,
      interval: Interval(0.0, 0.6, curve: Curves.easeOut),
    ).drive(controller);

    final taglineFade = const AnimationSpec(
      begin: 0,
      end: 1,
      interval: Interval(0.5, 1.0, curve: Curves.easeIn),
    ).drive(controller);

    return SplashAnimationBundle(
      controller: controller,
      fade: fade,
      scale: scale,
      slide: slide,
      rotate: rotate,
      taglineFade: taglineFade,
    );
  }
}
