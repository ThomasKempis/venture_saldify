# Saldify - Resumen Maestro de Arquitectura 01

Este documento sirve para abrir un nuevo chat o retomar el proyecto sin perder el contexto acumulado. El proyecto combina tres capas que deben respetarse juntas:

1. Logica funcional de la app Saldify.
2. Metodologia propietaria Flutter basada en `SmxController` y `SmxRowSet`.
3. Contrato de base de datos Firebird, nomenclatura y stored procedures.

La regla principal: no resolver como Flutter generico si existe un patron de la plataforma. Primero entender la intencion funcional, luego aplicar la metodologia `SmxController`/`SmxRowSet`, y finalmente cuidar que la base entregue datos con la forma que el rowset espera.

## 1. Producto: Que Es Saldify

Saldify es una app para manejar clientes, creditos, compras, pagos, saldos y disponible.

Existen dos modalidades funcionales:

- Modo standalone del anfitrion: el anfitrion crea sus clientes y administra compras, pagos y credito. El cliente no necesariamente entra a la app.
- Modo ecosistema: el anfitrion invita al cliente. El cliente entra al sistema y tambien puede registrar operaciones, consultar datos y participar del flujo.

Ambas modalidades deben convivir. No se debe asumir que todo cliente invitado entrara a la app. Tampoco se debe asumir que todo anfitrion quiere usar invitaciones.

## 2. Actores Principales

### Anfitrion

Es el usuario principal que administra su red financiera. Puede:

- Crear clientes.
- Invitar clientes.
- Ver clientes pendientes.
- Activar clientes pendientes manualmente.
- Configurar credito.
- Registrar compras.
- Registrar pagos.
- Ver resumen financiero.

### Cliente

Es el usuario que puede estar relacionado a un anfitrion. Puede existir de varias formas:

- Creado por logon propio.
- Creado por el anfitrion como cliente pendiente.
- Relacionado con un anfitrion mediante `SYSUSER11_DET_CONTACTOS`.
- Aceptado o pendiente segun `SYSUSER11_STATUS`.

## 3. Tablas Principales

### SYSUSER10_CAB_MOVIL

Tabla de usuarios/clientes moviles. Se crea cuando un usuario se logonea, pero tambien puede ser creada por el anfitrion al dar de alta un cliente.

Campos importantes:

- `ID_SYSUSER10`: id principal.
- `RELA_SYSJSON02`: si no es null, indica que el usuario ya se conecto/logoneo con identidad propia.
- `SYSUSER10_UUID`: uuid del usuario.
- `SYSUSER10_NOMBRES`
- `SYSUSER10_APELLIDOS`
- `SYSUSER10_TELEFONO`
- `SYSUSER10_CORREO`
- `SYSUSER10_CORREO_01`
- `SYSUSER10_FECHA`
- `SYSUSER10_GEOLOC_ULT`
- `SYSUSER10_FAPL`

Reglas:

- Si el anfitrion crea un cliente manualmente, puede quedar `RELA_SYSJSON02` null.
- Si el usuario se conecto por logon, `RELA_SYSJSON02` no debe tratarse como editable libremente por otro anfitrion.
- `SYSUSER10_CORREO_01` suele ser igual a `SYSUSER10_CORREO`.
- `SYSUSER10_GEOLOC_ULT` puede iniciar como cadena vacia para que el usuario active localizacion despues.

### SYSUSER11_DET_CONTACTOS

Relacion entre anfitrion y cliente.

Estado actual de la logica de relacion:

- `RELA_SYSUSER10` representa al cliente/invitado.
- `RELA_SYSUSER10_ANFITRION` representa al anfitrion.
- `ID_SYSUSER11` es el id de la relacion.
- `SYSUSER11_STATUS`:
  - `0`: pendiente.
  - `1`: aceptado/activo.
  - `2`: rechazado, si se usa.
- `SYSUSER11_FAPL`

Regla importante:

- El campo antiguo `RELA_SYSUSER10_INVITADO` ya no debe usarse. Fue eliminado conceptualmente y no debe quedar ninguna referencia nueva.
- El indice logico/unico debe pensarse como anfitrion + cliente.

### SYSUSER12_DEP_CLIENTES

Configuracion de credito del cliente con el anfitrion.

Campos importantes:

- `RELA_SYSUSER11`: relacion cliente/anfitrion.
- `ID_SYSUSER12`
- `SYSUSER12_CREDITO`
- `SYSUSER12_PLAN`
- `SYSUSER12_CORTE_TIPO`
- `SYSUSER12_CORTE_SEMANA`
- `SYSUSER12_CORTE_DIA`
- `SYSUSER12_FAPL`

