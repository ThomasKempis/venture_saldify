import 'package:flutter/material.dart';

import '../../smxSaldify_skeleton_block.dart';
import '../../../smxLayout/smxColors.dart';

class SmxSaldiFyClientesSkeleton extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;

  const SmxSaldiFyClientesSkeleton({
    super.key,
    required this.isMobile,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SkeletonSectionHeader(title: 'Clientes', trailing: 'Ver todos'),
        const SizedBox(height: 12),
        if (isMobile)
          const _ClientSkeletonCard()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 14.0;
              final maxColumns = _getMaxColumns(constraints.maxWidth);
              final visibleCount = maxColumns.clamp(1, 3).toInt();
              final cardWidth =
                  (constraints.maxWidth - (spacing * (visibleCount - 1))) /
                  visibleCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var index = 0; index < visibleCount; index++)
                    SizedBox(
                      width: cardWidth,
                      child: const _ClientSkeletonCard(),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }

  int _getMaxColumns(double width) {
    if (isDesktop && width >= 1180) return 4;
    if (isDesktop && width >= 820) return 3;
    return 2;
  }
}

class _ClientSkeletonCard extends StatelessWidget {
  const _ClientSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(child: SmxSaldiFySkeletonBlock(height: 26, alpha: .18)),
              SizedBox(width: 18),
              SmxSaldiFySkeletonBlock(
                width: 74,
                height: 34,
                radius: 16,
                alpha: .16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _ClientDataSkeleton()),
              SizedBox(width: 10),
              Expanded(child: _ClientDataSkeleton()),
              SizedBox(width: 10),
              Expanded(child: _ClientDataSkeleton(emphasis: true)),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: _ClientDataSkeleton()),
              SizedBox(width: 10),
              Expanded(child: _ClientDataSkeleton()),
              SizedBox(width: 10),
              Expanded(child: _ClientDataSkeleton()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClientDataSkeleton extends StatelessWidget {
  final bool emphasis;

  const _ClientDataSkeleton({this.emphasis = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emphasis
            ? SmxColors.brandAccent.withAlpha(28)
            : SmxColors.blackAlpha(.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmxSaldiFySkeletonBlock(width: 58, height: 14, alpha: .14),
          SizedBox(height: 8),
          SmxSaldiFySkeletonBlock(width: 76, height: 24, alpha: .18),
        ],
      ),
    );
  }
}

class _SkeletonSectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SkeletonSectionHeader({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: SmxColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: SmxColors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
