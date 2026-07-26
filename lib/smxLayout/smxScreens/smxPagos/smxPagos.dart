import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smx_decision_dialog.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/invita_cliente_card_bg.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/operacion_bg_panel.dart';
import 'package:venture_widgets/smxDatePicker/smxDatePicker.dart';
import 'package:venture_widgets/smxImagesCrud/smxImagesCrud.dart';
import 'package:venture_widgets/smxNumberField/smxNumberField.dart';
import 'package:venture_widgets/smxTextField/smxTextField.dart';
import 'smxPagosControllerContract.dart';
import 'smxPagosModels.dart';

class SmxPagos extends StatefulWidget {
  final SmxPagosControllerContract controller;
  final SmxPagosViewModel model;

  const SmxPagos({super.key, required this.controller, required this.model});

  @override
  State<SmxPagos> createState() => _SmxPagosState();
}

class _SmxPagosState extends State<SmxPagos> {
  bool _showForm = false;
  bool _savedSomething = false;
  int _formVersion = 0;
  double _totalPagosSesion = 0.0;

  @override
  Widget build(BuildContext context) {
    final layout = SmxLayout.sizeFromWidth(MediaQuery.of(context).size.width);
    final pagePadding = layout.saldifyPagePadding;
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);
    final credito = widget.model.credito;
    final disponible = widget.model.disponible;
    final saldo = widget.model.saldo;
    final disponibleVisible = disponible + _totalPagosSesion;
    final saldoVisible = saldo - _totalPagosSesion;

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
                      SmxSaldifyScreenHeader(
                        title: widget.model.clientName,
                        sectionLabel: 'Pagos',
                        onBackPressed: () =>
                            Navigator.of(context).pop(_savedSomething),
                      ),
                      const SizedBox(height: 18),
                      _SummaryPanel(
                        credito: SmxRowSet.formatAmount(credito),
                        disponible: SmxRowSet.formatAmount(disponibleVisible),
                        saldo: SmxRowSet.formatAmount(saldoVisible),
                        totalPagos: SmxRowSet.formatAmount(_totalPagosSesion),
                      ),
                      const SizedBox(height: 18),
                      _ListHeader(
                        showForm: _showForm,
                        onAddTap: () async {
                          if (!_showForm) {
                            await widget.controller.preparePagoNuevo();
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
                          key: ValueKey(
                            '${widget.model.keyPrefix}_form_$_formVersion',
                          ),
                          controller: widget.controller,
                          saldo: saldoVisible,
                          subtitle: widget.model.formSubtitle,
                          onImageChanged: () {
                            final synced = widget.controller
                                .syncEditingImageToList();
                            setState(
                              () => _savedSomething = _savedSomething || synced,
                            );
                          },
                          onSaved: () {
                            setState(() {
                              _savedSomething = true;
                              _totalPagosSesion +=
                                  widget.controller.lastSavedImporte;
                              _showForm = false;
                            });
                          },
                        ),
                        const SizedBox(height: 14),
                      ],
                      _PagosList(
                        controller: widget.controller,
                        onTap: (index) async {
                          if (widget.controller.getStatusAt(index) == 0) {
                            await widget.controller.setPagoIndex(index);
                          } else {
                            await widget.controller.setPagoImagesIndex(index);
                          }
                          if (!context.mounted) return;
                          setState(() {
                            _formVersion++;
                            _showForm = true;
                          });
                        },
                        onDeleted: (importe) {
                          setState(() {
                            _savedSomething = true;
                            _totalPagosSesion -= importe;
                          });
                        },
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

class _SummaryPanel extends StatelessWidget {
  final String credito;
  final String disponible;
  final String saldo;
  final String totalPagos;

  const _SummaryPanel({
    required this.credito,
    required this.disponible,
    required this.saldo,
    required this.totalPagos,
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
                  child: _SummaryItem(label: 'Total pagos', value: totalPagos),
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
            'Pagos pendientes',
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
  final SmxPagosControllerContract controller;
  final double saldo;
  final String subtitle;
  final VoidCallback onSaved;
  final VoidCallback onImageChanged;

  const _FormPanel({
    super.key,
    required this.controller,
    required this.saldo,
    required this.subtitle,
    required this.onSaved,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canEditData = controller.canEditPagoData;
    final isSoloImagenes = controller.isSoloImagenes;
    return OperacionBgPanel(
      title: isSoloImagenes ? 'Comprobante de pago' : 'Registrar pago',
      subtitle: isSoloImagenes
          ? 'Actualiza las imágenes del comprobante.'
          : subtitle,
      icon: Icons.payments_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canEditData) ...[
            SmxTextField(
              field: 'SYSUSER50_REFERENCIA',
              controller: controller,
              label: 'Referencia',
              textInputType: SmxTextInputType.mayusculas,
              isValid: true,
            ),
            const SizedBox(height: 18),
            _ResponsiveFields(
              children: [
                SmxNumberField(
                  field: 'SYSUSER50_IMPORTE',
                  controller: controller,
                  label: 'Importe',
                  decimales: 2,
                  currency: true,
                  isValid: true,
                ),
                SmxDatePicker(
                  field: 'SYSUSER50_FECHA',
                  controller: controller,
                  label: 'Fecha',
                  withEmpty: false,
                ),
              ],
            ),
          ] else
            const Text(
              'Este pago solo permite editar imágenes.',
              style: TextStyle(
                color: SmxColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          if (controller.isPagoPersistido) ...[
            const SizedBox(height: 18),
            _PagoImagenPanel(controller: controller, onChanged: onImageChanged),
          ],
          if (canEditData) ...[
            const SizedBox(height: 22),
            _SaveButton(
              label: controller.isPagoNuevo
                  ? 'Guardar pago'
                  : 'Actualizar pago',
              onPressed: () async {
                await controller.save(saldo: saldo);
                if (context.mounted && controller.lastSaveOk) {
                  onSaved();
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _PagoImagenPanel extends StatelessWidget {
  final SmxPagosControllerContract controller;
  final VoidCallback onChanged;
  const _PagoImagenPanel({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.56),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SmxColors.blackAlpha(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Comprobante del pago',
            style: TextStyle(
              color: SmxColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 132,
            child: SmxImagesCrud(
              key: ValueKey('pago_images_${controller.currentPagoId}'),
              alias: controller.imagesAlias,
              controller: controller,
              copyToTemp: true,
              rstImages: controller.getRstImages(),
              tablaWrite: controller.imagesTable,
              onChanged: onChanged,
              columns: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PagosList extends StatelessWidget {
  final SmxPagosControllerContract controller;
  final ValueChanged<int> onTap;
  final ValueChanged<double> onDeleted;

  const _PagosList({
    required this.controller,
    required this.onTap,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final pendientes = controller.pagosPendientesIndexes;
    final confirmados = controller.pagosConfirmadosIndexes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PagosSection(
          indexes: pendientes,
          controller: controller,
          onTap: onTap,
          onDeleted: onDeleted,
        ),
        if (confirmados.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text(
            'Pagos confirmados',
            style: TextStyle(
              color: SmxColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _PagosSection(
            indexes: confirmados,
            controller: controller,
            onTap: onTap,
            onDeleted: onDeleted,
          ),
        ],
      ],
    );
  }
}

class _PagosSection extends StatelessWidget {
  final List<int> indexes;
  final SmxPagosControllerContract controller;
  final ValueChanged<int> onTap;
  final ValueChanged<double> onDeleted;
  const _PagosSection({
    required this.indexes,
    required this.controller,
    required this.onTap,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (indexes.isEmpty) {
      return Material(
        color: SmxColors.whiteAlpha(.96),
        borderRadius: BorderRadius.circular(18),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            'No tienes pagos pendientes.',
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
        for (var position = 0; position < indexes.length; position++) ...[
          if (position > 0) const SizedBox(height: 10),
          _PagoSlidable(
            controller: controller,
            index: indexes[position],
            onDeleted: onDeleted,
            child: _PagoTile(
              referencia: controller.getReferenciaAt(indexes[position]),
              fecha: controller.getFechaAt(indexes[position]),
              importe: controller.getImporteAt(indexes[position]),
              status: controller.getStatusAt(indexes[position]),
              statusLabel: controller.getStatusLabelAt(indexes[position]),
              imageUrl: controller.getPagoImageUrlAt(indexes[position]),
              onTap: () => onTap(indexes[position]),
            ),
          ),
        ],
      ],
    );
  }
}

class _PagoSlidable extends StatelessWidget {
  final SmxPagosControllerContract controller;
  final int index;
  final Widget child;
  final ValueChanged<double> onDeleted;
  const _PagoSlidable({
    required this.controller,
    required this.index,
    required this.child,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.getStatusAt(index) != 0) return child;
    return Slidable(
      key: ValueKey('pago_${controller.getPagoIdAt(index)}'),
      groupTag: 'pagos',
      endActionPane: ActionPane(
        extentRatio: .24,
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              final confirmed = await showSmxDecisionDialog(
                context,
                title: 'Borrar pago',
                message: 'Este pago sera eliminado.',
                acceptText: 'Borrar',
                variant: SmxDecisionVariant.danger,
              );
              if (!confirmed) return;
              final importe = controller.getImporteValueAt(index);
              if (await controller.deletePagoAt(index)) onDeleted(importe);
            },
            autoClose: true,
            backgroundColor: const Color(0xFFE95656),
            foregroundColor: SmxColors.white,
            icon: Icons.delete_outline_rounded,
            label: 'Eliminar',
            borderRadius: BorderRadius.circular(18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PagoTile extends StatelessWidget {
  final String referencia;
  final String fecha;
  final String importe;
  final int status;
  final String statusLabel;
  final String imageUrl;
  final VoidCallback onTap;

  const _PagoTile({
    required this.referencia,
    required this.fecha,
    required this.importe,
    required this.status,
    required this.statusLabel,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: SmxColors.whiteAlpha(.96),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            const Positioned.fill(child: InvitaClienteCardBg()),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _PagoThumb(imageUrl: imageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          referencia.isEmpty ? 'Pago' : referencia,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SmxColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              fecha,
                              style: const TextStyle(
                                color: SmxColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            _PagoStatusChip(status: status, label: statusLabel),
                          ],
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
          ],
        ),
      ),
    );
  }
}

class _PagoStatusChip extends StatelessWidget {
  final int status;
  final String label;
  const _PagoStatusChip({required this.status, required this.label});
  @override
  Widget build(BuildContext context) {
    final colors = status == 0
        ? (const Color(0xFFFFE8A3), const Color(0xFF725100))
        : (const Color(0xFFCFF3DF), const Color(0xFF11653A));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.$2,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PagoThumb extends StatelessWidget {
  final String imageUrl;
  const _PagoThumb({required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    Widget fallback() => Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: SmxColors.surfacePill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.payments_rounded, color: Color(0xFF166534)),
    );
    if (imageUrl.trim().isEmpty) return fallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
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