`SYSUSER12_PLAN` define como se libera el credito:

- Plan 1: fondo revolvente. Cada pago libera disponible.
- Plan 2: pago completo en corte. No se libera disponible hasta liquidar todo.

Tipos de corte:

- `1`: mensual. `SEMANA = 0`, `DIA` entre 1 y 28. Default visual sugerido: dia 5.
- `2`: quincenal. Seleccion primera quincena o segunda quincena. Primera significa dia 15; segunda significa ultimo dia del mes.
- `3`: semanal. Usa dia de semana. Descripcion funcional: se aplica siempre en la siguiente semana de registro del credito.

### SYSUSER40_DET_COMPRAS

Compras registradas contra una relacion cliente/anfitrion.

Campos:

- `RELA_SYSUSER11`
- `RELA_SYSUSER10_ALTA`: usuario que dio de alta la operacion. Puede ser anfitrion o cliente.
- `ID_SYSUSER40`
- `SYSUSER40_CONCEPTO`
- `SYSUSER40_IMPORTE`
- `SYSUSER40_FECHA`
- `SYSUSER40_FAPL`

### SYSUSER50_DET_PAGOS

Pagos registrados contra una relacion cliente/anfitrion.

Campos:

- `RELA_SYSUSER11`
- `RELA_SYSUSER10_ALTA`: usuario que dio de alta la operacion. Puede ser anfitrion o cliente.
- `ID_SYSUSER50`
- `SYSUSER50_REFERENCIA`
- `SYSUSER50_IMPORTE`
- `SYSUSER50_FECHA`
- `SYSUSER50_FAPL`

## 4. Contrato SmxRowSet: ID y FAPL Son Obligatorios

La plataforma `SmxRowSet` espera que los rowsets tengan:

- Un campo `ID_...`
- Un campo `..._FAPL`

Esto aplica incluso para stored procedures de consulta si se consumen como `SmxRowSet`.

Si un stored procedure devuelve solo metricas agregadas y no trae `ID_` ni `_FAPL`, puede fallar con errores tipo:

```text
Null check operator used on a null value
```

Razon: internamente `SmxRowSet` activa una fila y puede consultar `getId()` o `getFapl()`. Si el campo no existe o viene null en escenarios sin datos, se rompe.

Solucion preferida:

- Corregir el stored procedure para que devuelva un `ID_...` y un `..._FAPL` consistentes.

Solucion de apoyo en Flutter si la base aun no lo hace:

```sql
select
  1 as ID_ALIAS,
  current_timestamp as ALIAS_FAPL,
  qry.*
from PROCEDURE(...) qry
```

Pero si ya se resolvio en base, no duplicar esta envoltura en Dart.

## 5. Metodologia Flutter: SmxController y SmxRowSet

La app no debe tratar la base como SQL suelto desde widgets. Se usa el patron:

- `SmxController`
- `SmxRowSet`
- `SmxControllerSendData`
- `data.accion`
- `data.tablaTroncal`
- `data.tablaTroncalRst`
- `rst.setAccion(AccionNN.X)`
- `setDetTransaction` cuando hay detalles dependientes.

### Regla de Accion

Para insertar:

```dart
data.accion = AccionNN.I;
rst.insert();
```

Para actualizar:

```dart
data.accion = AccionNN.W;
rst.first();
rst.setAccion(AccionNN.W);
```

Para borrar:

```dart
data.accion = AccionNN.D;
rst.setAccion(AccionNN.D);
```

Muy importante: en esta plataforma puede parecer redundante marcar `data.accion` y tambien `rst.setAccion`, pero no lo es. El controlador necesita saber la accion principal porque puede haber tabla troncal y detalles con acciones distintas.

Ejemplo conceptual:

- Troncal update.
- Detalles insert.

Por eso `data.accion` no se debe omitir.

### Rowset Troncal y Detalle

Cuando se crea un cliente nuevo desde anfitrion:

- Troncal: `SYSUSER10_CAB_MOVIL`.
- Detalle: `SYSUSER11_DET_CONTACTOS`, si corresponde.
- El detalle debe ir en la transaccion del troncal mediante `setDetTransaction`.

Cuando se modifica un cliente pendiente existente:

- Ya existe la relacion `SYSUSER11`.
- No se debe volver a crear ni mandar detalle `SYSUSER11`.
- Solo se modifican datos de `SYSUSER10` si la regla funcional permite editarlo.

### No Inventar Lectura Manual de IDs

Si el rowset esta bien posicionado, usar:

```dart
rst.getId()
```

Evitar hacer esto si no es necesario:

```dart
rst.getValue('ID_SYSUSER11')
```

