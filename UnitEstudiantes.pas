unit UnitEstudiantes;

interface

uses
  SysUtils, TiposGlobales, UnitUtilidades;

const
  RUTA_ESTUDIANTES = 'docs\estudiantes.dat';

procedure AbrirEstudiantes(var archE: FileEstudiantes);
function BuscarEstudiante(var archE: FileEstudiantes; legajo: string; var est: TEstudiante): LongInt;
function BuscarEstudiantePorDni(var archE: FileEstudiantes; dni: string): LongInt;
procedure MostrarEstudiante(est: TEstudiante);
procedure CargarEstudiantes(var archE: FileEstudiantes);
procedure BajaEstudiante(var archE: FileEstudiantes);
function LeerCampoEstudiante(var archE: FileEstudiantes; posicion: LongInt; campo: Integer; var est: TEstudiante): Boolean;
procedure GuardarEstudiante(var archE: FileEstudiantes; posicion: LongInt; est: TEstudiante);
procedure ListarEstudiantes(var archE: FileEstudiantes);

implementation

const
  TITULOS_ESTUDIANTES: array[1..7] of string = ('Legajo', 'DNI', 'Nombre y apellido', 'Carrera', 'Ingreso', 'Prom.', 'Avance');
  ANCHOS_ESTUDIANTES: array[1..7] of Integer = (10, 10, 25, 16, 7, 5, 7);

procedure AbrirEstudiantes(var archE: FileEstudiantes);
var
  carpeta: string;
begin
  carpeta := ExtractFilePath(RUTA_ESTUDIANTES);
  if (carpeta <> '') and (not DirectoryExists(carpeta)) then
    ForceDirectories(carpeta);
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
  MostrarDato('Legajo', est.legajo);
  MostrarDato('DNI', est.dni);
  MostrarDato('Nombre y apellido', est.nombreApellido);
  MostrarDato('Carrera', est.carrera);
  MostrarDato('Anio de ingreso', IntToStr(est.anioIngreso));
  MostrarDato('Promedio', RealATexto(est.promedio));
  MostrarDato('Porcentaje de avance', RealATexto(est.porcentajeAvance) + '%');
end;

procedure LeerDatosEstudiante(var est: TEstudiante);
begin
  write('Nombre y apellido: ');
  readln(est.nombreApellido);
  write('Carrera: ');
  readln(est.carrera);
  est.anioIngreso := LeerEntero('Anio de ingreso: ', 1900, 2100);
  est.promedio := LeerReal('Promedio: ', 0, 10);
  est.porcentajeAvance := LeerReal('Porcentaje de avance en carrera: ', 0, 100);
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
begin
  repeat
    AltaEstudiante(archE);
    writeln;
  until not Confirmar('Desea cargar otro estudiante?');
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
    writeln;
    MostrarEstudiante(est);
    writeln;
    if Confirmar('Confirma la baja del estudiante?') then
    begin
      est.activo := False;
      GuardarEstudiante(archE, posicion, est);
      writeln('Estudiante dado de baja.');
    end
    else
      writeln('Baja cancelada.');
  end;
end;

function LeerCampoEstudiante(var archE: FileEstudiantes; posicion: LongInt; campo: Integer; var est: TEstudiante): Boolean;
var
  dni: string[10];
  posicionDni: LongInt;
  valido: Boolean;
begin
  valido := True;
  case campo of
    1:
      begin
        write('Nuevo DNI: ');
        readln(dni);
        posicionDni := BuscarEstudiantePorDni(archE, dni);
        if (posicionDni <> -1) and (posicionDni <> posicion) then
        begin
          writeln('Ya existe otro estudiante con ese DNI.');
          valido := False;
        end
        else
          est.dni := dni;
      end;
    2:
      begin
        write('Nuevo nombre y apellido: ');
        readln(est.nombreApellido);
      end;
    3:
      begin
        write('Nueva carrera: ');
        readln(est.carrera);
      end;
    4: est.anioIngreso := LeerEntero('Nuevo anio de ingreso: ', 1900, 2100);
    5: est.promedio := LeerReal('Nuevo promedio: ', 0, 10);
    6: est.porcentajeAvance := LeerReal('Nuevo porcentaje de avance: ', 0, 100);
  end;
  LeerCampoEstudiante := valido;
end;

procedure GuardarEstudiante(var archE: FileEstudiantes; posicion: LongInt; est: TEstudiante);
begin
  Seek(archE, posicion);
  Write(archE, est);
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
      AgregarFila([est.legajo, est.dni, est.nombreApellido, est.carrera, IntToStr(est.anioIngreso),
                   RealATexto(est.promedio), RealATexto(est.porcentajeAvance) + '%'],
                  TITULOS_ESTUDIANTES, ANCHOS_ESTUDIANTES, cantidad);
  end;
  if cantidad = 0 then
    writeln('No hay estudiantes registrados.')
  else
    CerrarTabla(ANCHOS_ESTUDIANTES, cantidad);
end;

end.
