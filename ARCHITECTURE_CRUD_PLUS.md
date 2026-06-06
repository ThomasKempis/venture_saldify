# Arquitectura CRUD Plus SMX/Venture

Este documento describe el patron transaccional avanzado de la plataforma SMX/Venture: modulos divididos en `browser` y `crud`, con soporte para cabeceras, detalles anidados, rowsets padre-hijo y guardado troncal.

Debe leerse junto con `ARCHITECTURE.md`.

## Idea central

En la plataforma SMX/Venture, una pantalla transaccional no es simplemente un formulario Flutter con un modelo Dart.

El patron real es:

```text
Modulo
├── browser
│   ├── modulo.dart
│   └── modulo_controller.dart
└── crud
    ├── modulo_abm.dart
    └── modulo_abm_controller.dart
```

El `browser` lista registros y abre el `crud`. El `crud` edita o crea un registro usando `SmxController`, `SmxRowSet`, widgets bindeados por `field` y transacciones administradas por el core.

Cuando el modulo tiene detalles, cada detalle puede repetir el mismo patron:

```text
modulo_padre/
├── browser/
├── crud/
└── modulo_detalle/
    ├── browser/
    └── crud/
```

Esto permite construir transacciones complejas con cabecera y multiples detalles.

## Browser

El `browser` es la pantalla de listado. Normalmente se construye con `SmxDataGridBrowser`.

Ejemplo conceptual:

```dart
SmxDataGridBrowser(
  alias: MiModuloController.MI_MODULO,
  sql: controller.MI_MODULO_SQL,
  tabla: 'MI_TABLA_BROWSER',
  controller: controller,
  screenWidget: MiModulo_abm(),
  camposVe: {
    'CAMPO': SmxColumns(descripcion: 'Descripcion', width: 200),
  },
)
```

Responsabilidades del browser:

- Definir el alias del grid.
- Definir el SQL de listado.
- Definir la tabla de trabajo.
- Definir columnas visibles (`camposVe`).
- Definir que pantalla ABM se abre para nuevo/editar.
- Mantener sincronizado el browser cuando se inserta, edita o elimina una fila.

El browser no debe concentrar la logica de guardado transaccional. Esa logica pertenece al controller del ABM.

## Browser controller

El controller del browser extiende `SmxController`.

Ejemplo:

```dart
class MiModuloController extends SmxController {
  static const String MI_MODULO = 'MI_MODULO';

  late String MI_MODULO_SQL;

  MiModuloController({required super.alias, required super.data}) {
    MI_MODULO_SQL = 'SELECT * FROM MI_VISTA_BROWSER';
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> save() async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}
}
```

Responsabilidades:

- Definir alias constantes.
- Preparar SQL del listado.
- Servir de controller al `SmxDataGridBrowser`.
- Delegar la apertura del ABM al flujo del core/browser.

## ABM / CRUD

El `crud` o ABM es la pantalla de alta, baja o modificacion.

Patron:

```dart
class MiModulo_abm extends SmxStatefulWidget {
  @override
  State<MiModulo_abm> createState() => _MiModulo_abm();
}

class _MiModulo_abm extends State<MiModulo_abm> {
  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<MiModulo_abm_controller>(
      controllerBuilder: (context) => MiModulo_abm_controller(
        alias: 'MI_MODULOW',
        data: widget.dataFromBrowser,
      ),
      builder: (context, controller) => MiModulo_abm_build(
        controller: controller,
      ),
    );
  }
}
```

El ABM recibe `widget.dataFromBrowser`, que contiene informacion construida por el browser/core:

- accion (`I`, `W`, etc.).
- rowset troncal.
- controller padre.
- dataGridSource.
- dataGridBrowser.
- contexto.
- tabla troncal.

## Widgets bindeados

Los widgets del ABM se conectan al controller por `field`.

Ejemplo:

```dart
SmxTextField(
  field: 'MI_CAMPO',
  controller: controller,
  label: 'Campo',
)
```

