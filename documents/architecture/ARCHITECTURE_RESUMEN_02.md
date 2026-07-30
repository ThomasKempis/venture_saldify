# Saldify - Resumen Maestro de Arquitectura 02

Este documento continua `ARCHITECTURE_RESUMEN_01.md` y consolida las modificaciones realizadas sobre autenticacion, productos, imagenes, inventario, compras, pagos, historico, carritos y componentes visuales compartidos.

El objetivo es poder retomar el proyecto sin reconstruir decisiones ya tomadas. Antes de modificar estas areas se debe respetar la metodologia `SmxController`/`SmxRowSet`, la separacion entre vista y tabla troncal, y las reglas de negocio descritas aqui.

## 1. Principios Aplicados

1. Las vistas `QRY_*` se utilizan para lectura y pueden incluir campos calculados, imagenes y descripciones.
2. Las tablas troncales `SYSUSER*_...` se utilizan para altas, modificaciones y bajas.
3. Los controles compartidos viven en `smxLayout/smxScreens`; la recuperacion de datos y persistencia permanece en los controllers concretos de anfitrion e invitado.
4. Las imagenes se administran mediante `SmxImagesCrud`; no se reimplementa su persistencia en cada pantalla.
5. Las listas no deben recargarse completamente cuando la fila puede actualizarse en memoria.
6. El login de Google debe comenzar directamente desde el gesto del usuario para conservar la activacion que permite abrir `signInWithPopup`.
7. La identidad externa es neutral: el resto de la app no debe depender de `Firebase User`.
8. Los saldos se calculan de forma centralizada en base de datos.

## 2. Componentes Visuales Compartidos

Las interfaces iguales de anfitrion e invitado fueron desacopladas de sus controllers concretos.

Ubicacion:

```text
lib/smxLayout/smxScreens/
├── smxMetricasResumen/
├── smxComprasManual/
├── smxComprasCarrito/
└── smxPagos/
```

Cada modulo compartido puede contener:

- Widget visual.
- Contrato abstracto del controller.
- Modelos visuales neutrales.
- Skeleton, cuando corresponde.

Los controllers concretos siguen separados:

```text
lib/smxSaldify/...          # Anfitrion
lib/smxSaldifyCliente/...   # Invitado
```

### Regla de desacoplamiento

La UI compartida no debe conocer:

- Como se obtiene `RELA_SYSUSER11`.
- Si el usuario es anfitrion o invitado.
- Que consulta concreta recupera los datos.
- Como se refresca el dashboard concreto.

El controller concreto implementa el contrato y entrega modelos ya preparados.

### Backgrounds y perfil

- Los backgrounds comunes se encuentran en `lib/smxLayout/smxBackgrounds`.
- El perfil se encuentra en `lib/smxPerfil`.
- El perfil utiliza el controller principal resuelto durante el login.

## 3. Autenticacion

### Estructura actual

```text
lib/smxAuth/
├── smxAuth.dart
├── smxLogonMovil.dart
├── google/
│   ├── AuthRepository.dart
│   ├── AuthService.dart
│   └── AuthViewModel.dart
└── storage/
    └── SmxAuthStorage.dart
```

### Responsabilidades

`SmxAuth`:

- Es la fachada publica de autenticacion.
- Centraliza proveedores externos mediante `SmxAuthProvider`.
- Hoy resuelve Google; queda preparado para Facebook, Apple y Microsoft.
- Devuelve siempre un `SmxAuthUser` neutral.
- Administra storage de identidad y foto para que el cliente no conozca esos detalles.
- Mantiene un estado generico `SmxAuthStatus`.
- Si el usuario cancela el popup o ocurre un error, debe volver silenciosamente a `idle` para permitir otro intento.

`SmxAuthUser`:

- Vive en `lib/smxAuth/smxAuth.dart`.
- Representa la identidad externa neutral.
- No debe estar separado en `models/SmxAuthUser.dart`.

`AuthRepository`:

- Encapsula Firebase Auth.
- Construye `GoogleAuthProvider`.
- Ejecuta `signInWithPopup`.

`AuthService`:

- Convierte `UserCredential/User` de Firebase en `SmxAuthUser`.
- No expone Firebase al resto de la app.

`AuthViewModel`:

- Queda como implementacion/legado interno de Google.
- No debe ser consumido directamente por `SmxSaldifyLogon`.
- La pantalla publica debe hablar con `SmxAuth`.

`SmxAuthStorage`:

- Guarda proveedor, id externo, correo, nombre y foto.
- Mantiene compatibilidad con las claves usadas por la app.
- Si cambia el `providerId`, elimina la imagen anterior.

`SmxLogonMovil`:

- Recibe un `SmxAuthUser` neutral.
- Busca o crea `SYSUSER10_CAB_MOVIL`.
- Sube la imagen inicial si corresponde.
- Resuelve las credenciales individuales de base de datos del usuario.
- Reporta localizacion/login.
- Marca el modo activo.
- Navega al dashboard de anfitrion o invitado.

