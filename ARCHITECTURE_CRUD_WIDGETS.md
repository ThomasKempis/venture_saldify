# Arquitectura de Widgets SMX/Venture

Este documento describe el rol general del paquete `venture_widgets` dentro de la plataforma SMX/Venture.

Debe leerse junto con:

- `ARCHITECTURE.md`
- `ARCHITECTURE_CRUD_PLUS.md`

Este archivo no documenta todavia cada widget en profundidad. Su objetivo es explicar la idea general: los widgets SMX no son simples componentes visuales de Flutter, sino piezas propietarias integradas al `SmxController`, `SmxRowSet`, `SmxFactoryWidgets`, validacion y flujo transaccional.

## Idea central

En pantallas transaccionales reales no se deben usar inputs Flutter nativos como reemplazo directo de los widgets SMX.

La razon es que los widgets SMX participan del framework:

```text
Widget SMX
-> SmxFactoryWidgets
-> SmxControllerImpl
-> SmxController
-> SmxRowSet
-> getRowsABM()
-> JSON transaccional
-> servidor
```

Un `TextField` nativo puede verse correcto en pantalla, pero no queda registrado en el controller, no actualiza automaticamente el rowset troncal, no participa igual en validaciones del framework y puede quedar fuera de la transaccion.

## El tercer pilar de la plataforma

La arquitectura no es solamente:

```text
SmxController + SmxRowSet
```

La arquitectura completa incluye:

```text
SmxRowSet
   ↕
SmxController / SmxControllerImpl
   ↕
SmxFactoryWidgets
   ↕
Widgets propietarios SMX
```

Los widgets propietarios son la capa visual que entiende el contrato del controller.

## SmxFactoryWidgets

`SmxFactoryWidgets` es la estructura donde el controller registra los widgets por tipo y alias/campo.

Tipos principales observados:

```dart
enum widgetSmx {
  TEXT,
  TEXTAREA,
  CBO,
  CBOGRID,
  DATE,
  NUMBER,
  FILE,
  LOGICO,
  LABEL
}
```

Cada widget puede guardar:

- tipo de widget;
- referencia al widget;
- alias/campo;
- valor actual;
- valor anterior;
- descripcion de combo;
- banderas de validacion.

Esto permite que el controller conozca los inputs registrados y pueda leerlos, escribirlos, validarlos y sincronizarlos con el rowset.

## SmxControllerImpl

`SmxControllerImpl` contiene el mapa de widgets:

```dart
final Map<String, SmxFactoryWidgets> _factoryWidgets = {};
```

Y ofrece metodos especializados:

- `setText()` / `getText()`
- `setTextArea()` / `getTextArea()`
- `setNumericDbl()` / `getNumericDbl()`
- `setNumericInt()` / `getNumericInt()`
- `setIdCbo()` / `getIdCbo()`
- `setIdCboGrid()` / `getIdCboGrid()`
- `setDate()` / `getDate()`
- `setLogico()` / `getLogico()`
- `setLabel()` / `getLabel()`
- `setFile()` / `getFile()`

Estos metodos no solo guardan valores en memoria. Tambien actualizan el rowset troncal cuando existe:

```text
controller.setText(field, value)
-> factoryWidgets[field].setValue(value)
-> getRowSetWrite().update(field, value)
```

## Registro de widgets

Los widgets SMX se registran en el controller durante `initState()`.

Ejemplo conceptual:

```dart
widget.controller.setValueFactory(
  widgetSmx.TEXT,
  widget.field,
  widget: widget,
);
```

Esto permite que el controller tenga tracking del campo y de su widget visual.

## Lectura inicial de valores

Los widgets SMX suelen buscar su valor inicial en este orden conceptual:

1. valor recibido por parametro;
2. `getRowSetWrite()`;
3. fila del browser;
4. valor ya guardado en la factory del controller;
5. default interno.

Esto permite que el mismo widget funcione en alta, edicion, detalle, tab, browser o pantalla reutilizada.

## Escritura de valores

Cuando el usuario cambia un widget SMX, el valor no queda solo en pantalla.

El widget empuja el cambio hacia:

```text
controller
-> factory
-> rowset troncal
```

Ejemplo conceptual:

```dart
widget.controller.setText(widget.field, value);
widget.controller.getRowSetWrite()?.update(widget.field, value);
```

Esta es la razon por la que los inputs propietarios son parte de la transaccion.

## Validacion

