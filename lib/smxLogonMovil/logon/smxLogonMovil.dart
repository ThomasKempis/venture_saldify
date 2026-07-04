import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
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
    //controller.checkPermissionCamara();
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
  String _version = '';
  bool _alreadyNavigated = false; // ⬅️ bandera

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  Future<void> _getVersion() async {
    final info = await widget.controller.infoUser.getVersion();
    setState(() {
      _version = info;
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

      return const SizedBox.shrink();
    }

    // Si no está logueado, ejecutamos la lógica en segundo plano
    return _alreadyNavigated
        ? const SizedBox.shrink()
        : _buildAuth();
  }

  Widget _buildAuth() {
    return Center(
      child: Consumer<AuthViewModel>(
        builder: (context, viewModel, _) {
          return StreamBuilder<User?>(
            stream: viewModel.authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final user = snapshot.data!;
                if (!_alreadyNavigated) {
                  _alreadyNavigated = true;
                  Future.microtask(() async {
                    await widget.controller.saveCredentials(user);
                    if (!mounted) return;
                    widget.controller.navigateToAppMovil(context);
                  });
                }
              } else if (!viewModel.isLoading && !_alreadyNavigated) {
                // No hay sesión activa y no está en proceso de carga: disparar Google automáticamente
                Future.microtask(() {
                  viewModel.signInWithGoogle();
                });
              }

              // Esta pantalla es invisible
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
