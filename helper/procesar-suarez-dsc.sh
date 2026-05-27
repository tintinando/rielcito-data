#!/bin/bash

# *************************************************************
#   procesar-suarez-dsc.sh
#
#   Este script de bash linux toma un CSV con la tabla
#   de horarios de la línea Mitre ramales J.L.Suárez / B.Mitre
#   finalizada en Retiro y divide la tabla
#   en sus 2 ramales separados
#
#   uso: ./procesar-suarez-dsc.sh mi-archivo.csv
#
#   Una vez convertido agregar a los archivos
#   el sufijo de los días de la semana "LAV | SAB | DYF"
#
#   Ver nombres en la línea 32
#
# ************************************************************

INPUT_FILE="$1"

if [ -z "$INPUT_FILE" ]; then
    echo "Uso: $0 archivo.csv"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Archivo no encontrado: $INPUT_FILE"
    exit 1
fi

TABLE1="RET-JLSU_DSC_.csv"
TABLE2="RET_BMIT_DSC_.csv"

# ==================== ENCABEZADOS ====================
head -n 1 "$INPUT_FILE" | awk -F, '
{
    # Encabezado Tabla 1 (campo 12 vacío)
    print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$18,$19,$20,$21,$22 > "'$TABLE1'"

    # Encabezado Tabla 2 (campo 12 lleno)
    print $1,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22 > "'$TABLE2'"
}' OFS=,

# ==================== DATOS ====================
echo "Procesando datos..."

tail -n +2 "$INPUT_FILE" | awk -F, '
{
    # Limpiar campo 12 (quitar espacios)
    campo12 = $12
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", campo12)

    if (campo12 == "" || NF < 12) {
        # Campo 12 vacío → Tabla 1: 1,2,3,4,5,6,7,8,9,10,11,18,19,20,21,22
        print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$18,$19,$20,$21,$22 >> "'$TABLE1'"
        count1++
    } else {
        # Campo 12 lleno → Tabla 2: 1,12,13,14,15,16,17,18,19,20,21,22
        print $1,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22 >> "'$TABLE2'"
        count2++
    }
} END {
    print "Total tabla1: " count1+1 > "/dev/stderr"
    print "Total tabla2: " count2+1 > "/dev/stderr"
}' OFS=,

echo ""
echo "✅ Proceso finalizado."
echo "   📁 $TABLE1 → Campos: 1,2,3,4,5,6,7,8,9,10,11,18,19,20,21,22  ($(wc -l < "$TABLE1") registros)"
echo "   📁 $TABLE2 → Campos: 1,12,13,14,15,16,17,18,19,20,21,22     ($(wc -l < "$TABLE2") registros)"
