import 'package:flutter/material.dart';
import 'package:venture_saldify/smxApis/smxConfig.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxMenuVersion.dart';

class SmxSaldiFyClienteMenuButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SmxSaldiFyClienteMenuButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.14),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.menu_rounded, color: SmxColors.white, size: 26),
        ),
      ),
    );
  }
}

class SmxSaldiFyClienteNavigationPanel extends StatelessWidget {
  final bool isDesktop;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const SmxSaldiFyClienteNavigationPanel({
    super.key,
    required this.isDesktop,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final expanded = isDesktop;
    final width = expanded ? 280.0 : 92.0;

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: SmxColors.navigationDark),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, expanded ? 24 : 18, 12, 18),
            child: Column(
              children: [
                _NavigationBrand(expanded: expanded),
                const SizedBox(height: 24),
                _NavigationItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Inicio',
                  expanded: expanded,
                  selected: selectedIndex == 0,
                  onTap: () => onSelect(0),
                ),
                const SizedBox(height: 8),
                _NavigationItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  expanded: expanded,
                  selected: selectedIndex == 1,
                  onTap: () => onSelect(1),
                ),
                const SizedBox(height: 8),
                _NavigationItem(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Programa de lealtad',
                  expanded: expanded,
                  selected: selectedIndex == 2,
                  onTap: () => onSelect(2),
                ),
                const Divider(color: SmxColors.white24, height: 32),
                _NavigationItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Movimientos',
                  expanded: expanded,
                  enabled: false,
                ),
                const SizedBox(height: 8),
                _NavigationItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Credito',
                  expanded: expanded,
                  enabled: false,
                ),
                const SizedBox(height: 8),
                _NavigationItem(
                  icon: Icons.payments_rounded,
                  label: 'Pagos',
                  expanded: expanded,
                  enabled: false,
                ),
                const Spacer(),
                if (expanded)
                  const SmxMenuVersion(
                    style: TextStyle(
                      color: SmxColors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  const Icon(
                    Icons.more_horiz_rounded,
                    color: SmxColors.white38,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmxSaldiFyClienteDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const SmxSaldiFyClienteDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = _drawerTopInset(context);

    return Drawer(
      backgroundColor: SmxColors.navigationDark,
      child: SizedBox.expand(
        child: ColoredBox(
          color: SmxColors.navigationDark,
          child: Padding(
            padding: EdgeInsets.only(top: topInset),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 34,
                          height: 34,
                          child: SmxConfig.logo(fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              SmxConfig.titulo.toUpperCase(),
                              style: const TextStyle(
                                color: SmxColors.white,
                                fontFamily: 'Segoe UI',
                                fontFamilyFallback: [
                                  'Tahoma',
                                  'Geneva',
                                  'Verdana',
                                  'Arial',
                                ],
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                letterSpacing: 2.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              SmxConfig.descripcion,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: SmxColors.brandDescription,
                                fontFamily: 'Segoe UI',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .7,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _DrawerItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Inicio',
                  selected: selectedIndex == 0,
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelect(0);
                  },
                ),
                _DrawerItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  selected: selectedIndex == 1,
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelect(1);
                  },
                ),
                _DrawerItem(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Programa de lealtad',
                  selected: selectedIndex == 2,
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelect(2);
                  },
                ),
                const Divider(color: SmxColors.white24, height: 28),
                const _DisabledDrawerItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Movimientos',
                ),
                const _DisabledDrawerItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Credito',
                ),
                const _DisabledDrawerItem(
                  icon: Icons.payments_rounded,
                  label: 'Pagos',
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SmxMenuVersion(
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SmxColors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _drawerTopInset(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final systemTopInset = mediaQuery.viewPadding.top > 0
        ? mediaQuery.viewPadding.top
        : mediaQuery.padding.top;

    if (systemTopInset > 0) return systemTopInset;

    return SmxLayout.topContentInset(context);
  }
}

class _NavigationBrand extends StatelessWidget {
  final bool expanded;

  const _NavigationBrand({required this.expanded});

  @override
  Widget build(BuildContext context) {
    final logo = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 34,
        height: 34,
        child: SmxConfig.logo(fit: BoxFit.contain),
      ),
    );

    if (!expanded) return logo;

    return Row(
      children: [
        logo,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SmxConfig.titulo.toUpperCase(),
                style: const TextStyle(
                  color: SmxColors.white,
                  fontFamily: 'Segoe UI',
                  fontFamilyFallback: ['Tahoma', 'Geneva', 'Verdana', 'Arial'],
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                SmxConfig.descripcion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.brandDescription,
                  fontFamily: 'Segoe UI',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool expanded;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.expanded,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? SmxColors.whiteAlpha(.32)
        : selected
        ? SmxColors.brandAccent
        : SmxColors.white70;

    return Material(
      color: selected ? SmxColors.accentAlpha(.16) : SmxColors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 50,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: expanded ? 14 : 0),
            child: Row(
              mainAxisAlignment: expanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? SmxColors.white : color,
                        fontWeight: selected
                            ? FontWeight.w900
                            : FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        onTap: onTap,
        selected: selected,
        selectedTileColor: SmxColors.accentAlpha(.16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(
          icon,
          color: selected ? SmxColors.brandAccent : SmxColors.white70,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? SmxColors.white : SmxColors.white70,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DisabledDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DisabledDrawerItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        enabled: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, color: SmxColors.whiteAlpha(.32)),
        title: Text(
          label,
          style: TextStyle(
            color: SmxColors.whiteAlpha(.32),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
