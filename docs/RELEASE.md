**[Descarga Porta-1.4-universal-beta.dmg](https://github.com/martinzg16/porta/releases/download/v1.4-beta.1/Porta-1.4-universal-beta.dmg)** · [Guía visual](https://martinzg16.github.io/porta/#instalar)

Mac Intel o Apple Silicon, macOS 14 o posterior. Abre el DMG y arrastra Porta a Aplicaciones. Sal de la versión anterior antes de reemplazarla.

### Historial cifrado

- AES-256-GCM para todo el historial, incluidos títulos, categorías, texto y representaciones de imágenes y archivos. Cada guardado utiliza un nonce nuevo.
- Clave aleatoria de 256 bits en el Llavero de macOS, sin servidor ni contraseña propia de Porta.
- Migración automática: cifra, vuelve a leer, autentica y compara antes de retirar el archivo antiguo.
- Si falta la clave, se deniega el Llavero o el archivo no se puede descifrar, detiene la captura y no guarda datos en claro ni sobrescribe el archivo con un historial vacío.
- Si hay dos instancias de la nueva versión, solo una puede abrir el historial.

**macOS puede pedir permiso para acceder a la clave del Llavero**, especialmente al cambiar de versión de esta beta con firma local. Desbloquea el Llavero y utiliza «Reintentar historial cifrado» en el menú. Si no se resuelve, conserva los archivos y el Llavero; no borres ni reemplaces la clave. No hay recuperación sin la clave. No se garantiza traslado del historial a otro Mac. Evita volver a versiones anteriores: pueden volver a guardar datos sin cifrar.

El cifrado protege el archivo en reposo, no los datos en memoria ni el portapapeles activo. No elimina las copias antiguas de backups o snapshots y no convierte Porta en un gestor de contraseñas.

**Beta sin notarizar por Apple.** Tras intentar abrirla, si confías en la descarga oficial, puede ser necesario usar Ajustes del Sistema → Privacidad y seguridad → Abrir igualmente. No desactives las protecciones del Mac. Accesibilidad sigue siendo opcional para pegar automáticamente.

Pruebas: cifrado/descifrado, nonce único por guardado, manipulación, clave incorrecta o perdida, migración interrumpida, conflictos con un historial antiguo, fallo de escritura, exclusión de instancias y clave temporal del Llavero recuperada desde otro proceso. No se usan historiales ni credenciales personales. La autorización tras actualizar una firma ad hoc y el pegado entre aplicaciones requieren además validación manual en cada entorno.
