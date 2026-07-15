import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import '../../smxSaldify_dashboard/smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'smxSaldiFy_mired_controller.dart';

class SmxSaldiFyMiRed extends StatelessWidget {
  final SmxSaldiFyClientTapData client;

  const SmxSaldiFyMiRed({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyMiRedController>(
      controllerBuilder: (context) => SmxSaldiFyMiRedController(
        alias: 'SMXSALDIFY_MI_RED',
        data: SmxControllerSendData(context: context),
        idSysuser11Raiz: client.idSysuser11,
      ),
      builder: (context, controller) =>
          _MiRedView(client: client, controller: controller),
    );
  }
}

class _MiRedView extends StatelessWidget {
  final SmxSaldiFyClientTapData client;
  final SmxSaldiFyMiRedController controller;

  const _MiRedView({required this.client, required this.controller});

  @override
  Widget build(BuildContext context) {
    final layout = SmxLayout.sizeFromWidth(MediaQuery.of(context).size.width);
    final pagePadding = layout.saldifyPagePadding;
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);

    return Scaffold(
      backgroundColor: SmxColors.transparent,
      body: SizedBox.expand(
        child: SmxSaldifyBackground(
          child: SafeArea(
            top: false,
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: layout.saldifyMaxContentWidth,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    pagePadding.left,
                    pagePadding.top + topContentInset,
                    pagePadding.right,
                    pagePadding.bottom + bottomContentInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SmxSaldifyScreenHeader(
                        title: 'Mi red de Venta',
                        sectionLabel: client.name,
                        onBackPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 22),
                      if (controller.hasNodes)
                        _MiRedTree(nodes: controller.nodes)
                      else
                        const _EmptyRedCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiRedTree extends StatelessWidget {
  static const double _nodeWidth = 218;
  static const double _nodeHeight = 92;
  static const double _horizontalGap = 34;
  static const double _verticalGap = 72;

  final List<SmxMiRedNode> nodes;

  const _MiRedTree({required this.nodes});

  @override
  Widget build(BuildContext context) {
    final viewportMaxHeight = math.max(
      440.0,
      MediaQuery.sizeOf(context).height -
          SmxLayout.topContentInset(context) -
          SmxLayout.bottomContentInset(context) -
          130,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _TreeLayout.build(
          nodes,
          nodeWidth: _nodeWidth,
          nodeHeight: _nodeHeight,
          horizontalGap: _horizontalGap,
          verticalGap: _verticalGap,
          minWidth: constraints.maxWidth,
        );
        final viewportHeight = viewportMaxHeight;
        final initialX = (constraints.maxWidth / 2) - layout.rootCenterX;
        final transformationController = TransformationController(
          Matrix4.translationValues(initialX, 0.0, 0.0),
        );

        return SizedBox(
          height: viewportHeight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: SmxColors.whiteAlpha(.14),
                border: Border.all(color: SmxColors.whiteAlpha(.18), width: 1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: InteractiveViewer(
                transformationController: transformationController,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(70),
                minScale: .62,
                maxScale: 1.35,
                child: SizedBox(
                  width: layout.width,
                  height: layout.height,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _TreeConnectionsPainter(layout),
                        ),
                      ),
                      for (final entry in layout.entries)
                        Positioned(
                          left: entry.x,
                          top: entry.y,
                          width: _nodeWidth,
                          height: _nodeHeight,
                          child: _TreeNodeCard(node: entry.node),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TreeNodeCard extends StatelessWidget {
  final SmxMiRedNode node;

  const _TreeNodeCard({required this.node});

  @override
  Widget build(BuildContext context) {
    final active = node.status == 1;
    final statusColor = active
        ? SmxColors.brandPrimary
        : SmxColors.warningForeground;
    final initials = _initials(node.nombreCompleto);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SmxColors.surfaceQr.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withValues(alpha: .18), width: 1),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.16),
            blurRadius: 16,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    node.nombreCompleto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SmxColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    node.correo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SmxColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          node.telefono,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SmxColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          node.statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts[1].characters.first}'
        .toUpperCase();
  }
}

class _TreeConnectionsPainter extends CustomPainter {
  final _TreeLayout layout;

  const _TreeConnectionsPainter(this.layout);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SmxColors.whiteAlpha(.64)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final entry in layout.entries) {
      final parent = layout.entryByPath[entry.parentPath];
      if (parent == null) continue;

      final parentBottom = Offset(
        parent.x + layout.nodeWidth / 2,
        parent.y + layout.nodeHeight,
      );
      final childTop = Offset(entry.x + layout.nodeWidth / 2, entry.y);
      final midY = parentBottom.dy + ((childTop.dy - parentBottom.dy) / 2);

      final path = Path()
        ..moveTo(parentBottom.dx, parentBottom.dy)
        ..lineTo(parentBottom.dx, midY)
        ..lineTo(childTop.dx, midY)
        ..lineTo(childTop.dx, childTop.dy);

      canvas.drawPath(path, paint);

      canvas.drawCircle(
        childTop,
        4.2,
        Paint()
          ..color = SmxColors.brandAccent.withValues(alpha: .92)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TreeConnectionsPainter oldDelegate) {
    return oldDelegate.layout != layout;
  }
}

class _TreeLayout {
  final List<_TreeLayoutEntry> entries;
  final Map<String, _TreeLayoutEntry> entryByPath;
  final double width;
  final double height;
  final double nodeWidth;
  final double nodeHeight;
  final double rootCenterX;

  const _TreeLayout({
    required this.entries,
    required this.entryByPath,
    required this.width,
    required this.height,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.rootCenterX,
  });

  static _TreeLayout build(
    List<SmxMiRedNode> source, {
    required double nodeWidth,
    required double nodeHeight,
    required double horizontalGap,
    required double verticalGap,
    required double minWidth,
  }) {
    final sorted = [...source]..sort((a, b) => a.path.compareTo(b.path));
    final byPath = {for (final node in sorted) node.path: node};
    final childrenByPath = <String, List<SmxMiRedNode>>{};

    for (final node in sorted) {
      final parentPath = _parentPath(node.path);
      if (parentPath == null || !byPath.containsKey(parentPath)) continue;
      childrenByPath.putIfAbsent(parentPath, () => []).add(node);
    }

    final root = sorted.firstWhere((node) => node.nivel == 0);
    final xByPath = <String, double>{};
    var nextLeafX = 24.0;

    double assignX(SmxMiRedNode node) {
      final children = childrenByPath[node.path] ?? const <SmxMiRedNode>[];
      if (children.isEmpty) {
        final x = nextLeafX;
        xByPath[node.path] = x;
        nextLeafX += nodeWidth + horizontalGap;
        return x;
      }

      final childXs = children.map(assignX).toList();
      final x = (childXs.first + childXs.last) / 2;
      xByPath[node.path] = x;
      return x;
    }

    assignX(root);

    final rootCenter = (xByPath[root.path] ?? 24.0) + (nodeWidth / 2);
    final desiredRootCenter = minWidth / 2;
    final shiftX = math.max(0.0, desiredRootCenter - rootCenter);
    final entries = <_TreeLayoutEntry>[];
    var maxX = minWidth;
    var maxY = 0.0;
    var rootCenterX = minWidth / 2;

    for (final node in sorted) {
      final x = (xByPath[node.path] ?? 24.0) + shiftX;
      final y = 24.0 + (node.nivel * (nodeHeight + verticalGap));
      if (node.path == root.path) {
        rootCenterX = x + (nodeWidth / 2);
      }
      maxX = math.max(maxX, x + nodeWidth + 24);
      maxY = math.max(maxY, y + nodeHeight + 24);
      entries.add(
        _TreeLayoutEntry(
          node: node,
          x: x,
          y: y,
          parentPath: _parentPath(node.path),
        ),
      );
    }

    return _TreeLayout(
      entries: entries,
      entryByPath: {for (final entry in entries) entry.node.path: entry},
      width: math.max(maxX, nodeWidth + 48),
      height: math.max(maxY, nodeHeight + 48),
      nodeWidth: nodeWidth,
      nodeHeight: nodeHeight,
      rootCenterX: rootCenterX,
    );
  }

  static String? _parentPath(String path) {
    final index = path.lastIndexOf('.');
    if (index <= 0) return null;
    return path.substring(0, index);
  }
}

class _TreeLayoutEntry {
  final SmxMiRedNode node;
  final double x;
  final double y;
  final String? parentPath;

  const _TreeLayoutEntry({
    required this.node,
    required this.x,
    required this.y,
    required this.parentPath,
  });
}

class _EmptyRedCard extends StatelessWidget {
  const _EmptyRedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.84),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'Sin red de venta registrada.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: SmxColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
