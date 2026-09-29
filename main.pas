program UADERTalents;

uses
  TiposGlobales, UnitEstudiantes, UnitHabilidades, UnitCompetencias, UnitPresentacion;

var
  archE: FileEstudiantes;
  archH: FileHabilidades;
  archC: FileCompetencias;
  opcion: Char;

procedure MenuEstudiantes;
var
  op: Char;
begin
  repeat
    MostrarMenu('ESTUDIANTES', ['Cargar estudiantes', 'Alta de estudiante', 'Baja de estudiante',
                'Modificar estudiante', 'Listar estudiantes'], 'Volver al menu principal');
    readln(op);
    case op of
      '1': begin MostrarTituloSeccion('ESTUDIANTES', 'Carga de estudiantes'); CargarEstudiantes(archE); Pausa; end;
      '2': begin MostrarTituloSeccion('ESTUDIANTES', 'Alta de estudiante'); AltaEstudiante(archE); Pausa; end;
      '3': begin MostrarTituloSeccion('ESTUDIANTES', 'Baja de estudiante'); BajaEstudiante(archE); Pausa; end;
      '4': begin MostrarTituloSeccion('ESTUDIANTES', 'Modificar estudiante'); ModificarEstudiante(archE); Pausa; end;
      '5': begin MostrarTituloSeccion('ESTUDIANTES', 'Listado de estudiantes'); ListarEstudiantes(archE); Pausa; end;
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
    MostrarMenu('HABILIDADES', ['Cargar habilidades', 'Alta de habilidad', 'Baja de habilidad',
                'Modificar habilidad', 'Listar habilidades'], 'Volver al menu principal');
    readln(op);
    case op of
      '1': begin MostrarTituloSeccion('HABILIDADES', 'Carga de habilidades'); CargarHabilidades(archH); Pausa; end;
      '2': begin MostrarTituloSeccion('HABILIDADES', 'Alta de habilidad'); AltaHabilidad(archH); Pausa; end;
      '3': begin MostrarTituloSeccion('HABILIDADES', 'Baja de habilidad'); BajaHabilidad(archH); Pausa; end;
      '4': begin MostrarTituloSeccion('HABILIDADES', 'Modificar habilidad'); ModificarHabilidad(archH); Pausa; end;
      '5': begin MostrarTituloSeccion('HABILIDADES', 'Listado de habilidades'); ListarHabilidades(archH); Pausa; end;
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
    MostrarMenu('COMPETENCIAS', ['Cargar competencias', 'Alta de competencia', 'Baja de competencia',
                'Modificar competencia', 'Listar competencias'], 'Volver al menu principal');
    readln(op);
    case op of
      '1': begin MostrarTituloSeccion('COMPETENCIAS', 'Carga de competencias'); CargarCompetencias(archC, archE, archH); Pausa; end;
      '2': begin MostrarTituloSeccion('COMPETENCIAS', 'Alta de competencia'); AltaCompetencia(archC, archE, archH); Pausa; end;
      '3': begin MostrarTituloSeccion('COMPETENCIAS', 'Baja de competencia'); BajaCompetencia(archC); Pausa; end;
      '4': begin MostrarTituloSeccion('COMPETENCIAS', 'Modificar competencia'); ModificarCompetencia(archC); Pausa; end;
      '5': begin MostrarTituloSeccion('COMPETENCIAS', 'Listado de competencias'); ListarCompetencias(archC); Pausa; end;
      '0': ;
    else
      MostrarAviso('Opcion invalida.');
    end;
  until op = '0';
end;

begin
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
