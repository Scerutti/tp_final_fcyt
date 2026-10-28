program UADERTalents;

uses
  TiposGlobales, UnitUtilidades, UnitEstudiantes, UnitHabilidades, UnitCompetencias, UnitPresentacion;

const
  CAMPOS_ESTUDIANTE: array[1..6] of string = ('DNI', 'Nombre y apellido', 'Carrera', 'Anio de ingreso',
                                              'Promedio', 'Porcentaje de avance');
  CAMPOS_HABILIDAD: array[1..2] of string = ('Nombre', 'Categoria');
  CAMPOS_COMPETENCIA: array[1..1] of string = ('Nivel de dominio');

var
  archE: FileEstudiantes;
  archH: FileHabilidades;
  archC: FileCompetencias;
  opcion: Char;

function NumeroDeCampo(op: Char; cantidad: Integer): Integer;
var
  campo: Integer;
begin
  campo := Ord(op) - Ord('0');
  if (campo < 1) or (campo > cantidad) then
    campo := 0;
  NumeroDeCampo := campo;
end;

procedure EditarEstudiante;
var
  est, nuevo: TEstudiante;
  legajo: string[10];
  posicion: LongInt;
  op: Char;
  campo: Integer;
  aviso: string;
begin
  MostrarTituloSeccion('ESTUDIANTES', 'Modificar estudiante');
  write('Legajo del estudiante a modificar: ');
  readln(legajo);
  posicion := BuscarEstudiante(archE, legajo, est);
  if posicion = -1 then
  begin
    writeln('No existe un estudiante con ese legajo.');
    Pausa;
  end
  else
  begin
    aviso := '';
    repeat
      MostrarEstadoActual('ESTUDIANTES', 'Modificar estudiante');
      MostrarEstudiante(est);
      MostrarOpcionesEdicion(CAMPOS_ESTUDIANTE, aviso);
      readln(op);
      aviso := '';
      campo := NumeroDeCampo(op, High(CAMPOS_ESTUDIANTE));
      if campo <> 0 then
      begin
        MostrarEstadoActual('ESTUDIANTES', 'Modificar estudiante');
        MostrarEstudiante(est);
        MostrarCampoElegido(CAMPOS_ESTUDIANTE[campo]);
        nuevo := est;
        if not LeerCampoEstudiante(archE, posicion, campo, nuevo) then
          Pausa
        else if Confirmar('Confirma el cambio?') then
        begin
          GuardarEstudiante(archE, posicion, nuevo);
          est := nuevo;
          aviso := 'Cambio guardado.';
        end
        else
          aviso := 'Cambio descartado.';
      end
      else if op <> '0' then
        aviso := 'Opcion invalida.';
    until op = '0';
  end;
end;

procedure EditarHabilidad;
var
  hab, nueva: THabilidad;
  codigo: string[10];
  posicion: LongInt;
  op: Char;
  campo: Integer;
  aviso: string;
begin
  MostrarTituloSeccion('HABILIDADES', 'Modificar habilidad');
  write('Codigo de la habilidad a modificar: ');
  readln(codigo);
  posicion := BuscarHabilidad(archH, codigo, hab);
  if posicion = -1 then
  begin
    writeln('No existe una habilidad con ese codigo.');
    Pausa;
  end
  else
  begin
    aviso := '';
    repeat
      MostrarEstadoActual('HABILIDADES', 'Modificar habilidad');
      MostrarHabilidad(hab);
      MostrarOpcionesEdicion(CAMPOS_HABILIDAD, aviso);
      readln(op);
      aviso := '';
      campo := NumeroDeCampo(op, High(CAMPOS_HABILIDAD));
      if campo <> 0 then
      begin
        MostrarEstadoActual('HABILIDADES', 'Modificar habilidad');
        MostrarHabilidad(hab);
        MostrarCampoElegido(CAMPOS_HABILIDAD[campo]);
        nueva := hab;
        LeerCampoHabilidad(campo, nueva);
        if Confirmar('Confirma el cambio?') then
        begin
          GuardarHabilidad(archH, posicion, nueva);
          hab := nueva;
          aviso := 'Cambio guardado.';
        end
        else
          aviso := 'Cambio descartado.';
      end
      else if op <> '0' then
        aviso := 'Opcion invalida.';
    until op = '0';
  end;
end;

procedure EditarCompetencia;
var
  comp, nueva: TCompetencia;
  legajo, codigo: string[10];
  posicion: LongInt;
  op: Char;
  campo: Integer;
  aviso: string;
