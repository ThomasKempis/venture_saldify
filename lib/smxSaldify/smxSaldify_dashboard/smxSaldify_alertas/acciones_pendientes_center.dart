import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

import 'acciones_pendientes_modal.dart';

export 'acciones_pendientes_modal.dart' show AccionPendienteTipo;

class AccionesPendientesCenter extends StatefulWidget {
  final List<AccionPendienteTipo> acciones;
  final bool isMobile;

  const AccionesPendientesCenter({
    super.key,
    required this.acciones,
    required this.isMobile,
  });

  @override
  State<AccionesPendientesCenter> createState() =>
      _AccionesPendientesCenterState();
}

class _AccionesPendientesCenterState extends State<AccionesPendientesCenter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _previousControllerValue = 0.0;
  var _dismissedThisCycle = false;
  var _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(minutes: 1))
          ..addListener(_handleAnimationTick)
          ..repeat();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleAnimationTick);
    _controller.dispose();
    super.dispose();
  }

  void _handleAnimationTick() {
    final value = _controller.value;
    if (value < _previousControllerValue && _dismissedThisCycle) {
      setState(() {
        _dismissedThisCycle = false;
        _dragOffset = 0;
      });
    }
    _previousControllerValue = value;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.acciones.isEmpty) {
      return const SizedBox.shrink();
    }

    final width = widget.isMobile ? 220.0 : 238.0;
    final height = widget.isMobile ? 76.0 : 82.0;
    const expandedOffset = 20.0;
    final hiddenOffset = width + 40;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_currentOffset(hiddenOffset, expandedOffset), 0),
          child: child,
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx <= 0) return;
          setState(() {
            _dragOffset = (_dragOffset + details.delta.dx).clamp(
              0,
              hiddenOffset - expandedOffset,
            );
          });
        },
        onHorizontalDragEnd: (details) {
          final shouldDismiss =
              _dragOffset > 28 ||
              details.primaryVelocity != null && details.primaryVelocity! > 120;
          setState(() {
            _dismissedThisCycle = shouldDismiss;
            _dragOffset = 0;
          });
        },
        child: Material(
          color: SmxColors.transparent,
          child: InkWell(
            onTap: () => _showPendingCenter(context),
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(height / 2),
            ),
            child: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _FloatingPendingPainter()),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      widget.isMobile ? 16 : 18,
                      10,
                      18,
                      10,
                    ),
                    child: Row(
                      children: [
                        _FloatingIcon(count: widget.acciones.length),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Acciones',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF123247),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'pendientes',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF31566B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF123247),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _currentOffset(double hiddenOffset, double expandedOffset) {
    if (_dismissedThisCycle) {
      return hiddenOffset;
    }

    return (_slideOffset(hiddenOffset, expandedOffset) + _dragOffset).clamp(
      expandedOffset,
      hiddenOffset,
    );
  }

  double _slideOffset(double hiddenOffset, double expandedOffset) {
    final value = _controller.value;

    if (value < .018) {
      return hiddenOffset -
          ((hiddenOffset - expandedOffset) *
              Curves.easeOutCubic.transform(value / .018));
    }

    if (value < .151) {
      return expandedOffset;
    }

    if (value < .171) {
      return expandedOffset +
          ((hiddenOffset - expandedOffset) *
              Curves.easeInCubic.transform((value - .151) / .020));
    }

    return hiddenOffset;
  }

  void _showPendingCenter(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: SmxColors.blackAlpha(.42),
      builder: (dialogContext) => Dialog(
        backgroundColor: SmxColors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: widget.isMobile ? 18 : 28,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: AccionesPendientesModal(
            acciones: widget.acciones,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final int count;

  const _FloatingIcon({required this.count});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: SmxColors.whiteAlpha(.72),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pending_actions_rounded,
                color: Color(0xFF123247),
                size: 25,
              ),
            ),
          ),
          Positioned(
            right: -1,
            top: -2,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD166),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Color(0xFF123247),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingPendingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(size.height / 2),
      bottomLeft: Radius.circular(size.height / 2),
    );

    canvas.drawRRect(
      rrect.shift(const Offset(0, 8)),
      Paint()
        ..color = SmxColors.blackAlpha(.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawRRect(rrect, Paint()..color = SmxColors.whiteAlpha(.94));
    canvas.drawCircle(
      Offset(size.width * .84, size.height * .18),
      size.height * .58,
      Paint()..color = const Color(0xFF58D69B).withValues(alpha: .15),
    );
    canvas.drawCircle(
      Offset(size.width * .72, size.height * .96),
      size.height * .56,
      Paint()..color = const Color(0xFF14577A).withValues(alpha: .10),
    );
    canvas.drawCircle(
      Offset(size.width * .90, size.height * .28),
      7,
      Paint()..color = const Color(0xFFFFD166),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
