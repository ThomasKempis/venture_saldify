# Saldify - Resumen Maestro de Arquitectura 03

Este documento continua `ARCHITECTURE_RESUMEN_02.md` y consolida las decisiones recientes sobre profundidad visual, historial de movimientos, rechazo de pagos confirmados, motivos de rechazo y reglas asociadas en base de datos.

El objetivo es dejar claro que el rechazo de pagos es una accion excepcional, controlada por el anfitrion, pero visible como auditoria tanto para anfitrion como para invitado.

## 1. SmxDepth

Se agrego el widget reutilizable:

```text
lib/smxApis/smxDepth.dart
```

`SmxDepth` dibuja un efecto de profundidad alrededor de un widget usando `CustomPainter`. El efecto se pinta principalmente hacia la derecha y abajo, sin crear una tarjeta completa atras del contenido.

Parametros principales:

```dart
SmxDepth(
  radius: 20,
  depth: 3,
  opacity: .14,
  blurRadius: 7,
  child: ...
)
```

Significado:

- `radius`: radio de las esquinas del efecto. Debe coincidir con el `borderRadius` del widget envuelto.
- `depth`: desplazamiento visual hacia derecha/abajo.
- `opacity`: intensidad del volumen.
- `blurRadius`: suavidad de la sombra.

Uso actual:

- Tarjeta principal del logon.
- Tarjetas de `Clientes`.
- Tarjetas de `Clientes pendientes`.

En listas con `Slidable`, `SmxDepth` se aplica dentro del `child` del `Slidable`, envolviendo la tarjeta visual. El padding derecho que existia para el `Slidable` fue dejado en cero para evitar que las tarjetas se vieran mas angostas que el resto del dashboard.

## 2. Rechazo de Pagos Confirmados

### Regla de negocio

El invitado puede registrar y modificar pagos pendientes, pero no confirma depositos.

El anfitrion:

- Confirma pagos pendientes.
- Puede rechazar un pago confirmado en casos excepcionales.

El rechazo no borra el pago. Cambia su estado y documenta el motivo.

Flujo:

```text
Pago pendiente
  -> Confirmado por anfitrion
  -> Rechazado por anfitrion, si luego el deposito no procede
```

El saldo se recalcula correctamente porque la vista de saldos suma pagos solo cuando:

```sql
sysuser50_status = 1
```

Por lo tanto, un pago rechazado deja de afectar:

- Pagos.
- Saldo.
- Disponible.
- Cobranza derivada.

## 3. Estados de SYSUSER50

Estados usados para pagos:

```text
0 = Pendiente confirmar
1 = Deposito confirmado
2 = Pago rechazado
```

`status = 2` no es una accion normal del invitado. Es una accion de auditoria del anfitrion sobre un pago previamente confirmado.

## 4. Motivo de Rechazo

Se agrego el campo en base:

```text
SYSUSER50_MOTIVO
```

Uso:

- Obligatorio al rechazar un pago confirmado.
- Minimo en Flutter: 30 caracteres.
- Maximo en Flutter: 3000 caracteres.
- Debe guardarse en base junto con `sysuser50_status = 2`.

El motivo permite que el anfitrion y el invitado entiendan por que un pago confirmado dejo de afectar el saldo.

## 5. Stored Procedure de Actualizacion

El historial ya usaba el proceso:

```text
UPDATE_SYSUSER40_SYSUSER50
```

Antes se llamaba con:

```sql
UPDATE_SYSUSER40_SYSUSER50(accion, id, status)
```

Ahora se llama con un cuarto parametro:

```sql
UPDATE_SYSUSER40_SYSUSER50(accion, id, status, motivo)
```

Para acciones normales `C` y `P`, Flutter manda motivo vacio:

```sql
UPDATE_SYSUSER40_SYSUSER50('C', id_compra, status, '')
UPDATE_SYSUSER40_SYSUSER50('P', id_pago, status, '')
```

Para rechazar un pago confirmado:

```sql
UPDATE_SYSUSER40_SYSUSER50('PR', id_pago, 2, motivo)
```

La rama `PR` debe validar en base:

- `status = 2`.
- `motivo` no vacio.
- El pago existe.
- El pago todavia tiene `sysuser50_status = 1`.

La actualizacion recomendada:

```sql
update sysuser50_det_pagos set
    sysuser50_status = :status,
    sysuser50_motivo = :motivo
where id_sysuser50 = :id
  and sysuser50_status = 1;
```

