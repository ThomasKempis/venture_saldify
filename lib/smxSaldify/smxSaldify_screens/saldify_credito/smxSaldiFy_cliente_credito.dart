import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_screens/saldify_credito/smxSaldiFy_cliente_credito_controller.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_screens/saldify_credito/smxSaldiFy_cliente_credito_tarjetas.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';
import 'package:venture_widgets/smxNumberField/smxNumberField.dart';
import '../../smxSaldify_dashboard/smxSaldiFy_clientes/smxSaldiFy_clientes.dart';

class SmxSaldiFyClienteCredito extends StatelessWidget {
  final SmxSaldiFyClientTapData client;

  const SmxSaldiFyClienteCredito({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClienteCreditoController>(
      controllerBuilder: (context) => SmxSaldiFyClienteCreditoController(
        alias: 'SMXSALDIFY_CLIENTE_CREDITO',
        data: SmxControllerSendData(context: context),
        idSysuser11: client.idSysuser11,
      ),
      builder: (context, controller) =>
          _ClienteCreditoView(controller: controller, client: client),
    );
  }
}

class _ClienteCreditoView extends StatefulWidget {
  final SmxSaldiFyClienteCreditoController controller;
  final SmxSaldiFyClientTapData client;

  const _ClienteCreditoView({required this.controller, required this.client});

  @override
  State<_ClienteCreditoView> createState() => _ClienteCreditoViewState();
}

class _ClienteCreditoViewState extends State<_ClienteCreditoView> {
  bool _showPlanSelector = true;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final layout = SmxLayout.sizeFromWidth(MediaQuery.of(context).size.width);
    final pagePadding = layout.saldifyPagePadding;
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);

    return Scaffold(
      backgroundColor: SmxColors.transparent,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: SmxGradients.saldifyBackground,
          ),
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
                      _Header(title: widget.client.name),
                      const SizedBox(height: 22),
                      if (_showPlanSelector)
                        SmxSaldiFyCreditoPlanSelector(
                          value: controller.plan,
                          onSelected: (value) {
                            controller.setPlan(value);
                            setState(() {
                              _showPlanSelector = false;
                            });
                          },
                        )
                      else
                        _FormPanel(
                          controller: controller,
                          onChanged: () => setState(() {}),
                        ),
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

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          color: SmxColors.white,
          style: IconButton.styleFrom(
            backgroundColor: SmxColors.whiteAlpha(.12),
            fixedSize: const Size(44, 44),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Actualizar credito',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: SmxColors.brandAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormPanel extends StatelessWidget {
  final SmxSaldiFyClienteCreditoController controller;
  final VoidCallback onChanged;

  const _FormPanel({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final corteTipo = controller.corteTipo;

    return Material(
      color: SmxColors.whiteAlpha(.96),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SmxNumberField(
              field: 'SYSUSER12_CREDITO',
              controller: controller,
              label: 'Credito',
              decimales: 2,
              minValue: 0,
              currency: true,
              isValid: true,
            ),
            const SizedBox(height: 18),
            _CutTypeSelector(
              value: corteTipo,
              onChanged: (value) {
                controller.setCorteTipo(value);
                onChanged();
              },
            ),
            const SizedBox(height: 20),
            _CutConfigDivider(corteTipo: corteTipo),
            const SizedBox(height: 16),
            if (corteTipo == 1)
              _MonthDaySelector(
                value: controller.corteDiaMensual,
                onChanged: (value) {
                  controller.setCorteDiaMensual(value);
                  onChanged();
                },
              ),
            if (corteTipo == 2)
              _FortnightSelector(
                value: controller.corteQuincena,
                onChanged: (value) {
                  controller.setCorteQuincena(value);
                  onChanged();
                },
              ),
            if (corteTipo == 3)
              _WeekSelector(
                value: controller.corteSemana,
                values: controller.diasSemana,
                onChanged: (value) {
                  controller.setCorteSemana(value);
                  onChanged();
                },
              ),
            const SizedBox(height: 22),
            _SaveButton(
              label: controller.isAlta
                  ? 'Dar de alta credito'
                  : 'Guardar cambios',
              onPressed: () async {
                await controller.save();
                if (context.mounted && controller.lastSaveOk) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CutConfigDivider extends StatelessWidget {
  final int corteTipo;

  const _CutConfigDivider({required this.corteTipo});

  @override
  Widget build(BuildContext context) {
    final label = switch (corteTipo) {
      2 => 'Configuracion quincenal',
      3 => 'Configuracion semanal',
      _ => 'Configuracion mensual',
    };

    return Row(
      children: [
        Expanded(child: Container(height: 1, color: SmxColors.blackAlpha(.08))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: SmxColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: .4,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: SmxColors.blackAlpha(.08))),
      ],
    );
  }
}

class _CutTypeSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _CutTypeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      (id: 1, label: 'Mensual', description: 'Dia fijo del mes'),
      (id: 2, label: 'Quincenal', description: 'Dia 15 o fin de mes'),
      (id: 3, label: 'Semanal', description: 'Lunes a viernes'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 620 ? 1 : 3;

        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: columns == 1 ? 4.4 : 2.25,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final selected = value == item.id;

            return Material(
              color: selected ? SmxColors.brandAccent : SmxColors.surfaceData,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onChanged(item.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? SmxColors.white
                              : SmxColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? SmxColors.white
                              : SmxColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MonthDaySelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _MonthDaySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _InfoBox(
          title: 'Corte mensual',
          text: 'Selecciona el dia de corte entre el 1 y el 28.',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 380 ? 4 : 7;

            return GridView.builder(
              itemCount: 28,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.55,
              ),
              itemBuilder: (context, index) {
                final day = index + 1;
                final selected = value == day;

                return Material(
                  color: selected
                      ? SmxColors.brandAccent
                      : SmxColors.surfaceData,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onChanged(day),
                    child: Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color: selected
                              ? SmxColors.white
                              : SmxColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _WeekSelector extends StatelessWidget {
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _WeekSelector({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _InfoBox(
          title: 'Corte semanal',
          text:
              'Se aplica siempre en la siguiente semana de registro del credito.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final day in values)
              ChoiceChip(
                label: Text(day),
                selected: value == day,
                onSelected: (_) => onChanged(day),
                selectedColor: SmxColors.brandAccent,
                labelStyle: TextStyle(
                  color: value == day ? SmxColors.white : SmxColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FortnightSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _FortnightSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _InfoBox(
          title: 'Corte quincenal',
          text: 'Elige si el corte cae el dia 15 o el ultimo dia del mes.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FortnightChip(
              label: 'Primera quincena',
              description: 'Dia 15',
              selected: value == 1,
              onSelected: () => onChanged(1),
            ),
            _FortnightChip(
              label: 'Segunda quincena',
              description: 'Ultimo dia del mes',
              selected: value == 2,
              onSelected: () => onChanged(2),
            ),
          ],
        ),
      ],
    );
  }
}

class _FortnightChip extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onSelected;

  const _FortnightChip({
    required this.label,
    required this.description,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Text(
            description,
            style: TextStyle(
              color: selected ? SmxColors.white : SmxColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: SmxColors.brandAccent,
      labelStyle: TextStyle(
        color: selected ? SmxColors.white : SmxColors.textDark,
        fontWeight: FontWeight.w800,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String text;

  const _InfoBox({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SmxColors.surfaceData,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: SmxColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: SmxColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SaveButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: SmxColors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF16A34A), Color(0xFF0284C7)],
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Text(
                label,
                style: const TextStyle(
                  color: SmxColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
