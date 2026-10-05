unit UnitEstudiantes;

interface

uses
  SysUtils, TiposGlobales;

const
  RUTA_ESTUDIANTES = 'docs\estudiantes.dat';

procedure AbrirEstudiantes(var archE: FileEstudiantes);
function BuscarEstudiante(var archE: FileEstudiantes; legajo: string; var est: TEstudiante): LongInt;
function BuscarEstudiantePorDni(var archE: FileEstudiantes; dni: string): LongInt;
procedure MostrarEstudiante(est: TEstudiante);
procedure AltaEstudiante(var archE: FileEstudiantes);
procedure CargarEstudiantes(var archE: FileEstudiantes);
procedure BajaEstudiante(var archE: FileEstudiantes);
procedure ModificarEstudiante(var archE: FileEstudiantes);
procedure ListarEstudiantes(var archE: FileEstudiantes);

implementation

procedure AbrirEstudiantes(var archE: FileEstudiantes);
begin
  Assign(archE, RUTA_ESTUDIANTES);
  if FileExists(RUTA_ESTUDIANTES) then
    Reset(archE)
  else
    Rewrite(archE);
end;

function BuscarEstudiante(var archE: FileEstudiantes; legajo: string; var est: TEstudiante): LongInt;
var
  posicion: LongInt;
begin
  posicion := -1;
  Seek(archE, 0);
  while (not Eof(archE)) and (posicion = -1) do
  begin
    Read(archE, est);
    if est.activo and (est.legajo = legajo) then
      posicion := FilePos(archE) - 1;
  end;
  BuscarEstudiante := posicion;
end;

function BuscarEstudiantePorDni(var archE: FileEstudiantes; dni: string): LongInt;
var
  est: TEstudiante;
  posicion: LongInt;
begin
  posicion := -1;
  Seek(archE, 0);
  while (not Eof(archE)) and (posicion = -1) do
  begin
    Read(archE, est);
    if est.activo and (est.dni = dni) then
      posicion := FilePos(archE) - 1;
  end;
  BuscarEstudiantePorDni := posicion;
end;

procedure MostrarEstudiante(est: TEstudiante);
begin
  writeln('Legajo: ', est.legajo);
  writeln('DNI: ', est.dni);
  writeln('Nombre y apellido: ', est.nombreApellido);
  writeln('Carrera: ', est.carrera);
  writeln('Anio de ingreso: ', est.anioIngreso);
  writeln('Promedio: ', est.promedio:0:2);
  writeln('Porcentaje de avance: ', est.porcentajeAvance:0:2, '%');
  writeln('----------------------------------------');
end;

procedure LeerDatosEstudiante(var est: TEstudiante);
begin
  write('Nombre y apellido: ');
  readln(est.nombreApellido);
  write('Carrera: ');
  readln(est.carrera);
  write('Anio de ingreso: ');
  readln(est.anioIngreso);
  write('Promedio: ');
  readln(est.promedio);
  write('Porcentaje de avance en carrera: ');
  readln(est.porcentajeAvance);
end;

procedure AltaEstudiante(var archE: FileEstudiantes);
var
  est, existente: TEstudiante;
begin
  write('Legajo: ');
  readln(est.legajo);
  if BuscarEstudiante(archE, est.legajo, existente) <> -1 then
    writeln('Ya existe un estudiante con ese legajo.')
  else
  begin
    write('DNI: ');
    readln(est.dni);
    if BuscarEstudiantePorDni(archE, est.dni) <> -1 then
      writeln('Ya existe un estudiante con ese DNI.')
    else
    begin
      LeerDatosEstudiante(est);
      est.activo := True;
      Seek(archE, FileSize(archE));
      Write(archE, est);
      writeln('Estudiante registrado.');
    end;
  end;
end;

procedure CargarEstudiantes(var archE: FileEstudiantes);
var
  respuesta: Char;
begin
  repeat
    AltaEstudiante(archE);
    write('Desea cargar otro estudiante? (S/N): ');
    readln(respuesta);
  until UpCase(respuesta) <> 'S';
end;

procedure BajaEstudiante(var archE: FileEstudiantes);
var
  est: TEstudiante;
  legajo: string[10];
  posicion: LongInt;
begin
  write('Legajo del estudiante a dar de baja: ');
  readln(legajo);
  posicion := BuscarEstudiante(archE, legajo, est);
  if posicion = -1 then
    writeln('No existe un estudiante con ese legajo.')
  else
  begin
    est.activo := False;
    Seek(archE, posicion);
    Write(archE, est);
    writeln('Estudiante dado de baja.');
  end;
end;

procedure ModificarEstudiante(var archE: FileEstudiantes);
var
  est: TEstudiante;
  legajo, dni: string[10];
  posicion, posicionDni: LongInt;
begin
  write('Legajo del estudiante a modificar: ');
  readln(legajo);
  posicion := BuscarEstudiante(archE, legajo, est);
  if posicion = -1 then
    writeln('No existe un estudiante con ese legajo.')
  else
  begin
    MostrarEstudiante(est);
    write('DNI: ');
    readln(dni);
    posicionDni := BuscarEstudiantePorDni(archE, dni);
    if (posicionDni <> -1) and (posicionDni <> posicion) then
      writeln('Ya existe otro estudiante con ese DNI.')
    else
    begin
      est.dni := dni;
      LeerDatosEstudiante(est);
      Seek(archE, posicion);
      Write(archE, est);
      writeln('Estudiante modificado.');
    end;
  end;
end;

procedure ListarEstudiantes(var archE: FileEstudiantes);
var
  est: TEstudiante;
  cantidad: Integer;
begin
  cantidad := 0;
  Seek(archE, 0);
  while not Eof(archE) do
  begin
    Read(archE, est);
    if est.activo then
    begin
      MostrarEstudiante(est);
      cantidad := cantidad + 1;
    end;
  end;
  if cantidad = 0 then
    writeln('No hay estudiantes registrados.');
end;

end.
