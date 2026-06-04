import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxPerfil/smxPerfil.dart';
import 'smxLogonMovil_controller.dart';

class SmxVentureMovil extends StatefulWidget {
  final SmxLogonMovil_controller controllerMain;

  const SmxVentureMovil({super.key, required this.controllerMain});

  @override
  State<SmxVentureMovil> createState() => _SmxVentureMovilState();
}

class _SmxVentureMovilState extends State<SmxVentureMovil> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final adminName = _getAdminName();

    return Scaffold(
      drawer: _SaldifyDrawer(
        selectedIndex: _selectedIndex,
        onSelect: _selectPage,
      ),
      body: _selectedIndex == 0
          ? _SaldifyDashboard(adminName: adminName)
          : _PerfilPage(
              controllerMain: widget.controllerMain,
              onNavigateToHome: () => _selectPage(0),
            ),
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

class _SaldifyDashboard extends StatelessWidget {
  final String adminName;

  const _SaldifyDashboard({required this.adminName});

  static const _backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: _backgroundGradient),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed([
                      const _SaldifyHeader(),
                      const SizedBox(height: 26),
                      Text(
                        'Hola, $adminName',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tu red de vendedores al dia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          height: 1.04,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const _MetricsGrid(),
                      const SizedBox(height: 16),
                      const _InviteSellerCard(),
                      const SizedBox(height: 24),
                      const _SectionHeader(
                        title: 'Acciones rapidas',
                        trailing: 'Corte: 15 Jun',
                      ),
                      const SizedBox(height: 12),
                      const _QuickActions(),
                      const SizedBox(height: 26),
                      const _SectionHeader(
                        title: 'Vendedores',
                        trailing: 'Ver todos',
                      ),
                      const SizedBox(height: 12),
                      const _SellerCard(
                        name: 'Maria Lopez',
                        status: 'Al dia',
                        statusType: _SellerStatusType.ok,
                        cutDate: '15 Jun',
                        credit: r'$18,000',
                        balance: r'$4,800',
                      ),
                      const SizedBox(height: 12),
                      const _SellerCard(
                        name: 'Carlos Rivera',
                        status: 'Por vencer',
                        statusType: _SellerStatusType.warning,
                        cutDate: '06 Jun',
                        credit: r'$12,500',
                        balance: r'$7,100',
                      ),
                      const SizedBox(height: 12),
                      const _SellerCard(
                        name: 'Ana Torres',
                        status: 'Vencido',
                        statusType: _SellerStatusType.danger,
                        cutDate: '31 May',
                        credit: r'$20,000',
                        balance: r'$11,200',
                      ),
                    ]),
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

class _PerfilPage extends StatelessWidget {
  final SmxLogonMovil_controller controllerMain;
  final VoidCallback onNavigateToHome;

  const _PerfilPage({
    required this.controllerMain,
    required this.onNavigateToHome,
  });

  static const _backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: _backgroundGradient),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _SaldifyHeader(title: 'Perfil'),
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
    );
  }
}

class _SaldifyHeader extends StatelessWidget {
  final String? title;

  const _SaldifyHeader({this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (context) =>
              _MenuButton(onPressed: () => Scaffold.of(context).openDrawer()),
        ),
        const SizedBox(width: 14),
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
              label: 'Vendedores',
            ),
            const _DisabledDrawerItem(
              icon: Icons.qr_code_2_rounded,
              label: 'Invitar vendedores',
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
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Total vendido',
                value: r'$184,250',
                note: '+12% este corte',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Credito entregado',
                value: r'$96,000',
                note: '8 vendedores',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Pagos recibidos',
                value: r'$42,780',
                note: '18 movimientos',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Saldo pendiente',
                value: r'$53,220',
                note: '3 por vencer',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String note;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
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
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 10),
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
    );
  }
}

class _InviteSellerCard extends StatelessWidget {
  const _InviteSellerCard();

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invita vendedores',
                  style: TextStyle(
                    color: Color(0xFF173144),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Comparte tu QR o link. Todo vendedor que se registre entra a tu negocio y queda pendiente de aprobacion.',
                  style: TextStyle(
                    color: Color(0xFF667783),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    _InvitePill(label: 'Copiar link', filled: true),
                    SizedBox(width: 8),
                    _InvitePill(label: 'WhatsApp'),
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

  const _InvitePill({required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFF0D47A1) : const Color(0xFFE8F5F0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: filled ? Colors.white : const Color(0xFF1B5E20),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({required this.title, required this.trailing});

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
        Text(
          trailing,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _QuickActionCard(icon: Icons.add_rounded, label: 'Vendedor'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.attach_money_rounded,
            label: 'Pago',
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.north_east_rounded,
            label: 'Credito',
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickActionCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
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
    );
  }
}

enum _SellerStatusType { ok, warning, danger }

class _SellerCard extends StatelessWidget {
  final String name;
  final String status;
  final _SellerStatusType statusType;
  final String cutDate;
  final String credit;
  final String balance;

  const _SellerCard({
    required this.name,
    required this.status,
    required this.statusType,
    required this.cutDate,
    required this.credit,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
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
                child: _SellerData(label: 'Corte', value: cutDate),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SellerData(label: 'Credito', value: credit),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SellerData(label: 'Saldo', value: balance),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final _SellerStatusType statusType;

  const _StatusBadge({required this.label, required this.statusType});

  @override
  Widget build(BuildContext context) {
    final colors = switch (statusType) {
      _SellerStatusType.ok => (
        bg: const Color(0xFFE7F8F0),
        fg: const Color(0xFF1B8A54),
      ),
      _SellerStatusType.warning => (
        bg: const Color(0xFFFFF4D8),
        fg: const Color(0xFF9C6800),
      ),
      _SellerStatusType.danger => (
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

class _SellerData extends StatelessWidget {
  final String label;
  final String value;

  const _SellerData({required this.label, required this.value});

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
