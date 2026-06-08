import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxColors.dart';

import '../smxSaldiFy_clientes/smxSaldiFy_clientes_mock.dart';

Future<void> showSmxSaldiFyInvitaModal({
  required BuildContext context,
  required String uuidAnfitrion,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) {
      return _InviteLinkDialog(
        uuidAnfitrion: uuidAnfitrion,
        onCopy: (link) async {
          await Clipboard.setData(ClipboardData(text: link));

          if (!context.mounted) return;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Link de invitacion copiado.')),
            );
        },
      );
    },
  );
}

class _InviteLinkDialog extends StatefulWidget {
  final String uuidAnfitrion;
  final Future<void> Function(String link) onCopy;

  const _InviteLinkDialog({required this.uuidAnfitrion, required this.onCopy});

  @override
  State<_InviteLinkDialog> createState() => _InviteLinkDialogState();
}

class _InviteLinkDialogState extends State<_InviteLinkDialog> {
  late final SmxRowSet _clientes;
  late final TextEditingController _correoController;

  @override
  void initState() {
    super.initState();
    _clientes = getRstSmxSaldiFyClientesMock();
    _correoController = TextEditingController();
  }

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

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
                          onCopy: _copyClienteLink,
                        ),
                        _CorreoInvitadoTab(
                          controller: _correoController,
                          onCopy: _copyCorreoLink,
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

  Future<void> _copyClienteLink(String uuidInvitado) async {
    final link = _buildInviteLink(uuidInvitado: uuidInvitado);
    await widget.onCopy(link);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _copyCorreoLink() async {
    final correo = _correoController.text.trim().toLowerCase();

    if (!_isValidEmail(correo)) {
      _showModalMessage('Ingresa un correo valido.');
      return;
    }

    final link = _buildInviteLink(correoInvitado: correo);
    await widget.onCopy(link);
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

  void _showModalMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ClienteExistenteTab extends StatelessWidget {
  final SmxRowSet clientes;
  final ValueChanged<String> onCopy;

  const _ClienteExistenteTab({required this.clientes, required this.onCopy});

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

              return Material(
                color: SmxColors.whiteAlpha(.92),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: uuidInvitado.isEmpty
                      ? null
                      : () => onCopy(uuidInvitado),
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
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.copy_rounded,
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
  final TextEditingController controller;
  final VoidCallback onCopy;

  const _CorreoInvitadoTab({required this.controller, required this.onCopy});

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
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onCopy(),
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
        const Spacer(),
        ElevatedButton.icon(
          onPressed: onCopy,
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Copiar link'),
        ),
      ],
    );
  }
}
