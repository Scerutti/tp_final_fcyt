# Pruebas automáticas

Suite estilo Jest para las tres units. Corre todos los casos, cuenta los que pasan y los que fallan, y nunca se corta en el primero que falla.

```powershell
.\tests\run-tests.ps1
```

Sale con código 0 si pasan todas, y 1 si alguna falla o si algún programa de prueba no compila.

## Cómo funciona

- `PruebaBloqueA.pas` y `PruebaBloqueB.pas` son programas de prueba. Cada uno crea sus propios `.dat` con datos fijos y después ejecuta una acción que se le pasa por parámetro.
- Los procedimientos del programa piden datos con `readln`, así que el runner les manda las respuestas por la entrada estándar.
- `run-tests.ps1` compila los dos programas, corre cada caso en una carpeta temporal propia y compara la salida.
- Cada caso puede verificar: texto que tiene que aparecer, texto que no tiene que aparecer, y el orden en que aparecen varios textos (para las dos consultas).
- Si un caso corta la ejecución, el runner lo anota como fallo con el motivo y la entrada que lo provocó, y sigue con el siguiente.
- Cada caso tiene un límite de 15 segundos. Si se pasa, el runner mata el proceso y lo anota como fallo. Esto hace falta porque los bucles que validan la entrada (`LeerNivel`, `LeerEntero`, `LeerReal`) vuelven a pedir el dato indefinidamente: si la prueba manda menos datos de los que el programa pide, el proceso quedaría girando para siempre.

## Estado actual

47 pasan, 0 fallan.

## Qué cubre

| Suite | Casos |
|---|---|
| Estudiantes | Alta con legajo y DNI repetidos, modificación con el DNI de otro, baja lógica, listados, legajo de más de 10 caracteres, reusar el legajo de una baja, carga múltiple |
| Habilidades | Alta con código repetido, modificación, baja lógica, listados, código de más de 10 caracteres |
| Apertura de archivos | Crea el `.dat` si no existe, lo reabre sin perder datos, y crea la carpeta `docs` si falta |
| Entradas inválidas | Año, promedio y porcentaje con letras, con coma, vacíos o fuera de rango: vuelve a pedir el dato en lugar de cortarse |
| Competencias | Alta con legajo o código inexistente, par repetido, nivel fuera de rango o con texto, modificación y baja |
| Consulta por legajo | Orden por habilidad y nivel, legajo inexistente, estudiante sin habilidades |
| Consulta por habilidad | Orden por promedio y nombre, filtro por nivel mínimo, sin resultados, ignora registros dados de baja |

`PruebaBloqueB.ps1` es el runner anterior, solo del bloque B. Sigue acá, pero `run-tests.ps1` ya cubre esos mismos casos.
