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
#       NUMPROC[indicePr]     -> Número del proceso.                                                                                            #
#		T_ENTRADA[indicePr]	  -> Tiempo de llegada en el sistema del proceso                                                                    #
#       TEJ[indicePr]         -> Tiempo de ejecución (ráfaga) del proceso.                                                                      #
#       MEMORIA[indicePr]     -> Tamaño en memoria del proceso.                                                                                 #
#       EN_ESPERA[indicePr]	  -> [ Si / No ] Proceso en espera por tiempo de llegada.                                                           #
#       ESTADO[indicePr]      -> Estado del proceso en el sistema (Ejecución, en pausa, terminado...).                                          #
#		                                                                                                                                        #
#       PROC[indicePa]        -> Referencia al índice de proceso que está en memoria en una partición (Valor especial -1 para partición vacía). #
#       PART[indicePr]        -> Referencia a la partición en la que está el proceso (Valor especial -1 si no está en ninguna partición).       #
#################################################################################################################################################

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


#Se ha dejado un espacio de separación al principio de cada línea por si se da el caso de utilizar un terminal que corte el primer carácter de cada línea

#Variables Globales
min=9999
primvez=true
#He introducido variables para los colores para un mejor entendimiento en el código.
resetColor="\e[0m"			#resetea el color
colorRecuadro="\e[0;33m"	#amarillo normal
colorTexto="\e[1;36m"		#cian bold


### Función para comprobar si el parámetro pasado es un número entero mayor que 0 comparándolo con una expresión regular.
mayor_cero()
{
	if [[ $1 =~ ^[0-9]+$ ]] && [[ $1 -gt 0 ]]
	then
		return 0
	else
		return 1
	fi
}


### Cabecera con el algoritmo, autor y versión.
#He eliminado parámetros de color sobrante al final de la línea.
imprime_cabecera_larga()
{
	echo -e "$colorRecuadro┌─────────────────────────────────────────────────────────────────────┐"
	echo -e "$colorRecuadro│                 $colorTexto R.R. Fijas no iguales, peor ajuste.                $colorRecuadro│"			
	echo -e "$colorRecuadro│     $colorTexto Mario Juez Gil, Omar Santos, Alvaro Urdiales Santidria,        $colorRecuadro│"
	echo -e "$colorRecuadro│           $colorTexto Gonzalo Burgos de la Hera, Lucas Olmedo Díez             $colorRecuadro│"
	echo -e "$colorRecuadro│                       $colorTexto Miguel Díaz Hernando                         $colorRecuadro│"
	echo -e "$colorRecuadro│                        $colorTexto Versión Junio 2023                          $colorRecuadro│"
	echo -e "$colorRecuadro└─────────────────────────────────────────────────────────────────────┘ $resetColor"
}


### Cabecera con el algoritmo.
imprime_cabecera()
{
	echo -e "$colorRecuadro┌─────────────────────────────────────────────────────────────────────┐"
	echo -e "$colorRecuadro│                 $colorTexto R.R. Fijas no iguales, peor ajuste.                $colorRecuadro│"
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
	echo " Datos de las particiones"
	echo " Datos de las particiones" >> informeCOLOR.txt
	echo " Datos de las particiones" >> informeBN.txt
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
	echo " Datos de los procesos"
	echo " Datos de los procesos" >> informeCOLOR.txt
	echo " Datos de los procesos" >> informeBN.txt
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo " Los procesos introducidos hasta ahora son: "
	echo " Los procesos introducidos hasta ahora son: " >> informeCOLOR.txt
	echo " Los procesos introducidos hasta ahora son: " >> informeBN.txt
	echo " Ref Tll Tej Mem"
	echo " Ref Tll Tej Mem" >> informeCOLOR.txt
	echo " Ref Tll Tej Mem" >> informeBN.txt
	echo " ---------------"
	echo " ---------------" >> informeCOLOR.txt
	echo " ---------------" >> informeBN.txt
}


### He creado una nueva función que imprime la información de los datos que se están introduciendo en la opción 4. Este código estaba duplicado múltiples veces.
imprime_info_datos_aleatorios()
{
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo " Datos de las particiones"
	echo " Datos de las particiones" >> informeCOLOR.txt
	echo " Datos de las particiones" >> informeBN.txt
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
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
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo " Datos de los procesos"
	echo " Datos de los procesos" >> informeCOLOR.txt
	echo " Datos de los procesos" >> informeBN.txt
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo " Número de procesos:	$num_proc_min - $num_proc_max -> $num_proc"
	echo " Número de procesos:	$num_proc_min - $num_proc_max -> $num_proc" >> informeCOLOR.txt
	echo " Número de procesos:	$num_proc_min - $num_proc_max -> $num_proc" >> informeBN.txt
	echo " Tiempo de llegada:	$entrada_min - $entrada_max"
	echo " Tiempo de llegada:	$entrada_min - $entrada_max" >> informeCOLOR.txt
	echo " Tiempo de llegada:	$entrada_min - $entrada_max" >> informeBN.txt
	echo " Tiempo de ejecución:	$rafaga_min - $rafaga_max"
	echo " Tiempo de ejecución:	$rafaga_min - $rafaga_max" >> informeCOLOR.txt
	echo " Tiempo de ejecución:	$rafaga_min - $rafaga_max" >> informeBN.txt
	echo " Memoria a ocupar: 	$memo_proc_min - $memo_proc_max"
	echo " Memoria a ocupar: 	$memo_proc_min - $memo_proc_max" >> informeCOLOR.txt
	echo " Memoria a ocupar: 	$memo_proc_min - $memo_proc_max" >> informeBN.txt
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo " Los procesos introducidos hasta ahora son: "
	echo " Los procesos introducidos hasta ahora son: " >> informeCOLOR.txt
	echo " Los procesos introducidos hasta ahora son: " >> informeBN.txt
	echo " Ref Tll Tej Mem"
	echo " Ref Tll Tej Mem" >> informeCOLOR.txt
	echo " Ref Tll Tej Mem" >> informeBN.txt
	echo " ---------------"
	echo " ---------------" >> informeCOLOR.txt
	echo " ---------------" >> informeBN.txt
}


### He creado una nueva función que imprime la información de los datos que se están introduciendo en la opción 4. Este código estaba duplicado múltiples veces.
imprime_info_datos_rangos_aleatorios()
{
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo " Datos de las particiones"
	echo " Datos de las particiones" >> informeCOLOR.txt
	echo " Datos de las particiones" >> informeBN.txt
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo -e " Número de particiones: $rango_n_par_min - $rango_n_par_max -> $n_par_min - $n_par_max -> $n_par"
	echo -e " Número de particiones: $rango_n_par_min - $rango_n_par_max -> $n_par_min - $n_par_max -> $n_par" >> informeCOLOR.txt
	echo -e " Número de particiones: $rango_n_par_min - $rango_n_par_max -> $n_par_min - $n_par_max -> $n_par" >> informeBN.txt

	echo -e " Tamaño de particiones: $rango_tam_par_min - $rango_tam_par_max -> $tam_par_min - $tam_par_max -> ${tam_par[@]}"
	echo -e " Tamaño de particiones: $rango_tam_par_min - $rango_tam_par_max -> $tam_par_min - $tam_par_max -> ${tam_par[@]}" >> informeCOLOR.txt
	echo -e " Tamaño de particiones: $rango_tam_par_min - $rango_tam_par_max -> $tam_par_min - $tam_par_max -> ${tam_par[@]}" >> informeBN.txt	

	echo -e " Quantum:               $rango_quantum_min - $rango_quantum_max -> $quantum_min - $quantum_max -> $quantum"
	echo -e " Quantum:               $rango_quantum_min - $rango_quantum_max -> $quantum_min - $quantum_max -> $quantum" >> informeCOLOR.txt
	echo -e " Quantum:               $rango_quantum_min - $rango_quantum_max -> $quantum_min - $quantum_max -> $quantum" >> informeBN.txt		
	
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo " Datos de los procesos"
	echo " Datos de los procesos" >> informeCOLOR.txt
	echo " Datos de los procesos" >> informeBN.txt
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo " Número de procesos:	$rango_num_proc_min - $rango_num_proc_max -> $num_proc_min - $num_proc_max -> $num_proc"
	echo " Número de procesos:	$rango_num_proc_min - $rango_num_proc_max -> $num_proc_min - $num_proc_max -> $num_proc" >> informeCOLOR.txt
	echo " Número de procesos:	$rango_num_proc_min - $rango_num_proc_max -> $num_proc_min - $num_proc_max -> $num_proc" >> informeBN.txt
	echo " Tiempo de llegada:	$rango_entrada_min - $rango_entrada_max -> $entrada_min - $entrada_max"
	echo " Tiempo de llegada:	$rango_entrada_min - $rango_entrada_max -> $entrada_min - $entrada_max" >> informeCOLOR.txt
	echo " Tiempo de llegada:	$rango_entrada_min - $rango_entrada_max -> $entrada_min - $entrada_max" >> informeBN.txt
	echo " Tiempo de ejecución:	$rango_rafaga_min - $rango_rafaga_max -> $rafaga_min - $rafaga_max"
	echo " Tiempo de ejecución:	$rango_rafaga_min - $rango_rafaga_max -> $rafaga_min - $rafaga_max" >> informeCOLOR.txt
	echo " Tiempo de ejecución:	$rango_rafaga_min - $rango_rafaga_max -> $rafaga_min - $rafaga_max" >> informeBN.txt
	echo " Memoria a ocupar: 	$rango_memo_proc_min - $rango_memo_proc_max -> $memo_proc_min - $memo_proc_max"
	echo " Memoria a ocupar: 	$rango_memo_proc_min - $rango_memo_proc_max -> $memo_proc_min - $memo_proc_max" >> informeCOLOR.txt
	echo " Memoria a ocupar: 	$rango_memo_proc_min - $rango_memo_proc_max -> $memo_proc_min - $memo_proc_max" >> informeBN.txt
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo " Los procesos introducidos hasta ahora son: "
	echo " Los procesos introducidos hasta ahora son: " >> informeCOLOR.txt
	echo " Los procesos introducidos hasta ahora son: " >> informeBN.txt
	echo " Ref Tll Tej Mem"
	echo " Ref Tll Tej Mem" >> informeCOLOR.txt
	echo " Ref Tll Tej Mem" >> informeBN.txt
	echo " ---------------"
	echo " ---------------" >> informeCOLOR.txt
	echo " ---------------" >> informeBN.txt
}