`SmxControllerImpl.validateWidgets(context)` recorre los widgets registrados.

Puede validar:

- campos de texto requeridos;
- numeros requeridos o en cero;
- combos requeridos;
- combos grid requeridos;
- metadata del rowset, por ejemplo `getFieldsHeader(key).requerido`;
- reglas propias del widget, como `isValid`.

La validacion no es solo visual. Esta conectada al controller y al metadata del rowset.

## Familias de widgets

El paquete `venture_widgets` incluye varias familias. Algunas son directamente transaccionales y otras son estructurales, auxiliares o especializadas.

## Inputs y campos bindeados

Widgets principales para ABM y formularios:

- `SmxTextField`
- `SmxTextArea`
- `SmxNumberField`
- `SmxDatePicker`
- `SmxCheckBox`
- `SmxComboBox`
- `SmxComboBoxGrid`
- `SmxLabel`

Estos widgets son los mas sensibles para el flujo transaccional. En ABM reales, deben preferirse sobre widgets Flutter nativos.

### SmxTextField

Campo de texto propietario.

Funciones observadas:

- se registra como `widgetSmx.TEXT`;
- lee valor desde rowset/browser/controller;
- soporta tipos como email, telefono, RFC, geolocalizacion, mayusculas y password;
- formatea entrada;
- valida patrones especiales;
- actualiza controller y rowset al cambiar.

### SmxNumberField

Campo numerico propietario.

Funciones observadas:

- se registra como `widgetSmx.NUMBER`;
- lee valor desde rowset;
- formatea numeros en locale `es_MX`;
- maneja decimales, enteros, moneda, longitud, minimo y maximo;
- actualiza controller y rowset como int o double.

### SmxComboBoxGrid

Combo basado en grid.

Funciones observadas:

- se registra como `widgetSmx.CBOGRID`;
- usa un rowset auxiliar por alias;
- abre un `SmxDataGrid` para seleccion;
- guarda ID real en el controller;
- guarda descripcion visual separada;
- actualiza el rowset troncal con la relacion/ID.

Este widget representa muy bien la filosofia SMX: el usuario ve descripcion, la transaccion guarda clave.

### SmxDatePicker

Campo de fecha propietario.

Funciones observadas:

- se registra como `widgetSmx.DATE`;
- lee fecha desde rowset o default;
- formatea visualmente;
- actualiza controller y rowset al seleccionar fecha;
- soporta campo vacio cuando aplica.

### SmxCheckBox

Campo logico propietario.

Funciones observadas:

- se registra como `widgetSmx.LOGICO`;
- interpreta bool, int o String;
- actualiza controller y rowset con `setLogico()`;
- permite labels diferentes para on/off.

### SmxFilePicker

Selector de archivos integrado al controller.

Funciones observadas:

- se registra como `widgetSmx.FILE`;
- maneja tipos de archivo como PDF, XML, ZIP, XLS, PNG, CER, KEY;
- usa `jsonSend.microServicio = FILES`;
- puede descargar o subir archivos;
- mantiene UUID/URL de archivo;
- se integra con servicios del core.

## Grids y browsers

Widgets principales:

- `SmxDataGrid`
- `SmxDataGridBrowser`
- `SmxDataGridSource`
- `SmxDataGridNavigathor`
- `SmxDataGridToolBar`
- `SmxToolBarAbm`
- `SmxDataGridReports`
- `SmxDataGridReportsTabs`

Estos componentes sostienen el patron browser/CRUD.

`SmxDataGridBrowser` es clave para:

- listar rowsets;
- abrir ABM con `screenWidget`;
- construir `dataFromBrowser`;
- registrar browsers en `stackGridBrowser`;
- insertar, editar o borrar filas visibles;
- conectar browser con `callTroncal()`.

`SmxToolBarAbm` es clave para:

- guardar;
- cancelar;
- borrar;
- validar antes de guardar;
- disparar el flujo del controller.

## Layout y composicion

Widgets principales:

- `SmxContainer`
- `SmxTabbedPage`
- `SmxAccordion`
- `SmxAccordionItem`
- `SmxRowList`
- `SmxRowScroll`
- `SmxScreenFloating`
- `SmxTmpScreen`
- `SmxButton`

### SmxTabbedPage

`SmxTabbedPage` es especialmente importante para CRUD Plus.

Funciones observadas:

- muestra pantallas en tabs;
- recibe un `SmxController` padre;
- puede deshabilitar tabs;
- puede usar pantallas completas o solo widgets;
- cuando `onlyWidgets` es false, inyecta:

```dart
ctlPadre.dataFromBrowser.context = context;
ctlPadre.dataFromBrowser.controllerPadre = widget.controller;
```

Esto permite que un detalle dentro de un tab conozca automaticamente al controller padre.

## Archivos e imagenes

Widgets principales:

- `SmxFilePicker`
- `SmxImagesCrud`
- `SmxImagesAdd`
- `SmxImagesView`

### SmxImagesCrud

`SmxImagesCrud` es un componente potente de imagenes integrado al core.

Funciones observadas:

- carga imagenes desde rowset o alias de datos;
- usa servicio `FILES`;
- sube imagenes;
- redimensiona antes de enviar;
- recibe URL/UUID del servidor;
- inserta filas en un rowset local de imagenes;
- relaciona imagenes con el registro troncal usando el ID del rowset padre;
- puede llamar `callTroncalSave()` si tiene `tablaWrite`;
- puede eliminar imagenes con `callDeleteAlt()`;
- soporta modo solo lectura y unica imagen.

Esto no es un visor simple: es un subcomponente CRUD de archivos/imagenes conectado al controller y al servidor.

## Dialogos y mensajes

Widgets y helpers:

- `showValidDialog`
- `showSystemErrorDialog`
- `showDialogWait`
- `SmxConfirmDialog`
- `NoDataAvailableMessage`
- `SmxMessagePrompt`

Estos componentes centralizan validaciones, errores de sistema, confirmaciones y esperas.

## QR, dispositivos y multimedia

Componentes observados:

- `SmxCodeQr`
- `SmxReadQRCode`
- `SmxDeviceCamPhoto`
- `SmxDeviceCamVideo`
- `SmxWebCamImpl`
- `SmxWebCamStreamer`

Esta familia extiende la plataforma hacia entrada por camara, QR, foto y video.

## Mapas y ubicacion

Componentes observados:

- `SmxViewMap`
- `SmxViewMap_controller`
- `SmxViewMap_invitacion`
- `SmxInfoUser`
- `SmxLocationService`

Esta familia parece cubrir ubicacion, mapas e informacion del usuario/dispositivo.

## Utilidades y componentes especializados

Componentes observados:

- `SmxCronometro`
- `SmxMonitorLatencia`
- `SmxComboRowForm`
- `SmxComboRowItems`
- `SmxShopping`
- `ProductCard`
- `ProductCardDet`
- `BannerCarousel`
- `CategoryChip`

Algunos son componentes de dominio o experiencias especificas. Deben analizarse caso por caso antes de reutilizarlos.

## Regla para ABM reales

Si un campo participa en una transaccion, debe usarse un widget SMX compatible con controller.

Preferir:

```text
SmxTextField
SmxNumberField
SmxDatePicker
SmxCheckBox
SmxComboBox
SmxComboBoxGrid
SmxFilePicker
SmxImagesCrud
```

Evitar como reemplazo directo en ABM:

```text
TextField
TextFormField
DropdownButton
Checkbox
showDatePicker aislado
FilePicker aislado
```

Estos widgets nativos pueden usarse para UI auxiliar si no participan del rowset ni de la transaccion, pero no deben sustituir inputs SMX en formularios transaccionales.

## Relacion con documentacion futura

Este documento es una guia general.

Mas adelante conviene crear documentacion especifica por widget o por familia:

```text
docs/widgets/
├── smx_text_field.md
├── smx_number_field.md
├── smx_combo_box_grid.md
├── smx_date_picker.md
├── smx_file_picker.md
├── smx_images_crud.md
├── smx_data_grid_browser.md
└── smx_tabbed_page.md
```

Cada ficha futura deberia incluir:

- proposito;
- parametros principales;
- como se registra en `SmxFactoryWidgets`;
- que valor lee del rowset;
- que valor escribe;
- como valida;
- como se usa en alta/edicion;
- ejemplos reales.

## Nota para futuros colaboradores

No tratar `venture_widgets` como una libreria visual generica.

Es parte del framework de datos y transacciones de SMX/Venture.

El contrato principal es:

```text
Widget propietario SMX + field/alias + SmxController + SmxFactoryWidgets + SmxRowSet
```

Cuando se construyen pantallas CRUD/ABM, los widgets propietarios son tan importantes como el controller y el rowset.
