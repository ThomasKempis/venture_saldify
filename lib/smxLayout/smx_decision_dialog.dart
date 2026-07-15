import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

enum SmxDecisionVariant { normal, success, warning, danger }

Future<bool> showSmxDecisionDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelText = 'Cancelar',
  String acceptText = 'Aceptar',
  IconData icon = Icons.delete_outline_rounded,
  SmxDecisionVariant variant = SmxDecisionVariant.normal,
  bool barrierDismissible = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => SmxDecisionDialog(
      title: title,
      message: message,
      cancelText: cancelText,
      acceptText: acceptText,
      icon: icon,
      variant: variant,
    ),
  );

  return confirmed == true;
}

class SmxDecisionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String acceptText;
  final IconData icon;
  final SmxDecisionVariant variant;

  const SmxDecisionDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelText = 'Cancelar',
    this.acceptText = 'Aceptar',
    this.icon = Icons.delete_outline_rounded,
    this.variant = SmxDecisionVariant.normal,
  });

  @override
  Widget build(BuildContext context) {
    final actionColor = _variantColor(variant);

    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 21, vertical: 18),
      backgroundColor: SmxColors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 292),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: SmxColors.surfaceQr.withValues(alpha: .96),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SmxDecisionBubblesPainter(actionColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: actionColor.withValues(alpha: .12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: actionColor, size: 23),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: SmxColors.textDark,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: SmxColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1.28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0x1F173144)),
                    SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          Expanded(
                            child: _SmxDialogAction(
                              label: cancelText,
                              color: SmxColors.textMuted,
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                          ),
                          const VerticalDivider(
                            width: 1,
                            color: Color(0x1F173144),
                          ),
                          Expanded(
                            child: _SmxDialogAction(
                              label: acceptText,
                              color: actionColor,
                              onPressed: () => Navigator.of(context).pop(true),
                              isPrimary: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _variantColor(SmxDecisionVariant variant) {
    return switch (variant) {
      SmxDecisionVariant.normal => SmxColors.brandSecondary,
      SmxDecisionVariant.success => SmxColors.successForeground,
      SmxDecisionVariant.warning => SmxColors.warningForeground,
      SmxDecisionVariant.danger => SmxColors.dangerForeground,
    };
  }
}

class _SmxDialogAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _SmxDialogAction({
    required this.label,
    required this.color,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.transparent,
      child: InkWell(
        onTap: onPressed,
        overlayColor: WidgetStatePropertyAll(color.withValues(alpha: .08)),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: isPrimary ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmxDecisionBubblesPainter extends CustomPainter {
  final Color accentColor;

  const _SmxDecisionBubblesPainter(this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBubble(
      canvas,
      center: Offset(size.width * .98, size.height * -.02),
      radius: size.shortestSide * .58,
      color: SmxColors.brandSecondary.withValues(alpha: .08),
    );
    _drawBubble(
      canvas,
      center: Offset(size.width * -.08, size.height * .90),
      radius: size.shortestSide * .44,
      color: SmxColors.brandPrimary.withValues(alpha: .05),
    );
    _drawBubble(
      canvas,
      center: Offset(size.width * .86, size.height * .92),
      radius: size.shortestSide * .32,
      color: accentColor.withValues(alpha: .05),
    );
  }

  void _drawBubble(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    canvas.drawCircle(center, radius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SmxDecisionBubblesPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}
