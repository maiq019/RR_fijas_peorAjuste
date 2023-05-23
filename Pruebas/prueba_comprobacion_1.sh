#!/bin/bash

imprime_cabecera()
{
	echo -e "$colorRecuadro┌─────────────────────────────────────────────────────────────────────┐"
	echo -e "$colorRecuadro│    $colorTexto Round-Robin, particiones fijas no iguales al peor ajuste.       $colorRecuadro│"			
	echo -e "$colorRecuadro│     $colorTexto Mario Juez Gil, Omar Santos, Alvaro Urdiales Santidria,        $colorRecuadro│"
	echo -e "$colorRecuadro│           $colorTexto Gonzalo Burgos de la Hera, Lucas Olmedo Díez             $colorRecuadro│"
	echo -e "$colorRecuadro│                       $colorTexto Miguel Díaz Hernando                         $colorRecuadro│"
	echo -e "$colorRecuadro│                        $colorTexto Versión Junio 2023                          $colorRecuadro│"
	echo -e "$colorRecuadro└─────────────────────────────────────────────────────────────────────┘ $resetColor"
}

imprime_info_datos_aleatorios()
{
	echo ""
	echo -e " Número de particiones: $n_par_min - $n_par_max -> $n_par\n"
	echo -e " Número de particiones: $n_par_min - $n_par_max -> $n_par\n" >> informeCOLOR.txt
	echo -e " Número de particiones: $n_par_min - $n_par_max -> $n_par\n" >> informeBN.txt

	echo -e " Tamaño de particiones: $tam_par_min - $tam_par_max -> $tam_par\n"
	echo -e " Tamaño de particiones: $tam_par_min - $tam_par_max -> $tam_par\n" >> informeCOLOR.txt
	echo -e " Tamaño de particiones: $tam_par_min - $tam_par_max -> $tam_par\n" >> informeBN.txt	

	echo -e " Quantum: 	        $quantum_min - $quantum_max -> $quantum\n"
	echo -e " Quantum: 	        $quantum_min - $quantum_max -> $quantum\n" >> informeCOLOR.txt
	echo -e " Quantum:	        $quantum_min - $quantum_max -> $quantum\n" >> informeBN.txt		
	
	echo ""
	echo " Datos de los procesos"
	echo ""
	echo " Número de procesos:	$num_proc_min - $num_proc_max -> $contador_proc"
	echo " Tiempo de llegada:	$entrada_min - $entrada_max"
	echo " Tiempo de ejecución:	$rafaga_min - $rafaga_max"
	echo " Memoria a ocupar: 	$memo_proc_min - $memo_proc_max"
	echo ""
	echo " Ref Tll Tej Mem"
	echo " ---------------"
	echo "Los procesos introducidos hasta ahora son: " >> informeCOLOR.txt
	echo " Ref Tll Tej Mem" >> informeCOLOR.txt
	echo " ---------------" >> informeCOLOR.txt
	echo "Los procesos introducidos hasta ahora son: " >> informeBN.txt
	echo " Ref Tll Tej Mem" >> informeBN.txt
	echo " ---------------" >> informeBN.txt
}

# Nos permite saber si el parámetro pasado es entero mayor que 0.
mayor_cero()
{
    [ "$1" -eq "$1" -a "$1" -gt "0" ] > /dev/null 2>&1  # En caso de error, sentencia falsa (Compara variables como enteros)
    return $?                           				# Retorna si la sentencia anterior fue verdadera
}

comprobar()
{
	while ! mayor_cero $1
	do
		echo $3
		echo $3 >> informeCOLOR.txt
		echo $3 >> informeBN.txt
		echo -n $4
		echo -n $4 >> informeCOLOR.txt
		echo -n $4 >> informeBN.txt
		read $2
		echo $1 >> informeCOLOR.txt
		echo $1 >> informeBN.txt
	done
}

comprobar_rango()
{
	while [ $1 -lt $3 ] #Límite máximo inferior al mínimo.
	do
		echo $4
		echo $4 >> informeCOLOR.txt
		echo $4 >> informeBN.txt
		echo -n $5
		echo -n $5 >> informeCOLOR.txt
		echo -n $5 >> informeBN.txt
	    read $2
		echo $1 >> informeCOLOR.txt
		echo $1 >> informeBN.txt
	done
}

