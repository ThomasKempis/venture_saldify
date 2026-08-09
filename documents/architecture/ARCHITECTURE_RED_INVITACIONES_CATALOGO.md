# SaldiFY - Red comercial, invitaciones y catalogo heredado

Ultima revision: 2026-07-20

## Proposito

Este documento consolida las decisiones realizadas desde la simplificacion del
logon movil hasta la administracion actual de la red comercial, invitaciones,
clientes administrados, metricas globales, catalogo heredado y carrito.

Debe leerse junto con:

- `ARCHITECTURE.md`
- `ARCHITECTURE_RESUMEN_02.md`, especialmente la resolucion de `SYSUSER10`.
- `ARCHITECTURE_CLIENTE.md`

Los procedimientos almacenados y vistas pertenecen a la base SaldiFY. Flutter
consume sus contratos, pero no debe duplicar sus reglas estructurales.

## 1. Punto de partida: logon consolidado

El cambio base fue eliminar del logon la secuencia separada de buscar, insertar,
guardar y volver a consultar al usuario movil.

`SmxLogonMovil.prepareUser(...)` ejecuta como transaccion con efectos:

```sql
select * from ADD_SYSUSER10(
  :nombres,
  :correo,
  :geolocalizacion
)
```

`ADD_SYSUSER10` debe:

1. Buscar `SYSUSER10_CAB_MOVIL` por correo.
2. Crear el usuario si no existe.
3. Crear o recuperar sus credenciales de `SYSUSER99`.
4. Regresar el rowset definitivo de `SYSUSER10` con
   `SYSUSER99_USUARIO` y `SYSUSER99_PASSWORD`.

Flutter posiciona el rowset con `first()`, cambia la sesion a las credenciales
individuales y ejecuta `resetJsonSend()` antes de continuar.

La foto se carga despues de tener el `ID_SYSUSER10` real y solo cuando
`RELA_SYSJSON02 <= 0`.

## 2. Identidad y rol

### 2.1 Identidad unica

`SYSUSER10_CAB_MOVIL` es la identidad maestra. Sus reglas son:

- correo unico;
- UUID unico;
- una persona no se duplica por cambiar entre modo anfitrion e invitado;
- Google autentica, pero no define el rol comercial.

### 2.2 Rol relacional

El rol depende de `SYSUSER11_DET_CONTACTOS`:

```text
RELA_SYSUSER10             = cliente
RELA_SYSUSER10_ANFITRION   = anfitrion directo
ID_SYSUSER11               = relacion comercial
SYSUSER11_STATUS           = estado
SYSUSER11_STATUS_ACCION    = quien administra los datos
```

Un mismo `SYSUSER10` puede:

- ser anfitrion de su propia red;
- ser cliente de otro anfitrion;
- ejercer ambos roles al mismo tiempo sin duplicar su correo.

No se crea una fila en `SYSUSER11` solo por entrar como anfitrion. La fila existe
cuando ese usuario es cliente de otro anfitrion.

## 3. Arbol comercial

La red se representa como un arbol dirigido:

```text
Anfitrion raiz
  -> cliente/anfitrion
       -> cliente/anfitrion
            -> cliente
```

La regla adoptada es un solo padre directo por cliente. En base se protege con
un indice unico sobre:

```text
SYSUSER11_DET_CONTACTOS.RELA_SYSUSER10
```

Tambien existe la unicidad del par:

```text
RELA_SYSUSER10_ANFITRION, RELA_SYSUSER10
```

La primera restriccion impide que un cliente pertenezca simultaneamente a dos
anfitriones. La segunda evita duplicar una relacion exacta y sirve para busquedas
por anfitrion y cliente.

### 3.1 Invariantes

Toda alta o invitacion debe validar:

1. El anfitrion existe.
2. El invitado existe despues de `prepareUser(...)`.
3. Anfitrion e invitado no son el mismo `SYSUSER10`.
4. El invitado no tiene otro anfitrion directo.
5. La operacion no produce un ciclo.
6. Una relacion archivada no se reactiva de manera silenciosa.
7. Las restricciones unicas de base siguen siendo la ultima defensa ante
   concurrencia.

Un anfitrion raiz que ya tiene descendientes puede convertirse en cliente de
otro anfitrion solamente si no crea un ciclo. Esa operacion traslada de hecho su
subarbol bajo el nuevo padre y debe tratarse como una vinculacion estructural,
no como una simple modificacion visual.

