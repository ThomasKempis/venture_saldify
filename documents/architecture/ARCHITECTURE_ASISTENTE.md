# ChatGPT Asistente SaldiFY

Este documento resume las decisiones conversadas para crear un chatbot de ayuda con IA para SaldiFY. La idea es conservar el contexto tecnico y funcional antes de implementar la conexion desde el servidor Java/GlassFish.

## Datos Actuales

Proyecto de referencia en ChatGPT:

```text
Saldify Asistente
```

Proyecto recomendado en OpenAI Platform:

```text
Saldify IA Ayuda
```

API key:

```text
No documentar la clave completa en el repo.
Guardar en GlassFish, variable de entorno, property segura o gestor de secretos.
```

Vector store:

```text
NOMBRE: saldify_knowledge
ID: vs_6a47d5d2483c819199d3d8b76e1112f4
```

## Objetivo

Agregar un asistente de ayuda dentro de SaldiFY que explique conceptos de la app de forma clara y contextual.

El asistente debe ayudar al usuario a entender:

- Que es SaldiFY.
- Que es un Anfitrion Empresa.
- Que es un Invitado Cliente.
- Como funciona una invitacion a cliente `SF`.
- Como funciona una invitacion de lealtad `SY`.
- Que ambas invitaciones tienen objetivos y accesos posteriores diferentes.
- Que significan credito, disponible, saldo, compras, pagos y corte.
- Que significan los estados de compras y pagos.
- Que se puede hacer en cada pantalla.

La primera version no debe modificar datos, consultar saldos reales ni ejecutar acciones. Solo debe explicar y orientar.

## Alcance Recomendado

La mejor primera version combina dos ideas:

1. Chatbot simple, barato y seguro.
2. Respuestas con contexto de la pantalla actual.

Ejemplos de contexto:

```json
{
  "screen": "historial_cliente",
  "role": "anfitrion",
  "message": "Que significa compra pendiente?"
}
```

El asistente puede responder distinto segun:

- Pantalla actual.
- Rol actual.
- Pregunta del usuario.
- Documentacion cargada en el vector store.

## Arquitectura General

La API key de OpenAI nunca debe estar en Flutter.

Flujo recomendado:

```text
Flutter SaldiFY
  -> WebService Java/GlassFish propio
    -> OpenAI Responses API
      -> File Search sobre vector store saldify_knowledge
        -> Respuesta de ayuda
  -> Flutter muestra la respuesta
```

Flutter solo llama a los servicios propios de la plataforma. El servidor Java se encarga de hablar con OpenAI.

## Proyecto OpenAI Platform

No confundir estos conceptos:

```text
Codex/repo local             -> donde se programa SaldiFY
Proyecto de ChatGPT          -> organiza chats dentro de chatgpt.com
OpenAI Platform Project      -> API keys, vector stores, usage, logs y billing
```

Para produccion se debe usar un proyecto de OpenAI Platform dedicado, por ejemplo:

```text
Saldify IA Ayuda
```

Dentro de ese proyecto deben quedar:

- API key especifica.
- Vector store `saldify_knowledge`.
- Documentos `.md`.
- Limites de gasto.
- Logs y metricas.

## API Key

La API key se crea en:

```text
https://platform.openai.com/api-keys
```

Debe pertenecer al proyecto de OpenAI Platform dedicado a SaldiFY.

Nombre sugerido:

```text
glassfish-saldify-assistant
```

Importante:

- No guardar la API key en Flutter.
- No guardar la API key en Git.
- No dejar la API key escrita en archivos `.md`.
- Guardarla como variable de entorno, propiedad segura del servidor o mecanismo equivalente.

Ejemplo conceptual:

```text
OPENAI_API_KEY=sk-...
```

## Vector Store

Nombre del vector store:

```text
saldify_knowledge
```

ID actual:

```text
vs_6a47d5d2483c819199d3d8b76e1112f4
```

Los documentos deben subirse dentro de:

```text
Storage -> Vector stores -> saldify_knowledge -> Add files
```

Subirlos solo en la pestana general `Files` no es lo ideal, porque pueden quedar como archivos sueltos y no necesariamente indexados para busqueda dentro del vector store.

## Assistants

La opcion `Assistants` existe en Platform, pero no es la ruta recomendada para esta implementacion nueva.

Decision tomada:

```text
Usar Responses API + file_search + vector_store_id.
```