El SP puede usar `row_count` despues del `update` para devolver:

```text
TMPUSER99_STATUS = OK
TMPUSER99_STATUS = ERROR
```

Flutter ya interpreta cualquier resultado distinto de `OK` como error y muestra:

```text
No se pudo actualizar el movimiento.
```

La app valida para experiencia de usuario, pero la base debe ser la ultima autoridad.

## 6. Historial del Anfitrion

Archivos:

```text
lib/smxSaldify/smxSaldify_screens/saldify_historial/smxSaldiFy_historial.dart
lib/smxSaldify/smxSaldify_screens/saldify_historial/smxSaldiFy_historial_controller.dart
```

### Confirmacion normal

Los pagos pendientes mantienen la accion:

```text
Confirmar deposito
```

Esta accion llama:

```sql
UPDATE_SYSUSER40_SYSUSER50('P', id_pago, 1, '')
```

### Rechazo de pago confirmado

No se agrego un boton visible permanente de rechazo para evitar una accion peligrosa demasiado expuesta.

Regla visual:

- El chip de folio del pago es clickeable solo si el pago esta confirmado (`status = 1`).
- Al tocarlo se abre una hoja inferior.
- La hoja se titula `Pago rechazado`.
- Debajo del titulo muestra un resumen del movimiento:

```text
P-00025        $10,000        13/07/2026
```

- Solicita `Motivo`.
- El boton `Rechazar pago confirmado` queda deshabilitado hasta cumplir el minimo de caracteres.
- Antes de ejecutar, se muestra confirmacion de proceso irreversible.

Despues de aceptar:

```sql
UPDATE_SYSUSER40_SYSUSER50('PR', id_pago, 2, motivo)
```

Si la base devuelve `OK`, Flutter:

- Actualiza `SYSUSER90_STATUS` localmente a `2`.
- Actualiza `SYSUSER90_MOTIVO` localmente si el campo existe.
- Recalcula saldo local.
- Marca `hasChanges = true`.

### Lectura de motivo

Si el movimiento ya esta rechazado (`status = 2`) y viene `SYSUSER90_MOTIVO`, el chip `Pago rechazado` es clickeable.

Al tocarlo se muestra una hoja inferior de solo lectura:

```text
Pago rechazado
P-00025        $10,000        13/07/2026
Motivo
...
Cerrar
```

Si `SYSUSER90_MOTIVO` aun no viene desde base, no rompe la pantalla. Simplemente el chip no queda clickeable.

## 7. Historial del Invitado

Archivos:

```text
lib/smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_historial/smxSaldiFyCliente_historial.dart
lib/smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_historial/smxSaldiFyCliente_historial_controller.dart
```

El invitado no puede rechazar ni confirmar pagos desde el historial.

Se agrego soporte de solo lectura para:

```text
status = 2 -> Rechazado
```

Si viene `SYSUSER90_MOTIVO`, el badge `Rechazado` es clickeable y abre una hoja inferior con el motivo.

Esto permite que el cliente sepa por que un pago fue rechazado y por que dejo de afectar su saldo.

La hoja de motivo rechazado tambien muestra el mismo resumen del movimiento:

```text
P-00025        $10,000        13 Jul
```

No existe accion de rechazo ni edicion desde invitado; solo consulta.

## 7.1 Folio de Movimiento

Se agrego folio visible para movimientos usando `ID_SYSUSER90`.

Formato:

```text
Pago   -> P-00025
Compra -> C-00018
```

Regla:

```text
prefijo + '-' + ID_SYSUSER90 con 5 digitos, completado con ceros a la izquierda
```

Ejemplos:

```text
ID_SYSUSER90 = 7, tipo Pago   -> P-00007
ID_SYSUSER90 = 42, tipo Compra -> C-00042
```

En anfitrion:

- El chip que antes mostraba `Pago` o `Compra` ahora muestra el folio.
- La regla de clic no cambia: solo el folio de pago confirmado es clickeable para iniciar rechazo.

En invitado:

- Donde antes se mostraba `Pago` o `Compra` en la metadata de la tarjeta, ahora se muestra el folio.
- El badge `Rechazado` sigue siendo de solo lectura y abre el motivo si existe.

El folio no define el orden del historial. El orden se mantiene por base:

```sql
order by x.sysuser90_fapl desc, x.id_sysuser90 desc
```

El folio es un identificador de auditoria/soporte, no un criterio de ordenamiento.

