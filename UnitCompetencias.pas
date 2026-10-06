unit UnitCompetencias;

interface

uses
  SysUtils, TiposGlobales, UnitEstudiantes, UnitHabilidades;

const
  RUTA_COMPETENCIAS = 'docs\competencias.dat';

procedure AbrirCompetencias(var archC: FileCompetencias);
function BuscarCompetencia(var archC: FileCompetencias; legajo, codigo: string; var comp: TCompetencia): LongInt;
function NombreNivel(nivel: Byte): string;
procedure MostrarCompetencia(comp: TCompetencia);
procedure AltaCompetencia(var archC: FileCompetencias; var archE: FileEstudiantes; var archH: FileHabilidades);
procedure CargarCompetencias(var archC: FileCompetencias; var archE: FileEstudiantes; var archH: FileHabilidades);
procedure BajaCompetencia(var archC: FileCompetencias);
procedure ModificarCompetencia(var archC: FileCompetencias);
procedure ListarCompetencias(var archC: FileCompetencias);
procedure ConsultarPorLegajo(var archC: FileCompetencias; var archE: FileEstudiantes; var archH: FileHabilidades);
procedure ConsultarPorHabilidad(var archC: FileCompetencias; var archE: FileEstudiantes; var archH: FileHabilidades);

implementation

const
  MAX_RESULTADOS = 1000;

type
  THabilidadEstudiante = record
    codigoHabilidad: string[10];
    nombre: string[40];
    categoria: string[30];
    nivelDominio: Byte;
  end;
  TVectorHabilidades = array[1..MAX_RESULTADOS] of THabilidadEstudiante;

  TCandidato = record
    est: TEstudiante;
    nivelDominio: Byte;
  end;
  TVectorCandidatos = array[1..MAX_RESULTADOS] of TCandidato;

var
  habilidadesEstudiante: TVectorHabilidades;
  candidatos: TVectorCandidatos;

procedure AbrirCompetencias(var archC: FileCompetencias);
var
  carpeta: string;
begin
  carpeta := ExtractFilePath(RUTA_COMPETENCIAS);
  if (carpeta <> '') and (not DirectoryExists(carpeta)) then
    ForceDirectories(carpeta);
  Assign(archC, RUTA_COMPETENCIAS);
  if FileExists(RUTA_COMPETENCIAS) then
    Reset(archC)
  else
    Rewrite(archC);
end;

function BuscarCompetencia(var archC: FileCompetencias; legajo, codigo: string; var comp: TCompetencia): LongInt;
var
  posicion: LongInt;
begin
  posicion := -1;
  Seek(archC, 0);
  while (not Eof(archC)) and (posicion = -1) do
  begin
    Read(archC, comp);
    if comp.activa and (comp.legajoEstudiante = legajo) and (comp.codigoHabilidad = codigo) then
      posicion := FilePos(archC) - 1;
  end;
  BuscarCompetencia := posicion;
end;

function NombreNivel(nivel: Byte): string;
begin
  case nivel of
    1: NombreNivel := 'Inicial';
    2: NombreNivel := 'Basico';
    3: NombreNivel := 'Intermedio';
    4: NombreNivel := 'Avanzado';
    5: NombreNivel := 'Experto';
  else
    NombreNivel := 'Desconocido';
  end;
end;

function LeerNivel(mensaje: string): Byte;
var
  entrada: string;
  nivel, error: LongInt;
  valido: Boolean;
begin
  repeat
    write(mensaje, ' (1=Inicial, 2=Basico, 3=Intermedio, 4=Avanzado, 5=Experto): ');
    readln(entrada);
    Val(Trim(entrada), nivel, error);
    valido := (error = 0) and (nivel >= 1) and (nivel <= 5);
    if not valido then
      writeln('El nivel debe estar entre 1 y 5.');
  until valido;
  LeerNivel := nivel;
end;

procedure MostrarCompetencia(comp: TCompetencia);
begin
  writeln('Legajo: ', comp.legajoEstudiante);
  writeln('Codigo de habilidad: ', comp.codigoHabilidad);
  writeln('Nivel de dominio: ', comp.nivelDominio, ' - ', NombreNivel(comp.nivelDominio));
  writeln('----------------------------------------');
