import 'package:flutter/material.dart';
import '../../smxLayout/smxColors.dart';

class PrincipalOptionCard extends StatelessWidget {
  final bool compact;
  final VoidCallback? onAnfitrionTap;
  final VoidCallback? onInvitadoTap;
  final VoidCallback onCambiarCuentaAnfitrionTap;
  final bool forceNextAnfitrionAccountSelection;


  const PrincipalOptionCard({
    super.key,
    required this.compact,
    required this.onAnfitrionTap,
    required this.onCambiarCuentaAnfitrionTap,
    required this.forceNextAnfitrionAccountSelection,
    required this.onInvitadoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccessOptionCard(
          compact: compact,
          icon: Icons.storefront_rounded,
          title: 'Anfitrión (Empresa)',
          subtitle: 'Gestiona créditos y clientes',
          accentColor: SmxColors.successForeground,
          backgroundColor:
              compact ? SmxColors.white : const Color(0xFFEAF8F0),
          borderColor: const Color(0xFFC7E9D9),
          onTap: onAnfitrionTap,
        ),
        SizedBox(height: compact ? 8 : 10),
        ChangeHostAccountAction(
          compact: compact,
          active: forceNextAnfitrionAccountSelection,
          enabled: true,
          onTap: onCambiarCuentaAnfitrionTap,
        ),
        SizedBox(height: compact ? 12 : 14),
        AccessOptionCard(
          compact: compact,
          icon: Icons.person_pin_circle_rounded,
          title: 'Invitado (Cliente)',
          subtitle: 'Ingresa con el ultimo link de invitacion validado',
          accentColor: const Color(0xFF1454B8),
          backgroundColor:
              compact ? SmxColors.white : const Color(0xFFF5FBFF),
          borderColor: const Color(0xFFCFE0F6),
          onTap: onInvitadoTap,
        ),
      ],
    );
  }
}

class AccessOptionCard extends StatelessWidget {
  final bool compact;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const AccessOptionCard({
    super.key,
    required this.compact,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.backgroundColor,
    required this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 16.0 : 20.0;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: compact ? 1.4 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: Opacity(
            opacity: onTap == null ? 0.5 : 1.0,
            child: Padding(
              padding: EdgeInsets.all(compact ? 12 : 16),
              child: Row(
                children: [
                  OptionIcon(compact: compact, icon: icon, color: accentColor),
                  SizedBox(width: compact ? 12 : 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: SmxColors.textDark,
                            fontSize: compact ? 16 : 18,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: compact ? 5 : 6),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: SmxColors.textMuted,
                            fontSize: compact ? 13 : 14,
                            fontWeight: FontWeight.w700,
                            height: 1.18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: accentColor,
                    size: compact ? 28 : 32,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChangeHostAccountAction extends StatelessWidget {
  final bool compact;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const ChangeHostAccountAction({
    super.key,
    required this.compact,
    required this.active,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? SmxColors.successForeground : SmxColors.textMuted;
    final disabledColor = SmxColors.textMuted.withValues(alpha: .45);

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: SmxColors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 8 : 10,
              vertical: compact ? 6 : 7,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  active
                      ? Icons.check_circle_outline_rounded
                      : Icons.switch_account_rounded,
                  color: enabled ? color : disabledColor,
                  size: compact ? 18 : 19,
                ),
                const SizedBox(width: 7),
                Text(
                  active
                      ? 'Se elegirá otra cuenta de Google'
                      : 'Cambiar cuenta de google',
                  style: TextStyle(
                    color: enabled ? color : disabledColor,
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OptionIcon extends StatelessWidget {
  final bool compact;
  final IconData icon;
  final Color color;

  const OptionIcon({
    super.key,
    required this.compact,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 42 : 48,
      height: compact ? 42 : 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: compact ? .10 : .12),
        borderRadius: BorderRadius.circular(compact ? 14 : 16),
      ),
      child: Icon(icon, color: color, size: compact ? 27 : 29),
    );
  }
}