## 8. Contrato de QRY_SYSUSER10_HISTORIAL

Tanto anfitrion como invitado usan:

```text
QRY_SYSUSER10_HISTORIAL
```

Esta consulta/procedure consume movimientos desde:

```text
qry_sysuser40_vs_sysuser50
```

Para soportar motivos de rechazo, la recomendacion es modificar la vista `qry_sysuser40_vs_sysuser50` y agregar:

```text
SYSUSER90_MOTIVO
```

En compras:

```sql
cast(null as varchar(3000)) as sysuser90_motivo
```

En pagos:

```sql
p.sysuser50_motivo as sysuser90_motivo
```

Luego `QRY_SYSUSER10_HISTORIAL` debe seleccionar y suspender ese campo junto con los demas `SYSUSER90_*`.

No se recomienda hacer un `select` adicional dentro del loop por `rela_sysuser50`, porque agrega una consulta por cada movimiento y duplica responsabilidad. La vista de union debe ser la fuente completa del movimiento historico.

## 9. Gestiones Pendientes y Pagos Rechazados

El contador de gestiones pendientes de la lista de clientes viene desde `QRY_SYSUSER11`, campo `NOVE_PAGOS`.

Antes la base contaba pagos pendientes con:

```sql
sysuser50_status != 1
```

Con el nuevo estado `2 = rechazado`, esta regla cuenta rechazados como pendientes.

Debe cambiarse a:

```sql
sysuser50_status = 0
```

Asi `gestiones pendientes` significa pagos pendientes de confirmar, no pagos rechazados.

## 10. Cobranza y Limite de Credito

Se detecto una ruptura conceptual en cobranza:

Un cliente puede estar `Al dia` por fecha de corte pero quedar sin disponible o con saldo superior al credito.

La regla propuesta en base para la lista de clientes/cobranza es:

```text
Si balance > credito -> Limite excedido / danger
Si disponible <= 0 y balance > 0 -> Sin disponible / alert
Si no, aplicar vencimiento normal por corte
```

Ejemplo dentro de la logica de `QRY_SYSUSER11`:

```sql
if (sysuser12_balance > 0.0) then
begin
    select
        qry_sysuser11_vencimiento.dias,
        qry_sysuser11_vencimiento.sysuser12_status,
        qry_sysuser11_vencimiento.sysuser12_status_tipo
    from qry_sysuser11_vencimiento(:fecha_corte)
    into :sysuser12_dias,
         :sysuser12_status,
         :sysuser12_status_tipo;

    if (sysuser12_balance > sysuser12_credito) then
    begin
        sysuser12_status = 'Limite excedido';
        sysuser12_status_tipo = 'danger';
    end
    else if (sysuser12_disponible <= 0 and sysuser12_balance > 0) then
    begin
        sysuser12_status = 'Sin disponible';
        sysuser12_status_tipo = 'alert';
    end
end
```

La base sigue siendo la fuente de verdad para saldos, cortes y status financiero.

## 11. Validaciones de Flutter

Para rechazo de pago confirmado:

- Solo anfitrion.
- Solo movimiento tipo pago.
- Solo `status = 1`.
- Motivo minimo: 30 caracteres.
- Motivo maximo: 3000 caracteres.
- Confirmacion irreversible antes de llamar a base.
- Si base devuelve error, Flutter no actualiza el movimiento local.

La UI no sustituye las validaciones de base; solo evita errores comunes y mejora la experiencia.

## 12. Archivos Tocables Relacionados

Visual compartido:

```text
lib/smxApis/smxDepth.dart
```