end;

procedure AltaCompetencia(var archC: FileCompetencias; var archE: FileEstudiantes; var archH: FileHabilidades);
var
  comp, existente: TCompetencia;
  est: TEstudiante;
  hab: THabilidad;
begin
  write('Legajo del estudiante: ');
  readln(comp.legajoEstudiante);
  if BuscarEstudiante(archE, comp.legajoEstudiante, est) = -1 then
    writeln('No existe un estudiante con ese legajo.')
  else
  begin
    write('Codigo de habilidad: ');
    readln(comp.codigoHabilidad);
    if BuscarHabilidad(archH, comp.codigoHabilidad, hab) = -1 then
      writeln('No existe una habilidad con ese codigo.')
    else if BuscarCompetencia(archC, comp.legajoEstudiante, comp.codigoHabilidad, existente) <> -1 then
      writeln('El estudiante ya tiene registrada esa habilidad.')
    else
    begin
      comp.nivelDominio := LeerNivel('Nivel de dominio');
      comp.activa := True;
      Seek(archC, FileSize(archC));
      Write(archC, comp);
      writeln('Competencia registrada.');
    end;
  end;
end;

procedure CargarCompetencias(var archC: FileCompetencias; var archE: FileEstudiantes; var archH: FileHabilidades);
var
  respuesta: Char;
begin
  repeat
    AltaCompetencia(archC, archE, archH);
    write('Desea cargar otra competencia? (S/N): ');
    readln(respuesta);
  until UpCase(respuesta) <> 'S';
end;

procedure BajaCompetencia(var archC: FileCompetencias);
var
  comp: TCompetencia;
  legajo, codigo: string[10];
  posicion: LongInt;
begin
  write('Legajo del estudiante: ');
  readln(legajo);
  write('Codigo de habilidad: ');
  readln(codigo);
  posicion := BuscarCompetencia(archC, legajo, codigo, comp);
  if posicion = -1 then
    writeln('No existe esa competencia.')
  else
  begin
    comp.activa := False;
    Seek(archC, posicion);
    Write(archC, comp);
    writeln('Competencia dada de baja.');
  end;
end;

procedure ModificarCompetencia(var archC: FileCompetencias);
var
  comp: TCompetencia;
  legajo, codigo: string[10];
  posicion: LongInt;
begin
  write('Legajo del estudiante: ');
  readln(legajo);
  write('Codigo de habilidad: ');
  readln(codigo);
  posicion := BuscarCompetencia(archC, legajo, codigo, comp);
  if posicion = -1 then
    writeln('No existe esa competencia.')
  else
  begin
    MostrarCompetencia(comp);
    comp.nivelDominio := LeerNivel('Nuevo nivel de dominio');
    Seek(archC, posicion);
    Write(archC, comp);
    writeln('Competencia modificada.');
  end;
end;

procedure ListarCompetencias(var archC: FileCompetencias);
var
  comp: TCompetencia;
  cantidad: Integer;
begin
  cantidad := 0;
  Seek(archC, 0);
  while not Eof(archC) do
  begin
    Read(archC, comp);
    if comp.activa then
    begin
      MostrarCompetencia(comp);
      cantidad := cantidad + 1;
    end;
  end;
  if cantidad = 0 then
    writeln('No hay competencias registradas.');
end;

procedure OrdenarPorHabilidadYNivel(var v: TVectorHabilidades; n: Integer);
var
  i, j: Integer;
  aux: THabilidadEstudiante;
begin
  for i := 1 to n - 1 do
    for j := 1 to n - i do
      if (v[j].nombre < v[j + 1].nombre) or
         ((v[j].nombre = v[j + 1].nombre) and (v[j].nivelDominio < v[j + 1].nivelDominio)) then
      begin
        aux := v[j];
        v[j] := v[j + 1];
        v[j + 1] := aux;
      end;
end;

procedure ConsultarPorLegajo(var archC: FileCompetencias; var archE: FileEstudiantes; var archH: FileHabilidades);
var
  est: TEstudiante;
  comp: TCompetencia;
  hab: THabilidad;
  legajo: string[10];
  cantidad, i: Integer;