###  MÉTODO DE GUARDADO  ###


#Guardado de datos en ficheros destinados a datos aleatorios con rango.
imprime_cabecera
echo  " ¿Dónde guardar los rangos?"
echo  " ¿Dónde guardar los rangos?" >> informeCOLOR.txt
echo  " ¿Dónde guardar los rangos?" >> informeBN.txt
echo  " 1- Fichero de rangos de última ejecución (datosrangos.txt)"
echo  " 1- Fichero de rangos de última ejecución (datosrangos.txt)" >> informeCOLOR.txt
echo  " 1- Fichero de rangos de última ejecución (datosrangos.txt)" >> informeBN.txt
echo  " 2- Otros ficheros de rangos"
echo  " 2- Otros ficheros de rangos" >> informeCOLOR.txt
echo  " 2- Otros ficheros de rangos" >> informeBN.txt

read opcion_guardado_aleatorio

#He añadido una explicación más detallada del error de introducción de opción.
while [ "${opcion_guardado_aleatorio}" != "1" -a "${opcion_guardado_aleatorio}" != "2" ] #Lectura errónea.
do
	echo "Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los rangos?"
	read opcion_guardado_aleatorio
done

echo $opcion_guardado_aleatorio >> informeCOLOR.txt
echo $opcion_guardado_aleatorio >> informeBN.txt

#Si se guarda en otro fichero, pregunta el nombre.
if [ "${opcion_guardado_aleatorio}" == "2" ]
then
	echo  " Nombre del nuevo fichero con rangos: (No poner .txt)"
	echo  " Nombre del nuevo fichero con rangos: (No poner .txt)" >> informeCOLOR.txt
	echo  " Nombre del nuevo fichero con rangos: (No poner .txt)" >> informeBN.txt
	read nombre_fichero_aleatorio
fi

clear
imprime_cabecera
echo  " ¿Dónde guardar los datos?"
echo  " ¿Dónde guardar los datos?" >> informeCOLOR.txt
echo  " ¿Dónde guardar los datos?" >> informeBN.txt
echo  " 1- Fichero de datos de última ejecución (datos.txt)"
echo  " 1- Fichero de datos de última ejecución (datos.txt)" >> informeCOLOR.txt
echo  " 1- Fichero de datos de última ejecución (datos.txt)" >> informeBN.txt
echo  " 2- Otros ficheros de datos"
echo  " 2- Otros ficheros de datos" >> informeCOLOR.txt
echo  " 2- Otros ficheros de datos" >> informeBN.txt


read opcion_guardado_aleatorio_datos

while [ "${opcion_guardado_aleatorio_datos}" != "1" -a "${opcion_guardado_aleatorio_datos}" != "2" ] #Lectura errónea.
do
	echo " Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los datos?"
	read opcion_guardado_aleatorio_datos
done

echo $opcion_guardado_aleatorio_datos >> informeCOLOR.txt
echo $opcion_guardado_aleatorio_datos >> informeBN.txt

#Si se guarda en otro fichero, pregunta el nombre.
if [ "${opcion_guardado_aleatorio_datos}" == "2" ]
then
	echo  " Nombre del nuevo fichero con datos: (No poner .txt)"
	echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> informeCOLOR.txt
	echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> informeBN.txt
	read nombre_fichero
fi


###  PARTICIONES Y QUANTUM  ###


###  NÚMERO DE PARTICIONES MÍNIMO  ###

clear
imprime_cabecera
imprime_info_datos_aleatorios
echo -n " Introduzca numero de particiones mínimo: "
echo -n " Introduzca numero de particiones mínimo: " >> informeCOLOR.txt
echo -n " Introduzca numero de particiones mínimo: " >> informeBN.txt
read n_par_min
echo $n_par_min >> informeCOLOR.txt
echo $n_par_min >> informeBN.txt

comprobar $n_par_min n_par_min " Entrada no válida, por favor, introduce un número natural mayor que cero" " Introduzca numero de particiones mínimo:"

###  NÚMERO DE PARTICIONES MÁXIMO  ###

