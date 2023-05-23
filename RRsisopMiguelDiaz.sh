#!/bin/bash
#################################################################################################################################################
# Script realizado por Mario Juez Gil. Sistemas Operativos, Grado en ingeniería informática UBU 2012-2013						      			#
# Última versión por Miguel Díaz. Sistemas operativos, Grado en ingeniería informática UBU 2022-2023						      				#			    												 	      #					
#                                                                                                                                               #
# Funcionamiento del script:                                                                                                                    #
#	Parte importante del script se basa en la comprobación de las lecturas, especial importancia tienen:                                        #
#		- Lectura de quantum 			 -> Deberá ser entero y mayor que 0                                                                  	#
#		- Lectura del número de procesos -> Deberá ser entero y mayor que 0                                                                     #
#		- Lectura de ráfagas			 -> Deberán ser enteras y mayores que 0                                                              	#
#		- Lectura de tiempo de E/S 	 	 -> Deberá ser desde 1 hasta la ráfaga total - 1 (E/S en el primer o último tiempo no tiene sentido)    #
#		- Lectura de duración E/S 		 -> Deberá ser entero y mayor que 0                                                                 	#
#                                                                                                                                               #
#	El script deberá contemplar la opción de Round Robin con particiones fijas no iguales al peor ajuste.						              	#
#	Para resolver el problema he usado los Arrays de bash:                                                                                      #
#		PROCESOS[indice] 	-> Almacena la ráfaga del proceso                                                                                   #
#		QT_PROC[indice]	 	-> Almacena el quantum sin usar del proceso (útil cuando un proceso se bloquea por E/S)                             #
#		PROC_ENAUX[indice] 	-> [ Si / No ] Nos dice si el proceso actual está en la cola auxiliar (bloqueado por E/S)                           #
#		T_ENTRADA[indice]	-> Tiempo de llegada en el sistema del proceso                                                                      #
#		EN_ESPERA[indice]	-> [ Si / No ] Proceso en espera por tiempo de llegada                                                              #
#		[indice]		-> Momento en el cual el proceso se bloqueará por una situación de E/S                                              	#
#		DURACION[indice]	-> Duración de la situación de E/S                                                                                  #
#		FIN_ES[indice]		-> Almacena cuando va a terminar la E/S de un proceso, teniendo en cuenta su posicion en la cola FIFO               #
#		AUX[indice]			-> Cola FIFO auxiliar para los procesos bloqueados por E/S. Almacena indices de procesos.                     		#
#################################################################################################################################################
#
echo "############################################################"
echo "#                     Creative Commons                     #"
echo "#                                                          #"
echo "#                   BY - Atribución (BY)                   #"
echo "#                 NC - No uso Comercial (NC)               #"
echo "#                SA - Compartir Igual (SA)                 #"
echo "############################################################"

echo "############################################################" >> informeCOLOR.txt
echo "#                     Creative Commons                     #" >> informeCOLOR.txt
echo "#                                                          #" >> informeCOLOR.txt
echo "#                   BY - Atribución (BY)                   #" >> informeCOLOR.txt
echo "#                 NC - No uso Comercial (NC)               #" >> informeCOLOR.txt
echo "#                SA - Compartir Igual (SA)                 #" >> informeCOLOR.txt
echo "############################################################" >> informeCOLOR.txt

echo "############################################################" >> informeBN.txt
echo "#                     Creative Commons                     #" >> informeBN.txt
echo "#                                                          #" >> informeBN.txt
echo "#                   BY - Atribución (BY)                   #" >> informeBN.txt
echo "#                 NC - No uso Comercial (NC)               #" >> informeBN.txt
echo "#                SA - Compartir Igual (SA)                 #" >> informeBN.txt
echo "############################################################" >> informeBN.txt


#Se ha dejado un espacio de separación al principio de cada línea por si se da el caso de utilizar un terminar que corte el primer carácter de cada línea

#Variables Globales
min=9999
primvez=0
#He introducido variables para los colores para un mejor entendimiento en el código.
resetColor="\e[0m"			#resetea el color
colorRecuadro="\e[0;33m"	#amarillo normal
colorTexto="\e[1;36m"		#cian bold


### Función para comprobar si el parámetro pasado es un número entero mayor que 0 comparándolo con una expresión regular.
mayor_cero()
{
	if ! [[ $1 =~ ^[1-9][0-9]*$ ]]
	then
		return 1
	else
		return 0
	fi
}


### Cabecera con el algoritmo, autor y versión.
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


