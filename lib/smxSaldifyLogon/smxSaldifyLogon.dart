import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venture_saldify/smxApis/smxConfig.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxApis/smxDepth.dart';
import 'package:venture_saldify/smxAuth/smxAuth.dart';
import 'package:venture_saldify/smxAuth/smxLogonMovil.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxSaldifyAssistant/smxSaldifyAssistant.dart';
import 'package:venture_saldify/smxSaldifyAssistant/smxSaldifyAssistant_context.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/logon_access_bg.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldifyAccessSession.dart';
import 'smxSaldifyLogon_controller.dart';

class SmxSaldifyLogon extends StatelessWidget {
  static const welcomeAsset = SmxSaldifyLogonController.welcomeAsset;
  static const welcomeAssetHd = SmxSaldifyLogonController.welcomeAssetHd;

  static Future<void> warmUpAssets() =>
      SmxSaldifyLogonController.warmUpAssets();

  final VoidCallback? onAnfitrionTap;
  final VoidCallback? onInvitadoTap;
  final ValueChanged<String>? onInvitadoCodigoTap;
  final String codigoInicial;

  const SmxSaldifyLogon({
    super.key,
    this.onAnfitrionTap,
    this.onInvitadoTap,
    this.onInvitadoCodigoTap,
    this.codigoInicial = '',
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldifyLogonController>(
      controllerBuilder: (context) => SmxSaldifyLogonController(
        alias: 'SMXSALDIFY_LOGON',
        data: SmxControllerSendData(context: context),
        codigoInicial: codigoInicial,
      ),
      loadingBuilder: (_) => const _SmxSaldifyLogonLoading(),
      builder: (context, controller) => _SmxSaldifyLogonBody(
        controller: controller,
        onAnfitrionTap: onAnfitrionTap,
        onInvitadoTap: onInvitadoTap,
        onInvitadoCodigoTap: onInvitadoCodigoTap,
      ),
    );
  }
}

class _SmxSaldifyLogonBody extends StatefulWidget {
  final SmxSaldifyLogonController controller;
  final VoidCallback? onAnfitrionTap;
  final VoidCallback? onInvitadoTap;
  final ValueChanged<String>? onInvitadoCodigoTap;

  const _SmxSaldifyLogonBody({
    required this.controller,
    required this.onAnfitrionTap,
    required this.onInvitadoTap,
    required this.onInvitadoCodigoTap,
  });

  @override
  State<_SmxSaldifyLogonBody> createState() => _SmxSaldifyLogonBodyState();
}

class _SmxSaldifyLogonBodyState extends State<_SmxSaldifyLogonBody> {
  late final SmxAuth _auth;
  bool _forceNextAuthAccountSelection = false;
  bool _forceNextAnfitrionAccountSelection = false;

