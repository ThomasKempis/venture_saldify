import 'package:flutter/material.dart';

import '../../../smxSaldify/smxSaldify_skeleton_block.dart';
import '../../../smxColors.dart';

class SmxSaldiFyClienteHistorialSkeleton extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;

  const SmxSaldiFyClienteHistorialSkeleton({
    super.key,
    required this.isMobile,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    final cards = List<Widget>.generate(3, (_) => const _MovimientoSkeleton());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _HistorialSkeletonHeader(),
        const SizedBox(height: 12),
        if (isMobile)
          Column(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                if (index > 0) const SizedBox(height: 12),
                cards[index],
              ],
            ],
          )
        else
          GridView.count(
            crossAxisCount: isDesktop ? 3 : 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: isDesktop ? 2.55 : 2.25,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cards,
          ),
      ],
    );
  }
}

class _HistorialSkeletonHeader extends StatelessWidget {
  const _HistorialSkeletonHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SmxSaldiFySkeletonBlock(width: 132, height: 26, alpha: .24),
        Spacer(),
        SmxSaldiFySkeletonBlock(width: 62, height: 14, alpha: .20),
      ],
    );
  }
}

class _MovimientoSkeleton extends StatelessWidget {
  const _MovimientoSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SmxColors.whiteAlpha(.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 52,
            decoration: BoxDecoration(
              color: SmxColors.whiteAlpha(.18),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SmxSaldiFySkeletonBlock(height: 16, alpha: .22),
                    ),
                    SizedBox(width: 8),
                    SmxSaldiFySkeletonBlock(
                      width: 74,
                      height: 22,
                      radius: 999,
                      alpha: .20,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    SmxSaldiFySkeletonBlock(width: 48, height: 12, alpha: .18),
                    SizedBox(width: 10),
                    Expanded(
                      child: SmxSaldiFySkeletonBlock(height: 12, alpha: .16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SmxSaldiFySkeletonBlock(width: 62, height: 20, alpha: .24),
        ],
      ),
    );
  }
}