### 3.2 Cambio de red y traslado de subarbol

Un usuario que ya actua como anfitrion puede cambiar de red y llevar consigo
toda su red descendente. Esto no se implementa como copia de clientes ni como
duplicacion de relaciones: se resuelve cambiando el padre directo del
`SYSUSER10` que encabeza ese subarbol.

Ejemplo:

```text
Antes

A
  -> B
       -> C
       -> D

E

Despues de mover B bajo E

A

E
  -> B
       -> C
       -> D
```

En terminos de datos, C y D no cambian de padre. Siguen dependiendo de B. Lo
que cambia es la relacion directa de B:

```text
SYSUSER11_DET_CONTACTOS.RELA_SYSUSER10           = B
SYSUSER11_DET_CONTACTOS.RELA_SYSUSER10_ANFITRION = E
```

Por eso el subarbol se mueve completo de forma natural: todos los descendientes
siguen colgados del mismo `SYSUSER10` raiz del subarbol.

Esta operacion debe distinguirse del alta o invitacion normal:

- Alta/invitacion normal: crea o consolida una relacion nueva cuando el cliente
  no tiene padre directo.
- Cambio de red: modifica el padre directo de un cliente/anfitrion que ya puede
  tener red propia.

El cambio de red debe ser una operacion explicita y transaccional de base. No
debe hacerse desde Flutter editando rowsets sueltos, porque afecta estructura,
metricas, permisos, catalogo heredado y validaciones de ciclo.

Reglas obligatorias:

1. Resolver el `ID_SYSUSER10` que se movera y el `ID_SYSUSER10` del nuevo
   anfitrion.
2. Rechazar si ambos son el mismo usuario.
3. Rechazar si el nuevo anfitrion ya pertenece al subarbol del usuario que se
   intenta mover.
4. Rechazar si hay compras, pagos o saldos pendientes que la politica comercial
   decida bloquear antes del traslado.
5. Registrar el cambio como una modificacion estructural auditable.
6. No duplicar `SYSUSER10_CAB_MOVIL`.
7. No duplicar los descendientes.
8. No crear una segunda relacion activa para el mismo `RELA_SYSUSER10`.

Contrato recomendado de base:

```sql
select * from MOVE_SYSUSER11_RED(
  :id_sysuser10_mover,
  :id_sysuser10_nuevo_anfitrion,
  :id_sysuser10_usuario_alta
)
```

El SP debe devolver una fila de resultado con al menos:

```text
MENSAJE
ID_SYSUSER11
RELA_SYSUSER10
RELA_SYSUSER10_ANFITRION
SYSUSER11_STATUS
SYSUSER11_STATUS_ACCION
```

`MENSAJE = 'OK'` significa que la red fue reubicada. Cualquier otro mensaje se
muestra al usuario y no debe dejar cambios parciales.

Impacto esperado:

- `QRY_SYSUSER11_MI_RED` mostrara automaticamente el subarbol debajo del nuevo
  anfitrion.
- Las metricas de A dejan de incluir a B y su red, si las metricas se calculan
  recursivamente por arbol.
- Las metricas de E empiezan a incluir a B y su red, bajo la misma condicion.
- El catalogo heredado debe recalcular propietario efectivo despues del cambio.
- El acceso de B como anfitrion no cambia; solo cambia a que red superior
  pertenece.
- Los clientes C y D no necesitan reinvitarse.

### 3.3 Algoritmo de validacion del arbol

Para proponer la relacion `invitado -> anfitrion` la base debe comprobar en este
orden:

1. Resolver ambos `ID_SYSUSER10`.
2. Rechazar si son iguales.
3. Buscar por `RELA_SYSUSER10 = id_invitado` si el invitado ya tiene padre.
4. Si el padre encontrado es el mismo anfitrion, reutilizar la relacion.
5. Si el padre encontrado es distinto, rechazar la vinculacion.
6. Para evitar ciclos, comenzar en el anfitrion propuesto y recorrer sus padres
   mediante `RELA_SYSUSER10_ANFITRION`.
7. Si durante ese recorrido aparece `id_invitado`, rechazar porque el anfitrion
   propuesto ya pertenece al subarbol del invitado.
8. Si se llega a una raiz sin encontrarlo, la relacion es estructuralmente
   valida.

