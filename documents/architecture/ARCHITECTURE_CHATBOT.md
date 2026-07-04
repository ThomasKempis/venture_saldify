# Arquitectura Chatbot SaldiFY

Este documento resume el estado actual de la interfaz del asistente de ayuda de SaldiFY y las decisiones tomadas para mantenerla alineada con la plataforma SMX/Venture.

Debe leerse junto con:

- `ARCHITECTURE.md`
- `ARCHITECTURE_CRUD_WIDGETS.md`
- `ARCHITECTURE_ASISTENTE.md`

## Objetivo

Crear una primera interfaz de chatbot dentro de SaldiFY para orientar al usuario sobre conceptos, pantallas y estados.

La version actual es solo UI con respuestas mock locales. No llama a OpenAI, no llama a GlassFish y no modifica datos.

El asistente debe mantenerse limitado a ayuda contextual:

- Explicar conceptos de SaldiFY.
- Explicar roles de anfitrion e invitado.
- Explicar credito, disponible, saldo, compras, pagos y cortes.
- Explicar estados de compras y pagos.
- Orientar segun la pantalla actual.

No debe:

- Consultar saldos reales.
- Inventar datos de base.
- Confirmar pagos.
- Cambiar estados.
- Ejecutar acciones automaticas.
- Guardar API keys en Flutter.

## Estado Actual

Se creo el modulo:

```text
lib/smxSaldify/smxSaldify_assistant/
```

Archivos:

```text
smxSaldify_assistant.dart
smxSaldify_assistant_controller.dart
smxSaldify_assistant_context.dart
```

La UI esta integrada en:

```text
lib/smxSaldify/smxSaldify.dart
lib/smxSaldifyCliente/smxSaldifyCliente.dart
```

Actualmente aparece como boton flotante en:

- Dashboard anfitrion.
- Perfil anfitrion.
- Dashboard cliente/invitado.
- Perfil cliente/invitado.

No se agrego todavia a pantallas internas como compras, pagos, credito, historial o cobranza.

## Patron SMX Correcto

La primera version del controller visual se habia creado como `ChangeNotifier`, pero se corrigio para respetar la plataforma.

El controller actual es:

```dart
class SmxSaldifyAssistantController extends SmxController
```

Y se inicializa con:

```dart
SmxCallBaseStateful<SmxSaldifyAssistantController>
```

Patron usado:

```dart
SmxCallBaseStateful<SmxSaldifyAssistantController>(
  controllerBuilder: (context) => SmxSaldifyAssistantController(
    alias: 'SMXSALDIFY_ASSISTANT',
    data: SmxControllerSendData(context: context),
  ),
  loadingBuilder: (_) => child,
  builder: (context, controller) => ...
)
```

Se usa `loadingBuilder: (_) => child` para evitar que el spinner default del framework tape la pantalla mientras inicializa un controller que por ahora no carga datos.

## Responsabilidades Por Archivo

### `smxSaldify_assistant.dart`

Contiene la UI del asistente.

Responsabilidades:

- Envolver la pantalla con `SmxSaldifyAssistantHost`.
- Crear el controller con `SmxCallBaseStateful`.
- Mostrar el boton flotante de ayuda.
- Abrir un bottom sheet en mobile.
- Abrir un dialog en tablet/desktop.
- Mostrar header con rol y pantalla.
- Mostrar historial de mensajes.
- Mostrar sugerencias rapidas.
- Capturar la pregunta del usuario.

La UI no llama directo al servidor. Solo llama al metodo del controller:

```dart
controller.send(...)
```

### `smxSaldify_assistant_controller.dart`

Controller de plataforma para el asistente.

Responsabilidades actuales:

- Extender `SmxController`.
- Implementar `init()`, `save()`, `cancel()`, `delete()` y `filtro(...)`.
- Mantener el estado de mensajes.
- Mantener el estado de envio.
- Responder con mock local.

Aunque usa `ValueNotifier` para refrescar la UI del chat, el controller pertenece al ciclo SMX.

Notifiers actuales:

```dart
messagesNotifier
sendingNotifier
```

El punto de acople futuro al webservice esta en:

```dart
requestAssistantReply(...)
```

Por ahora este metodo devuelve respuestas mock.

### `smxSaldify_assistant_context.dart`

Define enums de contexto:

```dart
SmxSaldifyAssistantRole
SmxSaldifyAssistantScreen
```

Roles actuales:

```text
anfitrion
invitado
```

Pantallas actuales:

```text
dashboard_anfitrion
perfil_anfitrion
dashboard_cliente
perfil_cliente
```