### He creado una nueva función que imprime la información de los datos que se están introduciendo en la opción 1. Este código estaba duplicado múltiples veces.
#He sustituido también los printf por echo -e porque no había necesidad de printf y por añadir consistencia.
#He añadido una línea en blanco antes de los datos de particiones y de los datos de procesos.
imprime_info_datos()
{
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo -e " Número de particiones: $n_par\n"
	echo -e " Número de particiones: $n_par\n" >> informeCOLOR.txt
	echo -e " Número de particiones: $n_par\n" >> informeBN.txt

	echo -e " Tamaño de particiones: ${tam_par[@]}\n"
	echo -e " Tamaño de particiones: ${tam_par[@]}\n" >> informeCOLOR.txt
	echo -e " Tamaño de particiones: ${tam_par[@]}\n" >> informeBN.txt	

	echo -e " Quantum:               $quantum\n"
	echo -e " Quantum:               $quantum\n" >> informeCOLOR.txt
	echo -e " Quantum:               $quantum\n" >> informeBN.txt		

	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
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


### He creado una nueva función que imprime la información de los datos que se están introduciendo en la opción 4. Este código estaba duplicado múltiples veces.
#He sustituido también los printf por echo -e porque no había necesidad de printf y por añadir consistencia.
imprime_info_datos_aleatorios()
{
	echo ""
	echo -e " Número de particiones: $n_par_min - $n_par_max -> $n_par"
	echo -e " Número de particiones: $n_par_min - $n_par_max -> $n_par" >> informeCOLOR.txt
	echo -e " Número de particiones: $n_par_min - $n_par_max -> $n_par" >> informeBN.txt

	echo -e " Tamaño de particiones: $tam_par_min - $tam_par_max -> ${tam_par[@]}"
	echo -e " Tamaño de particiones: $tam_par_min - $tam_par_max -> ${tam_par[@]}" >> informeCOLOR.txt
	echo -e " Tamaño de particiones: $tam_par_min - $tam_par_max -> ${tam_par[@]}" >> informeBN.txt	

	echo -e " Quantum:               $quantum_min - $quantum_max -> $quantum"
	echo -e " Quantum:               $quantum_min - $quantum_max -> $quantum" >> informeCOLOR.txt
	echo -e " Quantum:               $quantum_min - $quantum_max -> $quantum" >> informeBN.txt		
	
	echo ""
	echo " Datos de los procesos"
	echo ""
	echo " Número de procesos:	$num_proc_min - $num_proc_max -> $num_proc"
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


### Función de lectura de entrada para el menú principal (6 opciones principales, menú de guardado y recogida de datos principales en caso de introducción manual de datos).
lee_datos() {
	#Menú inicial
	echo ""
	echo " 1- Entrada Manual"
	echo " 2- Fichero de datos de última ejecución (datos.txt)"
	echo " 3- Otros ficheros de datos"
	echo " 4- Rangos aleatorios"
	echo " 5- Fichero de rangos de última ejecución (datosrangos.txt)"
	echo " 6- Otros ficheros de rangos"
	echo " 1- Entrada Manual" >> informeCOLOR.txt
	echo " 2- Fichero de datos de última ejecución (datos.txt)" >> informeCOLOR.txt
	echo " 3- Otros ficheros de datos" >> informeCOLOR.txt
	echo " 4- Rangos aleatorios" >> informeCOLOR.txt
	echo " 5- Fichero de rangos de última ejecución (datosrangos.txt)" >> informeCOLOR.txt
	echo " 6- Otros ficheros de rangos" >> informeCOLOR.txt
	echo " 1- Entrada Manual" >> informeBN.txt
	echo " 2- Fichero de datos de última ejecución (datos.txt)" >> informeBN.txt
	echo " 3- Otros ficheros de datos" >> informeBN.txt
	echo " 4- Rangos aleatorios" >> informeBN.txt
	echo " 5- Fichero de rangos de última ejecución (datosrangos.txt)" >> informeBN.txt
	echo " 6- Otros ficheros de rangos" >> informeBN.txt
	echo ""
	read -p " Elija una opción: " dat_fich
	echo $dat_fich >> informeCOLOR.txt
	echo $dat_fich >> informeBN.txt

	#COMPROBACIÓN DE LECTURA
	#He añadido una explicación más detallada del error de introducción de opción.
	while [ "${dat_fich}" != "1" -a "${dat_fich}" != "2" -a "${dat_fich}" != "3" -a "${dat_fich}" != "4" -a "${dat_fich}" != "5" -a "${dat_fich}" != "6" ] #Lectura errónea.
	do
		echo "Entrada no válida"
		read -p "Elija una opción como un número natural del 1 al 6: " dat_fich
		echo $dat_fich >> informeCOLOR.txt
		echo $dat_fich >> informeBN.txt
	done

	clear
	#Introducción de datos a mano
	#He agrupado en el mismo if la selección de guardado y la introducción/lectura de datos.
	if [ "${dat_fich}" == "1" ]
	then

		###  MÉTODO DE GUARDADO  ###

		#Se pide el método de guardado de los datos introducidos.
		#Los métodos de guardado consisten en crear un fichero nuevo con los datos (Con nombre estandar o a elegir por el usuario), o guardarlo en la última ejecución.
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

		read opcion_guardado

		#He añadido una explicación más detallada del error de introducción de opción.
		while [ "${opcion_guardado}" != "1" -a "${opcion_guardado}" != "2" ] #Lectura errónea.
		do
			echo "Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los datos?"
			read opcion_guardado
		done

		echo $opcion_guardado >> informeCOLOR.txt
		echo $opcion_guardado >> informeBN.txt

		#Si se guarda en otro fichero, pregunta el nombre.
		if [ "${opcion_guardado}" == "2" ]
		then
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)"
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> informeCOLOR.txt
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> informeBN.txt
			read nombre_fichero

			#He añadido el nombre del fichero de guardado nuevo a los informes.
			echo $nombre_fichero >> informeCOLOR.txt 
			echo $nombre_fichero >> informeBN.txt 
		fi

		#Lectura de los datos de las particiones y el quantum.
		lectura_dat_particiones

		#Lectura de los datos concretos de los procesos.
		lectura_dat_procesos
		ordenacion_procesos
	fi


	#Entrada por fichero de última ejecución.
	if [ $dat_fich = '2' ] 
	then
		#fich="datos.txt"
		lectura_fichero "datos.txt"
	fi


	#Entrada por otros ficheros.
	if [ $dat_fich = '3' ] 
	then
		clear
		#Como ahora los otros ficheros de datos también terminan en .txt se eliminan los informes y el archivo últimos de la búsqueda.
		ls | grep .txt | grep -v informeBN.txt | grep -v informeCOLOR.txt | grep -v datosrangos.txt | grep -v RNG* > listado.temp
	
		#Muestra el listado con ficheros posibles.
		cat listado.temp
		cat listado.temp >> informeCOLOR.txt
		cat listado.temp >> informeBN.txt
		echo -n " Introduce uno de los ficheros del listado:"
		echo -n " Introduce uno de los ficheros del listado:" >> informeCOLOR.txt
		echo -n " Introduce uno de los ficheros del listado:" >> informeBN.txt
		read fich
		echo $fich >> informeCOLOR.txt
		echo $fich >> informeBN.txt

		while [ ! -f $fich ] #Si el fichero no existe, lectura erronea.
		do
			echo " Entrada no válida, el fichero no se ha encontrado o no existe"
			echo " Entrada no válida, el fichero no se ha encontrado o no existe" >> informeCOLOR.txt
			echo " Entrada no válida, el fichero no se ha encontrado o no existe" >> informeBN.txt
			echo -n " Introduce uno de los ficheros del listado:"
			echo -n " Introduce uno de los ficheros del listado:" >> informeCOLOR.txt
			echo -n " Introduce uno de los ficheros del listado:" >> informeBN.txt
			read fich
			echo $fich >> informeCOLOR.txt
			echo $fich >> informeBN.txt
		done

		#Lectura de los datos del fichero.
		rm -r listado.temp #Borra el temporal.
		#Lectura de los datos del fichero.
		lectura_fichero "$fich"
	fi


	#Introduccion de datos aleatorios con rango a mano.
	#He agrupado otra vez en el mismo if la selección de guardado y la introducción/lectura de datos.
	if [ "${dat_fich}" == "4" ]
	then

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

		#Lectura de datos de particiones y quántum
		lectura_dat_particiones_aleatorias

		#Lectura de datos concretos de los procesos.
		lectura_dat_procesos_aleatorios
		ordenacion_procesos
	fi


	#Lectura de fichero de última ejecución de datos aleatorios.
	if [ $dat_fich = '5' ]
	then 
		#fich="datosrangos.txt"
		lectura_fichero_aleatorio "datosrangos.txt"
	fi


	#Lectura de otros ficheros con datos aleatorios
	if [ $dat_fich = '6' ] 
	then 
		clear
		ls | grep RNG* | grep -v datos.txt  > listado.temp
		ls | grep datosrangos.txt | grep -v datos.txt  >> listado.temp

		#Muestra listados con ficheros.
		cat listado.temp
		cat listado.temp >> informeCOLOR.txt
		cat listado.temp >> informeBN.txt
		echo -n " Introduce uno de los ficheros del listado:"
		echo -n " Introduce uno de los ficheros del listado:" >> informeCOLOR.txt
		echo -n " Introduce uno de los ficheros del listado:" >> informeBN.txt
		read fich
		echo $fich >> informeCOLOR.txt
		echo $fich >> informeBN.txt

		while [ ! -f $fich ] #Si el fichero no existe, lectura erronea.
		do
			echo " Entrada no válida, el fichero no se ha encontrado o no existe"
			echo " Entrada no válida, el fichero no se ha encontrado o no existe" >> informeCOLOR.txt
			echo " Entrada no válida, el fichero no se ha encontrado o no existe" >> informeBN.txt
			echo -n " Introduce uno de los ficheros del listado:"
			echo -n " Introduce uno de los ficheros del listado:" >> informeCOLOR.txt
			echo -n " Introduce uno de los ficheros del listado:" >> informeBN.txt
			read fich
			echo $fich >> informeCOLOR.txt
			echo $fich >> informeBN.txt
		done

		#Lectura de los datos del fichero.
		lectura_fichero_aleatorio "$fich"
		rm -r listado.temp # Borra el temporal
	fi

	#Volcado de datos a los informes.
	#He modificado el dato de tamaño de particiones para ajustarse a particiones no iguales.
	echo "		>> Numero de particiones: $n_par" >> informeCOLOR.txt
	echo "		>> Numero de particiones: $n_par" >> informeBN.txt
	echo "		>> Tamaño de particiones: ${tam_par[@]}" >> informeCOLOR.txt
	echo "		>> Tamaño de particiones: ${tam_par[@]}" >> informeBN.txt
	echo "		>> Quantum de tiempo: $quantum" >> informeCOLOR.txt
	echo "		>> Quantum de tiempo: $quantum" >> informeBN.txt
	echo "		>> $num_proc procesos." >> informeCOLOR.txt
	echo "		>> $num_proc procesos." >> informeBN.txt

	#Una vez leido quantum y los datos de los procesos, escritura de la cabecera del informe y el enunciado.
	escribe_cabecera_informe
	escribe_enunciado
}


### Escribe la cabecera del informe para la tabla de procesos.
escribe_cabecera_informe()
{
	echo "		>> Procesos y sus datos:" >> informeCOLOR.txt
	echo "		>> Procesos y sus datos:" >> informeBN.txt
	echo "			Ref Tll Tej Mem " >> informeCOLOR.txt
	echo "			Ref Tll Tej Mem " >> informeBN.txt
	echo "      	----------------" >> informeCOLOR.txt
	echo "      	----------------" >> informeBN.txt
}


### Escribe en los informes las filas del enunciado con los datos introducidos.
escribe_enunciado()
{
	p=0
	#He añadido un comentario con los colores usados en el código, y acortado el array de colores repetidos dado que su funcionamiento es cíclico.
	#color=(cyan, purple, blue, green, red)
	color=(96 95 94 92 91)
	for(( c = 0, pr = 1; pr <= $num_proc; c++, pr++ ))
	do
		if [[ $c -gt 4 ]] #Si se sale del array de colores, vuelve al primero.
		then
			c=0
		fi

		echo -ne "                \e[${color[$c]}mP" >> informeCOLOR.txt
		printf "%02d " "${PROC[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${TEJ[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${MEMORIA[$pr]}" >> informeCOLOR.txt
		echo -e "$resetColor" >> informeCOLOR.txt

		echo -ne "                P" >> informeBN.txt
		printf "%02d " "${PROC[$pr]}" >> informeBN.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> informeBN.txt
		printf "%3s " "${TEJ[$pr]}" >> informeBN.txt
		printf "%3s " "${MEMORIA[$pr]}" >> informeBN.txt
		echo " " >> informeBN.txt
	done
}

### He separado la recogida de datos manuales para cada opción en una función aparte para añadir modularidad.

### Lectura de los datos de las particiones y el quantum para la introducción a mano (opción 1)
lectura_dat_particiones()
{
	###  PARTICIONES  ###

	#Se piden las particiones y su tamaño junto al quantum.
	#Lectura del numero de particiones.
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

	#Lectura del tamaño de las particiones.
	#He modificado esta entrada de datos para particiones no iguales, pidiendo el tamaño de cada una de las particiones.
	for ((p=0; p < $n_par; p++))
	{
		clear
		imprime_cabecera
		imprime_info_datos
		echo -ne " Introduce tamaño de la partición $(($p+1)): "
		echo -ne " Introduce tamaño de la partición $(($p+1)): " >> informeCOLOR.txt
		echo -ne " Introduce tamaño de la partición $(($p+1)): " >> informeBN.txt
		read tam_par_p

		#He añadido una explicación más detallada del error de introducción de opción.
		while ! mayor_cero $tam_par_p
		do
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
			echo -ne " Introduce tamaño de la partición $(($p+1)): "
			echo -ne " Introduce tamaño de la partición $(($p+1)): " >> informeCOLOR.txt
			echo -ne " Introduce tamaño de la partición $(($p+1)): " >> informeBN.txt
			read tam_par_p
			echo $tam_par_p >> informeCOLOR.txt
			echo $tam_par_p >> informeBN.txt
		done

		tam_par[$p]=$tam_par_p
	}
	
	###  QUANTUM  ###

	#Lectura del quantum.
	clear
	imprime_cabecera
	imprime_info_datos
	echo -n " Introduce el quantum de ejecución: "
	echo -n " Introduce el quantum de ejecución: " >> informeCOLOR.txt
	echo -n " Introduce el quantum de ejecución: " >> informeBN.txt
	read quantum
	echo $quantum >> informeCOLOR.txt
	echo $quantum >> informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $quantum
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduce el quantum de ejecución: "
		echo -n " Introduce el quantum de ejecución: " >> informeCOLOR.txt
		echo -n " Introduce el quantum de ejecución: " >> informeBN.txt
		read quantum
		echo $quantum >> informeCOLOR.txt
		echo $quantum >> informeBN.txt
	done

	clear
	imprime_cabecera
	imprime_info_datos
}


### Lectura de los datos de los procesos para la introducción a mano (opción 1).
#He eliminado una variable de proceso redundante.
lectura_dat_procesos()
{
	num_proc=0 	#Número de procesos.
	
	procesos_ejecutables=0 	#Número de procesos que entran en memoria y se pueden ejecutar en CPU

	###  LECTURA DE INFORMACIÓN DE CADA PROCESO  ###
	
	#He modificado la condición del bucle para que tome el enter sin introducir nada al preguntar por un proceso nuevo como un si.
	#He cambiado el uso de comandos de expr por let.
	while [[ $proc_new = "s" || $proc_new = "" ]]
	do
		if [ $num_proc -ne 0 ]	#Si hay algún proceso.
		then 					#Imprime tabla con datos.
			ordenacion_procesos
			imprimir_tabla_procesos
		fi

		#índice del proceso.
		i_proc=$num_proc

		#Suma el número de proceso.
		let num_proc=num_proc+1

		###  LECTURA DE TIEMPO DE LLEGADA  ###

		echo -n " Introduce el tiempo de llegada a CPU del proceso $num_proc: "
		echo -n " Introduce el tiempo de llegada a CPU del proceso $num_proc: " >> informeCOLOR.txt
		echo -n " Introduce el tiempo de llegada a CPU del proceso $num_proc: " >> informeBN.txt
		read entrada
		echo $entrada >> informeCOLOR.txt
		echo $entrada >> informeBN.txt

		#He añadido una explicación más detallada del error de introducción de opción.
		while ! mayor_cero $entrada
		do
			clear
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
			echo -n " Introduce el tiempo de llegada a CPU del proceso $num_proc: "
			echo -n " Introduce el tiempo de llegada a CPU del proceso $num_proc: " >> informeCOLOR.txt
			echo -n " Introduce el tiempo de llegada a CPU del proceso $num_proc: " >> informeBN.txt
			read entrada
			echo $entrada >> informeCOLOR.txt
			echo $entrada >> informeBN.txt
		done

		#Almacenamiento de valores en los arrays.
		T_ENTRADA_I[$i_proc]="$entrada"

		#Almacena el proceso con el menor tiempo de llegada, por orden de introducción.
		if [ $entrada -lt $min ]
		then
			min=$entrada
			pos=$i_proc
		fi

		#La condición se cumplirá siempre porque el tiempo de llegada debe ser mayor que 0, pero he decidido dejar la comprobación en caso de futuras modificaciones a la restricción.
		if [ $entrada -ne '0' ] #Si el tiempo de llegada no es 0. (Se cumplirá siempre)
		then
			EN_ESPERA_I[$i_proc]="Si" #Por defecto en t=0 todos los procesos estarán en espera ya que llegan a partir de t=1.
		else
			EN_ESPERA_I[$i_proc]="No"
			let procesos_ejecutables=procesos_ejecutables+1
		fi

		#Almacenamiento de datos en un archivo temporal.
		echo ${T_ENTRADA_I[$i_proc]} >> archivo.temp
		echo ${EN_ESPERA_I[$i_proc]} >> archivo.temp

		ordenacion_procesos
		imprimir_tabla_procesos

		###  LECTURA DE RÁFAGA DE CPU DEL PROCESO  ###

		echo -n " Introduce el tiempo en CPU del proceso $num_proc: "
		echo -n " Introduce el tiempo en CPU del proceso $num_proc: " >> informeCOLOR.txt
		echo -n " Introduce el tiempo en CPU del proceso $num_proc: " >> informeBN.txt
		read rafaga
		echo $rafaga >> informeCOLOR.txt
		echo $rafaga >> informeBN.txt

		#He añadido una explicación más detallada del error de introducción de opción.
		while ! mayor_cero $rafaga
		do
 			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
			echo -n " Introduce el tiempo en CPU del proceso $num_proc: "
			echo -n " Introduce el tiempo en CPU del proceso $num_proc: " >> informeCOLOR.txt
			echo -n " Introduce el tiempo en CPU del proceso $num_proc: " >> informeBN.txt
			read rafaga
			echo $rafaga >> informeCOLOR.txt
			echo $rafaga >> informeBN.txt
		done

		#Almacenamiento de valores en los arrays.
		PROCESOS_I[$i_proc]=$rafaga  # Almacenará la ráfaga del proceso
		QT_PROC_I[$i_proc]=$quantum 	# Almacenará el quantum restante del proceso (en caso de E/S)
		PROC_ENAUX_I[$i_proc]="No" 	# Por defecto ningún proceso estará en la cola auxiliar FIFO de E/S

		#Almacenamiento de datos en un archivo temporal.
		echo $rafaga >> archivo.temp

		ordenacion_procesos
		imprimir_tabla_procesos

		###  LECTURA DE LA MEMORIA DEL PROCESO  ###

		echo -n " Introduce la memoria del proceso $num_proc: "
		echo -n " Introduce la memoria del proceso $num_proc: " >> informeCOLOR.txt
		echo -n " Introduce la memoria del proceso $num_proc: " >> informeBN.txt
		read memo_proc
		echo $memo_proc >> informeCOLOR.txt
		echo $memo_proc >> informeBN.txt

		#He añadido una explicación más detallada del error de introducción de opción.
		while ! mayor_cero $memo_proc
		do
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
			echo -n " Introduce la memoria del proceso $num_proc: "
			echo -n " Introduce la memoria del proceso $num_proc: " >> informeCOLOR.txt
			echo -n " Introduce la memoria del proceso $num_proc: " >> informeBN.txt
			read memo_proc
			echo $memo_proc >> informeCOLOR.txt
			echo $memo_proc >> informeBN.txt
		done

		###  COMPROBACIÓN DE MEMORIA MENOR QUE PARTICIONES  ###

		#He adaptado esta parte para ajustarse a particiones no iguales.
		#Compruebo el tamaño máximo de entre las particiones disponibles.
		tam_par_max_efec=1
		for tp in "${tam_par[@]}"
		do
			if [ $tp -gt $tam_par_max_efec ]
			then
				tam_par_max_efec=$tp
			fi
		done

		while [ $memo_proc -gt $tam_par_max_efec ] #Si la memoria del proceso es mayor que la mayor partición
		do
 			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeBN.txt
			echo -n " Introduce la memoria del proceso $num_proc: "
			echo -n " Introduce la memoria del proceso $num_proc: " >> informeCOLOR.txt
			echo -n " Introduce la memoria del proceso $num_proc: " >> informeBN.txt
			read memo_proc
			echo $memo_proc >> informeCOLOR.txt
			echo $memo_proc >> informeBN.txt
		done

		#Almacenamiento de valores en los arrays.
		MEMORIA_I[$i_proc]=$memo_proc  # Almacenará la memoria del proceso

		#Almacenamiento de datos en un archivo temporal.
		echo $memo_proc >> archivo.temp

		ordenacion_procesos
		imprimir_tabla_procesos
		
		#Pregunta por la introducción de un nuevo proceso.
		new_proc
	done

	#Si no hay procesos ejecutables, saca de espera al proceso con el menor tiempo de llegada y suma procesos ejecutables.
	if [ $procesos_ejecutables -eq 0 ]
	then
		EN_ESPERA[$pos]="No"
		let procesos_ejecutables=procesos_ejecutables+1
	fi
}


### Pregunta si se desea introducir mas procesos al ejercicio.
#He modificado esta función para admitir el texto vacío como válido, que se podrá interpretar como sí o no en su uso.
new_proc()
{
	read -p "¿desea intoducir un proceso nuevo? ([s]/n) " proc_new

	while [ "${proc_new}" != "" -a "${proc_new}" != "s" -a "${proc_new}" != "n" ]
	do
		read -p "Entrada no válida, vuelve a intentarlo. ¿desea intoducir un proceso nuevo? ([s]/n) " proc_new
	done
}


### Lectura de los datos de rangos de las particiones y el quantum para la introducción a mano para sacar los datos aleatorios (opción 4).
lectura_dat_particiones_aleatorias()
{
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

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $n_par_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduzca numero de particiones mínimo: "
		echo -n " Introduzca numero de particiones mínimo: " >> informeCOLOR.txt
		echo -n " Introduzca numero de particiones mínimo: " >> informeBN.txt
		read n_par_min
		echo $n_par_min >> informeCOLOR.txt
		echo $n_par_min >> informeBN.txt
	done

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

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE NÚMERO DE PARTICIONES  ###
	
	#He fusionado la comprobación de mayor que cero y mayor que número de particiones mínimo porque me parece más elegante.
	while ! mayor_cero $n_par_max || [ $n_par_max -lt $n_par_min ]
	do
		if ! mayor_cero $n_par_max	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
			echo -n " Introduzca numero de particiones máximo: "
			echo -n " Introduzca numero de particiones máximo: " >> informeCOLOR.txt
			echo -n " Introduzca numero de particiones máximo: " >> informeBN.txt
			read n_par_max
			echo $n_par_max >> informeCOLOR.txt
			echo $n_par_max >> informeBN.txt
		else	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
			echo -n " Introduzca numero de particiones máximo: "
			echo -n " Introduzca numero de particiones máximo: " >> informeCOLOR.txt
			echo -n " Introduzca numero de particiones máximo: " >> informeBN.txt
			read n_par_max
			echo $n_par_max >> informeCOLOR.txt
			echo $n_par_max >> informeBN.txt
		fi
	done

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

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $tam_par_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduzca tamaño de particiones mínimo: "
		echo -n " Introduzca tamaño de particiones mínimo: " >> informeCOLOR.txt
		echo -n " Introduzca tamaño de particiones mínimo: " >> informeBN.txt
		read tam_par_min
		echo $tam_par_min >> informeCOLOR.txt
		echo $tam_par_min >> informeBN.txt
	done

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

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE TAMAÑO DE PARTICIONES  ###
	
	#He fusionado la comprobación de mayor que cero y mayor que tamaño de particiones mínimo porque me parece más elegante.
	while ! mayor_cero $tam_par_max || [ $tam_par_max -lt $tam_par_min ]
	do
		if ! mayor_cero $tam_par_max	#He añadido una explicación más detallada del error de introducción de opción.	
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
			echo -n " Introduzca tamaño de particiones máximo: "
			echo -n " Introduzca tamaño de particiones máximo: " >> informeCOLOR.txt
			echo -n " Introduzca tamaño de particiones máximo: " >> informeBN.txt
			read tam_par_max
			echo $tam_par_max >> informeCOLOR.txt
			echo $tam_par_max >> informeBN.txt
		else	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
			echo -n " Introduzca tamaño de particiones máximo: "
			echo -n " Introduzca tamaño de particiones máximo: " >> informeCOLOR.txt
			echo -n " Introduzca tamaño de particiones máximo: " >> informeBN.txt
			read tam_par_max
			echo $tam_par_max >> informeCOLOR.txt
			echo $tam_par_max >> informeBN.txt
		fi
	done	

	#Asignación aleatoria del tamaño de particiones en el rango.
	for ((p=0; p < $n_par; p++))
	{
		tam_par[$p]=`shuf -i $tam_par_min-$tam_par_max -n 1`
	}

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

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $quantum_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduce el quantum de ejecución mínimo: "
		echo -n " Introduce el quantum de ejecución mínimo: " >> informeCOLOR.txt
		echo -n " Introduce el quantum de ejecución mínimo: " >> informeBN.txt
		read quantum_min
		echo $quantum_min >> informeCOLOR.txt
		echo $quantum_min >> informeBN.txt
	done

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

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE QUÁNTUM  ###

	#He fusionado la comprobación de mayor que cero y mayor que quántum mínimo porque me parece más elegante.
	while ! mayor_cero $quantum_max || [ $quantum_max -lt $quantum_min ]
	do
		if ! mayor_cero $quantum_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
			echo -n " Introduce el quantum de ejecución máximo: "
			echo -n " Introduce el quantum de ejecución máximo: " >> informeCOLOR.txt
			echo -n " Introduce el quantum de ejecución máximo: " >> informeBN.txt
			read quantum_max
			echo $quantum_max >> informeCOLOR.txt
			echo $quantum_max >> informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
			echo -n " Introduzca el quantum de ejecución máximo: "
			echo -n " Introduzca el quantum de ejecución máximo: " >> informeCOLOR.txt
			echo -n " Introduzca el quantum de ejecución máximo: " >> informeBN.txt
			read quantum_max
			echo $quantum_max >> informeCOLOR.txt
			echo $quantum_max >> informeBN.txt
		fi
	done

	#Asignación aleatoria del quántum en el rango.
	quantum=`shuf -i $quantum_min-$quantum_max -n 1`

	clear
	imprime_cabecera
	imprime_info_datos_aleatorios
}


### Lectura de los datos de rangos de los procesos para la introducción a mano para sacar los datos aleatorios (opción 4).
lectura_dat_procesos_aleatorios()
{
	num_proc=0
	procesos_ejecutables=0 	#Número de procesos que entran en memoria y se pueden ejecutar en CPU

	###  NÚMERO DE PROCESOS MÍNIMO  ###
	imprimir_tabla_RNG
	echo -n " Introduce el número de procesos mínimo: "
	echo -n " Introduce el número de procesos mínimo: " >> informeCOLOR.txt
	echo -n " Introduce el número de procesos mínimo: " >> informeBN.txt
	read num_proc_min
	echo $num_proc_min >> informeCOLOR.txt
	echo $num_proc_min >> informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $num_proc_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduce el número de procesos mínimo: "
		echo -n " Introduce el número de procesos mínimo: " >> informeCOLOR.txt
		echo -n " Introduce el número de procesos mínimo: " >> informeBN.txt
		read num_proc_min
		echo $num_proc_min >> informeCOLOR.txt
		echo $num_proc_min >> informeBN.txt
	done

	###  NÚMERO DE PROCESOS MÁXIMO  ###

	imprimir_tabla_RNG
	echo -n " Introduce el número de procesos máximo: "
	echo -n " Introduce el número de procesos máximo: " >> informeCOLOR.txt
	echo -n " Introduce el número de procesos máximo: " >> informeBN.txt
	read num_proc_max
	echo $num_proc_max >> informeCOLOR.txt
	echo $num_proc_max >> informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE NÚMERO DE PROCESOS  ###

	#He fusionado la comprobación de mayor que cero y mayor que número de procesos mínimo porque me parece más elegante.
	while ! mayor_cero $num_proc_max || [ $num_proc_max -lt $num_proc_min ]
	do
		if ! mayor_cero $num_proc_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
			echo -n " Introduce el número de procesos máximo: "
			echo -n " Introduce el número de procesos máximo: " >> informeCOLOR.txt
			echo -n " Introduce el número de procesos máximo: " >> informeBN.txt
			read num_proc_max
			echo $num_proc_max >> informeCOLOR.txt
			echo $num_proc_max >> informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
			echo -n " Introduzca el número de procesos máximo: "
			echo -n " Introduzca el número de procesos máximo: " >> informeCOLOR.txt
			echo -n " Introduzca el número de procesos máximo: " >> informeBN.txt
			read num_proc_max
			echo $num_proc_max >> informeCOLOR.txt
			echo $num_proc_max >> informeBN.txt
		fi
	done
	
	#Asignación aleatoria del número de procesos en el rango.
	num_proc=`shuf -i $num_proc_min-$num_proc_max -n 1`

	###   TIEMPO DE LLEGADA MÍNIMO  ###

	ordenacion_procesos
	imprimir_tabla_RNG
	echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: "
	echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: " >> informeBN.txt
	read entrada_min
	echo $entrada_min >> informeCOLOR.txt
	echo $entrada_min >> informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $entrada_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: "
		echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: " >> informeBN.txt
		read entrada_min
		echo $entrada_min >> informeCOLOR.txt
		echo $entrada_min >> informeBN.txt
	done

	###   TIEMPO DE LLEGADA MÁXIMO  ###

	ordenacion_procesos
	imprimir_tabla_RNG
	echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: "
	echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: " >> informeBN.txt
	read entrada_max
	echo $entrada_max >> informeCOLOR.txt
	echo $entrada_max >> informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE TIEMPOS DE LLEGADA  ###

	#He fusionado la comprobación de mayor que cero y mayor que llegada mínima porque me parece más elegante.
	while ! mayor_cero $entrada_max || [ $entrada_max -lt $entrada_min ]
	do
		if ! mayor_cero $entrada_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
			echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: "
			echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: " >> informeCOLOR.txt
			echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: " >> informeBN.txt
			read entrada_max
			echo $entrada_max >> informeCOLOR.txt
			echo $entrada_max >> informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
			echo -n " Introduzca el tiempo de llegada máximo a CPU de los procesos: "
			echo -n " Introduzca el tiempo de llegada máximo a CPU de los procesos: " >> informeCOLOR.txt
			echo -n " Introduzca el tiempo de llegada máximo a CPU de los procesos: " >> informeBN.txt
			read entrada_max
			echo $entrada_max >> informeCOLOR.txt
			echo $entrada_max >> informeBN.txt
		fi
	done

	###  RÁFAGA MÍNIMA  ###

	ordenacion_procesos
	imprimir_tabla_RNG
	echo -n " Introduce la ráfaga mínima de CPU de los procesos: "
	echo -n " Introduce la ráfaga mínima de CPU de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce la ráfaga mínima de CPU de los procesos: " >> informeBN.txt
	read rafaga_min
	echo $rafaga_min >> informeCOLOR.txt
	echo $rafaga_min >> informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rafaga_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduce la ráfaga mínima de CPU de los procesos: "
		echo -n " Introduce la ráfaga mínima de CPU de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce la ráfaga mínima de CPU de los procesos: " >> informeBN.txt
		read rafaga_min
		echo $rafaga_min >> informeCOLOR.txt
		echo $rafaga_min >> informeBN.txt
	done

	###  RÁFAGA MÁXIMA  ###

	ordenacion_procesos
	imprimir_tabla_RNG
	echo -n " Introduce la ráfaga máxima de CPU de los procesos: "
	echo -n " Introduce la ráfaga máxima de CPU de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce la ráfaga máxima de CPU de los procesos: " >> informeBN.txt
	read rafaga_max
	echo $rafaga_max >> informeCOLOR.txt
	echo $rafaga_max >> informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE RÁFAGA  ###

	#He fusionado la comprobación de mayor que cero y mayor que ráfaga mínima porque me parece más elegante.
	while ! mayor_cero $rafaga_max || [ $rafaga_max -lt $rafaga_min ]
	do
		if ! mayor_cero $rafaga_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then 
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
			echo -n " Introduce la ráfaga máxima de CPU de los procesos: "
			echo -n " Introduce la ráfaga máxima de CPU de los procesos: " >> informeCOLOR.txt
			echo -n " Introduce la ráfaga máxima de CPU de los procesos: " >> informeBN.txt
			read rafaga_max
			echo $rafaga_max >> informeCOLOR.txt
			echo $rafaga_max >> informeBN.txt
		else  	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
			echo -n " Introduzca la ráfaga máxima de CPU de los procesos: "
			echo -n " Introduzca la ráfaga máxima de CPU de los procesos: " >> informeCOLOR.txt
			echo -n " Introduzca la ráfaga máxima de CPU de los procesos: " >> informeBN.txt
			read rafaga_max
			echo $rafaga_max >> informeCOLOR.txt
			echo $rafaga_max >> informeBN.txt
		fi
	done

	###  MEMORIA  ###

	#He adaptado la parte de las comprobaciones de la memoria para ajustarse a particiones no iguales.
	#Compruebo el tamaño máximo efectivo de entre las particiones disponibles.
	tam_par_max_efec=1
	for tp in "${tam_par[@]}"
	do
		if [ $tp -gt $tam_par_max_efec ]
		then
			tam_par_max_efec=$tp
		fi
	done

	###  MEMORIA MÍNIMA  ###

	ordenacion_procesos
	imprimir_tabla_RNG
	echo -n " Introduce la memoria mínima de los procesos: "
	echo -n " Introduce la memoria mínima de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce la memoria mínima de los procesos: " >> informeBN.txt
	read memo_proc_min
	echo $memo_proc_min >> informeCOLOR.txt
	echo $memo_proc_min >> informeBN.txt

	###  COMPROBACIÓN DE MEMORIA MÍNIMA MAYOR QUE CERO Y MENOR QUE TAMAÑO DE PARTICIONES  ###

	#He fusionado las comprobaciones de mayor que cero y menor que partición máxima para evitar la situación que se daba al poder introducir
	#un valor correcto mayor que cero primero, pero luego un valor incorrecto mayor que la partición máxima y en el reintento un valor"correcto" 
	#menor que la partición máxima pero menor que 0 o directamente no un número.
	while ! mayor_cero $memo_proc_min || [ $memo_proc_min -gt $tam_par_max_efec ]
	do
		if ! mayor_cero $memo_proc_min 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
			echo -n " Introduce la memoria mínima de los procesos: "
			echo -n " Introduce la memoria mínima de los procesos: " >> informeCOLOR.txt
			echo -n " Introduce la memoria mínima de los procesos: " >> informeBN.txt
			read memo_proc_min
			echo $memo_proc_min >> informeCOLOR.txt
			echo $memo_proc_min >> informeBN.txt
		else #Si la memoria mínima de los procesos es mayor que la mayor partición.
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeBN.txt
			echo -n " Introduce la memoria mínima de los procesos: "
			echo -n " Introduce la memoria mínima de los procesos: " >> informeCOLOR.txt
			echo -n " Introduce la memoria mínima de los procesos: " >> informeBN.txt
			read memo_proc_min
			echo $memo_proc_min >> informeCOLOR.txt
			echo $memo_proc_min >> informeBN.txt
		fi
	done

	###  MEMORIA MÁXIMA  ###

	ordenacion_procesos
	imprimir_tabla_RNG
	echo -n " Introduce la memoria máxima de los procesos: "
	echo -n " Introduce la memoria máxima de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce la memoria máxima de los procesos: " >> informeBN.txt
	read memo_proc_max
	echo $memo_proc_max >> informeCOLOR.txt
	echo $memo_proc_max >> informeBN.txt

	###  COMPROBACIÓN DE MEMORIA MÁXIMA MAYOR QUE CERO, MENOR QUE TAMAÑO DE PARTICIONES Y DE RANGOS DE MEMORIA ###

	#He fusionado las comprobaciones de mayor que cero, menor que partición máxima y mayor que memoria mínima para evitar la situación que se daba 
	#al poder introducir un valor correcto mayor que cero primero, pero luego un valor incorrecto mayor que la partición máxima y en el reintento 
	#un valor"correcto" menor que la partición máxima pero menor que 0 o directamente no un número, o un valor correcto mayor que cero y menor o igual 
	#que la mayor partición pero luego un valor "correcto" mayor que la memoria mínima pero mayor también que la partición máxima.
	while ! mayor_cero $memo_proc_max || [ $memo_proc_max -gt $tam_par_max_efec ] || [ $memo_proc_max -lt $memo_proc_min ]
	do
		if ! mayor_cero $memo_proc_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
			echo -n " Introduce la memoria máxima de los procesos: "
			echo -n " Introduce la memoria máxima de los procesos: " >> informeCOLOR.txt
			echo -n " Introduce la memoria máxima de los procesos: " >> informeBN.txt
			read memo_proc_max
			echo $memo_proc_max >> informeCOLOR.txt
			echo $memo_proc_max >> informeBN.txt
		elif [ $memo_proc_max -gt $tam_par_max_efec ] 	#Si la memoria máxima de los procesos es mayor que la mayor partición.
		then
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeBN.txt
			echo -n " Introduce la memoria máxima de los procesos: "
			echo -n " Introduce la memoria máxima de los procesos: " >> informeCOLOR.txt
			echo -n " Introduce la memoria máxima de los procesos: " >> informeBN.txt
			read memo_proc_max
			echo $memo_proc_max >> informeCOLOR.txt
			echo $memo_proc_max >> informeBN.txt
		else 
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
			echo -n " Introduzca la memoria máxima de los procesos: "
			echo -n " Introduzca la memoria máxima de los procesos: " >> informeCOLOR.txt
			echo -n " Introduzca la memoria máxima de los procesos: " >> informeBN.txt
			read memo_proc_max
			echo $memo_proc_max >> informeCOLOR.txt
			echo $memo_proc_max >> informeBN.txt
		fi
	done

	ordenacion_procesos
	imprimir_tabla_RNG

	#Bucle que calcula los datos de los procesos con los rangos y los imprime antes de que comience la ejecución del algoritmo RR.
	#He eliminado variables redundantes y cambiado los comandos de expr por let.
	for(( i = 0, proc = 1; i < ($num_proc); i++, proc++ ))
	do
		if [ $proc -gt 1 ] 	#Si hay algún proceso.
		then 				#Imprime tabla con datos.
			ordenacion_procesos
			imprimir_tabla_RNG
		fi

		#Asignación aleatoria del tiempo de entrada en el rango.
		entrada=`shuf -i $entrada_min-$entrada_max -n 1`
		T_ENTRADA_I[$i]="$entrada"

		#Almacena el proceso con el menor tiempo de llegada, por orden de introducción.
		if [ $entrada -lt $min ]
		then
			min=$entrada
			pos=$i
		fi

		#La condición se cumplirá siempre porque el tiempo de llegada debe ser mayor que 0, pero he decidido dejar la comprobación en caso de futuras modificaciones a la restricción.
		if [ $entrada -ne '0' ]  #Si el tiempo de llegada no es 0. (Se cumplirá siempre)
		then	
			EN_ESPERA_I[$i]="Si" #Por defecto en t=0 todos los procesos estarán en espera ya que llegan a partir de t=1.
		else
			EN_ESPERA[$i]="No"
			let procesos_ejecutables=procesos_ejecutables+1
		fi

		#Almacenamiento de datos en un archivo temporal.
		echo ${T_ENTRADA_I[$i]} >> archivo.temp
		echo ${EN_ESPERA_I[$i]} >> archivo.temp

		ordenacion_procesos
		imprimir_tabla_RNG

		#Asignación aleatoria de la ráfaga en el rango.
		rafaga=`shuf -i $rafaga_min-$rafaga_max -n 1`
		PROCESOS_I[$i]=$rafaga  #Almacena la ráfaga del proceso
		QT_PROC_I[$i]=$quantum 	#Almacena el quantum restante del proceso (en caso de E/S)
		PROC_ENAUX_I[$i]="No" 	#Por defecto ningún proceso estará en la cola auxiliar FIFO de E/S

		#Almacenamiento de datos en un archivo temporal
		echo $rafaga >> archivo.temp

		ordenacion_procesos
		imprimir_tabla_RNG

		#Asignación aleatoria de la memoria en el rango.
		memo_proc=`shuf -i $memo_proc_min-$memo_proc_max -n 1`
		MEMORIA_I[$i]=$memo_proc

		#Almacenamiento de datos en un archivo temporal
		echo $memo_proc >> archivo.temp

		ordenacion_procesos
		imprimir_tabla_RNG
	done

	#Si no hay procesos ejecutables, saca de espera al proceso con el menor tiempo de llegada y suma procesos ejecutables.
	if [ $procesos_ejecutables -eq '0' ]
	then
		EN_ESPERA[$pos]="No"
		let procesos_ejecutables=procesos_ejecutables+1
	fi
}


### Lee los datos desde un fichero.
#He cambiado la variable fich a un parámetro de la función.
#He cambiado los comandos de operaciones a let.
#He cambado el bucle de lectura a una forma más directa, ya que se conoce el formato del archivo.
lectura_fichero()
{
	n_linea=0
	num_proc=0
	procesos_ejecutables=0

	cp $1 copia.txt
	fich="copia.txt"

	#Elimina las filas con texto.
	sed -i 3d $fich
	sed -i 1d $fich

	while read line
	do
		if [[ $n_linea == 0 ]] #La primera línea contiene los datos de las particiones
		then
			i=0
			let last=${#line}/2 #Como el contro de caracteres cuenta los espacios, a un espacio por elemento (menos el último) 
								#para saber el índice que tendrá el último elemento divido entre dos.
			for dat in $line 
			do
				case $i in 
					0)
						n_par=$dat 				#El primer dato (0) de la línea es el número de procesos.
					;;
					$last)
						quantum=$dat 			#El último elemento del array es el quántum.
					;;
					*)
						let i_par=i-1
						tam_par[$i_par]=$dat 	#Desde el segundo dato (1) hasta el penúltimo es el tamaño de cada partición.
					;;
				esac
				let i=i+1
			done
		else
			dat_proc_leidos=0
			for dat in $line #Cada línea siguiente contiene los datos de cada proceso.
			do
				case $dat_proc_leidos in 
					0)
						T_ENTRADA_I[$num_proc]=$dat 
					;;
					1)
						PROCESOS_I[$num_proc]=$dat 
					;;
					2)
						MEMORIA_I[$num_proc]=$dat 
					;;
					*)
						echo "Error al leer los procesos del fichero datos.txt"
						read -p "close" x
					;;
				esac

				let dat_proc_leidos=dat_proc_leidos+1
			done

			let num_proc=num_proc+1 #Suma el número de procesos leídos.
		fi
		let n_linea=n_linea+1 #Suma el número de líneas leídas.
	done < $fich

	datos_fichTfich
	ordenacion_procesos
	rm $fich
}


