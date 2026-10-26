# Desarrollo

## Estructura

```text
Source/main.swift        Modelo, captura, categorías, interfaz y pruebas
Resources/Info.plist      Metadatos del paquete de macOS
build.sh                 Compilación y firma local
Porta.app/               Resultado generado; excluido de Git
```

Requisitos: macOS 14 o posterior, Intel o Apple Silicon y herramientas de línea de comandos de Xcode. La compilación utiliza Swift en modo de lenguaje 5 y los frameworks AppKit, ApplicationServices, CryptoKit y Carbon.

```sh
zsh build.sh
```

El script copia el Info.plist, compila los ejecutables ARM64 e Intel y los combina con lipo y aplica una firma ad hoc. No hace una distribución notarizada. `SWIFT_MODULECACHE_PATH` permite cambiar la ubicación de la caché del compilador.

## Pruebas

```sh
# Solo clasificación y compatibilidad del modelo; sin acceder al portapapeles:
Porta.app/Contents/MacOS/Porta --category-self-test

# Añade pruebas sobre un portapapeles de nombre único:
Porta.app/Contents/MacOS/Porta --self-test

# Registro real del atajo; cerrar antes la instancia normal de Porta:
Porta.app/Contents/MacOS/Porta --shortcut-self-test
```

Las pruebas usan ejemplos sintéticos. El test completo no altera el portapapeles general y comprueba texto, imágenes, referencias a archivos, persistencia, deduplicación, exclusiones y tamaño máximo. Requiere una sesión de macOS que permita los servicios de AppKit y portapapeles.

La prueba del atajo registra y libera Command + Option + V. Puede fallar si otra app o una instancia de Porta ya tiene registrada la combinación. No prueba por sí sola la interacción de teclado ni la compatibilidad con Wispr.

## Comprobación manual

1. Copiar varios textos y abrir el selector con Command + Option + V.
2. Buscar, cambiar filtros y corregir una categoría.
3. Copiar de nuevo el mismo contenido y comprobar que conserva la corrección.
4. Cerrar y abrir Porta para comprobar persistencia.
5. Pegar en una app de destino con Accesibilidad concedida.
6. Probar Command + V y un dictado real con Wispr.
7. Pausar y reanudar; comprobar que el atajo se libera y vuelve a registrarse.

## Actualizaciones locales

Compilar no sustituye el proceso que ya está abierto: salir de Porta desde su menú y abrir la nueva app. La firma ad hoc puede requerir renovar Accesibilidad tras recompilar. Abrir el historial debe seguir funcionando sin ese permiso.

No añadir historiales, diagnósticos locales ni capturas que contengan datos reales al repositorio. Para informes de errores, usar ejemplos sintéticos y describir pasos reproducibles.

## Distribución

```sh
zsh scripts/package.sh
zsh scripts/verify-package.sh dist/Porta-1.3.1-universal-beta.dmg
```

Genera un DMG con Porta, un acceso a Aplicaciones y SHA-256.
El verificador copia la aplicación fuera del DMG, valida su firma y ejecuta
las pruebas sobre esa copia. No usa el historial ni el portapapeles general.

GitHub Actions construye un único DMG en macOS 14 y prueba ese mismo archivo
en macOS 14 ARM, 15 Intel y 26 ARM. Un tag `v1.3.1-beta.1` publica una prerelease
solo cuando todas las comprobaciones pasan. Los otros pushes solo prueban.
Antes de crear un nuevo tag, actualizar versión, build y notas de release.

### Firma y notarización

No subir certificados, contraseñas ni claves al repositorio. Configurar un
certificado Developer ID Application en el llavero y credenciales mediante
`xcrun notarytool store-credentials`. Después:

```sh
SIGNING_IDENTITY="Developer ID Application: NOMBRE (TEAMID)" \
NOTARY_PROFILE="porta-notary" zsh scripts/package.sh
```

La variante firmada exige notarización aceptada, adjunta el ticket y comprueba
Gatekeeper antes de crear el DMG sin el sufijo beta. Esta ruta requiere un
certificado real y no queda validada por las pruebas de la beta ad hoc.
Referencia: https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution

### Validación manual antes de recomendar uso general

En un Mac limpio, descargar desde GitHub con Safari, instalar en Aplicaciones
y comprobar Gatekeeper, bienvenida, captura, búsqueda, copia sin permiso,
pegado con permiso, reinicio, actualización y conflicto de atajo.
Probar al menos TextEdit, Finder, un navegador y las aplicaciones destino
habituales. CI no concede Accesibilidad ni verifica el pegado entre apps.
