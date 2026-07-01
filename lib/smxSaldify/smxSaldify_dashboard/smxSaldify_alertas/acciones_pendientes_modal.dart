import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';

enum AccionPendienteTipo { clientesPendientes, creditoPendiente }

class AccionesPendientesModal extends StatelessWidget {
  final List<AccionPendienteTipo> acciones;
  final VoidCallback onClose;

  const AccionesPendientesModal({
    super.key,
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
