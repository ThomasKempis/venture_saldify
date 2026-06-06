import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxAuth/AuthRepository.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxAuth/AuthService.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxAuth/AuthViewModel.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxLogonMovil_controller.dart';

class SmxLogonMovil extends StatefulWidget {
  const SmxLogonMovil({super.key});

  @override
  State<SmxLogonMovil> createState() => _SmxLogonMovilState();
}

class _SmxLogonMovilState extends State<SmxLogonMovil> {
  late final SmxLogonMovil_controller controller;
  bool navigated = false;

  @override
  void initState() {
    super.initState();
    controller = SmxLogonMovil_controller();
    controller.checkPermissionLocation();
    controller.checkPermissionCamara();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        ProxyProvider<AuthRepository, AuthService>(
          update: (_, repo, __) => FirebaseAuthService(repo),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) =>
              AuthViewModel(Provider.of<AuthService>(context, listen: false)),
        ),
      ],
      child: _LogonFrontEndBody(controller: controller),
    );
  }
}

class _LogonFrontEndBody extends StatefulWidget {
  final SmxLogonMovil_controller controller;

  const _LogonFrontEndBody({required this.controller});

  @override
  State<_LogonFrontEndBody> createState() => _LogonFrontEndBodyState();
}

class _LogonFrontEndBodyState extends State<_LogonFrontEndBody> {
  static const _loginGradient = SmxGradients.saldifyBackground;

  String _version = '';
  bool _alreadyNavigated = false; // ⬅️ bandera

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  Future<void> _getVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.isUserLoggedIn() && !_alreadyNavigated) {
      _alreadyNavigated = true;

      // Diferir la navegación para evitar errores en build
      Future.microtask(() {
        widget.controller.navigateToAppMovil(context);
      });

      // Mientras se redirige, devolver algo temporal
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: _loginGradient),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      );
    }

    // Si no está logueado, mostrar la pantalla de autenticación
    return _alreadyNavigated
        ? SizedBox.shrink()
        : Scaffold(
            backgroundColor: Colors.transparent,
            body: SizedBox.expand(
              child: DecoratedBox(
                decoration: const BoxDecoration(gradient: _loginGradient),
                child: _buildAuth(),
              ),
            ),
          );
  }

  Widget _buildAuth() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Consumer<AuthViewModel>(
              builder: (context, viewModel, _) {
                return StreamBuilder<User?>(
                  stream: viewModel.authStateChanges,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Colors.white,
                      );
                    }

                    if (snapshot.hasData && snapshot.data != null) {
                      final user = snapshot.data!;
                      Future.microtask(() async {
                        await widget.controller.saveCredentials(user);

                        if (!mounted) return;

                        widget.controller.navigateToAppMovil(context);
                      });

                      return const SizedBox.shrink();
                    }

                    // No está logueado, mostrar botón login
                    return _buildLoginButton(viewModel);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(AuthViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 430;
        final logoWidth = isCompact ? 210.0 : 260.0;
        final titleSize = isCompact ? 48.0 : 60.0;
        final buttonHeight = isCompact ? 58.0 : 64.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SizedBox(
                  width: logoWidth,
                  height: logoWidth / 1.5,
                  child: Image.asset(
                    'assets/images/logo_logon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'SALDIFY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Segoe UI',
                  fontFamilyFallback: ['Tahoma', 'Geneva', 'Verdana', 'Arial'],
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'SMART BALANCE & CREDITS CONTROL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SmxColors.brandAccent,
                  fontFamily: 'Segoe UI',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: isCompact ? 58 : 84),
              const Text(
                'Inicia sesión con tu cuenta de Google',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),
              if (viewModel.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else ...[
                _SaldifyLoginButton(
                  height: buttonHeight,
                  label: 'Continuar con Google',
                  icon: Icons.login_rounded,
                  onPressed: viewModel.signInWithGoogle,
                ),
                const SizedBox(height: 16),
                _SaldifyLoginButton(
                  height: buttonHeight,
                  label: 'Usar otra cuenta de Google',
                  icon: Icons.switch_account_rounded,
                  onPressed: () async {
                    await viewModel.signOut();
                    await viewModel.signInWithGoogle();
                  },
                ),
              ],
              const SizedBox(height: 44),
              Center(
                child: Text(
                  'Ver. $_version',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (viewModel.isLoading)
                const Text(
                  'Redirigiendo a Google...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SaldifyLoginButton extends StatelessWidget {
  final double height;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SaldifyLoginButton({
    required this.height,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Material(
      elevation: 10,
      shadowColor: SmxColors.blackAlpha(.32),
      color: SmxColors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [SmxColors.brandAccent, SmxColors.brandSecondary],
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: SmxColors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: SmxColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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