### Lee los datos desde un fichero de rangos.
#He cambiado la variable fich a un parámetro de la función.
#He cambiado los comandos de operaciones a let.
#He cambiado la estructura de la función de if-elses anidados a case.
lectura_fichero_aleatorio()
{
	n_linea=0
	#num_proc=0
	procesos_ejecutables=0

	cp $1 copia.txt
	fich="copia.txt"

	#Elimina las fila con texto
	sed -i 13d $fich
	sed -i 11d $fich
	sed -i 9d $fich
	sed -i 7d $fich
	sed -i 5d $fich
	sed -i 3d $fich
	sed -i 1d $fich

	#Asigna las variables según donde se encuentre el dato.
	while read line
	do
		dat_leidos=0
		case $n_linea in 
			0)									#Línea 0, número de particiones.
				for dat in $line 
				do
					case $dat_leidos in
						0)						#Primer dato, mínimo.
							n_par_min=$dat
						;;
						1)						#Segundo dato, máximo.
							n_par_max=$dat
						;;
					esac
					let dat_leidos=dat_leidos+1
				done
			;;
			1)									#Línea 1, tamaño de particiones.
				for dat in $line 
				do
					case $dat_leidos in
						0)						#Primer dato, mínimo.
							tam_par_min=$dat
						;;
						1)						#Segundo dato, máximo.
							tam_par_max=$dat
						;;
					esac
					let dat_leidos=dat_leidos+1
				done
			;;
			2)									#Línea 2, quántum.
				for dat in $line 
				do
					case $dat_leidos in
						0)						#Primer dato, mínimo.
							quantum_min=$dat
						;;
						1)						#Segundo dato, máximo.
							quantum_max=$dat
						;;
					esac
					let dat_leidos=dat_leidos+1
				done
			;;
			3)									#Línea 3, número de procesos.
				for dat in $line 
				do
					case $dat_leidos in
						0)						#Primer dato, mínimo.
							num_proc_min=$dat
						;;
						1)						#Segundo dato, máximo.
							num_proc_max=$dat
						;;
					esac
					let dat_leidos=dat_leidos+1
				done
			;;
			4)									#Línea 4, tiempo de llegada de procesos.
				for dat in $line 
				do
					case $dat_leidos in
						0)						#Primer dato, mínimo.
							entrada_min=$dat
						;;
						1)						#Segundo dato, máximo.
							entrada_max=$dat
						;;
					esac
					let dat_leidos=dat_leidos+1
				done
			;;
			5)									#Línea 5, tiempo de ejecución de procesos.
				for dat in $line 
				do
					case $dat_leidos in
						0)						#Primer dato, mínimo.
							rafaga_min=$dat
						;;
						1)						#Segundo dato, máximo.
							rafaga_max=$dat
						;;
					esac
					let dat_leidos=dat_leidos+1
				done
			;;
			6)									#Línea 6, memoria de procesos.
				for dat in $line 
				do
					case $dat_leidos in
						0)						#Primer dato, mínimo.
							memo_proc_min=$dat
						;;
						1)						#Segundo dato, máximo.
							memo_proc_max=$dat
						;;
					esac
					let dat_leidos=dat_leidos+1
				done
			;;
			*)
				echo "Error al leer los procesos del fichero datos.txt"
				read -p "close" x
			;;
		esac
		let n_linea=n_linea+1 #Suma el número de líneas leídas.
	done < $fich

	#Asignación aleatoria de los datos en los rangos.
	n_par=`shuf -i $n_par_min-$n_par_max -n 1`
	for (( pa = 0; pa < n_par; pa++ ))
	do
		tam_par[$pa]=`shuf -i $tam_par_min-$tam_par_max -n 1`
	done
	quantum=`shuf -i $quantum_min-$quantum_max -n 1`
	num_proc=`shuf -i $num_proc_min-$num_proc_max -n 1`
	
	for(( i = 0; i < $num_proc; i++ ))
	do
		entrada=`shuf -i $entrada_min-$entrada_max -n 1`
		T_ENTRADA_I[$i]="$entrada"
		rafaga=`shuf -i $rafaga_min-$rafaga_max -n 1`
		PROCESOS_I[$i]="$rafaga"
		memo_proc=`shuf -i $memo_proc_min-$memo_proc_max -n 1`
		MEMORIA_I[$i]="$memo_proc"
	done

	datos_fichTfich
	ordenacion_procesos
	rm $fich
}


