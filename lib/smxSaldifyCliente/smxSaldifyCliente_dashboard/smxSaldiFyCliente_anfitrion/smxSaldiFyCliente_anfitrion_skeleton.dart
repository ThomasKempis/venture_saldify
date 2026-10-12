import 'package:flutter/material.dart';

import '../../../smxLayout/smxColors.dart';
import '../../../smxSaldify/smxSaldify_skeleton_block.dart';

class SmxSaldiFyClienteAnfitrionSkeleton extends StatelessWidget {
  const SmxSaldiFyClienteAnfitrionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.22),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: const Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _IconSkeleton(),
                SizedBox(width: 16),
                Expanded(child: _ContentSkeleton()),
              ],
            ),
          ),
          Positioned(
            right: 26,
            top: 0,
            bottom: 20,
            child: Center(
              child: SmxSaldiFySkeletonBlock(
                width: 38,
                height: 38,
                radius: 999,
                alpha: .18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconSkeleton extends StatelessWidget {
  const _IconSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: SmxColors.surfaceQr,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SmxColors.white, width: 5),
      ),
      child: const Center(
        child: SmxSaldiFySkeletonBlock(
          width: 36,
          height: 36,
          radius: 12,
          alpha: .20,
        ),
      ),
    );
  }
}

class _ContentSkeleton extends StatelessWidget {
  const _ContentSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: SmxSaldiFySkeletonBlock(height: 22, alpha: .20)),
            SizedBox(width: 8),
            SmxSaldiFySkeletonBlock(
              width: 72,
              height: 25,
              radius: 999,
              alpha: .18,
            ),
          ],
        ),
        SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SmxSaldiFySkeletonBlock(width: 92, height: 12, alpha: .16),
            SizedBox(height: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: SmxSaldiFySkeletonBlock(
                width: 168,
                height: 12,
                alpha: .16,
              ),
            ),
          ],
        ),
        SizedBox(height: 7),
        Row(
          children: [
            Expanded(child: SmxSaldiFySkeletonBlock(height: 14, alpha: .18)),
            SizedBox(width: 8),
            SmxSaldiFySkeletonBlock(width: 70, height: 14, alpha: .16),
          ],
        ),
        SizedBox(height: 7),
        Row(
          children: [
            Expanded(child: SmxSaldiFySkeletonBlock(height: 12, alpha: .14)),
            SizedBox(width: 8),
            SmxSaldiFySkeletonBlock(
              width: 86,
              height: 23,
              radius: 999,
              alpha: .18,
            ),
          ],
        ),
      ],
    );
  }
}