### Resolucion de SYSUSER10 y usuario de base de datos

`SmxLogonMovil.prepareUser(...)` ya no realiza desde Flutter una secuencia separada de consulta, alta manual, guardado troncal y segunda consulta.

La resolucion se centraliza en:

```sql
select * from ADD_SYSUSER10(
  :nombres,
  :correo,
  :geolocalizacion
)
```

El procedimiento tiene tres responsabilidades relacionadas:

1. Buscar el usuario movil por correo en `SYSUSER10_CAB_MOVIL`.
2. Si no existe, crear `SYSUSER10` y regresar inmediatamente el registro definitivo.
3. Crear o recuperar en `SYSUSER99` el usuario y clave de base de datos asociados al `SYSUSER10`.

El rowset regresado incluye los campos de `SYSUSER10_CAB_MOVIL` y:

```text
SYSUSER99_USUARIO
SYSUSER99_PASSWORD
```

El flujo de conexion queda:

```text
Proveedor externo
  -> SmxAuthUser
  -> conexion inicial con usuario tecnico
  -> ADD_SYSUSER10
  -> busca o crea SYSUSER10
  -> crea o recupera SYSUSER99
  -> devuelve usuario y clave individuales
  -> futuras llamadas usan el usuario individual
```

Despues de recuperar el rowset, Flutter configura:

```dart
SmxConstants_core.instancia = 'SALDIFY';
SmxConstants_core.usuario =
    rstSysUser10.getValue('SYSUSER99_USUARIO');
SmxConstants_core.clave =
    rstSysUser10.getValue('SYSUSER99_PASSWORD');
resetJsonSend();
```

`resetJsonSend()` es importante en este punto porque los nuevos objetos de comunicacion deben construirse con las credenciales individuales ya resueltas.

La conexion tecnica se utiliza solamente para completar el ingreso inicial. A partir de `prepareUser(...)`, las operaciones de la sesion se realizan con el usuario de base de datos reservado para ese usuario movil.

Esto permite:

- identificar tecnicamente al usuario conectado;
- auditar quien realiza cada operacion;
- evitar que toda la actividad quede registrada bajo un unico usuario tecnico;
- mantener una relacion estable entre `SYSUSER10` y su identidad de seguridad en `SYSUSER99`.

### Carga inicial de foto

La imagen no debe subirse antes de ejecutar `ADD_SYSUSER10`, porque eso provocaria una carga nueva en cada logon sin saber si el usuario ya tiene foto.

El orden correcto es:

```text
ADD_SYSUSER10
  -> recuperar RELA_SYSJSON02
  -> si RELA_SYSJSON02 > 0, no subir imagen
  -> si RELA_SYSJSON02 esta vacio o es 0, subir imagen
  -> actualizar solamente RELA_SYSJSON02 en SYSUSER10_CAB_MOVIL
```

Cuando hace falta la imagen:

```dart
data.tablaTroncalRst = rstSysUser10;
final idImage = await _callWSImageLoad();

if (idImage > 0) {
  rstSysUser10.update('RELA_SYSJSON02', idImage);
  await callTroncalSave(rstSysUser10);
}
```

`_callWSImageLoad()` solamente carga el archivo y devuelve el identificador creado en `SYSJSON02`. La relacion con el usuario se completa despues mediante `RELA_SYSJSON02`.

Regla:

- usuario existente con imagen: no se vuelve a subir;
- usuario existente sin imagen: se carga una vez y se actualiza;
- usuario nuevo: se crea primero, luego se carga y relaciona su imagen inicial;
- si el servicio de archivos no devuelve un id valido, no se ejecuta una modificacion troncal.

### SmxAuthUser

El modelo contiene datos comunes a cualquier proveedor:

```text
provider
providerId
email
displayName
photoUrl
imageBytes
```

No debe contener reglas de Saldify como rol, codigo de invitacion o `RELA_SYSUSER11`.

### Flujo desde SmxSaldifyLogon

`SmxSaldifyLogon` no debe conocer detalles internos de Google, Firebase, storage, foto ni estados especificos del proveedor.

La pantalla solo debe pedir autenticacion a la fachada:

```text
Clic del usuario
  -> SmxAuth.signIn(SmxAuthProvider.google, forceAccountSelection: ...)
  -> signInWithPopup
  -> SmxAuthUser
  -> SmxLogonMovil
  -> SYSUSER10
  -> Dashboard
```

No existe una pantalla intermedia que lance Google mediante `microtask`.

### Cancelacion y reintentos

`SmxSaldifyLogon` no debe mostrar modales propios cuando el usuario cancela el popup de Google o cuando el proveedor devuelve `null`.

Regla actual:

- Tocar Anfitrion, Invitado o Validar codigo abre directamente el proveedor configurado.
- Si el usuario cancela, se regresa silenciosamente a la pantalla de acceso.
- No debe aparecer `AlertDialog` de cancelar/reintentar.
- No debe aparecer overlay local de carga de autenticacion encima del logon.
- El siguiente toque debe poder abrir de nuevo el proveedor.

