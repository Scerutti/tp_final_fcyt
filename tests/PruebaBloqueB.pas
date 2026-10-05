program PruebaBloqueB;
uses SysUtils, TiposGlobales, UnitCompetencias;
var
  e: FileEstudiantes;
  h: FileHabilidades;
  c: FileCompetencias;
  est: TEstudiante;
  hab: THabilidad;
  comp: TCompetencia;
  i, pos: LongInt;
  accion: string;
const
  nombres: array[1..5] of string[60] =
    ('Zoe Perez', 'Ana Torres', 'Luis Gomez', 'Bruno Diaz', 'Eva Ruiz');
  promedios: array[1..5] of Real = (8, 8, 9, 7, 6);
  habilidades: array[1..5] of string[40] =
    ('Programacion', 'Analisis', 'Analisis', 'Redes', 'Diseno');
  legajos: array[1..10] of Byte = (1, 1, 1, 1, 2, 2, 3, 3, 4, 4);
  codigos: array[1..10] of Byte = (1, 2, 3, 4, 1, 2, 1, 4, 1, 5);
  niveles: array[1..10] of Byte = (4, 5, 2, 3, 4, 2, 5, 4, 2, 3);
procedure Comprobar(condicion: Boolean);
begin
  if not condicion then Halt(1);
  writeln('VERIFICADO');
end;
begin
  Assign(e, 'estudiantes.dat'); Rewrite(e);
  Assign(h, 'habilidades.dat'); Rewrite(h);
  Assign(c, 'competencias.dat'); Rewrite(c);
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
  accion := ParamStr(1);
  if accion = 'alta-rechazada' then
  begin
    AltaCompetencia(c, e, h); Comprobar(FileSize(c) = 10);
  end
  else if accion = 'alta' then
  begin
    AltaCompetencia(c, e, h);
    pos := BuscarCompetencia(c, 'E5', 'H1', comp);
    Comprobar((FileSize(c) = 11) and (pos = 10) and (comp.nivelDominio = 3));
  end
  else if accion = 'modificar' then
  begin
    ModificarCompetencia(c);
    pos := BuscarCompetencia(c, 'E1', 'H1', comp);
    Comprobar((FileSize(c) = 10) and (pos = 0) and (comp.nivelDominio = 1));
  end
  else if accion = 'baja' then
  begin
    BajaCompetencia(c);
    Comprobar((FileSize(c) = 10) and (BuscarCompetencia(c, 'E1', 'H1', comp) = -1));
    Seek(c, 0); Read(c, comp); Comprobar(not comp.activa);
    ConsultarPorLegajo(c, e, h);
  end
  else if accion = 'modificar-inexistente' then ModificarCompetencia(c)
  else if accion = 'baja-inexistente' then BajaCompetencia(c)
  else if accion = 'legajo' then ConsultarPorLegajo(c, e, h)
  else if accion = 'habilidad' then ConsultarPorHabilidad(c, e, h)
  else if accion = 'inactivos' then
  begin
    Seek(h, 1); Read(h, hab); hab.activa := False; Seek(h, 1); Write(h, hab);
    Seek(e, 2); Read(e, est); est.activo := False; Seek(e, 2); Write(e, est);
    ConsultarPorLegajo(c, e, h); ConsultarPorHabilidad(c, e, h);
  end
  else Halt(2);
  Close(c); Close(h); Close(e);
end.
