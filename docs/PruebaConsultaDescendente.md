# Prueba paso a paso: orden descendente y datos de ejemplo

1. Abrí PowerShell en la carpeta del proyecto y cerrá el programa si está abierto. Usá la rama `codex/consulta-descendente-datos`.
2. Cargá los datos de ejemplo:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/PopularDatos.ps1
   ```

   Se crean `docs/estudiantes.dat`, `docs/habilidades.dat` y `docs/competencias.dat` con 5 estudiantes, 5 habilidades y 10 competencias. Si ya hay archivos, el script se detiene. Para sustituirlos explícitamente, usá:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/PopularDatos.ps1 -Reemplazar
   ```

   Antes de sustituirlos, guarda una copia en `docs/respaldo-<identificador>`. Para restaurarla, cerrá el programa y copiá los archivos de ese respaldo a `docs`. No subas los archivos de datos ni los respaldos a GitHub.
3. Compilá y abrí el programa desde la carpeta del proyecto:

   ```powershell
   fpc -B main.pas
   .\main.exe
   ```

4. Presioná Enter en la presentación. En **Estudiantes**, opción **5**, verificá que figuran E1 a E5. Volvé con **0**. En **Habilidades**, opción **5**, verificá H1 a H5. En **Competencias**, opción **5**, verificá las 10 relaciones. El juego completo está documentado en [BloqueB.md](BloqueB.md).
5. En el menú principal, seleccioná **4** e ingresá **E1**. El resultado debe ser exactamente:

   | Orden | Habilidad | Código | Nivel |
   |---|---|---|---|
   | 1 | Redes | H4 | 3 |
   | 2 | Programacion | H1 | 4 |
   | 3 | Analisis | H2 | 5 |
   | 4 | Analisis | H3 | 2 |

   El nombre se ordena de Z a A y, cuando coincide, el nivel de 5 a 1. El nivel no es el criterio principal: Redes aparece antes aunque tenga nivel 3.
6. Repetí la consulta **4** con **E5**: debe informar que no tiene habilidades. Con **E99**: debe informar que no existe el estudiante.
7. En el menú principal, seleccioná **5**, código **H1** y mínimo **2**. Deben aparecer Luis Gomez, Ana Torres, Zoe Perez y Bruno Diaz, en ese orden. Esta consulta conserva promedio descendente y nombre ascendente en empates. Con mínimo **5**, solo debe aparecer Luis Gomez.
8. Probá los niveles **0**, **6** y **texto** en Consulta 2: debe volver a pedirlos. Después ingresá **2** para terminar la consulta. Probá **H99** para código inexistente y **H5**, mínimo **5**, para resultados vacíos.
9. Ejecutá la suite automática:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File tests/PruebaBloqueB.ps1
   ```

   Debe finalizar con `Las 16 pruebas del bloque B pasaron.` Estas pruebas usan datos temporales independientes y no alteran los ejemplos de `docs`.

Si Windows informa que Control de aplicaciones bloqueó el ejecutable, la compilación pudo haber terminado correctamente pero la prueba no se ejecutó. `ExecutionPolicy Bypass` no autoriza ejecutables. Ejecutá en un entorno que permita los programas compilados o solicitá autorización al administrador del equipo.
