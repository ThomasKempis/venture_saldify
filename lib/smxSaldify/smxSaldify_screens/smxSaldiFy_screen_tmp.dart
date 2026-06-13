import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout.dart';

class SmxSaldiFyScreenTmp extends StatelessWidget {
  final String title;
  final String mensaje;
  final bool btoBack;

  const SmxSaldiFyScreenTmp({
    super.key,
    required this.title,
    this.mensaje =
        'Este modulo esta preparado para conectar su controller y flujo operativo.',
    this.btoBack = true,
  });

  static const _backgroundGradient = SmxGradients.saldifyBackground;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = SmxLayout.sizeFromWidth(constraints.maxWidth);
        final pagePadding = layout.pagePadding;
        final topContentInset = SmxLayout.topContentInset(context);
        final bottomContentInset = SmxLayout.bottomContentInset(context);

        return Scaffold(
          backgroundColor: SmxColors.transparent,
          body: SizedBox.expand(
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: _backgroundGradient),
              child: SafeArea(
                top: false,
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: layout.maxContentWidth,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            pagePadding.left,
                            pagePadding.top + topContentInset,
                            pagePadding.right,
                            0,
                          ),
                          child: Row(
                            children: [
                              if (btoBack)
                                _BackButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: SmxColors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  28,
                                  28,
                                  28,
                                  28 + bottomContentInset,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'Sistema en construccion',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: SmxColors.white,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        height: 1.05,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      mensaje,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: SmxColors.brandAccent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

extension _ScreenTmpLayoutValues on SmxLayoutSize {
  double get maxContentWidth => switch (this) {
    SmxLayoutSize.mobile => 460,
    SmxLayoutSize.tablet => 860,
    SmxLayoutSize.desktop => 1180,
  };

  EdgeInsets get pagePadding => switch (this) {
    SmxLayoutSize.mobile => const EdgeInsets.fromLTRB(20, 20, 20, 28),
    SmxLayoutSize.tablet => const EdgeInsets.fromLTRB(28, 28, 28, 34),
    SmxLayoutSize.desktop => const EdgeInsets.fromLTRB(36, 34, 36, 40),
  };
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: SmxColors.whiteAlpha(0.14),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: const Icon(Icons.arrow_back_rounded, color: SmxColors.white),
        ),
      ),
    );
  }
}