```dart
SmxNumberField(
  field: 'MI_IMPORTE',
  decimales: 2,
  controller: controller,
  label: 'Importe',
)
```

Esto confirma el principio central de la plataforma:

```text
Widget -> field -> SmxController -> SmxRowSet activo
```

La pantalla no necesita crear modelos Dart manuales si el controller y el rowset ya representan el dato.

## ABM controller

El controller del ABM concentra la logica transaccional.

Responsabilidades:

- Ejecutar `beginDB()` en `init()`.
- Detectar si es alta con `isAltaRst()`.
- Cargar combos/listas auxiliares con `addSql()` y `getRowSetFuture()`.
- Posicionar valores default para altas.
- Validar o preparar datos antes de guardar.
- Actualizar campos del rowset.
- Insertar o actualizar la fila visible del browser.
- Colgar detalles transaccionales.
- Ejecutar `callTroncalSave()` o `callTroncalDelete()`.

Ejemplo conceptual:

```dart
@override
Future<void> save() async {
  SmxRowSet rstWrite = getRowSetWrite()!;

  rstWrite.update('CAMPO_NUMERICO', getNumericDbl('CAMPO_NUMERICO'));

  Map<String, dynamic> otrosValores = {};
  otrosValores['DESCRIPCION'] = rstWrite.getValue('DESCRIPCION');

  if (isAltaRst()) {
    insertValueBrowserRow(rstWrite, otrosValores);
  } else {
    saveValueBrowserRow(rstWrite, otrosValores);
  }

  await callTroncalSave(rstWrite);
}
```

## dataFromBrowser

Todas las pantallas SMX heredan de `SmxStatefulWidget`, que tiene `dataFromBrowser`.

`dataFromBrowser` es el canal por donde viaja el contexto transaccional entre browser, ABM, tabs y detalles.

Contiene, entre otros:

- `tablaTroncalRst`
- `controllerPadre`
- `dataGridSource`
- `dataGridBrowser`
- `accion`
- `context`
- `alias`
- `tablaTroncal`

Este objeto permite que un ABM sepa si esta creando o editando, cual es el rowset activo, quien es el padre y que browser debe actualizar.

## callTroncal

El core usa `callTroncal()` para abrir una pantalla ABM desde un browser.

Flujo conceptual:

```text
Browser selecciona nuevo/editar
-> callTroncal()
-> consulta la tabla troncal
-> crea o recupera SmxRowSet
-> posiciona la fila activa
-> construye SmxControllerSendData
-> inyecta dataFromBrowser en el screenWidget
-> navega al ABM
```

Esto evita pasar parametros manualmente por constructores. El core arma el contexto completo.

## Cabecera y detalle

Un modulo padre puede tener detalles. Cada detalle puede ser otro modulo completo con `browser` y `crud`.

Ejemplo conceptual:

```text
sicingr01/
├── browser/
├── crud/
└── sicingr02/
    ├── browser/
    └── crud/
```

`sicingr01` es cabecera. `sicingr02` es detalle.

El detalle obtiene el rowset padre desde:

```dart
data.controllerPadre!.getRowSetWrite()
```

Y puede filtrar su browser usando el ID de la cabecera:

```dart
SQL = 'SELECT * FROM DETALLE WHERE RELA_PADRE = '
      '${data.controllerPadre!.getRowSetWrite()!.getId()}';
```

## SmxTabbedPage y detalles

Los detalles suelen vivir dentro de tabs.

`SmxTabbedPage` inyecta automaticamente el controller padre en cada pantalla hija:

```dart
ctlPadre.dataFromBrowser.context = context;
ctlPadre.dataFromBrowser.controllerPadre = widget.controller;
```

Esto permite que el detalle conozca al ABM padre sin pasar parametros manuales.

Patron:

```dart
SmxTabbedPage(
  controller: controller,
  screens: {
    'Detalle': MiDetalle(),
  },
)
```

## Transaccion de detalle

Un detalle no necesariamente guarda directamente en el servidor.

Normalmente:

1. Obtiene el rowset padre.
2. Obtiene su propio rowset de escritura.
3. Actualiza relacion con el padre si es alta.
4. Inserta o actualiza la fila del browser detalle.
5. Cuelga su rowset como detalle transaccional del padre.

Ejemplo:

```dart
@override
Future<void> save() async {
  SmxRowSet rstPadre = data.controllerPadre!.getRowSetWrite()!;
  SmxRowSet rstDetalle = getRowSetWrite()!;

  if (isAltaRst()) {
    rstDetalle.update('RELA_PADRE', rstPadre.getId());
    insertValueBrowserRow(rstDetalle, otrosValores);
  } else {
    saveValueBrowserRow(rstDetalle, otrosValores);
  }

  rstPadre.setDetTransaction(rstDetalle);
}
```

La cabecera conserva ese detalle hasta que se ejecute el guardado troncal.

## setDetTransaction

`SmxRowSet.setDetTransaction(rowsetDetalle)` agrega o actualiza detalles dentro del rowset padre.

Conceptualmente:

```text
RowSet cabecera
└── row activa
    └── rowDetTransaction[]
        ├── detalle insertado
        ├── detalle actualizado
        └── detalle eliminado
```

Esto permite serializar una transaccion compuesta:

```text
Cabecera + Detalles + Acciones ABM
```

El core luego puede convertir esa estructura en JSON para enviarla al servidor.

## Guardado troncal

El guardado final se hace con:

```dart
await callTroncalSave(rstWrite);
```

`callTroncalSave()` decide si es insert o update:

- Si es alta, usa servicio de insert.
- Si es modificacion, usa servicio de update.

Luego toma:

```dart
jsonSend.rowsABM = rstWrite.getRowsABM();
```

Esto envia al servidor las filas ABM, incluyendo detalles transaccionales cuando estan colgados en el rowset.

## Delete

Para una cabecera:

```dart
await callTroncalDelete();
```

Para un detalle:

```dart
detalleDelete();
```

`detalleDelete()` marca/elimina el detalle en el rowset correspondiente, lo cuelga nuevamente del padre y actualiza el browser visible.

## Combos y datos auxiliares

Los controllers pueden cargar rowsets auxiliares para combos:

```dart
addSql('ALIAS_COMBO', 'SELECT * FROM CBO_TABLA ORDER BY CODIGO');
await getRowSetFuture('ALIAS_COMBO');
```

Luego el widget visual usa ese alias:

```dart
SmxComboBoxGrid(
  field: 'ALIAS_COMBO',
  fieldView: 'DESCRIPCION',
  controller: controller,
)
```

Para altas se pueden posicionar defaults:

```dart
setPositionCbos('ALIAS_COMBO', 'DESCRIPCION');
```

o filtrando por campo:

```dart
setPositionCbos(
  'ALIAS_COMBO',
  'DESCRIPCION',
  campo: 'CODIGO',
  filtro: 'MXN',
);
```

## Validacion

La validacion suele ocurrir en el toolbar ABM:

```dart
SmxToolBarAbm(
  controller: controller,
  onSavePressed: (confirma) {
    if (!controller.isValida()) {
      confirma.valor = false;
      return;
    }
  },
)
```

Si `confirma.valor` queda en `false`, el guardado no continua.

## Actualizacion del browser

Cuando se edita o inserta, el ABM puede actualizar la fila visible del browser sin recargar todo:

```dart
insertValueBrowserRow(rowset, otrosValores);
saveValueBrowserRow(rowset, otrosValores);
deleteValueBrowserRow(id);
```

`otrosValores` sirve para actualizar columnas calculadas, alias visuales o campos que no estan directamente en el rowset principal.

Ejemplo:

```dart
Map<String, dynamic> otrosValores = {};
otrosValores['ENTIDAD'] = rstWrite.getValue('NOMBRE');
otrosValores['RFC'] = rstWrite.getValue('RFC');
```

## Row history

El core puede conservar historial de rowsets para evitar recargar registros ya abiertos, especialmente en detalles.

