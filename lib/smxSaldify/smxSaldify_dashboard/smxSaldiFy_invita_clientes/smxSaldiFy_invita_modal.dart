import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxColors.dart';

import '../smxSaldiFy_clientes/smxSaldiFy_clientes_mock.dart';

enum SmxSaldiFyInvitaAction { copiarLink, whatsApp }

Future<void> showSmxSaldiFyInvitaModal({
  required BuildContext context,
  required String uuidAnfitrion,
  required String anfitrionNombre,
  required SmxSaldiFyInvitaAction action,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) {
      return _InviteLinkDialog(
        uuidAnfitrion: uuidAnfitrion,
        action: action,
        onInvite: (invite) =>
            _runInviteAction(context, invite, action, anfitrionNombre),
      );
    },
  );
}

Future<void> _runInviteAction(
  BuildContext context,
  _InviteActionData invite,
  SmxSaldiFyInvitaAction action,
  String anfitrionNombre,
) async {
  if (action == SmxSaldiFyInvitaAction.copiarLink) {
    await Clipboard.setData(ClipboardData(text: invite.link));

    if (!context.mounted) return;

    _showPageMessage(context, 'Link de invitacion copiado.');
    return;
  }

  final whatsAppUrl = _buildWhatsAppUrl(
    telefono: invite.telefono,
    link: invite.link,
    anfitrionNombre: anfitrionNombre,
  );

  if (whatsAppUrl == null) {
    if (!context.mounted) return;
    _showPageMessage(context, 'Ingresa un telefono valido.');
    return;
  }

  await launchUrl(whatsAppUrl, mode: LaunchMode.externalApplication);
}

Uri? _buildWhatsAppUrl({
  required String telefono,
  required String link,
  required String anfitrionNombre,
}) {
  final phone = _normalizeWhatsAppPhone(telefono);
  if (phone.length < 8) return null;

  return Uri.https('api.whatsapp.com', '/send', {
    'phone': phone,
    'text': _buildWhatsAppMessage(link: link, anfitrionNombre: anfitrionNombre),
  });
}

String _buildWhatsAppMessage({
  required String link,
  required String anfitrionNombre,
}) {
  final anfitrion = anfitrionNombre.trim().isEmpty
      ? 'Tu anfitrion'
      : anfitrionNombre.trim();

  return [
    'SALDIFY',
    'Anfitrion: $anfitrion',
    'Te comparto tu invitacion para entrar a mi red de clientes.',
    link,
  ].join('\n');
}

String _normalizeWhatsAppPhone(String telefono) {
  var phone = telefono.replaceAll(RegExp(r'[^0-9]'), '');

  if (phone.startsWith('00')) {
    phone = phone.substring(2);
  }

  if (phone.startsWith('044') || phone.startsWith('045')) {
    phone = phone.substring(3);
  }

  if (phone.startsWith('01') && phone.length == 12) {
    phone = phone.substring(2);
  }

  if (phone.length == 10) {
    phone = '52$phone';
  }

  if (phone.startsWith('521') && phone.length == 13) {
    phone = '52${phone.substring(3)}';
  }

  return phone;
}

void _showPageMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class _InviteActionData {
  final String link;
  final String telefono;

  const _InviteActionData({required this.link, this.telefono = ''});
}

class _InviteLinkDialog extends StatefulWidget {
  final String uuidAnfitrion;
  final SmxSaldiFyInvitaAction action;
  final Future<void> Function(_InviteActionData invite) onInvite;

  const _InviteLinkDialog({
    required this.uuidAnfitrion,
    required this.action,
    required this.onInvite,
  });

  @override
  State<_InviteLinkDialog> createState() => _InviteLinkDialogState();
}

class _InviteLinkDialogState extends State<_InviteLinkDialog> {
  late final SmxRowSet _clientes;
  late final TextEditingController _correoController;
  late final TextEditingController _telefonoController;

  @override
  void initState() {
    super.initState();
    _clientes = getRstSmxSaldiFyClientesMock();
    _correoController = TextEditingController();
    _telefonoController = TextEditingController();
  }

