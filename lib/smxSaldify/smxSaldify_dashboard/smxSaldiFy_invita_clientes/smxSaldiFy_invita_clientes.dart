import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smx_message_dialog.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxApis/smxDepth.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/smx_saldify_sheet_bg.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/saldify_circles_background.dart';

import 'smxSaldiFy_invita_clientes_models.dart';
import 'smxSaldiFy_invita_service.dart';

class SmxSaldiFyInvitaClientes extends StatelessWidget {
  final String uuidAnfitrion;
  final String anfitrionNombre;

  const SmxSaldiFyInvitaClientes({
    super.key,
    required this.uuidAnfitrion,
    required this.anfitrionNombre,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: SmxColors.whiteAlpha(.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: SmxColors.blackAlpha(.22),
                blurRadius: 34,
                offset: const Offset(0, 16),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Material(
                      color: SmxColors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () => _showInvitaClientesSheet(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: SmxColors.surfaceQr,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: SmxColors.white,
                              width: 8,
                            ),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            color: SmxColors.iconDark,
                            size: 70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invita clientes',
                            style: TextStyle(
                              color: SmxColors.textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Toca el QR para mostrar tu invitacion abierta o copiar un link restringido a Gmail.',
                            style: TextStyle(
                              color: SmxColors.textMuted,
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showInvitaClientesSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => _InvitaClientesSheet(
        uuidAnfitrion: uuidAnfitrion,
        anfitrionNombre: anfitrionNombre,
      ),
    );
  }
}

class _InvitaClientesSheet extends StatefulWidget {
  final String uuidAnfitrion;
  final String anfitrionNombre;

  const _InvitaClientesSheet({
    required this.uuidAnfitrion,
    required this.anfitrionNombre,
  });

  @override
  State<_InvitaClientesSheet> createState() => _InvitaClientesSheetState();
}

class _InvitaClientesSheetState extends State<_InvitaClientesSheet> {
  final TextEditingController _correoController = TextEditingController();
  SmxSaldiFyInvitacionGenerada? _invitacionAbierta;
  bool _loadingQr = true;
  bool _loadingCorreo = false;
  String _mensaje = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generarInvitacionAbierta();
    });
  }

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmxSaldifySheetBackground(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          22,
          20,
          22,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.qr_code_2_rounded,
                  color: SmxColors.brandPrimary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.anfitrionNombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SmxColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _SectionDivider(label: 'Si esta presente puede leer el QR'),
            const SizedBox(height: 14),
            _QrInvitePanel(
              invitacion: _invitacionAbierta,
              loading: _loadingQr,
              onCopy: _copyInvitacionAbierta,
            ),
            const SizedBox(height: 18),
            const _SectionDivider(label: 'Puede invitar por correo Gmail'),
            const SizedBox(height: 14),
            _GmailInviteRow(
              controller: _correoController,
              loading: _loadingCorreo,
              onCopy: _copyInvitacionCorreo,
            ),
            const SizedBox(height: 18),
            const _SectionDivider(label: 'Mensaje'),
            const SizedBox(height: 10),
            _InviteMessage(mensaje: _mensaje),
          ],
        ),
      ),
    );
  }

  Future<void> _generarInvitacionAbierta() async {
    if (!mounted) return;
    setState(() => _loadingQr = true);

    SmxSaldiFyInvitacionGenerada? invitacion;

    invitacion = await SmxSaldifyInvitaService.crearInvitacion(
      controller: SmxConstants.controllerMain,
      parametros: SmxSaldifyInvitacionParametros.anfitrionAnonimo(
        uuidAnfitrion: widget.uuidAnfitrion,
      ),
    );

    if (!mounted) return;

    final error = SmxConstants.controllerMain.jsonSend.getError();
    if (error != null) {
      if (!mounted) return;
      showSmxSystemErrorDialog(context, message: error);
      setState(() => _loadingQr = false);
      return;
    }

    setState(() {
      _invitacionAbierta = invitacion;
      _loadingQr = false;
    });
  }

  Future<void> _copyInvitacionAbierta() async {
    final invitacion = _invitacionAbierta;
    if (invitacion == null) return;

    await _copyLink(invitacion.link, 'Se copio el link anonimo');
  }

  Future<void> _copyInvitacionCorreo() async {
    final correoUsuario = _correoController.text.trim().toLowerCase();
    final correo = '$correoUsuario@gmail.com';

    if (correoUsuario.isEmpty) {
      setState(() => _mensaje = 'Ingrese un correo Gmail.');
      return;
    }

    if (correoUsuario.contains('@')) {
      setState(() => _mensaje = 'Ingrese solo el nombre, sin @gmail.com.');
      return;
    }

    if (!RegExp(r'^[a-z0-9._%+-]+$').hasMatch(correoUsuario)) {
      setState(() => _mensaje = 'Ingrese un correo Gmail valido.');
      return;
    }

    setState(() => _loadingCorreo = true);

    SmxSaldiFyInvitacionGenerada? invitacion;

    invitacion = await SmxSaldifyInvitaService.crearInvitacion(
      controller: SmxConstants.controllerMain,
      parametros: SmxSaldifyInvitacionParametros.invitadoCorreo(
        uuidAnfitrion: widget.uuidAnfitrion,
        correoInvitado: correo,
      ),
    );

    if (!mounted) return;

    setState(() => _loadingCorreo = false);

    final error = SmxConstants.controllerMain.jsonSend.getError();
    if (error != null) {
      if (!mounted) return;
      showSmxSystemErrorDialog(context, message: error);
      return;
    }

    final invite = invitacion;
    if (invite == null) return;

    await _copyLink(invite.link, 'Se copio link por correo');
  }

  Future<void> _copyLink(String link, String mensaje) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;

    setState(() => _mensaje = mensaje);
  }
}