En `callTroncal()` se consulta y actualiza el historial con alias e ID.

Esto ayuda a preservar modificaciones anidadas mientras la transaccion no ha sido enviada al servidor.

## Ejemplo real observado: sicingr01 / sicingr02

El modulo `sicingr01` representa una cabecera de clientes.

Estructura:

```text
sicingr01/
├── browser/
│   ├── sicingr01.dart
│   └── sicingr01_controller.dart
├── crud/
│   ├── sicingr01_abm.dart
│   └── sicingr01_abm_controller.dart
└── sicingr02/
    ├── browser/
    │   ├── sicingr02.dart
    │   └── sicingr02_controller.dart
    └── crud/
        ├── sicingr02_abm.dart
        └── sicingr02_abm_controller.dart
```

`sicingr01/browser` lista clientes.

`sicingr01/crud` edita la cabecera y muestra datos de persona/cliente. Dentro del ABM, un `SmxTabbedPage` carga el detalle `sicingr02`.

`sicingr02/browser` lista bancos del cliente seleccionado usando el ID de la cabecera.

`sicingr02/crud` edita un banco. Al guardar, no dispara una transaccion independiente al servidor; actualiza el rowset detalle y lo agrega al rowset padre con `setDetTransaction()`.

Luego `sicingr01_abm_controller.save()` toma el troncal, agrega detalles existentes y ejecuta `callTroncalSave()`.

## Flujo completo

```text
Browser cabecera
-> SmxDataGridBrowser
-> callTroncal()
-> ABM cabecera
-> SmxCallBaseStateful
-> Controller ABM padre
-> RowSet troncal activo
-> SmxTabbedPage
-> Browser detalle
-> ABM detalle
-> RowSet detalle
-> setDetTransaction(rowsetDetalle)
-> Guardado padre
-> callTroncalSave(rowsetTroncal)
-> getRowsABM()
-> JSON transaccional
-> servidor
```

## Reglas para nuevos modulos CRUD Plus

1. Crear siempre `browser` y `crud` cuando el modulo sea transaccional.
2. El browser debe usar `SmxDataGridBrowser` cuando sea listado editable.
3. El browser controller define alias y SQL del listado.
4. El ABM debe heredar de `SmxStatefulWidget`.
5. El ABM debe recibir `widget.dataFromBrowser`.
6. El ABM controller debe extender `SmxController`.
7. Los widgets visuales deben bindear por `field`.
8. Los detalles deben ser modulos completos si tienen listado y edicion propia.
9. Los detalles deben usar `data.controllerPadre` para acceder a la cabecera.
10. Los detalles deben colgar cambios con `setDetTransaction()`.
11. El guardado real de cabecera y detalles debe hacerse desde el troncal con `callTroncalSave()`.
12. No crear modelos Dart manuales si el rowset y el core ya representan la estructura.
13. Usar `otrosValores` para columnas visuales/calculadas del browser.
14. Usar `detalleDelete()` para eliminar detalles dentro de una transaccion padre.
15. Mantener alias consistentes y en mayusculas.

## Diferencia con CRUD tradicional

CRUD tradicional suele ser:

```text
Formulario -> modelo -> API save
```

CRUD Plus SMX/Venture es:

```text
Browser -> RowSet troncal -> ABM -> Detalles -> setDetTransaction -> getRowsABM -> servidor
```

La diferencia principal es que la transaccion puede incluir cabecera, detalles, altas, cambios y bajas como una sola estructura serializable.

## Nota para futuros colaboradores

No simplificar este patron a una arquitectura Flutter generica sin entender el core.

La plataforma usa rowsets, alias, controllers padre, `dataFromBrowser`, grids, ABM y transacciones anidadas para resolver problemas empresariales complejos.

El contrato tecnico es:

```text
SmxDataGridBrowser + SmxController + SmxRowSet + SmxStatefulWidget + dataFromBrowser + setDetTransaction + callTroncalSave
```

Ese contrato debe respetarse al crear o modificar modulos transaccionales.
