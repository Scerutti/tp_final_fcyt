$ErrorActionPreference = 'Continue'
$PSNativeCommandUseErrorActionPreference = $false

$raiz = Split-Path $PSScriptRoot -Parent
$temporal = Join-Path ([IO.Path]::GetTempPath()) ('tp-final-tests-' + [guid]::NewGuid())
New-Item -ItemType Directory $temporal | Out-Null

$script:total = 0
$script:pasaron = 0
$script:fallaron = 0
$script:fallos = @()
$script:suiteActual = ''
$limiteMs = 15000

function Suite($nombre) {
    $script:suiteActual = $nombre
    Write-Host ''
    Write-Host " $nombre " -BackgroundColor DarkBlue -ForegroundColor White
}

function Compilar($programa) {
    $fuente = Join-Path $PSScriptRoot "$programa.pas"
    $salida = & fpc '-B' '-Cr' '-Co' '-Ci' "-Fu$raiz" "-FU$temporal" "-FE$temporal" $fuente 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        Write-Host "No compila: $programa" -ForegroundColor Red
        Write-Host $salida
        return $false
    }
    return $true
}

function Probar {
    param(
        [string]$nombre,
        [string]$programa,
        [string]$accion,
        [string]$entrada = '',
        [string[]]$esperados = @(),
        [string[]]$ausentes = @(),
        [string[]]$orden = @(),
        [switch]$corteEsperado
    )

    $script:total++
    $etiqueta = "$($script:suiteActual) > $nombre"
    $exe = Join-Path $temporal "$programa.exe"
    $caso = Join-Path $temporal ('caso-' + $script:total)
    New-Item -ItemType Directory $caso | Out-Null

    $colgado = $false
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $exe
    $psi.Arguments = $accion
    $psi.WorkingDirectory = $caso
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    try {
        $proc = [System.Diagnostics.Process]::Start($psi)
        $lectorSalida = $proc.StandardOutput.ReadToEndAsync()
        $lectorError = $proc.StandardError.ReadToEndAsync()
        $proc.StandardInput.Write($entrada + "`n")
        $proc.StandardInput.Close()
        if ($proc.WaitForExit($limiteMs)) {
            $codigo = $proc.ExitCode
        } else {
            $colgado = $true
            $codigo = -1
            $proc.Kill($true)
            $proc.WaitForExit(5000) | Out-Null
        }
        $salida = $lectorSalida.Result + $lectorError.Result
        $proc.Dispose()
    } catch {
        $salida = $_.Exception.Message
        $codigo = -1
    }

    $motivos = @()
    if ($colgado) {
        $motivos += "La prueba se colgo mas de $([int]($limiteMs / 1000)) segundos: el programa sigue pidiendo datos y la entrada se agoto"
    }
    $corte = ''
    if ($salida -match 'Runtime error (\d+)') { $corte = "runtime error $($Matches[1])" }
    elseif ($salida -match '(E[A-Za-z]+Error): *([^\r\n]*)') { $corte = ($Matches[1] + ': ' + $Matches[2]).Trim() }
    elseif ($codigo -eq 1) { $corte = 'una comprobacion dio falso' }
    elseif ($codigo -ne 0) { $corte = "codigo de salida $codigo" }

    $explicacion = ''
    if ($corte -match 'Invalid input') { $explicacion = 'se esperaba un numero y llego texto, vacio o coma decimal' }
    elseif ($corte -match 'Invalid filename') { $explicacion = 'no existe la carpeta donde va el archivo .dat' }
    elseif ($corte -match 'File not (open|found)') { $explicacion = 'el archivo no estaba abierto' }
    elseif ($corte -eq 'una comprobacion dio falso') { $explicacion = 'el archivo no quedo como esperaba la prueba' }
    if ($explicacion -ne '') { $explicacion = " ($explicacion)" }

    if ($colgado) { }
    elseif ($corteEsperado) {
        if ($corte -eq '') { $motivos += 'Se esperaba que la ejecucion se cortara y no se corto' }
    }
    elseif ($corte -ne '') {
        $motivos += "La ejecucion se corto: $corte$explicacion"
        if ($entrada -ne '') { $motivos += "Entrada tipeada: " + ($entrada -replace "`n", ' / ') }
    }

    foreach ($t in $esperados) {
        if (-not $salida.Contains($t)) { $motivos += "Falta en la salida: '$t'" }
    }
    foreach ($t in $ausentes) {
        if ($salida.Contains($t)) { $motivos += "No deberia aparecer: '$t'" }
    }
    $previo = -1
    foreach ($t in $orden) {
        $indice = $salida.IndexOf($t)
        if ($indice -lt 0) { $motivos += "Falta en la salida: '$t'"; break }
        if ($indice -le $previo) { $motivos += "Orden incorrecto en: '$t'"; break }
        $previo = $indice
    }

    if ($motivos.Count -eq 0) {
        $script:pasaron++
        Write-Host '  PASS ' -ForegroundColor Green -NoNewline
        Write-Host " $etiqueta"
    } else {
        $script:fallaron++
        $script:fallos += [pscustomobject]@{ Nombre = $etiqueta; Motivos = $motivos; Salida = $salida }
        Write-Host '  FAIL ' -ForegroundColor Red -NoNewline
        Write-Host " $etiqueta"
        foreach ($m in $motivos) { Write-Host "        $m" -ForegroundColor DarkYellow }
    }
}

