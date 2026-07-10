import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool _alreadyNavigated = false;
  bool _googleLoginStarted = false;
  GoogleLoginStatus? _dialogStatus;

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
    return _alreadyNavigated ? const SizedBox.shrink() : _buildAuth();
  }

  Widget _buildAuth() {
    return Consumer<AuthViewModel>(
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
            } else if (!_googleLoginStarted &&
                !viewModel.isLoading &&
                viewModel.googleLoginStatus == GoogleLoginStatus.idle &&
                !_alreadyNavigated) {
              _googleLoginStarted = true;
              Future.microtask(() {
                viewModel.signInWithGoogle();
              });
            }

            if (_mustShowRecovery(viewModel.googleLoginStatus) &&
                _dialogStatus != viewModel.googleLoginStatus) {
              _dialogStatus = viewModel.googleLoginStatus;
              Future.microtask(() {
                if (!mounted) return;
                _showGoogleLoginDialog(viewModel);
              });
            }

            return const _GoogleLoginProgress();
          },
        );
      },
    );
  }

  bool _mustShowRecovery(GoogleLoginStatus status) {
    return status == GoogleLoginStatus.popupBlocked ||
        status == GoogleLoginStatus.popupClosed ||
        status == GoogleLoginStatus.cancelled ||
        status == GoogleLoginStatus.error;
  }

  Future<void> _showGoogleLoginDialog(AuthViewModel viewModel) async {
    final navigator = Navigator.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _GoogleLoginDialog(
          status: viewModel.googleLoginStatus,
          message: viewModel.googleLoginErrorMessage,
          errorCode: viewModel.googleLoginErrorCode,
          onRetry: () {
            Navigator.of(dialogContext).pop();
            _dialogStatus = null;
            viewModel.signInWithGoogle();
          },
          onBack: () {
            Navigator.of(dialogContext).pop();
            navigator.maybePop();
          },
        );
      },
    );
  }
}

class _GoogleLoginProgress extends StatelessWidget {
  const _GoogleLoginProgress();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: ModalBarrier(
              color: Colors.black.withValues(alpha: 0.08),
              dismissible: false,
            ),
          ),
          Center(child: CircularProgressIndicator(color: theme.primaryColor)),
        ],
      ),
    );
  }
}

class _GoogleLoginDialog extends StatelessWidget {
  final GoogleLoginStatus status;
  final String? message;
  final String? errorCode;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _GoogleLoginDialog({
    required this.status,
    required this.message,
    required this.errorCode,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        Icons.open_in_new_off_rounded,
        size: 42,
        color: theme.primaryColor,
      ),
      title: Text(_title, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message ??
                'No se pudo abrir el ingreso con Google. Intenta nuevamente.',
            textAlign: TextAlign.center,
          ),
          if (errorCode != null && errorCode!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              errorCode!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(onPressed: onBack, child: const Text('Volver')),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Reintentar'),
        ),
      ],
    );
  }

  String get _title {
    return switch (status) {
      GoogleLoginStatus.popupBlocked => 'Ventana emergente bloqueada',
      GoogleLoginStatus.popupClosed => 'Ingreso cancelado',
      GoogleLoginStatus.cancelled => 'Ingreso en proceso',
      GoogleLoginStatus.error => 'No se pudo ingresar',
      _ => 'Ingreso con Google',
    };
  }
}
