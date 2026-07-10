import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxSaldifyBackgrounds/invita_cliente_card_bg.dart';
import 'package:venture_saldify/smxSaldifyBackgrounds/operacion_bg_panel.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';
import 'package:venture_widgets/smxImagesCrud/smxImagesCrud.dart';
import 'package:venture_widgets/smxNumberField/smxNumberField.dart';
import 'package:venture_widgets/smxTextField/smxTextField.dart';

import 'smxSaldiFy_productos_controller.dart';

class SmxSaldiFyProductos extends StatelessWidget {
  const SmxSaldiFyProductos({super.key});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyProductosController>(
      controllerBuilder: (context) => SmxSaldiFyProductosController(
        alias: 'SMXSALDIFY_PRODUCTOS',
        data: SmxControllerSendData(context: context),
      ),
      builder: (context, controller) => _ProductosView(controller: controller),
    );
  }
}

class _ProductosView extends StatefulWidget {
  final SmxSaldiFyProductosController controller;

  const _ProductosView({required this.controller});

  @override
  State<_ProductosView> createState() => _ProductosViewState();
}

class _ProductosViewState extends State<_ProductosView> {
  bool _showForm = false;
  bool _savedSomething = false;
  int _formVersion = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final layout = SmxLayout.sizeFromWidth(MediaQuery.of(context).size.width);
    final pagePadding = layout.saldifyPagePadding;
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);

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
                      _Header(savedSomething: _savedSomething),
                      const SizedBox(height: 24),
                      _ListHeader(
                        showForm: _showForm,
                        onAddTap: () async {
                          if (!_showForm) {
                            await widget.controller.prepareNuevo();
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
                          key: ValueKey('producto_form_$_formVersion'),
                          controller: widget.controller,
                          onImageChanged: () {
                            final synced = widget.controller
                                .syncEditingImageToList();
                            setState(() {
                              _savedSomething = _savedSomething || synced;
                            });
                          },
                          onSaved: () => setState(() {
                            _savedSomething = true;
                            _showForm = false;
                          }),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _ProductosList(
                        controller: widget.controller,
                        onStatusChanged: () =>
                            setState(() => _savedSomething = true),
                        onEdit: (index) async {
                          await widget.controller.setProductoIndex(index);
                          if (!context.mounted) return;
                          _formVersion++;
                          setState(() => _showForm = true);
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
  final bool savedSomething;

  const _Header({required this.savedSomething});

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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catálogo de Productos',
                style: TextStyle(
                  color: SmxColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Gestiona los servicios que ofreces',
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

class _ListHeader extends StatelessWidget {
  final bool showForm;
  final VoidCallback onAddTap;

  const _ListHeader({required this.showForm, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Tus productos',
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
  final SmxSaldiFyProductosController controller;
  final VoidCallback onSaved;
  final VoidCallback onImageChanged;

  const _FormPanel({
    super.key,
    required this.controller,
    required this.onSaved,
    required this.onImageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEditing = controller.isEditing;

    return OperacionBgPanel(
      title: isEditing ? 'Editar producto' : 'Registrar producto',
      subtitle: 'Define el nombre y el precio base.',
      icon: Icons.inventory_2_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SmxTextField(
            field: 'SYSUSER41_PRODUCTO',
            controller: controller,
            textInputType: SmxTextInputType.mayusculas,
            label: 'Nombre del Producto',
            isValid: true,
          ),
          const SizedBox(height: 16),
          SmxNumberField(
            field: 'SYSUSER41_IMPORTE',
            controller: controller,
            label: 'Importe sugerido',
            decimales: 2,
            currency: true,
            isValid: true,
          ),
          if (isEditing) ...[
            const SizedBox(height: 18),
            _ProductoImagenPanel(
              controller: controller,
              onChanged: onImageChanged,
            ),
          ],
          const SizedBox(height: 22),
          _SaveButton(
            label: isEditing ? 'Actualizar producto' : 'Guardar producto',
            onPressed: () async {
              await controller.save();
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

class _ProductoImagenPanel extends StatelessWidget {
  final SmxSaldiFyProductosController controller;
  final VoidCallback onChanged;

  const _ProductoImagenPanel({
    required this.controller,
    required this.onChanged,
  });

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
            'Imagenes del producto',
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
              alias: SmxSaldiFyProductosController.ALIAS_IMAGES,
              controller: controller,
              copyToTemp: true,
              rstImages: controller.getRstImages(),
              tablaWrite: SmxSaldiFyProductosController.TABLE_IMAGES,
              onChanged: onChanged,
              columns: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductosList extends StatelessWidget {
  final SmxSaldiFyProductosController controller;
  final ValueChanged<int> onEdit;
  final VoidCallback onStatusChanged;

  const _ProductosList({
    required this.controller,
    required this.onEdit,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activos = controller.productosActivosIndexes;
    final archivados = controller.productosArchivadosIndexes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProductosSection(
          title: 'Tus productos',
          emptyText: 'No tienes productos activos.',
          indexes: activos,
          controller: controller,
          onEdit: onEdit,
          onToggleStatus: (index) => _toggleStatus(context, index),
        ),
        if (archivados.isNotEmpty) ...[
          const SizedBox(height: 22),
          _ProductosSection(
            title: 'Archivados',
            emptyText: 'No tienes productos archivados.',
            indexes: archivados,
            controller: controller,
            onEdit: onEdit,
            onToggleStatus: (index) => _toggleStatus(context, index),
          ),
        ],
      ],
    );
  }

  void _toggleStatus(BuildContext context, int index) {
    final status = controller.getStatusAt(index);
    final isArchiving = status == 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArchiving ? '¿Archivar producto?' : '¿Activar producto?'),
        content: Text(
          isArchiving
              ? 'El producto se marcará como archivado.'
              : 'El producto volverá a estar activo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.toggleStatus(index);
              if (controller.lastStatusOk) {
                onStatusChanged();
              }
            },
            child: Text(
              isArchiving ? 'Archivar' : 'Activar',
              style: TextStyle(color: isArchiving ? Colors.red : Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductosSection extends StatelessWidget {
  final String title;
  final String emptyText;
  final List<int> indexes;
  final SmxSaldiFyProductosController controller;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onToggleStatus;

  const _ProductosSection({
    required this.title,
    required this.emptyText,
    required this.indexes,
    required this.controller,
    required this.onEdit,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title == 'Archivados') ...[
          Text(
            title,
            style: const TextStyle(
              color: SmxColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (indexes.isEmpty)
          _EmptyProductosList(text: emptyText)
        else
          for (var position = 0; position < indexes.length; position++) ...[
            if (position > 0) const SizedBox(height: 10),
            _ProductoTile(
              nombre: controller.getProductoAt(indexes[position]),
              importe: controller.getImporteAt(indexes[position]),
              imageUrl: controller.getProductoImageUrlAt(indexes[position]),
              status: controller.getStatusAt(indexes[position]),
              onTap: () => onEdit(indexes[position]),
              onToggleStatus: () => onToggleStatus(indexes[position]),
            ),
          ],
      ],
    );
  }
}

class _EmptyProductosList extends StatelessWidget {
  final String text;

  const _EmptyProductosList({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.96),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          text,
          style: const TextStyle(
            color: SmxColors.textMuted,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ProductoTile extends StatelessWidget {
  final String nombre;
  final String importe;
  final String imageUrl;
  final int status;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;

  const _ProductoTile({
    required this.nombre,
    required this.importe,
    required this.imageUrl,
    required this.status,
    required this.onTap,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isArchived = status == 1;

    return Material(
      color: SmxColors.whiteAlpha(isArchived ? .70 : .95),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            const Positioned.fill(child: InvitaClienteCardBg()),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _ProductoThumb(imageUrl: imageUrl, isArchived: isArchived),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre.isEmpty ? 'Producto sin nombre' : nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isArchived
                                ? SmxColors.textMuted
                                : SmxColors.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            decoration: isArchived
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Precio base: $importe',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SmxColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleStatus,
                    icon: Icon(
                      isArchived
                          ? Icons.unarchive_rounded
                          : Icons.archive_outlined,
                      color: isArchived ? Colors.red : SmxColors.textMuted,
                      size: 22,
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

class _ProductoThumb extends StatelessWidget {
  final String imageUrl;
  final bool isArchived;

  const _ProductoThumb({required this.imageUrl, required this.isArchived});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isArchived
        ? SmxColors.dangerBackground
        : SmxColors.surfacePill;
    final iconColor = isArchived
        ? SmxColors.dangerForeground
        : const Color(0xFF0369A1);

    Widget fallback() {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.inventory_2_rounded, color: iconColor),
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

class _SaveButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SaveButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
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
