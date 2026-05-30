#!/bin/bash

# Validar que se pasen los argumentos necesarios
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 archivo_entrada.csv archivo_salida.csv"
    exit 1
fi

ARCHIVO_ENTRADA="$1"
ARCHIVO_SALIDA="$2"

# Procesar el CSV con awk
awk -F, '$12 != "BQ"' "$ARCHIVO_ENTRADA" > "$ARCHIVO_SALIDA"

echo "Procesamiento completado. Filas filtradas guardadas en: $ARCHIVO_SALIDA"
