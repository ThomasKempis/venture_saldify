import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';
import 'package:venture_widgets/smxDatePicker/smxDatePicker.dart';
import 'package:venture_widgets/smxTextField/smxTextField.dart';

import 'package:venture_saldify/smxLayout/smxBackgrounds/cliente_bg_datos.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/cliente_bg_gmail.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/cliente_bg_inicio.dart';
import 'smxSaldiFy_cliente_controller.dart';

class SmxSaldiFyCliente extends StatelessWidget {
  final int relaSysuser10Cliente;

  const SmxSaldiFyCliente({super.key, this.relaSysuser10Cliente = -1});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClienteController>(
      controllerBuilder: (context) => SmxSaldiFyClienteController(
        alias: 'SMXSALDIFY_CLIENTE',
        data: SmxControllerSendData(context: context),
        relaSysuser10Cliente: relaSysuser10Cliente,
      ),
      builder: (context, controller) => _ClienteView(controller: controller),
    );
  }
}

class _ClienteView extends StatefulWidget {
  final SmxSaldiFyClienteController controller;

  const _ClienteView({required this.controller});

  @override
  State<_ClienteView> createState() => _ClienteViewState();
}

class _ClienteViewState extends State<_ClienteView> {
  late final TextEditingController _correoController;
  bool _didAutoResolve = false;

  SmxSaldiFyClienteController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _correoController = TextEditingController(text: controller.correoBusqueda);
    _correoController.addListener(_normalizeCorreo);
  }

  @override
  void dispose() {
    _correoController.removeListener(_normalizeCorreo);
    _correoController.dispose();
    super.dispose();
  }

  void _normalizeCorreo() {
    final lower = _correoController.text.toLowerCase();
    if (_correoController.text == lower) return;

    _correoController.value = _correoController.value.copyWith(
      text: lower,
      selection: TextSelection.collapsed(offset: lower.length),
      composing: TextRange.empty,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller.isUpdate && !_didAutoResolve) {
      _didAutoResolve = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await controller.resolveCorreo(_correoController.text);
        if (!mounted) return;

        _correoController.text = controller.correoBusqueda;
        setState(() {});
      });
    }

    final layout = SmxLayout.sizeFromWidth(MediaQuery.of(context).size.width);
    final pagePadding = layout.pagePadding;
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
                constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
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
                      _Header(controller: controller),
                      const SizedBox(height: 22),
                      if (!controller.isCorreoResolved)
                        _CorreoPanel(
                          correoController: _correoController,
                          enabled: !controller.isUpdate,
                          onResolve: () async {
                            if (controller.isUpdate) return;
                            await controller.resolveCorreo(
                              _correoController.text,
                            );
                            if (!mounted) return;

                            _correoController.text = controller.correoBusqueda;
                            setState(() {});
                          },
                        )
                      else
                        _FormPanel(
                          key: ValueKey(controller.resolveVersion),
                          controller: controller,
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
  final SmxSaldiFyClienteController controller;

  const _Header({required this.controller});

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
                controller.isUpdate ? 'Editar cliente' : 'Nuevo cliente',
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
                controller.isUpdate ? 'Actualizar datos' : 'Alta de cliente',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
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

class _CorreoPanel extends StatelessWidget {
  final TextEditingController correoController;
  final bool enabled;
  final VoidCallback onResolve;

  const _CorreoPanel({
    required this.correoController,
    required this.enabled,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    return ClienteBgGmail(
      enabled: enabled,
      onContinue: onResolve,
      field: _CorreoSearchField(
        correoController: correoController,
        enabled: enabled,
        onSubmitted: onResolve,
      ),
    );
  }
}

class _CorreoSearchField extends StatelessWidget {
  final TextEditingController correoController;
  final bool enabled;
  final VoidCallback onSubmitted;

  const _CorreoSearchField({
    required this.correoController,
    required this.enabled,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: correoController,
      enabled: enabled,
      onSubmitted: (_) => onSubmitted(),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: 'Usuario de Gmail',
        hintText: 'nombre.apellido',
        helperText: 'Solo lo que va antes de @gmail.com.',
        filled: true,
        fillColor: SmxColors.whiteAlpha(.92),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: SmxColors.blackAlpha(.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF58D69B), width: 1.6),
        ),
      ),
      style: const TextStyle(
        color: SmxColors.textDark,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  final SmxSaldiFyClienteController controller;

  const _FormPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final readOnly = controller.isDatosReadOnly;

    return ClienteBgDatos(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SmxTextField(
            key: ValueKey('nombres_${controller.resolveVersion}'),
            field: 'SYSUSER10_NOMBRES',
            controller: controller,
            label: 'Nombres',
            textInputType: SmxTextInputType.mayusculas,
            isValid: true,
            readOnly: readOnly,
          ),
          const SizedBox(height: 18),
          SmxTextField(
            key: ValueKey('apellidos_${controller.resolveVersion}'),
            field: 'SYSUSER10_APELLIDOS',
            controller: controller,
            label: 'Apellidos',
            textInputType: SmxTextInputType.mayusculas,
            isValid: true,
            readOnly: readOnly,
          ),
          const SizedBox(height: 18),
          _ResponsiveFields(
            children: [
              SmxTextField(
                key: ValueKey('telefono_${controller.resolveVersion}'),
                field: 'SYSUSER10_TELEFONO',
                controller: controller,
                label: 'Telefono',
                textInputType: SmxTextInputType.phone,
                isValid: true,
                readOnly: readOnly,
              ),
              _CorreoResolvedDisplay(
                key: ValueKey('correo_${controller.resolveVersion}'),
                value: controller.correoResolved,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SmxDatePicker(
            key: ValueKey('fecha_${controller.resolveVersion}'),
            field: 'SYSUSER10_FECHA',
            controller: controller,
            label: 'Fecha',
            withEmpty: false,
            readOnly: readOnly,
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerRight,
            child: ClienteBgActionButton(
              label: controller.saveButtonLabel,
              onPressed: () async {
                await controller.save();
                if (context.mounted && controller.lastSaveOk) {
                  Navigator.of(context).pop(true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CorreoResolvedDisplay extends StatelessWidget {
  final String value;

  const _CorreoResolvedDisplay({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Correo',
        filled: true,
        fillColor: SmxColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: SmxColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w800,
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

extension _ClienteLayoutValues on SmxLayoutSize {
  double get maxContentWidth => switch (this) {
    SmxLayoutSize.mobile => 460,
    SmxLayoutSize.tablet => 760,
    SmxLayoutSize.desktop => 820,
  };

  EdgeInsets get pagePadding => switch (this) {
    SmxLayoutSize.mobile => const EdgeInsets.fromLTRB(20, 20, 20, 28),
    SmxLayoutSize.tablet => const EdgeInsets.fromLTRB(28, 28, 28, 34),
    SmxLayoutSize.desktop => const EdgeInsets.fromLTRB(36, 34, 36, 40),
  };
}
