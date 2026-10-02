# UADERTalents - Base de Talentos

Trabajo Práctico Final de Fundamentos de Programación 2026 (UADER - FCyT).

Autores: Cerutti, Sebastián · Martinez, Facundo

## Estado actual

Ya están implementados todos los puntos del enunciado:

| Archivo | Contenido |
|---|---|
| `TiposGlobales.pas` | Registros y tipos de archivo |
| `UnitEstudiantes.pas` | Apertura, carga, ABM y listado de estudiantes |
| `UnitHabilidades.pas` | Apertura, carga, ABM y listado de habilidades |
| `UnitCompetencias.pas` | Apertura, carga, ABM y listado de competencias, Consulta 1 y Consulta 2 |
| `UnitPresentacion.pas` | Logo, menús, encabezados y pie de pantalla |
| `main.pas` | Programa principal con los menús |

Lo que falta es probar todo, cerrar algunas decisiones y preparar la defensa.

## Antes de empezar

### 1. Validar la ruta de los archivos

Para que el programa funcione, validá que la ruta de la carpeta `docs` sea la correcta en tu PC. Está definida en estas tres constantes:

- `RUTA_ESTUDIANTES` en `UnitEstudiantes.pas`
- `RUTA_HABILIDADES` en `UnitHabilidades.pas`
- `RUTA_COMPETENCIAS` en `UnitCompetencias.pas`

La carpeta `docs` tiene que existir.

### 2. Compilar

```bash
fpc main.pas
```

## Puntos que se pueden hacer por separado

Cada uno trabaja con sus propios `.dat`, así que no hace falta coordinarse para probar. Para evitar conflictos en git, cada uno toca solo los archivos de su bloque.

### Bloque A: Estudiantes, Habilidades y menús

Archivos: `UnitEstudiantes.pas`, `UnitHabilidades.pas`, `UnitPresentacion.pas`, `main.pas`

- [ ] Probar el alta de estudiantes con legajo repetido y con DNI repetido. Las dos tienen que rechazarse.
- [ ] Probar la modificación de un estudiante poniéndole el DNI de otro. Tiene que rechazarse.
- [ ] Probar la baja de un estudiante y verificar que no aparece más en el listado.
- [ ] Probar el alta de habilidades con código repetido. Tiene que rechazarse.
- [ ] Probar la modificación y la baja de habilidades.
- [ ] Probar los menús: todas las opciones, opción inválida, volver y salir.
- [ ] Verificar que la pantalla se ve bien en la consola (bordes alineados, colores, pie).
- [ ] Estudiar a fondo estas units para la defensa: búsqueda secuencial, `Seek`, `FilePos`, baja lógica con `activo`.

### Bloque B: Competencias y Consultas

Archivo: `UnitCompetencias.pas`

Para probar hacen falta estudiantes y habilidades cargados. Usá los menús de Estudiantes y Habilidades para cargar algunos.

- [ ] Probar el alta de competencias con legajo inexistente, código inexistente y par legajo-habilidad repetido. Las tres tienen que rechazarse.
- [ ] Probar el nivel de dominio fuera de rango (0, 6). Tiene que volver a pedirlo.
- [ ] Probar la modificación y la baja de competencias.
- [ ] Probar la Consulta 1 con un estudiante que tenga varias habilidades. Verificar el orden por habilidad y nivel.
- [ ] Probar la Consulta 2 con varios estudiantes, incluyendo dos con el mismo promedio. Verificar que el empate se ordena por nombre y apellido.
- [ ] Probar las dos consultas con legajos y códigos que no existen, y con resultados vacíos.
- [ ] Estudiar a fondo esta unit para la defensa: validaciones del alta, carga en vector y ordenamiento burbuja.

### Cualquiera de los dos

- [ ] Armar un juego de datos de prueba (por ejemplo 5 estudiantes, 5 habilidades y 10 competencias) y anotarlo, para usarlo en la prueba completa y en la defensa.
- [ ] Anotar cualquier error encontrado, con los pasos para reproducirlo.

## Puntos a hacer juntos

- [ ] **Ruta de los archivos:** decidir si se usa una ruta relativa (por ejemplo `docs\estudiantes.dat`), que funciona en cualquier PC si el programa se ejecuta desde la carpeta del proyecto.
- [ ] **Confirmar o cambiar estas decisiones**, que el enunciado no aclara:
  - La baja es lógica: el registro queda en el archivo con `activo := False`.
  - Dar de baja un estudiante o una habilidad no da de baja sus competencias.
  - La Consulta 1 ordena por nombre de habilidad y después por nivel, de menor a mayor.
  - La Consulta 2 ordena por promedio de mayor a menor, y ante empate por nombre y apellido alfabético.
  - En la modificación no se puede cambiar el legajo ni el código de habilidad, porque son las claves.
  - Si se escribe una letra donde va un número (año, promedio, porcentaje, nivel), el programa se corta con error.
- [ ] **Decidir si se suben los `.dat` a git** o se agregan al `.gitignore`.
- [ ] **Corregir los errores** que haya encontrado cada uno.
- [ ] **Prueba completa** en una sola PC, con el juego de datos de prueba, recorriendo todos los puntos del enunciado.
- [ ] **Preparar la defensa:** cada uno le explica su bloque al otro. La defensa es teórica y práctica, así que los dos tienen que poder explicar todo el código.
- [ ] **Revisión previa a la defensa:** enviar el trabajo al corrector del turno que corresponda (los mails están en el enunciado).
