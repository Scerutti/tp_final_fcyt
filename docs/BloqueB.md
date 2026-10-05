# Bloque B: pruebas y defensa

## Ejecutar las pruebas

Desde la carpeta del proyecto, con Free Pascal disponible:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/PruebaBloqueB.ps1
```

El script ejecuta 16 casos con archivos propios en una carpeta temporal; no modifica `docs/*.dat`. Verifica altas rechazadas, niveles inválidos, modificación, baja lógica, consultas ordenadas, empate de promedios, resultados vacíos, claves inexistentes y referencias inactivas.

La unit y el programa de pruebas compilaron con Free Pascal 3.2.2 y controles de rango, desbordamiento y entrada/salida. Windows bloqueó la ejecución mediante Control de aplicaciones. Los casos siguen pendientes de ejecución; compilar no demuestra que pasen. `ExecutionPolicy Bypass` solo afecta al script PowerShell.

## Datos de prueba

Los estudiantes cursan LSI, ingresaron en 2026 y tienen 20% de avance. Todos los registros iniciales están activos.

| Legajo | DNI | Nombre y apellido | Promedio |
|---|---|---|---|
| E1 | 40000001 | Zoe Perez | 8 |
| E2 | 40000002 | Ana Torres | 8 |
| E3 | 40000003 | Luis Gomez | 9 |
| E4 | 40000004 | Bruno Diaz | 7 |
| E5 | 40000005 | Eva Ruiz | 6 |

| Código | Habilidad | Categoría |
|---|---|---|
| H1 | Programacion | Tecnica |
| H2 | Analisis | Tecnica |
| H3 | Analisis | Tecnica |
| H4 | Redes | Tecnica |
| H5 | Diseno | Tecnica |

| Legajo | Habilidad | Nivel |
|---|---|---|
| E1 | H1 | 4 |
| E1 | H2 | 5 |
| E1 | H3 | 2 |
| E1 | H4 | 3 |
| E2 | H1 | 4 |
| E2 | H2 | 2 |
| E3 | H1 | 5 |
| E3 | H4 | 4 |
| E4 | H1 | 2 |
| E4 | H5 | 3 |

Consulta 1 para E1 debe mostrar H3, H2, H1 y H4: nombre de habilidad ascendente y nivel ascendente cuando el nombre coincide. Consulta 2 para H1 con mínimo 2 debe mostrar Luis Gomez, Ana Torres, Zoe Perez y Bruno Diaz: promedio descendente y nombre completo ascendente en los empates. E5 no tiene competencias; H5 con mínimo 5 no devuelve candidatos.

## Error corregido

Ingresar texto como nivel en alta, modificación o Consulta 2 terminaba el programa por error de lectura numérica. `LeerNivel` ahora lee una cadena, la convierte con `Val` y vuelve a pedirla si no representa un entero entre 1 y 5. También rechaza entradas vacías y números demasiado grandes.

## Guía para la defensa

- **Alta:** validar estudiante activo, habilidad activa y ausencia de un par activo repetido. Agregar al final con `Seek(archC, FileSize(archC))`.
- **Búsqueda secuencial:** recorrer desde `Seek(archC, 0)` hasta encontrar el par activo o llegar al final. `Read` avanza la posición, por eso se devuelve `FilePos(archC) - 1`; -1 significa que no se encontró.
- **Modificación y baja:** buscar la posición, cambiar el nivel o `activa`, regresar con `Seek` y sobrescribir. Las claves se conservan; una baja lógica no reduce el tamaño del archivo.
- **Vectores:** cargar las relaciones activas que cumplen el filtro. Consulta 1 filtra por legajo; Consulta 2 por habilidad y nivel mínimo. Se omiten estudiantes o habilidades inactivos.
- **Burbuja:** comparar vecinos e intercambiar el registro completo. Cada pasada reduce el tramo pendiente mediante `n - i`; el costo de ordenamiento es cuadrático.
- **Criterios:** Consulta 1 ordena nombre y nivel ascendentes; Consulta 2 promedio descendente y `nombreApellido` ascendente. La comparación de cadenas es sensible a mayúsculas y no separa nombre de apellido.
- **Límite actual:** cada vector admite 1000 resultados. Dar de baja un estudiante o habilidad no modifica sus competencias, aunque las consultas omiten esas relaciones inactivas.
