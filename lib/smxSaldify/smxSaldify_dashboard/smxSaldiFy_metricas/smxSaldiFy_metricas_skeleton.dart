import 'package:flutter/material.dart';

import '../../../smxApis/smxSaldiFy_skeleton_block.dart';
import '../../../smxColors.dart';

class SmxSaldiFyMetricasSkeleton extends StatelessWidget {
  final bool isMobile;

  const SmxSaldiFyMetricasSkeleton({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 660;

            if (isCompact) {
              return const _CompactTopSkeletonCard();
            }

            return const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 9, child: _RadialSkeletonCard()),
                SizedBox(width: 12),
                Expanded(flex: 11, child: _MetricasSkeletonGrid()),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CompactTopSkeletonCard extends StatelessWidget {
  const _CompactTopSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SmxColors.whiteAlpha(.18)),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _RadialSkeletonRing(size: 132),
          SizedBox(width: 10),
          Expanded(
            child: _MetricasSkeletonGrid(
              itemCount: 4,
              mainAxisExtent: 62,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadialSkeletonCard extends StatelessWidget {
  const _RadialSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 240),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SmxColors.whiteAlpha(.18)),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.14),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Center(child: _RadialSkeletonRing(size: 176))],
      ),
    );
  }
}

class _RadialSkeletonRing extends StatelessWidget {
  final double size;

  const _RadialSkeletonRing({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * .875,
            height: size * .875,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: SmxColors.whiteAlpha(.18), width: 14),
            ),
          ),
          Container(
            width: size * .64,
            height: size * .64,
            decoration: BoxDecoration(
              color: SmxColors.accentAlpha(.08),
              shape: BoxShape.circle,
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SmxSaldiFySkeletonBlock(width: 58, height: 14, alpha: .26),
              SizedBox(height: 10),
              SmxSaldiFySkeletonBlock(width: 92, height: 28, alpha: .38),
              SizedBox(height: 10),
              SmxSaldiFySkeletonBlock(width: 80, height: 14, alpha: .26),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricasSkeletonGrid extends StatelessWidget {
  final int itemCount;
  final double mainAxisExtent;
  final bool compact;

  const _MetricasSkeletonGrid({
    this.itemCount = 4,
    this.mainAxisExtent = 114,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: compact ? 8 : 12,
        crossAxisSpacing: compact ? 8 : 12,
        mainAxisExtent: mainAxisExtent,
      ),
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _MetricSkeletonCard(compact: compact);
      },
    );
  }
}

class _MetricSkeletonCard extends StatelessWidget {
  final bool compact;

  const _MetricSkeletonCard({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 14),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.13),
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        border: Border.all(color: SmxColors.whiteAlpha(.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmxSaldiFySkeletonBlock(
            width: compact ? 68 : 94,
            height: compact ? 12 : 16,
            alpha: .28,
          ),
          SmxSaldiFySkeletonBlock(
            width: compact ? 72 : 112,
            height: compact ? 20 : 30,
            alpha: .38,
          ),
          if (!compact)
            const SmxSaldiFySkeletonBlock(width: 74, height: 16, alpha: .26),
        ],
      ),
    );
  }
}
