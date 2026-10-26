# Privacidad y almacenamiento

Porta no implementa red, analítica ni sincronización. Clasifica localmente.

## Historial cifrado (desde 1.4)

`~/Library/Application Support/Porta/history.porta` contiene un encabezado de
versión no secreto, seguido del nonce, ciphertext y tag de AES-256-GCM. Todo
el JSON del historial está cifrado: textos, imágenes, referencias a archivos,
metadatos, títulos y categorías. Cada guardado usa un nonce aleatorio nuevo.

La clave aleatoria de 256 bits se guarda como contraseña genérica en el Llavero
login de macOS, servicio `local.martin.porta.history-key.v1`, cuenta `aes256`.
No se guarda en archivos de Porta, no se envía a un servidor y no se configura
sincronización iCloud. Se respetan los controles de acceso por aplicación del
Llavero; no se concede acceso a todas las aplicaciones. No se usa el Llavero
Data Protection, que requiere una configuración de firma diferente: no se
promete protección ThisDeviceOnly ni revocación al bloquear la pantalla.

La clave y el historial descifrado permanecen en memoria mientras Porta está
abierta. El cifrado protege el archivo almacenado, no un proceso comprometido,
la sesión desbloqueada, el portapapeles del sistema ni datos pegados en otra app.

## Migración y fallos

El antiguo `history.json` se cifra, se sincroniza a disco, se vuelve a leer,
se autentica y se compara antes de eliminar el archivo antiguo. Un fallo
conserva los datos existentes y detiene la captura. Si una interrupción deja
ambos archivos, solo se retira el antiguo si el contenido completo coincide;
si divergen, Porta se bloquea sin fusionarlos ni descartarlos.

No se genera otra clave si ya existe `history.porta` y falta su clave. Tampoco
se hace fallback a texto claro. Tras desbloquear/autorizar el Llavero, usa
«Reintentar historial cifrado». Si el archivo está dañado o la clave se ha
perdido, conserva archivos y Llavero; no existe recuperación sin la clave.

No vuelvas a una versión antigua: podría crear otro historial sin cifrar.
Eliminar el archivo original no borra snapshots, backups ni sectores de SSD.
No se garantiza recuperar el historial trasladando solo el archivo a otro Mac.

## Otros datos y permisos

La carpeta tiene permisos 0700 y los archivos 0600. `history.lock` coordina
instancias; `status.json` contiene PID, estado del atajo, pausa y Accesibilidad,
sin contenido copiado. Estos permisos no bloquean a procesos con tu usuario.
La firma ad hoc puede requerir una nueva autorización del Llavero tras actualizar.

Accesibilidad es opcional para pegar automáticamente. El historial admite
100 elementos, 32 MiB de datos y 12 MiB por captura. Excluye las marcas de
contenido secreto/transitorio que suministra la app de origen, pero no todas
las aplicaciones las utilizan: Porta no es un gestor de contraseñas.
Borrar el historial guarda una lista vacía cifrada; no borra la clave, el
portapapeles activo ni las copias de seguridad. No garantiza borrado físico.
