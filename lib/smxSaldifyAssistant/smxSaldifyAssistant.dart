import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/assistant_body_bg.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/assistant_header_bg.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import '../smxApis/smxConfig.dart';
import 'smxSaldifyAssistant_context.dart';
import 'smxSaldifyAssistant_controller.dart';
import 'smxSaldifyAssistant_screen_mock.dart';

class SmxSaldifyAssistantHost extends StatelessWidget {
  final Widget child;
  final SmxSaldifyAssistantRole role;
  final SmxSaldifyAssistantScreen screen;
  final bool isMobile;

  const SmxSaldifyAssistantHost({
    super.key,
    required this.child,
    required this.role,
    required this.screen,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldifyAssistantController>(
      controllerBuilder: (context) => SmxSaldifyAssistantController(
        alias: 'SMXSALDIFY_ASSISTANT',
        data: SmxControllerSendData(context: context),
      ),
      loadingBuilder: (_) => child,
      builder: (context, controller) => _AssistantSurface(
        controller: controller,
        role: role,
        screen: screen,
        isMobile: isMobile,
        child: child,
      ),
    );
  }
}

class _AssistantSurface extends StatelessWidget {
  final SmxSaldifyAssistantController controller;
  final Widget child;
  final SmxSaldifyAssistantRole role;
  final SmxSaldifyAssistantScreen screen;
  final bool isMobile;

  const _AssistantSurface({
    required this.controller,
    required this.child,
    required this.role,
    required this.screen,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = SmxLayout.bottomContentInset(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          left: isMobile ? 16 : 24,
          bottom: bottomInset + (isMobile ? 18 : 24),
          child: _AssistantLauncher(
            isMobile: isMobile,
            onPressed: () => _openAssistant(context),
          ),
        ),
      ],
    );
  }

  void _openAssistant(BuildContext context) {
    if (isMobile) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: SmxColors.transparent,
        builder: (sheetContext) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: _AssistantPanel(
            controller: controller,
            role: role,
            screen: screen,
            isMobile: true,
            onClose: () => Navigator.of(sheetContext).pop(),
          ),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierColor: SmxColors.blackAlpha(.42),
      builder: (dialogContext) => Dialog(
        backgroundColor: SmxColors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
          child: _AssistantPanel(
            controller: controller,
            role: role,
            screen: screen,
            isMobile: false,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
        ),
      ),
    );
  }
}