Clientes:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_clientes/smxSaldiFy_clientes.dart
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_clientes_pendientes/smxSaldiFy_clientes_pendientes.dart
```

Historial anfitrion:

```text
lib/smxSaldify/smxSaldify_screens/saldify_historial/smxSaldiFy_historial.dart
lib/smxSaldify/smxSaldify_screens/saldify_historial/smxSaldiFy_historial_controller.dart
```

Historial invitado:

```text
lib/smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_historial/smxSaldiFyCliente_historial.dart
lib/smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_historial/smxSaldiFyCliente_historial_controller.dart
```

Base de datos relacionada:

```text
SYSUSER50_DET_PAGOS.SYSUSER50_STATUS
SYSUSER50_DET_PAGOS.SYSUSER50_MOTIVO
UPDATE_SYSUSER40_SYSUSER50
QRY_SYSUSER10_HISTORIAL
qry_sysuser40_vs_sysuser50
QRY_SYSUSER11
qry_sysuser11_saldos
```

## 13. Carrito de Compras: Ajuste Visual y Consistencia

Archivo principal:

```text
lib/smxLayout/smxScreens/smxComprasCarrito/smxComprasCarrito.dart
```

Se ajusto el carrito para que use el mismo lenguaje visual de las pantallas Saldify:

- Fondo `SmxSaldifyBackground`.
- `Scaffold` transparente.
- Sin `AppBar` propio.
- Header interno comun.
- Padding responsive desde `SmxLayout.saldifyPagePadding`.
- Ancho maximo desde `SmxLayout.saldifyMaxContentWidth`.
- `SafeArea(top: false, bottom: false)`.
- `Align(alignment: Alignment.topCenter)`.
- `ConstrainedBox` para igualar el comportamiento de pagos y compras manuales.

Esto corrige diferencias de margen entre:

```text
Pagos
Compras manual
Carrito
```

Antes el carrito usaba:

```dart
ListView(
  padding: const EdgeInsets.all(16),
)
```

Ahora usa el mismo calculo que las demas pantallas operativas:

```dart
padding: EdgeInsets.fromLTRB(
  pagePadding.left,
  pagePadding.top + topContentInset,
  pagePadding.right,
  pagePadding.bottom + bottomContentInset,
)
```

### Tarjetas de Producto

Las tarjetas de producto del carrito quedaron:

- Fondo blanco translucido para dejar ver el fondo Saldify.
- `borderRadius` 12.
- Imagen arriba con `AspectRatio(1.10)`.
- Precio y stock como badges sobre la foto.
- Control completo `- cantidad +` sobre la parte inferior de la foto.
- Nombre del producto sin corte fijo de dos lineas; puede crecer si la descripcion es larga.

Se cambio el grid fijo por un `Wrap` con ancho calculado por columna. Esto permite tarjetas de altura variable cuando el nombre del producto ocupa mas lineas.

### Decision sobre palette_generator

Se probo `palette_generator` para pintar cada card con colores dominantes de su foto.

Decision final:

- Se descarto por costo visual/performance.
- La primera carga tardaba demasiado en pintar.
- Se retiro del codigo.
- Se retiro de `pubspec.yaml`.
- Se ejecuto `flutter pub get` y `pubspec.lock` quedo sin `palette_generator`.

El carrito queda rapido y consistente, usando el fondo del sistema y cards translucidas en lugar de calcular colores por imagen.

## 14. Header Comun de Pantallas Internas

Se centralizo el header de pantallas internas en:

```text
lib/smxLayout/smxLayout.dart
```

Widgets agregados:

```dart
SmxSaldifyScreenHeader
SmxSaldifyHeaderIconButton
```

`SmxSaldifyScreenHeader` parametriza:

- `title`
- `sectionLabel`
- `onBackPressed`
- `actions`

Estilo comun:

- Boton regresar `44x44`.
- Fondo del boton `SmxColors.whiteAlpha(.12)`.
- Titulo blanco `fontSize: 24`, `fontWeight: w900`.
- Subtitulo `SmxColors.brandAccent`, `fontSize: 13`, `fontWeight: w800`.
- `maxLines: 1` y `overflow: TextOverflow.ellipsis`.

`SmxSaldifyHeaderIconButton` permite reutilizar el mismo boton circular/translucido para acciones del header, por ejemplo:

- Carritos guardados.
- Ver carrito.

### Pantallas migradas al header comun

Se removieron los `_Header` privados de:

```text
lib/smxLayout/smxScreens/smxPagos/smxPagos.dart
lib/smxLayout/smxScreens/smxComprasManual/smxComprasManual.dart
lib/smxLayout/smxScreens/smxComprasCarrito/smxComprasCarrito.dart
lib/smxSaldify/smxSaldify_screens/saldify_cliente/smxSaldiFy_cliente.dart
lib/smxSaldify/smxSaldify_screens/saldify_productos/smxSaldiFy_productos.dart
lib/smxSaldify/smxSaldify_screens/saldify_cobranza/smxSaldiFy_cobranza.dart
lib/smxSaldify/smxSaldify_screens/saldify_archivados/smxSaldiFy_archivados.dart
lib/smxSaldify/smxSaldify_screens/saldify_credito/smxSaldiFy_cliente_credito.dart
lib/smxSaldify/smxSaldify_screens/saldify_historial/smxSaldiFy_historial.dart
```

Logicas especiales conservadas:

```dart
Navigator.of(context).pop(_savedSomething)
Navigator.of(context).pop(_changed)
Navigator.of(context).pop(controller.hasChanges)
Navigator.of(context).pop(controller.cambioDisponibilidadCatalogo)
```

Esto mantiene el contrato de retorno de cada pantalla, pero unifica el dibujo del header.

Verificacion usada:

```bash
rg -n "class _Header\\b|_Header\\(" lib
```

Resultado esperado:

```text
Sin resultados
```

### Headers que no se unificaron

Los dashboards usan headers de marca, no headers de pantalla interna:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_dashboard.dart
lib/smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_dashboard.dart
```