El indice unico sobre `RELA_SYSUSER10` garantiza un solo padre y vuelve
determinista el recorrido ascendente. La validacion del SP explica el rechazo al
usuario; el indice protege la regla incluso si dos solicitudes concurrentes
superan la validacion al mismo tiempo.

Para alta e invitacion normal, si el invitado ya tiene un padre distinto, se
rechaza la vinculacion. Para cambio de red, esa misma condicion no se rechaza
automaticamente: se trata como reubicacion explicita y debe pasar por el SP de
movimiento estructural.

## 4. Estados de la relacion

### 4.1 Estado comercial

```text
SYSUSER11_STATUS = 0  pendiente
SYSUSER11_STATUS = 1  activo
SYSUSER11_STATUS = 2  archivado
```

### 4.2 Responsable de los datos

```text
SYSUSER11_STATUS_ACCION = 'A'  administrado por el anfitrion
SYSUSER11_STATUS_ACCION = 'I'  administrado por el invitado
```

`A` permite que el anfitrion modifique los datos del cliente, incluso si la
relacion ya esta activa. Se utiliza para clientes operados fuera de red.

`I` significa que el usuario ya ingreso y tomo control de su cuenta. Desde ese
momento el anfitrion puede consultar sus datos, pero no modificarlos.

Cuando el anfitrion activa un pendiente, Flutter actualiza los dos campos:

```dart
data.accion = AccionNN.W;
rst.setAccion(AccionNN.W);
rst.update('SYSUSER11_STATUS', 1);
rst.update('SYSUSER11_STATUS_ACCION', 'A');
```

Cuando el invitado consolida su ingreso, la base deja la relacion activa y con
`SYSUSER11_STATUS_ACCION = 'I'`.

## 5. Alta y edicion de clientes desde anfitrion

La pantalla recibe:

```dart
SmxSaldiFyCliente(relaSysuser10Cliente: -1) // alta
SmxSaldiFyCliente(relaSysuser10Cliente: id) // edicion
```

### 5.1 Alta

El anfitrion escribe solamente el usuario Gmail. La UI presenta `@gmail.com`
como sufijo no editable y rechaza valores que ya contengan `@`.

Antes de consultar la base valida que el correo no sea el del propio anfitrion.

`QRY_SYSUSER10_FIND(anfitrion, correo)` se usa como consulta de existencia y
mensaje. Si devuelve una fila, `SYSUSER10_STATUS` explica por que no se puede
crear el cliente. Si no devuelve filas, Flutter prepara el alta.

La regla funcional es que el alta administrativa crea solamente una identidad
nueva. Si el correo ya existe, la vinculacion debe realizarse mediante una
invitacion y no apropiando una identidad existente.

El guardado utiliza cabecera-detalle:

```text
SYSUSER10_CAB_MOVIL
  -> SYSUSER11_DET_CONTACTOS
```

La nueva relacion queda:

```text
STATUS = 0
STATUS_ACCION = 'A'
```

### 5.2 Edicion

La edicion carga `SYSUSER10` y su relacion `SYSUSER11` con el anfitrion activo.

- Si `STATUS_ACCION = 'A'`, los campos son editables.
- Si `STATUS_ACCION = 'I'`, los campos quedan en solo lectura.
- La UI informa que el usuario ya se registro en la red y administra sus datos.

La opcion Editar aparece como primera accion en el menu de clientes activos. La
misma regla se aplica al abrir un cliente pendiente.

## 6. Invitaciones

### 6.1 Tipos

A nivel de producto existen dos familias:

```text
SF  invitacion a cliente
SY  invitacion de lealtad para un Anfitrion referido
```

`SF` crea o consolida una relacion comercial en `SYSUSER11`. `SY` registra una
referencia independiente en `SYSUSER91_TBL_LEALTAD` y no crea una relacion de
cliente ni asigna credito.

Antes de autenticar, el logon valida localmente el formato y consulta:

```sql
select * from QRY_SYSUSER90_91_FIND(:codigo)
```

La consulta devuelve el nombre del remitente para la tarjeta sin consumir el
codigo. La validacion definitiva se conserva en el proceso que acepta cada tipo
de invitacion.

Dentro de la familia `SF`, Flutter genera tres variantes operativas:

```text
anfitrionAnonimo     codigo sin destinatario previo
invitadoRegistrado  codigo ligado a UUID
invitadoCorreo      codigo ligado a correo Gmail
```

`ADD_SYSUSER90_SALDIFY` reserva un codigo aleatorio con digito verificador y
guarda la intencion en `SYSUSER90_TBL_SALDIFY`.

### 6.2 Invitacion generica

Una invitacion generica es abierta respecto al destinatario, pero es de un solo
uso. El primer usuario autenticado que la utiliza correctamente completa correo
y UUID mediante `UPDATE_SYSUSER90`.

Despues de esa asignacion:

- el codigo queda ligado al primer usuario;
- otro usuario no puede reutilizarlo;
- para otro cliente se genera un codigo nuevo.

Esto evita que una captura del QR o un enlace reenviado registre varias cuentas.

### 6.3 Flujo de validacion

```text
Codigo o link
  -> Google/Firebase
  -> SmxLogonMovil.prepareUser
  -> UPDATE_SYSUSER90
  -> SmxConstants.setClienteInvitado
  -> navegacion al modulo cliente
  -> ADD_SYSUSER10_SYSUSER11
  -> dashboard o pantalla de estado
```

Google debe abrirse directamente desde el gesto del usuario. No debe existir un
`await`, consulta remota o dialogo asincrono antes de `signInWithPopup`.

`UPDATE_SYSUSER90` valida el codigo y, si era generico, lo reclama de forma
atomica. Puede regresar cero filas cuando el codigo no existe, ya fue tomado de
forma incompatible o no pudo actualizarse.

#### Lectura y validacion del URL

`main.dart` lee `Uri.base.queryParameters` y entrega el valor de `codigo` a
`SmxSaldifyLogon`. Los demas datos de invitacion no se consideran confiables por
si solos: se recuperan o verifican contra `SYSUSER90`.

El codigo se normaliza eliminando separadores y convirtiendo a mayusculas. El
formato valido es:

```text
SF + 12 digitos
```

El ultimo digito se valida con Luhn. Un codigo con prefijo, longitud, caracteres
o verificador incorrectos se rechaza antes de consultar la base.

Para un codigo valido:

1. El gesto del usuario abre Google directamente.
2. `prepareUser(...)` recupera o crea el `SYSUSER10` autenticado.
3. Flutter llama `UPDATE_SYSUSER90(codigo, uuid, correo)`.
4. El SP devuelve anfitrion y destinatario definitivo.
5. Flutter compara el correo o UUID devuelto con la cuenta autenticada.
6. Una discrepancia limpia el modo invitado y obliga a seleccionar otra cuenta.
7. Una coincidencia guarda codigo, anfitrion y destinatario en `localStorage`.
8. El acceso recurrente puede reutilizar esos datos sin solicitar nuevamente el
   codigo, pero vuelve a autenticar la cuenta.

La cancelacion del popup regresa a estado inactivo sin mostrar un error de
sistema. Despues de un codigo fallido se fuerza el selector de cuenta para
permitir corregir una cuenta Google equivocada.

### 6.4 Consolidacion con `ADD_SYSUSER10_SYSUSER11`

El controller cliente ya no ejecuta primero `QRY_SYSUSER10_SYSUSER11`. Ejecuta
una sola operacion con efectos:

```sql
select * from ADD_SYSUSER10_SYSUSER11(
  :uuid_anfitrion,
  :correo_autenticado
)
```

El procedimiento debe regresar siempre una fila util. Su contrato incluye:

```text
MENSAJE
RELA_SYSUSER10
ID_SYSUSER11
SYSUSER10_NOMBRES
SYSUSER10_APELLIDOS
SYSUSER10_TELEFONO
SYSUSER10_CORREO
SYSUSER11_STATUS
CON_CATALOGO
SYSUSER11_FAPL
```

Interpretacion:

```text
MENSAJE = 'OK'  continuar al dashboard
MENSAJE distinto de 'OK'  mostrar SmxSaldiFyClienteInvitacionEstado
```

El SP valida identidad, auto invitacion, padre unico y ciclos. Si no existe una
relacion, la crea activa con `STATUS_ACCION = 'I'`. Si ya pertenece al mismo
anfitrion, consolida esa relacion segun su estado. Si pertenece a otra red, no
modifica datos y devuelve el mensaje correspondiente.

Los SP con efectos se invocan con `addSTrans()` y `getCallWS()`, no con
`getRowSetFuture()`.

