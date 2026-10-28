unit UnitUtilidades;

interface

const
  MARGEN = 3;
  ANCHO = 100;
  FILAS_POR_PAGINA = 10;

function Repetir(c: Char; n: Integer): string;
function Ajustar(texto: string; largo: Integer): string;
function RealATexto(valor: Real): string;
function LeerEntero(mensaje: string; minimo, maximo: LongInt): LongInt;
function LeerReal(mensaje: string; minimo, maximo: Real): Real;
function Confirmar(pregunta: string): Boolean;
procedure MostrarDato(etiqueta, valor: string);
procedure LineaTabla(anchos: array of Integer);
procedure FilaTabla(textos: array of string; anchos: array of Integer);
procedure EncabezadoTabla(titulos: array of string; anchos: array of Integer);
procedure AgregarFila(textos, titulos: array of string; anchos: array of Integer; var filas: Integer);
procedure CerrarTabla(anchos: array of Integer; filas: Integer);

implementation

uses
  SysUtils;

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

function Ajustar(texto: string; largo: Integer): string;
begin
  if Length(texto) > largo then
    Ajustar := Copy(texto, 1, largo)
  else
    Ajustar := texto + Repetir(' ', largo - Length(texto));
end;

function RealATexto(valor: Real): string;
var
  s: string;
begin
  Str(valor:0:2, s);
  RealATexto := s;
end;

function LeerEntero(mensaje: string; minimo, maximo: LongInt): LongInt;
var
  entrada: string;
  valor, error: LongInt;
  valido: Boolean;
begin
  repeat
    write(mensaje);
    readln(entrada);
    Val(Trim(entrada), valor, error);
    valido := (error = 0) and (valor >= minimo) and (valor <= maximo);
    if not valido then
      writeln('Ingrese un numero entero entre ', minimo, ' y ', maximo, '.');
  until valido;
  LeerEntero := valor;
end;

function LeerReal(mensaje: string; minimo, maximo: Real): Real;
var
  entrada: string;
  valor: Real;
  error: LongInt;
  valido: Boolean;
begin
  repeat
    write(mensaje);
    readln(entrada);
    Val(Trim(entrada), valor, error);
    valido := (error = 0) and (valor >= minimo) and (valor <= maximo);
    if not valido then
      writeln('Ingrese un numero entre ', minimo:0:2, ' y ', maximo:0:2, ' usando punto decimal.');
  until valido;
  LeerReal := valor;
end;

function Confirmar(pregunta: string): Boolean;
var
  respuesta: string;
begin
  repeat
    write(pregunta, ' (S/N): ');
    readln(respuesta);
    respuesta := UpperCase(Trim(respuesta));
    if (respuesta <> 'S') and (respuesta <> 'N') then
      writeln('Responda S o N.');
  until (respuesta = 'S') or (respuesta = 'N');
  Confirmar := respuesta = 'S';
end;

procedure MostrarDato(etiqueta, valor: string);
begin
  writeln('': MARGEN, Ajustar(etiqueta, 22), ': ', valor);
end;

procedure LineaTabla(anchos: array of Integer);
var
  linea: string;
  i: Integer;
begin
  linea := '+';
  for i := 0 to High(anchos) do
    linea := linea + Repetir('-', anchos[i] + 2) + '+';
  writeln('': MARGEN, linea);
end;

procedure FilaTabla(textos: array of string; anchos: array of Integer);
var
  linea: string;
  i: Integer;
begin
  linea := '|';
  for i := 0 to High(anchos) do
    linea := linea + ' ' + Ajustar(textos[i], anchos[i]) + ' |';
  writeln('': MARGEN, linea);
end;

procedure EncabezadoTabla(titulos: array of string; anchos: array of Integer);
begin
  LineaTabla(anchos);
  FilaTabla(titulos, anchos);
  LineaTabla(anchos);
end;

procedure AgregarFila(textos, titulos: array of string; anchos: array of Integer; var filas: Integer);
begin
  if filas = 0 then
    EncabezadoTabla(titulos, anchos)
  else if filas mod FILAS_POR_PAGINA = 0 then
  begin
    LineaTabla(anchos);
    write('': MARGEN, 'Presione ENTER para ver la pagina siguiente...');
    readln;
    writeln;
    EncabezadoTabla(titulos, anchos);
  end;
  FilaTabla(textos, anchos);
  filas := filas + 1;
end;

procedure CerrarTabla(anchos: array of Integer; filas: Integer);
begin
  LineaTabla(anchos);
  writeln('': MARGEN, 'Total: ', filas);
end;

end.
