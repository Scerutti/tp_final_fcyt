program PopularDatos;
uses SysUtils, TiposGlobales;
var
  e: FileEstudiantes;
  h: FileHabilidades;
  c: FileCompetencias;
  est: TEstudiante;
  hab: THabilidad;
  comp: TCompetencia;
  i: LongInt;
  destino: string;
const
  nombres: array[1..5] of string[60] =
    ('Zoe Perez', 'Ana Torres', 'Luis Gomez', 'Bruno Diaz', 'Eva Ruiz');
  promedios: array[1..5] of Real = (8, 8, 9, 7, 6);
  habilidades: array[1..5] of string[40] =
    ('Programacion', 'Analisis', 'Analisis', 'Redes', 'Diseno');
  legajos: array[1..10] of Byte = (1, 1, 1, 1, 2, 2, 3, 3, 4, 4);
  codigos: array[1..10] of Byte = (1, 2, 3, 4, 1, 2, 1, 4, 1, 5);
  niveles: array[1..10] of Byte = (4, 5, 2, 3, 4, 2, 5, 4, 2, 3);
begin
  if ParamCount < 1 then
  begin
    writeln('Uso: PopularDatos carpeta [--reemplazar]'); Halt(1);
  end;
  destino := ParamStr(1);
  if not DirectoryExists(destino) then
    if not ForceDirectories(destino) then Halt(1);
  if (ParamStr(2) <> '--reemplazar') and
     (FileExists(IncludeTrailingPathDelimiter(destino) + 'estudiantes.dat') or
      FileExists(IncludeTrailingPathDelimiter(destino) + 'habilidades.dat') or
      FileExists(IncludeTrailingPathDelimiter(destino) + 'competencias.dat')) then
  begin
    writeln('Ya existen datos. Use el script con -Reemplazar para respaldarlos primero.');
    Halt(1);
  end;
  Assign(e, IncludeTrailingPathDelimiter(destino) + 'estudiantes.dat'); Rewrite(e);
  Assign(h, IncludeTrailingPathDelimiter(destino) + 'habilidades.dat'); Rewrite(h);
  Assign(c, IncludeTrailingPathDelimiter(destino) + 'competencias.dat'); Rewrite(c);
  FillChar(est, SizeOf(est), 0);
  for i := 1 to 5 do
  begin
    est.legajo := 'E' + IntToStr(i);
    est.dni := IntToStr(40000000 + i);
    est.nombreApellido := nombres[i]; est.carrera := 'LSI';
    est.anioIngreso := 2026; est.promedio := promedios[i];
    est.porcentajeAvance := 20; est.activo := True;
    Write(e, est);
  end;
  FillChar(hab, SizeOf(hab), 0);
  for i := 1 to 5 do
  begin
    hab.codigoHabilidad := 'H' + IntToStr(i);
    hab.nombre := habilidades[i]; hab.categoria := 'Tecnica';
    hab.activa := True; Write(h, hab);
  end;
  for i := 1 to 10 do
  begin
    comp.legajoEstudiante := 'E' + IntToStr(legajos[i]);
    comp.codigoHabilidad := 'H' + IntToStr(codigos[i]);
    comp.nivelDominio := niveles[i]; comp.activa := True; Write(c, comp);
  end;
  Close(c); Close(h); Close(e);
  writeln('Datos cargados: 5 estudiantes, 5 habilidades y 10 competencias.');
end.
