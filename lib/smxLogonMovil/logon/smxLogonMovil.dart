import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
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
  static const _loginGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
  );

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
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: _loginGradient),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    // Si no está logueado, mostrar la pantalla de autenticación
    return _alreadyNavigated
        ? SizedBox.shrink()
        : Scaffold(
            body: DecoratedBox(
              decoration: const BoxDecoration(gradient: _loginGradient),
              child: _buildAuth(),
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
                  color: Color(0xFF58D9A4),
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
                SizedBox(
                  height: buttonHeight,
                  child: SignInButton(
                    Buttons.Google,
                    text: "Continuar con Google",
                    onPressed: viewModel.signInWithGoogle,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: buttonHeight,
                  child: SignInButton(
                    Buttons.Google,
                    text: "Usar otra cuenta de Google",
                    onPressed: () async {
                      await viewModel
                          .signOut(); // <-- Este método debe llamar a googleSignIn.signOut()
                      await viewModel.signInWithGoogle();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
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
