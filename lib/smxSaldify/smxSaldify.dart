import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxPerfil/smxPerfil.dart';
import '../smxLogonMovil/logon/smxLogonMovil_controller.dart';
import 'SmxSaldiFy_screen_tmp.dart';

class SmxSaldiFy extends StatefulWidget {
  final SmxLogonMovil_controller controllerMain;

  const SmxSaldiFy({super.key, required this.controllerMain});

  @override
  State<SmxSaldiFy> createState() => _SmxSaldiFy();
}

class _SmxSaldiFy extends State<SmxSaldiFy> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final adminName = _getAdminName();

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _SaldifyLayout.fromWidth(constraints.maxWidth);
        final page = _selectedIndex == 0
            ? _SaldifyDashboard(adminName: adminName, layout: layout)
            : _PerfilPage(
                controllerMain: widget.controllerMain,
                onNavigateToHome: () => _selectPage(0),
                layout: layout,
              );

        if (layout.isMobile) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
            extendBodyBehindAppBar: true,
            drawer: _SaldifyDrawer(
              selectedIndex: _selectedIndex,
              onSelect: _selectPage,
            ),
            body: page,
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: Row(
            children: [
              _SaldifyNavigationPanel(
                layout: layout,
                selectedIndex: _selectedIndex,
                onSelect: _selectPage,
              ),
              Expanded(child: page),
            ],
          ),
        );
      },
    );
  }

  void _selectPage(int index) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAdminName() {
    try {
      final fullName = widget.controllerMain.getNombres().trim();
      if (fullName.isEmpty) return 'Administrador';

      return fullName.split(RegExp(r'\s+')).first;
    } catch (_) {
      return 'Administrador';
    }
  }
}

enum _SaldifyLayout {
  mobile,
  tablet,
  desktop;

  static _SaldifyLayout fromWidth(double width) {
    if (width < 700) return _SaldifyLayout.mobile;
    if (width < 1100) return _SaldifyLayout.tablet;
    return _SaldifyLayout.desktop;
  }

  bool get isMobile => this == _SaldifyLayout.mobile;
  bool get isTablet => this == _SaldifyLayout.tablet;
  bool get isDesktop => this == _SaldifyLayout.desktop;

  double get maxContentWidth => switch (this) {
    _SaldifyLayout.mobile => 460,
    _SaldifyLayout.tablet => 860,
    _SaldifyLayout.desktop => 1180,
  };

  EdgeInsets get pagePadding => switch (this) {
    _SaldifyLayout.mobile => const EdgeInsets.fromLTRB(20, 20, 20, 28),
    _SaldifyLayout.tablet => const EdgeInsets.fromLTRB(28, 28, 28, 34),
    _SaldifyLayout.desktop => const EdgeInsets.fromLTRB(36, 34, 36, 40),
  };

  int metricColumnsFor(double width) {
    if (width >= 980) return 4;
    if (width >= 700) return 3;
    if (width >= 300) return 2;
    return 1;
  }
}

class _SaldifyDashboard extends StatefulWidget {
  final String adminName;
  final _SaldifyLayout layout;

  const _SaldifyDashboard({required this.adminName, required this.layout});

  @override
  State<_SaldifyDashboard> createState() => _SaldifyDashboardState();
}

