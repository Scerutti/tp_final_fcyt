unit UnitPresentacion;

interface

procedure MostrarPresentacion;
procedure MostrarMenu(titulo: string; opciones: array of string; opcionSalida: string);
procedure MostrarTituloSeccion(seccion, titulo: string);
procedure MostrarAviso(mensaje: string);
procedure Pausa;
procedure MostrarDespedida;

implementation

uses
  Crt;

const
  MARGEN = 3;
  ANCHO = 70;
  ANCHO_LOGO = 58;
  LARGO_BARRA = 40;
  COLOR_BORDE = LightBlue;
  TEXTO_SUPERIOR = 'LSI - Fundamentos de Programacion 2026';
  TEXTO_INFERIOR = 'UADER - FCyT - Concepcion del Uruguay';

  LOGO: array[1..5, 1..5] of string[5] = (
    ('#   #', '#   #', '#   #', '#   #', ' ### '),
    (' ### ', '#   #', '#####', '#   #', '#   #'),
    ('#### ', '#   #', '#   #', '#   #', '#### '),
    ('#####', '#    ', '#### ', '#    ', '#####'),
    ('#### ', '#   #', '#### ', '#  # ', '#   #')
  );

  COLORES_LOGO: array[1..5] of Byte = (LightGray, Cyan, Cyan, Blue, Blue);

function Repetir(c: Char; n: Integer): string;
var
  s: string;
  i: Integer;
begin
  s := '';
  for i := 1 to n do
    s := s + c;
  Repetir := s;
end;

procedure IrMargen;
begin
  TextBackground(Black);
  write('': MARGEN);
end;

procedure AbrirLinea;
begin
  IrMargen;
  TextColor(COLOR_BORDE);
  write('|');
end;

procedure CerrarLinea(usados: Integer);
begin
  TextBackground(Black);
  if usados < ANCHO then
    write('': ANCHO - usados);
  TextColor(COLOR_BORDE);
  writeln('|');
end;

procedure LineaVacia;
begin
  AbrirLinea;
  CerrarLinea(0);
end;

procedure Borde(relleno: Char; texto: string);
var
  resto: Integer;
begin
  IrMargen;
  TextColor(COLOR_BORDE);
  if texto = '' then
    write('+', Repetir(relleno, ANCHO), '+')
  else
  begin
    texto := ' ' + texto + ' ';
    resto := ANCHO - Length(texto);
    write('+', Repetir(relleno, resto div 2));
    TextColor(LightGray);
    write(texto);
    TextColor(COLOR_BORDE);
    write(Repetir(relleno, resto - resto div 2), '+');
  end;
end;

procedure LineaCentrada(texto: string; color: Byte);
var
  izquierda: Integer;
begin
  AbrirLinea;
  izquierda := (ANCHO - Length(texto)) div 2;
  write('': izquierda);
  TextColor(color);
  write(texto);
  CerrarLinea(izquierda + Length(texto));
end;

procedure DibujarFilaLogo(fila: Integer);
var
  letra, i, izquierda: Integer;
  linea: string;
begin
  AbrirLinea;
  izquierda := (ANCHO - ANCHO_LOGO) div 2;
  write('': izquierda);
  for letra := 1 to 5 do
  begin
    linea := LOGO[letra, fila];
    for i := 1 to Length(linea) do
    begin
      if linea[i] = '#' then
        TextBackground(COLORES_LOGO[fila])
      else
        TextBackground(Black);
      write('  ');
    end;
    TextBackground(Black);
    if letra < 5 then
      write('  ');
  end;
  CerrarLinea(izquierda + ANCHO_LOGO);
end;

procedure DibujarLogo(animado: Boolean);
var
  fila: Integer;
begin
  for fila := 1 to 5 do
  begin
    DibujarFilaLogo(fila);
    if animado then
      Delay(90);
  end;
end;

procedure DibujarSubtitulo;
begin
  LineaCentrada('T   A   L   E   N   T   S', Yellow);
  LineaCentrada('Base de Talentos  |  Perfiles para proyectos y desafios', LightGray);
end;

procedure DibujarPie;
var
  izquierda, largo: Integer;
begin
  largo := Length('Hecho por:   * Cerutti, Sebastian     * Martinez, Facundo');
  AbrirLinea;
  izquierda := (ANCHO - largo) div 2;
  write('': izquierda);
  TextColor(DarkGray);
  write('Hecho por:   ');
  TextColor(Yellow);
  write('*');
  TextColor(White);
  write(' Cerutti, Sebastian     ');
  TextColor(Yellow);
  write('*');
  TextColor(White);
  write(' Martinez, Facundo');
  CerrarLinea(izquierda + largo);
end;

procedure DibujarBarraTitulo(titulo: string);
var
  texto: string;
