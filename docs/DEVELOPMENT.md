# Desarrollo

## Estructura

```text
Source/main.swift        Modelo, captura, categorías, interfaz y pruebas
Resources/Info.plist      Metadatos del paquete de macOS
build.sh                 Compilación y firma local
Porta.app/               Resultado generado; excluido de Git
```

Requisitos: macOS 14 o posterior, Apple Silicon y herramientas de línea de comandos de Xcode. La compilación utiliza Swift en modo de lenguaje 5 y los frameworks AppKit, ApplicationServices, CryptoKit y Carbon.

```sh
zsh build.sh
```

El script copia el Info.plist, compila el ejecutable ARM64 y aplica una firma ad hoc. No hace una distribución notarizada. `SWIFT_MODULECACHE_PATH` permite cambiar la ubicación de la caché del compilador.

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
