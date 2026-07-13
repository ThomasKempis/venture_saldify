import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/invita_cliente_card_bg.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/operacion_bg_panel.dart';
import 'package:venture_widgets/smxDatePicker/smxDatePicker.dart';
import 'package:venture_widgets/smxImagesCrud/smxImagesCrud.dart';
import 'package:venture_widgets/smxNumberField/smxNumberField.dart';
import 'package:venture_widgets/smxTextField/smxTextField.dart';

import 'smxComprasManualControllerContract.dart';
import 'smxComprasManualModels.dart';

class SmxComprasManual extends StatefulWidget {
  final SmxComprasManualControllerContract controller;
  final SmxComprasManualViewModel model;

  const SmxComprasManual({
    super.key,
    required this.controller,
    required this.model,
  });

  @override
  State<SmxComprasManual> createState() => _SmxComprasManualState();
}

class _SmxComprasManualState extends State<SmxComprasManual> {
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
    final credito = widget.model.credito;
    final disponible = widget.model.disponible;
    final saldo = widget.model.saldo;
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
                        title: widget.model.clientName,
                        sectionLabel: widget.model.headerLabel,
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
                          key: ValueKey(
                            '${widget.model.keyPrefix}_form_$_formVersion',
                          ),
                          controller: widget.controller,
                          disponible: disponibleVisible,
                          formTitle: widget.model.formTitle,
                          formSubtitle: widget.model.formSubtitle,
                          onImageChanged: () {
                            final synced = widget.controller
                                .syncEditingImageToList();
                            setState(() {
                              _savedSomething = _savedSomething || synced;
                            });
                          },
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
                      _ComprasList(
                        controller: widget.controller,
                        receivedEmptyText: widget.model.receivedEmptyText,
                        onTap: (index) async {
                          final status = widget.controller.getStatusAt(index);
                          if (status == 0) {
                            await widget.controller.setCompraIndex(index);
                          } else {
                            await widget.controller.setCompraImagesIndex(index);
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
                            _totalComprasSesion -= importe;
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

class _Header extends StatelessWidget {
  final String title;
  final String sectionLabel;
  final bool savedSomething;

  const _Header({
    required this.title,
    required this.sectionLabel,
    required this.savedSomething,
  });

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
              Text(
                sectionLabel,
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
            'Compras pendientes',
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
  final SmxComprasManualControllerContract controller;
  final double disponible;
  final String formTitle;
  final String formSubtitle;
  final VoidCallback onSaved;
  final VoidCallback onImageChanged;

  const _FormPanel({
    super.key,
    required this.controller,
    required this.disponible,
    required this.formTitle,
    required this.formSubtitle,
    required this.onSaved,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canEditData = controller.canEditCompraData;
    final isSoloImagenes = controller.isSoloImagenes;
    final isPersistida = controller.isCompraPersistida;

    return OperacionBgPanel(
      title: isSoloImagenes ? 'Fotos de compra' : formTitle,
      subtitle: isSoloImagenes
          ? 'Actualiza las imágenes de soporte.'
          : formSubtitle,
      icon: Icons.shopping_cart_checkout_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canEditData) ...[
            SmxTextField(
              field: 'SYSUSER40_CONCEPTO',
              controller: controller,
              textInputType: SmxTextInputType.mayusculas,
              label: 'Producto',
              isValid: true,
            ),
            const SizedBox(height: 18),
            _ResponsiveFields(
              children: [
                SmxNumberField(
                  field: 'SYSUSER40_CANTIDAD',
                  controller: controller,
                  label: 'Cantidad',
                  decimales: 0,
                  isValid: true,
                ),
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
                  label: 'Fecha de entrega',
                  withEmpty: false,
                ),
              ],
            ),
          ] else ...[
            Text(
              'Esta compra solo permite editar imágenes.',
              style: TextStyle(
                color: SmxColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (isPersistida) ...[
            const SizedBox(height: 18),
            _CompraImagenPanel(
              controller: controller,
              onChanged: onImageChanged,
            ),
          ],
          if (canEditData) ...[
            const SizedBox(height: 22),
            _SaveButton(
              label: controller.isCompraNueva
                  ? 'Guardar compra'
                  : 'Actualizar compra',
              onPressed: () async {
                await controller.save(disponible: disponible);
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

class _CompraImagenPanel extends StatelessWidget {
  final SmxComprasManualControllerContract controller;
  final VoidCallback onChanged;

  const _CompraImagenPanel({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.56),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SmxColors.blackAlpha(.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Imagen de la compra',
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
              key: ValueKey('compra_images_${controller.currentCompraId}'),
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

class _ComprasList extends StatelessWidget {
  final SmxComprasManualControllerContract controller;
  final String receivedEmptyText;
  final ValueChanged<int> onTap;
  final ValueChanged<double> onDeleted;

  const _ComprasList({
    required this.controller,
    required this.receivedEmptyText,
    required this.onTap,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final pendientes = controller.comprasPendientesIndexes;
    final recibidas = controller.comprasRecibidasIndexes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ComprasSection(
          indexes: pendientes,
          emptyText: 'No tienes compras pendientes.',
          controller: controller,
          onTap: onTap,
          onDeleted: onDeleted,
        ),
        if (recibidas.isNotEmpty) ...[
          const SizedBox(height: 22),
          const Text(
            'Compras recibidas',
            style: TextStyle(
              color: SmxColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          _ComprasSection(
            indexes: recibidas,
            emptyText: receivedEmptyText,
            controller: controller,
            onTap: onTap,
            onDeleted: onDeleted,
          ),
        ],
      ],
    );
  }
}

class _ComprasSection extends StatelessWidget {
  final List<int> indexes;
  final String emptyText;
  final SmxComprasManualControllerContract controller;
  final ValueChanged<int> onTap;
  final ValueChanged<double> onDeleted;

  const _ComprasSection({
    required this.indexes,
    required this.emptyText,
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
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            emptyText,
            style: const TextStyle(
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
          _CompraDismissible(
            controller: controller,
            index: indexes[position],
            onDeleted: onDeleted,
            child: _CompraTile(
              concepto: controller.getProductoAt(indexes[position]),
              cantidad: controller.getCantidadAt(indexes[position]),
              fecha: controller.getFechaAt(indexes[position]),
              importe: controller.getImporteAt(indexes[position]),
              total: controller.getTotalAt(indexes[position]),
              status: controller.getStatusAt(indexes[position]),
              statusLabel: controller.getStatusLabelAt(indexes[position]),
              imageUrl: controller.getCompraImageUrlAt(indexes[position]),
              editable: controller.getStatusAt(indexes[position]) == 0,
              onTap: () => onTap(indexes[position]),
            ),
          ),
        ],
      ],
    );
  }
}

class _CompraDismissible extends StatelessWidget {
  final SmxComprasManualControllerContract controller;
  final int index;
  final Widget child;
  final ValueChanged<double> onDeleted;

  const _CompraDismissible({
    required this.controller,
    required this.index,
    required this.child,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.getStatusAt(index) != 0) return child;

    return Slidable(
      key: ValueKey('compra_${controller.getCompraIdAt(index)}'),
      groupTag: 'compras_registradas',
      endActionPane: ActionPane(
        extentRatio: .24,
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Borrar compra?'),
                  content: const Text('Esta compra será eliminada.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Borrar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (shouldDelete != true) return;

              final importe = controller.getImporteValueAt(index);
              final deleted = await controller.deleteCompraAt(index);
              if (deleted) onDeleted(importe);
            },
            autoClose: true,
            backgroundColor: const Color(0xFFE95656),
            foregroundColor: SmxColors.white,
            icon: Icons.delete_outline_rounded,
            label: 'Eliminar',
            borderRadius: BorderRadius.circular(18),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CompraTile extends StatelessWidget {
  final String concepto;
  final String cantidad;
  final String fecha;
  final String importe;
  final String total;
  final int status;
  final String statusLabel;
  final String imageUrl;
  final bool editable;
  final VoidCallback onTap;

  const _CompraTile({
    required this.concepto,
    required this.cantidad,
    required this.fecha,
    required this.importe,
    required this.total,
    required this.status,
    required this.statusLabel,
    required this.imageUrl,
    required this.editable,
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
                  _CompraThumb(imageUrl: imageUrl),
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '$cantidad × $importe · $fecha',
                              style: const TextStyle(
                                color: SmxColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            _CompraStatusChip(
                              status: status,
                              label: statusLabel,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        total,
                        style: const TextStyle(
                          color: SmxColors.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        editable
                            ? Icons.edit_rounded
                            : Icons.photo_camera_rounded,
                        color: SmxColors.textMuted,
                        size: 18,
                      ),
                    ],
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

class _CompraStatusChip extends StatelessWidget {
  final int status;
  final String label;

  const _CompraStatusChip({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      0 => (const Color(0xFFFFE8A3), const Color(0xFF725100)),
      1 => (const Color(0xFFFFD6B0), const Color(0xFF8A3F00)),
      2 => (const Color(0xFFCFF3DF), const Color(0xFF11653A)),
      _ => (const Color(0xFFE5E7EB), const Color(0xFF4B5563)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CompraThumb extends StatelessWidget {
  final String imageUrl;

  const _CompraThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    Widget fallback() {
      return Container(
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
      );
    }

    if (imageUrl.trim().isEmpty) return fallback();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback(),
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