  @override
  void initState() {
    super.initState();
    _auth = SmxAuth()..addListener(_onAuthChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(_SmxSaldifyLogonBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;

    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.precacheAssets(context);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _auth.dispose();
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _authenticate(
    SmxAuthProvider provider,
    SmxSaldifyAccessMode accessMode,
    Future<void> Function(SmxAuthUser user) onAuthenticated, {
    bool forceAccountSelection = false,
  }) async {
    _auth.resetStatus();
    if (_auth.isLoading) return;

    final shouldForceAccountSelection =
        forceAccountSelection ||
        _forceNextAuthAccountSelection ||
        SmxSaldifyAccessSession.ultimoModo != null &&
            SmxSaldifyAccessSession.ultimoModo != accessMode;

    final user = await _auth.signIn(
      provider,
      forceAccountSelection: shouldForceAccountSelection,
    );
    if (!mounted) return;

    if (user == null) {
      _auth.resetStatus();
      return;
    }

    await onAuthenticated(user);
  }

  Future<void> _continueToApp(SmxAuthUser user) async {
    final controller = SmxLogonMovil(authUser: user);
    await controller.navigateToAppMovil(context);
  }

  void _onCodigoInvitadoTap() {
    final codigo = widget.controller.validarFormatoCodigo();
    if (codigo == null) return;

    _authenticate(SmxAuthProvider.google, SmxSaldifyAccessMode.invitado, (
      user,
    ) async {
      final logonController = SmxLogonMovil(authUser: user);
      await logonController.prepareUser(context);
      if (!mounted) return;

      final validado = await widget.controller.validarCodigoAutenticado(
        codigo,
        user.email,
        uuidUsuario: logonController.getUuid(),
      );
      if (!validado || !mounted) {
        _forceNextAuthAccountSelection = true;
        return;
      }

      _forceNextAuthAccountSelection = false;

      if (widget.onInvitadoCodigoTap != null) {
        widget.onInvitadoCodigoTap!(codigo);
        return;
      }

      await logonController.navigatePreparedUser(context);
    });
  }

  void _onInvitadoTap() {
    if (!widget.controller.cargarInvitadoGuardado(context)) return;

    _authenticate(SmxAuthProvider.google, SmxSaldifyAccessMode.invitado, (
      user,
    ) async {
      _forceNextAuthAccountSelection = false;

      if (widget.onInvitadoTap != null) {
        widget.onInvitadoTap!();
        return;
      }

      await _continueToApp(user);
    });
  }

  void _onAnfitrionTap() {
    _authenticate(
      SmxAuthProvider.google,
      SmxSaldifyAccessMode.anfitrion,
      (user) async {
        SmxConstants.clearClienteInvitado();

        _forceNextAuthAccountSelection = false;
        _forceNextAnfitrionAccountSelection = false;

        if (widget.onAnfitrionTap != null) {
          widget.onAnfitrionTap!();
          return;
        }

        await _continueToApp(user);
      },
      forceAccountSelection: _forceNextAnfitrionAccountSelection,
    );
  }

  void _onCambiarCuentaAnfitrionTap() {
    setState(() {
      _forceNextAnfitrionAccountSelection =
          !_forceNextAnfitrionAccountSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, rootConstraints) {
        final layout = SmxLayout.sizeFromWidth(rootConstraints.maxWidth);

        return Stack(
          children: [
            SmxSaldifyAssistantHost(
              role: SmxSaldifyAssistantRole.publico,
              screen: SmxSaldifyAssistantScreen.logon,
              isMobile: layout.isMobile,
              child: Scaffold(
                backgroundColor: SmxColors.transparent,
                body: SmxSaldifyBackground(
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 520;
                        final welcomeAsset = widget.controller.getWelcomeAsset(
                          constraints.maxWidth,
                        );
                        final maxWidth = compact ? constraints.maxWidth : 760.0;
                        final horizontalPadding = compact ? 22.0 : 36.0;
                        final topPadding = compact ? 0.0 : 36.0;
                        final bottomPadding = compact ? 24.0 : 36.0;

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeOutCubic,
                          child: widget.controller.contentReady
                              ? SingleChildScrollView(
                                  key: const ValueKey('saldify-logon-content'),
                                  padding: EdgeInsets.fromLTRB(
                                    horizontalPadding,
                                    topPadding,
                                    horizontalPadding,
                                    bottomPadding,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight:
                                          constraints.maxHeight -
                                          MediaQuery.of(
                                            context,
                                          ).padding.vertical -
                                          topPadding -
                                          bottomPadding,
                                    ),
                                    child: Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: maxWidth,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            _SaldifyBrand(compact: compact),
                                            _WelcomeGraphic(
                                              compact: compact,
                                              asset: welcomeAsset,
                                            ),
                                            Transform.translate(
                                              offset: Offset(
                                                0,

                                                ///compact ? -32 : -24,
                                                ///compact ? -54 : -44
                                                compact ? -64 : -54,
                                              ),
                                              child: _WelcomeCard(
                                                compact: compact,
                                                hasCodigoInicialValido: widget
                                                    .controller
                                                    .hasCodigoInicialValido,
                                                codigoController: widget
                                                    .controller
                                                    .codigoController,
                                                codigoError: widget
                                                    .controller
                                                    .codigoError,
                                                onAnfitrionTap: _onAnfitrionTap,
                                                onCambiarCuentaAnfitrionTap:
                                                    _onCambiarCuentaAnfitrionTap,
                                                forceNextAnfitrionAccountSelection:
                                                    _forceNextAnfitrionAccountSelection,
                                                onInvitadoTap: _onInvitadoTap,
                                                onCodigoChanged: widget
                                                    .controller
                                                    .clearCodigoError,
                                                onInvitadoCodigoTap:
                                                    _onCodigoInvitadoTap,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : const Center(
                                  key: ValueKey('saldify-logon-loading'),
                                  child: CircularProgressIndicator(
                                    color: SmxColors.white,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SmxSaldifyLogonLoading extends StatelessWidget {
  const _SmxSaldifyLogonLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: SmxColors.transparent,
      body: SmxSaldifyBackground(
        child: Center(child: CircularProgressIndicator(color: SmxColors.white)),
      ),
    );
  }
}

class _SaldifyBrand extends StatelessWidget {
  final bool compact;

  const _SaldifyBrand({required this.compact});

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 78.0 : 96.0;
    final logoWidth = logoSize * 266 / 386;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, compact ? 5 : 5),
          child: SizedBox(
            width: logoWidth,
            height: logoSize,
            child: SmxConfig.logo(fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              SmxConfig.titulo.toUpperCase(),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: SmxColors.white,
                fontFamily: 'Segoe UI',
                fontFamilyFallback: const [
                  'Tahoma',
                  'Geneva',
                  'Verdana',
                  'Arial',
                ],
                fontSize: compact ? 38 : 48,
                fontWeight: FontWeight.w800,
                height: .98,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              SmxConfig.descripcion,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: SmxColors.brandDescription,
                fontFamily: 'Segoe UI',
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WelcomeGraphic extends StatelessWidget {
  final bool compact;
  final String asset;

  const _WelcomeGraphic({required this.compact, required this.asset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 238 : 286,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final bool compact;
  final bool hasCodigoInicialValido;
  final TextEditingController codigoController;
  final String? codigoError;
  final VoidCallback? onAnfitrionTap;
  final VoidCallback onCambiarCuentaAnfitrionTap;
  final bool forceNextAnfitrionAccountSelection;
  final VoidCallback? onInvitadoTap;
  final VoidCallback onCodigoChanged;
  final VoidCallback onInvitadoCodigoTap;

  const _WelcomeCard({
    required this.compact,
    required this.hasCodigoInicialValido,
    required this.codigoController,
    required this.codigoError,
    required this.onAnfitrionTap,
    required this.onCambiarCuentaAnfitrionTap,
    required this.forceNextAnfitrionAccountSelection,
    required this.onInvitadoTap,
    required this.onCodigoChanged,
    required this.onInvitadoCodigoTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 24.0 : 32.0;
    final mainCard = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.18),
            blurRadius: compact ? 24 : 30,
            offset: Offset(0, compact ? 14 : 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 24,
                compact ? 18 : 24,
                compact ? 16 : 24,
                compact ? 14 : 18,
              ),
              decoration: BoxDecoration(
                color: SmxColors.whiteAlpha(.68),
                border: Border(
                  bottom: BorderSide(
                    color: SmxColors.whiteAlpha(.46),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: compact
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Bienvenido',
                          textAlign: compact
                              ? TextAlign.left
                              : TextAlign.center,
                          style: TextStyle(
                            color: SmxColors.textDark,
                            fontSize: compact ? 27 : 36,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: compact ? 8 : 10),
                        Text(
                          'Elige cómo quieres ingresar a ${SmxConfig.titulo}.',
                          textAlign: compact
                              ? TextAlign.left
                              : TextAlign.center,
                          style: TextStyle(
                            color: SmxColors.textMuted,
                            fontSize: compact ? 14 : 17,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 12),
                  _InfoButton(
                    onTap: () => _showAccessInfo(
                      context,
                      hasCodigoInicialValido: hasCodigoInicialValido,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: SmxColors.whiteAlpha(.96),
              child: Stack(
                children: [
                  const Positioned.fill(child: LogonAccessBg()),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 16 : 24,
                      compact ? 16 : 22,
                      compact ? 16 : 24,
                      compact ? 16 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (hasCodigoInicialValido) ...[
                          _InvitadoOptionCard(
                            compact: compact,
                            hasCodigoInicialValido: hasCodigoInicialValido,
                            codigoController: codigoController,
                            codigoError: codigoError,
                            onCodigoChanged: onCodigoChanged,
                            onInvitadoCodigoTap: onInvitadoCodigoTap,
                          ),
                        ] else ...[
                          _AccessOptionCard(
                            compact: compact,
                            icon: Icons.storefront_rounded,
                            title: 'Anfitrión (Empresa)',
                            subtitle: 'Gestiona créditos y clientes',
                            accentColor: SmxColors.successForeground,
                            backgroundColor: compact
                                ? SmxColors.white
                                : const Color(0xFFEAF8F0),
                            borderColor: const Color(0xFFC7E9D9),
                            onTap: onAnfitrionTap,
                          ),
                          SizedBox(height: compact ? 8 : 10),
                          _ChangeHostAccountAction(
                            compact: compact,
                            active: forceNextAnfitrionAccountSelection,
                            enabled: true,
                            onTap: onCambiarCuentaAnfitrionTap,
                          ),
                          SizedBox(height: compact ? 12 : 14),
                          _AccessOptionCard(
                            compact: compact,
                            icon: Icons.person_pin_circle_rounded,
                            title: 'Invitado (Cliente)',
                            subtitle:
                                'Ingresa con el ultimo link de invitacion validado',
                            accentColor: const Color(0xFF1454B8),
                            backgroundColor: compact
                                ? SmxColors.white
                                : const Color(0xFFF5FBFF),
                            borderColor: const Color(0xFFCFE0F6),
                            onTap: onInvitadoTap,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final card = SmxDepth(
      radius: radius,
      depth: compact ? 5 : 6,
      opacity: .24,
      blurRadius: compact ? 10 : 12,
      fade: true,
      child: mainCard,
    );

    if (!compact) return card;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: card,
    );
  }

  void _showAccessInfo(
    BuildContext context, {
    required bool hasCodigoInicialValido,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SmxColors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          _AccessInfoSheet(hasCodigoInicialValido: hasCodigoInicialValido),
    );
  }
}

class _InfoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _InfoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAF4F8),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF14577A),
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _AccessInfoSheet extends StatelessWidget {
  final bool hasCodigoInicialValido;

  const _AccessInfoSheet({required this.hasCodigoInicialValido});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
        decoration: BoxDecoration(
          color: SmxColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: SmxColors.blackAlpha(.18),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E1E8),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF14577A),
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cómo funciona el acceso',
                    style: TextStyle(
                      color: SmxColors.textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasCodigoInicialValido) ...[
              const _AccessInfoItem(
                icon: Icons.confirmation_number_outlined,
                color: Color(0xFF1454B8),
                title: 'Código de invitación',
                text:
                    'Código único para ingresar a la red del Anfitrion cuando recibes un link de invitacion.',
              ),
              const SizedBox(height: 14),
              const _AccessInfoItem(
                icon: Icons.check_circle_outline_rounded,
                color: Color(0xFF1454B8),
                title: 'Validar código',
                text:
                    'Valida el link recibido. Despues podras entrar desde el acceso general como Invitado en este dispositivo.',
              ),
            ] else ...[
              const _AccessInfoItem(
                icon: Icons.storefront_rounded,
                color: SmxColors.successForeground,
                title: 'Anfitrión (Empresa)',
                text:
                    'Ingresa para administrar clientes, creditos, compras y pagos.',
              ),
              const SizedBox(height: 14),
              const _AccessInfoItem(
                icon: Icons.switch_account_rounded,
                color: SmxColors.successForeground,
                title: 'Cambiar cuenta de Anfitrión',
                text:
                    'Activalo solo si administras otra red y necesitas elegir otra cuenta de Anfitrion.',
              ),
              const SizedBox(height: 14),
              const _AccessInfoItem(
                icon: Icons.person_pin_circle_rounded,
                color: Color(0xFF1454B8),
                title: 'Invitado (Cliente)',
                text: 'Ingresas con el ultimo link de invitacion validado.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccessInfoItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String text;

  const _AccessInfoItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 25),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: SmxColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                text,
                style: TextStyle(
                  color: SmxColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccessOptionCard extends StatelessWidget {
  final bool compact;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const _AccessOptionCard({
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
                  _OptionIcon(compact: compact, icon: icon, color: accentColor),
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

class _ChangeHostAccountAction extends StatelessWidget {
  final bool compact;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const _ChangeHostAccountAction({
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
                      ? 'Se elegirá otra cuenta de Anfitrión'
                      : 'Cambiar cuenta de Anfitrión',
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

class _InvitadoOptionCard extends StatelessWidget {
  final bool compact;
  final bool hasCodigoInicialValido;
  final TextEditingController codigoController;
  final String? codigoError;
  final VoidCallback onCodigoChanged;
  final VoidCallback onInvitadoCodigoTap;

  const _InvitadoOptionCard({
    required this.compact,
    required this.hasCodigoInicialValido,
    required this.codigoController,
    required this.codigoError,
    required this.onCodigoChanged,
    required this.onInvitadoCodigoTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBgColor = hasCodigoInicialValido
        ? const Color(0xFFF0F4F7)
        : (compact ? SmxColors.white : const Color(0xFFF5FBFF));
    final cardBorderColor = hasCodigoInicialValido
        ? const Color(0xFFDDE4EB)
        : const Color(0xFFCFE0F6);
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
              TextField(
                controller: codigoController,
                enabled: !hasCodigoInicialValido,
                onChanged: (_) => onCodigoChanged(),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]')),
                  UpperCaseTextFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: 'Código de invitación',
                  errorText: codigoError,
                  filled: true,
                  fillColor: hasCodigoInicialValido
                      ? const Color(0xFFE8EEF2)
                      : SmxColors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: compact ? 12 : 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(compact ? 13 : 16),
                    borderSide: const BorderSide(color: Color(0xFFD1DAE4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(compact ? 13 : 16),
                    borderSide: const BorderSide(color: Color(0xFFD1DAE4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(compact ? 13 : 16),
                    borderSide: const BorderSide(
                      color: Color(0xFF1454B8),
                      width: 1.6,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Color(0xFF1454B8),
                  ),
                ),
                style: TextStyle(
                  color: hasCodigoInicialValido
                      ? SmxColors.textMuted
                      : SmxColors.textDark,
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
                  label: const Text('Validar código'),
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

class _OptionIcon extends StatelessWidget {
  final bool compact;
  final IconData icon;
  final Color color;

  const _OptionIcon({
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