Estos headers muestran:

- Logo.
- `SmxConfig.titulo.toUpperCase()`.
- `SmxConfig.descripcion`.
- Letter spacing.
- Boton de menu opcional.
- Boton refresh opcional.

Por eso no se mezclaron con `SmxSaldifyScreenHeader`.

Refactor posible futuro:

```text
SmxSaldifyBrandHeader
```

para compartir el header de marca entre dashboard anfitrion y dashboard cliente.

## 15. Skeleton de "Tu Anfitrion"

Archivo:

```text
lib/smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_anfitrion/smxSaldiFyCliente_anfitrion_skeleton.dart
```

Se detecto que el skeleton del card `Tu anfitrion` se percibia mas bajo que el card real.

El card real puede crecer por:

- Telefono y correo.
- Textos con `height`.
- Pills reales de estado e informacion.
- Filas con contenido variable.

Se aumento solo el `minHeight` del skeleton:

```dart
constraints: const BoxConstraints(minHeight: 150)
```

No se modifico el card real.

El objetivo es reducir el salto visual entre carga y contenido final.

## 16. Ajustes finales de invitaciones

La documentacion conceptual de invitaciones vive en:

```text
documents/architecture/ARCHITECTURE_RESUMEN_01.md
```

En este cierre se implementaron/ajustaron detalles operativos de esa arquitectura.

### Invita Clientes

Archivo principal:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_invita_clientes/smxSaldiFy_invita_clientes.dart
```

La tarjeta del dashboard mantiene el concepto de `Invita clientes`, pero ya no es clickeable completa. Solo el QR simulado abre la hoja inferior.

La hoja inferior queda distribuida en tres bloques:

```text
Si esta presente puede leer el QR
  -> QR anonimo + codigo + boton copiar link

Puede invitar por correo Gmail
  -> campo con nombre de correo + sufijo fijo @gmail.com + boton copiar link

Mensaje
  -> validaciones y confirmaciones de copiado
```

Reglas UI:

- El QR real se genera con `qr_flutter`.
- El card del QR usa `SmxDepth` con `fade: true`.
- El codigo `SF...` se muestra completo; no se separa visualmente el prefijo `SF`.
- El boton de link del QR y el boton de link del correo mantienen el mismo tamano.
- Las validaciones de correo se muestran en `Mensaje`, no en modal.
- El campo de Gmail recibe solo el nombre del correo, sin `@gmail.com`.
- `@gmail.com` queda siempre visible como sufijo fijo.

Mensajes actuales:

```text
Se copio el link anonimo
Se copio link por correo
Ingrese un correo Gmail.
Ingrese solo el nombre, sin @gmail.com.
Ingrese un correo Gmail valido.
```

### Links desde clientes activos y pendientes

Clientes activos:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_dashboard_menu.dart
```

El menu inferior del cliente incluye un boton circular de cadena/link en el encabezado. Ese boton genera y copia una invitacion especifica para el cliente seleccionado.

Clientes pendientes:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_clientes_pendientes/
```

La tarjeta de pendiente agrega accion `Invitar` junto a `Activar cliente`, usando el mismo flujo de link especifico.

Servicio compartido:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_invita_clientes/smxSaldiFy_invita_copy.dart
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_invita_clientes/smxSaldiFy_invita_service.dart
```

El link especifico usa:

```text
uuidAnfitrion = SmxConstants.controllerMain.getUuid()
uuidInvitado = uuid del cliente seleccionado
```

La generacion no ensucia `showSmxSaldiFyDashboardMenu`; el menu solo contiene el boton y llama al helper de copia.

### Superficies de invitacion modificadas

Quedaron tres puntos de entrada para invitacion:

```text
1. Tarjeta Invita clientes
   Dashboard anfitrion.
   Solo el QR simulado es clickeable.
   Abre la hoja inferior con QR anonimo, Gmail y Mensaje.

2. Clientes activos
   Menu inferior del cliente.
   Boton circular de cadena/link en el header.
   Genera link especifico usando el uuid del cliente.

3. Clientes pendientes
   Tarjeta de cliente pendiente.
   Accion Invitar junto a Activar cliente.
   Genera link especifico usando el uuid del pendiente.
```

Todas estas entradas usan el mismo servicio de generacion/copia de invitacion y terminan reservando codigo en `SYSUSER90_TBL_SALDIFY`.

### Tipos de link generados

La app genera tres variantes de invitacion desde el mismo servicio:

#### 1. QR / link anonimo

Origen:

```text
Tarjeta Invita clientes -> hoja inferior -> bloque QR
```

Uso:

- Para una persona presente que puede escanear el QR.
- Para copiar un link abierto y enviarlo por cualquier canal externo.

Datos guardados:

```text
SYSUSER90_CODIGO
SYSUSER90_ANFITRION_UUID
SYSUSER90_INVITADO_CORREO = ''
SYSUSER90_INVITADO_UUID = ''
```

Link:

```text
https://venture.jars.mx/venture_saldify?codigo=SF...
```

Al validar, el logon reclama el codigo con `UPDATE_SYSUSER90`, usando el correo y uuid reales del usuario autenticado con Google.

#### 2. Invitacion por cliente existente

Origen:

```text
Clientes activos -> menu inferior -> boton link
Clientes pendientes -> tarjeta -> accion Invitar
```

Uso:

- Reenviar acceso a un cliente que ya existe en la red.
- Aplica tanto para clientes activos como para clientes pendientes.

Datos guardados:

```text
SYSUSER90_CODIGO
SYSUSER90_ANFITRION_UUID
SYSUSER90_INVITADO_UUID
SYSUSER90_INVITADO_CORREO = ''
```

Link:

```text
https://venture.jars.mx/venture_saldify?codigo=SF...&uuid_anfitrion=...&uuid_invitado=...
```

Aunque el link pueda llevar `uuid_anfitrion` y `uuid_invitado`, la validacion confiable se resuelve desde `SYSUSER90` usando el `codigo`.

#### 3. Invitacion por correo Gmail

Origen:

```text
Tarjeta Invita clientes -> hoja inferior -> bloque Gmail
```

Uso:

- Restringir una invitacion a una cuenta Gmail concreta cuando aun no se tiene uuid del invitado.

UI:

- El anfitrion escribe solo el nombre del correo.
- El sufijo `@gmail.com` se muestra fijo.
- No se permite escribir `@gmail.com` dentro del campo.
- Las validaciones se muestran en el bloque `Mensaje`.

Datos guardados:

```text
SYSUSER90_CODIGO
SYSUSER90_ANFITRION_UUID
SYSUSER90_INVITADO_CORREO
SYSUSER90_INVITADO_UUID = ''
```

Link:

```text
https://venture.jars.mx/venture_saldify?codigo=SF...&uuid_anfitrion=...&correo_invitado=...
```

Al validar, el correo Google autenticado debe coincidir con el correo guardado. Despues puede consolidarse el uuid real del invitado.

### Validacion de codigo recibido por URL

El logon ya no valida el codigo con un `SELECT` directo contra `SYSUSER90_TBL_SALDIFY`.

Ahora usa:

```dart
addSTrans(
  alias,
  "SELECT * FROM UPDATE_SYSUSER90('$codigo', '$uuidUsuario', '$correoGoogle')",
);
await getCallWS();
```

Archivo:

```text
lib/smxSaldifyLogon/smxSaldifyLogon_controller.dart
```

Esto permite que un codigo anonimo se reclame/consolide en base despues de Google login, cuando ya existen:

```text
correoGoogle
uuidUsuario
```

La app lee los campos finales devueltos por el SP:

```text
SYSUSER90_ANFITRION_UUID
SYSUSER90_INVITADO_CORREO
SYSUSER90_INVITADO_UUID
```

Luego guarda el contexto con:

```dart
SmxConstants.setClienteInvitado(...)
_guardarInvitado(...)
```

Regla UI actual:

```text
Con link ?codigo=SF...
  -> solo se muestra Codigo de invitacion + Validar codigo

Sin link
  -> solo se muestra Anfitrion + Cambiar cuenta de Anfitrion + Invitado
```

