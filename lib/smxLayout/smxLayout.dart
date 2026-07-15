import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:venture_saldify/smxLayout/smxColors.dart';

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
    final cssTopInset = _cssPixelValue('--saldify-safe-area-top');

    if (systemTopInset > 0 || cssTopInset > 0) {
      return systemTopInset > cssTopInset ? systemTopInset : cssTopInset;
    }

    return 0;
  }

  static double bottomContentInset(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final systemBottomInset = mediaQuery.padding.bottom > 0
        ? mediaQuery.padding.bottom
        : mediaQuery.viewPadding.bottom;
    final cssBottomInset = _cssPixelValue('--saldify-safe-area-bottom');

    if (systemBottomInset > 0 || cssBottomInset > 0) {
      return systemBottomInset > cssBottomInset
          ? systemBottomInset
          : cssBottomInset;
    }

    return 0;
  }

  static double _cssPixelValue(String propertyName) {
    if (!kIsWeb) return 0;

    final root = html.document.documentElement;
    if (root == null) return 0;

    final rawValue = root
        .getComputedStyle()
        .getPropertyValue(propertyName)
        .trim();
    if (rawValue.isEmpty) return 0;

    return double.tryParse(rawValue.replaceAll('px', '').trim()) ?? 0;
  }
}

class SmxSaldifyBackground extends StatelessWidget {
  final Widget child;
  final bool showBubbles;

  const SmxSaldifyBackground({
    super.key,
    required this.child,
    this.showBubbles = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: SmxGradients.saldifyBackground),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (showBubbles)
            const IgnorePointer(child: CustomPaint(painter: _SaldifyBubbles())),
          child,
        ],
      ),
    );
  }
}

class SmxSaldifyScreenHeader extends StatelessWidget {
  final String title;
  final String sectionLabel;
  final VoidCallback onBackPressed;
  final List<Widget> actions;

  const SmxSaldifyScreenHeader({
    super.key,
    required this.title,
    required this.sectionLabel,
    required this.onBackPressed,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SmxSaldifyHeaderIconButton(
          tooltip: 'Regresar',
          icon: Icons.arrow_back_rounded,
          onPressed: onBackPressed,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                sectionLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.brandAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        for (final action in actions) ...[const SizedBox(width: 8), action],
      ],
    );
  }
}

class SmxSaldifyHeaderIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const SmxSaldifyHeaderIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      color: SmxColors.white,
      style: IconButton.styleFrom(
        backgroundColor: SmxColors.whiteAlpha(.12),
        fixedSize: const Size(44, 44),
      ),
    );
  }
}

class _SaldifyBubbles extends CustomPainter {
  const _SaldifyBubbles();

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;

    _drawBubble(
      canvas,
      center: Offset(size.width + shortest * .05, shortest * .22),
      radius: shortest * .38,
      alpha: .12,
    );
    _drawBubble(
      canvas,
      center: Offset(-shortest * .12, size.height * .40),
      radius: shortest * .26,
      alpha: .08,
    );
    _drawBubble(
      canvas,
      center: Offset(size.width * .86, size.height * .88),
      radius: shortest * .32,
      alpha: .10,
    );
    _drawBubble(
      canvas,
      center: Offset(size.width * .28, size.height * .78),
      radius: shortest * .18,
      alpha: .06,
    );
  }

  void _drawBubble(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double alpha,
  }) {
    final paint = Paint()..color = SmxColors.whiteAlpha(alpha);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
