import 'package:flutter/material.dart';

class NavigationUtils {
  /// Navigate with fade and slide transition
  static Future<T?> navigateWithFadeSlide<T>(
    BuildContext context,
    Widget destination, {
    Duration duration = const Duration(milliseconds: 300),
    Offset beginOffset = const Offset(0.0, 0.1),
    Curve curve = Curves.easeOutCubic,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: beginOffset,
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: curve,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: duration,
      ),
    );
  }

  /// Navigate with fade transition only
  static Future<T?> navigateWithFade<T>(
    BuildContext context,
    Widget destination, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: duration,
      ),
    );
  }

  /// Navigate with slide transition only
  static Future<T?> navigateWithSlide<T>(
    BuildContext context,
    Widget destination, {
    Duration duration = const Duration(milliseconds: 300),
    Offset beginOffset = const Offset(1.0, 0.0),
    Curve curve = Curves.easeOutCubic,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: curve,
            )),
            child: child,
          );
        },
        transitionDuration: duration,
      ),
    );
  }
}
