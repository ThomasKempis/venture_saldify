# Saldify Cliente - Arquitectura Flutter

## Contexto

`smxSaldifyCliente` es el modulo invitado/cliente dentro del proyecto `venture_saldify`. No es una app separada: entra por el mismo logon general y se habilita por una invitacion asociada a un anfitrion.

La arquitectura actual mantiene separado el cliente del anfitrion:

- Anfitrion: `lib/smxSaldify`
- Cliente/invitado: `lib/smxSaldifyCliente`

El cliente reutiliza patrones del anfitrion, pero vive en directorios propios para poder cambiar reglas e interfaz sin romper la operatoria administrativa del anfitrion.

## Entrada Principal

Archivo:

```text
lib/smxSaldifyCliente/smxSaldifyCliente.dart
```

Clase principal:

```text
SmxSaldiFyCliente
```

Responsabilidades:

- Crea el `SmxSaldiFyClienteController`.
- Valida la invitacion antes de mostrar el dashboard.
- Arma layout responsive con `SmxLayout`.
- En mobile usa drawer.
- En desktop/tablet usa panel lateral.
- Pasa al dashboard los datos centrales:
  - nombre del cliente
  - nombre del anfitrion
  - telefono del anfitrion
  - estado de la relacion
  - `ID_SYSUSER11`
  - `RELA_SYSUSER10_ANFITRION`

La pantalla usa un refresh por revision:

```text
_dashboardRefreshRevision
```

Cuando vuelve una accion con cambios, se reconstruye el dashboard.

## Controller Principal Cliente

Archivo:

```text
lib/smxSaldifyCliente/smxSaldiFyCliente_controller.dart
```

Clase:

```text
SmxSaldiFyClienteController
```

Consulta principal:

```sql
select * from QRY_SYSUSER10_SYSUSER11
where UUID_ANFITRION = ...
and UUID_INVITADO / INVITADO_CORREO = ...
```

Si no existe relacion por correo invitado, intenta crearla con:

```sql
ADD_SYSUSER10_SYSUSER11(uuid_anfitrion, correo_invitado)
```

Campos importantes tomados de `QRY_SYSUSER10_SYSUSER11`:

- `RELA_SYSUSER10`: id interno del anfitrion.
- `ID_SYSUSER11`: relacion cliente/anfitrion.
- `SYSUSER10_NOMBRES`: nombres del anfitrion.
- `SYSUSER10_APELLIDOS`: apellidos del anfitrion.
- `SYSUSER10_TELEFONO`: telefono del anfitrion.
- `SYSUSER11_STATUS`: estado de la relacion.

Estados de relacion:

```text
0 = Pendiente
1 = Aprobado / aceptado
2 = Archivado
```

Importante: `SYSUSER11_STATUS = 2` es archivado, no rechazado.

Si la relacion no esta aceptada, el modulo cliente muestra una pantalla temporal de validacion y no entra al dashboard.

## Dashboard Cliente

Archivo:

```text
lib/smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_dashboard.dart
```

Clase:

```text
SmxSaldiFyClienteDashboard
```

Estructura visual:

1. Header SALDIFY.
2. Saludo al cliente.
3. Nombre del anfitrion.
4. Widget de metricas.
5. Tarjeta del anfitrion.
6. Acciones rapidas.
7. Historial de movimientos.

El dashboard usa:

```text
CustomScrollView
SliverToBoxAdapter
Column
```

Esto se hizo para igualar el comportamiento del anfitrion y evitar que las metricas se desmonten/remonten por scroll.

## Metricas Cliente

Directorio:

```text
lib/smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_metricas
```

Archivos:

```text
smxSaldiFyCliente_metricas.dart
smxSaldiFyCliente_metricas_controller.dart
smxSaldiFyCliente_metricas_skeleton.dart
```

Consulta:

```sql
QRY_SYSUSER11_SALDOS_INVITADO(rela_sysuser10, rela_sysuser10_anfitrion)
```

Parametros usados:

