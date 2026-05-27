#!/bin/bash

# *************************************************************
#   procesar-suarez-asc.sh
#
#   Este script de bash linux toma un CSV con la tabla
#   de horarios de la línea Mitre ramales J.L.Suárez / B.Mitre
#   iniciada en Retiro y divide la tabla
#   en sus 2 ramales separados
#
#   uso: ./procesar-suarez-asc.sh mi-archivo.csv
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

TABLE1="RET-BMIT_ASC_.csv"
TABLE2="RET-JLSU_ASC_.csv"

# ==================== ENCABEZADOS ====================
head -n 1 "$INPUT_FILE" | awk -F, '
{
    print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12 > "'$TABLE1'"
    print $1,$2,$3,$4,$5,$6,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22 > "'$TABLE2'"
}' OFS=,

# ==================== DATOS + DIAGNÓSTICO ====================
echo "Procesando datos..."

tail -n +2 "$INPUT_FILE" | awk -F, '
{
    campo13 = $13
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", campo13)  # quita espacios al inicio y final

    if (campo13 == "" || NF < 13) {
        # Va a tabla1
        print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12 >> "'$TABLE1'"
        count1++
    } else {
        # Va a tabla2
        print $1,$2,$3,$4,$5,$6,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22 >> "'$TABLE2'"
        count2++

        # Muestra las primeras 3 líneas que van a tabla2 para debug
        if (count2 <= 3) {
            print "DEBUG - Línea a tabla2 | Campo13='" $13 "' | NF=" NF > "/dev/stderr"
        }
    }
} END {
    print "Total tabla1: " count1+1 > "/dev/stderr"
    print "Total tabla2: " count2+1 > "/dev/stderr"
}' OFS=,

echo ""
echo "✅ Proceso finalizado."
echo "   📁 tabla1.csv → $(wc -l < "$TABLE1") registros"
echo "   📁 tabla2.csv → $(wc -l < "$TABLE2") registros"
