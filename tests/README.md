# Pruebas automáticas

Suite estilo Jest para las tres units. Corre todos los casos, cuenta los que pasan y los que fallan, y nunca se corta en el primero que falla.

```powershell
.\tests\run-tests.ps1
```

Sale con código 0 si pasan todas, y 1 si alguna falla.

## Cómo funciona

- `PruebaBloqueA.pas` y `PruebaBloqueB.pas` son programas de prueba. Cada uno crea sus propios `.dat` con datos fijos y después ejecuta una acción que se le pasa por parámetro.
- Los procedimientos del programa piden datos con `readln`, así que el runner les manda las respuestas por la entrada estándar.
- `run-tests.ps1` compila los dos programas, corre cada caso en una carpeta temporal propia y compara la salida.
- Cada caso puede verificar: texto que tiene que aparecer, texto que no tiene que aparecer, y el orden en que aparecen varios textos (para las dos consultas).
- Si un caso corta la ejecución, el runner lo anota como fallo con el motivo y sigue con el siguiente.

## Estado actual

40 pasan, 4 fallan.

Las 4 que fallan son limitaciones conocidas, no errores nuevos:

| Caso | Motivo |
|---|---|
| Apertura sin la carpeta `docs` | `EInOutError: Invalid filename`. Las rutas son relativas, así que la carpeta tiene que existir y hay que ejecutar desde la carpeta del proyecto. |
| Año con letras | `EInOutError: Invalid input`. `readln` sobre un número se corta con texto. |
| Promedio con coma (`8,5`) | Igual. Hay que usar punto. |
| Promedio vacío (ENTER) | Igual. |

Para que dejen de fallar hay que leer esos campos como texto y convertirlos con `Val`, volviendo a pedir el dato si no es válido, como ya hace `LeerNivel` en `UnitCompetencias`.

`PruebaBloqueB.ps1` es el runner anterior, solo del bloque B. Sigue acá, pero `run-tests.ps1` ya cubre esos mismos casos.