- `rela_sysuser10`: `SmxConstants.controllerMain.rstSysUser10.getId()`
- `rela_sysuser10_anfitrion`: valor recibido desde `QRY_SYSUSER10_SYSUSER11.RELA_SYSUSER10`

Campos esperados:

- `SYSUSER12_CREDITO`
- `SYSUSER12_DISPONIBLE`
- `SYSUSER12_COMPRAS`
- `SYSUSER12_PAGOS`
- `SYSUSER12_BALANCE`
- `SYSUSER12_DEUDOR`

La UI reutiliza:

```text
lib/smxApis/smxSaldiFy_credito_resumen.dart
```

La metrica cliente pasa:

```text
saldoEnDeuda = SYSUSER12_DEUDOR > 0
```

Si `saldoEnDeuda` es true y el saldo es mayor a cero, el resumen pinta el saldo/deuda en rojo.

## Tarjeta del Anfitrion

Directorio:

```text
lib/smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_anfitrion
```

Archivo:

```text
smxSaldiFyCliente_anfitrion.dart
```

Clase:

```text
SmxSaldiFyClienteAnfitrion
```

Responsabilidades:

- Mostrar nombre real del anfitrion.
- Mostrar estado de la relacion.
- Usar telefono real del anfitrion.
- Abrir WhatsApp con `url_launcher`.

Datos recibidos desde el controller principal:

- `anfitrionNombreCompleto`
- `anfitrionTelefono`
- `anfitrionRelacionEstado`

Esta tarjeta reemplazo el mock anterior de negocio.

## Acciones Rapidas

Directorio:

```text
lib/smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_acciones_rapidas
```

Archivo:

```text
smxSaldiFyCliente_acciones_rapidas.dart
```

Acciones actuales:

- Compras
- Pagos

Desde el dashboard se abren pantallas reales:

- `SmxSaldiFyClienteCompras`
- `SmxSaldiFyClientePagos`

Si una pantalla devuelve `true`, el dashboard ejecuta `onRefresh`.

## Historial de Movimientos

Directorio:

```text
lib/smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_historial
```

Archivos:

```text
smxSaldiFyCliente_historial.dart
smxSaldiFyCliente_historial_controller.dart
smxSaldiFyCliente_historial_skeleton.dart
```

Consulta:

```sql
QRY_SYSUSER10_HISTORIAL(rela_sysuser10, rela_sysuser10_anfitrion)
```

Parametros usados:

- `rela_sysuser10`: usuario logueado.
- `rela_sysuser10_anfitrion`: anfitrion de la invitacion.

Campos esperados:

- `ID_SYSUSER90`
- `SYSUSER90_TIPO`
- `SYSUSER90_CONCEPTO`
- `SYSUSER90_IMPORTE`
- `SYSUSER90_FECHA`
- `SYSUSER90_STATUS`
- `SYSUSER90_FAPL`

El widget muestra inicialmente 5 movimientos y permite ver todos.

Compras:

- Fondo claro normal.
- Barra vertical en tonos calidos.
- Estados:
  - `0`: Solicitada
  - `1`: Pendiente
  - `2`: Entregada

Pagos:

- Fondo azul sutil.
- Barra vertical en tonos azules.
- Estados:
  - `0`: Por confirmar
  - `1`: Confirmado

El color de la barra se calcula de forma estable usando `ID_SYSUSER90`, para que parezca variado pero no cambie en cada rebuild.

El skeleton muestra 3 filas compactas, aunque el historial real muestra 5 movimientos inicialmente.

## Screens Cliente

Directorio:

```text
lib/smxSaldifyCliente/smxSaldifyCliente_screens
```

Se creo este directorio para separar pantallas completas del cliente, igual que el anfitrion tiene `smxSaldify_screens`.

### Compras Cliente

Directorio:

```text
lib/smxSaldifyCliente/smxSaldifyCliente_screens/saldify_compras
```

Archivos:

```text
smxSaldiFyCliente_compras.dart
smxSaldiFyCliente_compras_controller.dart
```

