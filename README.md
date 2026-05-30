# rielcito-data

Repositorio de datos públicos con los horarios de los trenes de Argentina, estructurados en archivos CSV normalizados y versionados.

> Este repositorio **solo contiene datos**. No hay frontend ni lógica de aplicación acá.

---

## Estructura del repositorio

```
rielcito-data/
├── data/                        # Archivos CSV con los horarios
├── helpers/                     # Scripts bash para manipulación de datos
│   └── ...
├── diseño-de-registro.md        # Especificación del esquema de las tablas CSV
├── manifest.json                # SHA256 de cada archivo CSV + fecha de última modificación
└── crear-manifest.py            # Script que genera el manifest.json automáticamente
```

---

## Archivos de datos (`data/`)

Los archivos CSV siguen el esquema definido en [`diseño-de-registro.md`](./diseño-de-registro.md), que establece los campos, tipos de dato y convenciones de cada tabla.

Los archivos son datos crudos y normalizados: sin formato especial, sin fórmulas, sin celdas fusionadas. Pensados para ser consumidos por cualquier herramienta que lea CSV estándar.

---

## Manifest (`manifest.json`)

El archivo `manifest.json` se genera automáticamente y contiene:

- El hash **SHA256** de cada archivo CSV en `data/`
- El campo `updatedAt` con la fecha de la última modificación de cada archivo

Se usa para detectar cambios, verificar integridad y sincronizar versiones del lado del consumidor.

### Generación manual

```bash
python crear-manifest.py
```

### Generación automática

El manifest se regenera automáticamente en cada push mediante una GitHub Action definida en `.github/workflows/`. No es necesario ejecutarlo a mano salvo para pruebas locales.

---

## Diseño de registro (`diseño-de-registro.md`)

Define la estructura de las tablas CSV: qué columnas tiene cada archivo, qué tipo de dato contiene cada campo, qué valores son válidos y cómo se representan casos especiales (por ejemplo, trenes que no paran en todas las estaciones, servicios especiales, frecuencias variables).

**Antes de modificar cualquier CSV o agregar un archivo nuevo, leer este documento.**

---

## Helpers (`helpers/`)

Carpeta con scripts bash para automatizar tareas comunes al traducir la información oficial publicada por los operadores ferroviarios al formato de los CSV.

Los scripts están pensados para correr en entornos GNU/Linux o macOS. En Windows se puede usar WSL.

Cada script tiene comentarios en el encabezado explicando qué hace, qué parámetros recibe y un ejemplo de uso.

---

## Cómo contribuir

1. Leer [`diseño-de-registro.md`](./diseño-de-registro.md) para entender el esquema.
2. Modificar o agregar los CSV correspondientes en `data/`.
3. Correr `python crear-manifest.py` para actualizar el manifest localmente.
4. Abrir un pull request con una descripción clara del cambio (qué línea, qué servicio, qué período).

Si encontrás un error en los datos o un horario desactualizado, podés abrir un issue detallando el problema y la fuente oficial de referencia.

---

## Fuentes

Los datos se obtienen de las tablas de horarios publicadas oficialmente por los operadores y organismos ferroviarios. Cada modificación debería referenciar la fuente en el mensaje del commit o en el PR.

---

## Licencia

Los datos son de carácter público. Consultar el archivo [`LICENSE`](./LICENSE) para los términos de uso de este repositorio.
