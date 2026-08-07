import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../smxLayout/smxColors.dart';

class InvitadoOptionCard extends StatelessWidget {
  final bool compact;
  final String codigo;
  final String? codigoError;
  final VoidCallback onInvitadoCodigoTap;

  const InvitadoOptionCard({
    required this.compact,
    required this.codigo,
    required this.codigoError,
    required this.onInvitadoCodigoTap,
  });

  @override
  Widget build(BuildContext context) {
    const cardBgColor = Color(0xFFF0F4F7);
    const cardBorderColor = Color(0xFFDDE4EB);
    final radius = compact ? 16.0 : 20.0;

    return Material(
      color: cardBgColor,
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: cardBorderColor,
            width: compact ? 1.4 : 1.4,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: codigo,
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Código de invitación',
                  errorText: codigoError,
                  filled: true,
                  fillColor: const Color(0xFFE8EEF2),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: compact ? 12 : 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(compact ? 13 : 16),
                    borderSide: const BorderSide(color: Color(0xFFD1DAE4)),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(compact ? 13 : 16),
                    borderSide: const BorderSide(color: Color(0xFFD1DAE4)),
                  ),
                  prefixIcon: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Color(0xFF1454B8),
                  ),
                ),
                style: TextStyle(
                  color: SmxColors.textMuted,
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: compact ? 10 : 12),
              SizedBox(
                height: compact ? 46 : 52,
                child: ElevatedButton.icon(
                  onPressed: onInvitadoCodigoTap,
                  icon: compact
                      ? const SizedBox.shrink()
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Continuar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0647B7),
                    foregroundColor: SmxColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(compact ? 13 : 16),
                    ),
                    textStyle: TextStyle(
                      fontSize: compact ? 15 : 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}