Clase de pantalla:

```text
SmxSaldiFyClienteCompras
```

Controller:

```text
SmxSaldiFyClienteComprasController
```

Patron usado:

- Igual al anfitrion en estructura.
- Carga metricas con `QRY_SYSUSER11_SALDOS_INVITADO`.
- Crea rowset vacio desde `SYSUSER40_DET_COMPRAS where 1 = 0`.
- Inserta nuevo registro con `rstCompra.insert()`.
- Guarda con `callTroncalSave`.
- Muestra en una lista local los registros guardados durante la sesion.

Defaults al crear compra:

- `RELA_SYSUSER11 = idSysuser11`
- `RELA_SYSUSER10_ALTA = usuario logueado`
- `SYSUSER40_CONCEPTO = ''`
- `SYSUSER40_IMPORTE = 0.0`
- `SYSUSER40_FECHA = DateTime.now()`
- `SYSUSER40_STATUS = 0`

Validaciones:

- importe mayor a cero.
- importe no debe superar disponible.

### Pagos Cliente

Directorio:

```text
lib/smxSaldifyCliente/smxSaldifyCliente_screens/saldify_pagos
```

Archivos:

```text
smxSaldiFyCliente_pagos.dart
smxSaldiFyCliente_pagos_controller.dart
```

Clase de pantalla:

```text
SmxSaldiFyClientePagos
```

Controller:

```text
SmxSaldiFyClientePagosController
```

Patron usado:

- Igual al anfitrion en estructura.
- Carga metricas con `QRY_SYSUSER11_SALDOS_INVITADO`.
- Crea rowset vacio desde `SYSUSER50_DET_PAGOS where 1 = 0`.
- Inserta nuevo registro con `rstPago.insert()`.
- Guarda con `callTroncalSave`.
- Muestra en una lista local los registros guardados durante la sesion.

Defaults al crear pago:

- `RELA_SYSUSER11 = idSysuser11`
- `RELA_SYSUSER10_ALTA = usuario logueado`
- `SYSUSER50_REFERENCIA = ''`
- `SYSUSER50_IMPORTE = 0.0`
- `SYSUSER50_FECHA = DateTime.now()`
- `SYSUSER50_STATUS = 0`

Validaciones:

- importe mayor a cero.
- importe no debe superar saldo.

## Cambios Relacionados en Anfitrion

Aunque este documento se concentra en cliente, tambien se toco anfitrion para estandarizar altas:

```text
lib/smxSaldify/smxSaldify_screens/saldify_compras/smxSaldiFy_compras_controller.dart
lib/smxSaldify/smxSaldify_screens/saldify_pagos/smxSaldiFy_pagos_controller.dart
```

Se agrego status inicial:

- Compra nueva: `SYSUSER40_STATUS = 0`
- Pago nuevo: `SYSUSER50_STATUS = 0`

## Reglas Operativas Actuales en Flutter

Cliente y anfitrion usan el mismo patron de alta:

```text
rowset vacio -> insert -> defaults -> validateWidgets -> callTroncalSave
```

La diferencia es de ubicacion y futuro mantenimiento:

- Anfitrion sigue en `lib/smxSaldify`.
- Cliente tiene copia propia en `lib/smxSaldifyCliente/smxSaldifyCliente_screens`.

Esto permite que hoy funcionen parecido, pero manana puedan divergir sin romperse mutuamente.

## Pendientes / Decisiones Abiertas

- La logica fina de `SYSUSER12_DEUDOR` pertenece al stored procedure de saldos, no a Flutter.
- Flutter actualmente solo pinta rojo si `SYSUSER12_DEUDOR > 0`.
- Pagos y compras cliente quedan con status `0`; la confirmacion/entrega queda para reglas posteriores.
- Si se agregan pantallas de confirmacion o cobranza, deberian vivir en anfitrion, no en cliente.
- El historial depende de `QRY_SYSUSER10_HISTORIAL`; si cambian codigos de status, actualizar el mapeo visual.

