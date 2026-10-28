import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
DESTINO = RAIZ / "docs"
FUENTE = RAIZ / "scripts" / "PopularDatos.pas"
ARCHIVOS = ["estudiantes.dat", "habilidades.dat", "competencias.dat"]


def compilar(fpc, temporal):
    resultado = subprocess.run(
        [fpc, "-B", "-Cr", "-Co", "-Ci", f"-Fu{RAIZ}", f"-FU{temporal}", f"-FE{temporal}", str(FUENTE)],
        capture_output=True,
        text=True,
    )
    if resultado.returncode != 0:
        print(resultado.stdout)
        print(resultado.stderr)
        sys.exit("Fallo la compilacion del cargador.")
    nombre = "PopularDatos.exe" if os.name == "nt" else "PopularDatos"
    return Path(temporal) / nombre


def respaldar(existentes):
    respaldo = DESTINO / ("respaldo-" + datetime.now().strftime("%Y%m%d-%H%M%S"))
    respaldo.mkdir()
    for nombre in existentes:
        shutil.copy2(DESTINO / nombre, respaldo / nombre)
    print(f"Respaldo guardado en: {respaldo}", flush=True)


def main():
    parser = argparse.ArgumentParser(description="Carga 5 estudiantes, 5 habilidades y 10 competencias de ejemplo en docs.")
    parser.add_argument("--reemplazar", action="store_true",
                        help="respalda los datos existentes y los sustituye por los ejemplos")
    argumentos = parser.parse_args()

    fpc = shutil.which("fpc")
    if fpc is None:
        sys.exit("No se encontro fpc. Instale Free Pascal 3.2.2 y agreguelo al PATH.")

    DESTINO.mkdir(exist_ok=True)
    existentes = [nombre for nombre in ARCHIVOS if (DESTINO / nombre).exists()]
    if existentes and not argumentos.reemplazar:
        sys.exit("Ya existen datos en docs. Para respaldarlos y sustituirlos por los ejemplos, "
                 "ejecutar con --reemplazar. Cerrar el programa antes de continuar.")

    with tempfile.TemporaryDirectory(prefix="popular-datos-") as temporal:
        cargador = compilar(fpc, temporal)
        if existentes:
            respaldar(existentes)
        comando = [str(cargador), str(DESTINO)]
        if argumentos.reemplazar:
            comando.append("--reemplazar")
        try:
            resultado = subprocess.run(comando)
        except OSError as error:
            sys.exit(f"No se pudo ejecutar el cargador ({error}). Los datos existentes se conservan.")
        if resultado.returncode != 0:
            sys.exit("Fallo la carga de datos.")


if __name__ == "__main__":
    main()
