import 'package:flutter/material.dart';

import 'saldify_circles_background.dart';

class ClienteMovimientoBg extends StatelessWidget {
  final Color accentColor;

  const ClienteMovimientoBg({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SaldifyCirclesBackgroundPainter(accentColor: accentColor),
    );
  }
}