class _SaldifyDashboardState extends State<_SaldifyDashboard> {
  static const _backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
  );

  @override
  Widget build(BuildContext context) {
    final topContentInset = _topContentInset(context);
    final pagePadding = widget.layout.pagePadding;
    final layout = widget.layout;

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      pagePadding.left,
                      pagePadding.top + topContentInset,
                      pagePadding.right,
                      pagePadding.bottom,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _SaldifyHeader(showMenu: layout.isMobile),
                        SizedBox(height: layout.isMobile ? 26 : 34),
                        Text(
                          'Hola, ${widget.adminName}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _openUnderConstruction(
                              context,
                              'Red de clientes',
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                'Tu red de clientes al dia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  height: 1.04,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: layout.isMobile ? 22 : 28),
                        _MetricsGrid(
                          layout: layout,
                          onMetricTap: (title) =>
                              _openUnderConstruction(context, title),
                        ),
                        SizedBox(height: layout.isMobile ? 16 : 20),
                        const _InviteClientCard(),
                        SizedBox(height: layout.isMobile ? 24 : 30),
                        const _SectionHeader(
                          title: 'Acciones rapidas',
                          trailing: 'Corte: 15 Jun',
                        ),
                        const SizedBox(height: 12),
                        _QuickActions(
                          layout: layout,
                          onActionTap: (title) {
                            if (title == 'Cliente') {
                              title = 'Nuevo Cliente';
                            }

                            _openUnderConstruction(context, title);
                          },
                        ),
                        SizedBox(height: layout.isMobile ? 26 : 30),
                        _SectionHeader(
                          title: 'Clientes',
                          trailing: _showAllClients ? 'Ver menos' : 'Ver todos',
                          onTrailingTap: () {
                            setState(() {
                              _showAllClients = !_showAllClients;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _ClientCards(
                          layout: layout,
                          showAll: _showAllClients,
                          onClientTap: (name) =>
                              _openUnderConstruction(context, name),
                        ),
                      ]),
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

  bool _showAllClients = false;
}

double _topContentInset(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final systemTopInset = mediaQuery.padding.top > 0
      ? mediaQuery.padding.top
      : mediaQuery.viewPadding.top;

  if (systemTopInset > 0) return 0;

  final isMobileWidth = mediaQuery.size.shortestSide < 600;
  final isMobilePlatform =
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  return kIsWeb && isMobileWidth && isMobilePlatform ? 44 : 0;
}

void _openUnderConstruction(BuildContext context, String title) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => SmxSaldiFyScreenTmp(title: title)),
  );
}

class _PerfilPage extends StatelessWidget {
  final SmxLogonMovil_controller controllerMain;
  final VoidCallback onNavigateToHome;
  final _SaldifyLayout layout;

  const _PerfilPage({
    required this.controllerMain,
    required this.onNavigateToHome,
    required this.layout,
  });

  static const _backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
  );

  @override
  Widget build(BuildContext context) {
    final topContentInset = _topContentInset(context);
    final pagePadding = layout.pagePadding;

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pagePadding.left,
                      pagePadding.top + topContentInset,
                      pagePadding.right,
                      0,
                    ),
                    child: _SaldifyHeader(
                      title: 'Perfil',
                      showMenu: layout.isMobile,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: SmxPerfil(
                      controllerMain: controllerMain,
                      onNavigateToHome: onNavigateToHome,
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
}

class _SaldifyHeader extends StatelessWidget {
  final String? title;
  final bool showMenu;

  const _SaldifyHeader({this.title, this.showMenu = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showMenu) ...[
          Builder(
            builder: (context) =>
                _MenuButton(onPressed: () => Scaffold.of(context).openDrawer()),
          ),
          const SizedBox(width: 14),
        ],
        ClipOval(
          child: SizedBox(
            width: 54,
            height: 54,
            child: Image.asset(
              'assets/images/logo_logon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: title == null
              ? const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SALDIFY',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Segoe UI',
                        fontFamilyFallback: [
                          'Tahoma',
                          'Geneva',
                          'Verdana',
                          'Arial',
                        ],
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: 2.6,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'SMART BALANCE & CREDITS CONTROL',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF58D9A4),
                        fontFamily: 'Segoe UI',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                      ),
                    ),
                  ],
                )
              : Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
        ),
      ],
    );
  }
}

