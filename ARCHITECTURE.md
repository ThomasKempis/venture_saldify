# Arquitectura del proyecto Venture Saldify

Este documento resume la arquitectura actual del proyecto y la filosofia de la plataforma SMX/Venture. Debe leerse antes de crear pantallas, controllers, mocks o conexiones nuevas, especialmente si se trabaja con Codex, IA u otro desarrollador que no conoce el framework interno.

## Vision general

Venture Saldify no debe tratarse como una app Flutter comun basada solamente en modelos Dart, listas hardcodeadas y widgets que consumen objetos manuales.

La app se apoya en una plataforma empresarial propia donde:

- El servidor entrega datos estructurados como JSON.
- El core del cliente deserializa ese JSON y lo convierte en `SmxRowSet`.
- Los controllers extienden de `SmxController` y administran el ciclo de vida, carga, transacciones y estado.
- Los widgets leen datos desde el controller y desde rowsets.
- El binding de datos se hace por nombres de campo, alias y fila activa.
- En produccion, los mocks temporales se reemplazan por llamadas reales al servidor, web service o websocket.

El objetivo es que la UI este preparada desde el inicio para consumir datos como lo hara en produccion, sin depender de modelos Dart temporales que luego habria que desmontar.

## Filosofia de datos

La pieza central de datos es `SmxRowSet`.

Un `SmxRowSet` representa un conjunto de filas con campos nombrados. El rowset tiene una fila activa. Para leer valores, primero se posiciona la fila con `index(i)`, `first()` u otro metodo de navegacion, y despues se llama `getValue('CAMPO')`.

Ejemplo:

```dart
for (int i = 0; i < rstClientes.getRowCount(); i++) {
  rstClientes.index(i);

  final nombre = rstClientes.getValue('NAME')?.toString() ?? '';
  final saldo = rstClientes.getValue('BALANCE')?.toString() ?? '';
}
```

Este patron es importante porque se parece al flujo real de la plataforma: el servidor devuelve un rowset, el cliente lo transforma en memoria, los widgets leen por campo y despues el core puede serializar de vuelta para enviar transacciones.

### Lectura tipada con `getValue()`

`SmxRowSet.getValue('CAMPO')` ya interpreta el tipo del campo definido en el rowset. Para campos numericos, como `INT`, `LNG` o `DBL`, el core devuelve valores numericos y normaliza `null` o cadena vacia a `0` o `0.0` segun corresponda.

Por eso, si el stored procedure o la tabla ya entrega el campo con el tipo correcto, evitar helpers redundantes como parsear de nuevo con `double.tryParse(...)`, envolver cada lectura en `try/catch`, o convertir a string antes de sumar. Es preferible leer directo:

```dart
final credito = rstMetricas.getValue('SYSUSER12_CREDITO');
final disponible = rstMetricas.getValue('SYSUSER12_DISPONIBLE');
```

Solo agregar conversiones manuales cuando el dato realmente venga como texto o cuando el origen no tenga metadata/tipo confiable.

## SmxController

Los controllers de modulos deben extender directamente de `SmxController` cuando formen parte del flujo real de la plataforma.

Patron base:

```dart
class MiModuloController extends SmxController {
  late SmxRowSet rstDatos;

  MiModuloController({required super.alias, required super.data});

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();
    rstDatos = getRstMiModuloMock();
    rstDatos.first();
  }

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

Reglas importantes:

- No extender de `SmxTmpCtl` para modulos reales del dashboard.
- Usar `SmxController` directamente.
- Cargar datos en `init()`.
- Usar `beginDB()` para marcar el inicio del ciclo del controller.
- Evitar modelos Dart innecesarios si el dato real vendra como `SmxRowSet`.
- Exponer metodos de lectura especificos cuando ayuden a la UI, por ejemplo `getClientName()` o `getActionIcon()`.

## SmxCallBaseStateful

Los widgets que dependen de controllers SMX deben inicializarse con `SmxCallBaseStateful`.

Ejemplo:

```dart
return SmxCallBaseStateful<MiModuloController>(
  controllerBuilder: (context) => MiModuloController(
    alias: 'MI_MODULO',
    data: SmxControllerSendData(context: context),
  ),
  builder: (context, controller) => MiModuloView(controller: controller),
);
```

Esto permite que el controller ejecute `init()` antes de que la vista consuma datos. El widget queda alineado al ciclo real del framework.

## Mocks temporales

Los mocks actuales no deben verse como modelos definitivos. Son simulaciones temporales del rowset que en produccion llegara desde el servidor.

Patron recomendado:

```dart
SmxRowSet getRstMiModuloMock() {
  return SmxRowSet.newRowSet(_rstMiModuloMock);
}