### Función de lectura de entrada para el menú principal (6 opciones principales, menú de guardado y recogida de datos principales en caso de introducción manual de datos).
lee_datos() {
	#Menú inicial
	echo ""
	echo " 1- Entrada Manual"
	echo " 1- Entrada Manual" >> informeCOLOR.txt
	echo " 1- Entrada Manual" >> informeBN.txt
	echo " 2- Fichero de datos de última ejecución (DatosLast.txt)"
	echo " 2- Fichero de datos de última ejecución (DatosLast.txt)" >> informeCOLOR.txt
	echo " 2- Fichero de datos de última ejecución (DatosLast.txt)" >> informeBN.txt
	echo " 3- Otros ficheros de datos"
	echo " 3- Otros ficheros de datos" >> informeCOLOR.txt
	echo " 3- Otros ficheros de datos" >> informeBN.txt
	echo " 4- Rangos manuales para valores aleatorios"
	echo " 4- Rangos manuales para valores aleatorios" >> informeCOLOR.txt
	echo " 4- Rangos manuales para valores aleatorios" >> informeBN.txt
	echo " 5- Fichero de rangos de última ejecución (DatosRangosRNG.txt)"
	echo " 5- Fichero de rangos de última ejecución (DatosRangosRNG.txt)" >> informeCOLOR.txt
	echo " 5- Fichero de rangos de última ejecución (DatosRangosRNG.txt)" >> informeBN.txt
	echo " 6- Otros ficheros de rangos"
	echo " 6- Otros ficheros de rangos" >> informeCOLOR.txt
	echo " 6- Otros ficheros de rangos" >> informeBN.txt
	echo " 7- Rangos manuales para rangos aleatorios (prueba de casos extremos)"
	echo " 7- Rangos manuales para rangos aleatorios (prueba de casos extremos)" >> informeCOLOR.txt
	echo " 7- Rangos manuales para rangos aleatorios (prueba de casos extremos)" >> informeBN.txt
	echo " 8- Fichero de rangos aleatorios de última ejecución (DatosRangosAleatoriosRNGALE.txt)"
	echo " 8- Fichero de rangos aleatorios de última ejecución (DatosRangosAleatoriosRNGALE.txt)" >> informeCOLOR.txt
	echo " 8- Fichero de rangos aleatorios de última ejecución (DatosRangosAleatoriosRNGALE.txt)" >> informeBN.txt
	echo " 9- Otros ficheros de rangos para rangos aleatorios"
	echo " 9- Otros ficheros de rangos para rangos aleatorios" >> informeCOLOR.txt
	echo " 9- Otros ficheros de rangos para rangos aleatorios" >> informeBN.txt
	echo ""
	read -p " Elija una opción: " dat_fich
	echo $dat_fich >> informeCOLOR.txt
	echo $dat_fich >> informeBN.txt

	#COMPROBACIÓN DE LECTURA
	#He añadido una explicación más detallada del error de introducción de opción.
	while [ "${dat_fich}" != "1" -a "${dat_fich}" != "2" -a "${dat_fich}" != "3" -a "${dat_fich}" != "4" -a "${dat_fich}" != "5" -a "${dat_fich}" != "6" -a "${dat_fich}" != "7" -a "${dat_fich}" != "8" -a "${dat_fich}" != "9" ] #Lectura errónea.
	do
		echo "Entrada no válida"
		read -p "Elija una opción como un número natural del 1 al 8: " dat_fich
		echo $dat_fich >> informeCOLOR.txt
		echo $dat_fich >> informeBN.txt
	done

	#clear
	#Introducción de datos a mano
	#He agrupado en el mismo if la selección de guardado y la introducción/lectura de datos.
	if [ "${dat_fich}" == "1" ]
	then

		###  MÉTODO DE GUARDADO  ###

		#Se pide el método de guardado de los datos introducidos.
		#Los métodos de guardado consisten en crear un fichero nuevo con los datos (Con nombre estandar o a elegir por el usuario), o guardarlo en la última ejecución.
		imprime_cabecera_larga
		echo  " ¿Dónde guardar los datos?"
		echo  " ¿Dónde guardar los datos?" >> informeCOLOR.txt
		echo  " ¿Dónde guardar los datos?" >> informeBN.txt
		echo  " 1- Fichero de datos de última ejecución (DatosLast.txt)"
		echo  " 1- Fichero de datos de última ejecución (DatosLast.txt)" >> informeCOLOR.txt
		echo  " 1- Fichero de datos de última ejecución (DatosLast.txt)" >> informeBN.txt
		echo  " 2- Otros ficheros de datos"
		echo  " 2- Otros ficheros de datos" >> informeCOLOR.txt
		echo  " 2- Otros ficheros de datos" >> informeBN.txt

		read opcion_guardado_datos

		#He añadido una explicación más detallada del error de introducción de opción.
		while [ "${opcion_guardado_datos}" != "1" -a "${opcion_guardado_datos}" != "2" ] #Lectura errónea.
		do
			echo "Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los datos?"
			read opcion_guardado_datos
		done

		echo $opcion_guardado_datos >> informeCOLOR.txt
		echo $opcion_guardado_datos >> informeBN.txt

		#Si se guarda en otro fichero, pregunta el nombre.
		if [ "${opcion_guardado_datos}" == "2" ]
		then
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)"
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> informeCOLOR.txt
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> informeBN.txt
			read nombre_fichero_datos

			#He añadido el nombre del fichero de guardado nuevo a los informes.
			echo $nombre_fichero_datos >> informeCOLOR.txt 
			echo $nombre_fichero_datos >> informeBN.txt 
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
		lectura_fichero "DatosLast.txt"
	fi


	#Entrada por otros ficheros.
	if [ $dat_fich = '3' ] 
	then
		#clear
		#Como ahora los otros ficheros de datos también terminan en .txt se eliminan los informes y el archivo últimos de la búsqueda.
		ls | grep .txt | grep -v informeBN.txt | grep -v informeCOLOR.txt | grep -v DatosRangosRNG.txt | grep -v RNG* > listado.temp
	
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
		imprime_cabecera_larga
		echo  " ¿Dónde guardar los rangos?"
		echo  " ¿Dónde guardar los rangos?" >> informeCOLOR.txt
		echo  " ¿Dónde guardar los rangos?" >> informeBN.txt
		echo  " 1- Fichero de rangos de última ejecución (DatosRangosRNG.txt)"
		echo  " 1- Fichero de rangos de última ejecución (DatosRangosRNG.txt)" >> informeCOLOR.txt
		echo  " 1- Fichero de rangos de última ejecución (DatosRangosRNG.txt)" >> informeBN.txt
		echo  " 2- Otros ficheros de rangos"
		echo  " 2- Otros ficheros de rangos" >> informeCOLOR.txt
		echo  " 2- Otros ficheros de rangos" >> informeBN.txt

		read opcion_guardado_rangos

		#He añadido una explicación más detallada del error de introducción de opción.
		while [ "${opcion_guardado_rangos}" != "1" -a "${opcion_guardado_rangos}" != "2" ] #Lectura errónea.
		do
			echo "Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los rangos?"
			read opcion_guardado_rangos
		done

		echo $opcion_guardado_rangos >> informeCOLOR.txt
		echo $opcion_guardado_rangos >> informeBN.txt
	
		#Si se guarda en otro fichero, pregunta el nombre.
		if [ "${opcion_guardado_rangos}" == "2" ]
		then
			echo  " Nombre del nuevo fichero con rangos: (No poner .txt)"
			echo  " Nombre del nuevo fichero con rangos: (No poner .txt)" >> informeCOLOR.txt
			echo  " Nombre del nuevo fichero con rangos: (No poner .txt)" >> informeBN.txt
			read nombre_fichero_rangos
		fi

		#clear
		imprime_cabecera_larga
		echo  " ¿Dónde guardar los datos?"
		echo  " ¿Dónde guardar los datos?" >> informeCOLOR.txt
		echo  " ¿Dónde guardar los datos?" >> informeBN.txt
		echo  " 1- Fichero de datos de última ejecución (DatosLast.txt)"
		echo  " 1- Fichero de datos de última ejecución (DatosLast.txt)" >> informeCOLOR.txt
		echo  " 1- Fichero de datos de última ejecución (DatosLast.txt)" >> informeBN.txt
		echo  " 2- Otros ficheros de datos"
		echo  " 2- Otros ficheros de datos" >> informeCOLOR.txt
		echo  " 2- Otros ficheros de datos" >> informeBN.txt

		read opcion_guardado_datos_rangos

		while [ "${opcion_guardado_datos_rangos}" != "1" -a "${opcion_guardado_datos_rangos}" != "2" ] #Lectura errónea.
		do
			echo " Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los datos?"
			read opcion_guardado_datos_rangos
		done

		echo $opcion_guardado_datos_rangos >> informeCOLOR.txt
		echo $opcion_guardado_datos_rangos >> informeBN.txt

		#Si se guarda en otro fichero, pregunta el nombre.
		if [ "${opcion_guardado_datos_rangos}" == "2" ]
		then
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)"
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> informeCOLOR.txt
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> informeBN.txt
			read nombre_fichero_datos
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
		lectura_fichero_aleatorio "DatosRangosRNG.txt"
	fi


	#Lectura de otros ficheros con datos aleatorios
	if [ $dat_fich = '6' ] 
	then 
		ls | grep RNG* > listado.temp

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


	#Introduccion de rangos aleatorios a mano.
	if [ $dat_fich = '7' ] 
	then
		###  MÉTODO DE GUARDADO  ###

		#Guardado de datos en ficheros destinados a rangos para rangos aleatorios.
		imprime_cabecera_larga
		echo  " ¿Dónde guardar los rangos para calcular rangos?"
		echo  " ¿Dónde guardar los rangos para calcular rangos?" >> informeCOLOR.txt
		echo  " ¿Dónde guardar los rangos para calcular rangos?" >> informeBN.txt
		echo  " 1- Fichero de rangos para rangos de última ejecución (DatosRangosAleatoriosRNGALE.txt)"
		echo  " 1- Fichero de rangos para rangos de última ejecución (DatosRangosAleatoriosRNGALE.txt)" >> informeCOLOR.txt
		echo  " 1- Fichero de rangos para rangos de última ejecución (DatosRangosAleatoriosRNGALE.txt)" >> informeBN.txt
		echo  " 2- Otros ficheros de rangos para rangos"
		echo  " 2- Otros ficheros de rangos para rangos" >> informeCOLOR.txt
		echo  " 2- Otros ficheros de rangos para rangos" >> informeBN.txt

		read opcion_guardado_rangos_rangos

		#He añadido una explicación más detallada del error de introducción de opción.
		while [ "${opcion_guardado_rangos_rangos}" != "1" -a "${opcion_guardado_rangos_rangos}" != "2" ] #Lectura errónea.
		do
			echo "Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los rangos para rangos?"
			read opcion_guardado_rangos_rangos
		done

		echo $opcion_guardado_rangos_rangos >> informeCOLOR.txt
		echo $opcion_guardado_rangos_rangos >> informeBN.txt
	
		#Si se guarda en otro fichero, pregunta el nombre.
		if [ "${opcion_guardado_rangos_rangos}" == "2" ]
		then
			echo  " Nombre del nuevo fichero con rangos para rangos: (No poner .txt)"
			echo  " Nombre del nuevo fichero con rangos para rangos: (No poner .txt)" >> informeCOLOR.txt
			echo  " Nombre del nuevo fichero con rangos para rangos: (No poner .txt)" >> informeBN.txt
			read nombre_fichero_rangos_rangos
		fi

		#Guardado de datos en ficheros destinados rangos para datos aleatorios.
		imprime_cabecera_larga
		echo  " ¿Dónde guardar los rangos?"
		echo  " ¿Dónde guardar los rangos?" >> informeCOLOR.txt
		echo  " ¿Dónde guardar los rangos?" >> informeBN.txt
		echo  " 1- Fichero de rangos de última ejecución (DatosRangosRNG.txt)"
		echo  " 1- Fichero de rangos de última ejecución (DatosRangosRNG.txt)" >> informeCOLOR.txt
		echo  " 1- Fichero de rangos de última ejecución (DatosRangosRNG.txt)" >> informeBN.txt
		echo  " 2- Otros ficheros de rangos"
		echo  " 2- Otros ficheros de rangos" >> informeCOLOR.txt
		echo  " 2- Otros ficheros de rangos" >> informeBN.txt

		read opcion_guardado_rangos_2

		#He añadido una explicación más detallada del error de introducción de opción.
		while [ "${opcion_guardado_rangos_2}" != "1" -a "${opcion_guardado_rangos_2}" != "2" ] #Lectura errónea.
		do
			echo "Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los rangos?"
			read opcion_guardado_rangos_2
		done

		echo $opcion_guardado_rangos_2 >> informeCOLOR.txt
		echo $opcion_guardado_rangos_2 >> informeBN.txt
	
		#Si se guarda en otro fichero, pregunta el nombre.
		if [ "${opcion_guardado_rangos_2}" == "2" ]
		then
			echo  " Nombre del nuevo fichero con rangos: (No poner .txt)"
			echo  " Nombre del nuevo fichero con rangos: (No poner .txt)" >> informeCOLOR.txt
			echo  " Nombre del nuevo fichero con rangos: (No poner .txt)" >> informeBN.txt
			read nombre_fichero_rangos
		fi

		#clear
		imprime_cabecera_larga
		echo  " ¿Dónde guardar los datos?"
		echo  " ¿Dónde guardar los datos?" >> informeCOLOR.txt
		echo  " ¿Dónde guardar los datos?" >> informeBN.txt
		echo  " 1- Fichero de datos de última ejecución (DatosLast.txt)"
		echo  " 1- Fichero de datos de última ejecución (DatosLast.txt)" >> informeCOLOR.txt
		echo  " 1- Fichero de datos de última ejecución (DatosLast.txt)" >> informeBN.txt
		echo  " 2- Otros ficheros de datos"
		echo  " 2- Otros ficheros de datos" >> informeCOLOR.txt
		echo  " 2- Otros ficheros de datos" >> informeBN.txt

		read opcion_guardado_datos_rangos_2

		while [ "${opcion_guardado_datos_rangos_2}" != "1" -a "${opcion_guardado_datos_rangos_2}" != "2" ] #Lectura errónea.
		do
			echo " Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los datos?"
			read opcion_guardado_datos_rangos_2
		done

		echo $opcion_guardado_datos_rangos_2 >> informeCOLOR.txt
		echo $opcion_guardado_datos_rangos_2 >> informeBN.txt

		#Si se guarda en otro fichero, pregunta el nombre.
		if [ "${opcion_guardado_datos_rangos_2}" == "2" ]
		then
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)"
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> informeCOLOR.txt
			echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> informeBN.txt
			read nombre_fichero_datos
		fi

		#Lectura de datos de particiones y quántum.
		lectura_dat_particiones_rangos_aleatorios

		#Lectura de datos concretos de los procesos.
		lectura_dat_procesos_rangos_aleatorios

		ordenacion_procesos
	fi


	#Entrada por fichero de última ejecución de rangos aleatorios.
	if [ $dat_fich = '8' ] 
	then
		#fich="datos.txt"
		lectura_fichero_rangos_aleatorios "DatosRangosAleatoriosRNGALE.txt"
	fi


	#Entrada por otro fichero de rangos aleatorios.
	if [ $dat_fich = '9' ]
	then
		ls | grep RNGALE* > listado.temp
		ls | grep RNG* >> listado.temp

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
		lectura_fichero_rangos_aleatorios "$fich"
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
	echo "      >> Procesos y sus datos:" >> informeCOLOR.txt
	echo "      >> Procesos y sus datos:" >> informeBN.txt
	echo "         Ref Tll Tej Mem " >> informeCOLOR.txt
	echo "         Ref Tll Tej Mem " >> informeBN.txt
	echo "         ----------------" >> informeCOLOR.txt
	echo "         ----------------" >> informeBN.txt
}


### Escribe en los informes las filas del enunciado con los datos introducidos.
escribe_enunciado()
{
	p=0
	#He añadido un comentario con los colores usados en el código, y acortado el array de colores repetidos dado que su funcionamiento es cíclico.
	#color=(cyan, purple, blue, green, red)
	color=(96 95 94 92 91)

	for(( c=0, pr=0; pr<$num_proc; c++, pr++ ))
	do
		if [[ $c -gt 4 ]] #Si se sale del array de colores, vuelve al primero.
		then
			c=0
		fi

		echo -ne "                   \e[${color[$c]}mP" >> informeCOLOR.txt
		printf "%02d " "${NUMPROC[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${TEJ[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${MEMORIA[$pr]}" >> informeCOLOR.txt
		echo -e "$resetColor" >> informeCOLOR.txt

		echo -ne "                   P" >> informeBN.txt
		printf "%02d " "${NUMPROC[$pr]}" >> informeBN.txt
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
	#clear
	imprime_cabecera_larga
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
		#clear
		imprime_cabecera_larga
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
	#clear
	imprime_cabecera_larga
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

	#clear
	imprime_cabecera_larga
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
		NUMPROC_I[$i_proc]=$num_proc

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
		T_EJECUCION_I[$i_proc]=$rafaga  # Almacenará la ráfaga del proceso
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

	#clear
	imprime_cabecera_larga
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

	#clear
	imprime_cabecera_larga
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
		else	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduzca numero de particiones máximo: "
		echo -n " Introduzca numero de particiones máximo: " >> informeCOLOR.txt
		echo -n " Introduzca numero de particiones máximo: " >> informeBN.txt
		read n_par_max
		echo $n_par_max >> informeCOLOR.txt
		echo $n_par_max >> informeBN.txt
	done

	#Asignación aleatoria del número de particiones en el rango.
	n_par=`shuf -i $n_par_min-$n_par_max -n 1`

	###  TAMAÑO DE PARTICIONES MÍNIMO  ###

	#clear
	imprime_cabecera_larga
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

	#clear
	imprime_cabecera_larga
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
		else	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduzca tamaño de particiones máximo: "
		echo -n " Introduzca tamaño de particiones máximo: " >> informeCOLOR.txt
		echo -n " Introduzca tamaño de particiones máximo: " >> informeBN.txt
		read tam_par_max
		echo $tam_par_max >> informeCOLOR.txt
		echo $tam_par_max >> informeBN.txt
	done	

	#Asignación aleatoria del tamaño de particiones en el rango.
	for ((p=0; p < $n_par; p++))
	{
		tam_par[$p]=`shuf -i $tam_par_min-$tam_par_max -n 1`
	}

	###  QUÁNTUM MÍNIMO  ###

	#clear
	imprime_cabecera_larga
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

	#clear
	imprime_cabecera_larga
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
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduce el quantum de ejecución máximo: "
		echo -n " Introduce el quantum de ejecución máximo: " >> informeCOLOR.txt
		echo -n " Introduce el quantum de ejecución máximo: " >> informeBN.txt
		read quantum_max
		echo $quantum_max >> informeCOLOR.txt
		echo $quantum_max >> informeBN.txt
	done

	#Asignación aleatoria del quántum en el rango.
	quantum=`shuf -i $quantum_min-$quantum_max -n 1`

	#clear
	imprime_cabecera_larga
	imprime_info_datos_aleatorios
}


### Lectura de los datos de rangos de los procesos para la introducción a mano para sacar los datos aleatorios (opción 4).
lectura_dat_procesos_aleatorios()
{
	num_proc=0
	procesos_ejecutables=0 	#Número de procesos que entran en memoria y se pueden ejecutar en CPU

	###  NÚMERO DE PROCESOS MÍNIMO  ###
	imprimir_tabla_procesos_aleatorios
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

	imprimir_tabla_procesos_aleatorios
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
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduce el número de procesos máximo: "
		echo -n " Introduce el número de procesos máximo: " >> informeCOLOR.txt
		echo -n " Introduce el número de procesos máximo: " >> informeBN.txt
		read num_proc_max
		echo $num_proc_max >> informeCOLOR.txt
		echo $num_proc_max >> informeBN.txt
	done
	
	#Asignación aleatoria del número de procesos en el rango.
	num_proc=`shuf -i $num_proc_min-$num_proc_max -n 1`

	###   TIEMPO DE LLEGADA MÍNIMO  ###

	imprimir_tabla_procesos_aleatorios
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

	imprimir_tabla_procesos_aleatorios
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
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: "
		echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: " >> informeBN.txt
		read entrada_max
		echo $entrada_max >> informeCOLOR.txt
		echo $entrada_max >> informeBN.txt
	done

	###  RÁFAGA MÍNIMA  ###

	imprimir_tabla_procesos_aleatorios
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

	imprimir_tabla_procesos_aleatorios
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
		else  	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduce la ráfaga máxima de CPU de los procesos: "
		echo -n " Introduce la ráfaga máxima de CPU de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce la ráfaga máxima de CPU de los procesos: " >> informeBN.txt
		read rafaga_max
		echo $rafaga_max >> informeCOLOR.txt
		echo $rafaga_max >> informeBN.txt
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

	imprimir_tabla_procesos_aleatorios
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
		else #Si la memoria mínima de los procesos es mayor que la mayor partición.
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeBN.txt
		fi
		echo -n " Introduce la memoria mínima de los procesos: "
		echo -n " Introduce la memoria mínima de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce la memoria mínima de los procesos: " >> informeBN.txt
		read memo_proc_min
		echo $memo_proc_min >> informeCOLOR.txt
		echo $memo_proc_min >> informeBN.txt
	done

	###  MEMORIA MÁXIMA  ###

	imprimir_tabla_procesos_aleatorios
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
		elif [ $memo_proc_max -gt $tam_par_max_efec ] 	#Si la memoria máxima de los procesos es mayor que la mayor partición.
		then
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeBN.txt
		else 
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduce la memoria máxima de los procesos: "
		echo -n " Introduce la memoria máxima de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce la memoria máxima de los procesos: " >> informeBN.txt
		read memo_proc_max
		echo $memo_proc_max >> informeCOLOR.txt
		echo $memo_proc_max >> informeBN.txt
	done

	#Calculo los datos de los procesos.
	datos_procesos_aleatorios

	ordenacion_procesos
	imprimir_tabla_procesos_aleatorios
}


### Bucle que calcula los datos de los procesos con los rangos y los imprime antes de que comience la ejecución del algoritmo RR.
#He separado este proceso en una función aparte para reutilizarlo, eliminado variables redundantes y cambiado los comandos de expr por let.
#Recibe como parámetro si imprimir la tabla de rangos para datos o de rangos para rangos para datos.
datos_procesos_aleatorios()
{
	for(( pr=0; pr<$num_proc; pr++ ))
	do
		NUMPROC_I[$pr]=$(($pr+1))

		#Asignación aleatoria del tiempo de entrada en el rango.
		entrada=`shuf -i $entrada_min-$entrada_max -n 1`
		T_ENTRADA_I[$pr]=$entrada

		#Almacena el proceso con el menor tiempo de llegada, por orden de introducción.
		if [ $entrada -lt $min ]
		then
			min=$entrada
			pos=$pr
		fi

		#La condición se cumplirá siempre porque el tiempo de llegada debe ser mayor que 0, pero he decidido dejar la comprobación en caso de futuras modificaciones a la restricción.
		if [ $entrada -ne '0' ]  #Si el tiempo de llegada no es 0. (Se cumplirá siempre)
		then	
			EN_ESPERA_I[$pr]="Si" #Por defecto en t=0 todos los procesos estarán en espera ya que llegan a partir de t=1.
		else
			EN_ESPERA[$pr]="No"
			let procesos_ejecutables=procesos_ejecutables+1
		fi

		#Almacenamiento de datos en un archivo temporal.
		echo ${T_ENTRADA_I[$pr]} >> archivo.temp
		echo ${EN_ESPERA_I[$pr]} >> archivo.temp

		#Asignación aleatoria de la ráfaga en el rango.
		rafaga=`shuf -i $rafaga_min-$rafaga_max -n 1`
		T_EJECUCION_I[$pr]=$rafaga  #Almacena la ráfaga del proceso
		QT_PROC_I[$pr]=$quantum 	#Almacena el quantum restante del proceso (en caso de E/S)
		PROC_ENAUX_I[$pr]="No" 	#Por defecto ningún proceso estará en la cola auxiliar FIFO de E/S

		#Almacenamiento de datos en un archivo temporal
		echo $rafaga >> archivo.temp

		#Asignación aleatoria de la memoria en el rango.
		memo_proc=`shuf -i $memo_proc_min-$memo_proc_max -n 1`
		MEMORIA_I[$pr]=$memo_proc

		#Almacenamiento de datos en un archivo temporal
		echo $memo_proc >> archivo.temp
	done

	#Si no hay procesos ejecutables, saca de espera al proceso con el menor tiempo de llegada y suma procesos ejecutables.
	if [ $procesos_ejecutables -eq '0' ]
	then
		EN_ESPERA[$pos]="No"
		let procesos_ejecutables=procesos_ejecutables+1
	fi
}


