import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:venture_saldify/smxApis/smxCodeSegu.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/saldify_circles_background.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smx_message_dialog.dart';
import 'smxSaldiFy_lealtad_controller.dart';

class SmxLealtadQrCard extends StatelessWidget {
  final SmxSaldiFyLealtadController controller;

  const SmxLealtadQrCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final inv = controller.invitacion;
        final link = inv?.link ?? '';

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: SmxColors.whiteAlpha(.96),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: SmxColors.blackAlpha(.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(
                  painter: SaldifyCirclesBackgroundPainter(
                    accentColor: SmxColors.brandSecondary,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _RefreshButton(controller: controller),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Text(
                      'Comparte tu código',
                      style: TextStyle(
                        color: SmxColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Usa este código para invitar nuevos anfitriones al programa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SmxColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: 210,
                      height: 210,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SmxColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: SmxColors.blackAlpha(.08),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: controller.loadingInvitacion || inv == null
                          ? const Center(child: CircularProgressIndicator())
                          : QrImageView(
                              data: link,
                              version: QrVersions.auto,
                              size: 186,
                              padding: EdgeInsets.zero,
                            ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      inv != null 
                        ? SmxGenCodeSeguridad.format(inv.codigo)
                        : 'Generando código...',
                      style: const TextStyle(
                        color: SmxColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: inv == null ? null : () => _copy(context, link),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('COPIAR LINK DE INVITACIÓN'),
                        style: FilledButton.styleFrom(
                          backgroundColor: SmxColors.brandPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _copy(BuildContext context, String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (!context.mounted) return;
    showSmxValidDialog(context, mensaje: '¡Enlace copiado al portapapeles!');
  }
}

class _RefreshButton extends StatelessWidget {
  final SmxSaldiFyLealtadController controller;
  const _RefreshButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0D47A1),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: controller.loadingInvitacion
            ? null
            : () => controller.generarNuevaInvitacion(),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          child: controller.loadingInvitacion
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