final List<Map<String, dynamic>> _rstMiModuloMock = [
  {'NAME': 'Maria Lopez', 'BALANCE': r'$4,800'},
  {'NAME': 'Carlos Rivera', 'BALANCE': r'$7,100'},
];
```

Reglas:

- Los campos deben escribirse como alias de datos, preferiblemente en mayusculas.
- Usar nombres que puedan venir del servidor: `NAME`, `STATUS`, `BALANCE`, `ICON_KEY`.
- No guardar objetos visuales complejos dentro del rowset si esos datos no vendrian del servidor.
- El mock debe parecerse a un rowset real, no a una clase visual de Flutter.

## Iconos y datos visuales

El servidor no deberia mandar `IconData`, ni el rowset deberia depender de objetos Flutter como `Icons.add_rounded`.

El dato debe viajar como codigo o alias:

```dart
{'ICON_KEY': 'CLIENTE', 'LABEL': 'Cliente'}
```

El controller traduce ese codigo a UI:

```dart
IconData getActionIcon() {
  final iconKey = rstAcciones.getValue('ICON_KEY')?.toString() ?? '';

  return switch (iconKey) {
    'CLIENTE' => Icons.add_rounded,
    'PAGO' => Icons.attach_money_rounded,
    'CREDITO' => Icons.north_east_rounded,
    'REPORTE' => Icons.bar_chart_rounded,
    _ => Icons.touch_app_rounded,
  };
}
```

Esto mantiene separada la informacion de negocio de la representacion visual.

## Estructura actual de Saldify

La estructura actual separa el shell principal, menu, pantallas y modulos del dashboard.

```text
lib/
├── smxColors.dart
├── smxLayout.dart
├── smxThemeData.dart
└── smxSaldify/
    ├── smxSaldify.dart
    ├── smxSaldiFy_menu_lateral.dart
    ├── smxSaldify_dashboard/
    │   ├── smxSaldiFy_dashboard.dart
    │   ├── smxSaldiFy_red_clientes/
    │   │   ├── smxSaldiFy_red_clientes.dart
    │   │   ├── smxSaldiFy_red_clientes_controller.dart
    │   │   └── smxSaldiFy_red_clientes_mock.dart
    │   ├── smxSaldiFy_acciones_rapidas/
    │   │   ├── smxSaldiFy_acciones_rapidas.dart
    │   │   ├── smxSaldiFy_acciones_rapidas_controller.dart
    │   │   └── smxSaldiFy_acciones_rapidas_mock.dart
    │   ├── smxSaldiFy_clientes/
    │   │   ├── smxSaldiFy_clientes.dart
    │   │   ├── smxSaldiFy_clientes_controller.dart
    │   │   └── smxSaldiFy_clientes_mock.dart
    │   └── smxSaldiFy_invita_clientes/
    │       └── smxSaldiFy_invita_clientes.dart
    └── smxSaldify_screens/
        ├── smxSaldiFy_perfil.dart
        └── smxSaldiFy_screen_tmp.dart
