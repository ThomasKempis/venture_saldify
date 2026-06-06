import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';

class SmxSaldiFyInvitaClientes extends StatefulWidget {
  const SmxSaldiFyInvitaClientes({super.key});

  @override
  State<SmxSaldiFyInvitaClientes> createState() =>
      _SmxSaldiFyInvitaClientesState();
}

class _SmxSaldiFyInvitaClientesState extends State<SmxSaldiFyInvitaClientes> {
  bool _whatsAppSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: SmxColors.surfaceQr,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SmxColors.white, width: 8),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: SmxColors.iconDark,
              size: 70,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Invita clientes',
                  style: TextStyle(
                    color: SmxColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Comparte tu QR o link. Todo cliente que se registre entra a tu negocio y queda pendiente de aprobacion.',
                  style: TextStyle(
                    color: SmxColors.textMuted,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InvitePill(
                      label: 'Copiar link',
                      filled: !_whatsAppSelected,
                      onTap: () {
                        setState(() => _whatsAppSelected = false);
                      },
                    ),
                    const SizedBox(width: 8),
                    _InvitePill(
                      label: 'WhatsApp',
                      filled: _whatsAppSelected,
                      onTap: () {
                        setState(() => _whatsAppSelected = true);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitePill extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _InvitePill({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? SmxColors.brandSecondary : SmxColors.surfacePill,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? SmxColors.white : SmxColors.brandPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
