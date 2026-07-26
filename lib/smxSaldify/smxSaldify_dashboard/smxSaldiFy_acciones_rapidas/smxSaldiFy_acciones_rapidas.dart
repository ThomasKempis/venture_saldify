import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_acciones_rapidas_controller.dart';

class SmxSaldiFyAccionesRapidas extends StatelessWidget {
  final bool isMobile;
  final double cardWidth;
  final ValueChanged<String> onActionTap;

  const SmxSaldiFyAccionesRapidas({
    super.key,
    required this.isMobile,
    required this.cardWidth,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyAccionesRapidasController>(
      controllerBuilder: (context) => SmxSaldiFyAccionesRapidasController(
        alias: 'SMXSALDIFY_ACCIONES_RAPIDAS',
        data: SmxControllerSendData(context: context),
      ),
      builder: (context, controller) => _SmxSaldiFyAccionesRapidasView(
        isMobile: isMobile,
        cardWidth: cardWidth,
        onActionTap: onActionTap,
        controller: controller,
      ),
    );
  }
}

class _SmxSaldiFyAccionesRapidasView extends StatelessWidget {
  final bool isMobile;
  final double cardWidth;
  final ValueChanged<String> onActionTap;
  final SmxSaldiFyAccionesRapidasController controller;

  const _SmxSaldiFyAccionesRapidasView({
    required this.isMobile,
    required this.cardWidth,
    required this.onActionTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ActionsHeader(),
        const SizedBox(height: 12),
        _QuickActions(
          isMobile: isMobile,
          cardWidth: cardWidth,
          acciones: controller.rstAcciones,
          controller: controller,
          onActionTap: onActionTap,
        ),
      ],
    );
  }
}

class _ActionsHeader extends StatelessWidget {
  const _ActionsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Acciones rápidas',
            style: TextStyle(
              color: SmxColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final bool isMobile;
  final double cardWidth;
  final SmxRowSet acciones;
  final SmxSaldiFyAccionesRapidasController controller;
  final ValueChanged<String> onActionTap;

  const _QuickActions({
    required this.isMobile,
    required this.cardWidth,
    required this.acciones,
    required this.controller,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isMobile ? 118 : 126,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: const {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: acciones.getRowCount(),
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            acciones.index(index);
            final label = controller.getActionLabel();

            return SizedBox(
              width: cardWidth,
              child: _QuickActionCard(
                icon: controller.getActionIcon(),
                label: label,
                onTap: () => onActionTap(label),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.13),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SmxColors.whiteAlpha(.16)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: SmxColors.accentAlpha(.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: SmxColors.brandAccent, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: SmxColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