### Mete los datos sobre las particiones y el quantum obtenidos del fichero en el informe.
#He modificado la función para adaptarse a particiones no iguales.
datos_fichTfich()
{
	echo ""
	echo "		>> Numero de particiones: $n_par" >> informeCOLOR.txt
	echo "		>> Numero de particiones: $n_par" >> informeBN.txt
	echo "		>> Tamaño de particiones: ${tam_par[@]}" >> informeCOLOR.txt
	echo "		>> Tamaño de particiones: ${tam_par[@]}" >> informeBN.txt
	echo "		>> Quantum de tiempo: $quantum" >> informeCOLOR.txt
	echo "		>> Quantum de tiempo: $quantum" >> informeBN.txt
}


### Escribe las filas solución del informe.
#He cambiado el comando expr por let.
escribe_datos_informe()
{
	let tiempo_final=tiempo_transcurrido - ${T_ENTRADA[$proc_actual]}
	#Escritura del proceso terminado en la tabla del informe.
	if [ $proc -lt '10' ]
		then
		echo "		  ${PROC[$proc_actual]}   | $tiempo_final"	>> informeCOLOR.txt
	else
		echo "		  ${PROC[$proc_actual]}  | $tiempo_final"	>> informeCOLOR.txt
	fi
	echo "		----------------" >> informeCOLOR.txt
}


### Función para elegir el modo de ejecución del algoritmo.
modo_ejecucion()
{
	clear
	imprime_cabecera
	echo " 1- Por eventos (Intro)"
	echo " 2- Automática (Tras n segundos)"
	echo " 3- Completa (Todo seguido)"
	read -p " Modo de ejecución: " opcion_ejecucion

	while [ "${opcion_ejecucion}" != 1 -a "${opcion_ejecucion}" != 2 -a "${opcion_ejecucion}" != 3 ]
	do
		read -p "Entrada no válida, Elige un modo de ejecución: " opcion_ejecucion
	done

	#Lectura de segundos introducidos por el usuario en caso de opción 2.
	if [ "${opcion_ejecucion}" == 2 ]
	then
		read -p " Nº de segundos: " segundos_evento

		while ! mayor_cero $segundos_evento
		do
			read -p " Entrada no válida, Introduce el número de segundos que debe pasar entre cada evento: " segundos_evento
		done
	fi

	clear
}


### Imprime los datos de los procesos introducidos hasta el momento.
imprimir_tabla_procesos()
{
	#He añadido un comentario con los colores usados en el código, y acortado el array de colores repetidos dado que su funcionamiento es cíclico.
	#color=(cyan, pink, dark blue, purple, green, red)
	color=(96 95 94 35 92 91)

	clear
	imprime_cabecera
	imprime_info_datos

	for ((pr=0; pr < $num_proc; pr++ ))
	do
		if [ $(( ${PROC[$pr]} - 1 )) -ge 6 ]
		then
			colimp=$(( $(( ${PROC[$pr]} - 1 )) % 6 ))
		else
			colimp=$(( ${PROC[$pr]} - 1 ))
		fi

		echo -ne " \e[${color[$colimp]}mP"
		printf "%02d " "${PROC[$pr]}"
		printf "%3s " "${T_ENTRADA[$pr]}"
		printf "%3s " "${TEJ[$pr]}"
		printf "%3s " "${MEMORIA[$pr]}"	
		echo -e $resetColor
		echo -ne " \e[${color[$colimp]}mP" >> informeCOLOR.txt
		printf "%02d " "${PROC[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${TEJ[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${MEMORIA[$pr]}" >> informeCOLOR.txt
		echo -e $resetColor >> informeCOLOR.txt
		echo -ne " P" >> informeBN.txt
		printf "%02d " "${PROC[$pr]}" >> informeBN.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> informeBN.txt
		printf "%3s " "${TEJ[$pr]}" >> informeBN.txt
		printf "%3s " "${MEMORIA[$pr]}" >> informeBN.txt
		echo "" >> informeBN.txt
	done
}

### Imprime los datos generados para los procesos introducidos hasta el momento.
imprimir_tabla_RNG()
{
	#He añadido un comentario con los colores usados en el código, y acortado el array de colores repetidos dado que su funcionamiento es cíclico.
	#color=(cyan, pink, dark blue, purple, green, red)
	color=(96 95 94 35 92 91)
	
	clear
	imprime_cabecera
	imprime_info_datos_aleatorios

	for((pr=0; pr < $num_proc; pr++ ))
	do
		if [ $(( ${PROC[$pr]} - 1 )) -ge 6 ]
		then
			colimp=$(( $(( ${PROC[$pr]} - 1 )) % 6 ))
		else
			colimp=$(( ${PROC[$pr]} - 1 ))
		fi

		echo -ne " \e[${color[$colimp]}mP"
		printf "%02d " "${PROC[$pr]}"
		printf "%3s " "${T_ENTRADA[$pr]}"
		printf "%3s " "${TEJ[$pr]}"
		printf "%3s " "${MEMORIA[$pr]}"	
		echo -e $resetColor

		echo -ne " \e[${color[$colimp]}mP" >> informeCOLOR.txt
		printf "%02d " "${PROC[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${TEJ[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${MEMORIA[$pr]}" >> informeCOLOR.txt
		echo -e $resetColor >> informeCOLOR.txt

		echo -ne " P" >> informeBN.txt
		printf "%02d " "${PROC[$pr]}" >> informeBN.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> informeBN.txt
		printf "%3s " "${TEJ[$pr]}" >> informeBN.txt
		printf "%3s " "${MEMORIA[$pr]}" >> informeBN.txt
		echo "" >> informeBN.txt
	done
}


### Ordena los procesos por tiempo de llegada.
#He cambiado los comandos expr por let, y los he quitado de las asignaciones.
ordenacion_procesos() 
{
	proceso=0
	for (( nn=1; $proceso < $num_proc; nn++ ))
	do
		for(( j=0; j < $num_proc ; j++ ))
		do
			let caca=nn-1
			if [ ${T_ENTRADA_I[$j]} -eq $caca ]
			then
				TEJ[$proceso]=${PROCESOS_I[$j]}
				PROCESOS[$proceso]=${PROCESOS_I[$j]}
				MEMORIA[$proceso]=${MEMORIA_I[$j]}
				T_ENTRADA[$proceso]=${T_ENTRADA_I[$j]}
				#EN_ESPERA[$proceso]=`expr ${EN_ESPERA_I[$j]}`
				#QT_PROC[$proceso]=`expr ${QT_PROC_I[$j]}`
				#PROC_ENAUX[$proceso]=`expr ${PROC_ENAUX_I[$j]}`
				let pp=j+1
				PROC[$proceso]=$pp
				FIN[$proceso]=0
				TIEMPO[$proceso]=${PROCESOS_I[$j]}
				let proceso=proceso+1
			fi
		done
	done
#	EN_ESPERA[0]="No"
}

### Guarda datos en en auxiliares para evitar su modificacion.
datos_aux()
{
	for(( cc=0; cc < $num_proc; cc++ ))
	do
		RAFAGA_AUX[$cc]=${PROCESOS[$cc]}
		MEMORIA_AUX[$cc]=${MEMORIA[$cc]}
	done
}

### Comprueba si un proceso entra en memoria guardandolo en un array.
en_memoria()
{
	for(( co=0; co < $num_proc; co++ ))
	do
		if [ ${MEMORIA[$co]} -ne ${MEMORIA_AUX[$co]} ]
		then
			EN_MEMO[$co]="No"
		fi
	done
}

### Mete la tabla final en el informe que se da la opcion de visualizar al final del programa
datosfin_inf()
{
	en_memoria
	media=0

	echo " "  >> informeCOLOR.txt
	echo "	---------------------------------------------------------------------"  >> informeCOLOR.txt
	echo "	  PRO | T LLEGADA | RAFAGA | MEMORIA | EN MEMORIA | L TEMP | ESTADO  "  >> informeCOLOR.txt
	echo "	---------------------------------------------------------------------"  >> informeCOLOR.txt
	for(( xp=0 ; xp < $num_proc ; xp++ ))
	do
		echo "	    ${PROC[$xp]}|		${T_ENTRADA[$xp]}|	${RAFAGA_AUX[$xp]}|	${MEMORIA_AUX[$xp]}   |    ${EN_MEMO[$xp]}	|    ${TIEMPO_FIN[$xp]}    | ${ESTADO[$xp]}"  >> informeCOLOR.txt
		echo "	---------------------------------------------------------------------"  >> informeCOLOR.txt	
	done

	echo "	-----------------------------------"  >> informeCOLOR.txt	
	echo " 	    PRO |  T RETORNO  | T ESPERA   "  >> informeCOLOR.txt
	echo "	-----------------------------------"  >> informeCOLOR.txt
	for(( xp=0 ; xp < $num_proc ; xp++ ))
	do
		if [ "${ESTADO[$xp]}" != "Bloqueado" ]
		then
			T_RETORNO[$xp]=`expr ${TIEMPO_FIN[$xp]} - ${T_ENTRADA[$xp]}`
			T_ESPERA[$xp]=`expr ${TIEMPO_FIN[$xp]} - ${T_ENTRADA[$xp]} - ${RAFAGA_AUX[$xp]}`
		else
			T_RETORNO[$xp]=0
			T_ESPERA[$xp]=0			
		fi

		T_MEDIO_R=`expr $T_MEDIO_R + ${T_RETORNO[$xp]}`
		T_MEDIO_E=`expr $T_MEDIO_E + ${T_ESPERA[$xp]}`

		echo "	       ${PROC[$xp]}|   	    ${T_RETORNO[$xp]} |    ${T_ESPERA[$xp]}"  >> informeCOLOR.txt
		echo "	-----------------------------------"  >> informeCOLOR.txt
	done
	
	echo -n "	 El tiempo medio de retorno es: "  >> informeCOLOR.txt
	echo " 		 scale = 2; $T_MEDIO_R/$num_proc"| bc  >> informeCOLOR.txt	
	echo -n " 	 El tiempo medio de espera es:  "  >> informeCOLOR.txt
	echo "		 scale = 2; $T_MEDIO_E/$num_proc"| bc  >> informeCOLOR.txt
	echo " "  >> informeCOLOR.txt
	echo " "  >> informeCOLOR.txt
}

#Imprime una tabla final con los datos de los diferentes procesos.
solucion_impresa()
{
	en_memoria
	media=0

	echo "	---------------------------------------------------------------------" 
	echo "	  PRO | T LLEGADA | RAFAGA | MEMORIA | EN MEMORIA | L TEMP | ESTADO  " 
	echo "	---------------------------------------------------------------------" 
	for(( xp=0 ; xp < $num_proc ; xp++ ))
	do
		echo "	    "${PROC[$xp]}"|		${T_ENTRADA[$xp]}|	${RAFAGA_AUX[$xp]}|	${MEMORIA_AUX[$xp]}   |    ${EN_MEMO[$xp]}	|    ${TIEMPO_FIN[$xp]}    | ${ESTADO[$xp]}"
		echo "	---------------------------------------------------------------------"		
	done

	echo "	-----------------------------------"	
	echo " 	    PRO |  T RETORNO  | T ESPERA	 "
	echo "	-----------------------------------" 
	for(( xp=0 ; xp < $num_proc ; xp++ ))
	do
		if [ "${ESTADO[$xp]}" != "Bloqueado" ]
		then
			T_RETORNO[$xp]=`expr ${TIEMPO_FIN[$xp]} - ${T_ENTRADA[$xp]}`
			T_ESPERA[$xp]=`expr ${TIEMPO_FIN[$xp]} - ${T_ENTRADA[$xp]} - ${RAFAGA_AUX[$xp]}`
		else
			T_RETORNO[$xp]=0
			T_ESPERA[$xp]=0			
		fi

		T_MEDIO_R=`expr $T_MEDIO_R + ${T_RETORNO[$xp]}`
		T_MEDIO_E=`expr $T_MEDIO_E + ${T_ESPERA[$xp]}`

		echo "	      " ${PROC[$xp]}"|   	    "${T_RETORNO[$xp]}" |   " $((${T_ESPERA[$xp]} + 1))
		echo "	-----------------------------------" 
	done
	
	echo -n " El tiempo medio de retorno es: "
	echo "  scale = 2; $T_MEDIO_R/$num_proc"| bc	
	echo -n " El tiempo medio de espera es:  "
	echo " scale = 2; $T_MEDIO_E/$num_proc"| bc
	echo " "
}

### Inicia una serie de datos de los procesos.
inicio_estado()
{
	for(( xp=0 ; xp < $num_proc ; xp++ ))
	do
		ESTADO[$xp]="Fuera de Sistema"
		EN_MEMO[$xp]="S/E"
		TIEMPO_FIN[$xp]=0
	done
}

inicio_particiones()
{
	vacias=0
	#Función modificada para que aparezca un - en la particion de memoria de un proceso cuando este ha terminado de ejecutarse
	for (( pr=0; pr<$num_proc; pr++ ))
	do
		if [[ ${ESTADO[$pr]} == "Terminado" ]]
		then
			PART[$pr]="-"
		fi
	done

	for (( pa = 0; pa < $n_par; pa++ ))
	do
		if [[ ${ESTADO[${PARTS[$pa]}]} == "Terminado" ]]
		then
			PARTS[$pa]=-1
		fi

		for (( pr=0; pr<$num_proc; pr++ ))
		do
			if [[ ${EN_MEMO[$pr]} == "Si" ]] && [[ ${PART[$pr]} == "" ]] && [[ ${PARTS[$pa]} -eq -1 ]] && [[ ${tam_par[$pa]} -ge ${MEMORIA[$pr]} ]]
			then
				PARTS[$pa]=$pr
				PART[$pr]=$pa
				NUMPART[$pr]=$pa
				continue 2
			fi
		done

		if [[ ${PARTS[$pa]} -eq -1 ]]
		then
			let vacias=vacias+1
		fi
	done	
}