class _AssistantLauncher extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onPressed;

  const _AssistantLauncher({required this.isMobile, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final size = isMobile ? 58.0 : 62.0;

    return Tooltip(
      message: 'Ayuda ${SmxConfig.titulo}',
      child: Material(
        color: SmxColors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: SmxColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: SmxColors.blackAlpha(.24),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: SmxColors.brandPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

class _AssistantPanel extends StatefulWidget {
  final SmxSaldifyAssistantController controller;
  final SmxSaldifyAssistantRole role;
  final SmxSaldifyAssistantScreen screen;
  final bool isMobile;
  final VoidCallback onClose;

  const _AssistantPanel({
    required this.controller,
    required this.role,
    required this.screen,
    required this.isMobile,
    required this.onClose,
  });

  @override
  State<_AssistantPanel> createState() => _AssistantPanelState();
}

class _AssistantPanelState extends State<_AssistantPanel> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panelRadius = BorderRadius.vertical(
      top: const Radius.circular(22),
      bottom: Radius.circular(widget.isMobile ? 0 : 22),
    );

    return Material(
      color: SmxColors.transparent,
      child: Container(
        height: widget.isMobile
            ? MediaQuery.sizeOf(context).height * .82
            : null,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFC),
          borderRadius: panelRadius,
          boxShadow: [
            BoxShadow(
              color: SmxColors.blackAlpha(.22),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _AssistantHeader(
              role: widget.role,
              screen: widget.screen,
              onClose: widget.onClose,
              onClear: widget.controller.clear,
            ),
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(child: AssistantBodyBg()),
                  ValueListenableBuilder<List<SmxSaldifyAssistantMessage>>(
                    valueListenable: widget.controller.messagesNotifier,
                    builder: (context, messages, _) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_scrollController.hasClients) return;
                        _scrollController.animateTo(
                          _scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOut,
                        );
                      });

                      return ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        itemBuilder: (context, index) {
                          return _AssistantBubble(message: messages[index]);
                        },
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemCount: messages.length,
                      );
                    },
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: widget.controller.sendingNotifier,
              builder: (context, isSending, _) {
                return Column(
                  children: [
                    _AssistantSuggestions(
                      screen: widget.screen,
                      onSelect: _sendSuggestion,
                    ),
                    _AssistantInput(
                      controller: _textController,
                      isSending: isSending,
                      onSend: _sendCurrentText,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendSuggestion(String text) {
    _textController.text = text;
    _sendCurrentText();
  }

  void _sendCurrentText() {
    final text = _textController.text;
    _textController.clear();

    widget.controller.send(
      question: text,
      role: widget.role,
      screen: widget.screen,
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  final SmxSaldifyAssistantRole role;
  final SmxSaldifyAssistantScreen screen;
  final VoidCallback onClose;
  final VoidCallback onClear;

  const _AssistantHeader({
    required this.role,
    required this.screen,
    required this.onClose,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: SmxGradients.saldifyBackground),
      child: Stack(
        children: [
          const Positioned.fill(child: AssistantHeaderBg()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: SmxColors.whiteAlpha(.16),
                    shape: BoxShape.circle,
                    border: Border.all(color: SmxColors.whiteAlpha(.22)),
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: SmxColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asistente ${SmxConfig.titulo}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: SmxColors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${role.label} - ${screen.label}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SmxColors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Limpiar',
                  child: IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.refresh_rounded),
                    color: SmxColors.white,
                  ),
                ),
                Tooltip(
                  message: 'Cerrar',
                  child: IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                    color: SmxColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  final SmxSaldifyAssistantMessage message;

  const _AssistantBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final alignment = message.isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final color = message.isUser ? SmxColors.brandPrimary : SmxColors.white;
    final textColor = message.isUser ? SmxColors.white : SmxColors.textDark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: alignment,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * .78),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  border: message.isUser
                      ? null
                      : Border.all(color: const Color(0xFFE4EDF1)),
                  boxShadow: [
                    BoxShadow(
                      color: SmxColors.blackAlpha(.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isLoading) ...[
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: SmxColors.brandPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            height: 1.32,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

class _AssistantSuggestions extends StatelessWidget {
  final SmxSaldifyAssistantScreen screen;
  final ValueChanged<String> onSelect;

  const _AssistantSuggestions({required this.screen, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final suggestions = SmxSaldifyAssistantScreenMock.questionsFor(screen);

    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final text = suggestions[index];

          return ActionChip(
            onPressed: () => onSelect(text),
            avatar: const Icon(Icons.help_outline_rounded, size: 16),
            label: Text(text),
            labelStyle: const TextStyle(
              color: SmxColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            backgroundColor: SmxColors.surfacePill,
            side: BorderSide(
              color: SmxColors.brandAccent.withValues(alpha: .3),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: suggestions.length,
      ),
    );
  }
}

class _AssistantInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _AssistantInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Pregunta sobre ${SmxConfig.titulo}',
                  filled: true,
                  fillColor: SmxColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFDDE8EC)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Color(0xFFDDE8EC)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: SmxColors.brandPrimary,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: 'Enviar',
              child: IconButton.filled(
                onPressed: isSending ? null : onSend,
                icon: const Icon(Icons.send_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: SmxColors.brandPrimary,
                  foregroundColor: SmxColors.white,
                  disabledBackgroundColor: SmxColors.textMuted,
                  fixedSize: const Size(48, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
