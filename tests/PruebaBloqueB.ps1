$ErrorActionPreference = 'Stop'
$raiz = Split-Path $PSScriptRoot -Parent
$temporal = Join-Path ([IO.Path]::GetTempPath()) ('bloque-b-' + [guid]::NewGuid())
New-Item -ItemType Directory $temporal | Out-Null
try {
    & fpc '-B' '-Cr' '-Co' '-Ci' "-Fu$raiz" "-FU$temporal" "-FE$temporal" (Join-Path $PSScriptRoot 'PruebaBloqueB.pas')
    if ($LASTEXITCODE -ne 0) { throw 'Fallo la compilacion.' }
    Push-Location $temporal
    try {
        function Probar($nombre, $accion, $entrada, $esperados, $ausentes = @()) {
            try {
                $salida = ($entrada | & (Join-Path $temporal 'PruebaBloqueB.exe') $accion) -join "`n"
            } catch {
                if ($_.Exception.Message -match 'Application Control|0x11C7|4551') {
                    throw 'Compilacion correcta, pero Windows bloqueo el ejecutable mediante Control de aplicaciones. No se ejecutaron las pruebas. ExecutionPolicy Bypass solo afecta scripts de PowerShell; no autoriza este .exe. Revisar Seguridad de Windows > Control de aplicaciones y navegador, y los eventos CodeIntegrity > Operational. En equipos administrados, solicitar autorizacion al administrador o ejecutar la suite en un entorno de desarrollo autorizado.'
                }
                throw
            }
            if ($LASTEXITCODE -ne 0) { throw "$nombre fallo: $salida" }
            foreach ($texto in $esperados) {
                if (-not $salida.Contains($texto)) { throw "$nombre no contiene: $texto`n$salida" }
            }
            foreach ($texto in $ausentes) {
                if ($salida.Contains($texto)) { throw "$nombre contiene: $texto`n$salida" }
            }
            Write-Host "OK: $nombre"
            return $salida
        }
        $null = Probar 'Legajo inexistente' 'alta-rechazada' "E99" @('No existe un estudiante', 'VERIFICADO')
        $null = Probar 'Codigo inexistente' 'alta-rechazada' "E1`nH99" @('No existe una habilidad', 'VERIFICADO')
        $null = Probar 'Par repetido' 'alta-rechazada' "E1`nH1" @('ya tiene registrada', 'VERIFICADO')
        $null = Probar 'Alta y niveles invalidos' 'alta' "E5`nH1`n0`n6`ntexto`n`n9999999999999`n3" @('VERIFICADO', 'El nivel debe estar entre 1 y 5.')
        $null = Probar 'Modificar y validar nivel' 'modificar' "E1`nH1`n0`n6`n1" @('Competencia modificada.', 'VERIFICADO')
        $null = Probar 'Modificar inexistente' 'modificar-inexistente' "E99`nH1" @('No existe esa competencia.')
        $null = Probar 'Baja inexistente' 'baja-inexistente' "E99`nH1" @('No existe esa competencia.')
        $null = Probar 'Baja logica y consulta' 'baja' "E1`nH1`nE1" @('Competencia dada de baja.', 'VERIFICADO') @('Programacion (H1')
        $salida = Probar 'Consulta 1' 'legajo' 'E1' @('Analisis (H3', 'Analisis (H2', 'Programacion (H1', 'Redes (H4')
        $anterior = -1
        foreach ($texto in @('Analisis (H3', 'Analisis (H2', 'Programacion (H1', 'Redes (H4')) {
            $indice = $salida.IndexOf($texto)
            if ($indice -le $anterior) { throw 'Orden incorrecto de Consulta 1.' }
            $anterior = $indice
        }
        $salida = Probar 'Consulta 2 y empate' 'habilidad' "H1`n0`n6`n2" @('Luis Gomez', 'Ana Torres', 'Zoe Perez', 'Bruno Diaz')
        $anterior = -1
        foreach ($texto in @('Luis Gomez', 'Ana Torres', 'Zoe Perez', 'Bruno Diaz')) {
            $indice = $salida.IndexOf($texto)
            if ($indice -le $anterior) { throw 'Orden incorrecto de Consulta 2.' }
            $anterior = $indice
        }
        $null = Probar 'Consulta 1 inexistente' 'legajo' 'E99' @('No existe un estudiante')
        $null = Probar 'Consulta 1 vacia' 'legajo' 'E5' @('no posee habilidades registradas')
        $null = Probar 'Consulta 2 inexistente' 'habilidad' 'H99' @('No existe una habilidad')
        $null = Probar 'Consulta 2 vacia' 'habilidad' "H5`n5" @('No hay estudiantes con esa habilidad y nivel minimo.')
        $null = Probar 'Filtro por nivel minimo' 'habilidad' "H1`n5" @('Luis Gomez') @('Ana Torres', 'Zoe Perez', 'Bruno Diaz')
        $null = Probar 'Referencias inactivas' 'inactivos' "E1`nH1`n2" @('Analisis (H3', 'Ana Torres', 'Zoe Perez') @('Analisis (H2', 'Luis Gomez')
        Write-Host 'Las 16 pruebas del bloque B pasaron.'
    } finally { Pop-Location }
} finally {
    # Se elimina unicamente el directorio temporal creado por esta ejecucion.
    if ((Split-Path $temporal -Parent) -eq ([IO.Path]::GetTempPath()).TrimEnd('\')) {
        Remove-Item -LiteralPath $temporal -Recurse -Force
    }
}
