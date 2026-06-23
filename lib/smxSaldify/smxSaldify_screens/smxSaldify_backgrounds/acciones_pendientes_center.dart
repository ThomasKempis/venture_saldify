import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';

enum AccionPendienteTipo { clientesPendientes, creditoPendiente }

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.acciones.isEmpty) {
      return const SizedBox.shrink();
    }

    final width = widget.isMobile ? 220.0 : 238.0;
    final height = widget.isMobile ? 76.0 : 82.0;
    final visibleHandle = widget.isMobile ? 48.0 : 52.0;
    const expandedOffset = 20.0;
    final hiddenOffset = width - visibleHandle;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideOffset(hiddenOffset, expandedOffset), 0),
          child: child,
        );
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
    );
  }

  double _slideOffset(double hiddenOffset, double expandedOffset) {
    final value = _controller.value;

    if (value < .018) {
      return hiddenOffset -
          ((hiddenOffset - expandedOffset) *
              Curves.easeOutCubic.transform(value / .018));
    }

    if (value < .075) {
      return expandedOffset;
    }

    if (value < .095) {
      return expandedOffset +
          ((hiddenOffset - expandedOffset) *
              Curves.easeInCubic.transform((value - .075) / .020));
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
          child: _AccionesPendientesPanel(
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

class _AccionesPendientesPanel extends StatelessWidget {
  final List<AccionPendienteTipo> acciones;
  final VoidCallback onClose;

  const _AccionesPendientesPanel({
    required this.acciones,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.98),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9FBFD), Color(0xFFEAF5F6), Color(0xFFE3F3EA)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _PanelPendingPainter()),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: _PanelCopy()),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close_rounded),
                        color: const Color(0xFF123247),
                        style: IconButton.styleFrom(
                          backgroundColor: SmxColors.whiteAlpha(.50),
                          fixedSize: const Size(36, 36),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (final accion in acciones) ...[
                    _PendingActionCard(accion: accion),
                    const SizedBox(height: 10),
                  ],
                  const _PanelWarning(),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _PanelButton(onPressed: onClose),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PanelCopy extends StatelessWidget {
  const _PanelCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones pendientes',
          style: TextStyle(
            color: Color(0xFF123247),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Revisa lo que falta para completar el flujo de tus clientes.',
          style: TextStyle(
            color: Color(0xFF31566B),
            fontSize: 13,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _PendingActionCard extends StatelessWidget {
  final AccionPendienteTipo accion;

  const _PendingActionCard({required this.accion});

  @override
  Widget build(BuildContext context) {
    final data = _PendingActionData.from(accion);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.58),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SmxColors.whiteAlpha(.74), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF58D69B),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: const Color(0xFF123247), size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    color: Color(0xFF123247),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.body,
                  style: const TextStyle(
                    color: Color(0xFF31566B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingActionData {
  final IconData icon;
  final String title;
  final String body;

  const _PendingActionData({
    required this.icon,
    required this.title,
    required this.body,
  });

  factory _PendingActionData.from(AccionPendienteTipo accion) {
    return switch (accion) {
      AccionPendienteTipo.clientesPendientes => const _PendingActionData(
        icon: Icons.person_add_alt_1_rounded,
        title: 'Clientes pendientes',
        body:
            'Invitalos con link o WhatsApp, o activalos tu si llevaras sus compras y pagos.',
      ),
      AccionPendienteTipo.creditoPendiente => const _PendingActionData(
        icon: Icons.credit_card_rounded,
        title: 'Credito pendiente',
        body:
            'Da clic sobre la tarjeta del cliente y selecciona Actualizar credito.',
      ),
    };
  }
}

class _PanelWarning extends StatelessWidget {
  const _PanelWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD166).withValues(alpha: .24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD166).withValues(alpha: .58),
          width: 1,
        ),
      ),
      child: const Text(
        'Estas ayudas son informativas: elige el cliente correcto desde su tarjeta.',
        style: TextStyle(
          color: Color(0xFF123247),
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1.3,
        ),
      ),
    );
  }
}

class _PanelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PanelButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.40),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: SmxColors.whiteAlpha(.72), width: 1.2),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Entendido',
                style: TextStyle(
                  color: Color(0xFF123247),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_rounded, color: Color(0xFF123247), size: 19),
            ],
          ),
        ),
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

class _PanelPendingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * .86, size.height * .14),
      size.shortestSide * .22,
      Paint()..color = const Color(0xFF58D69B).withValues(alpha: .13),
    );
    canvas.drawCircle(
      Offset(size.width * .72, size.height * .96),
      size.shortestSide * .30,
      Paint()..color = const Color(0xFF14577A).withValues(alpha: .10),
    );
    canvas.drawCircle(
      Offset(size.width * .92, size.height * .32),
      8,
      Paint()..color = const Color(0xFFFFD166),
    );
    canvas.drawCircle(
      Offset(size.width * .55, size.height * .78),
      7,
      Paint()..color = const Color(0xFF14577A),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