Para lograrlo, `SmxAuth.signIn(...)` debe dejar el estado en `idle` antes de regresar `null` ante cancelacion o error.

`SmxSaldifyLogon` tambien limpia el estado antes de cada intento:

```dart
_auth.resetStatus();
final user = await _auth.signIn(provider);
if (user == null) {
  _auth.resetStatus();
  return;
}
```

`isLoading` no es una bandera independiente. Es un getter calculado:

```dart
bool get isLoading => _status == SmxAuthStatus.authenticating;
```

Por eso `resetStatus()` cambia `_status` a `idle` y automaticamente `isLoading` vuelve a `false`.

### Selector de cuenta

El selector de cuenta del proveedor no debe forzarse siempre. En el proveedor actual es Google, pero la UI no debe amarrarse a Google porque en el futuro pueden existir Apple, Facebook o Microsoft.

La regla actual es automatica:

- Si el usuario entra al mismo modo que el ultimo acceso, no se envia `prompt: select_account`.
- Si cambia de modo, se fuerza selector de cuenta.
- Validar codigo cuenta como modo `invitado`.
- El ultimo modo se lee desde `SmxSaldifyAccessSession.ultimoModo`.
- Si no se fuerza selector, `SmxAuth` debe intentar reutilizar `FirebaseAuth.currentUser` antes de abrir `signInWithPopup`.
- Existe una accion manual solo para anfitrion: `Cambiar cuenta de Anfitrion`.

Ejemplos:

```text
ultimo modo anfitrion + toca anfitrion -> no fuerza selector
ultimo modo anfitrion + toca invitado -> fuerza selector
ultimo modo invitado + toca invitado -> no fuerza selector
ultimo modo invitado + toca anfitrion -> fuerza selector
ultimo modo anfitrion + toca Cambiar cuenta de Anfitrion + toca anfitrion -> fuerza selector
```

El parametro se agrega solo cuando se detecta cambio de modo:

```dart
if (forceAccountSelection) {
  provider.setCustomParameters({'prompt': 'select_account'});
}
```

Esto permite que el acceso normal sea rapido, pero evita reutilizar silenciosamente una cuenta cuando el usuario cambia entre Anfitrion e Invitado.

La accion `Cambiar cuenta de Anfitrion` no es un checkbox persistente. Es un toggle visual temporal para el proximo acceso como anfitrion:

```text
Cambiar cuenta de Anfitrion
Se elegira otra cuenta de Anfitrion
```

Reglas:

- Solo afecta el siguiente tap en `Anfitrion`.
- No afecta el flujo `Invitado`.
- Se puede activar y desactivar tocandola de nuevo.
- Se limpia automaticamente cuando el acceso como anfitrion entra correctamente.
- Se muestra alineada a la derecha entre `Anfitrion` e `Invitado`.

Importante: quitar `prompt: select_account` no evita por si solo que se abra el popup. Si se quiere entrar sin pedir de nuevo en el mismo modo, primero se debe revisar la sesion Firebase ya restaurada:

```dart
final currentUser = await authRepository.getCurrentUser();
if (currentUser != null && !forceAccountSelection) {
  return crearSmxAuthUser(currentUser);
}
```

### Error de codigo y siguiente autenticacion

Cuando `Validar codigo` autentica una cuenta Google pero el codigo no corresponde a ese usuario, no se debe seguir reutilizando silenciosamente esa cuenta en el siguiente intento.

Regla:

- Si `validarCodigoAutenticado(...)` falla, `SmxSaldifyLogon` marca un flag temporal para forzar selector en la siguiente autenticacion.
- Ese flag aplica al siguiente intento de Anfitrion, Invitado o Validar codigo.
- El flag se limpia solamente cuando el flujo queda validado para entrar.
- Esto evita que `FirebaseAuth.currentUser` reutilice una cuenta que ya se comprobo que no corresponde al codigo.

### Invitado guardado y popup de Google

El boton Invitado debe revisar primero si existen datos de invitacion guardados en storage local antes de abrir Google.

Orden correcto:

```text
Tap Invitado
  -> cargarInvitadoGuardado(context)
  -> si no hay datos, mostrar mensaje y salir
  -> si hay datos, llamar SmxAuth.signIn(...)
```

Esto evita abrir Google cuando el flujo no puede continuar por falta de invitacion guardada.

Importante para navegadores:

- `cargarInvitadoGuardado(context)` debe ser sincrono.
- No debe haber `await` entre el tap del usuario y `SmxAuth.signIn(...)`.
- Si se agrega una operacion async antes de abrir Google, el navegador puede perder la activacion del gesto y bloquear `signInWithPopup`.

Por eso no se debe mover una consulta a base, espera, dialogo asincrono o validacion remota antes del popup de Google en los caminos que autentican.

### Foto de Google

La foto se obtiene desde `user.photoURL` y se descarga como bytes. El orden correcto es:

```dart
final cachedImage = storage.readImage();
final imageBytes = cachedImage ?? await storage.savePhoto(googleUser);
final user = googleUser.copyWith(imageBytes: imageBytes);
```

No se debe construir `SmxAuthUser` antes de descargar la foto cuando no hay cache, porque la primera sesion recibiria `imageBytes = null` aunque la descarga terminara despues.

La descarga de foto pertenece a `SmxAuth`, no a `SmxSaldifyLogon`. Si falla o vence el intento de descarga, el flujo de autenticacion debe continuar sin bloquear el acceso y el usuario puede quedar con imagen por defecto.

### Codigo de invitacion

Orden:

1. Validar formato local del codigo.
2. Autenticar con Google.
3. Resolver `SYSUSER10` para conocer correo y UUID interno.
4. Validar/consolidar la invitacion con `UPDATE_SYSUSER90`.
5. Comparar correo o UUID con el usuario autenticado.
6. Navegar como invitado solamente si corresponde.

El storage de codigo, anfitrion e invitado sigue perteneciendo a `SmxSaldifyLogonController`, porque es contexto funcional de Saldify, no identidad del proveedor.

### Codigo de invitacion en UI de produccion

El card de codigo ya no se muestra como entrada manual permanente.

Regla visual:

```text
Si viene codigo por URL valido:
  mostrar solo el card Codigo de invitacion + Validar codigo

Si no viene codigo por URL:
  mostrar Anfitrion + Cambiar cuenta de Anfitrion + Invitado
```

Con link, no deben aparecer los cards de `Anfitrion`, `Cambiar cuenta de Anfitrion` ni `Invitado`. El foco de esa pantalla es validar el codigo recibido.

Sin link, no aparece `Codigo de invitacion` ni `Validar codigo`; el invitado recurrente entra usando la invitacion guardada en storage.

Esto evita que el usuario escriba codigos manualmente en produccion. Si necesita cambiar de invitacion/anfitrion, debe abrir otro link con otro `codigo`.

### Evitar flash visual despues de validar codigo

Antes, al validar correctamente un codigo recibido por URL se limpiaba el modo de codigo antes de navegar:

```dart
hasCodigoInicialValido = false;
codigoController.clear();
```

Eso provocaba un flash donde el logon cambiaba por un instante al modo normal (`Anfitrion`, `Cambiar cuenta`, `Invitado`) antes de entrar al dashboard.

La regla actual es no cerrar visualmente el modo codigo despues de una validacion exitosa. La invitacion se guarda en storage, pero la pantalla conserva el card de codigo hasta que termine la navegacion.

## 4. Productos

### Lectura y escritura

- Vista de lectura: `QRY_SYSUSER41`.
- Tabla troncal: `SYSUSER41_DET_PRODUCTOS`.
- Imagenes: `SYSUSER42_DET_IMAGENES`.
- Vista para CRUD de imagenes: `GRD_SYSUSER42`.

`rstProductos` es plural y representa la vista/lista.

`rstProducto` es la fila troncal preparada para escritura.

No se debe enviar `QRY_SYSUSER41` como tabla modificable. Los campos editables se copian hacia la tabla troncal.

### Alta eficiente

Para altas se utiliza:

```sql
ADD_SYSUSER41(rela_sysuser10, producto, importe, inventario)
```

El SP devuelve el id real. Este id reemplaza el id negativo temporal de la fila agregada en memoria.

Para modificar o archivar se actualiza la fila en memoria, se envia el rowset y no se recarga la lista completa.

### Listas de productos

El mismo `rstProductos` se divide visualmente en:

- `Tus productos`: activos, ordenados por nombre.
- `Archivados`: archivados, ordenados por nombre.

La grabacion sigue usando el mismo rowset/controlador; la division es visual y en memoria.

### Imagenes de productos

`SmxImagesCrud` se configura contra:

- Alias de imagen de producto.
- `GRD_SYSUSER42` como rowset de imagenes.
- Relacion `RELA_SYSUSER41`.

La imagen puede cargarse solamente cuando el producto ya tiene id real.

Despues de agregar o borrar una imagen:

- Se sincroniza la imagen activa con la fila seleccionada de `rstProductos`.
- Si se borra la imagen actual, se muestra la siguiente disponible.
- Si no queda ninguna, se limpia `SYSUSER41_IMAGE` y vuelve el icono de producto.
- No es necesario salir y volver a entrar para refrescar la tarjeta.

### URL de imagen

Prefijo:

```text
https://venture.jars.mx/sovimex/Temps/saldify/SYSUSER41
```

La vista devuelve alias + UUID. La app completa el URL y el sufijo de miniatura correspondiente.

Si no existe imagen se conserva el icono de producto.

### Refresco del indicador con_catalogo

El listado de clientes contiene `CON_CATALOGO`.

Al entrar a Productos se recuerda si habia productos. Al salir:

- Si entro sin productos y sale con productos, refresca clientes.
- Si entro con productos y sale sin productos, refresca clientes.
- Si el estado no cambio, no refresca.

Esto evita consultas repetidas durante toda la vida normal de la sesion.

## 5. Inventario

### Tablas y campos

Producto:

```text
SYSUSER41_INVENTARIO
```

Movimiento:

```sql
SYSUSER46_MOV_INVENTARIO
RELA_SYSUSER41
RELA_SYSUSER40
ID_SYSUSER46
SYSUSER46_STATUS
SYSUSER46_CANTIDAD
SYSUSER46_FAPL
```

Compra de catalogo:

```text
SYSUSER40_DET_COMPRAS.RELA_SYSUSER41
```

En compras manuales `RELA_SYSUSER41` permanece null.

### Tipos de movimiento

- `I`: existencia/inventario declarado.
- `N`: neutralizacion de la existencia acumulada anterior.
- `C`: consumo por compra entregada.

### Actualizacion de inventario

Cuando cambia `SYSUSER41_INVENTARIO`:

1. Se suma el movimiento actual.
2. Si la suma es distinta de cero, se inserta `N` con `suma * -1`.
3. Si el nuevo inventario es mayor que cero, se inserta `I` con el nuevo valor.
4. No se inserta un movimiento de inventario igual a cero.

La existencia real se calcula en `QRY_SYSUSER41` como suma de movimientos. El campo de la tabla de productos representa la nueva existencia declarada, no el historico final.

### Descuento por compra

El movimiento `C` se registra cuando la compra entra al estado entregado y tiene `RELA_SYSUSER41`.

Debe usarse la fila `NEW` para los datos finales de la actualizacion. El movimiento de compra es negativo para disminuir existencia.

### UI

Productos muestra:

- Inventario editable.
- Existencia actual como campo informativo `onlyRead`.
- Existencia tambien en las tarjetas.

Carrito muestra existencia junto al precio:

- El boton `+` no supera la existencia.
- Con existencia cero no se puede agregar.
- El boton `-` reduce hasta cero.
- Tocar la tarjeta no incrementa cantidad; solamente lo hace el boton `+`.

## 6. Imagenes Generales

### Metadatos

La tabla comun es `SYSJSON02_TBL_FILES`:

```text
ID_SYSJSON02
SYSJSON02_ALIAS
SYSJSON02_UUID
SYSJSON02_USUARIO
SYSJSON02_TIPO
SYSJSON02_NAME
SYSJSON02_FAPL
```

Cada entidad usa una tabla detalle de relacion:

- Producto: `SYSUSER42_DET_IMAGENES`.
- Compra: `SYSUSER43_DET_IMAGENES`.
- Pago: tabla detalle correspondiente al modulo de pagos.

Las vistas `GRD_*` unen el detalle con `SYSJSON02_TBL_FILES` y entregan `SYSJSON02_UUID` al CRUD.

### SmxImagesCrud

El CRUD:

- Sube una imagen por operacion.
- Puede permitir varias imagenes cuando `uniqueImage` no limita a una.
- Mantiene `rstImages`.
- Usa `copyToTemp` para que el web service copie la imagen disponible por URL.
- Puede reemplazar o eliminar imagenes sin reimplementar el protocolo en la pantalla.

### Miniaturas

El servidor genera la miniatura cuadrada y centrada, preservando proporcion. No se debe estirar la imagen a 1:1.

La miniatura se guarda en formato comprimido adecuado. Una miniatura PNG puede ser mas pesada que el original por el tipo de contenido; para fotografias se prefirio JPEG comprimido.

El archivo temporal usa el mismo UUID con el sufijo de miniatura definido por el servidor.

## 7. Compras Manuales

### Lectura y escritura

- Vista: `QRY_SYSUSER40`.
- Tabla: `SYSUSER40_DET_COMPRAS`.
- Imagenes: `SYSUSER43_DET_IMAGENES`.
- Vista de imagenes: `GRD_SYSUSER43`.

Campos principales:

```text
RELA_SYSUSER11
RELA_SYSUSER10_ALTA
RELA_SYSUSER41       # null en manual
RELA_SYSUSER45       # null si no pertenece a carrito
ID_SYSUSER40
SYSUSER40_CONCEPTO
SYSUSER40_CANTIDAD
SYSUSER40_IMPORTE
SYSUSER40_STATUS
SYSUSER40_FECHA
SYSUSER40_FAPL
```

La vista agrega:

```text
SYSUSER40_TOTAL = SYSUSER40_CANTIDAD * SYSUSER40_IMPORTE
SYSUSER40_IMAGE
```

### Reglas visuales

La lista se divide en:

- `Compras pendientes`: status cero.
- `Compras recibidas`: status diferente de cero.

Estados:

- `0`: solicitada/pendiente.
- `1`: pendiente de entrega segun el flujo vigente.
- `2`: entregada.

La compra puede editarse o eliminarse solamente con status cero.

Las imagenes pueden agregarse, cambiarse o eliminarse siempre, independientemente del status.

