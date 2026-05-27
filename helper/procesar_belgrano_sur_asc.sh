#!/bin/bash


# *********************************************************
#   procesar_belgrano_sur_asc.sh
#
#   Este script de bash linux toma un CSV con la tabla
#   de horarios de la línea Belgrano Sur iniciada en Saenz
#   y divide la tabla en sus 2 ramales separados
#
#   uso: ./procesar_belgrano_sur_asc.sh mi-archivo.csv
#
#   Una vez convertido agregar a los archivos
#   el sufijo de los días de la semana "LAV | SAB | DYF"
#
#   Ver nombres en la línea 32
#
# **********************************************************

INPUT_FILE="$1"

if [ -z "$INPUT_FILE" ]; then
    echo "Uso: $0 archivo.csv"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: No se encontró el archivo $INPUT_FILE"
    exit 1
fi

TABLE1="SAE-MCGB_ASC_V1.csv"
TABLE2="SAE-CATA_ASC_V1.csv"

echo "Procesando $INPUT_FILE ..."

# ==================== ENCABEZADOS ====================
head -n 1 "$INPUT_FILE" | awk -F, '
{
    # Tabla 1 → Campo 9 vacío
    print $1,$8,$15,$16,$17,$18,$19,$20,$21,$22,$23 > "'$TABLE1'"

    # Tabla 2 → Campo 9 lleno
    print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14 > "'$TABLE2'"
}' OFS=,

# ==================== DATOS ====================
tail -n +2 "$INPUT_FILE" | awk -F, '
{
    # Limpiar campo 9 (quitar espacios al inicio y final)
    campo9 = $9
    gsub(/^[ \t]+|[ \t]+$/, "", campo9)

    if (campo9 == "" || NF < 9) {
        # Campo 9 vacío → Tabla 1
        print $1,$8,$15,$16,$17,$18,$19,$20,$21,$22,$23 >> "'$TABLE1'"
    } else {
        # Campo 9 lleno → Tabla 2
        print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14 >> "'$TABLE2'"
    }
}' OFS=,

# ==================== RESULTADO ====================
echo ""
echo "✅ Proceso terminado correctamente."
echo "   📁 $TABLE1 → Campos: 1,8,15,16,17,18,19,20,21,22,23     ($(wc -l < "$TABLE1") registros)"
echo "   📁 $TABLE2 → Campos: 1,2,3,4,5,6,7,8,9,10,11,12,13,14   ($(wc -l < "$TABLE2") registros)"