## 7. Metricas compartidas

Se agregaron dos rowsets de sesion:

```dart
SmxConstants.rstMetricasAnfitrion
SmxConstants.rstMetricasCliente
```

Son `late SmxRowSet`: la consulta debe devolver siempre una fila valida. Quien
carga o refresca las metricas debe ejecutar `first()` antes de publicarlas en
`SmxConstants`.

### 7.1 Anfitrion

`QRY_SYSUSER11_SALDOS_ANFITRION(id_sysuser10)` entrega las metricas de su red y,
si el anfitrion tambien es cliente, informacion de su anfitrion anterior:

```text
RELA_SYSUSER10
RELA_SYSUSER11
RELA_SYSUSER12, cuando el contrato lo requiera
datos de nombre, telefono y correo del anfitrion anterior
```

Si `RELA_SYSUSER10 = 0`, el anfitrion no depende de otro anfitrion y la tarjeta
`Tu anfitrion` no se muestra.

Si es distinto de cero, el dashboard anfitrion reutiliza la tarjeta del modulo
cliente, tomando identidad desde `rstMetricasAnfitrion` y configuracion de
credito/corte desde la consulta de `SYSUSER12`.

### 7.2 Cliente

El cliente conserva su flujo normal:

```sql
QRY_SYSUSER11_SALDOS_INVITADO(
  id_cliente,
  id_anfitrion
)
```

Almacena el resultado posicionado en `rstMetricasCliente`. Compras y pagos leen
directamente los valores numericos del rowset, sin arrastrar snapshots ni hacer
conversiones repetidas de `double` a `String` y de regreso.

## 8. Catalogo propio, libre o heredado

### 8.1 Regla por presencia

No se agrego un campo de modo. `SYSUSER44_CAB_CATALOGO` existe solamente cuando
un anfitrion decide usar el catalogo de su anfitrion:

```text
RELA_SYSUSER10_ANFITRION  propietario ofrecido
RELA_SYSUSER10            anfitrion que hereda
ID_SYSUSER44
SYSUSER44_FAPL
```

Interpretacion:

- fila en `SYSUSER44`: catalogo heredado;
- sin fila y con productos propios: catalogo propio;
- sin fila y sin productos propios: compra manual/libre.

### 8.2 UI de productos

La opcion aparece solamente cuando:

```dart
SmxConstants.rstMetricasAnfitrion.getValue('RELA_SYSUSER10') != 0
```

Al seleccionar catalogo del anfitrion:

- se inserta `SYSUSER44`;
- se recargan configuracion y productos;
- los productos se muestran en modo consulta;
- no se permite editar, archivar ni borrar productos ajenos.

Al seleccionar catalogo propio:

- se elimina la fila `SYSUSER44`;
- se recarga la lista propia;
- se prepara un nuevo producto editable.

Insert y delete deben asignar tanto `data.accion` como la accion del rowset. El
cambio completo se ejecuta dentro de un solo `showDialogWait(...)` y revisa
`jsonSend.error` despues de cada operacion asincrona.

### 8.3 Consulta del carrito

El carrito anfitrion usa exclusivamente:

```sql
QRY_SYSUSER41_CARRITO(catalogOwnerId)
```

Debe regresar la misma estructura que `QRY_SYSUSER41`, resolviendo antes el
propietario efectivo del catalogo.

Advertencia importante para redes profundas: un unico `SELECT` a `SYSUSER44`
resuelve solo el padre inmediato. Para que A -> B -> C propague el catalogo de A
hasta C, el SP debe seguir `SYSUSER44` hasta encontrar el propietario efectivo,
o `SYSUSER44.RELA_SYSUSER10_ANFITRION` debe guardar directamente ese propietario
efectivo. No documentar una propagacion transitiva si el SP hace un solo salto.

## 9. Carrito y trazabilidad

`SYSUSER45_CAB_CARRITO` conserva la cabecera y
`SYSUSER40_DET_COMPRAS` los detalles.

No fue necesario agregar otro campo para saber quien genero la compra. La
trazabilidad ya existe en:

```text
SYSUSER40_DET_COMPRAS.RELA_SYSUSER10_ALTA
```

Permite distinguir si la compra fue capturada por el anfitrion o por el cliente.
El producto real queda en `RELA_SYSUSER41` y el carrito en `RELA_SYSUSER45`.

