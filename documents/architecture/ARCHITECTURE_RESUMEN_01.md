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

### Red Distribuida

Saldify no debe entenderse solo como una relacion plana:

```text
Anfitrion -> Cliente
```

El modelo real puede crecer como una red distribuida de vendedores, distribuidores, mayoristas, minoristas y clientes.

Una misma persona puede ser:

- Cliente/invitado dentro de la red de un anfitrion superior.
- Anfitrion de su propia red de clientes.

Ejemplo:

```text
Mayorista
  -> Distribuidor
       -> Minorista
            -> Cliente final
```

En terminos de datos, el usuario sigue siendo un `SYSUSER10`. Lo que cambia es el rol que ocupa en cada relacion `SYSUSER11_DET_CONTACTOS`.

Regla conceptual:

```text
El rol no vive fijo en el usuario.
El rol se interpreta segun la relacion.
```

Por eso no se debe asumir que un cliente no puede ser anfitrion. Un usuario puede entrar como invitado para ver su relacion con un anfitrion y tambien entrar como anfitrion para administrar su propia red.

## 2. Actores Principales

### Anfitrion

Es el usuario que, dentro de una relacion o contexto de pantalla, administra una red financiera. Puede:

- Crear clientes.
- Invitar clientes.
- Ver clientes pendientes.
- Activar clientes pendientes manualmente.
- Configurar credito.
- Registrar compras.
- Registrar pagos.
- Ver resumen financiero.

### Cliente

Es el usuario que, dentro de una relacion especifica, esta asociado a un anfitrion. Puede existir de varias formas:

- Creado por logon propio.
- Creado por el anfitrion como cliente pendiente.
- Relacionado con un anfitrion mediante `SYSUSER11_DET_CONTACTOS`.
- Pendiente, activo o archivado segun `SYSUSER11_STATUS`.

Importante:

- Cliente no significa usuario final permanente.
- Anfitrion no significa usuario raiz permanente.
- Ambos son roles funcionales segun la relacion activa.

## 2.1. Formas de Llegar a Saldify

Desde el logon existen dos puertas conceptuales:

### Entrada como Anfitrion

El anfitrion no necesita invitacion.

Flujo:

```text
Google login
  -> SmxLogonMovil crea/actualiza SYSUSER10
  -> entra como anfitrion
  -> puede administrar clientes, credito, compras, pagos e invitaciones
```

La identidad del anfitrion queda asociada a `SYSUSER10_UUID`. Ese uuid se usa para generar invitaciones.

### Entrada como Invitado

El invitado siempre entra mediante una estructura de invitacion.

Flujo:

```text
Codigo/link de invitacion
  -> Google login
  -> SmxLogonMovil crea/actualiza SYSUSER10
  -> se valida/consolida la invitacion
  -> se crea o recupera la relacion SYSUSER11 con el anfitrion
  -> entra como cliente invitado si la relacion corresponde
```

En esta etapa ya se conoce minimo:

- Correo Google autenticado.
- `SYSUSER10_UUID` del usuario autenticado.

Por eso las invitaciones abiertas pueden consolidarse despues del login, tomando los datos reales del usuario que tomo el codigo.

### Cliente Pendiente

En Saldify, un cliente pendiente no es una solicitud externa ni una invitacion sin aceptar.

Concepto correcto:

```text
Cliente pendiente = cliente ya vinculado/activo en la red del anfitrion,
pero pendiente de asignarle credito/configuracion comercial.
```

Puede nacer por:

- Alta manual del anfitrion.
- Invitacion anonima tomada por un invitado autenticado.
- Invitacion por correo Gmail.
- Reenvio de acceso a un usuario existente, si aun no tiene credito.

Una vez asignado credito/plan/corte, pasa al flujo normal de clientes activos.

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
  - `2`: archivado.
- `SYSUSER11_FAPL`

Regla importante:

- El campo antiguo `RELA_SYSUSER10_INVITADO` ya no debe usarse. Fue eliminado conceptualmente y no debe quedar ninguna referencia nueva.
- El indice logico/unico debe pensarse como anfitrion + cliente.
- `SYSUSER11_STATUS = 2` no significa rechazado: representa una relacion archivada por el anfitrion.

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

### Espera En Operaciones De Base

Para acciones que llaman base de datos o stored procedures, usar `showDialogWait(...)` desde el controller.

```dart
await showDialogWait(context, () async {
  await getRowSetFuture(alias);
});
```

No duplicar ese estado con flags locales de UI como `_isLoading`, `loadingRows` o spinners en filas/botones para la misma accion.

Regla practica:

- `loadingBuilder`/skeletons: carga inicial de widgets.
- `showDialogWait(...)`: acciones de base de datos desde controller.
- Flags locales: solo interacciones visuales/locales sin llamada a base.

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

### getValue() Ya Normaliza Segun Tipo

`SmxRowSet.getValue(field)` no es una lectura cruda de mapa. Internamente revisa el tipo del campo y devuelve valores normalizados.

Regla practica:

- Si el campo viene tipado como numerico (`INT`, `LNG`, `DBL`), leer directo con `getValue()`.
- No envolver cada lectura numerica en helpers con `try/catch`, `double.tryParse()` o conversion a string si el rowset ya trae metadata correcta.
- No crear helpers locales tipo `_getInt(field)`, `_getDouble(field)` o `_toDouble(value)` cuando el campo ya viene tipado. `getValue()` ya devuelve `0`, `0.0` o el valor numerico correspondiente segun la metadata.
- Para `DBL`, valores `null` o vacios regresan como `0.0`.
- Para `INT`/`LNG`, valores `null` o vacios regresan como `0`.
- Para `STR`, valores nulos regresan como cadena vacia.

Ejemplo recomendado:

```dart
final credito = rstMetricas.getValue('SYSUSER12_CREDITO');
final saldo = rstMetricas.getValue('SYSUSER12_BALANCE');
final plan = rstPlan.getValue('SYSUSER12_PLAN');
final diasAlVto = rstPlan.getValue('DIAS_AL_VTO');
```

Agregar conversion manual solo cuando el dato venga deliberadamente como texto o el origen no tenga tipo confiable.

### Buffer De RowSets Por Alias

`getRowSetFuture(alias)` no vuelve al servidor si el alias ya existe cargado en el buffer del controller.

Regla practica:

- Usar alias fijo para datos casi estables durante la vida del controller.
- No llamar `removeSql(alias)` si se quiere reutilizar lo ya cargado.
- Llamar `removeSql(alias)` solo cuando se necesita forzar una lectura nueva desde base.
- El buffer vive en el controller; si el controller se recrea, el dato se vuelve a cargar.

### Formatos Estandar Desde SmxRowSet

Para mostrar importes o fechas en pantalla, usar los helpers del `SmxRowSet` en lugar de crear formateadores locales repetidos.

Importes:

```dart
final credito = rstMetricas.getValueFormatAmount('SYSUSER12_CREDITO');
final saldo = SmxRowSet.formatAmount(valor);
```

Fechas:

```dart
final fecha = rstHistorial.getValueFormatDate('SYSUSER90_FECHA');
final fechaManual = SmxRowSet.formatDate(valor);
```

`getValueFormatAmount(field)` lee el campo con `getValue(field)` y aplica el formato monetario estandar. `getValueFormatDate(field)` lee el campo con `getValue(field)` y aplica el formato estandar `dd/mm/yyyy`.

Regla practica:

- No crear helpers locales tipo `_formatAmount`, `_formatMoney`, `_formatDate` o conversiones manuales si el formato estandar del rowset alcanza.
- Mantener helpers locales solo cuando la pantalla necesite un formato visual distinto, por ejemplo una fecha compacta tipo `30 Jun`.
- Si un formato especial se repite en varias pantallas, promoverlo al `SmxRowSet` o a una API comun antes de duplicarlo.

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

La invitacion es una regla de acceso/vinculo. El canal de envio no define la invitacion.

Regla clave:

```text
WhatsApp, telefono, copiar link y QR son canales de transporte.
No forman parte de la regla de invitacion.
```

El telefono solo sirve para abrir WhatsApp hacia un numero y pegar el mensaje con el link/codigo. No debe incidir en la validacion de la invitacion.

### Tabla de codigos

La invitacion se registra en:

```text
SYSUSER90_TBL_SALDIFY
```

Campos conceptuales:

```text
SYSUSER90_CODIGO
SYSUSER90_ANFITRION_UUID
SYSUSER90_INVITADO_CORREO
SYSUSER90_INVITADO_UUID
SYSUSER90_FAPL
```

El codigo visible mantiene el formato:

```text
SF 1234 5678 9012
```

Internamente se normaliza como:

```text
SF123456789012
```

El codigo debe tratarse como llave publica corta. El tipo de invitacion se deduce por los campos guardados en base, no por "descifrar" el numero.

### Tipos de invitacion

#### 1. Invitacion anonima / abierta

Se usa cuando el anfitrion quiere compartir su acceso sin saber todavia quien se conectara.

Guarda:

```text
SYSUSER90_CODIGO
SYSUSER90_ANFITRION_UUID
SYSUSER90_INVITADO_CORREO = ''
SYSUSER90_INVITADO_UUID = ''
```

Flujo:

```text
Anfitrion genera codigo/link/QR
  -> Invitado abre link o ingresa codigo
  -> Google login
  -> SmxLogonMovil crea/actualiza SYSUSER10
  -> se consolida SYSUSER90 con correo + uuid del invitado autenticado
  -> se crea/recupera relacion SYSUSER11
  -> queda como cliente pendiente de credito si aun no tiene credito
```

Consolidacion esperada:

```sql
update SYSUSER90_TBL_SALDIFY
set
  SYSUSER90_INVITADO_CORREO = :correo_invitado,
  SYSUSER90_INVITADO_UUID = :uuid_invitado
where SYSUSER90_CODIGO = :codigo
  and coalesce(SYSUSER90_INVITADO_CORREO, '') = ''
  and coalesce(SYSUSER90_INVITADO_UUID, '') = '';
```

Debe hacerse desde base/stored procedure para controlar concurrencia. Una vez consolidado, ese codigo queda tomado por ese usuario y ya valida como invitacion especifica.

