import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/historial_linear_bg.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'smxSaldiFy_lealtad_controller.dart';

class SmxLealtadListCard extends StatelessWidget {
  final SmxSaldiFyLealtadController controller;
  const SmxLealtadListCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final rst = controller.rstHistorial;
        final count = rst?.getRowCount() ?? 0;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: SmxColors.whiteAlpha(.94),
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
              const Positioned.fill(child: HistorialLinearBg()),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Invitaciones',
                      style: TextStyle(color: SmxColors.textDark, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const Text(
                      'Las invitaciones caducan en 24 horas.',
                      style: TextStyle(color: SmxColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    if (controller.loadingHistorial && rst == null)
                      const Center(child: CircularProgressIndicator())
                    else if (count == 0)
                      const _EmptyState()
                    else
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
                          ),
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: count,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              rst!.index(index);
                              return _ItemCard(
                                codigo: rst.getValue('SYSUSER91_CODIGO'),
                                invitado: rst.getValue('SYSUSER91_INVITADO'),
                                fechaCrea: rst.getValue('SYSUSER91_FAPL'),
                                fechaReg: rst.getValue('SYSUSER91_FECHA_REG'),
                              );
                            },
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
}

class _ItemCard extends StatelessWidget {
  final String? codigo;
  final String? invitado;
  final dynamic fechaCrea;
  final dynamic fechaReg;

  const _ItemCard({this.codigo, this.invitado, this.fechaCrea, this.fechaReg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: SmxColors.whiteAlpha(.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(codigo ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                fechaReg != null ? 'Completado' : 'Pendiente',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: fechaReg != null ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            invitado ?? 'Sin registrar',
            style: TextStyle(color: invitado != null ? SmxColors.textDark : SmxColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Label(label: 'Enviada:', fecha: fechaCrea),
              _Label(label: 'Registro:', fecha: fechaReg),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;
  final dynamic fecha;
  const _Label({required this.label, this.fecha});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label ', style: const TextStyle(fontSize: 10, color: SmxColors.textMuted)),
        Text(
          fecha != null ? fecha.toString().split(' ')[0] : '---',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SmxColors.textDark),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Aún no hay invitados registrados.', style: TextStyle(color: SmxColors.textMuted)),
      ),
    );
  }
}