  @override
  void dispose() {
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  bool get _isWhatsApp => widget.action == SmxSaldiFyInvitaAction.whatsApp;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: SmxColors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 620),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: SmxGradients.saldifyBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SmxColors.whiteAlpha(.14)),
            boxShadow: [
              BoxShadow(
                color: SmxColors.blackAlpha(.28),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: DefaultTabController(
            length: 2,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Crear invitacion',
                          style: TextStyle(
                            color: SmxColors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cancelar',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: SmxColors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: SmxColors.whiteAlpha(.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: SmxColors.brandAccent,
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      labelColor: SmxColors.navigationDark,
                      unselectedLabelColor: SmxColors.white70,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                      tabs: [
                        Tab(text: 'Cliente existente'),
                        Tab(text: 'Correo invitado'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _ClienteExistenteTab(
                          clientes: _clientes,
                          action: widget.action,
                          onInvite: _sendClienteLink,
                        ),
                        _CorreoInvitadoTab(
                          correoController: _correoController,
                          telefonoController: _telefonoController,
                          action: widget.action,
                          onInvite: _sendCorreoLink,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendClienteLink(_ClienteInvitadoInfo cliente) async {
    if (_isWhatsApp && !_isValidPhone(cliente.telefono)) {
      _showModalMessage('El cliente no tiene un telefono valido.');
      return;
    }

    final link = _buildInviteLink(uuidInvitado: cliente.uuidInvitado);
    await widget.onInvite(
      _InviteActionData(link: link, telefono: cliente.telefono),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _sendCorreoLink() async {
    final correo = _correoController.text.trim().toLowerCase();
    final telefono = _telefonoController.text.trim();

    if (!_isValidEmail(correo)) {
      _showModalMessage('Ingresa un correo valido.');
      return;
    }

    if (_isWhatsApp && !_isValidPhone(telefono)) {
      _showModalMessage('Ingresa un telefono valido.');
      return;
    }

    final link = _buildInviteLink(correoInvitado: correo);
    await widget.onInvite(_InviteActionData(link: link, telefono: telefono));
    if (mounted) Navigator.of(context).pop();
  }

  String _buildInviteLink({String? uuidInvitado, String? correoInvitado}) {
    final queryParameters = {
      SmxConstants.uuidAnfitrionParam: widget.uuidAnfitrion,
    };

    if (uuidInvitado != null) {
      queryParameters[SmxConstants.uuidInvitadoParam] = uuidInvitado;
    }

    if (correoInvitado != null) {
      queryParameters[SmxConstants.correoInvitadoParam] = correoInvitado;
    }

    return Uri.base.replace(queryParameters: queryParameters).toString();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  bool _isValidPhone(String value) {
    return _normalizeWhatsAppPhone(value).length >= 8;
  }

  void _showModalMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ClienteInvitadoInfo {
  final String uuidInvitado;
  final String telefono;

  const _ClienteInvitadoInfo({
    required this.uuidInvitado,
    required this.telefono,
  });
}

class _ClienteExistenteTab extends StatelessWidget {
  final SmxRowSet clientes;
  final SmxSaldiFyInvitaAction action;
  final ValueChanged<_ClienteInvitadoInfo> onInvite;

  const _ClienteExistenteTab({
    required this.clientes,
    required this.action,
    required this.onInvite,
  });

  bool get _isWhatsApp => action == SmxSaldiFyInvitaAction.whatsApp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Invitacion por credencial',
          style: TextStyle(
            color: SmxColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Usa esta opcion cuando el cliente ya existe en tu red.',
          style: TextStyle(
            color: SmxColors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: ListView.separated(
            itemCount: clientes.getRowCount(),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              clientes.index(index);
              final name = clientes.getValue('NAME')?.toString() ?? '';
              final status = clientes.getValue('STATUS')?.toString() ?? '';
              final uuidInvitado =
                  clientes.getValue('UUID_INVITADO')?.toString() ?? '';
              final telefono = clientes.getValue('TELEFONO')?.toString() ?? '';

              return Material(
                color: SmxColors.whiteAlpha(.92),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: uuidInvitado.isEmpty
                      ? null
                      : () => onInvite(
                          _ClienteInvitadoInfo(
                            uuidInvitado: uuidInvitado,
                            telefono: telefono,
                          ),
                        ),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          color: SmxColors.brandPrimary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: SmxColors.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                status,
                                style: const TextStyle(
                                  color: SmxColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_isWhatsApp) ...[
                                const SizedBox(height: 3),
                                Text(
                                  telefono.isEmpty ? 'Sin telefono' : telefono,
                                  style: const TextStyle(
                                    color: SmxColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          _isWhatsApp ? Icons.chat_rounded : Icons.copy_rounded,
                          color: SmxColors.brandSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CorreoInvitadoTab extends StatelessWidget {
  final TextEditingController correoController;
  final TextEditingController telefonoController;
  final SmxSaldiFyInvitaAction action;
  final VoidCallback onInvite;

  const _CorreoInvitadoTab({
    required this.correoController,
    required this.telefonoController,
    required this.action,
    required this.onInvite,
  });

  bool get _isWhatsApp => action == SmxSaldiFyInvitaAction.whatsApp;

  String get _buttonLabel => _isWhatsApp ? 'Enviar WhatsApp' : 'Copiar link';

  IconData get _buttonIcon =>
      _isWhatsApp ? Icons.chat_rounded : Icons.copy_rounded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Invitacion por correo',
          style: TextStyle(
            color: SmxColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Usa esta opcion cuando el cliente aun no esta cargado en tu red.',
          style: TextStyle(
            color: SmxColors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: correoController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: _isWhatsApp
              ? TextInputAction.next
              : TextInputAction.done,
          onSubmitted: (_) {
            if (!_isWhatsApp) onInvite();
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: SmxColors.whiteAlpha(.94),
            prefixIcon: const Icon(
              Icons.mail_rounded,
              color: SmxColors.brandPrimary,
            ),
            hintText: 'correo@cliente.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_isWhatsApp) ...[
          const SizedBox(height: 12),
          TextField(
            controller: telefonoController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onInvite(),
            decoration: InputDecoration(
              filled: true,
              fillColor: SmxColors.whiteAlpha(.94),
              prefixIcon: const Icon(
                Icons.phone_rounded,
                color: SmxColors.brandPrimary,
              ),
              hintText: 'Telefono WhatsApp',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
        const Spacer(),
        ElevatedButton.icon(
          onPressed: onInvite,
          icon: Icon(_buttonIcon),
          label: Text(_buttonLabel),
        ),
      ],
    );
  }
}
