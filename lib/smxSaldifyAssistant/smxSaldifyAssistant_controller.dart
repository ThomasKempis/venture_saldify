import 'package:flutter/foundation.dart';
import 'package:venture_core_connect/smxJson/smxJsonServicio.dart';
import 'package:venture_core_connect/smxJson/smxJsonUtil.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import '../smxApis/smxConfig.dart';
import 'smxSaldifyAssistant_context.dart';
import 'smxSaldifyAssistant_screen_mock.dart';

class SmxSaldifyAssistantMessage {
  final String text;
  final bool isUser;
  final bool isLoading;
  final DateTime createdAt;

  const SmxSaldifyAssistantMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
    required this.createdAt,
  });
}

class SmxSaldifyAssistantController extends SmxController {
  final ValueNotifier<List<SmxSaldifyAssistantMessage>> messagesNotifier =
      ValueNotifier<List<SmxSaldifyAssistantMessage>>([]);
  final ValueNotifier<bool> sendingNotifier = ValueNotifier<bool>(false);

  SmxSaldifyAssistantController({required super.alias, required super.data});

  List<SmxSaldifyAssistantMessage> get messages => messagesNotifier.value;

  bool get isSending => sendingNotifier.value;

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();
    _resetMessages();
  }

  Future<void> send({
    required String question,
    required SmxSaldifyAssistantRole role,
    required SmxSaldifyAssistantScreen screen,
  }) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || sendingNotifier.value) return;

    messagesNotifier.value = [
      ...messagesNotifier.value,
      SmxSaldifyAssistantMessage(
        text: trimmed,
        isUser: true,
        createdAt: DateTime.now(),
      ),
      SmxSaldifyAssistantMessage(
        text: 'Pensando...',
        isUser: false,
        isLoading: true,
        createdAt: DateTime.now(),
      ),
    ];
    sendingNotifier.value = true;

    final reply = await _requestAssistantReply(
      question: trimmed,
      role: role,
      screen: screen,
    );

    final messagesWithoutLoading = List<SmxSaldifyAssistantMessage>.from(
      messagesNotifier.value,
    )..removeLast();

    messagesNotifier.value = [
      ...messagesWithoutLoading,
      SmxSaldifyAssistantMessage(
        text: reply,
        isUser: false,
        createdAt: DateTime.now(),
      ),
    ];
    sendingNotifier.value = false;
  }

  Future<String> _requestAssistantReply({
    required String question,
    required SmxSaldifyAssistantRole role,
    required SmxSaldifyAssistantScreen screen,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    final suggestedAnswer = SmxSaldifyAssistantScreenMock.answerFor(
      screen: screen,
      question: question,
    );

    if (suggestedAnswer != null) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      return suggestedAnswer;
    }

    return _requestAssistantReplyFromWebService(
      question: question,
      role: role,
      screen: screen,
    );
  }

  Future<String> _requestAssistantReplyFromWebService({
    required String question,
    required SmxSaldifyAssistantRole role,
    required SmxSaldifyAssistantScreen screen,
  }) async {
    final servicio = SmxJsonServicio()
      ..setVariable('ROLE', role.payloadValue, TipoField.STR)
      ..setVariable('SCREEN', screen.payloadValue, TipoField.STR)
      ..setVariable('QUESTION', question, TipoField.STR);

    jsonSend
      ..microServicio = SmxServiciosSaldify.CHATBOT_IA_SALDIFY.name
      ..servicio = servicio;

    try {
      final jsonSendChatbot = await getCallWS();
      final respuesta =
          jsonSendChatbot.servicio?.getValorStr('RESPONSE')?.trim() ?? '';

      if (respuesta.isNotEmpty) return respuesta;
    } catch (_) {}

    return 'No pude obtener respuesta del asistente en este momento. Intenta de nuevo mas tarde.';
  }

  void clear() {
    _resetMessages();
  }

  void _resetMessages() {
    messagesNotifier.value = [
      SmxSaldifyAssistantMessage(
        text:
            'Hola, soy el asistente de ${SmxConfig.titulo}. Estoy aquí para ayudarle sobre la aplicación.',
        isUser: false,
        createdAt: DateTime.now(),
      ),
    ];
    sendingNotifier.value = false;
  }

  @override
  void dispose() {
    messagesNotifier.dispose();
    sendingNotifier.dispose();
    super.dispose();
  }

  @override
  Future<void> save() async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}
}