begin
  write('Legajo del estudiante: ');
  readln(legajo);
  if BuscarEstudiante(archE, legajo, est) = -1 then
    writeln('No existe un estudiante con ese legajo.')
  else
  begin
    MostrarEstudiante(est);
    cantidad := 0;
    Seek(archC, 0);
    while (not Eof(archC)) and (cantidad < MAX_RESULTADOS) do
    begin
      Read(archC, comp);
      if comp.activa and (comp.legajoEstudiante = legajo) then
        if BuscarHabilidad(archH, comp.codigoHabilidad, hab) <> -1 then
        begin
          cantidad := cantidad + 1;
          habilidadesEstudiante[cantidad].codigoHabilidad := hab.codigoHabilidad;
          habilidadesEstudiante[cantidad].nombre := hab.nombre;
          habilidadesEstudiante[cantidad].categoria := hab.categoria;
          habilidadesEstudiante[cantidad].nivelDominio := comp.nivelDominio;
        end;
    end;
    if cantidad = 0 then
      writeln('El estudiante no posee habilidades registradas.')
    else
    begin
      OrdenarPorHabilidadYNivel(habilidadesEstudiante, cantidad);
      writeln('Habilidades del estudiante:');
      for i := 1 to cantidad do
        writeln(habilidadesEstudiante[i].nombre, ' (', habilidadesEstudiante[i].codigoHabilidad, ', ',
                habilidadesEstudiante[i].categoria, ') - Nivel: ', habilidadesEstudiante[i].nivelDominio,
                ' - ', NombreNivel(habilidadesEstudiante[i].nivelDominio));
    end;
  end;
end;

procedure OrdenarPorPromedioYNombre(var v: TVectorCandidatos; n: Integer);
var
  i, j: Integer;
  aux: TCandidato;
begin
  for i := 1 to n - 1 do
    for j := 1 to n - i do
      if (v[j].est.promedio < v[j + 1].est.promedio) or
         ((v[j].est.promedio = v[j + 1].est.promedio) and (v[j].est.nombreApellido > v[j + 1].est.nombreApellido)) then
      begin
        aux := v[j];
        v[j] := v[j + 1];
        v[j + 1] := aux;
      end;
end;

procedure ConsultarPorHabilidad(var archC: FileCompetencias; var archE: FileEstudiantes; var archH: FileHabilidades);
var
  est: TEstudiante;
  comp: TCompetencia;
  hab: THabilidad;
  codigo: string[10];
  nivelMinimo: Byte;
  cantidad, i: Integer;
begin
  write('Codigo de habilidad: ');
  readln(codigo);
  if BuscarHabilidad(archH, codigo, hab) = -1 then
    writeln('No existe una habilidad con ese codigo.')
  else
  begin
    nivelMinimo := LeerNivel('Nivel minimo de dominio');
    cantidad := 0;
    Seek(archC, 0);
    while (not Eof(archC)) and (cantidad < MAX_RESULTADOS) do
    begin
      Read(archC, comp);
      if comp.activa and (comp.codigoHabilidad = codigo) and (comp.nivelDominio >= nivelMinimo) then
        if BuscarEstudiante(archE, comp.legajoEstudiante, est) <> -1 then
        begin
          cantidad := cantidad + 1;
          candidatos[cantidad].est := est;
          candidatos[cantidad].nivelDominio := comp.nivelDominio;
        end;
    end;
    if cantidad = 0 then
      writeln('No hay estudiantes con esa habilidad y nivel minimo.')
    else
    begin
      OrdenarPorPromedioYNombre(candidatos, cantidad);
      writeln('Estudiantes con ', hab.nombre, ' y nivel minimo ', nivelMinimo, ':');
      writeln('----------------------------------------');
      for i := 1 to cantidad do
      begin
        writeln('Nivel de dominio en ', hab.nombre, ': ', candidatos[i].nivelDominio, ' - ',
                NombreNivel(candidatos[i].nivelDominio));
        MostrarEstudiante(candidatos[i].est);
      end;
    end;
  end;
end;

end.