### Lectura de los rangos para rangos de las particiones y el quantum para la introducción a mano de rangos aleatorios (opción 7).
lectura_dat_particiones_rangos_aleatorios()
{
	###  RANGO DE NÚMERO DE PARTICIONES MÍNIMO  ###

	#clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo -n " Introduzca rango de número de particiones mínimo: "
	echo -n " Introduzca rango de número de particiones mínimo: " >> informeCOLOR.txt
	echo -n " Introduzca rango de número de particiones mínimo: " >> informeBN.txt
	read rango_n_par_min
	echo $rango_n_par_min >> informeCOLOR.txt
	echo $rango_n_par_min >> informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_n_par_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduzca rango de número de particiones mínimo: "
		echo -n " Introduzca rango de número de particiones mínimo: " >> informeCOLOR.txt
		echo -n " Introduzca rango de número de particiones mínimo: " >> informeBN.txt
		read rango_n_par_min
		echo $rango_n_par_min >> informeCOLOR.txt
		echo $rango_n_par_min >> informeBN.txt
	done

	###  RANGO DE NÚMERO DE PARTICIONES MÁXIMO  ###

	#clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo -n " Introduzca rango de número de particiones máximo: "
	echo -n " Introduzca rango de número de particiones máximo: " >> informeCOLOR.txt
	echo -n " Introduzca rango de número de particiones máximo: " >> informeBN.txt
	read rango_n_par_max
	echo $rango_n_par_max >> informeCOLOR.txt
	echo $rango_n_par_max >> informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE NÚMERO DE PARTICIONES  ###
	
	#He fusionado la comprobación de mayor que cero y mayor que número de particiones mínimo porque me parece más elegante.
	while ! mayor_cero $rango_n_par_max || [ $rango_n_par_max -lt $rango_n_par_min ]
	do
		if ! mayor_cero $rango_n_par_max	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
			
		else	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduzca rango de número de particiones máximo: "
		echo -n " Introduzca rango de número de particiones máximo: " >> informeCOLOR.txt
		echo -n " Introduzca rango de número de particiones máximo: " >> informeBN.txt
		read rango_n_par_max
		echo $rango_n_par_max >> informeCOLOR.txt
		echo $rango_n_par_max >> informeBN.txt
	done

	#Asignación aleatoria del número de particiones mínimo en el rango.
	n_par_min=`shuf -i $rango_n_par_min-$rango_n_par_max -n 1`
	#Asignación aleatoria del número de particiones máximo en el rango.
	n_par_max=`shuf -i $rango_n_par_min-$rango_n_par_max -n 1`

	while [ $n_par_min -gt $n_par_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria del número de particiones mínimo en el rango.
		n_par_min=`shuf -i $rango_n_par_min-$rango_n_par_max -n 1`
		#Asignación aleatoria del número de particiones máximo en el rango.
		n_par_max=`shuf -i $rango_n_par_min-$rango_n_par_max -n 1`
	done

	#Asignación aleatoria del número de particiones en el rango.
	n_par=`shuf -i $n_par_min-$n_par_max -n 1`

	###  RANGO DE TAMAÑO DE PARTICIONES MÍNIMO  ###

	#clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo -n " Introduce rango de tamaño de particiones mínimo: "
	echo -n " Introduce rango de tamaño de particiones mínimo: " >> informeCOLOR.txt
	echo -n " Introduce rango de tamaño de particiones mínimo: " >> informeBN.txt
	read rango_tam_par_min
	echo $rango_tam_par_min >> informeCOLOR.txt
	echo $rango_tam_par_min >> informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_tam_par_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduzca rango de tamaño de particiones mínimo: "
		echo -n " Introduzca rango de tamaño de particiones mínimo: " >> informeCOLOR.txt
		echo -n " Introduzca rango de tamaño de particiones mínimo: " >> informeBN.txt
		read rango_tam_par_min
		echo $rango_tam_par_min >> informeCOLOR.txt
		echo $rango_tam_par_min >> informeBN.txt
	done

	###  RANGO DE TAMAÑO DE PARTICIONES MÁXIMO  ###

	#clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo -n " Introduce rango de tamaño de particiones máximo: "
	echo -n " Introduce rango de tamaño de particiones máximo: " >> informeCOLOR.txt
	echo -n " Introduce rango de tamaño de particiones máximo: " >> informeBN.txt
	read rango_tam_par_max
	echo $rango_tam_par_max >> informeCOLOR.txt
	echo $rango_tam_par_max >> informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE TAMAÑO DE PARTICIONES  ###
	
	#He fusionado la comprobación de mayor que cero y mayor que tamaño de particiones mínimo porque me parece más elegante.
	while ! mayor_cero $rango_tam_par_max || [ $rango_tam_par_max -lt $rango_tam_par_min ]
	do
		if ! mayor_cero $rango_tam_par_max	#He añadido una explicación más detallada del error de introducción de opción.	
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
		else	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduzca rango de tamaño de particiones máximo: "
		echo -n " Introduzca rango de tamaño de particiones máximo: " >> informeCOLOR.txt
		echo -n " Introduzca rango de tamaño de particiones máximo: " >> informeBN.txt
		read rango_tam_par_max
		echo $rango_tam_par_max >> informeCOLOR.txt
		echo $rango_tam_par_max >> informeBN.txt
	done	

	#Asignación aleatoria del tamaño de particiones mínimo en el rango.
	tam_par_min=`shuf -i $rango_tam_par_min-$rango_tam_par_max -n 1`
	#Asignación aleatoria del tamaño de particiones máximo en el rango.
	tam_par_max=`shuf -i $rango_tam_par_min-$rango_tam_par_max -n 1`

	while [ $tam_par_min -gt $tam_par_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria del tamaño de particiones mínimo en el rango.
		tam_par_min=`shuf -i $rango_tam_par_min-$rango_tam_par_max -n 1`
		#Asignación aleatoria del tamaño de particiones máximo en el rango.
		tam_par_max=`shuf -i $rango_tam_par_min-$rango_tam_par_max -n 1`
	done

	#Asignación aleatoria del tamaño de particiones en el rango.
	for ((p=0; p < $n_par; p++))
	{
		tam_par[$p]=`shuf -i $tam_par_min-$tam_par_max -n 1`
	}

	###  RANGO DE QUÁNTUM MÍNIMO  ###

	#clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios		
	echo -n " Introduce el rango de quantum de ejecución mínimo: "
	echo -n " Introduce el rango de quantum de ejecución mínimo: " >> informeCOLOR.txt
	echo -n " Introduce el rango de quantum de ejecución mínimo: " >> informeBN.txt
	read rango_quantum_min
	echo $rango_quantum_min >> informeCOLOR.txt
	echo $rango_quantum_min >> informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_quantum_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduce el rango de quantum de ejecución mínimo: "
		echo -n " Introduce el rango de quantum de ejecución mínimo: " >> informeCOLOR.txt
		echo -n " Introduce el rango de quantum de ejecución mínimo: " >> informeBN.txt
		read rango_quantum_min
		echo $rango_quantum_min >> informeCOLOR.txt
		echo $rango_quantum_min >> informeBN.txt
	done

	###  RANGO DE QUÁNTUM MÁXIMO  ###

	#clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo -n " Introduce el rango de quantum de ejecución máximo: "
	echo -n " Introduce el rango de quantum de ejecución máximo: " >> informeCOLOR.txt
	echo -n " Introduce el rango de quantum de ejecución máximo: " >> informeBN.txt
	read rango_quantum_max
	echo $rango_quantum_max >> informeCOLOR.txt
	echo $rango_quantum_max >> informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE QUÁNTUM  ###

	#He fusionado la comprobación de mayor que cero y mayor que quántum mínimo porque me parece más elegante.
	while ! mayor_cero $rango_quantum_max || [ $rango_quantum_max -lt $rango_quantum_min ]
	do
		if ! mayor_cero $rango_quantum_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduce el rango de quantum de ejecución máximo: "
		echo -n " Introduce el rango de quantum de ejecución máximo: " >> informeCOLOR.txt
		echo -n " Introduce el rango de quantum de ejecución máximo: " >> informeBN.txt
		read rango_quantum_max
		echo $rango_quantum_max >> informeCOLOR.txt
		echo $rango_quantum_max >> informeBN.txt
	done

	#Asignación aleatoria del quántum mínimo en el rango.
	quantum_min=`shuf -i $rango_quantum_min-$rango_quantum_max -n 1`
	#Asignación aleatoria del quántum máximo en el rango.
	quantum_max=`shuf -i $rango_quantum_min-$rango_quantum_max -n 1`

	while [ $quantum_min -gt $quantum_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria del quántum mínimo en el rango.
		quantum_min=`shuf -i $rango_quantum_min-$rango_quantum_max -n 1`
		#Asignación aleatoria del quántums máximo en el rango.
		quantum_max=`shuf -i $rango_quantum_min-$rango_quantum_max -n 1`
	done

	#Asignación aleatoria del quántum en el rango.
	quantum=`shuf -i $quantum_min-$quantum_max -n 1`

	#clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
}


### Lectura de los datos de rangos para rangos de los procesos para la introducción a mano de rangos aleatorios (opción 7).
lectura_dat_procesos_rangos_aleatorios()
{
	num_proc=0
	procesos_ejecutables=0 	#Número de procesos que entran en memoria y se pueden ejecutar en CPU

	###  RANGO DE PROCESOS MÍNIMO  ###
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo -n " Introduce el rango de procesos mínimo: "
	echo -n " Introduce el rango de procesos mínimo: " >> informeCOLOR.txt
	echo -n " Introduce el rango de procesos mínimo: " >> informeBN.txt
	read rango_num_proc_min
	echo $rango_num_proc_min >> informeCOLOR.txt
	echo $rango_num_proc_min >> informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_num_proc_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduce el rango de procesos mínimo: "
		echo -n " Introduce el rango de procesos mínimo: " >> informeCOLOR.txt
		echo -n " Introduce el rango de procesos mínimo: " >> informeBN.txt
		read rango_num_proc_min
		echo $rango_num_proc_min >> informeCOLOR.txt
		echo $rango_num_proc_min >> informeBN.txt
	done

	###  RANGO DE PROCESOS MÁXIMO  ###

	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo -n " Introduce el rango de procesos máximo: "
	echo -n " Introduce el rango de procesos máximo: " >> informeCOLOR.txt
	echo -n " Introduce el rango de procesos máximo: " >> informeBN.txt
	read rango_num_proc_max
	echo $rango_num_proc_max >> informeCOLOR.txt
	echo $rango_num_proc_max >> informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE NÚMERO DE PROCESOS  ###

	#He fusionado la comprobación de mayor que cero y mayor que número de procesos mínimo porque me parece más elegante.
	while ! mayor_cero $rango_num_proc_max || [ $rango_num_proc_max -lt $rango_num_proc_min ]
	do
		if ! mayor_cero $rango_num_proc_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduce el rango de procesos máximo: "
		echo -n " Introduce el rango de procesos máximo: " >> informeCOLOR.txt
		echo -n " Introduce el rango de procesos máximo: " >> informeBN.txt
		read rango_num_proc_max
		echo $rango_num_proc_max >> informeCOLOR.txt
		echo $rango_num_proc_max >> informeBN.txt
	done
	
	#Asignación aleatoria del número de procesos mínimo en el rango.
	num_proc_min=`shuf -i $rango_num_proc_min-$rango_num_proc_max -n 1`
	#Asignación aleatoria del quántum máximo en el rango.
	num_proc_max=`shuf -i $rango_num_proc_min-$rango_num_proc_max -n 1`

	while [ $num_proc_min -gt $num_proc_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria del número de procesos mínimo en el rango.
		num_proc_min=`shuf -i $rango_num_proc_min-$rango_num_proc_max -n 1`
		#Asignación aleatoria del quántum máximo en el rango.
		num_proc_max=`shuf -i $rango_num_proc_min-$rango_num_proc_max -n 1`
	done

	#Asignación aleatoria del número de procesos en el rango.
	num_proc=`shuf -i $num_proc_min-$num_proc_max -n 1`

	###   RANGO DE TIEMPO DE LLEGADA MÍNIMO  ###

	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: "
	echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: " >> informeBN.txt
	read rango_entrada_min
	echo $rango_entrada_min >> informeCOLOR.txt
	echo $rango_entrada_min >> informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_entrada_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: "
		echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: " >> informeBN.txt
		read rango_entrada_min
		echo $rango_entrada_min >> informeCOLOR.txt
		echo $rango_entrada_min >> informeBN.txt
	done

	###   RANGO DE TIEMPO DE LLEGADA MÁXIMO  ###

	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: "
	echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: " >> informeBN.txt
	read rango_entrada_max
	echo $rango_entrada_max >> informeCOLOR.txt
	echo $rango_entrada_max >> informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE TIEMPOS DE LLEGADA  ###

	#He fusionado la comprobación de mayor que cero y mayor que llegada mínima porque me parece más elegante.
	while ! mayor_cero $rango_entrada_max || [ $rango_entrada_max -lt $rango_entrada_min ]
	do
		if ! mayor_cero $rango_entrada_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: "
		echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: " >> informeBN.txt
		read rango_entrada_max
		echo $rango_entrada_max >> informeCOLOR.txt
		echo $rango_entrada_max >> informeBN.txt
	done

	#Asignación aleatoria del tiempo de llegada mínimo en el rango.
	entrada_min=`shuf -i $rango_entrada_min-$rango_entrada_max -n 1`
	#Asignación aleatoria del tiempo de llegada máximo en el rango.
	entrada_max=`shuf -i $rango_entrada_min-$rango_entrada_max -n 1`

	while [ $entrada_min -gt $entrada_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria del tiempo de llegada mínimo en el rango.
		entrada_min=`shuf -i $rango_entrada_min-$rango_entrada_max -n 1`
		#Asignación aleatoria del tiempo de llegada máximo en el rango.
		entrada_max=`shuf -i $rango_entrada_min-$rango_entrada_max -n 1`
	done

	###  RANGO DE RÁFAGA MÍNIMA  ###

	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: "
	echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: " >> informeBN.txt
	read rango_rafaga_min
	echo $rango_rafaga_min >> informeCOLOR.txt
	echo $rango_rafaga_min >> informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_rafaga_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
		echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: "
		echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: " >> informeBN.txt
		read rango_rafaga_min
		echo $rango_rafaga_min >> informeCOLOR.txt
		echo $rango_rafaga_min >> informeBN.txt
	done

	###  RANGO DE RÁFAGA MÁXIMA  ###

	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: "
	echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: " >> informeBN.txt
	read rango_rafaga_max
	echo $rango_rafaga_max >> informeCOLOR.txt
	echo $rango_rafaga_max >> informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE RÁFAGA  ###

	#He fusionado la comprobación de mayor que cero y mayor que ráfaga mínima porque me parece más elegante.
	while ! mayor_cero $rango_rafaga_max || [ $rango_rafaga_max -lt $rango_rafaga_min ]
	do
		if ! mayor_cero $rango_rafaga_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then 
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
		else  	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: "
		echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: " >> informeBN.txt
		read rango_rafaga_max
		echo $rango_rafaga_max >> informeCOLOR.txt
		echo $rango_rafaga_max >> informeBN.txt
	done

	#Asignación aleatoria de ráfaga mínima en el rango.
	rafaga_min=`shuf -i $rango_rafaga_min-$rango_rafaga_max -n 1`
	#Asignación aleatoria de ráfaga máxima en el rango.
	rafaga_max=`shuf -i $rango_rafaga_min-$rango_rafaga_max -n 1`

	while [ $rafaga_min -gt $rafaga_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria de ráfaga mínima en el rango.
		rafaga_min=`shuf -i $rango_rafaga_min-$rango_rafaga_max -n 1`
		#Asignación aleatoria de ráfaga máxima en el rango.
		rafaga_max=`shuf -i $rango_rafaga_min-$rango_rafaga_max -n 1`
	done

	###  RANGO DE MEMORIA  ###

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

	###  RANGO DE MEMORIA MÍNIMA  ###

	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo -n " Introduce el rango de memoria mínima de los procesos: "
	echo -n " Introduce el rango de memoria mínima de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce el rango de memoria mínima de los procesos: " >> informeBN.txt
	read rango_memo_proc_min
	echo $rango_memo_proc_min >> informeCOLOR.txt
	echo $rango_memo_proc_min >> informeBN.txt

	###  COMPROBACIÓN DE MEMORIA MÍNIMA MAYOR QUE CERO Y MENOR QUE TAMAÑO DE PARTICIONES  ###

	#He fusionado las comprobaciones de mayor que cero y menor que partición máxima para evitar la situación que se daba al poder introducir
	#un valor correcto mayor que cero primero, pero luego un valor incorrecto mayor que la partición máxima y en el reintento un valor"correcto" 
	#menor que la partición máxima pero menor que 0 o directamente no un número.
	while ! mayor_cero $rango_memo_proc_min || [ $rango_memo_proc_min -gt $tam_par_max_efec ]
	do
		if ! mayor_cero $rango_memo_proc_min 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
		else #Si la memoria mínima de los procesos es mayor que la mayor partición.
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeBN.txt
		fi
		echo -n " Introduce el rango de memoria mínima de los procesos: "
		echo -n " Introduce el rango de memoria mínima de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce el rango de memoria mínima de los procesos: " >> informeBN.txt
		read rango_memo_proc_min
		echo $rango_memo_proc_min >> informeCOLOR.txt
		echo $rango_memo_proc_min >> informeBN.txt
	done

	###  RANGO DE MEMORIA MÁXIMA  ###

	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo -n " Introduce el rango de memoria máxima de los procesos: "
	echo -n " Introduce el rango de memoria máxima de los procesos: " >> informeCOLOR.txt
	echo -n " Introduce el rango de memoria máxima de los procesos: " >> informeBN.txt
	read rango_memo_proc_max
	echo $rango_memo_proc_max >> informeCOLOR.txt
	echo $rango_memo_proc_max >> informeBN.txt

	###  COMPROBACIÓN DE MEMORIA MÁXIMA MAYOR QUE CERO, MENOR QUE TAMAÑO DE PARTICIONES Y DE RANGOS DE MEMORIA ###

	#He fusionado las comprobaciones de mayor que cero, menor que partición máxima y mayor que memoria mínima para evitar la situación que se daba 
	#al poder introducir un valor correcto mayor que cero primero, pero luego un valor incorrecto mayor que la partición máxima y en el reintento 
	#un valor"correcto" menor que la partición máxima pero menor que 0 o directamente no un número, o un valor correcto mayor que cero y menor o igual 
	#que la mayor partición pero luego un valor "correcto" mayor que la memoria mínima pero mayor también que la partición máxima.
	while ! mayor_cero $rango_memo_proc_max || [ $rango_memo_proc_max -gt $tam_par_max_efec ] || [ $rango_memo_proc_max -lt $rango_memo_proc_min ]
	do
		if ! mayor_cero $rango_memo_proc_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> informeBN.txt
		elif [ $rango_memo_proc_max -gt $tam_par_max_efec ] 	#Si la memoria máxima de los procesos es mayor que la mayor partición.
		then
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> informeBN.txt
		else 
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> informeBN.txt
		fi
		echo -n " Introduce el rango de memoria máxima de los procesos: "
		echo -n " Introduce el rango de memoria máxima de los procesos: " >> informeCOLOR.txt
		echo -n " Introduce el rango de memoria máxima de los procesos: " >> informeBN.txt
		read rango_memo_proc_max
		echo $rango_memo_proc_max >> informeCOLOR.txt
		echo $rango_memo_proc_max >> informeBN.txt
	done

	#Asignación aleatoria de memoria mínima en el rango.
	memo_proc_min=`shuf -i $rango_memo_proc_min-$rango_memo_proc_max -n 1`
	#Asignación aleatoria de memoria máxima en el rango.
	memo_proc_max=`shuf -i $rango_memo_proc_min-$rango_memo_proc_max -n 1`

	while [ $memo_proc_min -gt $memo_proc_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria de memoria mínima en el rango.
		memo_proc_min=`shuf -i $rango_memo_proc_min-$rango_memo_proc_max -n 1`
		#Asignación aleatoria de memoria máxima en el rango.
		memo_proc_max=`shuf -i $rango_memo_proc_min-$rango_memo_proc_max -n 1`
	done

	#Calculo los datos de los procesos.
	datos_procesos_aleatorios

	ordenacion_procesos
	imprimir_tabla_procesos_rangos_aleatorios
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
	sed -i 5d $fich
	sed -i 3d $fich
	sed -i 1d $fich

	while read line
	do
		if [[ $n_linea == 0 ]] 					#La primera línea contiene los datos de las particiones
		then
			part_leidas=0
			for dat in $line 
			do
				tam_par[$part_leidas]=$dat 		#Cada dato es el tamaño de una partición.
				let part_leidas=part_leidas+1 	#Sumo las particiones leídas.
			done
			n_par=$part_leidas					#Ajusto el número de particiones leídas.
		elif [[ $n_linea == 1 ]]				#En la segunda línea está el quántum.
		then
			for dat in $line 
			do
				quantum=$dat
			done
		else
			dat_proc_leidos=0
			for dat in $line #Cada línea siguiente contiene los datos de cada proceso.
			do
				NUMPROC_I[$num_proc]=$(($num_proc+1))
				case $dat_proc_leidos in 
					0)
						T_ENTRADA_I[$num_proc]=$dat 
					;;
					1)
						T_EJECUCION_I[$num_proc]=$dat 
					;;
					2)
						MEMORIA_I[$num_proc]=$dat 
					;;
					*)
						echo "Error al leer los procesos del fichero $1.txt"
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
				echo "Error al leer los procesos del fichero $1.txt"
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
	
	for(( pr=0; pr<$num_proc; pr++ ))
	do
		NUMPROC_I[$pr]=$(($pr+1))
		entrada=`shuf -i $entrada_min-$entrada_max -n 1`
		T_ENTRADA_I[$pr]="$entrada"
		rafaga=`shuf -i $rafaga_min-$rafaga_max -n 1`
		T_EJECUCION_I[$pr]="$rafaga"
		memo_proc=`shuf -i $memo_proc_min-$memo_proc_max -n 1`
		MEMORIA_I[$pr]="$memo_proc"
	done

	datos_fichTfich
	ordenacion_procesos
	rm $fich
}

### Lee los datos desde un fichero de rangos aleatorios.
lectura_fichero_rangos_aleatorios()
{
	n_linea=0
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
							rango_n_par_min=$dat
						;;
						1)						#Segundo dato, máximo.
							rango_n_par_max=$dat
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
							rango_tam_par_min=$dat
						;;
						1)						#Segundo dato, máximo.
							rango_tam_par_max=$dat
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
							rango_quantum_min=$dat
						;;
						1)						#Segundo dato, máximo.
							rango_quantum_max=$dat
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
							rango_num_proc_min=$dat
						;;
						1)						#Segundo dato, máximo.
							rango_num_proc_max=$dat
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
							rango_entrada_min=$dat
						;;
						1)						#Segundo dato, máximo.
							rango_entrada_max=$dat
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
							rango_rafaga_min=$dat
						;;
						1)						#Segundo dato, máximo.
							rango_rafaga_max=$dat
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
							rango_memo_proc_min=$dat
						;;
						1)						#Segundo dato, máximo.
							rango_memo_proc_max=$dat
						;;
					esac
					let dat_leidos=dat_leidos+1
				done
			;;
			*)
				echo "Error al leer los procesos del fichero $1.txt"
				read -p "close" x
			;;
		esac
		let n_linea=n_linea+1 #Suma el número de líneas leídas.
	done < $fich

	#Asignación aleatoria del número de particiones mínimo en el rango.
	n_par_min=`shuf -i $rango_n_par_min-$rango_n_par_max -n 1`
	#Asignación aleatoria del número de particiones máximo en el rango.
	n_par_max=`shuf -i $rango_n_par_min-$rango_n_par_max -n 1`
	while [ $n_par_min -gt $n_par_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria del número de particiones mínimo en el rango.
		n_par_min=`shuf -i $rango_n_par_min-$rango_n_par_max -n 1`
		#Asignación aleatoria del número de particiones máximo en el rango.
		n_par_max=`shuf -i $rango_n_par_min-$rango_n_par_max -n 1`
	done
	#Asignación aleatoria del número de particiones en el rango.
	n_par=`shuf -i $n_par_min-$n_par_max -n 1`

	#Asignación aleatoria del tamaño de particiones mínimo en el rango.
	tam_par_min=`shuf -i $rango_tam_par_min-$rango_tam_par_max -n 1`
	#Asignación aleatoria del tamaño de particiones máximo en el rango.
	tam_par_max=`shuf -i $rango_tam_par_min-$rango_tam_par_max -n 1`
	while [ $tam_par_min -gt $tam_par_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria del tamaño de particiones mínimo en el rango.
		tam_par_min=`shuf -i $rango_tam_par_min-$rango_tam_par_max -n 1`
		#Asignación aleatoria del tamaño de particiones máximo en el rango.
		tam_par_max=`shuf -i $rango_tam_par_min-$rango_tam_par_max -n 1`
	done
	for (( pa = 0; pa < n_par; pa++ ))
	do
		tam_par[$pa]=`shuf -i $tam_par_min-$tam_par_max -n 1`
	done

	#Asignación aleatoria del quántum mínimo en el rango.
	quantum_min=`shuf -i $rango_quantum_min-$rango_quantum_max -n 1`
	#Asignación aleatoria del quántum máximo en el rango.
	quantum_max=`shuf -i $rango_quantum_min-$rango_quantum_max -n 1`
	while [ $quantum_min -gt $quantum_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria del quántum mínimo en el rango.
		quantum_min=`shuf -i $rango_quantum_min-$rango_quantum_max -n 1`
		#Asignación aleatoria del quántums máximo en el rango.
		quantum_max=`shuf -i $rango_quantum_min-$rango_quantum_max -n 1`
	done
	quantum=`shuf -i $quantum_min-$quantum_max -n 1`

	#Asignación aleatoria del número de procesos mínimo en el rango.
	num_proc_min=`shuf -i $rango_num_proc_min-$rango_num_proc_max -n 1`
	#Asignación aleatoria del quántum máximo en el rango.
	num_proc_max=`shuf -i $rango_num_proc_min-$rango_num_proc_max -n 1`
	while [ $num_proc_min -gt $num_proc_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria del número de procesos mínimo en el rango.
		num_proc_min=`shuf -i $rango_num_proc_min-$rango_num_proc_max -n 1`
		#Asignación aleatoria del quántum máximo en el rango.
		num_proc_max=`shuf -i $rango_num_proc_min-$rango_num_proc_max -n 1`
	done
	num_proc=`shuf -i $num_proc_min-$num_proc_max -n 1`
	
	#Asignación aleatoria del tiempo de llegada mínimo en el rango.
	entrada_min=`shuf -i $rango_entrada_min-$rango_entrada_max -n 1`
	#Asignación aleatoria del tiempo de llegada máximo en el rango.
	entrada_max=`shuf -i $rango_entrada_min-$rango_entrada_max -n 1`
	while [ $entrada_min -gt $entrada_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria del tiempo de llegada mínimo en el rango.
		entrada_min=`shuf -i $rango_entrada_min-$rango_entrada_max -n 1`
		#Asignación aleatoria del tiempo de llegada máximo en el rango.
		entrada_max=`shuf -i $rango_entrada_min-$rango_entrada_max -n 1`
	done

	#Asignación aleatoria de ráfaga mínima en el rango.
	rafaga_min=`shuf -i $rango_rafaga_min-$rango_rafaga_max -n 1`
	#Asignación aleatoria de ráfaga máxima en el rango.
	rafaga_max=`shuf -i $rango_rafaga_min-$rango_rafaga_max -n 1`
	while [ $rafaga_min -gt $rafaga_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria de ráfaga mínima en el rango.
		rafaga_min=`shuf -i $rango_rafaga_min-$rango_rafaga_max -n 1`
		#Asignación aleatoria de ráfaga máxima en el rango.
		rafaga_max=`shuf -i $rango_rafaga_min-$rango_rafaga_max -n 1`
	done

	#Asignación aleatoria de memoria mínima en el rango.
	memo_proc_min=`shuf -i $rango_memo_proc_min-$rango_memo_proc_max -n 1`
	#Asignación aleatoria de memoria máxima en el rango.
	memo_proc_max=`shuf -i $rango_memo_proc_min-$rango_memo_proc_max -n 1`
	while [ $memo_proc_min -gt $memo_proc_max ]		#Mientras el mínimo sea mayor al máximo, se recalculan.
	do
		#Asignación aleatoria de memoria mínima en el rango.
		memo_proc_min=`shuf -i $rango_memo_proc_min-$rango_memo_proc_max -n 1`
		#Asignación aleatoria de memoria máxima en el rango.
		memo_proc_max=`shuf -i $rango_memo_proc_min-$rango_memo_proc_max -n 1`
	done

	for(( pr=0; pr<$num_proc; pr++ ))
	do
		NUMPROC_I[$pr]=$(($pr+1))
		entrada=`shuf -i $entrada_min-$entrada_max -n 1`
		T_ENTRADA_I[$pr]="$entrada"
		rafaga=`shuf -i $rafaga_min-$rafaga_max -n 1`
		T_EJECUCION_I[$pr]="$rafaga"
		memo_proc=`shuf -i $memo_proc_min-$memo_proc_max -n 1`
		MEMORIA_I[$pr]="$memo_proc"
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


### Función para guardar datos en un fichero con nombre elegido (terminará en .txt).
#He eliminado las funciones "meterAficheroUltimos" y "meterAficheroNuevo" y las he agrupado en ésta, dado que al seleccionar la opción ya se puede pasar como parámetro datos.txt.
meterAfichero()
{
	#rm datos.txt (única diferencia entre métodos)
	#Datos principales.
	echo "Particiones" > "$1".txt
	echo "${tam_par[@]}" >> "$1".txt
	echo "Quantum" >> "$1".txt
	echo "$quantum" >> "$1".txt
	echo "Procesos (T-Entrada Rafaga Memoria)" >> "$1".txt
	#Bucle para meter los datos de cada proceso.
	for(( pr=0; pr<$num_proc; pr++ ))
	do
		echo "${T_ENTRADA_I[$pr]} ${T_EJECUCION_I[$pr]} ${MEMORIA_I[$pr]}" >> "$1".txt
	done
}


### Función para guardar datos en un fichero con nombre elegido (terminará en RNG.txt para que no aparezca en los listados de ficheros no aleatorios).
#He eliminado las funciones "meterAficheroUltimos_aleatorio" y "meterAficheroNuevo_aleatorio" y las he agrupado en ésta, dado que al seleccionar la opción ya se puede pasar como parámetro datos.txt.
meterAficheroRangos()
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


### Función para guardar datos en un fichero con nombre elegido (terminará en RNGALE.txt para que no aparezca en los listados de ficheros no aleatorios).
meterAficheroRangosAleatorios()
{
	echo "Rangos del número de particiones" > "$1"RNGALE.txt
	echo "$rango_n_par_min $rango_n_par_max" >> "$1"RNGALE.txt
	echo "Rangos del tamaño de particiones" >> "$1"RNGALE.txt
	echo "$rango_tam_par_min $rango_tam_par_max" >> "$1"RNGALE.txt
	echo "Rangos del quantum" >> "$1"RNGALE.txt
	echo "$rango_quantum_min $rango_quantum_max" >> "$1"RNGALE.txt
	echo "Rango del número de procesos" >> "$1"RNGALE.txt
	echo "$rango_num_proc_min $rango_num_proc_max" >> "$1"RNGALE.txt
	echo "Rangos del tiempo de llegada)" >> "$1"RNGALE.txt
	echo "$rango_entrada_min $rango_entrada_max" >> "$1"RNGALE.txt
	echo "Rangos del tiempo de ejecución" >> "$1"RNGALE.txt
	echo "$rango_rafaga_min $rango_rafaga_max" >> "$1"RNGALE.txt
	echo "Rangos de la memoria de cada proceso" >> "$1"RNGALE.txt
	echo "$rango_memo_proc_min $rango_memo_proc_max" >> "$1"RNGALE.txt
}


### Imprime los datos de los procesos introducidos a mano hasta el momento.
imprimir_tabla_procesos()
{
	#clear
	imprime_cabecera_larga
	imprime_info_datos
	imprimir_tabla
}


### Imprime los datos de los procesos generados con rangos hasta el momento.
imprimir_tabla_procesos_aleatorios()
{
	#clear
	imprime_cabecera_larga
	imprime_info_datos_aleatorios
	imprimir_tabla
}


### Imprime los datos de los procesos generados con rangos de rangos hasta el momento.
imprimir_tabla_procesos_rangos_aleatorios()
{
	#clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	imprimir_tabla
}


### Imprime los datos de los procesos introducidos hasta el momento.
imprimir_tabla()
{
	#He añadido un comentario con los colores usados en el código, y acortado el array de colores repetidos dado que su funcionamiento es cíclico.
	#color=(cyan, pink, dark blue, purple, green, red)
	color=(96 95 94 35 92 91)

	for ((pr=0; pr<$num_proc; pr++ ))
	do
		if [[ $pr -ge 5 ]]
		then
			let colimp=pr%5
		else
			colimp=$pr
		fi

		echo -ne " \e[${color[$colimp]}mP"
		printf "%02d " "${NUMPROC[$pr]}"
		printf "%3s " "${T_ENTRADA[$pr]}"
		printf "%3s " "${TEJ[$pr]}"
		printf "%3s " "${MEMORIA[$pr]}"	
		echo -e $resetColor

		echo -ne " \e[${color[$colimp]}mP" >> informeCOLOR.txt
		printf "%02d " "${NUMPROC[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${TEJ[$pr]}" >> informeCOLOR.txt
		printf "%3s " "${MEMORIA[$pr]}" >> informeCOLOR.txt
		echo -e $resetColor >> informeCOLOR.txt

		echo -ne " P" >> informeBN.txt
		printf "%02d " "${NUMPROC[$pr]}" >> informeBN.txt
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
	for (( nn=1; $proceso<$num_proc; nn++ ))
	do
		for(( pr=0; pr<$num_proc; pr++ ))
		do
			let caca=nn-1
			if [[ ${T_ENTRADA_I[$pr]} -eq $caca ]]
			then
				NUMPROC[$proceso]=${NUMPROC_I[$pr]}
				T_ENTRADA[$proceso]=${T_ENTRADA_I[$pr]}
				TEJ[$proceso]=${T_EJECUCION_I[$pr]}
				MEMORIA[$proceso]=${MEMORIA_I[$pr]}
				FIN[$proceso]=0
				TIEMPO[$proceso]=${T_EJECUCION_I[$pr]}
				let proceso=proceso+1
			fi
		done
	done
}


### Función para elegir el modo de ejecución del algoritmo.
modo_ejecucion()
{
	#clear
	imprime_cabecera_larga
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

	#clear
}


### Guarda datos en en auxiliares para evitar su modificacion.
datos_aux()
{
	for(( cc=0; cc<$num_proc; cc++ ))
	do
		RAFAGA_AUX[$cc]=${TEJ[$cc]}
		MEMORIA_AUX[$cc]=${MEMORIA[$cc]}
	done
}


### Comprueba si un proceso entra en memoria guardandolo en un array.
en_memoria()
{
	for(( co=0; co<$num_proc; co++ ))
	do
		if [ ${MEMORIA[$co]} -ne ${MEMORIA_AUX[$co]} ]
		then
			EN_MEMO[$co]="No"
		fi
	done
}


### Actualiza la información de las particiones.
inicio_particiones()
{
	vacias=0
	for (( pr=0; pr<$num_proc; pr++ ))
	do
		if [[ ${ESTADO[$pr]} == "Terminado" ]]
		then
			PART[$pr]=-1
		fi
	done

	for (( pa=0; pa<$n_par; pa++ ))
	do
		if [[ ${ESTADO[${PROC[$pa]}]} == "Terminado" ]]
		then
			PROC[$pa]=-1
		fi

		if [[ ${PROC[$pa]} -eq -1 ]]
		then
			let vacias=vacias+1
		fi
	done	
}


### Función que calcula el número de espacios en base a las cifras para una tabla equilibrada.
#He modificado la parte de las particiones para tener en cuenta que se muestra el tamaño de cada partición mas un espacio.
calcula_espacios()
{

	espacios_n_par=${#n_par}

	if [[ $espacios_n_par -le 4 ]]
	then
		espacios_n_par_tabla=4
	else
		espacios_n_par_tabla=$espacios_n_par
	fi

	let espacios_tam_par=${#tam_par[@]}*2
	espacios_quantum=${#quantum}
	espacios_mayortll=${#mayortll}

	if [[ $espacios_mayortll -le 3 ]]
	then
		espacios_mayortll_tabla=3
	else
		espacios_mayortll_tabla=$espacios_mayortll
	fi

	espacios_mayormem=${#mayormem}

	if [[ $espacios_mayormem -le 3 ]]
	then
		espacios_mayormem_tabla=3
	else
		espacios_mayormem_tabla=$espacios_mayormem
	fi

	espacios_mayortej=${#mayortej}

	if [[ $espacios_mayortej -le 3 ]]
	then
		espacios_mayortej_tabla=3
	else
		espacios_mayortej_tabla=$espacios_mayortej
	fi

	espacios_num_proc=${#num_proc}

	if [[ $espacios_num_proc -le 2 ]]
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
		chartej=${#T_EJECUCION_I[contespacios2]}

		if [[ $chartej -le 3 ]]
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

		if [[ $charmem -le 3 ]]
		then
			CARACTERESMEM[$contespacios3]=3
		else
			CARACTERESMEM[$contespacios3]=$charmem
		fi

		ESPACIOSMEM[$contespacios3]=$(($espacios_mayormem_tabla-${CARACTERESMEM[$contespacios3]}))
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

	for((xp=0; xp<$num_proc; xp++))
	do	
		t_espera[$xp]=$(( ${T_ENTRADA[$xp]} + $(( ${TEJ[$xp]} - ${TIEMPO[$xp]} )) ))
		if [ ${t_espera[$xp]} -lt $(( $tiempo_transcurrido + 1 )) -a "${ESTADO[$xp]}" != "Terminado" ]
		then
			TES[$xp]=$(( $t_real - ${t_espera[$xp]} ))
		elif [ "${ESTADO[$xp]}" != "Terminado" ]
		then
			TES[$xp]=0
		fi

		if [[ ${T_ENTRADA[$xp]} -gt $tiempo_transcurrido ]] 
		then
			TES[$xp]="-"
		elif [[ $pvez == 0 ]]
		then
			TES[$xp]=0
			pvez=1
		fi

		if [[ ${TES[$xp]} != "-" ]]
		then
			TESMEDIA[$tesmed]=${TES[$xp]}
			let tesmed=tesmed+1
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


	#Imprime la tabla con los 3 datos principales.
	imprimir_tabla_particiones_ejecucion


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
		if [ $xp -ge 5 ]
		then
			let colimp=xp%5
		else
			colimp=$xp
		fi

		#Ahora los datos aparecen entablados
		printf " │ " >> informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}mP" >> informeCOLOR.txt
		printf "%02d" "${NUMPROC[$xp]}" >> informeCOLOR.txt
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


		if [[ PART[$xp] -eq -1 ]]
		then
			part_displ="-"
		else 
			let part_displ=${PART[$xp]}+1
		fi
		printf " │ " >> informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> informeCOLOR.txt
		printf "%4s" "$part_displ" >> informeCOLOR.txt
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

	for((xp=0; xp<$num_proc; xp++ ))
	do
		if [ $xp -ge 5 ]
		then
			let colimp=$xp%5
		else
			colimp=$xp
		fi

		#Ahora los datos aparecen entablados
		printf " │ " >> informeBN.txt
		echo -ne "P" >> informeBN.txt
		printf "%02d" "${NUMPROC[$xp]}" >> informeBN.txt
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

		if [[ PART[$xp] -eq -1 ]]
		then
			part_displ="-"
		else 
			let part_displ=${PART[$xp]}+1
		fi
		printf " │ " >> informeBN.txt
		printf "%4s" "$part_displ" >> informeBN.txt

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

	for((xp=0; xp<$num_proc; xp++ ))
	do
		if [ $xp -ge 5 ]
		then
			let colimp=xp%5
		else
			colimp=$xp
		fi

		#Impresión de los procesos y sus datos en la tabla
		#Ahora los datos aparecen entablados
		printf " │ "
		echo -ne "\e[${color[$colimp]}mP"
		printf "%02d" "${NUMPROC[$xp]}"
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

		if [[ PART[$xp] -eq -1 ]]
		then
			part_displ="-"
		else 
			let part_displ=${PART[$xp]}+1
		fi
		printf " │ "
		echo -ne "\e[${color[$colimp]}m"
		printf "%4s" "$part_displ"
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
	

	sum_t_esp=0
	cont_t_esp=0
	sum_t_ret=0
	cont_t_ret=0
	for (( pr=0; pr<$num_proc; pr++ ))
	do
		if [[ ${TES[$pr]} != "-" ]]
		then
			let sum_t_esp=sum_t_esp+${TES[$pr]}
			let cont_t_esp=cont_t_esp+1
		fi
		if [[ ${TRET[$pr]} != "-" ]]
		then
			let sum_t_ret=sum_t_ret+${TRET[$pr]}
			let cont_t_ret=cont_t_ret+1
		fi
	done

	#Representación de los tiempos medios
	if [[ $cont_t_esp -eq 0 ]]
	then
		printf " Tesp medio = 0.00\t"
		printf " Tesp medio = 0.00\t" >> informeCOLOR.txt
		printf " Tesp medio = 0.00\t" >> informeBN.txt
	else
		#LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $(bc <<< scale=2\;$mediaesp/$tesmed)
		#LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $(bc <<< scale=2\;$mediaesp/$tesmed) >> informeCOLOR.txt
		#LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $(bc <<< scale=2\;$mediaesp/$tesmed) >> informeBN.txt
		med_t_esp=$(awk -v num1=$sum_t_esp -v num2=$cont_t_esp 'BEGIN {print num1/num2}')
		LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $med_t_esp
		LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $med_t_esp >> informeCOLOR.txt
		LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $med_t_esp >> informeBN.txt
	fi
	if [[ $tretmed -eq 0 ]]
	then
		printf " Tret medio = 0.00\n"
		printf " Tret medio = 0.00\n" >> informeCOLOR.txt
		printf " Tret medio = 0.00\n" >> informeBN.txt
	else
		#LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $(bc <<< scale=2\;$mediaret/$tretmed)
		#LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $(bc <<< scale=2\;$mediaret/$tretmed) >> informeCOLOR.txt
		#LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $(bc <<< scale=2\;$mediaret/$tretmed) >> informeBN.txt
		med_t_ret=$(awk -v num1=$sum_t_ret -v num2=$cont_t_ret 'BEGIN {print num1/num2}')
		LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $med_t_ret
		LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $med_t_ret >> informeCOLOR.txt
		LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $med_t_ret >> informeBN.txt
	fi

	echo -n " Cola RR: "
	echo -n " Cola RR: " >> informeCOLOR.txt
	echo -n " Cola RR: " >> informeBN.txt
	for(( i = 1; i < ${#colaprocs[@]}; i++ ))
	do
		if [  ${colaprocs[$i]} -ge 5 ]
		then
			let colimp=${colaprocs[$i]}%5
		else
			colimp=${colaprocs[$i]}
		fi

		printf "\e[${color[$colimp]}mP%02d$resetColor " "$((${colaprocs[$i]}+1))"
		printf "\e[${color[$colimp]}mP%02d$resetColor " "$((${colaprocs[$i]}+1))" >> informeCOLOR.txt
		printf "P%02d " "$((${colaprocs[$i]}+1))" >> informeBN.txt
	done
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt

	actualizar_bm

	#actualizar_bt
	imprimir_bt

	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
	echo "---------------------------------------------------------" >> informeCOLOR.txt
	echo "---------------------------------------------------------" >> informeBN.txt
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt

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
	primvez=false
}


### Imprime la tabla con los datos de particiones y quántum.
imprimir_tabla_particiones_ejecucion()
{
	imprime_cabecera
	echo -e " ${cad_top_tab_pa[@]}"
	echo -e " ${cad_top_tab_pa[@]}" >> informeCOLOR.txt
	echo -e " ${cad_top_tab_pa[@]}" >> informeBN.txt
	echo -e " ${cad_datos_tab_pa[@]}"
	echo -e " ${cad_datos_tab_pa[@]}" >> informeCOLOR.txt
	echo -e " ${cad_datos_tab_pa[@]}" >> informeBN.txt
	echo -e " ${cad_bot_tab_pa[@]}"
	echo -e " ${cad_bot_tab_pa[@]}" >> informeCOLOR.txt
	echo -e " ${cad_bot_tab_pa[@]}" >> informeBN.txt
}


### Ajusta la tabla de los datos de particiones y quántum al tamaño necesario.
calcular_tabla_particiones_ejecucion()
{
	#Cadena del top de la tabla de particiones.
	cad_top_tab_pa=""

	#Cadena de títulos de datos de la tabla de particiones.
	cad_titulo_tab_pa=""

	#Cadena de datos de la tabla de particiones.
	cad_datos_tab_pa=""

	#Cadena del final de la tabla de particiones.
	cad_bot_tab_pa=""

	      cad_top_tab_pa=${cad_top_tab_pa[@]}" ┌──────────────"
	  cad_datos_tab_pa=${cad_datos_tab_pa[@]}" │Nº Part: $n_par"
	      cad_bot_tab_pa=${cad_bot_tab_pa[@]}" └──────────────"

	if [[ ${#n_par} -le 5 ]]									#Si el número de particiones ocupa 5 espacios o menos,
	then
		for (( esp=0; esp<5-${#n_par}; esp++ ))					#Para el hueco que quede hasta los 5 espacios,
		do
			cad_datos_tab_pa=${cad_datos_tab_pa[@]}" "			#Añado un espacio.
		done
	else 														#Si ocupa 6 o más espacios,
		for (( esp=0; esp<${#n_par}-5; esp++ ))					#Para lo que ocupe el número de particiones de más,
		do
			cad_top_tab_pa=${cad_top_tab_pa[@]}"─"				#Añado una línea en la cadena del top.
	      	cad_bot_tab_pa=${cad_bot_tab_pa[@]}"─"				#Añado una línea en la cadena del final.
		done
	fi
	      cad_top_tab_pa=${cad_top_tab_pa[@]}"─┬───────────────"	#Añado la siguiente parte de la tabla.
	  cad_datos_tab_pa=${cad_datos_tab_pa[@]}" │Tam Part: ${tam_par[@]} "
	      cad_bot_tab_pa=${cad_bot_tab_pa[@]}"─┴───────────────"

	if [[ $(($n_par*2)) -le 5 ]]								#Si el tamaño de las particiones ocupa 5 espacios o menos, (numero de particiones con un espacio después de cada una)
	then
		for (( esp=0; esp<5-$(($n_par*2)); esp++ ))				#Para el hueco que quede hasta los 5 espacios,
		do
			cad_datos_tab_pa=${cad_datos_tab_pa[@]}" "			#Añado un espacio.
		done
	else 														#Si ocupa más de 15 espacios,
		for (( esp=0; esp<$(($n_par*2))-5; esp++ ))				#Para lo que ocupe el tamaño de particiones de más,
		do
			cad_top_tab_pa=${cad_top_tab_pa[@]}"─"				#Añado una línea en la cadena del top.
	      	cad_bot_tab_pa=${cad_bot_tab_pa[@]}"─"				#Añado una línea en la cadena del final.
		done
	fi
	      cad_top_tab_pa=${cad_top_tab_pa[@]}"┬──────────────"	#Añado la siguiente parte de la tabla.
	  cad_datos_tab_pa=${cad_datos_tab_pa[@]}"│Quantum: $quantum"
	      cad_bot_tab_pa=${cad_bot_tab_pa[@]}"┴──────────────"

	if [[ ${#quantum} -le 5 ]]									#Si el quántum ocupa 5 espacios o menos,
	then
		for (( esp=0; esp<5-${#quantum}; esp++ ))				#Para el hueco que quede hasta los 5 espacios,
		do
			cad_datos_tab_pa=${cad_datos_tab_pa[@]}" "			#Añado un espacio.
		done
	else 														#Si ocupa más de 5 espacios,
		for (( esp=0; esp<${#n_par}-5; esp++ ))					#Para lo que ocupe el quántum de más,
		do
			cad_top_tab_pa=${cad_top_tab_pa[@]}"─"				#Añado una línea en la cadena del top.
	      	cad_bot_tab_pa=${cad_bot_tab_pa[@]}"─"				#Añado una línea en la cadena del final.
		done
	fi
	      cad_top_tab_pa=${cad_top_tab_pa[@]}"─┐"				#Añado el final de la tabla.
	  cad_datos_tab_pa=${cad_datos_tab_pa[@]}" │"
	      cad_bot_tab_pa=${cad_bot_tab_pa[@]}"─┘"
}


actualizar_bm()
{	
	#Variable que guarda el tamaño del espacio representado en la barra por cada unidad de memoria.
	tam_unidad_bm=$tam_unidad_bt

	#Cadena de particiones en la BM.
	cad_particiones="    |"

	#Cadena de procesos en la BM.
	cad_proc_bm="    |"

	#Cadena de cuadrados de colores en la BM.
	cad_mem_col=" BM |"

	#Cadena de cuadrados en blanco y negro en la BM.
	cad_mem_byn=" BM |"

	#Cadena de la cantidad de memoria en la BM.
	cad_can_mem="    |"

	#Variable para contar la memoria representada.
	mem_rep=0

	#Columnas que quedan en la consola a la derecha de la barra inicial en la BM.
	columnas_bm=$(($(tput cols)-5))


		
	for ((pa=0; pa<$n_par; pa++))
	do
		#Cortar a la siguiente línea la partición entera.
		#let ocup_par=${tam_par[$pa]}*tam_unidad_bm
		#if [[ $ocup_par -gt $columnas_bm ]]						#Si la unidad va a ocupar más de lo que queda de pantalla,
		#then
		#	echo -e "${cad_particiones[@]}"							#Represento lo que llevo de barra de memoria.
		#	echo -e "${cad_particiones[@]}" >> informeCOLOR.txt
		#	echo -e "${cad_particiones[@]}" >> informeBN.txt

		#	echo -e "${cad_proc_bm[@]}"
		#	echo -e "${cad_proc_bm[@]}" >> informeCOLOR.txt
		#	echo -e "${cad_proc_bm[@]}" >> informeBN.txt

		#	echo -e "${cad_mem_col[@]}"
		#	echo -e "${cad_mem_col[@]}" >> informeCOLOR.txt
		#	echo -e "${cad_mem_byn[@]}" >> informeBN.txt

		#	echo -e "${cad_can_mem[@]}"
		#	echo -e "${cad_can_mem[@]}" >> informeCOLOR.txt
		#	echo -e "${cad_can_mem[@]}" >> informeBN.txt

		#	cad_particiones="     "									#Reseteo las cadenas con el margen izquierdo de la cabecera de la barra.
		#	cad_proc_bm="     "
		#	cad_mem_col="     "
		#	cad_mem_byn="     "
		#	cad_can_mem="     "
		#	columnas_bm=$(($(tput cols)-5)) 						#Reseteo las columnas que quedan libres.
		#fi
		#let columnas_bm=columnas_bm-ocup_par-6						#Actualizo las columnas que quedan restando lo que ocupa la partición, con 5 espacios al principio.

		for (( uni_par=1; uni_par<=${tam_par[$pa]}; uni_par++ ))		#Para cada unidad imprimible de la partición (su tamaño).
		do
			#cortar a la siguiente línea la unidad de memoria.
			if [[ $tam_unidad_bm -gt $columnas_bm ]]
			then
				echo -e "${cad_particiones[@]}"							#Represento lo que llevo de barra de memoria.
				echo -e "${cad_particiones[@]}" >> informeCOLOR.txt
				echo -e "${cad_particiones[@]}" >> informeBN.txt

				echo -e "${cad_proc_bm[@]}"
				echo -e "${cad_proc_bm[@]}" >> informeCOLOR.txt
				echo -e "${cad_proc_bm[@]}" >> informeBN.txt

				echo -e "${cad_mem_col[@]}"
				echo -e "${cad_mem_col[@]}" >> informeCOLOR.txt
				echo -e "${cad_mem_byn[@]}" >> informeBN.txt

				echo -e "${cad_can_mem[@]}"
				echo -e "${cad_can_mem[@]}" >> informeCOLOR.txt
				echo -e "${cad_can_mem[@]}" >> informeBN.txt

				cad_particiones="     "									#Reseteo las cadenas con el margen izquierdo de la cabecera de la barra.
				cad_proc_bm="     "
				cad_mem_col="     "
				cad_mem_byn="     "
				cad_can_mem="     "
				columnas_bm=$(($(tput cols)-5)) 						#Reseteo las columnas que quedan libres.
			fi
			let columnas_bm=columnas_bm-tam_unidad_bm					#Actualizo las columnas que quedan restando lo que ocupa la unidad.


			## Montaje de la cadena de particiones en la barra de memoria.
			num_par=$(($pa+1))														#Guardo el número imprimible de la partición.
			if [[ ${#num_par} -eq 2 ]]												#Si tiene 2 caracteres,
			then
				num_par_pri="${num_par:0:1}"										#Separo los caracteres.
				num_par_seg="${num_par:1:2}"
			fi

			if [[ $uni_par -eq 1 ]]													#Si es la primera unidad,
			then
				case $tam_unidad_bm in 												#Según el tamaño de la unidad,
					3)																#El mínimo puede ser 3, un caracter y un espacio a cada lado.
						cad_particiones=${cad_particiones[@]}"Par"
					;;
					4)																#Si tiene 4 caracteres,
						cad_particiones=${cad_particiones[@]}"Part"					#Añado 4 caracteres.
					;;
					5)																#Si tiene 5 caracteres,
						cad_particiones=${cad_particiones[@]}"Part "				#Añado 5 caracteres.
					;;
					6)																#Si tiene 6 caracteres,
						if [[ ${#num_par} -eq 1 ]]									#Si el número de partición tiene un dígito,
						then
							cad_particiones=${cad_particiones[@]}"Part 0" 			#El número irá con un 0 delante.
						else 														#Si tiene más de un dígito,
							cad_particiones=${cad_particiones[@]}"Part $num_par_pri" #Añado el primer caracter del número sin el 0.
						fi
					;;
					*)																#7 o más caracteres, (No debería tener nunca 0, 1 o 2 caracteres, ni valores negativos)
						if [[ ${#num_par} -eq 1 ]]									#Si el número de partición tiene un dígito,
						then
							cad_particiones=${cad_particiones[@]}"Part 0$(($pa+1))" #Añado el número con un 0 delante.
						else 														#Si tiene más de un dígito,
							cad_particiones=${cad_particiones[@]}"Part $(($pa+1))"  #Añado el numero sin el 0.
						fi
						for (( esp=0; esp<($tam_unidad_bm-7); esp++ ))				#Por lo que queda de unidad (-7 de los caracteres "Part XX")
						do
							cad_particiones=${cad_particiones[@]}" "				#Añado un espacio.
						done
					;;
				esac
			elif [[ $uni_par -eq 2 ]] 												#Si es la segunda unidad,
			then
				case $tam_unidad_bm in 												#Según el tamaño de la unidad,
					3)																#Si tiene 3 caracteres,
						if [[ ${#num_par} -eq 1 ]]									#Si el número de partición tiene un dígito,
						then
							cad_particiones=${cad_particiones[@]}"t 0" 				#El número llevará un 0 delante.
						else 														#Si tiene más de un dígito,
							cad_particiones=${cad_particiones[@]}"t $num_par_pri"  	#Añado el primer dígito del número sin el 0.
						fi
					;;
					4)																#Si tiene 4 caracteres,
						cad_particiones=${cad_particiones[@]}" $(($pa+1))"			#Añado los siguientes 4 caracteres.
						for (( esp=0; esp<$tam_unidad_bm-${#num_par}-1; esp++ ))	#Por lo que queda de unidad menos los caracteres escritos, (lo que ocupa el número y un espacio)
						do
							cad_particiones=${cad_particiones[@]}" "				#Añado un espacio.
						done
					;;
					5)																#Si tiene 5 caracteres,
						cad_particiones=${cad_particiones[@]}"$(($pa+1))"			#Añado los siguientes caracteres.
						for (( esp=0; esp<$tam_unidad_bm-${#num_par}; esp++ ))		#Por lo que queda de unidad menos los caracteres escritos, (lo que ocupa el número)
						do
							cad_particiones=${cad_particiones[@]}" "				#Añado un espacio.
						done
					;;
					6)																#Si tiene 6 caracteres,
						if [[ ${#num_par} -eq 1 ]]									#Si el número de partición tiene un dígito,
						then														#Añado los siguientes caracteres.
							cad_particiones=${cad_particiones[@]}"$(($pa+1))" 		#El número que iba con un 0 delante.
						else 														#Si tiene más de un dígito,
							cad_particiones=${cad_particiones[@]}"$num_par_seg" 	#El segundo caracter del número.
						fi
						for (( esp=0; esp<$tam_unidad_bm-1; esp++ ))				#Por lo que queda de unidad menos el caracter escrito, (el espacio que ocupa el número o el segundo caracter del mismo)
						do
							cad_particiones=${cad_particiones[@]}" "				#Añado un espacio.
						done
					;;
					*)																#7 o más caracteres, (No debería tener nunca 0, 1 o 2 caracteres, ni valores negativos)
						for (( esp=0; esp<($tam_unidad_bm-7); esp++ ))				#Por lo que queda de unidad (-7 de los caracteres "Part XX")
						do
							cad_particiones=${cad_particiones[@]}" "				#Añado un espacio. (ya debería haberse añadido toda la información de la partición)
						done
					;;
				esac
			elif [[ $uni_par -eq 3 ]]												#Si es la tercera unidad,
			then
				case $tam_unidad_bm in 												#Según el tamaño de la unidad,
					3)																#Si tiene 3 caracteres,
						if [[ ${#num_par} -eq 1 ]]									#Si el número de partición tiene un dígito,
						then
							cad_particiones=${cad_particiones[@]}"$(($pa+1))" 		#El número que llevaba un 0 delante.
						else 														#Si tiene más de un dígito,
							cad_particiones=${cad_particiones[@]}"$num_par_seg"  	#Añado el segundo dígito del número.
						fi
						for (( esp=0; esp<$tam_unidad_bm-1; esp++ ))				#Por lo que queda de unidad menos el caracter escrito, (lo que ocupa el número o el segundo caracter del mismo)
						do
							cad_particiones=${cad_particiones[@]}" "				#Añado un espacio.
						done
					;;
					*)																#Para 4 o más caracteres ya se escibió toda la partición.
						for (( esp=0; esp<$tam_unidad_bm; esp++ ))					#Por lo que queda de unidad,
						do
							cad_particiones=${cad_particiones[@]}" "				#Añado un espacio.
						done
					;;
				esac
			else 																	#A partir de la cuarta unidad, ya se escribió toda la partición.	
				for (( esp=0; esp<$tam_unidad_bm; esp++ ))							#Por lo que queda de unidad,
				do
					cad_particiones=${cad_particiones[@]}" "						#Añado un espacio.
				done
			fi
			if [[ $uni_par -eq ${tam_par[$pa]} ]] && [[ $pa -ne $(($n_par-1)) ]] 	#Si es la última unidad (el final de la partición), y no es la última partición,
			then
				cad_particiones=${cad_particiones[@]}" "							#Añado un espacio entre particiones.
				let columnas_bm=columnas_bm-1										#Actualizo las columnas que quedan restando el espacio.
			fi


			##Montaje de la cadena de procesos en la abarra de memoria.
			if [[ ${PROC[$pa]} -ne -1 ]] && [[ $uni_par -eq 1 ]]					#Si tiene un proceso y es la primera unidad,
			then
				if [[ ${#NUMPROC[${PROC[$pa]}]} -eq 1 ]]							#Si el proceso tiene un caracter,
				then								
					cad_proc_bm=${cad_proc_bm[@]}"P0${NUMPROC[${PROC[$pa]}]}"		#Añado el numero del proceso con un cero delante.
				else 																#Si tiene más de un caracter,
					cad_proc_bm=${cad_proc_bm[@]}"P${NUMPROC[${PROC[$pa]}]}"		#Añado el número del proceso sin ceros delante.
				fi
				for (( esp=0; esp<$tam_unidad_bm-3; esp++ ))						#Por cada hueco hasta completar la unidad, (menos 3 caracteres impresos PXX)
				do
					cad_proc_bm=${cad_proc_bm[@]}" "								#Añado un espacio.
				done
			else  																	#Si no tiene proceso o no es la primera unidad,
				for (( esp=0; esp<$tam_unidad_bm; esp++ ))							#Por cada hueco hasta completar la unidad,
				do
					cad_proc_bm=${cad_proc_bm[@]}" "								#Añado un espacio.
				done
			fi
			if [[ $uni_par -eq ${tam_par[$pa]} ]] && [[ $pa -ne $(($n_par-1)) ]]	#Si es la última unidad (el final de la partición), y no es la última partición,
			then										
				cad_proc_bm=${cad_proc_bm[@]}" "									#Añado un espacio adicional entre particiones.
				let columnas_bm=columnas_bm-1										#Actualizo las columnas que quedan restando el espacio.
			fi


			## Montaje de la cadena de cuadros en la barra de memoria.
			if [[ ${PROC[$pa]} -ne -1 ]] && [[ ${MEMORIA[${PROC[$pa]}]} -ge $uni_par ]]	#Si tiene un proceso y ocupa hasta la unidad de partición actual,
			then
				if [[ ${PROC[$pa]} -ge 5 ]]												#Recupero el color del proceso.
				then
					let colimp=${PROC[$pa]}%5
				else
					colimp=${PROC[$pa]}
				fi

				for (( esp=0; esp<$tam_unidad_bm; esp++ ))								#Por cada hueco en la unidad,
				do
					cad_mem_col=${cad_mem_col[@]}"\e[${color[$colimp]}m\u2588\e[0m"		#Añado cuadrados de color a la cadena en color.
					cad_mem_byn=${cad_mem_byn[@]}"*"									#Añado asteriscos a la cadena en blanco y negro.
				done
			else 																		#Si no hay un proceso o no ocupa hasta la unidad actual,
				for (( esp=0; esp<$tam_unidad_bm; esp++ ))								#Por cada hueco en la unidad,
				do
					cad_mem_col=${cad_mem_col[@]}"\u2588"								#Añado cuadrados blancos.
					cad_mem_byn=${cad_mem_byn[@]}"\u2588"
				done
			fi
			if [[ $uni_par -eq ${tam_par[$pa]} ]] && [[ $pa -ne $(($n_par-1)) ]] 		#Si es la última unidad (el final de la partición), y no es la última partición,
			then
				cad_mem_col=${cad_mem_col[@]}" "										#Añado un espacio entre particiones.
				cad_mem_byn=${cad_mem_byn[@]}" "
				let columnas_bm=columnas_bm-1											#Actualizo las columnas que quedan restando el espacio.
			fi


			## Montaje de la cadena de cantidad de memoria en la barra de memoria.
			if [[ ${PROC[$pa]} -ne -1 ]] && [[ ${MEMORIA[${PROC[$pa]}]} -eq $uni_par ]]
			then																		#Si tiene un proceso que ocupa justo hasta la unidad actual,
				memo_proc=${MEMORIA[${PROC[$pa]}]}
				let mem_rep=mem_rep+memo_proc											#Actualizo la cantidad de memoria representada.
				for (( esp=0; esp<$(($tam_unidad_bm-${#mem_rep})); esp++ ))				#Por lo que ocupe la unidad menos lo que ocupa escribir la memoria,
				do
					cad_can_mem=${cad_can_mem[@]}" "									#Añado un espacio.
				done
				cad_can_mem=${cad_can_mem[@]}"$mem_rep"									#Añado la cifra de memoria que se ha representado.
			elif [[ $uni_par -eq ${tam_par[$pa]} ]] 									#Si es la última unidad de la partición,
			then
				if [[ ${PROC[$pa]} -eq -1 ]]											#Si no había un proceso,
				then
					let mem_rep=mem_rep+${tam_par[$pa]}									#Actualizo la memoria representada con el tamaño de la partición.
				else 																	#Si había un proceso,
					let mem_rep=mem_rep-memo_proc+${tam_par[$pa]}						#Actualizo la memoria representada con el tamaño de la partición menos la memoria que se sumó del proceso.
				fi
				for (( esp=0; esp<$(($tam_unidad_bm-${#mem_rep})); esp++ ))				#Por lo que ocupe la unidad menos lo que ocupa escribir la memoria,
				do
					cad_can_mem=${cad_can_mem[@]}" "									#Añado un espacio.
				done
				cad_can_mem=${cad_can_mem[@]}"$mem_rep"									#Añado la cifra de memoria que se ha representado.
			else 																		#Si no hay memoria que representar,
				for (( esp=0; esp<$tam_unidad_bm; esp++ ))								#Por lo que ocupe la unidad,
				do
					cad_can_mem=${cad_can_mem[@]}" "									#Añado un espacio.
				done
			fi
			if [[ $uni_par -eq ${tam_par[$pa]} ]] && [[ $pa -ne $(($n_par-1)) ]] 		#Si es la última unidad (el final de la partición), y no es la última partición,
			then
				cad_can_mem=${cad_can_mem[@]}" "										#Añado un espacio entre particiones.
				let columnas_bm=columnas_bm-1											#Actualizo las columnas que quedan restando el espacio.
			fi
		done
	done


	let ocup_mem_total=5+${#memoria_total}					#Calculo lo que ocupa escribir la memoria total (mas 5 de barra, espacio, M, =, y espacio final.
	if [[ $ocup_mem_total -gt $columnas_bm ]]				#Si va a ocupar más de lo que queda de pantalla,
	then
		echo -e "${cad_particiones[@]}"						#Represento lo que llevo de barra de memoria.
		echo -e "${cad_particiones[@]}" >> informeCOLOR.txt
		echo -e "${cad_particiones[@]}" >> informeBN.txt

		echo -e "${cad_proc_bm[@]}"
		echo -e "${cad_proc_bm[@]}" >> informeCOLOR.txt
		echo -e "${cad_proc_bm[@]}" >> informeBN.txt

		echo -e "${cad_mem_col[@]}"
		echo -e "${cad_mem_col[@]}" >> informeCOLOR.txt
		echo -e "${cad_mem_byn[@]}" >> informeBN.txt

		echo -e "${cad_can_mem[@]}"
		echo -e "${cad_can_mem[@]}" >> informeCOLOR.txt
		echo -e "${cad_can_mem[@]}" >> informeBN.txt

		cad_particiones="     "								#Reseteo las cadenas con el margen izquierdo de la cabecera de la barra.
		cad_proc_bm="     "
		cad_mem_col="     "
		cad_mem_byn="     "
		cad_can_mem="     "
	fi

	## Añado la memoria total a las cadena.
	cad_particiones=${cad_particiones[@]}"| "
	cad_proc_bm=${cad_proc_bm[@]}"| "
	cad_mem_col=${cad_mem_col[@]}"| M=$memoria_total "
	cad_mem_byn=${cad_mem_byn[@]}"| M=$memoria_total "
	cad_can_mem=${cad_can_mem[@]}"| "

	## Representacion de la Barra de Memoria.
	echo -e "${cad_particiones[@]}"
	echo -e "${cad_particiones[@]}" >> informeCOLOR.txt
	echo -e "${cad_particiones[@]}" >> informeBN.txt

	echo -e "${cad_proc_bm[@]}"
	echo -e "${cad_proc_bm[@]}" >> informeCOLOR.txt
	echo -e "${cad_proc_bm[@]}" >> informeBN.txt

	echo -e "${cad_mem_col[@]}"
	echo -e "${cad_mem_col[@]}" >> informeCOLOR.txt
	echo -e "${cad_mem_byn[@]}" >> informeBN.txt

	echo -e "${cad_can_mem[@]}"
	echo -e "${cad_can_mem[@]}" >> informeCOLOR.txt
	echo -e "${cad_can_mem[@]}" >> informeBN.txt
		
	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
}


iniciar_bt()
{
	#Calculo el tamaño del espacio representado en la barra por cada unidad de tiempo en función del tamaño del mayor tiempo de entrada.
	mas_tarde=0
	for ((pr=0; pr<$num_proc; pr++ ))
	do
		if [[ ${T_ENTRADA[$pr]} -gt $mas_tarde ]]
		then
			mas_tarde=${T_ENTRADA[$pr]}
			let mas_tarde=mas_tarde+${TEJ[$pr]}
		fi
	done
	tam_unidad_bt=5
	#Si va a haber procesos que lleven el tiempo a más de 3 cifras, se aumenta el tamaño de la unidad de tiempo.
	if [[ $((${#mas_tarde}+2)) -gt $tam_unidad_bt ]]
	then
		tam_unidad_bt=$((${#mas_tarde}+2))
	fi

	cad_proc_col_bt=""
	cad_proc_byn_bt=""
	cad_tie_col=""
	cad_tie_byn=""
	cad_can_tie=""
}


### Actualiza las cadenas de texto de la barra de tiempo añadiendo otra unidad de tiempo.
actualizar_bt_info()
{
	for((pr=0; pr<$num_proc; pr++))														#Bucle para contar los procesos que están fuera del sistema.
	do
		if [[ ${ESTADO[$pr]} == "Fuera de Sistema" ]]
		then
			let fuera_sist=fuera_sist+1
		fi
	done

	## Adición de la cadena de procesos en la barra de tiempo.
	if [[ -z $proc_actual ]] && [[ ! -z $proc_ante || $proc_ante -ne $proc_actual ]]	#Si hay un proceso en ejecución y es distinto al anterior,
	then
		if [[ $proc_actual -ge 5 ]] 													#Condicional para ajustar el color del proceso.
		then
			let colimp=proc_actual%5
		else
			colimp=$proc_actual
		fi

		if [[ ${#NUMPROC[$proc_actual]} -eq 1 ]]															#Si el proceso tiene una cifra,
		then
			cad_proc_col_bt[$tiempo_transcurrido]="\e[${color[$colimp]}mP0${NUMPROC[$proc_actual]}\e[0m"	#Añado el proceso con un 0 delante en color a la cadena de color.
			cad_proc_byn_bt[$tiempo_transcurrido]="P0${NUMPROC[$proc_actual]}"								#Añado el proceso con un 0 delante a la cadena en blanco y negro.
		else 																								#Si tiene más de una cifra,
			cad_proc_col_bt[$tiempo_transcurrido]="\e[${color[$colimp]}mP${NUMPROC[$proc_actual]}\e[0m"		#Añado el proceso sin el 0 delante en color a la cadena de color.
			cad_proc_byn_bt[$tiempo_transcurrido]="P${NUMPROC[$proc_actual]}"								#Añado el proceso sin el 0 delante a la cadena en blanco y negro.
		fi
		for (( esp=0; esp<tam_unidad_bt-3; esp++ ))															#Por cada hueco hasta completar la unidad, (menos 3 caracteres impresos PXX)
		do
			cad_proc_col_bt[$tiempo_transcurrido]=${cad_proc_col_bt[$tiempo_transcurrido]}" "				#Añado un espacio.
			cad_proc_byn_bt[$tiempo_transcurrido]=${cad_proc_byn_bt[$tiempo_transcurrido]}" "
		done
		proc_ante=$proc_actual																				#Actualizo la referencia de proceso anterior.
	else  																									#Si no tiene proceso o el proceso es el mismo de antes,
		for (( esp=0; esp<$tam_unidad_bt; esp++ ))															#Por cada hueco hasta completar la unidad,
		do
			cad_proc_col_bt[$tiempo_transcurrido]=${cad_proc_col_bt[$tiempo_transcurrido]}" "				#Añado un espacio.
			cad_proc_byn_bt[$tiempo_transcurrido]=${cad_proc_byn_bt[$tiempo_transcurrido]}" "
		done
	fi


	## Adición de la cadena de cantidad de tiempo en la barra de tiempo.
	if [[ $fuera_sist == $num_proc ]]																		#Si no hay procesos en el sistema.
	then
		for (( esp=0; esp<$tam_unidad_bt; esp++ ))															#Por cada hueco hasta completar la unidad,
		do
			cad_can_tie[$tiempo_transcurrido]=${cad_can_tie[$tiempo_transcurrido]}" "						#Añado un espacio.
		done
	else																									#Si hay procesos,
		for (( esp=0; esp<$tam_unidad_bt-${#tiempo_transcurrido}; esp++ ))									#Por cada hueco de la unidad menos lo que ocupe el tiempo,
		do
			cad_can_tie[$tiempo_transcurrido]=${cad_can_tie[$tiempo_transcurrido]}" "						#Añado un espacio.
		done
		cad_can_tie[$tiempo_transcurrido]=${cad_can_tie[$tiempo_transcurrido]}"$tiempo_transcurrido"		#Añado el tiempo.
	fi
}


### Actualiza la cadena de cuadraditos de la barra de tiempo añadiendo otra unidad de tiempo.
actualizar_bt_line()
{
	if [[ -z $proc_actual ]] 																				#Si hay un proceso en ejecución,
	then
		if [[ $proc_actual -ge 5 ]] 																		#Condicional para ajustar el color del proceso.
		then
			let colimp=proc_actual%5
		else
			colimp=$proc_actual
		fi

		for(( esp=0; esp<$tam_unidad_bt; esp++ ))															#Por lo que ocupa la unidad,
		do
			cad_tie_col[$tiempo_transcurrido]=${cad_tie_col[$tiempo_transcurrido]}"\e[${color[$colimp]}m\u2588\e[0m"	#Añado un cuadrado de color a la cadena de color.
			cad_tie_byn[$tiempo_transcurrido]=${cad_tie_byn[$tiempo_transcurrido]}"\u2588"								#Añado un cuadrado blanco a la cadena en blanco y negro.
		done
	else 																									#Si no hay un proceso en ejecución,
		for (( esp=0; esp<$tam_unidad_bt; esp++ ))															#Por cada hueco hasta completar la unidad,
		do
			cad_tie_col[$tiempo_transcurrido]=${cad_tie_col[$tiempo_transcurrido]}"\u2588"					#Añado un cuadrado blanco.
			cad_tie_byn[$tiempo_transcurrido]=${cad_tie_byn[$tiempo_transcurrido]}"\u2588"		
		done
	fi
}


### Representación de la Barra de Tiempo.
imprimir_bt()
{
	columnas_bt=$(($(tput cols)-5))
	if [[ $primvez == true ]]
	then
		cad_pro_aux_bt=""
		cad_cua_aux_bt=""
		cad_tie_aux_bt=""
		for (( esp_ini=0; esp_ini<$tam_unidad_bt; esp_ini++ ))
		do
			cad_pro_aux_bt=${cad_pro_aux_bt[@]}" "
			cad_cua_aux_bt=${cad_cua_aux_bt[@]}"\u2588"
		done
		for (( esp_ini=0; esp_ini<$tam_unidad_bt-${#tiempo_transcurrido}; esp_ini++ ))
		do
			cad_tie_aux_bt=${cad_tie_aux_bt[@]}" "
		done
		cad_tie_aux_bt=${cad_tie_aux_bt[@]}"$tiempo_transcurrido"
		echo -e "    |${cad_pro_aux_bt[@]}|"
		echo -e " BT |${cad_cua_aux_bt[@]}| T=$tiempo_transcurrido"
		echo -e "    |${cad_tie_aux_bt[@]}|"
	else
		prim_linea_proc=true
		prim_linea_tie=true
		prim_linea_can_tie=true

		uds_impresas=0 														#Contador de los caracteres impresos en la cadena de procesos.

		echo "columnas restantes de la pantalla: $columnas_bt"
		echo "tamaño de unidad: $tam_unidad_bt"
		let unidades_posibles=columnas_bt/tam_unidad_bt 					#Calculo cuántas unidades caben en lo que queda de pantalla.
		if [[ $tiempo_transcurrido -lt $unidades_posibles ]]				#Si no hay tantas unidades de tiempo que representar,
		then
			unidades_posibles=$tiempo_transcurrido							#Lo ajusto al tiempo actual.
		fi
		echo "unidades posibles: $unidades_posibles"

		while [[ $uds_impresas<$tiempo_transcurrido ]]						#Mientras queden unidades de tiempo que representar,
		do
			## Impresión de cadena de procesos.
			echo ""
			echo "" >> informeCOLOR.txt
			echo "" >> informeBN.txt
			if [[ prim_linea_proc==true ]]									#Si es la primera línea de la barra,
			then
				echo -ne "    |"											#Imprimo la cabecera con la barra en una nueva línea.
				echo -ne "    |" >> informeCOLOR.txt
				echo -ne "    |" >> informeBN.txt
				prim_linea_proc=false 										#Ya no es la primera línea.
			else 															#Si no es la primera línea de la barra,
				echo -ne "     "											#Imprimo la cabecera de espacios en una nueva línea.
				echo -ne "     " >> informeCOLOR.txt
				echo -ne "     " >> informeBN.txt
			fi
			for (( uni=0; uni<$unidades_posibles; uni++ ))					#Para cada unidad que cabe en la línea, 
			do
				printf "${cad_proc_col_bt[uni]}"							#Imprimo la unidad en la misma línea.
				printf "${cad_proc_col_bt[uni]}" >> informeCOLOR.txt
				printf "${cad_proc_byn_bt[uni]}" >> informeBN.txt
			done

			## Impresión de cadena de tiempo.
			echo ""
			echo "" >> informeCOLOR.txt
			echo "" >> informeBN.txt
			if [[ prim_linea_tie==true ]]									#Si es la primera línea de la barra,
			then
				echo -ne " BT |"											#Imprimo la cabecera con la barra en una nueva línea.
				echo -ne " BT |" >> informeCOLOR.txt
				echo -ne " BT |" >> informeBN.txt
				prim_linea_tie=false 										#Ya no es la primera línea.
			else 															#Si no es la primera línea de la barra,
				echo -ne "     "											#Imprimo la cabecera de espacios en una nueva línea.
				echo -ne "     " >> informeCOLOR.txt
				echo -ne "     " >> informeBN.txt
			fi
			for (( uni=0; uni<$unidades_posibles; uni++ ))					#Para cada unidad que cabe en la línea, 
			do
				printf "${cad_tie_col[uni]}" 								#Imprimo la unidad en la misma línea.
				printf "${cad_tie_col[uni]}" >> informeCOLOR.txt
				printf "${cad_tie_byn[uni]}" >> informeBN.txt
				let uds_impresas=uds_impresas+1 							#Sumo el contador de unidades impresas.
			done

			## Impresión de cadena de cantidad de tiempo.
			echo ""
			echo "" >> informeCOLOR.txt
			echo "" >> informeBN.txt
			if [[ prim_linea_can_tie==true ]]								#Si es la primera línea de la barra,
			then
				echo -ne "    |"											#Imprimo la cabecera con la barra en una nueva línea.
				echo -ne "    |" >> informeCOLOR.txt
				echo -ne "    |" >> informeBN.txt
				prim_linea_can_tie=false 									#Ya no es la primera línea.
			else 															#Si no es la primera línea de la barra,
				echo -ne "     "											#Imprimo la cabecera de espacios en una nueva línea.
				echo -ne "     " >> informeCOLOR.txt
				echo -ne "     " >> informeBN.txt
			fi
			for (( uni=0; uni<$unidades_posibles; uni++ ))					#Para cada unidad que cabe en la línea, 
			do
				printf "${cad_can_tie[uni]}" 								#Imprimo la unidad en la misma línea.
				printf "${cad_can_tie[uni]}" >> informeCOLOR.txt
				printf "${cad_can_tie[uni]}" >> informeBN.txt
			done
		done
	fi

	echo ""
	echo "" >> informeCOLOR.txt
	echo "" >> informeBN.txt
}


### Representación de la Barra de Tiempo.
actualizar_bt()
{
	cad_pro_aux_bt=""
	cad_cua_aux_bt=""
	cad_tie_aux_bt=""
	for (( esp_ini=0; esp_ini<$tam_unidad_bt; esp_ini++ ))
	do
		cad_pro_aux_bt=${cad_pro_aux_bt[@]}" "
		cad_cua_aux_bt=${cad_cua_aux_bt[@]}"\u2588"
	done
	for (( esp_ini=0; esp_ini<$tam_unidad_bt-${#tiempo_transcurrido}; esp_ini++ ))
	do
		cad_tie_aux_bt=${cad_tie_aux_bt[@]}" "
	done
	cad_tie_aux_bt=${cad_tie_aux_bt[@]}"$tiempo_transcurrido"

	for (( i = 0, j = 0; i <= $const, j <= $constb; i++, j++ ))
	do
		#Comandos que ajustan las 3 lineas verticales del final de la barra de tiempo
		if [[ $primvez == true ]]													#Si es la primera vez que se imprime la barra (Al principio del ejercicio),
		then
			cadtiempo2[$j]="${cad_pro_aux_bt[@]}|"									#Imprimo espacios y cuadrados blancos iniciales.
			cadtiempo[$j]="${cad_cua_aux_bt[@]}|T=$tiempo_transcurrido"
			cadtiempo2bn[$j]="${cad_pro_aux_bt[@]}|"
			cadtiempobn[$j]="${cad_cua_aux_bt[@]}|T=$tiempo_transcurrido"
			cadtiempo3[$j]="${cad_tie_aux_bt[@]}|"
		else
			cadtiempo2[$j]=${cad2[$j]}"|"
			cadtiempo[$j]=${cad[$j]}"${cad_pro_aux_bt[@]}|T=$tiempo_transcurrido"
			cadtiempo2bn[$j]=${cad2bn[$j]}"|"
			cadtiempobn[$j]=${cadbn[$j]}"${cad_pro_aux_bt[@]}|T=$tiempo_transcurrido"
			cadtiempo3[$j]=${cad3[$j]}"|"
		fi

		#Representacion de la Barra de tiempo
		if [[ $i == 0 ]] 															#Si es el primer caracter de la barra de tiempo,
		then
			echo -e "    |${cadtiempo2[$j]}"
			echo -e "    |${cadtiempo2[$j]}" >> informeCOLOR.txt
			echo -e "    |${cadtiempo2bn[$i]}" >> informeBN.txt

			echo -e " BT |${cadtiempo[$i]}"
			echo -e " BT |${cadtiempo[$i]}" >> informeCOLOR.txt
			echo -e " BT |${cadtiempobn[$i]}" >> informeBN.txt

			echo -e "    |${cadtiempo3[$j]}"
			echo -e "    |${cadtiempo3[$j]}" >> informeCOLOR.txt
			echo -e "    |${cadtiempo3[$j]}" >> informeBN.txt
			columnas_bt=$(($(tput cols)-5-$tam_unidad_bt))
			num_linea=1
		else 																		#Si no es el primer caracter,
			let unidades_posibles=columnas_bt/tam_unidad_bt 						#Calculo cuántas unidades caben en lo que queda de pantalla.

			pos_linea=$(($i-($(tput cols)-5)*$num_linea))							#La posición en la línea actual  es la posición del caracter en la cadena menos  ( el número de caracteres 
																					#de la línea de pantalla menos 5 de cabecera, por el número de líneas de barra de tiempo que se han escrito ).
 			
 			if [[ $pos_linea -lt $(($unidades_posibles*$tam_unidad_bt))  ]]
 			then
 				echo -e "     ${cadtiempo2[$j]}"
				echo -e "     ${cadtiempo2[$j]}" >> informeCOLOR.txt
				echo -e "     ${cadtiempo2bn[$i]}" >> informeBN.txt

				echo -e "     ${cadtiempo[$i]}"
				echo -e "     ${cadtiempo[$i]}" >> informeCOLOR.txt
				echo -e "     ${cadtiempobn[$i]}" >> informeBN.txt

				echo -e "     ${cadtiempo3[$j]}"
				echo -e "     ${cadtiempo3[$j]}" >> informeCOLOR.txt
				echo -e "     ${cadtiempo3[$j]}" >> informeBN.txt
			else 
				echo ""
				let num_linea=num_linea+1
			fi
		fi

		#if [[ $i == 0 ]]
		#then
		#	echo -e "    |${cadtiempo2[$j]}"
		#	echo -e "    |${cadtiempo2[$j]}" >> informeCOLOR.txt
		#	echo -e "    |${cadtiempo2bn[$i]}" >> informeBN.txt

		#	echo -e " BT |${cadtiempo[$i]}"
		#	echo -e " BT |${cadtiempo[$i]}" >> informeCOLOR.txt
		#	echo -e " BT |${cadtiempobn[$i]}" >> informeBN.txt

		#	echo -e "    |${cadtiempo3[$j]}"
		#	echo -e "    |${cadtiempo3[$j]}" >> informeCOLOR.txt
		#	echo -e "    |${cadtiempo3[$j]}" >> informeBN.txt
		#else
		#	echo -e "     ${cadtiempo2[$j]}"
		#	echo -e "     ${cadtiempo2[$j]}" >> informeCOLOR.txt
		#	echo -e "     ${cadtiempo2bn[$i]}" >> informeBN.txt

		#	echo -e "     ${cadtiempo[$i]}"
		#	echo -e "     ${cadtiempo[$i]}" >> informeCOLOR.txt
		#	echo -e "     ${cadtiempobn[$i]}" >> informeBN.txt

		#	echo -e "     ${cadtiempo3[$j]}"
		#	echo -e "     ${cadtiempo3[$j]}" >> informeCOLOR.txt
		#	echo -e "     ${cadtiempo3[$j]}" >> informeBN.txt
		#fi
	done
}

### Actualiza la linea de tiempo, los cuadraditos de colores.
#He cambiado algunos comandos expr por let.
actualizar_linea()
{ 
	fuera_sist=0

	for((pr=0; pr<$num_proc; pr++))
	do
		if [[ ${ESTADO[$pr]} == "Fuera de Sistema" ]]
		then
			let fuera_sist=fuera_sist+1
		fi
	done

	if [[ $proc_actual -ge 5 ]]
	then
		let colimp=proc_actual%5
	else
		colimp=$proc_actual
	fi


	if [[ $ultvez == 0 ]]
	then
		#Cuadrados grises hasta que llegue el primer proceso
		if [[ $fuera_sist == $num_proc ]]
		then
			for(( k = 0; k < ${T_ENTRADA[0]}; k++ ))
			do
				for(( l=0; l<$tam_unidad_bt; l++ ))
				do
					cad1=$cad1"\u2588"
					cad1bn=$cad1bn"\u2588"
					let escritos=escritos+1
				done
			done
		elif [[ -z $proc_actual ]] #Si no hay procesos
		then
			for((l=0; l<$tam_unidad_bt; l++))
			do
				cad1=$cad1"\u2588"
				cad1bn=$cad1bn"\u2588"
				let escritos=escritos+1
			done
		else #Si hay procesos
			for((l=0; l<$tam_unidad_bt; l++))
			do
				cad1=$cad1"\e[${color[$colimp]}m\u2588\e[0m"
				cad1bn=$cad1bn"\u2588"
				let escritos=escritos+1
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
		for((i=$vali; i<$valcol; i++))
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

	for((pr=0; pr<$num_proc; pr++))
	do
		if [[ ${ESTADO[$pr]} == "Fuera de Sistema" ]]
		then
			let fuera_sist=fuera_sist+1
		fi
		if [[ $pr != $proc_actual ]]
		then
			EJEC[$pr]=0
		fi	
	done

	if [[ $proc_actual -ge 5 ]]
	then
		let colimp=proc_actual%5
	else
		colimp=$proc_actual
	fi

	if [[ $ultvez == 0 ]]
	then
		#Separacion inicial
		if [[ $fuera_sist == $num_proc ]]
		then
			for(( k=0; k<${T_ENTRADA[0]}; k++ ))
			do
				for(( l=0; l<$tam_unidad_bt; l++ ))
				do
					cad2b=$cad2b" "
					cad2bbn=$cad2bbn" "
					let saltocad=saltocad+1
				done
				if [[ $k -eq 0 ]]
				then
					cad3b=$cad3b"     "
					let saltocad=saltocad+1
				else
					for(( esp=0; esp<$tam_unidad_bt; esp++ ))
					do
						cad3b=$cad3b" "
						let saltocad=saltocad+1
					done
				fi
			done
		elif [[ -z $proc_actual ]]
		then
			if [[ $nulcontrol -eq 0 ]]
			then
				for(( esp=0; esp<$tam_unidad_bt-${#tiempo_transcurrido}; esp++ ))
				do
					cad3b=$cad3b" "
				done
				cad3b=$cad3b"$tiempo_transcurrido"

				for(( l=0; l<$tam_unidad_bt; l++ ))
				do
					cad2b=$cad2b" "
					cad2bbn=$cad2bbn" "
				done
				let saltocadc=saltocadc+$tam_unidad_bt
			else
				for(( l=0; l<$tam_unidad_bt; l++ ))
				do
					cad2b=$cad2b" "
					cad2bbn=$cad2bbn" "
					cad3b=$cad3b" "
					let saltocad=saltocad+1
					let saltocadc=saltocadc+1
				done
			fi
		else
			#Representacion con color del texto de la BT
			#Ahora aparece en el texto de la BT un proceso y el tiempo transcurrido si termina su cuantum, aunque sea el unico proceso en memoria.
			if [[ ${EJEC[$proc_actual]} == 0 ]] || [[ $((${T_EJEC[$proc_actual]} % $quantum)) = 1 ]] || [[ $quantum = 1 ]]
			then
				for (( esp=0; esp<$tam_unidad_bt-${#tiempo_transcurrido}; esp++ ))	#Por cada hueco hasta completar la unidad menos lo que ocupe el tiempo,
				do
					cad3b=$cad3b" "													#Añado un espacio a la cadena de cantidad de tiempo.
				done
				cad3b=$cad3b"$tiempo_transcurrido"

				if [[ ${#NUMPROC[$proc_actual]} -eq 1 ]]
				then
					cad2b=$cad2b"\e[${color[$colimp]}mP0${NUMPROC[$proc_actual]}\e[0m"
					cad2bbn=$cad2bbn"P0${NUMPROC[$proc_actual]}"
				else 
					cad2b=$cad2b"\e[${color[$colimp]}mP${NUMPROC[$proc_actual]}\e[0m"
					cad2bbn=$cad2bbn"P${NUMPROC[$proc_actual]}"
				fi
				for (( esp=0; esp<$tam_unidad_bt-3; esp++ ))						#Por cada hueco hasta completar la unidad, (menos 3 caracteres impresos PXX)
				do
					cad2b=$cad2b" "													#Añado un espacio.
					cad2bbn=$cad2bbn" "
				done

				let saltocad=saltocad+tam_unidad_bt
				let saltocadc=saltocadc+tam_unidad_bt
			else
				for((esp=0; esp<$tam_unidad_bt; esp++))
				do
					cad2b=$cad2b" "
					cad2bbn=$cad2bbn" "
					cad3b=$cad3b" "
					let saltocad=saltocad+1
					let saltocadc=saltocadc+1
				done
			fi
		fi
	fi

	IFS='-' read -r -a cad2array <<< "$cad2b"
	IFS='-' read -r -a cad2bnarray <<< "$cad2bbn"
	IFS='-' read -r -a cad3array <<< "$cad3b"

	let constb=saltocad/columnas
	const1b=0
	let constc=saltocadc/columnas
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
		let const1b=const1b+1
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


### Función que calcula el mayor dato de todos los procesos para cada dato (por ejemplo el mayor tiempo de llegada de 12 procesos) para ajustar la tabla a los datos introducidos.
mayor_dato_procesos()
{
	mayortll=0
	mayortej=0
	mayormem=0

	for (( pr=0; pr<$num_proc; pr++ ))
	do
		#Tiempo de llegada.
		if [[ $mayortll -lt ${T_ENTRADA_I[$pr]} ]]
		then
			mayortll=${T_ENTRADA_I[$pr]}
		fi

		#Tiempo de ejecución.
		if [[ $mayortej -lt ${T_EJECUCION_I[$pr]} ]]
		then
			mayortej=${T_EJECUCION_I[$pr]}
		fi

		#Espacio en memoria.
		if [[ $mayormem -lt ${MEMORIA_I[$pr]} ]]
		then
			mayormem=${MEMORIA_I[$pr]}
		fi
	done
}


### Calcula la memoria total de las particiones.
memoria_total()
{
	memoria_total=0
	for tp in "${tam_par[@]}"
	do
		let memoria_total=memoria_total+$tp
	done
	#return $memoria_total
}


### Setea valores al inicio del algoritmo.
inicializar()
{
	for(( pr=0 ; pr<$num_proc ; pr++ ))		#Setea todos los procesos:
	do
		ESTADO[$pr]="Fuera de Sistema"		#Fuera del sistema.
		EN_MEMO[$pr]="S/E"					#Fuera de memoria.
		TIEMPO_FIN[$pr]=0 					#Sin tiempo de fin.

		EN_COLA[$pr]="No"					#Fuera de la cola.
		contrcad[$pr]=0 					#
		contrcad2[$pr]=0 					#
		EJECUTADO[$pr]=0 					#No ejecutado.
		T_EJEC[$pr]=0 						#Sin tiempo de ejecución.
		TIEMPO[$pr]=${TEJ[$pr]}				#Sin tiempo de proceso.
		EJEC[$pr]=0 						#Fuera de ejecución.
	done

	for (( pa=0; pa<$n_par; pa++ ))			#Setea todas las particiones sin un proceso asociado con el valor especial -1.
	do
		PROC[$pa]=-1
	done
}

### Comprueba y mete un proceso en memoria al peor ajuste.
meterenmemo()
{
	for(( pr=0; pr<$num_proc; pr++ ))
	do
		mayor_tam_par=0
		part_vacia_may=-1
		for (( pa=0; pa<n_par; pa++ ))										#Busco la particion vacía más grande.
		do
			if [[ ${PROC[$pa]} -eq -1 ]] && [[ ${tam_par[$pa]} -gt  $mayor_tam_par ]] 
			then
				mayor_tam_par=${tam_par[$pa]}
				part_vacia_may=$pa
			fi
		done

		#Si el proceso puede entrar en memoria y cabe en la partición mayor,
		if [[ ${TIEMPO[$pr]} != 0 ]] && [[ $tiempo_transcurrido -ge ${T_ENTRADA[$pr]} ]] && [[ ${EN_MEMO[$pr]} == "S/E" ]] && [[ ${MEMORIA[$pr]} -le $mayor_tam_par ]]
		then
			EN_MEMO[$pr]="Si"												#Cambia el estado del proceso.
			PART[$pr]=$part_vacia_may 										#Asigna la partición al proceso.
			PROC[$part_vacia_may]=$pr 													#Asigna el proceso a la partición.
		fi
	done
}

### Asigna los estados a los procesos.
asignar_estados()
{
	inicio_particiones
	meterenmemo

	for(( pr=0; pr<$num_proc; pr++ ))
	do
		if [[ ${T_ENTRADA[$pr]} -le $tiempo_transcurrido ]] && [[ ${EN_MEMO[$pr]} != "No" ]]
		then
			ESTADO[$pr]="En espera"
		fi
	
		if [[ ${EN_MEMO[$pr]} == "Si" ]]
		then
			ESTADO[$pr]="En memoria"
		fi
	done
	
	if [[ ${EN_MEMO[$proc_actual]} == "Si" ]]
	then
		ESTADO[$proc_actual]="Ejecucion"
		T_EJEC[$proc_actual]=$(( ${T_EJEC[$proc_actual]} + 1 ))
	fi

	for(( pr=0; pr<$num_proc; pr++ ))
	do
		if [[ ${ESTADO[$pr]} == "Ejecucion" ]]
		then
			EJECUTADO[$pr]="Si"
		fi

		if [[ ${ESTADO[$pr]} == "En memoria" ]] && [[ ${EJECUTADO[$pr]} == "Si" ]]
		then
			ESTADO[$pr]="En pausa"
		fi
	done
}

#Copia estados para compararlo con el estado del mismo proceso más tarde y ver si este ha cambiado.
copiar_estados()
{
	for(( pr=0; pr<$num_proc; pr++ ))
	do
		ESTADOANT[$pr]=${ESTADO[$pr]}
	done
}

#Comparación de si un proceso ha cambiado de estado para pausar el algoritmo (Y pulsar intro para seguir, o esperar, o esperar un instante, dependiendo de lo elegido)
comparar_estados()
{
	evento=0
	for((pr=0; pr<$num_proc; pr++))
	do
		if [[ ${ESTADOANT[$pr]} != ${ESTADO[$pr]} ]]
		then
			evento=1
		fi
	done
}

cola()
{
	for(( pr=0; pr<$num_proc; pr++ ))
	do
		if [[ ${EN_MEMO[$pr]} == "Si" ]] && [[ ${EN_COLA[$pr]} == "No" ]] && [[ ${#colaprocs[@]} -lt $n_par ]]
		then
			colaprocs=( "${colaprocs[@]}" "$pr" )
			EN_COLA[$pr]="Si"
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
	actualizar_bt_info
	
	tabla_ejecucion

	actualizar_linea
	actualizar_bt_line

	tablapvez=0
	tiempo_transcurrido=$(($tiempo_transcurrido+${T_ENTRADA[0]}))

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
		actualizar_bt_info

		#Ahora aparece en el texto de la BT un proceso y el tiempo transcurrido si termina su cuantum, aunque sea el unico proceso en memoria.
		#Esta parte pausa la ejecucion en cada evento
		if [[ $evento = 1 ]] || [[ -z $proc_actual ]] || [[ $((${T_EJEC[$proc_actual]} % $quantum)) = 1 ]] || [[ $quantum = 1 ]]
		then
			if [[ -z $proc_actual ]]
			then
				if [[ $nulcontrol == 0 ]]
				then
					#clear
					tabla_ejecucion
					nulcontrol=1
				fi
			else
				#clear
				tabla_ejecucion
				nulcontrol=0
			fi
		fi
		tant=$tiempo_transcurrido
		let tiempo_transcurrido=tiempo_transcurrido+1

		actualizar_linea
		actualizar_bt_line

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
	actualizar_bt_info
}



if [[ -e archivo.temp ]]
then
	rm archivo.temp
fi
if [[ -e informeCOLOR.txt ]]
then
	rm informeCOLOR.txt
fi
if [[ -e informeBN.txt ]]
then
	rm informeBN.txt
fi

#Inicio del script (Con alumno nuevo 2022) para los 2 informes.
#clear
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


imprime_cabecera_larga
lee_datos

#Guardado incondicional en datosLast.txt.
meterAfichero datoslast

#Condicional que determinará el guardado de los datos manuales.
if [[ $opcion_guardado_datos -eq 1 || $opcion_guardado_datos_rangos -eq 1 || $opcion_guardado_datos_rangos_2 -eq 1 || $nombre_fichero_datos == "DatosLast" ]]
then
		meterAfichero DatosLast
fi
if [[ $opcion_guardado_datos -eq 2 || $opcion_guardado_datos_rangos -eq 2 || $opcion_guardado_datos_rangos_2 -eq 1 ]] && [[ $nombre_fichero_datos != "DatosLast" ]]
then
		meterAfichero "$nombre_fichero_datos"
fi
if [[ $opcion_guardado_rangos -eq 1 || $opcion_guardado_rangos_2 -eq 1 || $nombre_fichero_rangos == "DatosRangos" ]]
then
		meterAficheroRangos DatosRangos
fi
if [[ $opcion_guardado_rangos -eq 2 || $opcion_guardado_rangos_2 -eq 2 ]] && [[ $nombre_fichero_rangos != "DatosRangos" ]]
then
		meterAficheroRangos "$nombre_fichero_rangos"
fi

if [[ $opcion_guardado_rangos_rangos -eq 1 || $nombre_fichero_rangos == "DatosRangos" ]] 
then
	meterAficheroRangosAleatorios DatosRangosAleatorios
fi
if [[ $opcion_guardado_rangos_rangos -eq 2 ]] && [[ $nombre_fichero_rangos != "DatosRangos" ]]
then
	meterAficheroRangosAleatorios "$opcion_guardado_rangos_rangos"
fi


#clear
echo "		> ROUND ROBIN" >> informeCOLOR.txt
echo "		> ROUND ROBIN" >> informeBN.txt

#Calculo el tamaño del espacio representado en la barra por cada unidad de tiempo en función del tamaño del mayor tiempo de entrada.
mas_tarde=0
for ((pr=0; pr<$num_proc; pr++ ))
do
	if [[ ${T_ENTRADA[$pr]} -gt $mas_tarde ]]
	then
		mas_tarde=${T_ENTRADA[$pr]}
		let mas_tarde=mas_tarde+${TEJ[$pr]}
	fi
done
#Si va a haber procesos que lleven el tiempo a más de 3 cifras, se aumenta el tamaño de la unidad de tiempo.
if [[ ${#mas_tarde} -gt 3 ]]
then
	tam_unidad_bt=${#mas_tarde}
fi

datos_aux 								#Copia los datos
mayor_dato_procesos 					#Calcula el mayor dato
memoria_total 							#Calcula la memoria total.
calcular_tabla_particiones_ejecucion	#Calcula la tabla de datos de las particiones.
calcula_espacios 						#Calcula los espacios para la tabla de procesos.
iniciar_bt								#Inicia la barra de tiempo.
algoritmob 								#Algoritmo principal

#clear
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