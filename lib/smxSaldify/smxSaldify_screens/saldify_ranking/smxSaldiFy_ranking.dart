import 'package:flutter/material.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_ranking_controller.dart';

class SmxSaldiFyRanking extends StatelessWidget {
  const SmxSaldiFyRanking({super.key});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyRankingController>(
      controllerBuilder: (context) => SmxSaldiFyRankingController(
        alias: 'SMXSALDIFY_RANKING',
        data: SmxControllerSendData(context: context),
      ),
      builder: (context, controller) => SizedBox.square(
        dimension: 28,
        child: Center(
          child: SizedBox.square(
            dimension: 24,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: Icon(
                    Icons.star_rounded,
                    color: Color(0x66FFFFFF),
                    size: 24,
                  ),
                ),
                Positioned.fill(
                  child: ClipRect(
                    clipper: _RankingClipper(controller.porcentajeRanking),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFC94A),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RankingClipper extends CustomClipper<Rect> {
  final double porcentaje;

  const _RankingClipper(this.porcentaje);

  @override
  Rect getClip(Size size) {
    final value = porcentaje.clamp(0.0, 1.0);
    final width = size.width * value;
    return Rect.fromLTWH(size.width - width, 0, width, size.height);
  }

  @override
  bool shouldReclip(_RankingClipper oldClipper) {
    return porcentaje != oldClipper.porcentaje;
  }
}
