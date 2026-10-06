program PruebaBloqueA;
uses SysUtils, TiposGlobales, UnitEstudiantes, UnitHabilidades;
var
  e, aux: FileEstudiantes;
  h: FileHabilidades;
  est: TEstudiante;
  hab: THabilidad;
  i: LongInt;
  accion: string;
const
  legajos: array[1..3] of string[10] = ('1001', '1002', '1003');
  dnis: array[1..3] of string[10] = ('30111222', '31222333', '32333444');
  nombres: array[1..3] of string[60] = ('Ana Perez', 'Bruno Diaz', 'Carla Luna');
  carreras: array[1..3] of string[60] = ('Sistemas', 'Sistemas', 'Contador');
  promedios: array[1..3] of Real = (8.5, 7, 9);
  codigos: array[1..3] of string[10] = ('PROG01', 'COMU01', 'INGL01');
  titulos: array[1..3] of string[40] = ('Programacion', 'Comunicacion', 'Ingles');
  categorias: array[1..3] of string[30] = ('Tecnica', 'Blanda', 'Idioma');
procedure Comprobar(condicion: Boolean);
begin
  if not condicion then Halt(1);
  writeln('VERIFICADO');
end;
begin
  Assign(e, 'estudiantes.dat'); Rewrite(e);
  Assign(h, 'habilidades.dat'); Rewrite(h);
  FillChar(est, SizeOf(est), 0);
  for i := 1 to 3 do
  begin
    est.legajo := legajos[i]; est.dni := dnis[i];
    est.nombreApellido := nombres[i]; est.carrera := carreras[i];
    est.anioIngreso := 2020 + i; est.promedio := promedios[i];
    est.porcentajeAvance := 50; est.activo := True;
    Write(e, est);
  end;
  FillChar(hab, SizeOf(hab), 0);
  for i := 1 to 3 do
  begin
    hab.codigoHabilidad := codigos[i]; hab.nombre := titulos[i];
    hab.categoria := categorias[i]; hab.activa := True;
    Write(h, hab);
  end;
  accion := ParamStr(1);
  if accion = 'est-alta' then
  begin
    AltaEstudiante(e);
    Comprobar((FileSize(e) = 4) and (BuscarEstudiante(e, '1004', est) = 3));
    Comprobar((est.nombreApellido = 'Diego Sosa') and (est.anioIngreso = 2024) and est.activo);
  end
  else if accion = 'est-alta-nombre-vacio' then
  begin
    AltaEstudiante(e);
    Comprobar((FileSize(e) = 4) and (BuscarEstudiante(e, '1004', est) = 3));
    Comprobar(est.nombreApellido = '');
  end
  else if accion = 'est-alta-legajo-dup' then
  begin
    AltaEstudiante(e); Comprobar(FileSize(e) = 3);
  end
  else if accion = 'est-alta-dni-dup' then
  begin
    AltaEstudiante(e); Comprobar(FileSize(e) = 3);
  end
  else if accion = 'est-modificar-dni-ajeno' then
  begin
    ModificarEstudiante(e);
    Comprobar(BuscarEstudiante(e, '1002', est) = 1);
    Comprobar(est.dni = '31222333');
  end
  else if accion = 'est-modificar' then
  begin
    ModificarEstudiante(e);
    Comprobar(BuscarEstudiante(e, '1002', est) = 1);
    Comprobar((est.carrera = 'Ingenieria') and (est.dni = '31222333') and (FileSize(e) = 3));
  end
  else if accion = 'est-modificar-inexistente' then ModificarEstudiante(e)
  else if accion = 'est-baja' then
  begin
    BajaEstudiante(e);
    Comprobar((FileSize(e) = 3) and (BuscarEstudiante(e, '1003', est) = -1));
    Seek(e, 2); Read(e, est); Comprobar(not est.activo);
    ListarEstudiantes(e);
  end
  else if accion = 'est-baja-inexistente' then BajaEstudiante(e)
  else if accion = 'est-listar' then ListarEstudiantes(e)
  else if accion = 'est-listar-vacio' then
  begin
    Rewrite(e); ListarEstudiantes(e);
  end
  else if accion = 'est-clave-larga' then
  begin
    AltaEstudiante(e);
    Comprobar((FileSize(e) = 4) and (BuscarEstudiante(e, '1234567890', est) = 3));
    BajaEstudiante(e);
    Comprobar(BuscarEstudiante(e, '1234567890', est) = -1);
  end
  else if accion = 'est-reusar-legajo' then
  begin
    BajaEstudiante(e);
    AltaEstudiante(e);
    Comprobar((FileSize(e) = 4) and (BuscarEstudiante(e, '1003', est) = 3));
    Comprobar(est.nombreApellido = 'Fabio Sol');
  end
  else if accion = 'est-cargar' then
  begin
    CargarEstudiantes(e); Comprobar(FileSize(e) = 5);
  end
  else if accion = 'est-abrir' then
  begin
    CreateDir('docs');
    AbrirEstudiantes(aux); Comprobar(FileSize(aux) = 0);
    FillChar(est, SizeOf(est), 0);
    est.legajo := '2001'; est.activo := True;
    Seek(aux, 0); Write(aux, est); Close(aux);
    AbrirEstudiantes(aux);
    Comprobar((FileSize(aux) = 1) and (BuscarEstudiante(aux, '2001', est) = 0));
    Close(aux);
  end
  else if accion = 'est-abrir-sin-docs' then
  begin
    AbrirEstudiantes(aux); Comprobar(FileSize(aux) = 0); Close(aux);
  end
  else if accion = 'hab-alta' then
  begin
    AltaHabilidad(h);
    Comprobar((FileSize(h) = 4) and (BuscarHabilidad(h, 'REDE01', hab) = 3));
    Comprobar((hab.nombre = 'Redes') and hab.activa);
  end
  else if accion = 'hab-alta-dup' then
  begin
    AltaHabilidad(h); Comprobar(FileSize(h) = 3);
  end
  else if accion = 'hab-modificar' then
  begin
    ModificarHabilidad(h);
    Comprobar(BuscarHabilidad(h, 'COMU01', hab) = 1);
    Comprobar((hab.nombre = 'Oratoria') and (hab.categoria = 'Blanda') and (FileSize(h) = 3));
  end
  else if accion = 'hab-modificar-inexistente' then ModificarHabilidad(h)
  else if accion = 'hab-baja' then
  begin
    BajaHabilidad(h);
    Comprobar((FileSize(h) = 3) and (BuscarHabilidad(h, 'INGL01', hab) = -1));
    ListarHabilidades(h);
  end
  else if accion = 'hab-baja-inexistente' then BajaHabilidad(h)
  else if accion = 'hab-listar' then ListarHabilidades(h)
  else if accion = 'hab-listar-vacio' then
  begin
    Rewrite(h); ListarHabilidades(h);
  end
  else if accion = 'hab-clave-larga' then
  begin
    AltaHabilidad(h);
    Comprobar((FileSize(h) = 4) and (BuscarHabilidad(h, 'REDES12345', hab) = 3));
    BajaHabilidad(h);
    Comprobar(BuscarHabilidad(h, 'REDES12345', hab) = -1);
  end
  else Halt(2);
  Close(h); Close(e);
end.
