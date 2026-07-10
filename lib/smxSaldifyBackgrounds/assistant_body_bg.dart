import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

import 'saldify_circles_background.dart';

class AssistantBodyBg extends StatelessWidget {
  const AssistantBodyBg({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: SaldifyCirclesBackgroundPainter(
        accentColor: SmxColors.brandSecondary,
      ),
    );
  }
}
