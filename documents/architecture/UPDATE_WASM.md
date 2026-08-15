# UPDATE_WASM

## Objetivo

Preparar `venture_saldify` para compilar Flutter Web con WebAssembly sin
modificar los paquetes compartidos `venture_core_connect` y
`venture_widgets`.

## Alcance

El cambio corresponde solamente al proyecto Saldify. Los paquetes Venture ya
utilizan implementaciones compatibles con Wasm, incluyendo `dart:js_interop`,
por lo que quedan fuera de esta actualizacion.

## Archivos de Saldify por adaptar

Actualmente existen 10 archivos que dependen directamente de
`package:universal_html/html.dart`:

1. `lib/main.dart`
2. `lib/smxSaldifyLogon/smxSaldifyAccessSession.dart`
3. `lib/smxMenuVersion.dart`
4. `lib/smxSaldifyLogon/smxSaldifyLogon.dart`
5. `lib/smxLayout/smxLayout.dart`
6. `lib/smxAuth/smxLogonMovil.dart`
7. `lib/smxAuth/storage/smxAuthStorage.dart`
8. `lib/smxLayout/smxScreens/smxComprasCarrito/smxComprasCarritoStorage.dart`
9. `lib/smxApis/smxConstants.dart`
10. `lib/smxSaldify/smxSaldify_screens/saldify_reportes/smxSaldiFy_reportes_pdf.dart`

Los usos se dividen en:

- Almacenamiento local: sesion de acceso, identidad y borradores del carrito.
- Navegacion web: historial, documentacion y cambio de URL.
- Layout web: deteccion PWA y consulta del documento.
- Eventos web: bloqueo global de drag and drop.
- Acceso a camara.
- Apertura y descarga de PDF.

## Estandar propuesto

Centralizar estas operaciones en una capa de plataforma, por ejemplo
`SmxPlatformManager`, con importaciones condicionales y las implementaciones
necesarias para Web/Wasm y plataformas nativas. Los widgets y controladores de
Saldify deben consumir el contrato comun y no importar APIs del navegador de
forma directa.

## Dependencias

Revisar `pubspec.yaml` despues de migrar los usos anteriores:

- Eliminar `universal_html` cuando ningun archivo de Saldify lo importe.
- Eliminar `image_picker_web`, ya que Saldify lo declara directamente pero no
  lo utiliza en su codigo.

## Compilacion

Actualizar `build_saldify.sh` para compilar con la opcion `--wasm` una vez
terminada la adaptacion y validados todos los accesos de plataforma.

## Validacion requerida

- Compilacion release de Saldify con Wasm.
- Inicio de sesion de Google mediante popup.
- Inicio de sesion de Google mediante redirect.
- Persistencia de sesion e identidad.
- Apertura de documentacion.
- Acceso a camara y permisos.
- Carga de imagenes mediante los widgets compartidos.
- Generacion y apertura de reportes PDF.
- Persistencia del carrito.
- Funcionamiento instalado como PWA.

## Firebase

La autenticacion ya utiliza `firebase_auth` y no requiere una reescritura para
esta actualizacion. Los flujos popup y redirect deben probarse nuevamente en el
build Wasm usando la configuracion del proyecto Firebase `saldify`.

