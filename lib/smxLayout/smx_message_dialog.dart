import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

enum SmxMessageVariant { info, validation, error }

void showSmxValidDialog(
  BuildContext context, {
  String? titulo = 'Validación de datos',
  required String mensaje,
  String buttonText = 'Aceptar',
}) {
  showSmxMessageDialog(
    context,
    title: titulo ?? 'Validación de datos',
    message: mensaje,
    buttonText: buttonText,
    icon: Icons.info_outline_rounded,
    variant: SmxMessageVariant.validation,
    barrierDismissible: false,
  );
}

Future<void> showSmxSystemErrorDialog(
  BuildContext context, {
  String message = 'Dialogo de Error',
  String cancelText = 'Cancelar',
}) {
  return showSmxMessageDialog(
    context,
    title: 'Error del sistema',
    message: message,
    buttonText: cancelText,
    icon: Icons.error_outline_rounded,
    variant: SmxMessageVariant.error,
    barrierDismissible: false,
  );
}

Future<void> showSmxMessageDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonText = 'Aceptar',
  IconData icon = Icons.info_outline_rounded,
  SmxMessageVariant variant = SmxMessageVariant.info,
  bool barrierDismissible = true,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => SmxMessageDialog(
      title: title,
      message: message,
      buttonText: buttonText,
      icon: icon,
      variant: variant,
    ),
  );
}

class SmxMessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final IconData icon;
  final SmxMessageVariant variant;

  const SmxMessageDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Aceptar',
    this.icon = Icons.info_outline_rounded,
    this.variant = SmxMessageVariant.info,
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
                    painter: _SmxMessageBubblesPainter(actionColor),
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
                      width: double.infinity,
                      child: _SmxMessageAction(
                        label: buttonText,
                        color: actionColor,
                        onPressed: () => Navigator.of(context).pop(),
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

  static Color _variantColor(SmxMessageVariant variant) {
    return switch (variant) {
      SmxMessageVariant.info => SmxColors.brandSecondary,
      SmxMessageVariant.validation => SmxColors.warningForeground,
      SmxMessageVariant.error => SmxColors.dangerForeground,
    };
  }
}

class _SmxMessageAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SmxMessageAction({
    required this.label,
    required this.color,
    required this.onPressed,
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
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SmxMessageBubblesPainter extends CustomPainter {
  final Color accentColor;

  const _SmxMessageBubblesPainter(this.accentColor);

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
  bool shouldRepaint(covariant _SmxMessageBubblesPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}
