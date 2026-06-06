import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum SmxLayoutSize {
  mobile,
  tablet,
  desktop;

  static SmxLayoutSize fromWidth(double width) {
    if (width < 700) return SmxLayoutSize.mobile;
    if (width < 1100) return SmxLayoutSize.tablet;
    return SmxLayoutSize.desktop;
  }

  bool get isMobile => this == SmxLayoutSize.mobile;
  bool get isTablet => this == SmxLayoutSize.tablet;
  bool get isDesktop => this == SmxLayoutSize.desktop;
}

class SmxLayout {
  const SmxLayout._();

  static SmxLayoutSize sizeFromWidth(double width) {
    return SmxLayoutSize.fromWidth(width);
  }

  static bool isMobileWidth(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < 600;
  }

  static bool get isMobilePlatform {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  static bool isWebMobile(BuildContext context) {
    return kIsWeb && isMobileWidth(context) && isMobilePlatform;
  }

  static double topContentInset(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final systemTopInset = mediaQuery.padding.top > 0
        ? mediaQuery.padding.top
        : mediaQuery.viewPadding.top;

    if (systemTopInset > 0) return 0;

    return isWebMobile(context) ? 44 : 0;
  }
}