#Tabla que se va mostrando durante la ejecucion de los procesos.
#Esta función también monta las barras de memoria y tiempo, la cola, y las representa.
#También calcula los tiempos de espera, retorno, ejecución y los tiempos medios.
tabla_ejecucion()
{
	#He añadido un comentario con los colores usados en el código, y acortado el array de colores repetidos dado que su funcionamiento es cíclico.
	#color=(cyan, pink, dark blue, purple, green, red)
	color=(96 95 94 35 92 91)
	en_memoria
	tesmed=0
	tretmed=0
	tsum2=0
	t_real=$(( $tiempo_transcurrido ))

	inicio_particiones

	for((xp = 0; xp < $num_proc; xp++))
	do	
		t_espera[$xp]=$(( ${T_ENTRADA[$xp]} + $(( ${TEJ[$xp]} - ${TIEMPO[$xp]} )) ))
		if [ ${t_espera[$xp]} -lt $(( $tiempo_transcurrido + 1 )) -a "${ESTADO[$xp]}" != "Terminado" ]
		then
			TES[$xp]=$(( $t_real - ${t_espera[$xp]} ))
		elif [ "${ESTADO[$xp]}" != "Terminado" ]
		then
			TES[$xp]="0"
		fi

		if [[ ${T_ENTRADA[$xp]} -gt $tiempo_transcurrido ]]
		then
			TES[$xp]="-"
		elif [[ $pvez == 0 ]]
		then
			TES[$xp]="0"
			pvez=1
		fi

		if [[ ${TES[$xp]} != "-" ]]
		then
			TESMEDIA[$tesmed]=${TES[$xp]}
			tesmed=$(( $tesmed + 1 ))
		fi
		
		TRET[$xp]=0
		if [ $t_real -ge ${T_ENTRADA[$xp]} -a "${ESTADO[$xp]}" != "Terminado" ]
		then
			TRET[$xp]=$(( $t_real - ${T_ENTRADA[$xp]} ))
		elif [ "${ESTADO[$xp]}" == "Terminado" ]
		then
			TRET[$xp]=$(( ${TEJ[$xp]} + ${TES[$xp]} ))
		fi

		if [[ ${T_ENTRADA[$xp]} -gt $tiempo_transcurrido ]]
		then
			TRET[$xp]="-"
			TREJ[$xp]="-"
		else
			if [[ ${ESTADO[$xp]} == "En espera" ]]
			then
				TREJ[$xp]="-"
			else
				TREJ[$xp]=${TIEMPO[$xp]}
			fi
		fi

		if [[ ${TREJ[$xp]} != "-" ]]
		then
			TRETMEDIA[$tretmed]=${TRET[$xp]}
			tretmed=$(( $tretmed + 1 ))
		fi
	done

	#Imprime la tabla con los 3 datos principales, y se adapta al tamaño de los mismos.
	#He modificado la parte de las particiones para mostrar el tamaño de cada una.
	imprime_cabecera
	printf " ┌────────────┬───────────────┬────────────┐\n"
	printf " │Nº Part:    │Tam Part:      │Quantum:    │\n"
	printf " │"
	printf "$n_par" 

	for ((contador_n_par = 0; contador_n_par < ( 12 - $espacios_n_par); contador_n_par++))
	do
		printf " "
	done

	printf "│"
	for tp in "${tam_par[@]}"
	do
		printf "$tp "
	done
	#for (( pa=0; pa<${#tam_par[@]}; pa++ ))
	#do
	#	printf "${tam_par[$pa]} "
	#done

	for ((contador_tam_par = 0; contador_tam_par < ( 15 - $espacios_tam_par); contador_tam_par++))
	do
		printf " "
	done

	printf "│"
	printf "$quantum"

	for ((contador_quantum = 0; contador_quantum < ( 12 - $espacios_quantum); contador_quantum++))
	do
		printf " "
	done

	printf "│\n"
	printf " └────────────┴───────────────┴────────────┘\n"

	#Tabla de datos principales del informe de color
	printf " ┌────────────┬───────────────┬────────────┐\n" >> informeCOLOR.txt
	printf " │Nº Part:    │Tam Part:      │Quantum:    │\n" >> informeCOLOR.txt
	printf " │" >> informeCOLOR.txt
	printf "$n_par"  >> informeCOLOR.txt

	for ((contador_n_par = 0; contador_n_par < ( 12 - $espacios_n_par); contador_n_par++))
	do
		printf " " >> informeCOLOR.txt
	done

	printf "│" >> informeCOLOR.txt
	for tp in "${tam_par[@]}"
	do
		printf "$tp " >> informeCOLOR.txt
	done

	for ((contador_tam_par = 0; contador_tam_par < ( 15 - $espacios_tam_par); contador_tam_par++))
	do
		printf " " >> informeCOLOR.txt
	done

	printf "│" >> informeCOLOR.txt
	printf "$quantum" >> informeCOLOR.txt

	for ((contador_quantum = 0; contador_quantum < ( 12 - $espacios_quantum); contador_quantum++))
	do
		printf " " >> informeCOLOR.txt
	done

	printf "│\n" >> informeCOLOR.txt
	printf " └────────────┴───────────────┴────────────┘\n" >> informeCOLOR.txt

	#Tabla de los 3 datos principales para el informe en blanco y negro
	printf " ┌────────────┬───────────────┬────────────┐\n" >> informeBN.txt
	printf " │Nº Part:    │Tam Part:      │Quantum:    │\n" >> informeBN.txt
	printf " │" >> informeBN.txt
	printf "$n_par"  >> informeBN.txt

	for ((contador_n_par = 0; contador_n_par < ( 12 - $espacios_n_par); contador_n_par++))
	do
		printf " " >> informeBN.txt
	done

	printf "│" >> informeBN.txt
	for tp in "${tam_par[@]}"
	do
		printf "$tp " >> informeBN.txt
	done

	for ((contador_tam_par = 0; contador_tam_par < ( 15 - $espacios_tam_par); contador_tam_par++))
	do
		printf " " >> informeBN.txt
	done

	printf "│" >> informeBN.txt
	printf "$quantum" >> informeBN.txt

	for ((contador_quantum = 0; contador_quantum < ( 12 - $espacios_quantum); contador_quantum++))
	do
		printf " " >> informeBN.txt
	done

	printf "│\n" >> informeBN.txt
	printf " └────────────┴───────────────┴────────────┘\n" >> informeBN.txt

	#Tabla principal, que se ajusta a los datos introducidos, para el informe a color
	echo -ne " ┌────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo -ne "┬────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo -ne "┬────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo -ne "┬────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo -ne "┬──────┬──────┬──────┬─────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo "┬──────────────────┐" >> informeCOLOR.txt


	echo -ne " │ Ref" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne " " >> informeCOLOR.txt
	done
	echo  -ne "│ Tll" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne " " >> informeCOLOR.txt
	done
	echo -ne "│ Tej" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne " " >> informeCOLOR.txt
	done
	echo -ne "│ Mem" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne " " >> informeCOLOR.txt
	done
	echo -ne "│ Tesp │ Tret │ Trej │ Part" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne " " >> informeCOLOR.txt
	done
	echo "│ Estado           │" >> informeCOLOR.txt


	echo -ne " ├────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo -ne "┼────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo -ne "┼────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo -ne "┼────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo -ne "┼──────┼──────┼──────┼─────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo "┼──────────────────┤" >> informeCOLOR.txt


	for((xp = 0; xp < $num_proc; xp++ ))
	do
		if [ $(( ${PROC[$xp]} - 1 )) -ge 6 ]
		then
			colimp=$(( $(( ${PROC[$xp]} - 1 )) % 6 ))
		else
			colimp=$(( ${PROC[$xp]} - 1 ))
		fi

		#Ahora los datos aparecen entablados
		printf " │ " >> informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}mP" >> informeCOLOR.txt
		printf "%02d" "${PROC[$xp]}" >> informeCOLOR.txt
		for (( l = 0; l < ($espacios_num_proc_tabla - 2); l++))
		do
			echo -ne " "
		done
		echo -ne "\e[0m" >> informeCOLOR.txt

		printf " │ " >> informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> informeCOLOR.txt
		printf "%3s" "${T_ENTRADA[$xp]}" >> informeCOLOR.txt
		echo -ne "\e[0m" >> informeCOLOR.txt

		printf " │ " >> informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> informeCOLOR.txt
		printf "%3s" "${TEJ[$xp]}" >> informeCOLOR.txt
		echo -ne "\e[0m" >> informeCOLOR.txt

		printf " │ " >> informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> informeCOLOR.txt
		printf "%3s" "${MEMORIA[$xp]}" >> informeCOLOR.txt
		echo -ne "\e[0m" >> informeCOLOR.txt

		printf " │ " >> informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> informeCOLOR.txt
		printf "%4s" "${TES[$xp]}" >> informeCOLOR.txt
		echo -ne "\e[0m" >> informeCOLOR.txt

		printf " │ " >> informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> informeCOLOR.txt
		printf "%4s" "${TRET[$xp]}" >> informeCOLOR.txt
		echo -ne "\e[0m" >> informeCOLOR.txt

		printf " │ " >> informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> informeCOLOR.txt
		printf "%4s" "${TREJ[$xp]}" >> informeCOLOR.txt
		echo -ne "\e[0m" >> informeCOLOR.txt

		printf " │ " >> informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> informeCOLOR.txt
		printf "%4s" "${PART[$xp]}" >> informeCOLOR.txt
		echo -ne "\e[0m" >> informeCOLOR.txt

		printf " │ " >> informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> informeCOLOR.txt
		if [[ ${ESTADO[$xp]} == "Ejecucion" ]]
		then
			printf "${ESTADO[$xp]}" >> informeCOLOR.txt
			echo -ne "\e[0m" >> informeCOLOR.txt
			printf "        │ " >> informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "Fuera de Sistema" ]]
		then
			printf "${ESTADO[$xp]}" >> informeCOLOR.txt
			echo -ne "\e[0m" >> informeCOLOR.txt
			printf " │ " >> informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "En pausa" ]]
		then
			printf "${ESTADO[$xp]}" >> informeCOLOR.txt
			echo -ne "\e[0m" >> informeCOLOR.txt
			printf "         │ " >> informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "En memoria" ]]
		then
			printf "${ESTADO[$xp]}" >> informeCOLOR.txt
			echo -ne "\e[0m" >> informeCOLOR.txt
			printf "       │ " >> informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "En espera" ]]
		then
			printf "${ESTADO[$xp]}" >> informeCOLOR.txt
			echo -ne "\e[0m" >> informeCOLOR.txt
			printf "        │ " >> informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "Bloqueado" ]]
		then
			printf "${ESTADO[$xp]}" >> informeCOLOR.txt
			echo -ne "\e[0m" >> informeCOLOR.txt
			printf "        │ " >> informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "Terminado" ]]
		then
			printf "${ESTADO[$xp]}" >> informeCOLOR.txt
			echo -ne "\e[0m" >> informeCOLOR.txt
			printf "        │ " >> informeCOLOR.txt
		fi
		echo -e "\e[0m" >> informeCOLOR.txt

		memlibre[$xp]=$(( ${tam_par[$i]} - ${MEMORIA[$xp]} ))
	done

	echo -ne " └────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo -ne "┴────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done

	echo -ne "┴────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo -ne "┴────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo -ne "┴──────┴──────┴──────┴─────" >> informeCOLOR.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> informeCOLOR.txt
	done
	echo "┴──────────────────┘" >> informeCOLOR.txt

	#Tabla principal, que se ajusta a los datos introducidos, para el informe a blanco y negro
	echo -ne " ┌────" >> informeBN.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo -ne "┬────" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo -ne "┬────" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo -ne "┬────" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo -ne "┬──────┬──────┬──────┬─────" >> informeBN.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo "┬──────────────────┐" >> informeBN.txt

	echo -ne " │ Ref" >> informeBN.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne " " >> informeBN.txt
	done
	echo  -ne "│ Tll" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne " " >> informeBN.txt
	done
	echo -ne "│ Tej" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne " " >> informeBN.txt
	done
	echo -ne "│ Mem" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne " " >> informeBN.txt
	done
	echo -ne "│ Tesp │ Tret │ Trej │ Part" >> informeBN.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne " " >> informeBN.txt
	done
	echo "│ Estado           │" >> informeBN.txt

	echo -ne " ├────" >> informeBN.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo -ne "┼────" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo -ne "┼────" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo -ne "┼────" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo -ne "┼──────┼──────┼──────┼─────" >> informeBN.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo "┼──────────────────┤" >> informeBN.txt

	for((xp = 0; xp < $num_proc; xp++ ))
	do
		if [ $(( ${PROC[$xp]} - 1 )) -ge 6 ]
		then
			colimp=$(( $(( ${PROC[$xp]} - 1 )) % 6 ))
		else
			colimp=$(( ${PROC[$xp]} - 1 ))
		fi

		#Ahora los datos aparecen entablados
		printf " │ " >> informeBN.txt
		echo -ne "P" >> informeBN.txt
		printf "%02d" "${PROC[$xp]}" >> informeBN.txt
		for (( l = 0; l < ($espacios_num_proc_tabla - 2); l++))
		do
			echo -ne " "
		done

		printf " │ " >> informeBN.txt
		printf "%3s" "${T_ENTRADA[$xp]}" >> informeBN.txt

		printf " │ " >> informeBN.txt
		printf "%3s" "${TEJ[$xp]}" >> informeBN.txt

		printf " │ " >> informeBN.txt
		printf "%3s" "${MEMORIA[$xp]}" >> informeBN.txt

		printf " │ " >> informeBN.txt
		printf "%4s" "${TES[$xp]}" >> informeBN.txt

		printf " │ " >> informeBN.txt
		printf "%4s" "${TRET[$xp]}" >> informeBN.txt

		printf " │ " >> informeBN.txt
		printf "%4s" "${TREJ[$xp]}" >> informeBN.txt

		printf " │ " >> informeBN.txt
		printf "%4s" "${PART[$xp]}" >> informeBN.txt

		printf " │ " >> informeBN.txt
		if [[ ${ESTADO[$xp]} == "Ejecucion" ]]
		then
			printf "${ESTADO[$xp]}" >> informeBN.txt
			printf "        │ " >> informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "Fuera de Sistema" ]]
		then
			printf "${ESTADO[$xp]}" >> informeBN.txt
			printf " │ " >> informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "En pausa" ]]
		then
			printf "${ESTADO[$xp]}" >> informeBN.txt
			printf "         │ " >> informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "En memoria" ]]
		then
			printf "${ESTADO[$xp]}" >> informeBN.txt
			printf "       │ " >> informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "En espera" ]]
		then
			printf "${ESTADO[$xp]}" >> informeBN.txt
			printf "        │ " >> informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "Bloqueado" ]]
		then
			printf "${ESTADO[$xp]}" >> informeBN.txt
			printf "        │ " >> informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "Terminado" ]]
		then
			printf "${ESTADO[$xp]}" >> informeBN.txt
			printf "        │ " >> informeBN.txt
		fi
		echo -e "" >> informeBN.txt

		memlibre[$xp]=$(( ${tam_par[$i]} - ${MEMORIA[$xp]} ))
	done

	echo -ne " └────" >> informeBN.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo -ne "┴────" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> informeBN.txt
	done

	echo -ne "┴────" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo -ne "┴────" >> informeBN.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo -ne "┴──────┴──────┴──────┴─────" >> informeBN.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> informeBN.txt
	done
	echo "┴──────────────────┘" >> informeBN.txt

	#Tabla principal, que se ajusta a los datos introducidos.
	#Impresión de la parte de arriba de la tabla
	echo -ne " ┌────"
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─"
	done
	echo -ne "┬────"
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─"
	done
	echo -ne "┬────"
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─"
	done
	echo -ne "┬────"
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─"
	done
	echo -ne "┬──────┬──────┬──────┬─────"
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─"
	done
	echo "┬──────────────────┐"


	echo -ne " │ Ref"
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne " "
	done
	echo  -ne "│ Tll"
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne " "
	done
	echo -ne "│ Tej"
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne " "
	done
	echo -ne "│ Mem"
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne " "
	done
	echo -ne "│ Tesp │ Tret │ Trej │ Part"
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne " "
	done
	echo "│ Estado           │"

	echo -ne " ├────"
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─"
	done
	echo -ne "┼────"
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─"
	done
	echo -ne "┼────"
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─"
	done
	echo -ne "┼────"
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─"
	done
	echo -ne "┼──────┼──────┼──────┼─────"
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─"
	done
	echo "┼──────────────────┤"

	for((xp = 0; xp < $num_proc; xp++ ))
	do
		if [ $(( ${PROC[$xp]} - 1 )) -ge 6 ]
		then
			colimp=$(( $(( ${PROC[$xp]} - 1 )) % 6 ))
		else
			colimp=$(( ${PROC[$xp]} - 1 ))
		fi

		#Impresión de los procesos y sus datos en la tabla
		#Ahora los datos aparecen entablados
		printf " │ "
		echo -ne "\e[${color[$colimp]}mP"
		printf "%02d" "${PROC[$xp]}"
		for (( l = 0; l < ($espacios_num_proc_tabla - 2); l++))
		do
			echo -ne " "
		done
		echo -ne "\e[0m"

		printf " │ "
		echo -ne "\e[${color[$colimp]}m"
		printf "%3s" "${T_ENTRADA[$xp]}"

		for ((a = 0; a < ESPACIOSTLL[$xp]; a++))
		do
			echo -ne " "
		done

		echo -ne "\e[0m"

		printf " │ "
		echo -ne "\e[${color[$colimp]}m"
		printf "%3s" "${TEJ[$xp]}"

		for ((b = 0; b < ESPACIOSTEJ[$xp]; b++))
		do
			echo -ne " "
		done

		echo -ne "\e[0m"

		printf " │ "
		echo -ne "\e[${color[$colimp]}m"
		printf "%3s" "${MEMORIA[$xp]}"

		for ((c = 0; c < ESPACIOSMEM[$xp]; c++))
		do
			echo -ne " "
		done

		echo -ne "\e[0m"

		printf " │ "
		echo -ne "\e[${color[$colimp]}m"
		printf "%4s" "${TES[$xp]}"
		echo -ne "\e[0m"

		printf " │ "
		echo -ne "\e[${color[$colimp]}m"
		printf "%4s" "${TRET[$xp]}"
		echo -ne "\e[0m"

		printf " │ "
		echo -ne "\e[${color[$colimp]}m"
		printf "%4s" "${TREJ[$xp]}"
		echo -ne "\e[0m"

		printf " │ "
		echo -ne "\e[${color[$colimp]}m"
		printf "%4s" "${PART[$xp]}"
		echo -ne "\e[0m"

		printf " │ "
		echo -ne "\e[${color[$colimp]}m"
		if [[ ${ESTADO[$xp]} == "Ejecucion" ]]
		then
			printf "${ESTADO[$xp]}"
			echo -ne "\e[0m"
			printf "        │ "
		fi
		if [[ ${ESTADO[$xp]} == "Fuera de Sistema" ]]
		then
			printf "${ESTADO[$xp]}"
			echo -ne "\e[0m"
			printf " │ "
		fi
		if [[ ${ESTADO[$xp]} == "En pausa" ]]
		then
			printf "${ESTADO[$xp]}"
			echo -ne "\e[0m"
			printf "         │ "
		fi
		if [[ ${ESTADO[$xp]} == "En memoria" ]]
		then
			printf "${ESTADO[$xp]}"
			echo -ne "\e[0m"
			printf "       │ "
		fi
		if [[ ${ESTADO[$xp]} == "En espera" ]]
		then
			printf "${ESTADO[$xp]}"
			echo -ne "\e[0m"
			printf "        │ "
		fi
		if [[ ${ESTADO[$xp]} == "Bloqueado" ]]
		then
			printf "${ESTADO[$xp]}"
			echo -ne "\e[0m"
			printf "        │ "
		fi
		if [[ ${ESTADO[$xp]} == "Terminado" ]]
		then
			printf "${ESTADO[$xp]}"
			echo -ne "\e[0m"
			printf "        │ "
		fi
		echo -e "\e[0m"

		memlibre[$xp]=$(( ${tam_par[$i]} - ${MEMORIA[$xp]} ))
	done

	#Impresión de la parte baja de la tabla
	echo -ne " └────"
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─"
	done
	echo -ne "┴────"
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─"
	done

	echo -ne "┴────"
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─"
	done
	echo -ne "┴────"
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─"
	done
	echo -ne "┴──────┴──────┴──────┴─────"
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─"
	done
	echo "┴──────────────────┘"
	
	mediaret=0
	mediaesp=0
	
	for (( buclemedia = 0; buclemedia < $tesmed; buclemedia++ ))
	do
		mediaesp=$(( $mediaesp + ${TESMEDIA[$buclemedia]} ))
	done
	for (( buclemedia2 = 0; buclemedia2 < $tretmed; buclemedia2++ ))
	do
		mediaret=$(( $mediaret + ${TRETMEDIA[$buclemedia2]} ))
	done

	#Representación de los tiempos medios
	if [[ $tesmed == 0 ]]
	then
		printf " Tesp medio = 0.00\t"
		printf " Tesp medio = 0.00\t" >> informeCOLOR.txt
		printf " Tesp medio = 0.00\t" >> informeBN.txt
	else
		LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $(bc <<< scale=2\;$mediaesp/$tesmed)
		LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $(bc <<< scale=2\;$mediaesp/$tesmed) >> informeCOLOR.txt
		LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $(bc <<< scale=2\;$mediaesp/$tesmed) >> informeBN.txt
	fi
	if [[ $tretmed == 0 ]]
	then
		printf " Tret medio = 0.00\n"
		printf " Tret medio = 0.00\n" >> informeCOLOR.txt
		printf " Tret medio = 0.00\n" >> informeBN.txt
	else
		LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $(bc <<< scale=2\;$mediaret/$tretmed)
		LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $(bc <<< scale=2\;$mediaret/$tretmed) >> informeCOLOR.txt
		LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $(bc <<< scale=2\;$mediaret/$tretmed) >> informeBN.txt
	fi

	echo -n " Cola RR: "
	echo -n " Cola RR: " >> informeCOLOR.txt
	echo -n " Cola RR: " >> informeBN.txt
	for(( i = 1; i < ${#colaprocs[@]}; i++ ))
	do
		if [ $(( ${PROC[${colaprocs[$i]}]} - 1 )) -ge 6 ]
		then
			colimp=$(( $(( ${PROC[${colaprocs[$i]}]} - 1 )) % 6 ))
		else
			colimp=$(( ${PROC[${colaprocs[$i]}]} - 1 ))
		fi

		printf "\e[${color[$colimp]}mP%02d$resetColor " "${PROC[${colaprocs[$i]}]}"
		printf "\e[${color[$colimp]}mP%02d$resetColor " "${PROC[${colaprocs[$i]}]}" >> informeCOLOR.txt
		printf "P%02d " "${PROC[${colaprocs[$i]}]}" >> informeBN.txt
	done
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	
	contmemo=0

	#Cadena de procesos en la BM.
	cad_proc_bm=""

	#Cadena de cuadrados de colores en la BM.
	cad_mem_col=""

	#Cadena de cuadrados en blanco y negro en la BM.
	cad_mem_byn=""

	#Cadena de los tamaños de memoria en la BM.
	cad_tam_mem=""

	#Cadena de particiones en la BM.
	cad_particiones=""

	#Espacio de separación.
	cad_espacio=" "

	#Variable que indica cuántos procesos están fuera del sistema.
	fuera_sist=0

	#Columnas que quedan en la consola a la derecha de la barra inicial en la BM.
	columnas_bm=$(( $(tput cols) - 5 ))

	#Cadena de cuadrados de colores de la BT.
	cad_col_bt=0

	#Cadena de procesos de la BT.
	cad_proc_bt=0

	#Cadena de tiempo de la BT.
	cad_tem_bt=0

	#Caracteres de justificado de la cadena de particiones.
	carac_just_cad_part=0

	#Caracteres de justificado de la cadena de cuadrados. 
	carac_just_cad_cua=0

	#Caracteres de justificado de la cadena de procesos.
	carac_just_cad_proc=0

	#Caracteres de justificado de la cadena de tamaño de la memoria.
	carac_just_cad_mem=0 
		
	for ((pa=0; pa<$n_par; pa++))
	do

		## Montaje de la cadena de particiones en la barra de memoria.
		cad_particiones=${cad_particiones[@]}"Part $(($pa+1))" 	#Añado el numero de la partición.
		for (( esp=0; esp<(${tam_par[$pa]}*3-6); esp++ ))
		do
			cad_particiones=${cad_particiones[@]}" "			#Añado espacios hasta completar el tamaño de la partición.
		done
		if [[ $pa -ne $(($n_par-1)) ]]							#Si no es la última partición,
		then										
			cad_particiones=${cad_particiones[@]}" "			#Añado un espacio adicional entre particiones.
		else 
			cad_particiones=${cad_particiones[@]}"|"			#Si es la última, añado una barra.
		fi


		## Montaje de la cadena de procesos en la barra de memoria.
		if [[ ${PARTS[$pa]} -ne -1 ]]									#Si tiene un proceso,
		then
			if [[ ${#PARTS[$pa]} -eq 1 ]]								#Si el proceso tiene un caracter,
			then								
				cad_proc_bm=${cad_proc_bm[@]}"P0$((${PARTS[$pa]}+1))"	#Añado el numero del proceso con un cero delante.
			else 														#Si tiene más de un caracter,
				cad_proc_bm=${cad_proc_bm[@]}"P${PARTS[$pa]}"			#Añado el número del proceso sin ceros delante.
			fi

			for (( esp=0; esp<(${tam_par[$pa]}*3-3); esp++ ))			
			do
				cad_proc_bm=${cad_proc_bm[@]}" "						#Añado espacios hasta completar el tamaño de la partición.
			done
		else 															#Si no tiene un proceso,
			for (( esp=0; esp<${tam_par[$pa]}*3; esp++ ))			
			do
				cad_proc_bm=${cad_proc_bm[@]}" "						#Añado espacios hasta completar el tamaño de la partición.
			done
		fi
		if [[ $pa -ne $(($n_par-1)) ]]									#Si no es la última partición,
		then										
			cad_proc_bm=${cad_proc_bm[@]}" "							#Añado un espacio adicional entre particiones.
		else 
			cad_proc_bm=${cad_proc_bm[@]}"|"							#Si es la última, añado una barra.
		fi


		## Montaje de la cadena de cuadros en la barra de memoria.
		if [[ ${PARTS[$pa]} -ne -1 ]]											#Si tiene un proceso,
		then
			for (( tam_pr=0; tam_pr<${MEMORIA[${PARTS[$pa]}]}; tam_pr++ ))		
			do
				cad_mem_col=${cad_mem_col[@]}"\e[${color[$colimp]}m\u2588\e[0m"	#Añado 3 cuadrados de color por lo que ocupe en memoria el proceso. 
				cad_mem_col=${cad_mem_col[@]}"\e[${color[$colimp]}m\u2588\e[0m"
				cad_mem_col=${cad_mem_col[@]}"\e[${color[$colimp]}m\u2588\e[0m"
				cad_mem_byn=${cad_mem_byn[@]}"\u2588"							#Añado 3 cuadrados blancos por lo que ocupe en memoria el proceso.
				cad_mem_byn=${cad_mem_byn[@]}"\u2588"
				cad_mem_byn=${cad_mem_byn[@]}"\u2588"
			done
			for (( esp=0; esp<$(( ${tam_par[$pa]} - ${MEMORIA[${PARTS[$pa]}]} )); esp++ ))	
			do
				cad_mem_col=${cad_mem_col[@]}"\u2588"							#Añado 3 cuadrados blancos hasta completar la partición. 
				cad_mem_col=${cad_mem_col[@]}"\u2588"
				cad_mem_col=${cad_mem_col[@]}"\u2588"
				cad_mem_byn=${cad_mem_byn[@]}"\u2588"							#Añado 3 cuadrados blancos hasta completar la partición.
				cad_mem_byn=${cad_mem_byn[@]}"\u2588"
				cad_mem_byn=${cad_mem_byn[@]}"\u2588"
			done
		else 																	#Si no tiene un proceso,
			for (( esp=0; esp<${tam_par[$pa]}*3; esp++ ))			
			do
				cad_mem_col=${cad_mem_col[@]}"\u2588"							#Añado cuadrados blancos hasta completar la partición.
				cad_mem_byn=${cad_mem_byn[@]}"\u2588"
			done
		fi
		if [[ $pa -ne $(($n_par-1)) ]]											#Si no es la última partición,
		then										
			cad_mem_col=${cad_mem_col[@]}" "									#Añado un espacio adicional entre particiones.
			cad_mem_byn=${cad_mem_byn[@]}" "
		else 
			cad_mem_col=${cad_mem_col[@]}"| M=$memoria_total"					#Si es la última, añado una barra y la memoria total.
			cad_mem_byn=${cad_mem_byn[@]}"| M=$memoria_total"
		fi
		

		

	done

	#Esta parte crea las barras verticales y la memoria total al final de la Banda de Memoria
	cad_tam_mem[$cad_tem_bt]=${cad_tam_mem[$cad_tem_bt]}"|"
	
	## Representacion de la Barra de Memoria
	echo -e "    |${cad_particiones[@]}"
	echo -e "    |${cad_particiones[@]}" >> informeCOLOR.txt
	echo -e "    |${cad_particiones[@]}" >> informeBN.txt
	cad_particiones=""

	echo -e "    |${cad_proc_bm[@]}"
	echo -e "    |${cad_proc_bm[@]}" >> informeCOLOR.txt
	echo -e "    |${cad_proc_bm[@]}" >> informeBN.txt
	cad_proc_bm=""

	echo -e " BM |${cad_mem_col[@]}"
	echo -e " BM |${cad_mem_col[@]}" >> informeCOLOR.txt
	echo -e " BM |${cad_mem_byn[@]}" >> informeBN.txt
	cad_mem_col=""
	cad_mem_byn=""

	for(( i = 0, j = 0, k = 0; i <= $cad_col_bt, j <= $cad_proc_bt, k <= $cad_tem_bt; i++, j++, k++ ))
	do
		#Representacion de la Barra de Memoria
		if [[ $j == 0 ]]
		then

			echo -e "    |${cad_tam_mem[$k]}"
			echo -e "    |${cad_tam_mem[$k]}" >> informeCOLOR.txt
			echo -e "    |${cad_tam_mem[$k]}" >> informeBN.txt
		else
			echo -e "     ${cad_tam_mem[$k]}"
			echo -e "     ${cad_tam_mem[$k]}" >> informeCOLOR.txt
			echo -e "     ${cad_tam_mem[$k]}" >> informeBN.txt
		fi
		cad_tam_mem[$k]=""
	done
		
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt

	for (( i = 0, j = 0; i <= $const, j <= $constb; i++, j++ ))
	do

	#Comandos que ajustan las 3 lineas verticales del final de la barra de tiempo
	if [[ $primvez = 0 ]]
	then

	cadtiempo[$j]=" | T=$tiempo_transcurrido"
	cadtiempo2[$j]=" |"
	cadtiempobn[$j]=" | T=$tiempo_transcurrido"
	cadtiempo2bn[$j]=" |"
	cadtiempo3[$j]=" |"
	fi

	if [[ $primvez = 1 ]]
	then
	cadtiempo[$j]=${cad[$j]}"    | T=$tiempo_transcurrido"
	cadtiempo2[$j]=${cad2[$j]}" |"
	cadtiempobn[$j]=${cadbn[$j]}"    | T=$tiempo_transcurrido"
	cadtiempo2bn[$j]=${cad2bn[$j]}" |"
	cadtiempo3[$j]=${cad3[$j]}" |"
	fi

		#Representacion de la Barra de tiempo
	if [[ $i == 0 ]]
	then
		echo -e "    |${cadtiempo2[$j]}"
		echo -e "    |${cadtiempo2[$j]}" >> informeCOLOR.txt
		echo -e "    |${cadtiempo2bn[$i]}" >> informeBN.txt
	else
		echo -e "     ${cadtiempo2[$j]}"
		echo -e "     ${cadtiempo2[$j]}" >> informeCOLOR.txt
		echo -e "     ${cadtiempo2bn[$i]}" >> informeBN.txt
	fi
		if [[ $i == 0 ]]
		then
			echo -e " BT |${cadtiempo[$i]}"
			echo -e " BT |${cadtiempo[$i]}" >> informeCOLOR.txt
			echo -e " BT |${cadtiempobn[$i]}" >> informeBN.txt
		else
			echo -e "     ${cadtiempo[$i]}"
			echo -e "     ${cadtiempo[$i]}" >> informeCOLOR.txt
			echo -e "     ${cadtiempobn[$i]}" >> informeBN.txt
		fi

	if [[ $i == 0 ]]
	then
		echo -e "    |${cadtiempo3[$j]}"
		echo -e "    |${cadtiempo3[$j]}" >> informeCOLOR.txt
		echo -e "    |${cadtiempo3[$j]}" >> informeBN.txt
	else
		echo -e "     ${cadtiempo3[$j]}"
		echo -e "     ${cadtiempo3[$j]}" >> informeCOLOR.txt
		echo -e "     ${cadtiempo3[$j]}" >> informeBN.txt
	fi
	done

	for(( i = 0; i < 20; i++ ))
	do
		cad[$i]=""
		cad2[$i]=""
		cad3[$i]=""
	done
	
	echo ""
	echo "---------------------------------------------------------" >> informeCOLOR.txt
	echo "---------------------------------------------------------" >> informeBN.txt
	#Toma de decisión de cómo se va a actualizar el siguiente evento en función de lo elegido
	if [ $opcion_ejecucion == 1 ]
	then
		read -p " Pulsa Intro para continuar"

	fi

	if [ $opcion_ejecucion == 2 ]
	then
		echo " El siguiente evento ocurrirá en $segundos_evento segundos..."
		sleep $segundos_evento

	fi
	primvez=1
}

### Función que calcula el mayor dato de todos los procesos para cada dato (por ejemplo el mayor tiempo de llegada de 12 procesos) para ajustar la tabla a los datos introducidos.
mayor_dato_procesos()
{
	for (( contadortll = 0; contadortll < num_proc; contadortll++))
	do
		if [[ $contadortll == 0 ]]
		then
			mayortll=${T_ENTRADA_I[0]}
		fi
		if [[ $mayortll -lt ${T_ENTRADA_I[$contadortll]} ]]
		then
			mayortll=${T_ENTRADA_I[$contadortll]}
		fi
	done

	for (( contadortej = 0; contadortej < num_proc; contadortej++))
	do
		if [[ $contadortej == 0 ]]
		then
			mayortej=${PROCESOS_I[0]}
		fi
		if [[ $mayortej -lt ${PROCESOS_I[$contadortej]} ]]
		then
			mayortej=${PROCESOS_I[$contadortej]}
		fi
	done

	for (( contadormem = 0; contadormem < num_proc; contadormem++))
	do
		if [[ $contadormem == 0 ]]
		then
			mayormem=${MEMORIA_I[0]}
		fi
		if [[ $mayormem -lt ${MEMORIA_I[$contadormem]} ]]
		then
			mayormem=${MEMORIA_I[$contadormem]}
		fi
	done
}

### Función que calcula el número de espacios en base a las cifras para una tabla equilibrada.
#He modificado la parte de las particiones para tener en cuenta que se muestra el tamaño de cada partición mas un espacio.
calcula_espacios()
{

	espacios_n_par=${#n_par}

	if [[ $espacios_n_par == 1 ]] || [[ $espacios_n_par == 2 ]] || [[ $espacios_n_par == 3 ]] || [[ $espacios_n_par == 4 ]]
	then
		espacios_n_par_tabla=4
	else
		espacios_n_par_tabla=$espacios_n_par
	fi

	let espacios_tam_par=${#tam_par[@]}*2
	espacios_quantum=${#quantum}
	espacios_mayortll=${#mayortll}

	if [[ $espacios_mayortll == 1 ]] || [[ $espacios_mayortll == 2 ]] || [[ $espacios_mayortll == 3 ]]
	then
		espacios_mayortll_tabla=3
	else
		espacios_mayortll_tabla=$espacios_mayortll
	fi

	espacios_mayormem=${#mayormem}

	if [[ $espacios_mayormem == 1 ]] || [[ $espacios_mayormem == 2 ]] || [[ $espacios_mayortej == 3 ]]
	then
		espacios_mayormem_tabla=3
	else
		espacios_mayormem_tabla=$espacios_mayormem
	fi

	espacios_mayortej=${#mayortej}

	if [[ $espacios_mayortej == 1 ]] || [[ $espacios_mayortej == 2 ]] || [[ $espacios_mayormem == 3 ]]
	then
		espacios_mayortej_tabla=3
	else
		espacios_mayortej_tabla=$espacios_mayortej
	fi

	espacios_num_proc=${#num_proc}

	if [[ $espacios_num_proc == 1 ]] || [[ $espacios_num_proc == 2 ]]
	then
		espacios_num_proc_tabla=2
	else
		espacios_num_proc_tabla=$espacios_num_proc
	fi
		
	espacios_memoria_total=${#memoria_total}

	for((contespacios1 = 0; contespacios1 < num_proc; contespacios1++))
	do
		chartll=${#T_ENTRADA_I[contespacios1]}

		if [[ $chartll == 1 ]] || [[ $chartll == 2 ]] || [[ $chartll == 3 ]]
		then
			CARACTERESTLL[$contespacios1]=3
		else
			CARACTERESTLL[$contespacios1]=$chartll
		fi

		ESPACIOSTLL[$contespacios1]=$(($espacios_mayortll_tabla - ${CARACTERESTLL[$contespacios1]}))
	done

	for((contespacios2 = 0; contespacios2 < num_proc; contespacios2++))
	do
		chartej=${#PROCESOS_I[contespacios2]}

		if [[ $chartej == 1 ]] || [[ $chartej == 2 ]] || [[ $chartej == 3 ]]
		then
			CARACTERESTEJ[$contespacios2]=3
		else
			CARACTERESTEJ[$contespacios2]=$chartej
		fi

		ESPACIOSTEJ[$contespacios2]=$(($espacios_mayortej_tabla - ${CARACTERESTEJ[$contespacios2]}))
	done

	for((contespacios3 = 0; contespacios3 < num_proc; contespacios3++))
	do
		charmem=${#MEMORIA_I[contespacios3]}

		if [[ $charmem == 1 ]] || [[ $charmem == 2 ]] || [[ $charmem == 3 ]]
		then
			CARACTERESMEM[$contespacios3]=3
		else
			CARACTERESMEM[$contespacios3]=$charmem
		fi

		ESPACIOSMEM[$contespacios3]=$(($espacios_mayormem_tabla - ${CARACTERESMEM[$contespacios1]}))
	done
}

### Actualiza la linea de tiempo, los cuadraditos de colores.
#He cambiado algunos comandos expr por let.
actualizar_linea()
{ 
	fuera_sist=0

	for((xp = 0; xp < $num_proc; xp++))
	do
		if [[ ${ESTADO[$xp]} == "Fuera de Sistema" ]]
		then
			let fuera_sist=fuera_sist+1
		fi
	done

	if [ $(( ${PROC[$proc_actual]} - 1 )) -ge 6 ]
	then
		colimp=$(( $(( ${PROC[$proc_actual]} - 1 )) % 6 ))
	else
		colimp=$(( ${PROC[$proc_actual]} - 1 ))
	fi


	if [[ $ultvez == 0 ]]
	then
		#Cuadrados grises hasta que llegue el primer proceso
		if [[ $fuera_sist == $num_proc ]]
		then
			for(( k = 0; k < ${T_ENTRADA[0]}; k++ ))
			do
				for(( l = 0; l < 3; l++ ))
				do
					cad1=$cad1"\u2588-"
					cad1bn=$cad1bn"\u2588-"
					let escritos=escritos+1
				done
			done
		elif [[ -z $proc_actual ]] #Si no hay procesos
		then
			for((l = 0; l < 3; l++))
			do
				cad1=$cad1"\u2588-"
				cad1bn=$cad1bn"\u2588-"
				let escritos=escritos+1
			done
		else #Si hay procesos
			for((k = 0; k < $yomismo; k++))
			do
				for((l = 0; l < 3; l++))
				do
					cad1=$cad1"\e[${color[$colimp]}m\u2588\e[0m-"
					cad1bn=$cad1bn"\u2588-"
					let escritos=escritos+1
				done
			done
		fi
	fi

	IFS='-' read -r -a cadarray <<< "$cad1"
	IFS='-' read -r -a cadbnarray <<< "$cad1bn"

	let const=escritos/columnas
	const1=0

	while [ $const1 -le $const ]
	do
		vali=$(( 0 + $columnas * $const1 ))
		valcol=$(( $columnas * $(( $const1 + 1 )) ))
		for((i = $vali; i < $valcol; i++))
		do
			lin=$lin${cadarray[$i]}
			linbn=$linbn${cadbnarray[$i]}
		done
		cad[$const1]=$lin
		cadbn[$const1]=$linbn
		let const1=$const1+1
		lin=""
		linbn=""
	done
}

### Actualiza el texto de la linea de tiempo.
actualizar_ltsec()
{ 
	fuera_sist=0

	for((xp = 0; xp < $num_proc; xp++))
	do
		if [[ ${ESTADO[$xp]} == "Fuera de Sistema" ]]
		then
			let fuera_sist=fuera_sist+1
		fi
		if [[ $xp != $proc_actual ]]
		then
			EJEC[$xp]=0
		fi	
	done

	if [ $(( ${PROC[$proc_actual]} - 1 )) -ge 6 ]
	then
		colimp=$(( $(( ${PROC[$proc_actual]} - 1 )) % 6 ))
	else
		colimp=$(( ${PROC[$proc_actual]} - 1 ))
	fi

	if [[ $ultvez == 0 ]]
	then
		#Separacion inicial
		if [[ $fuera_sist == $num_proc ]]
		then
			for(( k = 0; k < ${T_ENTRADA[0]}; k++ ))
			do
				for(( l = 0; l < 3; l++ ))
				do
					cad2b=$cad2b" -"
					cad2bbn=$cad2bbn" -"
					let saltocad=saltocad+1
				done
				if [[ $k == 0 ]]
				then
					cad3b=$cad3b" - - -"
					let saltocad=saltocad+1
				else
					for(( l = 0; l < 3; l++ ))
					do
						cad3b=$cad3b" -"
						let saltocad=saltocad+1
					done
				fi
			done
		elif [[ -z $proc_actual ]]
		then
			if [[ $nulcontrol == 0 ]]
			then
				if [[ $tiempo_transcurrido -le 9 ]]
				then
					cad3b=$cad3b" - -$tiempo_transcurrido-"
				elif [[ $tiempo_transcurrido -le 99 ]]
				then
					vart=$tiempo_transcurrido
					t1="${vart:0:1}"
					t2="${vart:1:2}"
					cad3b=$cad3b" -$t1-$t2-"
				else
					vart=$tiempo_transcurrido
					t1="${vart:0:1}"
					t2="${vart:1:2}"
					t3="${vart:2:3}"
					cad3b=$cad3b"$t1-$t2-$t3-"
				fi
				for((l = 0; l < 3; l++))
				do
					cad2b=$cad2b" -"
					cad2bbn=$cad2bbn" -"
				done
				let saltocadc=saltocadc+3
			else
				for((l = 0; l < 3; l++))
				do
					cad2b=$cad2b" -"
					cad2bbn=$cad2bbn" -"
					cad3b=$cad3b" -"
					let saltocad=saltocad+1
					let saltocadc=saltocadc+1
				done
			fi
		else
			#Representacion con color del texto de la BT
			#Ahora aparece en el texto de la BT un proceso y el tiempo transcurrido si termina su cuantum, aunque sea el unico proceso en memoria.
			if [[ ${EJEC[$proc_actual]} == 0 ]] || [[ $((${T_EJEC[$proc_actual]} % $quantum)) = 1 ]] || [[ $quantum = 1 ]]
			then
				if [[ ${PROC[$proc_actual]} -le 9 ]]
				then
					cad2b=$cad2b"\e[${color[$colimp]}mP\e[0m-\e[${color[$colimp]}m0\e[0m-\e[${color[$colimp]}m${PROC[$proc_actual]}\e[0m-"
					cad2bbn=$cad2bbn"P-0-${PROC[$proc_actual]}-"
				else 
					varproc=${PROC[$proc_actual]}
					fchar="${varproc:0:1}"
					schar="${varproc:1:2}"
					cad2b=$cad2b"\e[${color[$colimp]}mP\e[0m-\e[${color[$colimp]}m$fchar\e[0m-\e[${color[$colimp]}m$schar\e[0m-"
					cad2bbn=$cad2bbn"P-$fchar-$schar-"
				fi
				if [[ $tiempo_transcurrido -le 9 ]]
				then
					cad3b=$cad3b" - -$tiempo_transcurrido-"
				elif [[ $tiempo_transcurrido -le 99 ]]
				then
					vart=$tiempo_transcurrido
					t1="${vart:0:1}"
					t2="${vart:1:2}"
					cad3b=$cad3b" -$t1-$t2-"
				else
					vart=$tiempo_transcurrido
					t1="${vart:0:1}"
					t2="${vart:1:2}"
					t3="${vart:2:3}"
					cad3b=$cad3b"$t1-$t2-$t3-"
				fi
				saltocad=$(( $saltocad + 3 ))
				saltocadc=$(( $saltocadc + 3 ))
			else
				for((l = 0; l < 3; l++))
				do
					cad2b=$cad2b" -"
					cad2bbn=$cad2bbn" -"
					cad3b=$cad3b" -"
					let saltocad=saltocad+1
					let saltocadc=saltocadc+1
				done
			fi
		fi
	fi

	IFS='-' read -r -a cad2array <<< "$cad2b"
	IFS='-' read -r -a cad2bnarray <<< "$cad2bbn"
	IFS='-' read -r -a cad3array <<< "$cad3b"

	constb=$(( $saltocad / $columnas ))
	const1b=0
	constc=$(( $saltocadc / $columnas ))
	const1c=0

	while [ $const1b -le $constb ]
	do
		valib=$(( $columnas * $const1b ))
		valcolb=$(( $columnas * $(( $const1b + 1 )) ))
		for((i = $valib; i < $valcolb; i++))
		do
			linb=$linb${cad2array[$i]}
			linbbn=$linbbn${cad2bnarray[$i]}
		done
		cad2[$const1b]=$linb
		cad2bn[$const1b]=$linbbn
		const1b=$(( $const1b + 1 ))
		linb=""
		linbbn=""
	done

	while [ $const1c -le $constc ]
	do
		valic=$(( $columnas * $const1c ))
		valcolc=$(( $columnas * $(( $const1c + 1 )) ))
		for((i = $valic; i < $valcolc; i++))
		do
			linc=$linc${cad3array[$i]}
		done
		cad3[$const1c]=$linc
		const1c=$(( $const1c + 1 ))
		linc=""
	done

	if [[ $tablapvez == 0 ]]
	then
		EJEC[$proc_actual]=1
	fi

}


### Función para guardar datos en un fichero con nombre elegido (terminará en .txt).
#He eliminado las funciones "meterAficheroUltimos" y "meterAficheroNuevo" y las he agrupado en ésta, dado que al seleccionar la opción ya se puede pasar como parámetro datos.txt.
meterAfichero()
{
	#rm datos.txt (única diferencia entre métodos)
	#Datos principales.
	echo "Datos iniciales (Particiones Tamaño Quantum)" > "$1".txt
	echo "$n_par ${tam_par[@]} $quantum" >> "$1".txt
	echo "Procesos (T-Entrada Rafaga Memoria)" >> "$1".txt
	#Bucle para meter los datos de cada proceso.
	for(( pr = 0; pr < $num_proc; pr++ ))
	do
		echo "${T_ENTRADA_I[$pr]} ${PROCESOS_I[$pr]} ${MEMORIA_I[$pr]}" >> "$1".txt
	done
}


### Función para guardar datos en un fichero con nombre elegido (terminará en RNG.txt para que no aparezca en los listados de ficheros no aleatorios).
#He eliminado las funciones "meterAficheroUltimos_aleatorio" y "meterAficheroNuevo_aleatorio" y las he agrupado en ésta, dado que al seleccionar la opción ya se puede pasar como parámetro datos.txt.
meterAficheroAleatorio()
{
	echo "Rangos del número de particiones" > "$1"RNG.txt
	echo "$n_par_min $n_par_max" >> "$1"RNG.txt
	echo "Rangos del tamaño de particiones" >> "$1"RNG.txt
	echo "$tam_par_min $tam_par_max" >> "$1"RNG.txt
	echo "Rangos del quantum" >> "$1"RNG.txt
	echo "$quantum_min $quantum_max" >> "$1"RNG.txt
	echo "Rango del número de procesos" >> "$1"RNG.txt
	echo "$num_proc_min $num_proc_max" >> "$1"RNG.txt
	echo "Rangos del tiempo de llegada)" >> "$1"RNG.txt
	echo "$entrada_min $entrada_max" >> "$1"RNG.txt
	echo "Rangos del tiempo de ejecución" >> "$1"RNG.txt
	echo "$rafaga_min $rafaga_max" >> "$1"RNG.txt
	echo "Rangos de la memoria de cada proceso" >> "$1"RNG.txt
	echo "$memo_proc_min $memo_proc_max" >> "$1"RNG.txt
}


### Setea valores al inicio del algoritmo.
inicializar()
{
	inicio_estado

	for((xp = 0; xp < $num_proc; xp++))
	do
		EN_COLA[$xp]="No"
		contrcad[$xp]=0
		contrcad2[$xp]=0
		EJECUTADO[$xp]=0
		T_EJEC[$xp]=0
		TIEMPO[$xp]=${TEJ[$xp]}
		EN_COLA[$xp]="No"
		EJEC[$xp]=0
	done

	for (( i = 0; i < $n_par; i++ ))
	do
		PARTS[$i]=-1
	done
}

### Meter en memoria un proceso.
meterenmemoVIEJO()
{
	for(( xp = 0; xp < $num_proc; xp++ ))
	do
		if [[ $vacias -gt 0 ]]
		then
			if [[ ${TIEMPO[$xp]} != 0 ]] && [[ $tiempo_transcurrido -ge ${T_ENTRADA[$xp]} ]] && [[ ${EN_MEMO[$xp]} == "S/E" ]] 
			then
				EN_MEMO[$xp]="Si"
				let valor=valor+1
				let vacias=vacias-1
			elif [[ $tiempo_transcurrido -lt ${T_ENTRADA[$xp]} ]]
			then
				EN_MEMO[$xp]="S/E"
			fi
		fi
	done
}

### Comprueba si un proceso puede entrar en memoria.
meterenmemo()
{
	for(( pr = 0; pr < $num_proc; pr++ ))
	do
		if [[ $vacias -gt 0 ]]
		then
			if [[ ${TIEMPO[$pr]} != 0 ]] && [[ $tiempo_transcurrido -ge ${T_ENTRADA[$pr]} ]] && [[ ${EN_MEMO[$pr]} == "S/E" ]] 
			then
				for (( pa=0; pa<n_par; pa++ ))
				do
					if [[ ${PARTS[$pa]} -eq -1 ]] && [[ ${MEMORIA[$pr]} -le ${tam_par[$pa]} ]]
					then
						EN_MEMO[$pr]="Si"
						let valor=valor+1
						let vacias=vacias-1
					else
						EN_MEMO[$pr]="S/E"
					fi
				done
			elif [[ $tiempo_transcurrido -lt ${T_ENTRADA[$pr]} ]]
			then
				EN_MEMO[$pr]="S/E"
			fi
		fi
	done
}

### Asigna los estados a los procesos.
asignar_estados()
{
	inicio_particiones
	meterenmemo

	for(( xp = 0; xp < $num_proc; xp++ ))
	do
		if [[ ${T_ENTRADA[$xp]} -le $tiempo_transcurrido ]] && [[ ${EN_MEMO[$xp]} != "No" ]]
		then
			ESTADO[$xp]="En espera"
		fi
	
		if [[ ${EN_MEMO[$xp]} == "Si" ]]
		then
			ESTADO[$xp]="En memoria"
		fi
	done
	
	if [[ ${EN_MEMO[$proc_actual]} == "Si" ]]
	then
		ESTADO[$proc_actual]="Ejecucion"
		T_EJEC[$proc_actual]=$(( ${T_EJEC[$proc_actual]} + 1 ))
	fi

	for(( xp = 0; xp < $num_proc; xp++ ))
	do
		if [[ ${ESTADO[$xp]} == "Ejecucion" ]]
		then
			EJECUTADO[$xp]="Si"
		fi

		if [[ ${ESTADO[$xp]} == "En memoria" ]] && [[ ${EJECUTADO[$xp]} == "Si" ]]
		then
			ESTADO[$xp]="En pausa"
		fi
	done
}

#Copia estados para compararlo con el estado del mismo proceso más tarde y ver si este ha cambiado.
copiar_estados(){
	for(( xp = 0; xp < $num_proc; xp++ ))
	do
		ESTADOANT[$xp]=${ESTADO[$xp]}
	done
}

#Comparación de si un proceso ha cambiado de estado para pausar el algoritmo (Y pulsar intro para seguir, o esperar, o esperar un instante, dependiendo de lo elegido)
comparar_estados()
{
	evento=0
	for((xp = 0; xp < $num_proc; xp++))
	do
		if [[ ${ESTADOANT[$xp]} != ${ESTADO[$xp]} ]]
		then
			evento=1
		fi
	done
}

cola()
{
	for(( xp = 0; xp < $num_proc; xp++ ))
	do
		if [[ ${EN_MEMO[$xp]} == "Si" ]] && [[ ${EN_COLA[$xp]} == "No" ]] && [[ ${#colaprocs[@]} -lt $n_par ]]
		then
			colaprocs=( "${colaprocs[@]}" "$xp" )
			EN_COLA[$xp]="Si"
		fi
	done
}

### Actualiza la cola cuando ocurre un evento.
actualizar_cola()
{
	if [[ ${TIEMPO[$proc_actual]} -gt 0 ]]
	then
		pcola=${colaprocs[0]}
		del_element=1; colaprocs=( "${colaprocs[@]:0:$((del_element-1))}" "${colaprocs[@]:$del_element}" )	#PARA EL QUE VAYA DESPUES DE MI, ESTO FUNCIONA POR MUCHO QUE ESTE EN ROJO
		colaprocs+=( "$pcola" )
	else
		del_element=1; colaprocs=( "${colaprocs[@]:0:$((del_element-1))}" "${colaprocs[@]:$del_element}" )	#ESTO MAS DE LO MISMO
		EN_MEMO[$proc_actual]="No"
		vacias=$(( $vacias + 1 ))
		meterenmemo
		cola
	fi
	
}

### Calcula el margen de separacion a la derecha de la pantalla en la BT.
calcularcol()	#CALCULA COLUMNAS DEL TERMINAL
{ 
	columnas=$(( $(tput cols) - 5 ))
}

##### FUNCIÓN PRINCIPAL // ALGORITMO #####
algoritmob()
{
	modo_ejecucion
	tiempo_transcurrido=0	# Tiempo de ejecución de los procesos
	procesos_terminados=0	# Numero de procesos terminados
	cads=0 #Caracteres que ayudan a la separacion de las cadenas
	cad_col_bt=1
	cad1=""
	saltocad=0
	saltocadt=6
	contador=0
	controlsuma=1
	controltabla=0
	pvez=0
	tablapvez=1
	pvezcola=1
	ultvez=0
	col=0
	yomismo=1
	nulcontrol=0
	const=0
	constb=0
	escritos=0

	inicializar

	tant=$tiempo_transcurrido
	calcularcol
	actualizar_ltsec
	tabla_ejecucion
	actualizar_linea
	tablapvez=0
	tiempo_transcurrido=$(( $tiempo_transcurrido + ${T_ENTRADA[0]} ))

	#El bucle se repite hasta que no queden procesos por ejecutar
	while [ $procesos_terminados -lt $num_proc ]
	do
		calcularcol
		cola_act=0
		if [[ $pvezcola == 1 ]]
		then
			meterenmemo
			cola
		fi	
		proc_actual=${colaprocs[0]}

		copiar_estados
		asignar_estados
		comparar_estados
		actualizar_ltsec

		#Ahora aparece en el texto de la BT un proceso y el tiempo transcurrido si termina su cuantum, aunque sea el unico proceso en memoria.
		#Esta parte pausa la ejecucion en cada evento
		if [[ $evento = 1 ]] || [[ -z $proc_actual ]] || [[ $((${T_EJEC[$proc_actual]} % $quantum)) = 1 ]] || [[ $quantum = 1 ]]
		then
			if [[ -z $proc_actual ]]
			then
				if [[ $nulcontrol == 0 ]]
				then
					clear
					tabla_ejecucion
					nulcontrol=1
				fi
			else
				clear
				tabla_ejecucion
				nulcontrol=0
			fi
		fi
		tant=$tiempo_transcurrido
		tiempo_transcurrido=$(( $tiempo_transcurrido + 1 ))
		actualizar_linea
		if [[ ! -z $proc_actual ]]
		then
			TIEMPO[$proc_actual]=$(( ${TIEMPO[$proc_actual]} - 1 ))
		fi

		if (( ${T_EJEC[$proc_actual]} % $quantum == 0 )) && [[ ${T_EJEC[$proc_actual]} != 0 ]]
		then
			actualizar_cola
			cola_act=1
		fi

		#Termina un proceso
		if [[ ${TIEMPO[$proc_actual]} == 0 ]] && [[ ! -z $proc_actual ]]
		then
			if [[ $cola_act == 0 ]]
			then
				actualizar_cola
			fi

			EN_MEMO[$proc_actual]="No"
			ESTADO[$proc_actual]="Terminado"
			TIEMPO_FIN[$proc_actual]=$tiempo_transcurrido
			procesos_terminados=$(( $procesos_terminados + 1 ))
		fi
	done
	actualizar_ltsec
}



if [ -f archivo.temp -o -f informeCOLOR.txt ]
then
	rm archivo.temp
	rm informeCOLOR.txt
	rm informeBN.txt
fi

#Inicio del script (Con alumno nuevo 2022) para los 2 informes.
clear
echo "---------------------------------------------------------------------" >> informeCOLOR.txt
echo "|                                                                   |" >> informeCOLOR.txt
echo "|                         INFORME DE PRÁCTICA                       |" >> informeCOLOR.txt
echo "|                         GESTIÓN DE PROCESOS                       |" >> informeCOLOR.txt
echo "|             -------------------------------------------           |" >> informeCOLOR.txt
echo "|     Antiguo alumno:                                               |" >> informeCOLOR.txt
echo "|     Alumno: Mario Juez Gil                                        |" >> informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeCOLOR.txt
echo "|     Grado en ingeniería informática (2012-2013)                   |" >> informeCOLOR.txt
echo "|             -------------------------------------------           |" >> informeCOLOR.txt
echo "|     Alumno: Omar Santos Bernabe                                   |" >> informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeCOLOR.txt
echo "|     Grado en ingeniería informática (2014-2015)                   |" >> informeCOLOR.txt
echo "|             -------------------------------------------           |" >> informeCOLOR.txt
echo "|     Alumnos:                                                      |" >> informeCOLOR.txt
echo "|     Alumno: Alvaro Urdiales Santidrian                            |" >> informeCOLOR.txt
echo "|     Alumno: Javier Rodriguez Barcenilla                           |" >> informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeCOLOR.txt
echo "|     Grado en ingeniería informática (2015-2016)                   |" >> informeCOLOR.txt
echo "|                                                                   |" >> informeCOLOR.txt
echo "|             -------------------------------------------           |" >> informeCOLOR.txt
echo "|     Alumno: Gonzalo Burgos de la Hera                             |" >> informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeCOLOR.txt
echo "|     Grado en ingeniería informática (2019-2020)                   |" >> informeCOLOR.txt
echo "|                                                                   |" >> informeCOLOR.txt
echo "|             -------------------------------------------           |" >> informeCOLOR.txt
echo "|     Alumno: Lucas Olmedo Díez                                     |" >> informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeCOLOR.txt
echo "|     Grado en ingeniería informática (2021-2022)                   |" >> informeCOLOR.txt
echo "|                                                                   |" >> informeCOLOR.txt
echo "|             -------------------------------------------           |" >> informeCOLOR.txt
echo "|     Alumno: Miguel Díaz Hernando                                  |" >> informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeCOLOR.txt
echo "|     Grado en ingeniería informática (2022-2023)                   |" >> informeCOLOR.txt
echo "|                                                                   |" >> informeCOLOR.txt
echo "---------------------------------------------------------------------" >> informeCOLOR.txt
echo "" >> informeCOLOR.txt
echo "---------------------------------------------------------------------" >> informeBN.txt
echo "|                                                                   |" >> informeBN.txt
echo "|                         INFORME DE PRÁCTICA                       |" >> informeBN.txt
echo "|                         GESTIÓN DE PROCESOS                       |" >> informeBN.txt
echo "|             -------------------------------------------           |" >> informeBN.txt
echo "|     Antiguo alumno:                                               |" >> informeBN.txt
echo "|     Alumno: Mario Juez Gil                                        |" >> informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeBN.txt
echo "|     Grado en ingeniería informática (2012-2013)                   |" >> informeBN.txt
echo "|             -------------------------------------------           |" >> informeBN.txt
echo "|     Alumno: Omar Santos Bernabe                                   |" >> informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeBN.txt
echo "|     Grado en ingeniería informática (2014-2015)                   |" >> informeBN.txt
echo "|             -------------------------------------------           |" >> informeBN.txt
echo "|     Alumnos:                                                      |" >> informeBN.txt
echo "|     Alumno: Alvaro Urdiales Santidrian                            |" >> informeBN.txt
echo "|     Alumno: Javier Rodriguez Barcenilla                           |" >> informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeBN.txt
echo "|     Grado en ingeniería informática (2015-2016)                   |" >> informeBN.txt
echo "|                                                                   |" >> informeBN.txt
echo "|             -------------------------------------------           |" >> informeBN.txt
echo "|     Alumno: Gonzalo Burgos de la Hera                             |" >> informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeBN.txt
echo "|     Grado en ingeniería informática (2019-2020)                   |" >> informeBN.txt
echo "|                                                                   |" >> informeBN.txt
echo "|             -------------------------------------------           |" >> informeBN.txt
echo "|     Alumno: Lucas Olmedo Díez                                     |" >> informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeBN.txt
echo "|     Grado en ingeniería informática (2021-2022)                   |" >> informeBN.txt
echo "|                                                                   |" >> informeBN.txt
echo "|             -------------------------------------------           |" >> informeBN.txt
echo "|     Alumno: Miguel Díaz Hernando                                  |" >> informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> informeBN.txt
echo "|     Grado en ingeniería informática (2022-2023)                   |" >> informeBN.txt
echo "|                                                                   |" >> informeBN.txt
echo "---------------------------------------------------------------------" >> informeBN.txt
echo "" >> informeBN.txt


imprime_cabecera
lee_datos
clear
echo "		> ROUND ROBIN" >> informeCOLOR.txt
echo "		> ROUND ROBIN" >> informeBN.txt

#Condicional que determinará el guardado de los datos manuales
if [ $opcion_guardado == "1" ]
then
		meterAfichero datos
fi
if [ $opcion_guardado == "2" ]
then
		meterAfichero "$nombre_fichero"
fi

#Condicionales que determinarán el guardado de los datos manuales aleatorios
if [ $opcion_guardado_aleatorio_datos == "1" ]
then
		meterAfichero datos
fi

if [ $opcion_guardado_aleatorio_datos == "2" ]
then
		meterAfichero "$nombre_fichero"
fi

if [[ $opcion_guardado_aleatorio == "1" ]] || [[ $nombre_fichero_aleatorio == "datosrangos" ]]
then
		meterAficheroAleatorio datosrangos
fi

if [[ $opcion_guardado_aleatorio == "2" ]] && [[ $nombre_fichero_aleatorio != "datosrangos" ]]
then
		meterAficheroAleatorio "$nombre_fichero_aleatorio"
fi

datos_aux #Copia los datos
mayor_dato_procesos #Calcula el mayor dato
memoria_total=0
for tp in "${tam_par[@]}"
do
	let memoria_total=memoria_total+$tp
done
calcula_espacios #Calcula los espacios para la tabla
algoritmob #Algoritmo principal
clear
ultvez=1
tabla_ejecucion

if [ -f log.temp ]
then
	rm log.temp
fi
#echo "Tiempo total de ejecución de los $num_proc procesos: $tiempo_transcurrido"

#He cambiado esta última parte para que al pulsar intro directamente, es decir, sin introducir "s" o "n" lo cuente como válido, vomo una s.
read -p " ¿Quieres abrir el informe en blanco y negro? ([s],n): " datos 

while [ "${datos}" != "" -a "${datos}" != "s" -a "${datos}" != "n" ]
do
	read -p "Entrada no válida, vuelve a intentarlo. ¿Quieres abrir el informe en Banco y Negro? ([s],n): " datos
	
done
if [[ $datos = "s" || $datos = "" ]]
then
	cat informeBN.txt
fi

read -p " ¿Quieres abrir el informe a color? ([s],n): " datos_color

while [ "${datos_color}" != "" -a "${datos_color}" != "s" -a "${datos_color}" != "n" ]
do
	read -p "Entrada no válida, vuelve a intentarlo. ¿Quieres abrir el informe a Color? ([s],n): " datos_color
done

if [[ $datos_color = "s" || $datos_color = "" ]]
then
	cat informeCOLOR.txt
	read -p "close" x
fi

#Borrado de archivos sobrantes
if [ -f archivo.temp ]
then
	rm archivo.temp
fi

if [ -f listado.temp ]
then
	rm listado.temp
fi