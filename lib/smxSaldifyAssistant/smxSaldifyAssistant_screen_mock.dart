import 'smxSaldifyAssistant_context.dart';

class SmxSaldifyAssistantSuggestedQa {
  final String question;
  final String answer;

  const SmxSaldifyAssistantSuggestedQa({
    required this.question,
    required this.answer,
  });
}

class SmxSaldifyAssistantScreenMock {
  const SmxSaldifyAssistantScreenMock._();

  static const List<SmxSaldifyAssistantSuggestedQa> _notConfiguredQuestions = [
    SmxSaldifyAssistantSuggestedQa(
      question: 'Pantalla o funcion aun no configurada',
      answer:
          'Esta pantalla aun no tiene ayuda configurada. Cuando se agregue al asistente, mostrara preguntas propias.',
    ),
  ];

  static const Map<
    SmxSaldifyAssistantScreen,
    List<SmxSaldifyAssistantSuggestedQa>
  >
  _questions = {
    SmxSaldifyAssistantScreen.logon: [
      SmxSaldifyAssistantSuggestedQa(
        question: 'Que es un anfitrion?',
        answer:
            'Un anfitrion es quien administra clientes, creditos, compras, pagos y cortes dentro de SaldiFY.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Que es un invitado?',
        answer:
            'Un invitado es el cliente que entra con una invitacion para consultar su credito, compras, pagos e historial.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Para que sirve el codigo?',
        answer:
            'El codigo de invitacion vincula al cliente con un anfitrion. Si tienes uno, validalo antes de entrar con Google.',
      ),
    ],
    SmxSaldifyAssistantScreen.logonInvitacionCliente: [
      SmxSaldifyAssistantSuggestedQa(
        question: 'Que tipo de invitacion recibi?',
        answer:
            'Recibiste una invitacion para ingresar como cliente de una red comercial. Al aceptarla, Saldify validara tu cuenta y la vinculara con el Anfitrion que aparece en la tarjeta.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Quien me esta invitando?',
        answer:
            'El nombre del Anfitrion que genero el enlace aparece en la tarjeta. Saldify lo consulta directamente en la base de datos usando el codigo de invitacion.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Que sucede al aceptar?',
        answer:
            'Seleccionaras tu cuenta, Saldify validara la invitacion y creara o confirmara tu relacion con el Anfitrion. Despues podras consultar credito, compras, pagos, saldo e historial.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Como ingreso despues?',
        answer:
            'Despues de aceptar la invitacion, puedes entrar desde el acceso general usando la opcion Invitado y la misma cuenta con la que te registraste.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Que pasa si ya pertenezco a otra red?',
        answer:
            'Una invitacion normal no cambia tu red automaticamente. Saldify protege la relacion existente y te mostrara el estado correspondiente si el Anfitrion es diferente.',
      ),
    ],
    SmxSaldifyAssistantScreen.logonInvitacionLealtad: [
      SmxSaldifyAssistantSuggestedQa(
        question: 'Que tipo de invitacion recibi?',
        answer:
            'Recibiste una invitacion al Programa de lealtad para ingresar o registrarte como Anfitrion. No es una invitacion para convertirte en cliente.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Quien me esta invitando?',
        answer:
            'El nombre de la persona que genero la invitacion de lealtad aparece en la tarjeta y se obtiene directamente desde Saldify.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Que sucede al ingresar?',
        answer:
            'Saldify iniciara tu acceso como Anfitrion y registrara quien te recomendo dentro del Programa de lealtad. Esto no crea una relacion de cliente ni asigna credito.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Como ingreso despues?',
        answer:
            'Una vez registrado, puedes entrar normalmente desde el acceso general usando la opcion Anfitrion y la misma cuenta.',
      ),
    ],
    SmxSaldifyAssistantScreen.dashboardAnfitrion: [
      SmxSaldifyAssistantSuggestedQa(
        question: 'Que significa credito total?',
        answer:
            'Credito total es la suma de los limites de credito configurados para tus clientes activos.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Que clientes tengo pendientes?',
        answer:
            'Los clientes pendientes son relaciones que aun no estan activas o que requieren completar datos antes de operar.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Como invito a un cliente?',
        answer:
            'Puedes invitarlo desde la opcion de invitacion, compartiendo el codigo o enlace para asociarlo a tu cuenta.',
      ),
    ],
    SmxSaldifyAssistantScreen.dashboardCliente: [
      SmxSaldifyAssistantSuggestedQa(
        question: 'Que significa saldo?',
        answer:
            'Saldo es lo que queda pendiente entre tus compras registradas y los pagos aplicados.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Que significa disponible?',
        answer:
            'Disponible es el monto que aun puedes usar de tu credito, segun tus compras, pagos y reglas del anfitrion.',
      ),
      SmxSaldifyAssistantSuggestedQa(
        question: 'Como veo mis pagos?',
        answer:
            'Tus pagos aparecen en el historial y en la pantalla de pagos, junto con su estado de confirmacion.',
      ),
    ],
    SmxSaldifyAssistantScreen.perfilAnfitrion: [
      SmxSaldifyAssistantSuggestedQa(
        question: 'Por que confirmar mis datos Anfitrion?',
        answer:
            'Confirmar tus datos ayuda a que tus clientes identifiquen correctamente a su anfitrion y evita errores en invitaciones.',
      ),
    ],
    SmxSaldifyAssistantScreen.perfilCliente: [
      SmxSaldifyAssistantSuggestedQa(
        question: 'Por que confirmar mis datos Cliente?',
        answer:
            'Confirmar tus datos ayuda a que tu anfitrion te identifique correctamente en compras, pagos e historial.',
      ),
    ],
  };

  static List<String> questionsFor(SmxSaldifyAssistantScreen screen) =>
      (_questions[screen] ?? _notConfiguredQuestions)
          .map((suggestedQa) => suggestedQa.question)
          .toList(growable: false);

  static String? answerFor({
    required SmxSaldifyAssistantScreen screen,
    required String question,
  }) {
    final normalizedQuestion = _normalize(question);
    final suggestedQuestions = _questions[screen] ?? _notConfiguredQuestions;

    for (final suggestedQa in suggestedQuestions) {
      if (_normalize(suggestedQa.question) == normalizedQuestion) {
        return suggestedQa.answer;
      }
    }

    return null;
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase();
  }
}
