import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';

class SmxSaldiFyClienteAnfitrion extends StatelessWidget {
  final String nombreAnfitrion;
  final String telefonoAnfitrion;
  final String estadoRelacion;
  final VoidCallback onContactTap;

  const SmxSaldiFyClienteAnfitrion({
    super.key,
    required this.nombreAnfitrion,
    required this.telefonoAnfitrion,
    required this.estadoRelacion,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final telefono = telefonoAnfitrion.trim();

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
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: SmxColors.surfaceQr,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SmxColors.white, width: 6),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: SmxColors.iconDark,
              size: 46,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nombreAnfitrion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SmxColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (estadoRelacion.isNotEmpty)
                      _EstadoPill(label: estadoRelacion),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  telefono.isEmpty
                      ? 'WhatsApp no registrado'
                      : 'WhatsApp: $telefono',
                  style: const TextStyle(
                    color: SmxColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tus compras provistas se cargan a credito y aparecen en saldo pendiente.',
                  style: TextStyle(
                    color: SmxColors.textMuted,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: SmxColors.brandSecondary,
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    onTap: onContactTap,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: const Text(
                        'WhatsApp del anfitrion',
                        style: TextStyle(
                          color: SmxColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoPill extends StatelessWidget {
  final String label;

  const _EstadoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SmxColors.successBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: SmxColors.successForeground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
