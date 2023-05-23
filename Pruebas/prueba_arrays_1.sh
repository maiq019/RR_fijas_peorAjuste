#!/bin/bash

# Nos permite saber si el parámetro pasado es entero mayor que 0.
mayor_cero()
{
    [ "$1" -eq "$1" -a "$1" -gt "0" ] > /dev/null 2>&1  # En caso de error, sentencia falsa (Compara variables como enteros)
    return $?                           				# Retorna si la sentencia anterior fue verdadera
}

#Cabecera con el algoritmo, autor y versión.
#He eliminado parámetros de color sobrante al final de la línea.
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

imprime_info_datos()
{
	echo ""
	echo -e " Número de particiones: $n_par\n"
	echo -e " Número de particiones: $n_par\n" >> informeCOLOR.txt
	echo -e " Número de particiones: $n_par\n" >> informeBN.txt

	echo -e " Tamaño de particiones: ${tam_par[@]}\n"
	echo -e " Tamaño de particiones: ${tam_par[@]}\n" >> informeCOLOR.txt
	echo -e " Tamaño de particiones: ${tam_par[@]}\n" >> informeBN.txt	

	echo -e " Quantum: 	        $quantum\n"
	echo -e " Quantum: 	        $quantum\n" >> informeCOLOR.txt
	echo -e " Quantum:	        $quantum\n" >> informeBN.txt		

	echo ""
	echo " Los procesos introducidos hasta ahora son: "
	echo " Ref Tll Tej Mem"
	echo " ---------------"
	echo " Los procesos introducidos hasta ahora son: " >> informeCOLOR.txt
	echo " Ref Tll Tej Mem" >> informeCOLOR.txt
	echo " ---------------" >> informeCOLOR.txt
	echo " Los procesos introducidos hasta ahora son: " >> informeBN.txt
	echo " Ref Tll Tej Mem" >> informeBN.txt
	echo " ---------------" >> informeBN.txt
}

clear
imprime_cabecera
imprime_info_datos

echo -n " Introduzca numero de particiones: "
echo -n " Introduzca numero de particiones: " >> informeCOLOR.txt
echo -n " Introduzca numero de particiones: " >> informeBN.txt
read n_par
echo $n_par >> informeCOLOR.txt
echo $n_par >> informeBN.txt

#He añadido una explicación más detallada del error de introducción de opción.
while ! mayor_cero $n_par
do
echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
echo -n " Introduzca numero de particiones: "
echo -n " Introduzca numero de particiones: " >> informeCOLOR.txt
echo -n " Introduzca numero de particiones: " >> informeBN.txt
read n_par
echo $n_par >> informeCOLOR.txt
echo $n_par >> informeBN.txt
done

clear
imprime_cabecera
imprime_info_datos

###  PARTICIONES  ###

#Lectura del tamaño de las particiones.
#He modificado esta entrada de datos para particiones no iguales, pidiendo el tamaño de cada una de las particiones.
for ((p=1; p <= $n_par; p++))
{
	clear
	imprime_cabecera
	imprime_info_datos

	echo -n -e " Introduce tamaño de la partición $p: "
	echo -n -e " Introduce tamaño de la partición $p: " >> informeCOLOR.txt
	echo -n -e " Introduce tamaño de la partición $p: " >> informeBN.txt
	read tam_par_p

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $tam_par_p
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
		echo -n -e " Introduce tamaño de la partición $p: "
		echo -n -e " Introduce tamaño de la partición $p: " >> informeCOLOR.txt
		echo -n -e " Introduce tamaño de la partición $p: " >> informeBN.txt
	    read tam_par_p
		echo $tam_par_p >> informeCOLOR.txt
		echo $tam_par_p >> informeBN.txt
		done

	tam_par[$p]=$tam_par_p
}

echo ""
echo -e " Tamaño de particiones: ${tam_par[@]}\n"

echo "pulse cualquier tecla para salir"
read x