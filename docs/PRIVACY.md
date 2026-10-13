# Privacidad y almacenamiento

Porta no implementa conexiones de red, analítica ni sincronización. La clasificación se ejecuta dentro del proceso con reglas locales.

## Datos locales

- `~/Library/Application Support/Porta/history.json`: contenido y representaciones capturadas, fecha, tipo, identificador y corrección de categoría cuando existe. Se escribe con permisos de archivo `0600`.
- `~/Library/Application Support/Porta/status.json`: diagnóstico de arranque con PID, registro del atajo, código de error, estado de pausa y permiso de Accesibilidad. No contiene textos copiados. No es un registro continuo y puede quedar desactualizado.

El historial no está cifrado. Una copia de seguridad del Mac puede incluirlo. Borrar desde Porta elimina los elementos de su historial, no el portapapeles del sistema ni copias de seguridad externas.

## Captura y exclusiones

Solo captura mientras está abierta y no está pausada. Ignora elementos que la aplicación de origen marca como ocultos, transitorios o autogenerados, y ciertos contenidos de gestores de contraseñas. Esas marcas no son universales.

Conserva representaciones públicas de texto, imágenes y referencias a archivos. Los contenidos privados y las transferencias basadas en promesas no se soportan. Los límites son 100 elementos, 32 MiB totales y 12 MiB por captura.

## Categorías

Datos personales es un filtro organizativo, no una barrera de seguridad. Su detección puede fallar y no verifica si una identificación es real o válida. Todos los elementos tienen el mismo tratamiento de almacenamiento.

## Permisos

El atajo global abre el historial sin Accesibilidad. El pegado automático sí necesita ese permiso, porque simula una pulsación en la aplicación de destino. Antes de enviar teclas, Porta comprueba que esa aplicación esté activa y que se hayan soltado los modificadores.
