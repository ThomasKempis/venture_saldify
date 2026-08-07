import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';
import 'smxSaldiFy_lealtad_controller.dart';
import 'smx_lealtad_qr_card.dart';
import 'smx_lealtad_reward_card.dart';
import 'smx_lealtad_list_card.dart';

class SmxSaldiFyLealtad extends StatelessWidget {
  final VoidCallback onBackPressed;

  const SmxSaldiFyLealtad({super.key, required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyLealtadController>(
      controllerBuilder: (context) => SmxSaldiFyLealtadController(
        alias: 'SMXSALDIFY_LEALTAD',
        data: SmxControllerSendData(context: context),
      )..init(),
      builder: (context, controller) =>
          _LealtadView(onBackPressed: onBackPressed, controller: controller),
    );
  }
}

class _LealtadView extends StatefulWidget {
  final VoidCallback onBackPressed;
  final SmxSaldiFyLealtadController controller;

  const _LealtadView({required this.onBackPressed, required this.controller});

  @override
  State<_LealtadView> createState() => _LealtadViewState();
}

class _LealtadViewState extends State<_LealtadView> {
  @override
  Widget build(BuildContext context) {
    final layout = SmxLayout.sizeFromWidth(MediaQuery.of(context).size.width);
    final pagePadding = layout.saldifyPagePadding;
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);

    return SizedBox.expand(
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
                      title: 'Programa de lealtad',
                      sectionLabel: 'Comparte tu código de lealtad',
                      onBackPressed: widget.onBackPressed,
                    ),
                    const SizedBox(height: 22),
                    
                    // 1. Tarjeta de Código QR
                    SmxLealtadQrCard(controller: widget.controller),
                    
                    const SizedBox(height: 20),
                    
                    // 2. Tarjeta de Recompensas (Monedas y Estrellas)
                    SmxLealtadRewardCard(controller: widget.controller),
                    
                    const SizedBox(height: 20),
                    
                    // 3. Panel de Historial de Invitaciones
                    SmxLealtadListCard(controller: widget.controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
