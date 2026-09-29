unit TiposGlobales;

interface

type
  TEstudiante = record
    legajo: string[10];
    dni: string[10];
    nombreApellido: string[60];
    carrera: string[60];
    anioIngreso: Word;
    promedio: Real;
    porcentajeAvance: Real;
    activo: Boolean;
  end;
  FileEstudiantes = file of TEstudiante;

  THabilidad = record
    codigoHabilidad: string[10];
    nombre: string[40];
    categoria: string[30];
    activa: Boolean;
  end;
  FileHabilidades = file of THabilidad;

  TCompetencia = record
    legajoEstudiante: string[10];
    codigoHabilidad: string[10];
    nivelDominio: Byte;
    activa: Boolean;
  end;
  FileCompetencias = file of TCompetencia;

implementation

end.
