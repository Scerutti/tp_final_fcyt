unit UnitHabilidades;

interface

uses
  SysUtils, TiposGlobales;

const
  RUTA_HABILIDADES = 'docs\habilidades.dat';

procedure AbrirHabilidades(var archH: FileHabilidades);
function BuscarHabilidad(var archH: FileHabilidades; codigo: string; var hab: THabilidad): LongInt;
procedure MostrarHabilidad(hab: THabilidad);
procedure AltaHabilidad(var archH: FileHabilidades);
procedure CargarHabilidades(var archH: FileHabilidades);
procedure BajaHabilidad(var archH: FileHabilidades);
procedure ModificarHabilidad(var archH: FileHabilidades);
procedure ListarHabilidades(var archH: FileHabilidades);

implementation

procedure AbrirHabilidades(var archH: FileHabilidades);
begin
  Assign(archH, RUTA_HABILIDADES);
  if FileExists(RUTA_HABILIDADES) then
    Reset(archH)
  else
    Rewrite(archH);
end;

function BuscarHabilidad(var archH: FileHabilidades; codigo: string; var hab: THabilidad): LongInt;
var
  posicion: LongInt;
begin
  posicion := -1;
  Seek(archH, 0);
  while (not Eof(archH)) and (posicion = -1) do
  begin
    Read(archH, hab);
    if hab.activa and (hab.codigoHabilidad = codigo) then
      posicion := FilePos(archH) - 1;
  end;
  BuscarHabilidad := posicion;
end;

procedure MostrarHabilidad(hab: THabilidad);
begin
  writeln('Codigo: ', hab.codigoHabilidad);
  writeln('Nombre: ', hab.nombre);
  writeln('Categoria: ', hab.categoria);
  writeln('----------------------------------------');
end;

procedure LeerDatosHabilidad(var hab: THabilidad);
begin
  write('Nombre: ');
  readln(hab.nombre);
  write('Categoria: ');
  readln(hab.categoria);
end;

procedure AltaHabilidad(var archH: FileHabilidades);
var
  hab, existente: THabilidad;
begin
  write('Codigo de habilidad: ');
  readln(hab.codigoHabilidad);
  if BuscarHabilidad(archH, hab.codigoHabilidad, existente) <> -1 then
    writeln('Ya existe una habilidad con ese codigo.')
  else
  begin
    LeerDatosHabilidad(hab);
    hab.activa := True;
    Seek(archH, FileSize(archH));
    Write(archH, hab);
    writeln('Habilidad registrada.');
  end;
end;

procedure CargarHabilidades(var archH: FileHabilidades);
var
  respuesta: Char;
begin
  repeat
    AltaHabilidad(archH);
    write('Desea cargar otra habilidad? (S/N): ');
    readln(respuesta);
  until UpCase(respuesta) <> 'S';
end;

procedure BajaHabilidad(var archH: FileHabilidades);
var
  hab: THabilidad;
  codigo: string[10];
  posicion: LongInt;
begin
  write('Codigo de la habilidad a dar de baja: ');
  readln(codigo);
  posicion := BuscarHabilidad(archH, codigo, hab);
  if posicion = -1 then
    writeln('No existe una habilidad con ese codigo.')
  else
  begin
    hab.activa := False;
    Seek(archH, posicion);
    Write(archH, hab);
    writeln('Habilidad dada de baja.');
  end;
end;

procedure ModificarHabilidad(var archH: FileHabilidades);
var
  hab: THabilidad;
  codigo: string[10];
  posicion: LongInt;
begin
  write('Codigo de la habilidad a modificar: ');
  readln(codigo);
  posicion := BuscarHabilidad(archH, codigo, hab);
  if posicion = -1 then
    writeln('No existe una habilidad con ese codigo.')
  else
  begin
    MostrarHabilidad(hab);
    LeerDatosHabilidad(hab);
    Seek(archH, posicion);
    Write(archH, hab);
    writeln('Habilidad modificada.');
  end;
end;

procedure ListarHabilidades(var archH: FileHabilidades);
var
  hab: THabilidad;
  cantidad: Integer;
begin
  cantidad := 0;
  Seek(archH, 0);
  while not Eof(archH) do
  begin
    Read(archH, hab);
    if hab.activa then
    begin
      MostrarHabilidad(hab);
      cantidad := cantidad + 1;
    end;
  end;
  if cantidad = 0 then
    writeln('No hay habilidades registradas.');
end;

end.
