# Diseño de Registro del Repositorio CSV

## Formato general

- Codificación: **UTF-8**
- Fin de línea: **LF**

---

## Tablas de referencia

### RAMALES

Contiene los identificadores y nombres comunes de los ramales.

| Campo | Descripción |
|-------|-------------|
| `id` | Identificador del ramal |
| `nombre` | Nombre común del ramal |
| `cabecera` | Estación cabecera (referencia para dirección ascendente) |

### ESTACIONES

Contiene el identificador de cada estación y sus datos asociados.

| Campo | Descripción |
|-------|-------------|
| `id` | Identificador de la estación |
| `...` | Otros datos de la estación |

### ESTACION_RAMAL

Relaciona estaciones con ramales. Cuando una estación pertenece a más de un ramal, se repite en un nuevo registro.

| Campo | Descripción |
|-------|-------------|
| `id_estacion` | Identificador de la estación |
| `id_ramal` | Identificador del ramal al que pertenece |

---

## Tablas de horarios

### Estructura

- **Encabezados:** campo `SERVICIOS` seguido de los `id` de las estaciones.
- **Registros:** número de tren y horarios de llegada a cada estación en formato `HH:MM` (horario local).

### Nomenclatura de archivos

```
[idRamal]_[direccion]_[dia_semana]
```

| Segmento | Valores | Descripción |
|----------|---------|-------------|
| `idRamal` | Según tabla RAMALES | Identificador del ramal |
| `direccion` | `ASC` \| `DSC` | `ASC` = ascendente (comienza en la cabecera definida en RAMALES); `DSC` = descendente |
| `dia_semana` | `LAV` \| `SAB` \| `DYF` \| `DDMMYYYY` | Lunes a viernes / Sábado / Domingos y feriados / Fecha para cronograma especial |

### Cronograma especial

Cuando `dia_semana` es una fecha (`DDMMYYYY`), el archivo corresponde a un cronograma especial (por evento o por obras). En ese caso, el **primer registro** debe ser un registro de metadatos identificado con la palabra reservada `METADATA`.

**Formato del registro METADATA:**

```
METADATA,CLAVE:valor
```

**Valores posibles:**

| Clave | Descripción | Ejemplo |
|-------|-------------|---------|
| `MENSAJE` | Mensaje informativo sobre el cronograma especial | `METADATA,MENSAJE:Los trenes tienen un horario especial por obras` |