class _QrInvitePanel extends StatelessWidget {
  final SmxSaldiFyInvitacionGenerada? invitacion;
  final bool loading;
  final VoidCallback onCopy;

  const _QrInvitePanel({
    required this.invitacion,
    required this.loading,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final invite = invitacion;

    return Column(
      children: [
        Center(
          child: SmxDepth(
            radius: 20,
            depth: 7,
            opacity: .36,
            blurRadius: 10,
            fade: true,
            child: Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: SmxColors.whiteAlpha(.88),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 210,
                height: 210,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SmxColors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: loading || invite == null
                    ? const CircularProgressIndicator()
                    : QrImageView(
                        data: invite.link,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: SmxColors.white,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                invite?.codigoFormato ?? 'Generando codigo...',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton.filled(
                  tooltip: 'Copiar link',
                  onPressed: invite == null ? null : onCopy,
                  iconSize: 28,
                  icon: const Icon(Icons.link),
                  style: IconButton.styleFrom(
                    backgroundColor: SmxColors.brandPrimary,
                    foregroundColor: SmxColors.white,
                    fixedSize: const Size(48, 48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InviteMessage extends StatelessWidget {
  final String mensaje;

  const _InviteMessage({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 38),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SmxColors.blackAlpha(.07)),
      ),
      child: Text(
        mensaje.isEmpty
            ? 'Copia un link para mostrar el mensaje aqui.'
            : mensaje,
        style: TextStyle(
          color: mensaje.isEmpty ? SmxColors.textMuted : SmxColors.brandPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String label;

  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: SmxColors.blackAlpha(.12))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: SmxColors.brandPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(child: Divider(color: SmxColors.blackAlpha(.12))),
      ],
    );
  }
}

class _GmailInviteRow extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onCopy;

  const _GmailInviteRow({
    required this.controller,
    required this.loading,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._%+-]')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                return newValue.copyWith(text: newValue.text.toLowerCase());
              }),
            ],
            decoration: InputDecoration(
              filled: true,
              fillColor: SmxColors.whiteAlpha(.9),
              hintText: 'correo',
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    '@gmail.com',
                    style: TextStyle(
                      color: SmxColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: SmxColors.blackAlpha(.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: SmxColors.blackAlpha(.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: SmxColors.brandPrimary,
                  width: 1.4,
                ),
              ),
            ),
            style: const TextStyle(
              color: SmxColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          tooltip: 'Copiar link Gmail',
          onPressed: loading ? null : onCopy,
          iconSize: 28,
          icon: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.link),
          style: IconButton.styleFrom(
            backgroundColor: SmxColors.brandPrimary,
            foregroundColor: SmxColors.white,
            fixedSize: const Size(48, 48),
          ),
        ),
      ],
    );
  }
}
