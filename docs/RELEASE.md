Descarga el archivo **Porta-1.3.1-universal-beta.dmg** de Assets. Los archivos «Source code» son para desarrollo.

**[Guía visual de instalación](https://martinzg16.github.io/porta/#instalar)**. El instalador contiene solo Porta y el acceso a Aplicaciones; no incluye archivos LEEME.

1. Abre el DMG y arrastra Porta a Aplicaciones.
2. Expulsa el disco y abre Porta desde Aplicaciones.
3. Copia algo y pulsa **⌘⌥V** para abrir el historial.

**Mac Intel o Apple Silicon, macOS 14 o posterior.** No requiere Xcode ni Terminal. No funciona en Windows o Linux.

**Beta sin notarizar:** macOS puede bloquear la primera apertura. Solo si confías en esta descarga oficial, tras intentar abrirla utiliza Ajustes del Sistema → Privacidad y seguridad → Abrir igualmente. No desactives Gatekeeper. Los equipos gestionados pueden impedirlo.

Novedades: paquete universal, guía de bienvenida y posibilidad de recuperar una copia sin conceder Accesibilidad. Para pegar automáticamente, concede ese permiso; sin él, Enter copia el elemento, Esc cierra el selector y ⌘V lo pega.

Para actualizar, sal de Porta antes de reemplazarla. El historial se conserva. Las actualizaciones de esta beta pueden requerir renovar el permiso de Accesibilidad. No hay actualización automática.

El proceso de publicación verifica el mismo DMG en macOS 14 ARM, macOS 15 Intel y macOS 26 ARM: integridad, firma local, instalación por copia y pruebas de clasificación, persistencia y formatos del portapapeles. Esto no certifica todas las aplicaciones ni el pegado automático en todos los equipos. Informa de problemas con pasos y datos ficticios en Issues.

El historial es local y no está cifrado. No uses Porta como gestor de contraseñas.

### Seguridad en esta versión

Permisos privados para la carpeta y los archivos del historial, rechazo de enlaces simbólicos al cargar datos, límites al tamaño del historial y hardened runtime. La web limita scripts y recursos mediante CSP; las acciones de CI están fijadas a commits. El historial sigue sin cifrar y esta beta no está notarizada.