La validacion/consolidacion no debe depender del `uuid_anfitrion` recibido por URL. El `codigo` es la llave publica corta; el `uuid_anfitrion` confiable se recupera desde `SYSUSER90_TBL_SALDIFY`.

#### 2. Invitacion a usuario existente

Se usa para reenviar acceso a clientes que ya estan en la red del anfitrion, sean clientes activos o pendientes de credito.

Guarda:

```text
SYSUSER90_CODIGO
SYSUSER90_ANFITRION_UUID
SYSUSER90_INVITADO_UUID
SYSUSER90_INVITADO_CORREO = ''
```

El codigo solo debe validar para el usuario autenticado cuyo `SYSUSER10_UUID` coincide con `SYSUSER90_INVITADO_UUID`.

Regla:

- Si se invita desde lista de clientes existentes, debe tomar datos desde el rowset real cargado.
- No debe depender de mock.
- Debe poder incluir clientes activos y clientes pendientes de credito.

#### 3. Invitacion especial por correo Gmail

Se usa cuando el anfitrion no tiene aun el uuid del invitado, pero quiere restringir la invitacion a un correo Google/Gmail especifico.

Guarda inicialmente:

```text
SYSUSER90_CODIGO
SYSUSER90_ANFITRION_UUID
SYSUSER90_INVITADO_CORREO
SYSUSER90_INVITADO_UUID = ''
```

Al validar:

- El correo Google autenticado debe coincidir con `SYSUSER90_INVITADO_CORREO`.
- Despues del login ya existe/queda actualizado `SYSUSER10`.
- Puede consolidarse `SYSUSER90_INVITADO_UUID` con el uuid real del usuario.

### Validacion de invitacion desde logon

La validacion del codigo sucede despues de Google login, por lo que ya se conoce:

```text
correoGoogle
uuidUsuario
```

Reglas:

```text
codigo no existe -> error
anfitrion_uuid vacio -> error
correo vacio + uuid vacio -> invitacion anonima; consolidar con usuario autenticado
correo lleno + uuid vacio -> validar correo Google; consolidar uuid
correo vacio + uuid lleno -> validar uuid del usuario
correo lleno + uuid lleno -> invitacion ya consolidada; validar ambos cuando aplique
```

Luego se setea el contexto funcional:

```dart
SmxConstants.setClienteInvitado(
  uuidAnfitrion: uuidAnfitrion,
  correoInvitado: correoGoogle,
  uuidInvitado: uuidUsuario,
);
```

Implementacion actual:

```text
SmxSaldifyLogonController.isValidaIntoDataBase
  -> SELECT * FROM UPDATE_SYSUSER90(codigo, uuidUsuario, correoGoogle)
  -> addSTrans(...)
  -> getCallWS()
```

`UPDATE_SYSUSER90` devuelve los campos finales de la invitacion. Si el codigo era anonimo, el SP puede actualizar `SYSUSER90_INVITADO_CORREO` y `SYSUSER90_INVITADO_UUID` usando los datos reales del usuario autenticado.

La app ya no necesita que la URL traiga `uuid_anfitrion`, `uuid_invitado` o `correo_invitado` para validar el acceso. La URL puede traer solo:

```text
?codigo=SF...
```

### Organizacion actual de invitaciones en dashboard

La tarjeta de `Invitar clientes` del dashboard debe seguir siendo visible e importante porque impulsa el crecimiento de la red del anfitrion.

Al tocar el QR simulado de la tarjeta se abre una hoja inferior enfocada solo en generar/copiar invitaciones:

```text
1. Invitacion anonima abierta
   QR grande + codigo + boton de link.

2. Invitacion por correo Gmail
   Campo donde el anfitrion escribe solo el nombre del correo.
   El sufijo `@gmail.com` se muestra fijo.

3. Mensaje
   Area de estado donde se muestran validaciones y confirmaciones de copiado.
```

Los mensajes de la hoja no usan modal para validaciones simples. Se muestran en el area `Mensaje`, por ejemplo:

```text
Se copio el link anonimo
Se copio link por correo
Ingrese solo el nombre, sin @gmail.com.
```

La generacion y armado de links se centraliza en:

```text
lib/smxSaldify/smxSaldify_dashboard/smxSaldiFy_invita_clientes/smxSaldiFy_invita_service.dart
```

Clases principales:

```text
SmxSaldifyInvitacionTipo
SmxSaldifyInvitacionParametros
SmxSaldifyInvitacionLink
SmxSaldifyInvitaService
SmxCodeInvitado
```

Links por cliente existente:

- En clientes activos, el menu inferior del cliente incluye un boton circular de link en el encabezado.
- En clientes pendientes, se agrega una accion `Invitar` junto a `Activar cliente`.
- Ambos usan el uuid real del cliente desde `QRY_SYSUSER11`/rowset de clientes.
- La copia se centraliza en `smxSaldiFy_invita_copy.dart`.

WhatsApp y telefono quedan fuera de la regla de invitacion. El usuario puede copiar el link y pegarlo donde prefiera.

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