El guardado sigue siendo cabecera-detalle mediante `setDetTransaction()` y
`callTroncalSave()`.

## 10. Ajustes de interfaz relacionados

### Dashboard anfitrion

- La tarjeta `Invita clientes` abre QR e invitacion por Gmail.
- El QR generico es de un solo uso.
- El campo Gmail muestra el sufijo fijo `@gmail.com`.
- El bottom sheet usa `viewInsets.bottom` y reposiciona el campo al abrir el
  teclado de iOS o Android.
- Si el anfitrion tambien es cliente, aparece la tarjeta `Tu anfitrion`.
- Se agrego una estrella de ranking junto al saludo. El porcentaje vive por
  ahora en `SmxSaldiFyRankingController` y se pinta de derecha a izquierda.

### Clientes activos

- Tarjeta compacta con nombre, correo y telefono accionables.
- Saldo y disponible permanecen visibles.
- El chip de estado despliega corte, credito, compras y pagos.
- Solo una tarjeta puede permanecer expandida.
- Hacer scroll no cierra la tarjeta.
- Las gestiones muestran un subpie compacto con campana, compras y pagos.
- El subpie ocupa desde la linea divisoria hasta el borde inferior de la tarjeta.

### Credito

Se agrego el campo transaccional:

```text
SYSUSER12_COMISION
```

La UI lo presenta como `Comision por venta (%)`, con rango de 0 a 100 y valor
inicial 0. Representa el porcentaje que el anfitrion devuelve al vendedor por la
venta, no un importe agregado a la deuda.

## 11. Archivos Flutter principales

```text
lib/smxAuth/smxLogonMovil.dart
lib/smxApis/smxConstants.dart
lib/smxSaldifyLogon/smxSaldifyLogon_controller.dart
lib/smxSaldify/smxSaldify_dashboard/
lib/smxSaldify/smxSaldify_screens/saldify_cliente/
lib/smxSaldify/smxSaldify_screens/saldify_productos/
lib/smxSaldify/smxSaldify_screens/saldify_compras/
lib/smxSaldify/smxSaldify_screens/saldify_credito/
lib/smxSaldify/smxSaldify_screens/saldify_ranking/
lib/smxSaldifyCliente/
```

## 12. Contratos de base involucrados

```text
ADD_SYSUSER10
ADD_SYSUSER90_SALDIFY
UPDATE_SYSUSER90
ADD_SYSUSER10_SYSUSER11
QRY_SYSUSER10_FIND
QRY_SYSUSER10_SYSUSER11
QRY_SYSUSER11
QRY_SYSUSER11_SALDOS_ANFITRION
QRY_SYSUSER11_SALDOS_INVITADO
QRY_SYSUSER12
QRY_SYSUSER41
QRY_SYSUSER41_CARRITO
MOVE_SYSUSER11_RED
```

Tablas principales:

```text
SYSUSER10_CAB_MOVIL
SYSUSER11_DET_CONTACTOS
SYSUSER12_DEP_CLIENTES
SYSUSER40_DET_COMPRAS
SYSUSER41_DET_PRODUCTOS
SYSUSER44_CAB_CATALOGO
SYSUSER45_CAB_CARRITO
SYSUSER46_MOV_INVENTARIO
SYSUSER90_TBL_SALDIFY
SYSUSER99
```

## 13. Lista de verificacion

Antes de modificar estos flujos comprobar:

1. El rowset fue posicionado antes de publicarlo o leerlo globalmente.
2. Un SP con efectos usa `addSTrans()` y `getCallWS()`.
3. Insert, update y delete asignan `data.accion` y accion de rowset.
4. Ningun cliente puede tener dos padres directos.
5. Ninguna invitacion puede crear auto relacion o ciclo.
6. `STATUS_ACCION = 'I'` bloquea la edicion por anfitrion.
7. Una invitacion generica no se reutiliza despues de ser reclamada.
8. Los productos heredados son solo lectura para quien no es propietario.
9. El carrito consulta `QRY_SYSUSER41_CARRITO`, no `QRY_SYSUSER41` directo.
10. La herencia profunda resuelve al propietario efectivo, no solo un salto.
11. El cambio de red de un anfitrion/cliente se ejecuta como traslado
    estructural de subarbol, no como invitacion comun ni copia de clientes.
