import 'package:flutter/material.dart';

import '../smxColors.dart';

class SmxSaldiFySkeletonBlock extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final double alpha;

  const SmxSaldiFySkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
    this.alpha = .18,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: width == null ? 1 : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: SmxColors.textDark.withAlpha((255 * alpha).round()),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