La plataforma ya conoce su id field mediante `getIdFieldName()`.

### index() Activa Fila

`rst.index(pos)` posiciona el rowset y activa `_rowActivo`.

Luego `getId()` usa la fila activa.

Regla: si se va a usar `getId()`, asegurar que el rowset tenga fila activa.

### Recorrer Todo El RowSet

Para recorrer todas las filas de un `SmxRowSet`, especialmente para sumar una columna o procesar todos los registros, usar el cursor del rowset:

```dart
double total = 0.0;

rst.beforeFirst();
while (rst.next()) {
  total += rst.getValue('CAMPO_IMPORTE');
}
```

No es necesario posicionar manualmente con `index(pos)` para estos casos. Si el campo ya viene tipado desde base, por ejemplo como `double`, evitar conversiones innecesarias a string.

## 6. SmxRowSetTrack

`SmxRowSetTrack` es una mejora de la plataforma, no una utilidad local de Saldify.

Nota actual:

- Se probo primero en Saldify y funciono bien.
- Luego se promovio al core/paquete de la plataforma.
- Ya no debe recrearse dentro de `lib/smxApis`.
- En Saldify debe importarse desde el paquete/core correspondiente.
- Si aparece una version local antigua, debe considerarse obsoleta o pendiente de limpieza.

Se usa para evitar conflictos entre llamadas simultaneas a base en controladores que comparten la infraestructura de websocket/adaptador.

Uso:

```dart
await SmxRowSetTrack.run(
  controller: this,
  call: () => getRowSetFuture('QRY_SYSUSER11'),
);
```

La idea:

- No cambiar globalmente `getRowSetFuture`.
- Envolver solo llamadas que necesitan orden o que chocaban entre controladores.
- Mantener la trazabilidad por alias del controller.
- Evitar que un controlador "pise" la llamada de otro cuando ambos disparan cargas en el dashboard.

No encapsular todo el sistema automaticamente sin pensar, porque algunas llamadas podrian funcionar bien en paralelo y serializarlas haria la app mas lenta.

## 7. Dashboard Anfitrion

Ruta principal:

```text
lib/smxSaldify/smxSaldify_dashboard/
```

Componentes relevantes:

- `smxSaldiFy_dashboard.dart`
- `smxSaldiFy_dashboard_controller.dart`
- `smxSaldiFy_dashboard_menu.dart`
- `smxSaldiFy_red_clientes/`
- `smxSaldiFy_invita_clientes/`
- `smxSaldiFy_acciones_rapidas/`
- `smxSaldiFy_clientes/`
- `smxSaldiFy_clientes_pendientes/`

### Red Financiera

El titulo actual debe ser:

```text
Tu red financiera
```

Se reemplazo el mock por datos reales desde:

```sql
QRY_SYSUSER11_SALDOS_ANFITRION(ID_SYSUSER10)
```

El widget visual reutilizable esta en:

```text
lib/smxApis/smxSaldiFy_credito_resumen.dart
```

Muestra:

- Credito.
- Disponible.
- Compras.
- Pagos.
- Saldo/balance.

En movil se adapto para compactar el radial y las tarjetas dentro de un solo card.

### Skeletons

Los skeletons se separaron por modulo.

Bloque base reutilizable:

```text
lib/smxApis/smxSaldiFy_skeleton_block.dart
```

Skeleton de red financiera:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_red_clientes/smxSaldiFy_red_clientes_skeleton.dart
```

Skeleton de clientes:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_clientes/smxSaldiFy_clientes_skeleton.dart
```

## 8. Clientes y Clientes Pendientes

### Clientes Activos

Se cargan con `QRY_SYSUSER11` pasando status `1`.

La lista activa debe mostrar datos del cliente y saldos:

- Nombre.
- Status.
- Corte.
- Credito.
- Disponible.
- Compras.
- Pagos.
- Saldo.

### Clientes Pendientes

Se cargan con `QRY_SYSUSER11` pasando status `0`, o con el alias/procedure separado que corresponda segun el codigo actual.

Debe mostrar solo lo necesario:

- Nombre.
- Correo.
- Telefono.

Si no hay pendientes, no debe aparecer titulo ni widget.

Acciones:

- Tap/click en pendiente abre modulo de cliente para editar datos pendientes.
- Swipe/borrar elimina solo la relacion `SYSUSER11` de ese anfitrion, no borra `SYSUSER10`.
- Activar pendiente cambia `SYSUSER11_STATUS` de `0` a `1`, para permitir configurar credito sin que el cliente se haya logoneado.

Importante:

- Si se activa pendiente en memoria, debe moverse visualmente de pendientes a clientes.
- Para grabar el update de status en base se necesita `data.accion = AccionNN.W`.

## 9. Invitacion de Clientes

La tarjeta de invitacion permite copiar link o WhatsApp.

El link usa parametros:

- `uuid_anfitrion`
- `uuid_invitado`
- `correo_invitado`

Se renombraron internamente como keys, no como "param" si asi esta en `SmxConstants`.

Reglas:

- `uuid_anfitrion` es del anfitrion.
- `uuid_invitado` es del cliente invitado.
- Si se invita desde lista de clientes existentes, debe tomar datos desde el rowset cargado, no desde mock.

Se hizo merge de clientes activos + pendientes para poder invitar tambien a pendientes.

Dashboard usa `ValueNotifier`/`ValueListenableBuilder` para no refrescar todo y para habilitar invitacion solo cuando el merge esta listo.

## 10. Alta/Edicion de Cliente

Modulo actual en screens:

```text
lib/smxSaldify/smxSaldify_screens/saldify_cliente/
```

Se renombro conceptualmente de add/update hacia cliente/perfil segun el flujo.

Regla principal:

- Si se abre desde acciones rapidas sin id: alta.
- Si se abre desde cliente pendiente con id: modificacion del cliente pendiente.

### Flujo de Correo

La pantalla debe comenzar con una card de busqueda por correo.

En el primer input de correo:

- El usuario escribe el correo sin dominio.
- Visualmente se muestra `@gmail.com`.
- Internamente se concatena gmail.
- El correo debe normalizarse en minuscula.

En el segundo card de datos:

- El correo se muestra, no se edita.
- No necesita label `@gmail.com`.

### QRY_SYSUSER10_FIND

Stored procedure de busqueda por correo y anfitrion.

Entrada:

- `id_sysuser10_anfitrion`
- `correo`
- parametro modo si se agrego: alta/update

Salida esperada:

- `EDITA`
- `ID_SYSUSER10`
- datos del usuario
- `SYSUSER10_FAPL`
- etc.

Semantica actual de `EDITA`:

- `0`: existe pero no se puede editar.
- `1`: existe y se puede editar/agregar relacion.
- `2`: ya esta relacionado con este anfitrion.

Reglas:

- Si no trae registro: se puede capturar datos nuevos y crear `SYSUSER10` + `SYSUSER11`.
- Si trae `EDITA = 1`: se pueden mostrar datos y editar si aplica; si es alta, normalmente solo se agrega la relacion `SYSUSER11` si el usuario ya existe.
- Si trae `EDITA = 0`: mostrar datos pero no permitir editar. Tampoco registrar si es modificacion y la regla lo prohibe.
- Si trae `EDITA = 2`: ya esta en la lista de este anfitrion; mostrar mensaje y no bajar/mostrar segundo card para editar como si fuera nuevo.

No buscar relacion en Flutter si el store procedure ya devuelve `EDITA`. La logica de relacion debe quedar centralizada en base.

## 11. Credito

Modulo:

```text
lib/smxSaldify/smxSaldify_screens/saldify_credito/
```

Incluye seleccion de plan antes de la pantalla de configuracion:

- Paga y libera credito.
- Paga completo en el corte.

Se crearon tarjetas visuales con dibujo/canvas o asset segun el estado actual. La idea final fue integrar la explicacion dentro de tarjetas tipo credito, no imagen gigante estirada.

Al guardar credito:

- Si no existe `SYSUSER12`, insertar.
- Si existe, actualizar.
- Para update, marcar tanto `data.accion = AccionNN.W` como `rst.setAccion(AccionNN.W)`.

## 12. Compras

Modulo:

```text
lib/smxSaldify/smxSaldify_screens/saldify_compras/
```

Usa `SmxController` porque graba en base.

Tabla:

```text
SYSUSER40_DET_COMPRAS
```

Reglas:

- Se usa rowset vacio como modelo para grabar.
- Existe o debe existir en `SmxConstants` un rowset tipo `rstCompraVacia`.
- Si esta null, se carga una vez desde:

```sql
select * from SYSUSER40_DET_COMPRAS where 1 = 0
```

- Luego se copia para crear rowset activo de grabacion.
- Al agregar compra se deben limpiar inputs.
- En la pantalla de compras, mientras el usuario agrega detalles, se actualizan en memoria:
  - total de compras de la sesion/pantalla,
  - saldo,
  - disponible.
- Al regresar al dashboard, la base vuelve a ser la verdad final.

No confundir:

- No se pidio mostrar necesariamente todas las compras historicas.
- Puede haber una lista vacia/local para la sesion de carga.

## 13. Pagos

Modulo:

```text
lib/smxSaldify/smxSaldify_screens/saldify_pagos/
```

Usa el mismo patron que compras.

Tabla:

```text
SYSUSER50_DET_PAGOS
```

Diferencia principal:

- Campo descripcion es `SYSUSER50_REFERENCIA`, no concepto.
- Existe o debe existir en `SmxConstants` un rowset tipo `rstPagoVacio`.

## 14. Saldos y Formulas

Stored procedure base por cliente:

```sql
QRY_SYSUSER11_SALDOS(RELA_SYSUSER12)
```

Formula:

```text
compras = sum(SYSUSER40_IMPORTE)
pagos = sum(SYSUSER50_IMPORTE)
balance/saldo = compras - pagos
disponible = credito - balance
```

Equivalente:

```text
disponible = credito - (compras - pagos)
saldo = compras - pagos
```

Reglas:

- Si compras o pagos es null, usar 0.
- El saldo pendiente debe ser menor o igual al credito para permitir mas compras.
- Para fondo revolvente, cada pago libera disponible.
- Para pago total, la regla de liberacion puede depender de que liquide todo el saldo.

Stored procedure de anfitrion:

```sql
QRY_SYSUSER11_SALDOS_ANFITRION(ID_SYSUSER10)
```

Debe sumar:

- credito total.
- disponible total.
- compras realizadas.
- pagos recibidos.
- saldo pendiente.

Debe devolver tambien `ID_...` y `..._FAPL` para rowset.

## 15. Menu Inferior de Cliente

En tarjetas de clientes activos, al tocar se abre menu inferior con opciones:

- Agregar compra.
- Registrar pago.
- Actualizar credito.
- Ver historial.

El widget del menu fue encapsulado:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_dashboard_menu.dart
```

Usa logo `logo_cab` si esta disponible, ajustado a tamano razonable. Se quito boton cancelar porque el bottom sheet se puede cerrar con gesto/tap fuera.

## 16. Logon Google

Se ajusto el segundo boton para forzar seleccion de cuenta Google.

Problema previo:

- Google tomaba por default la primera cuenta.

Solucion conceptual:

- Forzar sign out o modo seleccion segun `google_sign_in`/flujo usado.

Revisar `smxLogonMovil` si vuelve a aparecer.

## 17. UI y Diseno

Estilo general:

- Fondo verde/azul degradado.
- Cards claras tipo gris/blanco suave.
- Iconos verdes.
- Sin saturar con botones.
- Mobile primero, pero responsive a tablet/desktop.

Reglas aprendidas:

- Evitar imagenes gigantes dentro de cards.
- Evitar estirar PNGs.
- Si se usa canvas/custom paint, separar en archivo si crece.
- En mobile, compactar cards para que no oculten demasiado dashboard.
- En desktop/tablet puede usarse layout mas amplio.

## 18. Cosas Que No Debe Hacer Un Nuevo Chat

- No usar `RELA_SYSUSER10_INVITADO`.
- No crear SQL directo desde widgets para grabar si existe patron `SmxController`.
- No olvidar `data.accion`.
- No olvidar `rst.setAccion(...)` en updates/deletes.
- No asumir que `getValue('ID...')` es mejor que `getId()`.
- No refrescar toda la lista desde base si se puede actualizar rowset en memoria, salvo que el flujo actual necesite verdad final de base.
- No duplicar logica de relacion en Flutter si ya la resuelve un stored procedure.
- No usar mocks si ya existe rowset real de base.
- No dejar stored procedures consumidos por rowset sin `ID_...` y `..._FAPL`.
- No mezclar Saldify anfitrion (`smxSaldify`) con Saldify cliente (`smxSaldifyCliente`). Son entradas distintas.

## 19. Directorios Clave

```text
lib/smxApis/
lib/smxSaldify/
lib/smxSaldify/smxSaldify_dashboard/
lib/smxSaldify/smxSaldify_screens/
lib/smxSaldify/smxSaldify_screens/saldify_cliente/
lib/smxSaldify/smxSaldify_screens/saldify_credito/
lib/smxSaldify/smxSaldify_screens/saldify_compras/
lib/smxSaldify/smxSaldify_screens/saldify_pagos/
lib/smxSaldifyCliente/
```

## 20. Frase Guia Para Continuar

Antes de tocar codigo en este proyecto, revisar el patron existente alrededor. Este sistema no es Flutter generico: es una plataforma propia con contrato fuerte entre base Firebird, `SmxController`, `SmxRowSet` y widgets.

Si algo parece redundante, probablemente existe por la transaccion troncal/detalle o por la forma en que el rowset mantiene estado, id activo y fapl.