class _SaldifyNavigationPanel extends StatelessWidget {
  final _SaldifyLayout layout;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _SaldifyNavigationPanel({
    required this.layout,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final expanded = layout.isDesktop;
    final width = expanded ? 280.0 : 92.0;

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF102D36)),
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
                const Divider(color: Colors.white24, height: 32),
                _NavigationItem(
                  icon: Icons.groups_rounded,
                  label: 'Clientes',
                  expanded: expanded,
                  enabled: false,
                ),
                const SizedBox(height: 8),
                _NavigationItem(
                  icon: Icons.qr_code_2_rounded,
                  label: 'Invitar',
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
                  const Text(
                    'Version inicial operativa',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  const Icon(
                    Icons.more_horiz_rounded,
                    color: Colors.white38,
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

class _NavigationBrand extends StatelessWidget {
  final bool expanded;

  const _NavigationBrand({required this.expanded});

  @override
  Widget build(BuildContext context) {
    final logo = ClipOval(
      child: SizedBox(
        width: 50,
        height: 50,
        child: Image.asset('assets/images/logo_logon.png', fit: BoxFit.cover),
      ),
    );

    if (!expanded) return logo;

    return Row(
      children: [
        logo,
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SALDIFY',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Segoe UI',
                  fontFamilyFallback: ['Tahoma', 'Geneva', 'Verdana', 'Arial'],
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: 2.4,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'SMART BALANCE & CREDITS CONTROL',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF58D9A4),
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
        ? Colors.white.withValues(alpha: .32)
        : selected
        ? const Color(0xFF58D9A4)
        : Colors.white70;

    return Material(
      color: selected
          ? const Color(0xFF58D9A4).withValues(alpha: .16)
          : Colors.transparent,
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
                        color: selected ? Colors.white : color,
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

class _MenuButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _MenuButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

class _SaldifyDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _SaldifyDrawer({required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF102D36),
      child: SizedBox.expand(
        child: ColoredBox(
          color: const Color(0xFF102D36),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 54,
                          height: 54,
                          child: Image.asset(
                            'assets/images/logo_logon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SALDIFY',
                              style: TextStyle(
                                color: Colors.white,
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
                            SizedBox(height: 6),
                            Text(
                              'SMART BALANCE & CREDITS CONTROL',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF58D9A4),
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
                  onTap: () => onSelect(0),
                ),
                _DrawerItem(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  selected: selectedIndex == 1,
                  onTap: () => onSelect(1),
                ),
                const Divider(color: Colors.white24, height: 28),
                const _DisabledDrawerItem(
                  icon: Icons.groups_rounded,
                  label: 'Clientes',
                ),
                const _DisabledDrawerItem(
                  icon: Icons.qr_code_2_rounded,
                  label: 'Invitar clientes',
                ),
                const _DisabledDrawerItem(
                  icon: Icons.payments_rounded,
                  label: 'Pagos',
                ),
                const Spacer(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    'Version inicial operativa',
                    style: TextStyle(
                      color: Colors.white54,
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
        selectedTileColor: const Color(0xFF58D9A4).withValues(alpha: .16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(
          icon,
          color: selected ? const Color(0xFF58D9A4) : Colors.white70,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
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
        leading: Icon(icon, color: Colors.white.withValues(alpha: .32)),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .32),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final _SaldifyLayout layout;
  final ValueChanged<String> onMetricTap;

  const _MetricsGrid({required this.layout, required this.onMetricTap});

  @override
  Widget build(BuildContext context) {
    const cards = [
      _MetricCard(
        label: 'Total vendido',
        value: r'$184,250',
        note: '+12% este corte',
      ),
      _MetricCard(
        label: 'Credito entregado',
        value: r'$96,000',
        note: '8 clientes',
      ),
      _MetricCard(
        label: 'Pagos recibidos',
        value: r'$42,780',
        note: '18 movimientos',
      ),
      _MetricCard(
        label: 'Saldo pendiente',
        value: r'$53,220',
        note: '3 por vencer',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = layout.metricColumnsFor(constraints.maxWidth);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: layout.isMobile ? 128 : 138,
          ),
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _MetricCard(
              label: cards[index].label,
              value: cards[index].value,
              note: cards[index].note,
              onTap: () => onMetricTap(cards[index].label),
            );
          },
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String note;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: .18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .14),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              Text(
                note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF58D9A4),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteClientCard extends StatefulWidget {
  const _InviteClientCard();

  @override
  State<_InviteClientCard> createState() => _InviteClientCardState();
}

class _InviteClientCardState extends State<_InviteClientCard> {
  bool _whatsAppSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .22),
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
              color: const Color(0xFFF7FBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 8),
            ),
            child: const Icon(
              Icons.qr_code_2_rounded,
              color: Color(0xFF172431),
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
                    color: Color(0xFF173144),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Comparte tu QR o link. Todo cliente que se registre entra a tu negocio y queda pendiente de aprobacion.',
                  style: TextStyle(
                    color: Color(0xFF667783),
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
      color: filled ? const Color(0xFF0D47A1) : const Color(0xFFE8F5F0),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : const Color(0xFF1B5E20),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;
  final VoidCallback? onTrailingTap;

  const _SectionHeader({
    required this.title,
    required this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        InkWell(
          onTap: onTrailingTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              trailing,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final _SaldifyLayout layout;
  final ValueChanged<String> onActionTap;

  const _QuickActions({required this.layout, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final cardWidth = switch (layout) {
      _SaldifyLayout.mobile => 136.0,
      _SaldifyLayout.tablet => 180.0,
      _SaldifyLayout.desktop => 220.0,
    };

    const actions = [
      (icon: Icons.add_rounded, label: 'Cliente'),
      (icon: Icons.attach_money_rounded, label: 'Pago'),
      (icon: Icons.north_east_rounded, label: 'Credito'),
      (icon: Icons.bar_chart_rounded, label: 'Reporte'),
    ];

    return SizedBox(
      height: layout.isMobile ? 118 : 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: actions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final action = actions[index];

          return SizedBox(
            width: cardWidth,
            child: _QuickActionCard(
              icon: action.icon,
              label: action.label,
              onTap: () => onActionTap(action.label),
            ),
          );
        },
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: .16)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF58D9A4).withValues(alpha: .22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF58D9A4), size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientSummary {
  final String name;
  final String status;
  final _ClientStatusType statusType;
  final String cutDate;
  final String credit;
  final String balance;

  const _ClientSummary({
    required this.name,
    required this.status,
    required this.statusType,
    required this.cutDate,
    required this.credit,
    required this.balance,
  });
}

class _ClientCards extends StatelessWidget {
  final _SaldifyLayout layout;
  final bool showAll;
  final ValueChanged<String> onClientTap;

  const _ClientCards({
    required this.layout,
    required this.showAll,
    required this.onClientTap,
  });

  static const _clients = [
    _ClientSummary(
      name: 'Maria Lopez',
      status: 'Al dia',
      statusType: _ClientStatusType.ok,
      cutDate: '15 Jun',
      credit: r'$18,000',
      balance: r'$4,800',
    ),
    _ClientSummary(
      name: 'Carlos Rivera',
      status: 'Por vencer',
      statusType: _ClientStatusType.warning,
      cutDate: '06 Jun',
      credit: r'$12,500',
      balance: r'$7,100',
    ),
    _ClientSummary(
      name: 'Ana Torres',
      status: 'Vencido',
      statusType: _ClientStatusType.danger,
      cutDate: '31 May',
      credit: r'$20,000',
      balance: r'$11,200',
    ),
    _ClientSummary(
      name: 'Luis Mendoza',
      status: 'Al dia',
      statusType: _ClientStatusType.ok,
      cutDate: '20 Jun',
      credit: r'$15,000',
      balance: r'$2,900',
    ),
    _ClientSummary(
      name: 'Sofia Ramirez',
      status: 'Por vencer',
      statusType: _ClientStatusType.warning,
      cutDate: '08 Jun',
      credit: r'$9,500',
      balance: r'$5,600',
    ),
    _ClientSummary(
      name: 'Miguel Herrera',
      status: 'Vencido',
      statusType: _ClientStatusType.danger,
      cutDate: '29 May',
      credit: r'$16,000',
      balance: r'$8,750',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleClients = showAll ? _clients : _clients.take(3).toList();
    final cards = [
      for (final client in visibleClients)
        _ClientCard(
          name: client.name,
          status: client.status,
          statusType: client.statusType,
          cutDate: client.cutDate,
          credit: client.credit,
          balance: client.balance,
          onTap: () => onClientTap(client.name),
        ),
    ];

    if (layout.isMobile) {
      return Column(
        children: [
          for (var index = 0; index < cards.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            cards[index],
          ],
        ],
      );
    }

    return GridView.count(
      crossAxisCount: layout.isDesktop ? 3 : 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: layout.isDesktop ? 1.55 : 1.65,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }
}

enum _ClientStatusType { ok, warning, danger }

class _ClientCard extends StatelessWidget {
  final String name;
  final String status;
  final _ClientStatusType statusType;
  final String cutDate;
  final String credit;
  final String balance;
  final VoidCallback onTap;

  const _ClientCard({
    required this.name,
    required this.status,
    required this.statusType,
    required this.cutDate,
    required this.credit,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .94),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .14),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF173144),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _StatusBadge(label: status, statusType: statusType),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ClientData(label: 'Corte', value: cutDate),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ClientData(label: 'Credito', value: credit),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ClientData(label: 'Saldo', value: balance),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final _ClientStatusType statusType;

  const _StatusBadge({required this.label, required this.statusType});

  @override
  Widget build(BuildContext context) {
    final colors = switch (statusType) {
      _ClientStatusType.ok => (
        bg: const Color(0xFFE7F8F0),
        fg: const Color(0xFF1B8A54),
      ),
      _ClientStatusType.warning => (
        bg: const Color(0xFFFFF4D8),
        fg: const Color(0xFF9C6800),
      ),
      _ClientStatusType.danger => (
        bg: const Color(0xFFFFE7E7),
        fg: const Color(0xFFB42318),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.fg,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ClientData extends StatelessWidget {
  final String label;
  final String value;

  const _ClientData({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF667783),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF173144),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