Al guardar compra se cierra el formulario tanto en alta como en modificacion.

El gesto de borrar debe usar el mismo sentido y estilo iOS aplicado en clientes pendientes.

### Validacion de saldo

La validacion usa el total, no el precio unitario:

```text
total = cantidad * importe
```

Alta:

- El nuevo total no puede superar el disponible.

Modificacion:

- Se libera temporalmente el total anterior.
- Limite permitido = disponible actual + total anterior.
- Se valida el nuevo total contra ese limite.

No debe validarse una modificacion como si fuera un alta.

### Tarjetas

Muestran:

- Concepto.
- Cantidad.
- Precio unitario.
- Total.
- Fecha.
- Status.
- Imagen cuando existe.

## 8. Pagos

### Lectura y escritura

- Vista de lectura: `QRY_SYSUSER50`.
- Tabla troncal: `SYSUSER50_DET_PAGOS`.
- Vista de imagenes: `GRD_SYSUSER51`.

La UI compartida de pagos es usada por anfitrion e invitado mediante controllers concretos.

### Estados

- `0`: pendiente de confirmar contra el deposito bancario.
- `1`: deposito confirmado.

La lista se divide en:

- `Pagos pendientes`.
- `Pagos confirmados`.

Un pago pendiente puede editarse o borrarse. Un pago confirmado no.

Las imagenes pueden cambiarse siempre, igual que en compras.

Solamente el anfitrion confirma el deposito.

### Validacion de saldo

Alta:

- El importe nuevo se valida contra el saldo permitido.

Modificacion:

- Se recupera el importe anterior.
- Limite permitido = saldo actual + importe anterior.
- El nuevo importe no puede superar ese limite.

### Efecto financiero

El saldo general solamente debe descontar pagos confirmados (`status = 1`).

En la pantalla de alta puede mostrarse un calculo optimista local, pero el resumen general y el disponible dependen de la confirmacion.

## 9. Saldos e Historico

### Centralizacion

Los saldos se concentran en `QRY_SYSUSER11_SALDOS` o el SP equivalente utilizado por la app.

Calculos:

```text
compras = SUM(cantidad * importe)
pagos   = SUM(importe confirmado)
balance = compras - pagos
disponible = credito - balance
```

Reglas:

- Balance menor que cero se normaliza a cero.
- Disponible menor que cero se normaliza a cero.
- Disponible no puede superar el credito.
- Los calculos de periodo/corte conservan la misma regla de cantidad por importe.

### QRY_SYSUSER11_SALDOS

Contrato corregido:

- `SYSUSER12_COMPRAS` conserva el acumulado historico de compras.
- `SYSUSER12_PAGOS` conserva el acumulado historico de pagos confirmados.
- `SYSUSER12_COMPRAS_ULT` y `SYSUSER12_PAGOS_ULT` se usan solamente como variables internas para calcular corte/deudor.
- El corte no debe pisar las metricas principales de compras y pagos.

