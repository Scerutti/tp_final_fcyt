param([switch]$Reemplazar)
$ErrorActionPreference = 'Stop'
$raiz = Split-Path $PSScriptRoot -Parent
$destino = Join-Path $raiz 'docs'
$temporal = Join-Path ([IO.Path]::GetTempPath()) ('popular-datos-' + [guid]::NewGuid())
New-Item -ItemType Directory -Force $destino | Out-Null
$archivos = @('estudiantes.dat', 'habilidades.dat', 'competencias.dat')
$existentes = @($archivos | Where-Object { Test-Path -LiteralPath (Join-Path $destino $_) })
if ($existentes.Count -gt 0 -and -not $Reemplazar) {
    throw 'Ya existen datos en docs. Para crear un respaldo y sustituirlos por ejemplos, ejecutar con -Reemplazar. Cerrar el programa antes de continuar.'
}
New-Item -ItemType Directory $temporal | Out-Null
try {
    & fpc '-B' '-Cr' '-Co' '-Ci' "-Fu$raiz" "-FU$temporal" "-FE$temporal" (Join-Path $PSScriptRoot 'PopularDatos.pas')
    if ($LASTEXITCODE -ne 0) { throw 'Fallo la compilacion del cargador.' }
    if ($existentes.Count -gt 0) {
        $respaldo = Join-Path $destino ('respaldo-' + [guid]::NewGuid())
        New-Item -ItemType Directory $respaldo | Out-Null
        foreach ($nombre in $existentes) {
            Copy-Item -LiteralPath (Join-Path $destino $nombre) -Destination $respaldo
        }
        Write-Host "Respaldo guardado en: $respaldo"
    }
    $argumentos = @($destino)
    if ($Reemplazar) { $argumentos += '--reemplazar' }
    try {
        & (Join-Path $temporal 'PopularDatos.exe') @argumentos
    } catch {
        if ($_.Exception.Message -match 'Application Control|0x11C7|4551') {
            throw 'Windows bloqueo el cargador mediante Control de aplicaciones. El cargador no se ejecuto; los datos existentes se conservan.'
        }
        throw
    }
    if ($LASTEXITCODE -ne 0) { throw 'Fallo la carga de datos.' }
} finally {
    if ((Split-Path $temporal -Parent) -eq ([IO.Path]::GetTempPath()).TrimEnd('\')) {
        Remove-Item -LiteralPath $temporal -Recurse -Force
    }
}
