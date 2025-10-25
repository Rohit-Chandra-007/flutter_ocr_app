import 'package:flutter/widgets.dart';
/// 
class AnimationSpec {
  const AnimationSpec({
    required this.begin,
    required this.end,
    this.curve = Curves.linear,
    this.interval,
  });

  final double begin;
  final double end;
  final Curve curve;
  final Interval? interval;

  Animation<double> drive(AnimationController controller) {
    final curveToUse = interval ?? curve;
    final curved = CurvedAnimation(parent: controller, curve: curveToUse);
    return Tween<double>(begin: begin, end: end).animate(curved);
  }
}
