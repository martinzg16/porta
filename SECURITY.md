# Seguridad de Porta

Para informar de un problema, utiliza la opción **Report a vulnerability** de
la pestaña Security de este repositorio. No publiques historiales, contraseñas
ni datos personales en Issues.

## Alcance y límites

Porta es una aplicación local de macOS con acceso al portapapeles. No tiene
servidor, telemetría, login, actualizador remoto ni dependencias de ejecución
de terceros. Accesibilidad solo es necesaria para simular el pegado.

- El historial sigue en texto claro, con permisos 0700 para su carpeta y 0600
  para sus archivos. Esto limita otros usuarios del sistema; NO protege de
  malware que ya se ejecute con tu usuario, de un administrador ni de copias
  de seguridad. No sustituye al cifrado ni a un gestor de contraseñas.
- Los marcadores de contenido secreto dependen de la app de origen. No se
  puede garantizar que se excluyan todas las contraseñas o tokens copiados.
- La beta usa firma ad hoc con hardened runtime, sin Developer ID ni
  notarización. No es una verificación de identidad del editor por Apple.
- La web tiene CSP en HTML y no ejecuta recursos de terceros. GitHub Pages
  no permite configurar aquí cabeceras como frame-ancestors o Permissions-Policy.
  La CSP en meta no aporta protección contra la inclusión en un iframe.
- El acceso al repositorio y a la cuenta GitHub sigue siendo parte de la
  seguridad de distribución. Se recomienda 2FA/passkeys; no se ha auditado
  la configuración privada de autenticación del titular.

## Revisión del 26 de octubre de 2026

Se revisaron Swift, scripts, workflows, código de la landing, cabeceras HTTP,
configuración de alertas GitHub y patrones de secretos en el historial Git.
Es una revisión de código y configuración, no una auditoría independiente
ni una garantía de ausencia de vulnerabilidades.

Cambios en 1.3.1 beta:

- Se corrige la creación de la carpeta de datos por el diagnóstico antes de
  aplicar permisos privados; también se corrigen permisos preexistentes.
- La carga rechaza rutas simbólicas/no regulares y archivos mayores de 64 MiB,
  y conserva como máximo 100 elementos, 12 MiB por elemento y 32 MiB de datos.
- Escritura atómica dentro de una carpeta privada y permisos 0600.
- Hardened runtime en la beta, sin excepciones de entitlements.
- Scripts y estilos web externos al HTML; CSP sin unsafe-inline, conexiones,
  objetos, formularios ni base URL externos. Política no-referrer.
- Actions fijadas a SHA y checkout sin credenciales persistentes. Dependabot
  semanal y alertas/correcciones de seguridad activadas.

Las pruebas de regresión usan exclusivamente datos sintéticos y carpetas
 temporales: permisos, enlaces simbólicos, reemplazo atómico, historial
sobredimensionado/corrupto y límites de elementos, además de las pruebas
funcionales. CI verifica el DMG en macOS 14 ARM, 15 Intel y 26 ARM.

Prioridades abiertas: cifrado del historial con gestión de claves y migración
segura; firma Developer ID/notarización; validación manual de permisos y pegado
con hardened runtime en un Mac limpio. Borrar el historial no garantiza el
borrado físico de SSD, snapshots ni backups.