```

## Responsabilidades por archivo

### `smxSaldify.dart`

Es el punto principal del modulo Saldify.

Responsabilidades:

- Manejar el indice de navegacion seleccionado.
- Construir dashboard o perfil segun la opcion activa.
- Decidir layout mobile/tablet/desktop usando `SmxLayout`.
- Integrar el menu lateral o panel de navegacion.
- Pasar `menuButton` a las pantallas cuando aplica.

No deberia concentrar logica interna de dashboard, tarjetas, listas o datos.

### `smxSaldiFy_menu_lateral.dart`

Contiene la navegacion visual:

- Drawer en mobile.
- Panel lateral en tablet/desktop.
- Boton de menu para abrir el drawer.

El menu llama a las pantallas; no debe mezclar logica de datos del dashboard.

### `smxSaldify_dashboard/smxSaldiFy_dashboard.dart`

Agrupa los modulos visuales del dashboard:

- Red de clientes.
- Invitacion de clientes.
- Acciones rapidas.
- Lista de clientes.

Debe orquestar la composicion visual del dashboard, pero no cargar datos directamente si esa logica pertenece a controllers de cada modulo.

### Carpetas de modulos del dashboard

Cada modulo debe tener su propia carpeta cuando tenga logica propia:

```text
smxSaldiFy_modulo/
├── smxSaldiFy_modulo.dart
├── smxSaldiFy_modulo_controller.dart
└── smxSaldiFy_modulo_mock.dart
```

Esto evita que el dashboard principal mezcle logicas de clientes, pagos, metricas, creditos o transacciones.

### `smxSaldify_screens/`

Este directorio contiene pantallas llamadas desde el menu, no piezas internas del dashboard.

Ejemplos:

- Perfil.
- Pantallas temporales.
- Futuras pantallas completas del sistema.

## Layout y tema

La app centraliza criterios visuales globales en:

- `smxColors.dart`
- `smxThemeData.dart`
- `smxLayout.dart`

### `smxColors.dart`

Contiene colores y gradientes del proyecto. Los widgets deben preferir esta paleta en vez de repetir `Color(0x...)`.

### `smxThemeData.dart`

Concentra configuracion de Material/theme global.

### `smxLayout.dart`

Centraliza decisiones de layout responsivo y ayuda a evitar duplicar reglas para mobile, tablet, desktop, notch y alturas base.

## Criterios para nuevas pantallas

Cuando se cree una nueva pantalla o modulo:

1. Definir si es una pantalla del menu o un modulo interno del dashboard.
2. Crear carpeta propia si tendra controller, datos o logica.
3. Crear controller extendiendo `SmxController`.
4. Crear mock temporal como `SmxRowSet`.
5. Inicializar el controller con `SmxCallBaseStateful`.
6. Hacer que la UI lea datos desde el controller/rowset.
7. Evitar modelos Dart si el dato real vendra del rowset del servidor.
8. No meter logica de negocio en widgets principales.
9. No meter objetos visuales complejos en el rowset; usar codigos y traducirlos en el controller.
10. Mantener colores y layout usando `smxColors.dart` y `smxLayout.dart`.

## Relacion con el servidor

La plataforma esta pensada para un flujo cliente-servidor propio:

1. El cliente solicita datos.
2. El servidor consulta y arma JSON estructurado.
3. El cliente recibe y deserializa.
4. El core convierte los datos a `SmxRowSet`.
5. Los controllers administran los rowsets.
6. Los widgets se bindean por campo, alias o fila activa.
7. Para guardar o ejecutar transacciones, el core puede serializar de vuelta el rowset.
8. El servidor recibe la transaccion y ejecuta la operacion correspondiente.

Esto se parece conceptualmente a tecnologias empresariales como PowerBuilder DataWindow, Delphi DataSet, Oracle Forms, .NET DataSet o Meteor DDP, pero adaptado al framework propio SMX/Venture y a Flutter.

## Diferencia con Flutter tradicional

En Flutter comun es frecuente crear:

```text
Model -> Provider/Riverpod/BLoC -> Widget
```

En esta plataforma, muchas veces el modelo Dart no es necesario porque el servidor ya entrega una estructura que el core convierte en `SmxRowSet`.

El patron preferido aqui es:

```text
Servidor JSON -> SmxRowSet -> SmxController -> Widget/binding
```

Los modelos Dart solo deben agregarse cuando aporten valor real y no contradigan el flujo de rowsets.

## Estado actual del dashboard

Los siguientes modulos del dashboard ya estan alineados al patron `SmxController + SmxRowSet`:

- `SmxSaldiFyRedClientesController`
- `SmxSaldiFyAccionesRapidasController`
- `SmxSaldiFyClientesController`

Cada uno carga mocks temporales como rowsets y sus widgets consumen esos datos desde controllers inicializados con `SmxCallBaseStateful`.

## Nota para futuros colaboradores

Antes de modificar este proyecto, entender que la arquitectura busca madurez empresarial, modularidad y preparacion para produccion.

No convertir automaticamente los rowsets en modelos Dart solo porque sea comun en Flutter. Primero revisar si el dato debe permanecer como `SmxRowSet` por compatibilidad con el core, binding, alias, serializacion y transacciones.

La prioridad es respetar la plataforma SMX/Venture:

```text
SmxController + SmxRowSet + alias/campos + binding + core de serializacion
```

Ese es el contrato principal del proyecto.