```sql
create or alter procedure QRY_SYSUSER11_SALDOS (
    RELA_SYSUSER12 bigint,
    FECHA_CORTE date,
    FECHA_CORTE_ANT date)
returns (
    SYSUSER12_CREDITO double precision,
    SYSUSER12_DISPONIBLE double precision,
    SYSUSER12_COMPRAS double precision,
    SYSUSER12_PAGOS double precision,
    SYSUSER12_BALANCE double precision,
    SYSUSER12_DEUDOR double precision)
as
declare variable RELA_SYSUSER11 bigint;
declare variable SYSUSER12_PLAN integer;
declare variable SYSUSER12_PORCENTAJE double precision;
declare variable PAGO_MINIMO double precision;
declare variable SYSUSER12_COMPRAS_ULT double precision;
declare variable SYSUSER12_PAGOS_ULT double precision;
begin
    select
        s12.rela_sysuser11,
        s12.sysuser12_credito,
        s12.sysuser12_plan,
        s12.sysuser12_porcentaje
    from sysuser12_dep_clientes s12
    where s12.id_sysuser12 = :rela_sysuser12
    into :rela_sysuser11,
         :sysuser12_credito,
         :sysuser12_plan,
         :sysuser12_porcentaje;

    if (sysuser12_credito is null) then sysuser12_credito = 0.0;

    select sum(c.sysuser40_cantidad * c.sysuser40_importe)
    from sysuser40_det_compras c
    where c.rela_sysuser11 = :rela_sysuser11
    into :sysuser12_compras;

    select sum(p.sysuser50_importe)
    from sysuser50_det_pagos p
    where p.rela_sysuser11 = :rela_sysuser11
      and p.sysuser50_status = 1
    into :sysuser12_pagos;

    if (sysuser12_compras is null) then sysuser12_compras = 0.0;
    if (sysuser12_pagos is null) then sysuser12_pagos = 0.0;

    sysuser12_deudor = 0.0;
    sysuser12_balance = sysuser12_compras - sysuser12_pagos;

    if (fecha_corte is not null and fecha_corte_ant is not null) then
    begin
        select sum(c.sysuser40_cantidad * c.sysuser40_importe)
        from sysuser40_det_compras c
        where c.rela_sysuser11 = :rela_sysuser11
          and c.sysuser40_fecha >= :fecha_corte_ant
          and c.sysuser40_fecha <= :fecha_corte
        into :sysuser12_compras_ult;

        select sum(p.sysuser50_importe)
        from sysuser50_det_pagos p
        where p.rela_sysuser11 = :rela_sysuser11
          and p.sysuser50_status = 1
          and p.sysuser50_fecha >= :fecha_corte_ant
          and p.sysuser50_fecha <= :fecha_corte
        into :sysuser12_pagos_ult;

        if (sysuser12_compras_ult is null) then sysuser12_compras_ult = 0.0;
        if (sysuser12_pagos_ult is null) then sysuser12_pagos_ult = 0.0;

        if (sysuser12_balance > 0) then
        begin
            if (sysuser12_pagos_ult = 0) then
                sysuser12_deudor = sysuser12_balance;
            else
            begin
                if (sysuser12_plan = 1) then
                begin
                    -- hizo por lo menos un pago libero algo de credito
                end
                else if (sysuser12_plan = 2) then
                begin
                    if (sysuser12_pagos_ult < sysuser12_balance) then
                        sysuser12_deudor = sysuser12_balance - sysuser12_pagos_ult;
                end
                else if (sysuser12_plan = 3) then
                begin
                    pago_minimo = sysuser12_balance * (sysuser12_porcentaje / 100.0);

                    if (sysuser12_pagos_ult < pago_minimo) then
                        sysuser12_deudor = pago_minimo - sysuser12_pagos_ult;
                end
            end
        end

        ---sysuser12_compras = sysuser12_compras_ult;
        ---sysuser12_pagos = sysuser12_pagos_ult;
    end

    if (sysuser12_balance < 0) then sysuser12_balance = 0.0;

    sysuser12_disponible = sysuser12_credito - sysuser12_balance;

    if (sysuser12_disponible < 0) then sysuser12_disponible = 0.0;
    if (sysuser12_disponible > sysuser12_credito) then
        sysuser12_disponible = sysuser12_credito;

    suspend;
end
```

### Historico

Vista:

```text
QRY_SYSUSER40_VS_SYSUSER50
```

Campos relevantes:

```text
SYSUSER90_TIPO
SYSUSER90_CONCEPTO
SYSUSER90_CANTIDAD
SYSUSER90_IMPORTE
SYSUSER90_TOTAL
SYSUSER90_FECHA
SYSUSER90_STATUS
```

Compra:

- Cantidad real.
- Importe unitario positivo.
- Total = cantidad * importe.

Pago:

- Cantidad cero/null normalizada segun contrato del rowset.
- Importe y total negativos para representar abono.

Las tarjetas del historico alinean total y fecha a la derecha. En compras muestran `cantidad x precio unitario`; en pagos no se muestra cantidad.

## 10. Catalogo y Switch de Compras

La app soporta dos modalidades:

1. Compra manual cuando el anfitrion no tiene catalogo.
2. Compra por carrito cuando existe catalogo.

El campo `CON_CATALOGO` se obtiene en las consultas de relacion anfitrion/cliente:

- Anfitrion: vista/consulta que alimenta el listado de clientes (`QRY_SYSUSER11`).
- Invitado: `QRY_SYSUSER10_SYSUSER11`.

El switch/factory concreto decide que controller/pantalla abrir, pero ambas modalidades usan UI compartida donde corresponde.

No se debe consultar el catalogo desde cada tarjeta. El valor se obtiene junto con el contexto del cliente.

## 11. Carrito de Compras

### Estructura

Anfitrion e invitado tienen controllers concretos equivalentes y comparten:

```text
lib/smxLayout/smxScreens/smxComprasCarrito/
```

La UI se divide en:

- `Productos solicitados`: cantidad mayor que cero.
- `Catalogo de productos`: cantidad igual a cero.

### Carritos locales

Antes de confirmar, los carritos viven localmente:

- Se crea un carrito al seleccionar productos.
- Se guarda en storage local.
- Puede abandonarse y retomarse.
- Puede eliminarse.
- Los carritos guardados muestran contador.
- Al borrar el carrito seleccionado, la seleccion se limpia correctamente.
- Los paneles inferiores se repliegan al tocar fuera.

La tarjeta solo cambia cantidad mediante `+` y `-`.

### Persistencia servidor

Cabecera:

```sql
SYSUSER45_CAB_CARRITO
ID_SYSUSER45
SYSUSER45_UUID
SYSUSER45_FAPL
```

Detalle:

```text
SYSUSER40_DET_COMPRAS.RELA_SYSUSER45
```

Al confirmar:

1. Se prepara cabecera `SYSUSER45_CAB_CARRITO`.
2. Se preparan detalles `SYSUSER40_DET_COMPRAS`.
3. Cada detalle recibe concepto, cantidad, importe, fecha, status y `RELA_SYSUSER41`.
4. La relacion de cabecera se asigna mediante transaccion troncal-detalle.
5. Se usa `setDetTransaction` siguiendo el patron de Venture.
6. Solo si el servidor confirma la operacion se elimina/marca el carrito local como enviado.
7. Las compras confirmadas pasan al historico y al flujo normal de entrega.

`SmxCarritoItem.toJson()` conserva `idProducto`, porque se necesita para grabar `RELA_SYSUSER41` y descontar inventario.

## 12. Notificaciones de Cobranza

La tira de notificaciones incluye una cuarta accion cuando existe al menos un cliente cuyo status financiero requiere auditoria:

```text
Cobranza pendiente
```

Descripcion funcional:

```text
Tiene uno o mas clientes para auditar en cobranza. Mantenga su cartera al dia.
```

La condicion debe revisar `SYSUSER12_STATUS`, no solo `SYSUSER12_STATUS_TIPO`.

Estados conocidos:

- `Pendiente`: no tiene credito configurado; pertenece a la accion de credito pendiente.
- `Al dia`: no genera cobranza pendiente.
- `Vence hoy`: genera auditoria.
- `Por vencer`: genera auditoria.
- `Vencido`: genera auditoria.

## 13. Reglas de Rendimiento

1. No refrescar listas completas despues de cada CRUD si la fila ya esta disponible en memoria.
2. En alta, reemplazar el id temporal por el id real devuelto por el SP.
3. Mantener listas activas/archivadas o pendientes/confirmadas como indices sobre un mismo rowset.
4. Las imagenes de listas se sirven desde temporales/miniaturas, no descargando originales desde el storage privado por cada fila.
5. No ejecutar un query independiente por imagen desde Flutter.
6. Las vistas con subconsulta de imagen deben tener indices adecuados en relaciones e ids descendentes.
7. Conservar el calculo de saldos centralizado en base de datos.
8. Las operaciones cabecera-detalle deben enviarse en una transaccion.

## 14. Vistas y Tablas de Referencia

```text
SYSUSER10_CAB_MOVIL              Usuario interno
SYSUSER11_DET_CONTACTOS          Relacion anfitrion/invitado
SYSUSER12_DEP_CLIENTES           Credito del cliente
SYSUSER40_DET_COMPRAS            Compras
QRY_SYSUSER40                    Lectura de compras
SYSUSER41_DET_PRODUCTOS          Productos
QRY_SYSUSER41                    Catalogo, imagen y existencia
SYSUSER42_DET_IMAGENES           Imagenes de productos
GRD_SYSUSER42                    CRUD de imagenes de producto
SYSUSER43_DET_IMAGENES           Imagenes de compras
GRD_SYSUSER43                    CRUD de imagenes de compra
SYSUSER45_CAB_CARRITO            Cabecera de carrito confirmado
SYSUSER46_MOV_INVENTARIO         Movimientos de inventario
SYSUSER50_DET_PAGOS              Pagos
QRY_SYSUSER50                    Lectura de pagos
GRD_SYSUSER51                    CRUD de imagenes de pagos
QRY_SYSUSER40_VS_SYSUSER50       Historico unificado
SYSJSON02_TBL_FILES              Metadatos generales de archivos
```

## 15. Checklist Antes de Modificar

- Confirmar si el rowset es vista de lectura o tabla troncal.
- Confirmar `RELA_SYSUSER11` y usuario que registra la operacion.
- Confirmar si la operacion es manual o proviene de catalogo.
- En compras, validar `cantidad * importe`.
- En modificacion, liberar el valor anterior antes de validar.
- En pagos generales, contar solamente confirmados para liberar credito.
- En imagenes, usar la vista `GRD_*` correcta.
- En carrito, conservar `idProducto` y `RELA_SYSUSER41`.
- En inventario, descontar solo al entrar al estado definido como entregado.
- No duplicar UI de anfitrion e invitado cuando el comportamiento visual es igual.
- No mover logica de base a widgets compartidos.
- No exponer `Firebase User` fuera de `smxAuth/google`.
- No iniciar el popup de Google desde `microtask`, redirect automatico o carga inicial.
- Mantener la identidad externa separada del contexto anfitrion/invitado.

## 16. Estado General

La aplicacion ya no es solo un prototipo visual. El flujo implementado incluye:

- Autenticacion real.
- Usuarios internos.
- Invitaciones.
- Credito y saldos.
- Compras manuales.
- Compras por catalogo y carrito.
- Pagos y confirmacion.
- Historico.
- Imagenes persistentes y miniaturas.
- Productos activos/archivados.
- Inventario funcional basado en movimientos.
- UIs compartidas entre anfitrion e invitado.

Las siguientes ampliaciones deben construirse sobre estos contratos, no reemplazarlos con implementaciones Flutter genericas o consultas paralelas.