try {
    $compilaA = Compilar 'PruebaBloqueA'
    $compilaB = Compilar 'PruebaBloqueB'

    if ($compilaA) {
        Suite 'Estudiantes'
        Probar 'alta valida' 'PruebaBloqueA' 'est-alta' "1004`n33444555`nDiego Sosa`nSistemas`n2024`n6.5`n30" @('Estudiante registrado.', 'VERIFICADO')
        Probar 'alta con legajo repetido' 'PruebaBloqueA' 'est-alta-legajo-dup' "1001" @('Ya existe un estudiante con ese legajo.') @('DNI:')
        Probar 'alta con DNI repetido' 'PruebaBloqueA' 'est-alta-dni-dup' "1004`n30111222" @('Ya existe un estudiante con ese DNI.')
        Probar 'modificar con el DNI de otro' 'PruebaBloqueA' 'est-modificar-dni-ajeno' "1002`n30111222" @('Ya existe otro estudiante con ese DNI.', 'VERIFICADO')
        Probar 'modificar conservando su DNI' 'PruebaBloqueA' 'est-modificar' "1002`n31222333`nBruno Diaz`nIngenieria`n2023`n7.5`n45" @('Estudiante modificado.', 'VERIFICADO')
        Probar 'modificar legajo inexistente' 'PruebaBloqueA' 'est-modificar-inexistente' "9999" @('No existe un estudiante con ese legajo.')
        Probar 'baja logica' 'PruebaBloqueA' 'est-baja' "1003" @('Estudiante dado de baja.', 'VERIFICADO', 'Ana Perez') @('Carla Luna')
        Probar 'baja de legajo inexistente' 'PruebaBloqueA' 'est-baja-inexistente' "9999" @('No existe un estudiante con ese legajo.')
        Probar 'listado general' 'PruebaBloqueA' 'est-listar' '' @('Ana Perez', 'Bruno Diaz', 'Carla Luna')
        Probar 'listado sin registros' 'PruebaBloqueA' 'est-listar-vacio' '' @('No hay estudiantes registrados.')
        Probar 'legajo de mas de 10 caracteres' 'PruebaBloqueA' 'est-clave-larga' "1234567890AB`n34555666`nElsa Vera`nSistemas`n2025`n8`n20`n1234567890AB" @('Estudiante registrado.', 'Estudiante dado de baja.', 'VERIFICADO')
        Probar 'reusar el legajo de una baja' 'PruebaBloqueA' 'est-reusar-legajo' "1003`n1003`n35666777`nFabio Sol`nSistemas`n2026`n7`n10" @('Estudiante dado de baja.', 'Estudiante registrado.', 'VERIFICADO')
        Probar 'carga de varios estudiantes' 'PruebaBloqueA' 'est-cargar' "1004`n33444555`nDiego Sosa`nSistemas`n2024`n6.5`n30`nS`n1005`n34555666`nElsa Vera`nSistemas`n2025`n8`n20`nN" @('VERIFICADO')

        Suite 'Habilidades'
        Probar 'alta valida' 'PruebaBloqueA' 'hab-alta' "REDE01`nRedes`nTecnica" @('Habilidad registrada.', 'VERIFICADO')
        Probar 'alta con codigo repetido' 'PruebaBloqueA' 'hab-alta-dup' "PROG01" @('Ya existe una habilidad con ese codigo.') @('Nombre:')
        Probar 'modificar nombre y categoria' 'PruebaBloqueA' 'hab-modificar' "COMU01`nOratoria`nBlanda" @('Habilidad modificada.', 'VERIFICADO')
        Probar 'modificar codigo inexistente' 'PruebaBloqueA' 'hab-modificar-inexistente' "XXXX" @('No existe una habilidad con ese codigo.')
        Probar 'baja logica' 'PruebaBloqueA' 'hab-baja' "INGL01" @('Habilidad dada de baja.', 'VERIFICADO', 'Programacion') @('Ingles')
        Probar 'baja de codigo inexistente' 'PruebaBloqueA' 'hab-baja-inexistente' "XXXX" @('No existe una habilidad con ese codigo.')
        Probar 'listado general' 'PruebaBloqueA' 'hab-listar' '' @('Programacion', 'Comunicacion', 'Ingles')
        Probar 'listado sin registros' 'PruebaBloqueA' 'hab-listar-vacio' '' @('No hay habilidades registradas.')
        Probar 'codigo de mas de 10 caracteres' 'PruebaBloqueA' 'hab-clave-larga' "REDES12345XY`nRedes`nTecnica`nREDES12345XY" @('Habilidad registrada.', 'Habilidad dada de baja.', 'VERIFICADO')

        Suite 'Apertura de archivos'
        Probar 'crea el archivo y lo reabre' 'PruebaBloqueA' 'est-abrir' '' @('VERIFICADO')
        Probar 'crea la carpeta docs si falta' 'PruebaBloqueA' 'est-abrir-sin-docs' '' @('VERIFICADO')

        Suite 'Entradas invalidas'
        Probar 'anio con letras vuelve a pedirlo' 'PruebaBloqueA' 'est-alta' "1004`n33444555`nDiego Sosa`nSistemas`nabc`n2024`n6.5`n30" @('Ingrese un numero entero entre 1900 y 2100.', 'Estudiante registrado.', 'VERIFICADO')
        Probar 'anio fuera de rango vuelve a pedirlo' 'PruebaBloqueA' 'est-alta' "1004`n33444555`nDiego Sosa`nSistemas`n1800`n2024`n6.5`n30" @('Ingrese un numero entero entre 1900 y 2100.', 'Estudiante registrado.', 'VERIFICADO')
        Probar 'promedio con coma vuelve a pedirlo' 'PruebaBloqueA' 'est-alta' "1004`n33444555`nDiego Sosa`nSistemas`n2024`n8,5`n8.5`n30" @('usando punto decimal', 'Estudiante registrado.', 'VERIFICADO')
        Probar 'promedio vacio vuelve a pedirlo' 'PruebaBloqueA' 'est-alta' "1004`n33444555`nDiego Sosa`nSistemas`n2024`n`n7`n30" @('usando punto decimal', 'Estudiante registrado.', 'VERIFICADO')
        Probar 'porcentaje fuera de rango vuelve a pedirlo' 'PruebaBloqueA' 'est-alta' "1004`n33444555`nDiego Sosa`nSistemas`n2024`n6.5`n150`n30" @('Ingrese un numero entre 0.00 y 100.00', 'Estudiante registrado.', 'VERIFICADO')
        Probar 'nombre vacio se acepta' 'PruebaBloqueA' 'est-alta-nombre-vacio' "1004`n33444555`n`nSistemas`n2024`n6.5`n30" @('Estudiante registrado.', 'VERIFICADO')
    }

    if ($compilaB) {
        Suite 'Competencias'
        Probar 'alta con legajo inexistente' 'PruebaBloqueB' 'alta-rechazada' "E99" @('No existe un estudiante', 'VERIFICADO')
        Probar 'alta con codigo inexistente' 'PruebaBloqueB' 'alta-rechazada' "E1`nH99" @('No existe una habilidad', 'VERIFICADO')
        Probar 'alta con par repetido' 'PruebaBloqueB' 'alta-rechazada' "E1`nH1" @('ya tiene registrada', 'VERIFICADO')
        Probar 'alta y niveles invalidos' 'PruebaBloqueB' 'alta' "E5`nH1`n0`n6`ntexto`n`n9999999999999`n3" @('VERIFICADO', 'El nivel debe estar entre 1 y 5.')
        Probar 'modificar validando el nivel' 'PruebaBloqueB' 'modificar' "E1`nH1`n0`n6`n1" @('Competencia modificada.', 'VERIFICADO')
        Probar 'modificar competencia inexistente' 'PruebaBloqueB' 'modificar-inexistente' "E99`nH1" @('No existe esa competencia.')
        Probar 'baja de competencia inexistente' 'PruebaBloqueB' 'baja-inexistente' "E99`nH1" @('No existe esa competencia.')
        Probar 'baja logica' 'PruebaBloqueB' 'baja' "E1`nH1`nE1" @('Competencia dada de baja.', 'VERIFICADO') @('Programacion (H1')
        Probar 'nivel con texto vuelve a pedirlo' 'PruebaBloqueB' 'alta' "E5`nH1`ntexto`n3" @('El nivel debe estar entre 1 y 5.', 'Competencia registrada.', 'VERIFICADO')

        Suite 'Consulta por legajo'
        Probar 'ordena por habilidad y nivel' 'PruebaBloqueB' 'legajo' 'E1' @() @() @('Redes (H4', 'Programacion (H1', 'Analisis (H2', 'Analisis (H3')
        Probar 'legajo inexistente' 'PruebaBloqueB' 'legajo' 'E99' @('No existe un estudiante')
        Probar 'estudiante sin habilidades' 'PruebaBloqueB' 'legajo' 'E5' @('no posee habilidades registradas')

        Suite 'Consulta por habilidad y nivel'
        Probar 'ordena por promedio y nombre' 'PruebaBloqueB' 'habilidad' "H1`n0`n6`n2" @() @() @('Luis Gomez', 'Ana Torres', 'Zoe Perez', 'Bruno Diaz')
        Probar 'habilidad inexistente' 'PruebaBloqueB' 'habilidad' 'H99' @('No existe una habilidad')
        Probar 'sin resultados' 'PruebaBloqueB' 'habilidad' "H5`n5" @('No hay estudiantes con esa habilidad y nivel minimo.')
        Probar 'filtra por nivel minimo' 'PruebaBloqueB' 'habilidad' "H1`n5" @('Luis Gomez') @('Ana Torres', 'Zoe Perez', 'Bruno Diaz')
        Probar 'ignora estudiantes y habilidades inactivos' 'PruebaBloqueB' 'inactivos' "E1`nH1`n2" @('Analisis (H3', 'Ana Torres', 'Zoe Perez') @('Analisis (H2', 'Luis Gomez')
    }

    Write-Host ''
    Write-Host ('-' * 60)
    if (-not ($compilaA -and $compilaB)) {
        Write-Host 'No compilaron todos los programas de prueba. La suite esta incompleta.' -ForegroundColor Red
        Write-Host "Pruebas: $($script:pasaron) pasaron, $($script:fallaron) fallaron, $($script:total) en total"
        exit 1
    }
    if ($script:fallos.Count -gt 0) {
        Write-Host 'Pruebas que fallaron:' -ForegroundColor Red
        foreach ($f in $script:fallos) {
            Write-Host "  $($f.Nombre)" -ForegroundColor Red
            foreach ($m in $f.Motivos) { Write-Host "      $m" -ForegroundColor DarkYellow }
        }
        Write-Host ''
    }
    Write-Host "Pruebas: $($script:pasaron) pasaron, $($script:fallaron) fallaron, $($script:total) en total"
    if ($script:fallaron -gt 0) { exit 1 }
    exit 0
}
finally {
    if ((Split-Path $temporal -Parent) -eq ([IO.Path]::GetTempPath()).TrimEnd('\')) {
        Remove-Item -LiteralPath $temporal -Recurse -Force -ErrorAction SilentlyContinue
    }
}