No crear un Assistant legacy por ahora.

## Documentos Recomendados

No conviene subir todo el codigo fuente como conocimiento inicial. Es mejor subir documentacion curada.

Archivos sugeridos:

```text
SALDIFY_GENERAL.md
SALDIFY_ROLES.md
SALDIFY_SCREEN_LOGON.md
SALDIFY_SCREEN_CLIENTE_DASHBOARD.md
SALDIFY_SCREEN_CLIENTE_HISTORIAL.md
SALDIFY_SCREEN_CLIENTE_COMPRAS.md
SALDIFY_SCREEN_CLIENTE_PAGOS.md
SALDIFY_SCREEN_ANFITRION_CLIENTES.md
SALDIFY_SCREEN_ANFITRION_HISTORIAL.md
SALDIFY_ESTADOS.md
SALDIFY_FAQ.md
```

Las capturas de pantalla pueden servir para referencia humana, pero para `file_search` lo mas util son documentos de texto estructurados.

## Formato Recomendado Para Documentos

Estructura recomendada:

```md
# Pantalla: Historial del cliente

screen_id: historial_cliente
roles: invitado, anfitrion
modulo: saldify

## Proposito
Esta pantalla muestra los movimientos de compras y pagos de un cliente.

## Que ve el usuario
- Saldo actual.
- Lista de compras.
- Lista de pagos.
- Fecha de cada movimiento.
- Estado del movimiento.
- Quien registro el movimiento.

## Conceptos importantes
Compra solicitada significa que la compra fue registrada pero aun no fue entregada.
Compra pendiente significa que el anfitrion la marco como pendiente.
Compra entregada significa que la compra ya fue cerrada.

Pago pendiente significa que falta confirmar el deposito bancario.
Deposito confirmado significa que el pago ya fue validado.

## Reglas de negocio
- Las compras aparecen como pendientes de gestion hasta llegar a entregada.
- Los pagos aparecen como pendientes de gestion hasta llegar a deposito confirmado.

## Que puede responder el asistente
- Explicar que significa cada estado.
- Explicar por que aparece una gestion pendiente.
- Explicar que el panel de acciones pendientes puede avisar una gestion pendiente cuando al menos un cliente tiene compra solicitada o pago registrado por revisar.
- Explicar que debe revisar el anfitrion.
- Orientar al usuario sobre la pantalla.

## Que no debe responder
- No inventar saldos.
- No confirmar pagos.
- No cambiar estados.
- No prometer acciones automaticas.
```

## Reglas Generales Del Asistente

Archivo sugerido:

```text
SALDIFY_GENERAL.md
```

Contenido base:

```md
# Reglas del asistente SaldiFY

## Tono
Responde en espanol, claro, breve y amable.

## Limites
- No inventes datos reales.
- No digas saldos, montos o informacion de base si no viene explicitamente.
- No confirmes pagos.
- No cambies estados.
- No prometas acciones automaticas.
- No expliques detalles internos de base de datos al usuario final.

## Roles
Anfitrion Empresa: administra clientes, creditos, compras, pagos y cortes.
Invitado Cliente: consulta su credito, compras, pagos e historial.
```

## Estados De Compras Y Pagos

Estados de compra:

```text
0 = Compra solicitada
1 = Compra pendiente
2 = Compra entregada
```

Estados de pago:

```text
0 = Pendiente confirmar el registro con el deposito del banco
1 = Deposito confirmado
```

Regla funcional:

- Una compra tiene gestion pendiente mientras su estado sea diferente de `2`.
- Un pago tiene gestion pendiente mientras su estado sea diferente de `1`.
- El panel de acciones pendientes solo debe indicar que existe una gestion pendiente; el detalle se revisa en la campana de notificaciones de la tarjeta del cliente.

## Llamada HTTP Desde Java

No es necesario usar SDK Java para la primera version. Como la plataforma ya tiene servicios y manejo HTTP/JSON, se puede llamar directo por HTTP.

Endpoint:

```text
POST https://api.openai.com/v1/responses
```

Headers:

```text
Authorization: Bearer ${OPENAI_API_KEY}
Content-Type: application/json
```

Body conceptual:

```json
{
  "model": "gpt-5.5",
  "input": "Eres el asistente oficial de SaldiFY. Pantalla: historial_cliente. Rol: anfitrion. Pregunta: Que significa compra pendiente?",
  "tools": [
    {
      "type": "file_search",
      "vector_store_ids": ["vs_6a47d5d2483c819199d3d8b76e1112f4"],
      "max_num_results": 3
    }
  ]
}
```

