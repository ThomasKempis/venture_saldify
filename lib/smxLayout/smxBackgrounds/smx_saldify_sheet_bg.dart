import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

import 'saldify_circles_background.dart';

class SmxSaldifySheetBackground extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final BorderRadius borderRadius;
  final bool useSafeArea;

  const SmxSaldifySheetBackground({
    super.key,
    required this.child,
    this.accentColor = SmxColors.brandSecondary,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(26)),
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFBFEFE), Color(0xFFF3FAF9), Color(0xFFEEF7F6)],
        ),
        borderRadius: borderRadius,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: SaldifyCirclesBackgroundPainter(
                accentColor: accentColor,
              ),
            ),
          ),
          child,
        ],
      ),
    );

    if (!useSafeArea) return content;

    return SafeArea(top: false, child: content);
  }
}
