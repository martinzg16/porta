# Decisiones de producto y técnicas

## 1. Recuperar contenido antes de volver a buscarlo

La primera necesidad fue un historial accesible al pegar. Porta captura representaciones públicas del portapapeles, conserva un número acotado de elementos y permite buscar por texto o tipo. No intenta recuperar copias anteriores a su ejecución.

## 2. Dejar libre Command + V

El selector inicial interceptaba Command + V. En el uso con Wispr, esto interfería con la inserción del dictado. La solución fue dar al historial su propio atajo, Command + Option + V, y dejar el pegado normal en manos de la aplicación de destino.

El atajo elegido tiene una contrapartida conocida: coincide con mover archivos copiados en Finder. Pausar o cerrar Porta libera la combinación. Personalizarla queda pendiente.

## 3. Separar apertura y pegado

La captura original con `CGEvent.tapCreate` dependía de Accesibilidad. Tras una actualización, la app seguía abierta pero el atajo no se registraba.

La implementación actual usa `RegisterEventHotKey` para abrir el selector. Accesibilidad se solicita para simular Command + V al pegar en otra app. Esto permite consultar el historial aunque falte ese permiso.

## 4. Categorías locales y corregibles

Se añaden Datos personales, Trabajo y Otros. Las expresiones regulares detectan patrones y palabras; no hacen una interpretación semántica del contenido. Es una primera versión sencilla, transparente y sin servicios externos.

`categoryOverride` es opcional: los historiales anteriores se pueden decodificar sin migración destructiva. Sin una corrección, la categoría se calcula a partir del texto. Si el usuario la cambia, se guarda y se conserva al volver a capturar un elemento con el mismo identificador.

Los identificadores se calculan con SHA-256 sobre las representaciones del contenido. Si dos copias tienen distinto formato, pueden tener identificadores diferentes aunque su texto visible coincida.

## 5. Un proyecto pequeño, con límites explícitos

Un único archivo Swift facilita recorrer el flujo completo. Si el proyecto crece, separar almacenamiento, clasificación y presentación será un paso natural. Por ahora no hay sincronización, telemetría, cuentas, dependencias externas ni modelo de IA.

La persistencia local no equivale a almacenamiento seguro de secretos: el JSON no está cifrado. Los límites de tamaño y las marcas de exclusión reducen el alcance, pero no convierten Porta en un gestor de contraseñas.