begin
  MostrarTituloSeccion('COMPETENCIAS', 'Modificar competencia');
  write('Legajo del estudiante: ');
  readln(legajo);
  write('Codigo de habilidad: ');
  readln(codigo);
  posicion := BuscarCompetencia(archC, legajo, codigo, comp);
  if posicion = -1 then
  begin
    writeln('No existe esa competencia.');
    Pausa;
  end
  else
  begin
    aviso := '';
    repeat
      MostrarEstadoActual('COMPETENCIAS', 'Modificar competencia');
      MostrarCompetencia(comp);
      MostrarOpcionesEdicion(CAMPOS_COMPETENCIA, aviso);
      readln(op);
      aviso := '';
      campo := NumeroDeCampo(op, High(CAMPOS_COMPETENCIA));
      if campo <> 0 then
      begin
        MostrarEstadoActual('COMPETENCIAS', 'Modificar competencia');
        MostrarCompetencia(comp);
        MostrarCampoElegido(CAMPOS_COMPETENCIA[campo]);
        nueva := comp;
        LeerCampoCompetencia(campo, nueva);
        if Confirmar('Confirma el cambio?') then
        begin
          GuardarCompetencia(archC, posicion, nueva);
          comp := nueva;
          aviso := 'Cambio guardado.';
        end
        else
          aviso := 'Cambio descartado.';
      end
      else if op <> '0' then
        aviso := 'Opcion invalida.';
    until op = '0';
  end;
end;

procedure MenuEstudiantes;
var
  op: Char;
begin
  repeat
    MostrarMenu('ESTUDIANTES', ['Cargar estudiantes', 'Baja de estudiante', 'Modificar estudiante',
                'Listar estudiantes'], 'Volver al menu principal');
    readln(op);
    case op of
      '1': begin MostrarTituloSeccion('ESTUDIANTES', 'Carga de estudiantes'); CargarEstudiantes(archE); Pausa; end;
      '2': begin MostrarTituloSeccion('ESTUDIANTES', 'Baja de estudiante'); BajaEstudiante(archE); Pausa; end;
      '3': EditarEstudiante;
      '4': begin MostrarTituloSeccion('ESTUDIANTES', 'Listado de estudiantes'); ListarEstudiantes(archE); Pausa; end;
      '0': ;
    else
      MostrarAviso('Opcion invalida.');
    end;
  until op = '0';
end;

procedure MenuHabilidades;
var
  op: Char;
begin
  repeat
    MostrarMenu('HABILIDADES', ['Cargar habilidades', 'Baja de habilidad', 'Modificar habilidad',
                'Listar habilidades'], 'Volver al menu principal');
    readln(op);
    case op of
      '1': begin MostrarTituloSeccion('HABILIDADES', 'Carga de habilidades'); CargarHabilidades(archH); Pausa; end;
      '2': begin MostrarTituloSeccion('HABILIDADES', 'Baja de habilidad'); BajaHabilidad(archH); Pausa; end;
      '3': EditarHabilidad;
      '4': begin MostrarTituloSeccion('HABILIDADES', 'Listado de habilidades'); ListarHabilidades(archH); Pausa; end;
      '0': ;
    else
      MostrarAviso('Opcion invalida.');
    end;
  until op = '0';
end;

procedure MenuCompetencias;
var
  op: Char;
begin
  repeat
    MostrarMenu('COMPETENCIAS', ['Cargar competencias', 'Baja de competencia', 'Modificar competencia',
                'Listar competencias'], 'Volver al menu principal');
    readln(op);
    case op of
      '1': begin MostrarTituloSeccion('COMPETENCIAS', 'Carga de competencias'); CargarCompetencias(archC, archE, archH); Pausa; end;
      '2': begin MostrarTituloSeccion('COMPETENCIAS', 'Baja de competencia'); BajaCompetencia(archC); Pausa; end;
      '3': EditarCompetencia;
      '4': begin MostrarTituloSeccion('COMPETENCIAS', 'Listado de competencias'); ListarCompetencias(archC); Pausa; end;
      '0': ;
    else
      MostrarAviso('Opcion invalida.');
    end;
  until op = '0';
end;

begin
  Paginador := @PaginarListado;
  AbrirEstudiantes(archE);
  AbrirHabilidades(archH);
  AbrirCompetencias(archC);
  MostrarPresentacion;
  repeat
    MostrarMenu('MENU PRINCIPAL', ['Estudiantes', 'Habilidades', 'Competencias',
                'Consultar estudiante por legajo', 'Consultar por habilidad y nivel minimo'], 'Salir');
    readln(opcion);
    case opcion of
      '1': MenuEstudiantes;
      '2': MenuHabilidades;
      '3': MenuCompetencias;
      '4': begin MostrarTituloSeccion('CONSULTAS', 'Estudiante por legajo'); ConsultarPorLegajo(archC, archE, archH); Pausa; end;
      '5': begin MostrarTituloSeccion('CONSULTAS', 'Habilidad y nivel minimo'); ConsultarPorHabilidad(archC, archE, archH); Pausa; end;
      '0': MostrarDespedida;
    else
      MostrarAviso('Opcion invalida.');
    end;
  until opcion = '0';
  Close(archE);
  Close(archH);
  Close(archC);
end.