Nota: antes de implementar, confirmar el modelo final disponible y el costo elegido para produccion. Para ayuda contextual conviene usar un modelo economico y respuestas cortas.

## Ejemplo Java Con HttpURLConnection

```java
URL url = new URL("https://api.openai.com/v1/responses");
HttpURLConnection con = (HttpURLConnection) url.openConnection();

con.setRequestMethod("POST");
con.setRequestProperty("Authorization", "Bearer " + apiKey);
con.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
con.setDoOutput(true);

String body = "{"
    + "\"model\":\"gpt-5.5\","
    + "\"input\":\"Eres el asistente oficial de SaldiFY. "
    + "Pantalla: historial_cliente. "
    + "Rol: anfitrion. "
    + "Pregunta: Que significa compra pendiente?\","
    + "\"tools\":[{"
    + "\"type\":\"file_search\","
    + "\"vector_store_ids\":[\"vs_6a47d5d2483c819199d3d8b76e1112f4\"],"
    + "\"max_num_results\":3"
    + "}]"
    + "}";

try (OutputStream os = con.getOutputStream()) {
    os.write(body.getBytes("UTF-8"));
}

int status = con.getResponseCode();
InputStream is = status >= 200 && status < 300
    ? con.getInputStream()
    : con.getErrorStream();
```

La respuesta viene como JSON. El texto final se obtiene buscando contenido de tipo:

```text
output_text
```

Conceptualmente:

```text
response.output[].content[].type == "output_text"
response.output[].content[].text
```

## Control De Costos

El proyecto, API key y vector store vacio no son el gasto principal. El costo aparece cuando el servidor llama a OpenAI.

Medidas recomendadas:

- Limitar preguntas por usuario por dia.
- Limitar caracteres por pregunta.
- Limitar resultados de file search con `max_num_results`.
- Pedir respuestas cortas.
- Usar modelo economico para ayuda.
- Cachear respuestas frecuentes.
- Evitar conversaciones largas sin limite.

Prompt recomendado:

```text
Responde en maximo 5 lineas.
```

## Primera Version En Flutter

La UI no es el problema principal, pero la primera version podria tener:

- Boton discreto de ayuda.
- Bottom sheet o panel de chat.
- Contexto enviado desde la pantalla actual.
- Controller propio.
- Sin acceso directo a OpenAI.

Modulo sugerido:

```text
lib/smxSaldifyAssistant/
```

Archivos actuales/sugeridos:

```text
smxSaldifyAssistant.dart
smxSaldifyAssistant_controller.dart
smxSaldifyAssistant_context.dart
smxSaldifyAssistant_screen_mock.dart
```

Contexto inicial:

```dart
enum SmxSaldifyAssistantScreen {
  logon,
  logonInvitacionCliente,
  logonInvitacionLealtad,
  dashboardCliente,
  anfitrionCliente,
  historialCliente,
  compras,
  pagos,
  listaClientes,
  invitacion,
  miRed,
  reportes,
}
```

Valores de payload recomendados:

```text
miRed    -> mi_red
reportes -> reportes
```

`miRed` debe apoyarse en la documentacion `01.05.70 - Mi red y archivados.md`.

`reportes` debe apoyarse en la documentacion `01.05.80 - Reportes.md`.

Ambos contextos pertenecen al rol `anfitrion`.

En el logon, Flutter selecciona el contexto con el prefijo validado del URL:

```text
sin invitacion  -> logon
SF              -> logon_invitacion_cliente
SY              -> logon_invitacion_lealtad
```

Esta separacion evita que el asistente confunda una relacion comercial de
cliente con una referencia del Programa de lealtad.

Ejemplo:

```dart
SmxSaldifyAssistant(
  screen: SmxSaldifyAssistantScreen.historialCliente,
  role: SmxSaldifyAssistantRole.invitado,
)
```

## Decision Actual

La ruta elegida para continuar es:

```text
1. Crear proyecto OpenAI Platform dedicado.
2. Crear API key del proyecto.
3. Crear vector store saldify_knowledge.
4. Subir documentos .md curados.
5. Implementar llamada HTTP directa desde GlassFish.
6. Flutter consume solo el servicio propio.
```
