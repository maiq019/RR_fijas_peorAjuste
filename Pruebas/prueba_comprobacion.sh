#!/bin/bash

# Nos permite saber si el parámetro pasado es entero mayor que 0.
mayor_cero()
{
    [ "$1" -eq "$1" -a "$1" -gt "0" ] > /dev/null 2>&1  # En caso de error, sentencia falsa (Compara variables como enteros)
    return $?                           				# Retorna si la sentencia anterior fue verdadera
}

echo -n " Introduce tamaño máximo de partición: "
read tam_par_max_efec

echo -n " Introduce la memoria mínima de los procesos: "
read memo_proc_min

###  COMPROBACIÓN DE MEMORIA MÍNIMA MAYOR QUE CERO Y MENOR QUE TAMAÑO DE PARTICIONES  ###

#He fusionado las comprobaciones de mayor que cero y menor que partición máxima para evitar la situación que se daba al poder introducir un
#valor correcto mayor que cero primero, pero luego un valor "correcto" menor que la partición máxima pero menor que 0 o directamente no un número.
while ! mayor_cero $memo_proc_min || [ $memo_proc_min -gt $tam_par_max_efec ]
do
	if ! mayor_cero $memo_proc_min 	#He añadido una explicación más detallada del error de introducción de opción.
	then
        echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo -n " Introduce la memoria mínima de los procesos: "
    	read memo_proc_min
	else #Si la memoria mínima de los procesos es mayor que la mayor partición
		echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
		echo -n " Introduce la memoria mínima de los procesos: "
    	read memo_proc_min
	fi
done

read -p " Memoria mínima: $memo_proc_min" x