Cada enum tiene:

- `label`: texto para mostrar en UI.
- `payloadValue`: valor pensado para enviar al servidor despues.

## Respuestas Mock Actuales

Las respuestas mock estan en:

```dart
requestAssistantReply(...)
```

Casos actuales:

- Si la pregunta contiene `compra`, explica compra solicitada/pendiente/entregada.
- Si contiene `pago`, explica pago por confirmar/deposito confirmado.
- Si contiene `credito`, `disponible` o `saldo`, explica los conceptos.
- Si no coincide, responde con pantalla y rol actuales.

Estas respuestas son temporales y deben reemplazarse por la llamada real al servidor.

## Servicio Futuro

Se reviso el enum `SmxServicios` del paquete:

```text
venture_core_connect/lib/smxJson/smxJsonUtil.dart
```

Enum actual observado:

```dart
enum SmxServicios {
  CRUD_SQL,
  CRUD_UPDATE,
  CRUD_DELETE,
  CRUD_INSERT,
  CRUD_TRANS,
  FILES,
  MAIL,
  LOGON,
  LOGON_REGISTRO,
  LOGON_UUID,
  CFDI,
  SOCMAIN01_SOCUSUA01,
  EXPORT_EXCEL,
  REPORTS,
  VID_PDFS_PRODUCCION,
  CMO_XLSX_MIGRACION,
}
```

Todavia no existe un microservicio especifico para el asistente.

Cuando se agregue al core/backend podria ser algo como:

```dart
SmxServicios.SALDIFY_ASSISTANT
```

La llamada futura deberia hacerse desde `SmxSaldifyAssistantController`, no desde la UI.

Conceptualmente:

```dart
jsonSend.microServicio = SmxServicios.SALDIFY_ASSISTANT.toStringValue();
await getCallWS();
```

El nombre final del servicio debe definirse junto con el backend Java/GlassFish y el paquete `venture_core_connect`.

## Flujo Futuro Esperado

```text
Usuario pregunta en Flutter
-> SmxSaldifyAssistantController.send(...)
-> requestAssistantReply(...)
-> jsonSend.microServicio = servicio de asistente
-> getCallWS()
-> WebService Java/GlassFish
-> OpenAI Responses API + vector store saldify_knowledge
-> respuesta corta de ayuda
-> Flutter muestra mensaje
```

La API key de OpenAI nunca debe vivir en Flutter.

## Contexto Para Enviar Al Servidor

El payload futuro deberia incluir como minimo:

```json
{
  "screen": "dashboard_cliente",
  "role": "invitado",
  "message": "Que significa saldo?"
}
```

Opcionalmente podria incluir:

- idioma.
- version de app.
- id de usuario logueado, si el backend lo necesita.
- metadata de sesion SMX.

No se deben enviar saldos reales ni datos sensibles si la primera version solo es de ayuda conceptual.

## Reglas De Implementacion

1. La UI no debe llamar directo a OpenAI.
2. La UI no debe guardar API keys.
3. La comunicacion con servidor debe pasar por `SmxController`.
4. El controller debe inicializarse con `SmxCallBaseStateful`.
5. La llamada real debe vivir en `SmxSaldifyAssistantController`.
6. El boton flotante puede reutilizarse en otras pantallas pasando otro `screen`.
7. Si se agrega el asistente a pantallas internas, actualizar `SmxSaldifyAssistantScreen`.
8. Mantener respuestas cortas.
9. Mantener limites funcionales: no confirmar, no modificar, no consultar datos reales.

## Validacion Realizada

Se ejecuto formato sobre los archivos nuevos y modificados.

Se ejecuto analisis acotado:

```text
dart analyze lib/smxSaldify/smxSaldify_assistant lib/smxSaldify/smxSaldify.dart lib/smxSaldifyCliente/smxSaldifyCliente.dart
```

Resultado:

- Sin errores.
- Solo `info` por nombres de archivo que no usan `lower_case_with_underscores`, consistente con el estilo actual del proyecto.

`flutter analyze` completo del proyecto reporta issues preexistentes no relacionados con el asistente.

## Pendientes

- Definir nombre final del microservicio en `SmxServicios`.
- Implementar backend Java/GlassFish.
- Implementar llamada real en `requestAssistantReply(...)`.
- Definir estructura exacta del JSON de request/response.
- Conectar vector store `saldify_knowledge`.
- Agregar manejo de errores del webservice.
- Agregar limites de caracteres y control de envio.
- Decidir si el asistente debe aparecer tambien en compras, pagos, credito e historial.