begin
  AbrirLinea;
  texto := '  >>  ' + titulo;
  TextBackground(Blue);
  TextColor(White);
  write(texto, '': ANCHO - Length(texto));
  CerrarLinea(ANCHO);
end;

procedure DibujarOpcion(numero: Integer; texto: string; fondo, colorTexto: Byte);
begin
  AbrirLinea;
  write('': 8);
  TextBackground(fondo);
  TextColor(White);
  write(' ', numero, ' ');
  TextBackground(Black);
  TextColor(colorTexto);
  write('   ', texto);
  CerrarLinea(8 + 3 + 3 + Length(texto));
end;

procedure MostrarPresentacion;
var
  i, izquierda, columna, fila, filaFinal: Integer;
begin
  CursorOff;
  TextBackground(Black);
  ClrScr;
  Borde('=', TEXTO_SUPERIOR);
  writeln;
  LineaVacia;
  DibujarLogo(True);
  LineaVacia;
  DibujarSubtitulo;
  LineaVacia;
  LineaCentrada('Cargando base de talentos...', DarkGray);
  AbrirLinea;
  izquierda := (ANCHO - LARGO_BARRA) div 2;
  write('': izquierda);
  columna := WhereX;
  fila := WhereY;
  TextColor(DarkGray);
  write(Repetir('.', LARGO_BARRA));
  CerrarLinea(izquierda + LARGO_BARRA);
  LineaVacia;
  Borde('-', '');
  writeln;
  DibujarPie;
  Borde('=', TEXTO_INFERIOR);
  writeln;
  filaFinal := WhereY;
  TextBackground(Cyan);
  for i := 0 to LARGO_BARRA - 1 do
  begin
    GotoXY(columna + i, fila);
    write(' ');
    Delay(25);
  end;
  TextBackground(Black);
  GotoXY(1, filaFinal);
  writeln;
  IrMargen;
  TextColor(LightGreen);
  write('>> ');
  TextColor(White);
  write('Presione ENTER para comenzar...');
  CursorOn;
  readln;
end;

procedure MostrarMenu(titulo: string; opciones: array of string; opcionSalida: string);
var
  i, columna, fila: Integer;
begin
  TextBackground(Black);
  ClrScr;
  Borde('=', TEXTO_SUPERIOR);
  writeln;
  LineaVacia;
  DibujarLogo(False);
  LineaVacia;
  DibujarSubtitulo;
  Borde('-', '');
  writeln;
  DibujarBarraTitulo(titulo);
  LineaVacia;
  for i := 0 to High(opciones) do
    DibujarOpcion(i + 1, opciones[i], Cyan, White);
  DibujarOpcion(0, opcionSalida, Red, LightGray);
  LineaVacia;
  Borde('-', '');
  writeln;
  AbrirLinea;
  write('  ');
  TextColor(LightGreen);
  write('>>');
  TextColor(White);
  write(' Ingrese una opcion: ');
  columna := WhereX;
  fila := WhereY;
  CerrarLinea(2 + 2 + Length(' Ingrese una opcion: '));
  Borde('-', '');
  writeln;
  DibujarPie;
  Borde('=', TEXTO_INFERIOR);
  GotoXY(columna, fila);
  TextColor(Yellow);
end;

procedure MostrarTituloSeccion(seccion, titulo: string);
begin
  TextBackground(Black);
  ClrScr;
  Borde('=', 'UADERTalents');
  writeln;
  AbrirLinea;
  write('  ');
  TextColor(Yellow);
  write('* ', seccion);
  TextColor(DarkGray);
  write(' >> ');
  TextColor(White);
  write(titulo);
  CerrarLinea(2 + 2 + Length(seccion) + 4 + Length(titulo));
  Borde('=', '');
  writeln;
  writeln;
  TextColor(LightGray);
end;

procedure MostrarAviso(mensaje: string);
begin
  MostrarTituloSeccion('AVISO', 'Atencion');
  IrMargen;
  TextColor(LightRed);
  writeln('! ', mensaje);
  Pausa;
end;

procedure Pausa;
begin
  writeln;
  IrMargen;
  TextColor(DarkGray);
  writeln(Repetir('-', ANCHO + 2));
  IrMargen;
  TextColor(LightGreen);
  write('>> ');
  TextColor(White);
  write('Presione ENTER para continuar...');
  readln;
  TextColor(LightGray);
end;

procedure MostrarDespedida;
begin
  TextBackground(Black);
  ClrScr;
  Borde('=', TEXTO_SUPERIOR);
  writeln;
  LineaVacia;
  DibujarLogo(False);
  LineaVacia;
  LineaCentrada('Gracias por utilizar UADERTalents', Yellow);
  LineaCentrada('Hasta la proxima!', LightGray);
  LineaVacia;
  Borde('-', '');
  writeln;
  DibujarPie;
  Borde('=', TEXTO_INFERIOR);
  writeln;
  writeln;
  NormVideo;
end;

end.
