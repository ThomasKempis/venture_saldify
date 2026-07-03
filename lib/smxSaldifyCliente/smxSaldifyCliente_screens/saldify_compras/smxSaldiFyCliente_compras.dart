import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_screens/smxSaldify_backgrounds/operacion_bg_panel.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';
import 'package:venture_widgets/smxDatePicker/smxDatePicker.dart';
import 'package:venture_widgets/smxNumberField/smxNumberField.dart';
import 'package:venture_widgets/smxTextField/smxTextField.dart';

import '../../smxSaldifyCliente_dashboard/smxSaldiFyCliente_metricas/smxSaldiFyCliente_metricas_snapshot.dart';
import 'smxSaldiFyCliente_compras_controller.dart';

class SmxSaldiFyClienteCompras extends StatelessWidget {
  final String clientName;
  final int idSysuser11;
  final int relaSysuser10Anfitrion;
  final SmxSaldiFyClienteMetricasSnapshot? metricasIniciales;

  const SmxSaldiFyClienteCompras({
    super.key,
    required this.clientName,
    required this.idSysuser11,
    required this.relaSysuser10Anfitrion,
    this.metricasIniciales,
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClienteComprasController>(
      controllerBuilder: (context) => SmxSaldiFyClienteComprasController(
        alias: 'SMXSALDIFY_CLIENTE_COMPRAS',
        data: SmxControllerSendData(context: context),
        idSysuser11: idSysuser11,
        relaSysuser10Anfitrion: relaSysuser10Anfitrion,
        metricasIniciales: metricasIniciales,
      ),
      builder: (context, controller) =>
          _ComprasView(controller: controller, clientName: clientName),
    );
  }
}

class _ComprasView extends StatefulWidget {
  final SmxSaldiFyClienteComprasController controller;
  final String clientName;

  const _ComprasView({required this.controller, required this.clientName});

  @override
  State<_ComprasView> createState() => _ComprasViewState();
}

class _ComprasViewState extends State<_ComprasView> {
  bool _showForm = false;
  bool _savedSomething = false;
  int _formVersion = 0;
  double _totalComprasSesion = 0.0;

  @override
  Widget build(BuildContext context) {
    final layout = SmxLayout.sizeFromWidth(MediaQuery.of(context).size.width);
    final pagePadding = layout.saldifyPagePadding;
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);
    final credito = widget.controller.credito;
    final disponible = widget.controller.disponible;
    final saldo = widget.controller.saldo;
    final disponibleVisible = disponible - _totalComprasSesion;
    final saldoVisible = saldo + _totalComprasSesion;

    return Scaffold(
      backgroundColor: SmxColors.transparent,
      body: SizedBox.expand(
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
                      _Header(
                        title: widget.clientName,
                        savedSomething: _savedSomething,
                      ),
                      const SizedBox(height: 18),
                      _SummaryPanel(
                        credito: SmxRowSet.formatAmount(credito),
                        disponible: SmxRowSet.formatAmount(disponibleVisible),
                        saldo: SmxRowSet.formatAmount(saldoVisible),
                        totalCompras: SmxRowSet.formatAmount(
                          _totalComprasSesion,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _ListHeader(
                        showForm: _showForm,
                        onAddTap: () async {
                          if (!_showForm) {
                            await widget.controller.prepareCompraNueva();
                            _formVersion++;
                          }

                          if (!context.mounted) return;

                          setState(() {
                            _showForm = !_showForm;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_showForm) ...[
                        _FormPanel(
                          key: ValueKey('cliente_compra_form_$_formVersion'),
                          controller: widget.controller,
                          disponible: disponibleVisible,
                          onSaved: () {
                            setState(() {
                              _savedSomething = true;
                              _totalComprasSesion +=
                                  widget.controller.lastSavedImporte;
                              _showForm = false;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                      ],
                      _ComprasList(controller: widget.controller),
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
  final bool savedSomething;

  const _Header({required this.title, required this.savedSomething});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(savedSomething),
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
                'Compras',
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

class _SummaryPanel extends StatelessWidget {
  final String credito;
  final String disponible;
  final String saldo;
  final String totalCompras;

  const _SummaryPanel({
    required this.credito,
    required this.disponible,
    required this.saldo,
    required this.totalCompras,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.12),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            final columns = constraints.maxWidth < 560 ? 2 : 4;
            final itemWidth =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _SummaryItem(label: 'Credito', value: credito),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _SummaryItem(label: 'Disponible', value: disponible),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _SummaryItem(label: 'Saldo', value: saldo),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _SummaryItem(
                    label: 'Total compras',
                    value: totalCompras,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: SmxColors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value.isEmpty ? '0' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: SmxColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  final bool showForm;
  final Future<void> Function() onAddTap;

  const _ListHeader({required this.showForm, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Compras registradas',
            style: TextStyle(
              color: SmxColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Material(
          color: SmxColors.brandAccent,
          borderRadius: BorderRadius.circular(999),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onAddTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Text(
                showForm ? 'Cerrar' : '+ Agregar',
                style: const TextStyle(
                  color: SmxColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormPanel extends StatelessWidget {
  final SmxSaldiFyClienteComprasController controller;
  final double disponible;
  final VoidCallback onSaved;

  const _FormPanel({
    super.key,
    required this.controller,
    required this.disponible,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return OperacionBgPanel(
      title: 'Solicitar compra',
      subtitle: 'Captura la compra para enviarla a tu anfitrion.',
      icon: Icons.shopping_cart_checkout_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SmxTextField(
            field: 'SYSUSER40_CONCEPTO',
            controller: controller,
            label: 'Concepto',
            isValid: true,
          ),
          const SizedBox(height: 18),
          _ResponsiveFields(
            children: [
              SmxNumberField(
                field: 'SYSUSER40_IMPORTE',
                controller: controller,
                label: 'Importe',
                decimales: 2,
                currency: true,
                isValid: true,
              ),
              SmxDatePicker(
                field: 'SYSUSER40_FECHA',
                controller: controller,
                label: 'Fecha',
                withEmpty: false,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _SaveButton(
            label: 'Guardar compra',
            onPressed: () async {
              await controller.save(disponible: disponible);
              if (context.mounted && controller.lastSaveOk) {
                onSaved();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ComprasList extends StatelessWidget {
  final SmxSaldiFyClienteComprasController controller;

  const _ComprasList({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.rowCount == 0) {
      return Material(
        color: SmxColors.whiteAlpha(.96),
        borderRadius: BorderRadius.circular(18),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            'Sin compras registradas.',
            style: TextStyle(
              color: SmxColors.textMuted,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < controller.rowCount; index++) ...[
          if (index > 0) const SizedBox(height: 10),
          _CompraTile(
            concepto: controller.getConceptoAt(index),
            fecha: controller.getFechaAt(index),
            importe: controller.getImporteAt(index),
          ),
        ],
      ],
    );
  }
}

class _CompraTile extends StatelessWidget {
  final String concepto;
  final String fecha;
  final String importe;

  const _CompraTile({
    required this.concepto,
    required this.fecha,
    required this.importe,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.96),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SmxColors.surfacePill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_cart_checkout_rounded,
                color: Color(0xFF166534),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    concepto.isEmpty ? 'Compra' : concepto,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SmxColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    fecha,
                    style: const TextStyle(
                      color: SmxColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              importe,
              style: const TextStyle(
                color: SmxColors.textDark,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveFields({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 18),
                children[index],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(width: 14),
              Expanded(child: children[index]),
            ],
          ],
        );
      },
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