No se permite ingreso manual de codigo en el logon normal. Para cambiar de invitacion, el usuario debe abrir otro link de invitacion.

Cuando el codigo valida correctamente, no se limpia visualmente el modo codigo antes de navegar. Esto evita el flash donde aparecian por un instante los cards de `Anfitrion` e `Invitado` antes del dashboard.

### Cambio de cuenta de Anfitrion

Se agrego una accion temporal en el logon:

```text
Cambiar cuenta de Anfitrion
```

Objetivo:

- Permitir que un usuario que ya entro como anfitrion pueda elegir otra cuenta de proveedor para entrar nuevamente como anfitrion.
- No mencionar Google en la UI, para mantener el flujo compatible con futuros proveedores.

Reglas:

- Funciona como toggle.
- Al activarse muestra `Se elegira otra cuenta de Anfitrion`.
- Solo fuerza selector en el proximo acceso como anfitrion.
- No afecta el flujo invitado.
- Se limpia automaticamente cuando el acceso como anfitrion termina correctamente.

## 17. Mi red de Venta

Se agrego un nuevo acceso en el menu inferior del cliente, debajo de `Ver historial`:

```text
Mi red de Venta
```

Archivo del menu:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_dashboard_menu.dart
```

La accion devuelve:

```text
mired
```

El dashboard controller abre la nueva pantalla desde:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_dashboard_controller.dart
```

Pantalla creada:

```text
lib/smxSaldify/smxSaldify_screens/saldify_mired/smxSaldiFy_mired.dart
```

Controller creado:

```text
lib/smxSaldify/smxSaldify_screens/saldify_mired/smxSaldiFy_mired_controller.dart
```

Estado actual:

- Pantalla funcional.
- Usa el fondo estandar de Saldify.
- Usa `SmxSaldifyScreenHeader`.
- Titulo: `Mi red de Venta`.
- `sectionLabel`: nombre del cliente seleccionado.
- Carga los datos con `SmxCallBaseStateful<SmxSaldiFyMiRedController>`.
- Recibe como raiz el `idSysuser11` del cliente seleccionado.
- Dibuja el arbol con `InteractiveViewer`, `CustomPaint` y tarjetas posicionadas en un `Stack`.
- El nodo raiz queda centrado inicialmente en el visor.
- El usuario puede hacer pan y zoom sobre la red.

SP usado:

```sql
select * from QRY_SYSUSER11_MI_RED(:id_sysuser11_raiz)
```

El SP devuelve:

```text
NIVEL
PATH
ID_SYSUSER11
RELA_SYSUSER10_PADRE
RELA_SYSUSER10_HIJO
SYSUSER11_STATUS
SYSUSER10_NOMBRES
SYSUSER10_APELLIDOS
SYSUSER10_CORREO
SYSUSER10_TELEFONO
```

La fila visible siempre representa al usuario de `RELA_SYSUSER10_HIJO`.

`RELA_SYSUSER10_PADRE` sirve para conectar el arbol, pero los datos que se pintan en la tarjeta se leen desde el hijo.

### Consulta recursiva

La red se resuelve desde `SYSUSER11_DET_CONTACTOS` usando un CTE recursivo.

La relacion que abre el siguiente nivel es:

```sql
join red r on c.rela_sysuser10_anfitrion = r.rela_sysuser10_hijo
```

Esto significa:

```text
El hijo del nivel actual pasa a ser anfitrion del siguiente nivel.
```

Por eso el arbol permite ver:

```text
Anfitrion -> Cliente -> Cliente como anfitrion -> Clientes de ese cliente
```

Se mantiene un limite tecnico:

```sql
r.nivel < 20
```

Ese limite no es una regla de negocio. Es un guard de seguridad para evitar recorridos infinitos por datos inconsistentes.

### Corte por relacion consigo mismo

Existe un caso especial: un anfitrion puede aparecer como cliente de si mismo.

Ejemplo:

```text
RELA_SYSUSER10_PADRE = 7
RELA_SYSUSER10_HIJO = 7
```

La regla definida:

- Esa fila se muestra.
- No se expande recursivamente.

Condicion en la parte recursiva:

```sql
and r.rela_sysuser10_padre <> r.rela_sysuser10_hijo
```

La condicion se aplica sobre `r` porque corta la expansion del nodo actual. Asi el nodo self-loop puede verse una vez, pero no vuelve a traer toda la red debajo de si mismo.

### Render en Flutter

La pantalla transforma las filas del SP en `SmxMiRedNode`.

