import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

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

  double get saldifyMaxContentWidth => switch (this) {
    SmxLayoutSize.mobile => 460,
    SmxLayoutSize.tablet => 860,
    SmxLayoutSize.desktop => 1180,
  };

  EdgeInsets get saldifyPagePadding => switch (this) {
    SmxLayoutSize.mobile => const EdgeInsets.fromLTRB(20, 20, 20, 28),
    SmxLayoutSize.tablet => const EdgeInsets.fromLTRB(28, 28, 28, 34),
    SmxLayoutSize.desktop => const EdgeInsets.fromLTRB(36, 34, 36, 40),
  };

  int saldifyMetricColumnsFor(double width) {
    if (width >= 980) return 4;
    if (width >= 700) return 3;
    if (width >= 300) return 2;
    return 1;
  }

  double get saldifyQuickActionCardWidth => switch (this) {
    SmxLayoutSize.mobile => 136,
    SmxLayoutSize.tablet => 180,
    SmxLayoutSize.desktop => 220,
  };
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

  static bool get isWebStandalone {
    if (!kIsWeb) return false;

    final standalone = html.window.matchMedia('(display-mode: standalone)');
    final fullscreen = html.window.matchMedia('(display-mode: fullscreen)');

    return standalone.matches || fullscreen.matches;
  }

  static double topContentInset(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final systemTopInset = mediaQuery.padding.top > 0
        ? mediaQuery.padding.top
        : mediaQuery.viewPadding.top;

    if (systemTopInset > 0) return 0;

    return isWebMobile(context) && isWebStandalone ? 44 : 0;
  }
}