clear
imprime_cabecera
imprime_info_datos_aleatorios
echo -n " Introduzca numero de particiones máximo: "
echo -n " Introduzca numero de particiones máximo: " >> informeCOLOR.txt
echo -n " Introduzca numero de particiones máximo: " >> informeBN.txt
read n_par_max
echo $n_par_max >> informeCOLOR.txt
echo $n_par_max >> informeBN.txt

comprobar $n_par_max n_par_max {" Entrada no válida, por favor, introduce un número natural mayor que cero"} {" Introduzca numero de particiones máximo: "}

###  COMPROBACIÓN DE RANGOS DE NÚMERO DE PARTICIONES  ###

comprobar_rango $n_par_max n_par_max $num_par_min {" Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"} {" Introduzca numero de particiones máximo: "}

#Asignación aleatoria del número de particiones en el rango.
n_par=`shuf -i $n_par_min-$n_par_max -n 1`

###  TAMAÑO DE PARTICIONES MÍNIMO  ###

clear
imprime_cabecera
imprime_info_datos_aleatorios
echo -n " Introduce tamaño de particiones mínimo: "
echo -n " Introduce tamaño de particiones mínimo: " >> informeCOLOR.txt
echo -n " Introduce tamaño de particiones mínimo: " >> informeBN.txt
read tam_par_min
echo $tam_par_min >> informeCOLOR.txt
echo $tam_par_min >> informeBN.txt

comprobar $tam_par_min tam_par_min {" Entrada no válida, por favor, introduce un número natural mayor que cero"} {" Introduzca tamaño de particiones mínimo: "}

###  TAMAÑO DE PARTICIONES MÁXIMO  ###

clear
imprime_cabecera
imprime_info_datos_aleatorios
echo -n " Introduce tamaño de particiones máximo: "
echo -n " Introduce tamaño de particiones máximo: " >> informeCOLOR.txt
echo -n " Introduce tamaño de particiones máximo: " >> informeBN.txt
read tam_par_max
echo $tam_par_max >> informeCOLOR.txt
echo $tam_par_max >> informeBN.txt

comprobar $tam_par_max tam_par_max {" Entrada no válida, por favor, introduce un número natural mayor que cero"} {" Introduzca tamaño de particiones máximo: "}

###  COMPROBACIÓN DE RANGOS DE TAMAÑO DE PARTICIONES  ###

comprobar_rango $tam_par_max tam_par_max $tam_par_min {" Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"} {" Introduzca tamaño de particiones máximo: "}

#Asignación aleatoria del tamaño de particiones en el rango.
tam_par=`shuf -i $tam_par_min-$tam_par_max -n 1`


###  QUANTUM  ###


###  QUÁNTUM MÍNIMO  ###

clear
imprime_cabecera
imprime_info_datos_aleatorios		
echo -n " Introduce el quantum de ejecución mínimo: "
echo -n " Introduce el quantum de ejecución mínimo: " >> informeCOLOR.txt
echo -n " Introduce el quantum de ejecución mínimo: " >> informeBN.txt
read quantum_min
echo $quantum_min >> informeCOLOR.txt
echo $quantum_min >> informeBN.txt

comprobar $quantum_min quantum_min {" Entrada no válida, por favor, introduce un número natural mayor que cero"} {" Introduce el quantum de ejecución mínimo: "}

###  QUÁNTUM MÁXIMO  ###

clear
imprime_cabecera
imprime_info_datos_aleatorios
echo -n " Introduce el quantum de ejecución máximo: "
echo -n " Introduce el quantum de ejecución máximo: " >> informeCOLOR.txt
echo -n " Introduce el quantum de ejecución máximo: " >> informeBN.txt
read quantum_max
echo $quantum_max >> informeCOLOR.txt
echo $quantum_max >> informeBN.txt

comprobar $quantum_max quantum_max {" Entrada no válida, por favor, introduce un número natural mayor que cero"} {" Introduce el quantum de ejecución máximo: "}

###  COMPROBACIÓN DE RANGOS DE QUÁNTUM  ###

comprobar_rango $quantum_max quantum_max $quantum_min {" Entrada no válida, por favor, introduce un número natural mayor que cero"} {" Introduce el quantum de ejecución máximo: "}

#Asignación aleatoria del quántum en el rango.
quantum=`shuf -i $quantum_min-$quantum_max -n 1`

clear
imprime_cabecera
imprime_info_datos_aleatorios

echo "Pulse cualquier tecla para salir"
read x