El layout visual se calcula a partir de `PATH`:

- `PATH` define jerarquia y orden.
- Los nodos hoja se acomodan horizontalmente.
- Cada padre se centra sobre sus hijos.
- `NIVEL` define la posicion vertical.

Componentes internos:

- `_TreeLayout`: calcula posiciones.
- `_TreeConnectionsPainter`: dibuja lineas y puntos de conexion.
- `_TreeNodeCard`: dibuja cada usuario.
- `_MiRedTree`: contiene el visor interactivo.

La tarjeta grande funciona como una lupa/contenedor visual de la red. El contenido puede ser mas grande que el viewport y se explora con `InteractiveViewer`.

Objetivo funcional:

Mostrar la red descendente del cliente seleccionado cuando ese cliente tambien actua como anfitrion dentro de `SYSUSER11_DET_CONTACTOS`.

## 18. Dialogos de mensajes, decisiones y validaciones

Despues de crear la pantalla `Mi red de Venta`, se limpio el manejo de dialogos de mensajes y decisiones para que Saldify use un mismo look visual.

### Dialogo de decision

Se creo un dialogo centralizado para decisiones de dos acciones:

```text
lib/smxLayout/smx_decision_dialog.dart
```

Funcion principal:

```dart
showSmxDecisionDialog(...)
```

Uso:

- Confirmar archivar/reactivar clientes.
- Confirmar activar/eliminar clientes pendientes.
- Confirmar activar/archivar productos.
- Confirmar eliminar compras/pagos.
- Confirmar procesos irreversibles como rechazo de pago.

Caracteristicas:

- Estilo visual Saldify con fondo claro y burbujas suaves.
- Botones planos, minimalistas, integrados en la franja inferior.
- Textos de acciones parametrizables.
- Icono parametrizable segun el tipo de accion.
- Proporcion reducida para no ocupar demasiado espacio en mobile.

### Dialogo de mensaje

Se creo un dialogo centralizado para mensajes de una sola accion:

```text
lib/smxLayout/smx_message_dialog.dart
```

Funciones principales:

```dart
showSmxValidDialog(...)
showSmxSystemErrorDialog(...)
showSmxMessageDialog(...)
```

Uso:

- Validaciones de datos.
- Errores de sistema.
- Mensajes simples que requieren solo aceptar/cerrar.

El titulo de validacion queda por default como:

```text
Validacion de datos
```

Por eso los flujos de validacion pueden enviar solamente el mensaje:

```dart
showSmxValidDialog(context, mensaje: mensajeValidar);
```

### Validaciones automaticas del core en Saldify

Saldify adopta el camino tecnico documentado en:

```text
documents/architecture/ARCHITECTURE_CRUD_WIDGETS.md
```

Regla usada en pantallas Saldify:

```dart
final mensajeValidar = getValidateOnlyMessage();
if (mensajeValidar != null) {
  showSmxValidDialog(context, mensaje: mensajeValidar);
  return;
}
```

Motivo:

- El core valida y devuelve el mensaje.
- Saldify decide como mostrarlo con su dialogo visual propio.
- Se evita que `validateWidgets(context)` abra el dialogo visual viejo dentro de pantallas Saldify.

Se reemplazaron las llamadas directas a `validateWidgets(context)` en controladores Saldify por `getValidateOnlyMessage()` y `showSmxValidDialog`.

### Limpieza de dialogos viejos

Se reviso `lib` buscando usos directos de:

```text
AlertDialog
CupertinoAlertDialog
showValidDialog
showSystemErrorDialog
showConfirmationDialog
```

Resultado:

- No quedan dialogos viejos de mensajes o decisiones dentro de Saldify.
- Las validaciones usan `showSmxValidDialog`.
- Los errores de sistema usan `showSmxSystemErrorDialog`.
- Las decisiones usan `showSmxDecisionDialog`.

### Lo que no se reemplazo

`showDialogWait` no se considera dialogo de mensaje ni decision.

Uso:

```text
progressbar / loading asincrono
```

Decision:

- Se deja como esta.
- No muestra texto de validacion.
- No reemplaza ni compite con `SmxMessageDialog` o `SmxDecisionDialog`.

Tambien se dejan fuera de esta limpieza los paneles especificos:

- Bottom sheets de pantallas.
- Modal del assistant.
- Centro de acciones pendientes que entra desde la derecha.

Esos componentes son superficies funcionales de UI, no dialogos genericos de mensaje o decision.
