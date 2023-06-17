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

echo "############################################################" >> ./Informes/informeCOLOR.txt
echo "#                     Creative Commons                     #" >> ./Informes/informeCOLOR.txt
echo "#                                                          #" >> ./Informes/informeCOLOR.txt
echo "#                   BY - Atribución (BY)                   #" >> ./Informes/informeCOLOR.txt
echo "#                 NC - No uso Comercial (NC)               #" >> ./Informes/informeCOLOR.txt
echo "#                SA - Compartir Igual (SA)                 #" >> ./Informes/informeCOLOR.txt
echo "############################################################" >> ./Informes/informeCOLOR.txt

echo "############################################################" >> ./Informes/informeBN.txt
echo "#                     Creative Commons                     #" >> ./Informes/informeBN.txt
echo "#                                                          #" >> ./Informes/informeBN.txt
echo "#                   BY - Atribución (BY)                   #" >> ./Informes/informeBN.txt
echo "#                 NC - No uso Comercial (NC)               #" >> ./Informes/informeBN.txt
echo "#                SA - Compartir Igual (SA)                 #" >> ./Informes/informeBN.txt
echo "############################################################" >> ./Informes/informeBN.txt


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
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo " Datos de las particiones"
	echo " Datos de las particiones" >> ./Informes/informeCOLOR.txt
	echo " Datos de las particiones" >> ./Informes/informeBN.txt
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo -e " Número de particiones: $n_par\n"
	echo -e " Número de particiones: $n_par\n" >> ./Informes/informeCOLOR.txt
	echo -e " Número de particiones: $n_par\n" >> ./Informes/informeBN.txt

	echo -e " Tamaño de particiones: ${tam_par[@]}\n"
	echo -e " Tamaño de particiones: ${tam_par[@]}\n" >> ./Informes/informeCOLOR.txt
	echo -e " Tamaño de particiones: ${tam_par[@]}\n" >> ./Informes/informeBN.txt	

	echo -e " Quantum:               $quantum\n"
	echo -e " Quantum:               $quantum\n" >> ./Informes/informeCOLOR.txt
	echo -e " Quantum:               $quantum\n" >> ./Informes/informeBN.txt		

	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo " Datos de los procesos"
	echo " Datos de los procesos" >> ./Informes/informeCOLOR.txt
	echo " Datos de los procesos" >> ./Informes/informeBN.txt
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo " Los procesos introducidos hasta ahora son: "
	echo " Los procesos introducidos hasta ahora son: " >> ./Informes/informeCOLOR.txt
	echo " Los procesos introducidos hasta ahora son: " >> ./Informes/informeBN.txt
	echo " Ref Tll Tej Mem"
	echo " Ref Tll Tej Mem" >> ./Informes/informeCOLOR.txt
	echo " Ref Tll Tej Mem" >> ./Informes/informeBN.txt
	echo " ---------------"
	echo " ---------------" >> ./Informes/informeCOLOR.txt
	echo " ---------------" >> ./Informes/informeBN.txt
}


### He creado una nueva función que imprime la información de los datos que se están introduciendo en la opción 4. Este código estaba duplicado múltiples veces.
imprime_info_datos_aleatorios()
{
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo " Datos de las particiones"
	echo " Datos de las particiones" >> ./Informes/informeCOLOR.txt
	echo " Datos de las particiones" >> ./Informes/informeBN.txt
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo -e " Número de particiones: $n_par_min - $n_par_max -> $n_par"
	echo -e " Número de particiones: $n_par_min - $n_par_max -> $n_par" >> ./Informes/informeCOLOR.txt
	echo -e " Número de particiones: $n_par_min - $n_par_max -> $n_par" >> ./Informes/informeBN.txt

	echo -e " Tamaño de particiones: $tam_par_min - $tam_par_max -> ${tam_par[@]}"
	echo -e " Tamaño de particiones: $tam_par_min - $tam_par_max -> ${tam_par[@]}" >> ./Informes/informeCOLOR.txt
	echo -e " Tamaño de particiones: $tam_par_min - $tam_par_max -> ${tam_par[@]}" >> ./Informes/informeBN.txt	

	echo -e " Quantum:               $quantum_min - $quantum_max -> $quantum"
	echo -e " Quantum:               $quantum_min - $quantum_max -> $quantum" >> ./Informes/informeCOLOR.txt
	echo -e " Quantum:               $quantum_min - $quantum_max -> $quantum" >> ./Informes/informeBN.txt		
	
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo " Datos de los procesos"
	echo " Datos de los procesos" >> ./Informes/informeCOLOR.txt
	echo " Datos de los procesos" >> ./Informes/informeBN.txt
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo " Número de procesos:	$num_proc_min - $num_proc_max -> $num_proc"
	echo " Número de procesos:	$num_proc_min - $num_proc_max -> $num_proc" >> ./Informes/informeCOLOR.txt
	echo " Número de procesos:	$num_proc_min - $num_proc_max -> $num_proc" >> ./Informes/informeBN.txt
	echo " Tiempo de llegada:	$entrada_min - $entrada_max"
	echo " Tiempo de llegada:	$entrada_min - $entrada_max" >> ./Informes/informeCOLOR.txt
	echo " Tiempo de llegada:	$entrada_min - $entrada_max" >> ./Informes/informeBN.txt
	echo " Tiempo de ejecución:	$rafaga_min - $rafaga_max"
	echo " Tiempo de ejecución:	$rafaga_min - $rafaga_max" >> ./Informes/informeCOLOR.txt
	echo " Tiempo de ejecución:	$rafaga_min - $rafaga_max" >> ./Informes/informeBN.txt
	echo " Memoria a ocupar: 	$memo_proc_min - $memo_proc_max"
	echo " Memoria a ocupar: 	$memo_proc_min - $memo_proc_max" >> ./Informes/informeCOLOR.txt
	echo " Memoria a ocupar: 	$memo_proc_min - $memo_proc_max" >> ./Informes/informeBN.txt
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo " Los procesos introducidos hasta ahora son: "
	echo " Los procesos introducidos hasta ahora son: " >> ./Informes/informeCOLOR.txt
	echo " Los procesos introducidos hasta ahora son: " >> ./Informes/informeBN.txt
	echo " Ref Tll Tej Mem"
	echo " Ref Tll Tej Mem" >> ./Informes/informeCOLOR.txt
	echo " Ref Tll Tej Mem" >> ./Informes/informeBN.txt
	echo " ---------------"
	echo " ---------------" >> ./Informes/informeCOLOR.txt
	echo " ---------------" >> ./Informes/informeBN.txt
}


### He creado una nueva función que imprime la información de los datos que se están introduciendo en la opción 4. Este código estaba duplicado múltiples veces.
imprime_info_datos_rangos_aleatorios()
{
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo " Datos de las particiones"
	echo " Datos de las particiones" >> ./Informes/informeCOLOR.txt
	echo " Datos de las particiones" >> ./Informes/informeBN.txt
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo -e " Número de particiones: $rango_n_par_min - $rango_n_par_max -> $n_par_min - $n_par_max -> $n_par"
	echo -e " Número de particiones: $rango_n_par_min - $rango_n_par_max -> $n_par_min - $n_par_max -> $n_par" >> ./Informes/informeCOLOR.txt
	echo -e " Número de particiones: $rango_n_par_min - $rango_n_par_max -> $n_par_min - $n_par_max -> $n_par" >> ./Informes/informeBN.txt

	echo -e " Tamaño de particiones: $rango_tam_par_min - $rango_tam_par_max -> $tam_par_min - $tam_par_max -> ${tam_par[@]}"
	echo -e " Tamaño de particiones: $rango_tam_par_min - $rango_tam_par_max -> $tam_par_min - $tam_par_max -> ${tam_par[@]}" >> ./Informes/informeCOLOR.txt
	echo -e " Tamaño de particiones: $rango_tam_par_min - $rango_tam_par_max -> $tam_par_min - $tam_par_max -> ${tam_par[@]}" >> ./Informes/informeBN.txt	

	echo -e " Quantum:               $rango_quantum_min - $rango_quantum_max -> $quantum_min - $quantum_max -> $quantum"
	echo -e " Quantum:               $rango_quantum_min - $rango_quantum_max -> $quantum_min - $quantum_max -> $quantum" >> ./Informes/informeCOLOR.txt
	echo -e " Quantum:               $rango_quantum_min - $rango_quantum_max -> $quantum_min - $quantum_max -> $quantum" >> ./Informes/informeBN.txt		
	
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo " Datos de los procesos"
	echo " Datos de los procesos" >> ./Informes/informeCOLOR.txt
	echo " Datos de los procesos" >> ./Informes/informeBN.txt
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo " Número de procesos:	$rango_num_proc_min - $rango_num_proc_max -> $num_proc_min - $num_proc_max -> $num_proc"
	echo " Número de procesos:	$rango_num_proc_min - $rango_num_proc_max -> $num_proc_min - $num_proc_max -> $num_proc" >> ./Informes/informeCOLOR.txt
	echo " Número de procesos:	$rango_num_proc_min - $rango_num_proc_max -> $num_proc_min - $num_proc_max -> $num_proc" >> ./Informes/informeBN.txt
	echo " Tiempo de llegada:	$rango_entrada_min - $rango_entrada_max -> $entrada_min - $entrada_max"
	echo " Tiempo de llegada:	$rango_entrada_min - $rango_entrada_max -> $entrada_min - $entrada_max" >> ./Informes/informeCOLOR.txt
	echo " Tiempo de llegada:	$rango_entrada_min - $rango_entrada_max -> $entrada_min - $entrada_max" >> ./Informes/informeBN.txt
	echo " Tiempo de ejecución:	$rango_rafaga_min - $rango_rafaga_max -> $rafaga_min - $rafaga_max"
	echo " Tiempo de ejecución:	$rango_rafaga_min - $rango_rafaga_max -> $rafaga_min - $rafaga_max" >> ./Informes/informeCOLOR.txt
	echo " Tiempo de ejecución:	$rango_rafaga_min - $rango_rafaga_max -> $rafaga_min - $rafaga_max" >> ./Informes/informeBN.txt
	echo " Memoria a ocupar: 	$rango_memo_proc_min - $rango_memo_proc_max -> $memo_proc_min - $memo_proc_max"
	echo " Memoria a ocupar: 	$rango_memo_proc_min - $rango_memo_proc_max -> $memo_proc_min - $memo_proc_max" >> ./Informes/informeCOLOR.txt
	echo " Memoria a ocupar: 	$rango_memo_proc_min - $rango_memo_proc_max -> $memo_proc_min - $memo_proc_max" >> ./Informes/informeBN.txt
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo " Los procesos introducidos hasta ahora son: "
	echo " Los procesos introducidos hasta ahora son: " >> ./Informes/informeCOLOR.txt
	echo " Los procesos introducidos hasta ahora son: " >> ./Informes/informeBN.txt
	echo " Ref Tll Tej Mem"
	echo " Ref Tll Tej Mem" >> ./Informes/informeCOLOR.txt
	echo " Ref Tll Tej Mem" >> ./Informes/informeBN.txt
	echo " ---------------"
	echo " ---------------" >> ./Informes/informeCOLOR.txt
	echo " ---------------" >> ./Informes/informeBN.txt
}


### Función de lectura de entrada para el menú principal (6 opciones principales, menú de guardado y recogida de datos principales en caso de introducción manual de datos).
lee_datos() {
	#Menú inicial
	echo ""
	echo " 1- Entrada Manual"
	echo " 1- Entrada Manual" >> ./Informes/informeCOLOR.txt
	echo " 1- Entrada Manual" >> ./Informes/informeBN.txt
	echo " 2- Fichero de datos de última ejecución (DatosLast.txt)"
	echo " 2- Fichero de datos de última ejecución (DatosLast.txt)" >> ./Informes/informeCOLOR.txt
	echo " 2- Fichero de datos de última ejecución (DatosLast.txt)" >> ./Informes/informeBN.txt
	echo " 3- Otros ficheros de datos"
	echo " 3- Otros ficheros de datos" >> ./Informes/informeCOLOR.txt
	echo " 3- Otros ficheros de datos" >> ./Informes/informeBN.txt
	echo " 4- Rangos manuales para valores aleatorios"
	echo " 4- Rangos manuales para valores aleatorios" >> ./Informes/informeCOLOR.txt
	echo " 4- Rangos manuales para valores aleatorios" >> ./Informes/informeBN.txt
	echo " 5- Fichero de rangos de última ejecución (DatosRangosLast.txt)"
	echo " 5- Fichero de rangos de última ejecución (DatosRangosLast.txt)" >> ./Informes/informeCOLOR.txt
	echo " 5- Fichero de rangos de última ejecución (DatosRangosLast.txt)" >> ./Informes/informeBN.txt
	echo " 6- Otros ficheros de rangos"
	echo " 6- Otros ficheros de rangos" >> ./Informes/informeCOLOR.txt
	echo " 6- Otros ficheros de rangos" >> ./Informes/informeBN.txt
	echo " 7- Rangos manuales para rangos aleatorios (prueba de casos extremos)"
	echo " 7- Rangos manuales para rangos aleatorios (prueba de casos extremos)" >> ./Informes/informeCOLOR.txt
	echo " 7- Rangos manuales para rangos aleatorios (prueba de casos extremos)" >> ./Informes/informeBN.txt
	echo " 8- Fichero de rangos aleatorios de última ejecución (DatosRangosAleatoriosLast.txt)"
	echo " 8- Fichero de rangos aleatorios de última ejecución (DatosRangosAleatoriosLast.txt)" >> ./Informes/informeCOLOR.txt
	echo " 8- Fichero de rangos aleatorios de última ejecución (DatosRangosAleatoriosLast.txt)" >> ./Informes/informeBN.txt
	echo " 9- Otros ficheros de rangos para rangos aleatorios"
	echo " 9- Otros ficheros de rangos para rangos aleatorios" >> ./Informes/informeCOLOR.txt
	echo " 9- Otros ficheros de rangos para rangos aleatorios" >> ./Informes/informeBN.txt
	echo ""
	read -p " Elija una opción: " dat_fich
	echo $dat_fich >> ./Informes/informeCOLOR.txt
	echo $dat_fich >> ./Informes/informeBN.txt

	#COMPROBACIÓN DE LECTURA
	#He añadido una explicación más detallada del error de introducción de opción.
	while [ "${dat_fich}" != "1" -a "${dat_fich}" != "2" -a "${dat_fich}" != "3" -a "${dat_fich}" != "4" -a "${dat_fich}" != "5" -a "${dat_fich}" != "6" -a "${dat_fich}" != "7" -a "${dat_fich}" != "8" -a "${dat_fich}" != "9" ] #Lectura errónea.
	do
		echo "Entrada no válida"
		read -p "Elija una opción como un número natural del 1 al 8: " dat_fich
		echo $dat_fich >> ./Informes/informeCOLOR.txt
		echo $dat_fich >> ./Informes/informeBN.txt
	done

	clear
	#Introducción de datos a mano
	#He agrupado en el mismo if la selección de guardado y la introducción/lectura de datos.
	if [ "${dat_fich}" == "1" ]
	then

		###  MÉTODO DE GUARDADO  ###

		#Opción de guardado de datos introducidos en ficheros destinados a datos.
		#Los métodos de guardado consisten en crear un fichero nuevo con los datos (Con nombre estandar o a elegir por el usuario), o guardarlo en la última ejecución.
		preguntaGuardadoDatos "introducidos"

		#Lectura de los datos de las particiones y el quantum.
		lectura_dat_particiones

		#Lectura de los datos concretos de los procesos.
		lectura_dat_procesos

		ordenacion_procesos
	fi


	#Entrada por fichero de última ejecución.
	if [ $dat_fich = '2' ] 
	then
		clear
		#Lectura del fichero DatosLast.txt
		lectura_fichero "last"
	fi


	#Entrada por otros ficheros.
	if [ $dat_fich = '3' ] 
	then
		clear
		#Lectura de fichero a seleccionar.
		leerFichero 1
	fi


	#Introduccion de datos aleatorios con rango a mano.
	#He agrupado otra vez en el mismo if la selección de guardado y la introducción/lectura de datos.
	if [ "${dat_fich}" == "4" ]
	then

		###  MÉTODO DE GUARDADO  ###

		#Opción de guardado de rangos introducidos en ficheros destinados a rangos.
		preguntaGuardadoRangos "introducidos"

		clear
		#Opción de guardado de datos calculados en ficheros destinados a datos.
		preguntaGuardadoDatos "calculados"

		#Lectura de datos de particiones y quántum
		lectura_dat_particiones_aleatorias

		#Lectura de datos concretos de los procesos.
		lectura_dat_procesos_aleatorios

		ordenacion_procesos
	fi


	#Lectura de fichero de última ejecución de datos aleatorios.
	if [ $dat_fich = '5' ]
	then 
		clear
		#Opción de guardado de datos calculados en ficheros destinados a datos.
		preguntaGuardadoDatos "calculados"

		#Lectura del fichero DatosRangosLast.txt
		lectura_fichero_rangos "last"
	fi


	#Lectura de otros ficheros con datos aleatorios
	if [ $dat_fich = '6' ] 
	then 
		clear
		#Opción de guardado de datos calculados en ficheros destinados a datos.
		preguntaGuardadoDatos "calculados"

		#Lectura de fichero a seleccionar.
		leerFichero 2
	fi


	#Introduccion de rangos aleatorios a mano.
	if [ $dat_fich = '7' ] 
	then
		###  MÉTODO DE GUARDADO  ###

		#Guardado de datos en ficheros destinados a rangos para rangos aleatorios.
		imprime_cabecera_larga
		echo  " ¿Dónde guardar los rangos aleatorios introducidos?"
		echo  " ¿Dónde guardar los rangos aleatorios introducidos?" >> ./Informes/informeCOLOR.txt
		echo  " ¿Dónde guardar los rangos aleatorios introducidos?" >> ./Informes/informeBN.txt
		echo  " 1- Fichero de rangos aleatorios por defecto (DatosRangosAleatoriosDefault.txt)"
		echo  " 1- Fichero de rangos aleatorios por defecto (DatosRangosAleatoriosDefault.txt)" >> ./Informes/informeCOLOR.txt
		echo  " 1- Fichero de rangos aleatorios por defecto (DatosRangosAleatoriosDefault.txt)" >> ./Informes/informeBN.txt
		echo  " 2- Otro fichero de rangos aleatorios"
		echo  " 2- Otro fichero de rangos aleatorios" >> ./Informes/informeCOLOR.txt
		echo  " 2- Otro fichero de rangos aleatorios" >> ./Informes/informeBN.txt

		read opcion_guardado_datos_rangos_aleatorios

		#He añadido una explicación más detallada del error de introducción de opción.
		while [ "${opcion_guardado_datos_rangos_aleatorios}" != "1" -a "${opcion_guardado_datos_rangos_aleatorios}" != "2" ] #Lectura errónea.
		do
			echo "Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los rangos aleatorios introducidos?"
			read opcion_guardado_datos_rangos_aleatorios
		done

		echo $opcion_guardado_datos_rangos_aleatorios >> ./Informes/informeCOLOR.txt
		echo $opcion_guardado_datos_rangos_aleatorios >> ./Informes/informeBN.txt
	
		#Si se guarda en otro fichero, pregunta el nombre.
		if [ "${opcion_guardado_datos_rangos_aleatorios}" == "2" ]
		then
			echo  " Nombre del nuevo fichero con rangos aleatorios: (No poner .txt)"
			echo  " Nombre del nuevo fichero con rangos aleatorios: (No poner .txt)" >> ./Informes/informeCOLOR.txt
			echo  " Nombre del nuevo fichero con rangos aleatorios: (No poner .txt)" >> ./Informes/informeBN.txt
			read nombre_fichero_datos_rangos_aleatorios
		fi

		#Opción de guardado de rangos calculados en ficheros destinados a rangos.
		preguntaGuardadoRangos "calculados"

		#Opción de guardado de datos calculados en ficheros destinados a datos.
		preguntaGuardadoDatos "calculados"

		#Lectura de datos de particiones y quántum.
		lectura_dat_particiones_rangos_aleatorios

		#Lectura de datos concretos de los procesos.
		lectura_dat_procesos_rangos_aleatorios

		ordenacion_procesos
	fi


	#Entrada por fichero de última ejecución de rangos aleatorios.
	if [ $dat_fich = '8' ] 
	then
		clear
		#Opción de guardado de rangos calculados en ficheros destinados a rangos.
		preguntaGuardadoRangos "calculados"

		#Opción de guardado de datos calculados en ficheros destinados a datos.
		preguntaGuardadoDatos "calculados"

		#Lectura de fichero DatosRangosAleatoriosLast.txt
		lectura_fichero_rangos_aleatorios "last"
	fi


	#Entrada por otro fichero de rangos aleatorios.
	if [ $dat_fich = '9' ]
	then
		clear
		#Opción de guardado de rangos calculados en ficheros destinados a rangos.
		preguntaGuardadoRangos "calculados"

		#Opción de guardado de datos calculados en ficheros destinados a datos.
		preguntaGuardadoDatos "calculados"

		#Lectura de fichero a seleccionar.
		leerFichero 3
	fi


	#Volcado de datos a los informes.
	datos_fichTfich
	echo "      >> $num_proc procesos." >> ./Informes/informeCOLOR.txt
	echo "      >> $num_proc procesos." >> ./Informes/informeBN.txt

	#Una vez leido quantum y los datos de los procesos, escritura de la cabecera del informe y el enunciado.
	escribe_cabecera_informe
	escribe_enunciado
}


### Interacción con el usuario para determinar el método de guardado de los datos.
### Parámetros:
	# $1 -> "introducidos" si son introducidos manualmente o "calculados" si son calculados.
preguntaGuardadoDatos()
{
	imprime_cabecera_larga
	echo  " ¿Dónde guardar los datos $1?"
	echo  " ¿Dónde guardar los datos $1?" >> ./Informes/informeCOLOR.txt
	echo  " ¿Dónde guardar los datos $1?" >> ./Informes/informeBN.txt
	echo  " 1- Fichero de datos por defecto (DatosDefault.txt)"
	echo  " 1- Fichero de datos por defecto (DatosDefault.txt)" >> ./Informes/informeCOLOR.txt
	echo  " 1- Fichero de datos por defecto (DatosDefault.txt)" >> ./Informes/informeBN.txt
	echo  " 2- Otro fichero de datos"
	echo  " 2- Otro fichero de datos" >> ./Informes/informeCOLOR.txt
	echo  " 2- Otro fichero de datos" >> ./Informes/informeBN.txt

	read opcion_guardado_datos

	#He añadido una explicación más detallada del error de introducción de opción.
	while [ "${opcion_guardado_datos}" != "1" -a "${opcion_guardado_datos}" != "2" ] #Lectura errónea.
	do
		echo "Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los datos $1?"
		read opcion_guardado_datos
	done

	echo $opcion_guardado_datos >> ./Informes/informeCOLOR.txt
	echo $opcion_guardado_datos >> ./Informes/informeBN.txt

	#Si se guarda en otro fichero, pregunta el nombre.
	if [ "${opcion_guardado_datos}" == "2" ]
	then
		echo  " Nombre del nuevo fichero con datos: (No poner .txt)"
		echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> ./Informes/informeCOLOR.txt
		echo  " Nombre del nuevo fichero con datos: (No poner .txt)" >> ./Informes/informeBN.txt
		read nombre_fichero_datos

		#He añadido el nombre del fichero de guardado nuevo a los informes.
		echo $nombre_fichero_datos >> ./Informes/informeCOLOR.txt 
		echo $nombre_fichero_datos >> ./Informes/informeBN.txt 
	fi
}


### Interacción con el usuario para determinar el método de guardado de los rangos.
### Parámetros:
	# $1 -> "introducidos" si son introducidos manualmente o "calculados" si son calculados.
preguntaGuardadoRangos()
{
	imprime_cabecera_larga
	echo  " ¿Dónde guardar los rangos $1?"
	echo  " ¿Dónde guardar los rangos $1?" >> ./Informes/informeCOLOR.txt
	echo  " ¿Dónde guardar los rangos $1?" >> ./Informes/informeBN.txt
	echo  " 1- Fichero de rangos por defecto (DatosRangosDefault.txt)"
	echo  " 1- Fichero de rangos por defecto (DatosRangosDefault.txt)" >> ./Informes/informeCOLOR.txt
	echo  " 1- Fichero de rangos por defecto (DatosRangosDefault.txt)" >> ./Informes/informeBN.txt
	echo  " 2- Otro fichero de rangos"
	echo  " 2- Otro fichero de rangos" >> ./Informes/informeCOLOR.txt
	echo  " 2- Otro fichero de rangos" >> ./Informes/informeBN.txt

	read opcion_guardado_datos_rangos

	#He añadido una explicación más detallada del error de introducción de opción.
	while [ "${opcion_guardado_datos_rangos}" != "1" -a "${opcion_guardado_datos_rangos}" != "2" ] #Lectura errónea.
	do
		echo "Entrada no válida, elija introduciendo 1 o 2; ¿Dónde guardar los rangos $1?"
		read opcion_guardado_datos_rangos
	done

	echo $opcion_guardado_datos_rangos >> ./Informes/informeCOLOR.txt
	echo $opcion_guardado_datos_rangos >> ./Informes/informeBN.txt

	#Si se guarda en otro fichero, pregunta el nombre.
	if [ "${opcion_guardado_datos_rangos}" == "2" ]
	then
		echo  " Nombre del nuevo fichero con rangos: (No poner .txt)"
		echo  " Nombre del nuevo fichero con rangos: (No poner .txt)" >> ./Informes/informeCOLOR.txt
		echo  " Nombre del nuevo fichero con rangos: (No poner .txt)" >> ./Informes/informeBN.txt
		read nombre_fichero_datos_rangos

		#He añadido el nombre del fichero de guardado nuevo a los informes.
		echo $nombre_fichero_datos_rangos >> ./Informes/informeCOLOR.txt
		echo $nombre_fichero_datos_rangos >> ./Informes/informeBN.txt
	fi
}


### Mete los datos sobre las particiones y el quantum obtenidos del fichero en el informe.
#He modificado el dato de tamaño de particiones para ajustarse a particiones no iguales.
datos_fichTfich()
{
	echo ""
	echo "      >> Numero de particiones: $n_par" >> ./Informes/informeCOLOR.txt
	echo "      >> Numero de particiones: $n_par" >> ./Informes/informeBN.txt
	echo "      >> Tamaño de particiones: ${tam_par[@]}" >> ./Informes/informeCOLOR.txt
	echo "      >> Tamaño de particiones: ${tam_par[@]}" >> ./Informes/informeBN.txt
	echo "      >> Quantum de tiempo: $quantum" >> ./Informes/informeCOLOR.txt
	echo "      >> Quantum de tiempo: $quantum" >> ./Informes/informeBN.txt
}


### Escribe la cabecera del informe para la tabla de procesos.
escribe_cabecera_informe()
{
	echo "      >> Procesos y sus datos:" >> ./Informes/informeCOLOR.txt
	echo "      >> Procesos y sus datos:" >> ./Informes/informeBN.txt
	echo "         Ref Tll Tej Mem " >> ./Informes/informeCOLOR.txt
	echo "         Ref Tll Tej Mem " >> ./Informes/informeBN.txt
	echo "         ----------------" >> ./Informes/informeCOLOR.txt
	echo "         ----------------" >> ./Informes/informeBN.txt
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

		echo -ne "         \e[${color[$c]}mP" >> ./Informes/informeCOLOR.txt
		printf "%02d " "${NUMPROC[$pr]}" >> ./Informes/informeCOLOR.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> ./Informes/informeCOLOR.txt
		printf "%3s " "${TEJ[$pr]}" >> ./Informes/informeCOLOR.txt
		printf "%3s " "${MEMORIA[$pr]}" >> ./Informes/informeCOLOR.txt
		echo -e "$resetColor" >> ./Informes/informeCOLOR.txt

		echo -ne "         P" >> ./Informes/informeBN.txt
		printf "%02d " "${NUMPROC[$pr]}" >> ./Informes/informeBN.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> ./Informes/informeBN.txt
		printf "%3s " "${TEJ[$pr]}" >> ./Informes/informeBN.txt
		printf "%3s " "${MEMORIA[$pr]}" >> ./Informes/informeBN.txt
		echo " " >> ./Informes/informeBN.txt
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
	imprime_cabecera_larga
	imprime_info_datos
	echo -n " Introduzca numero de particiones: "
	echo -n " Introduzca numero de particiones: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduzca numero de particiones: " >> ./Informes/informeBN.txt
	read n_par
	echo $n_par >> ./Informes/informeCOLOR.txt
	echo $n_par >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $n_par
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduzca numero de particiones: "
		echo -n " Introduzca numero de particiones: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduzca numero de particiones: " >> ./Informes/informeBN.txt
		read n_par
		echo $n_par >> ./Informes/informeCOLOR.txt
		echo $n_par >> ./Informes/informeBN.txt
	done

	#Lectura del tamaño de las particiones.
	#He modificado esta entrada de datos para particiones no iguales, pidiendo el tamaño de cada una de las particiones.
	for ((p=0; p < $n_par; p++))
	{
		clear
		imprime_cabecera_larga
		imprime_info_datos
		echo -ne " Introduce tamaño de la partición $(($p+1)): "
		echo -ne " Introduce tamaño de la partición $(($p+1)): " >> ./Informes/informeCOLOR.txt
		echo -ne " Introduce tamaño de la partición $(($p+1)): " >> ./Informes/informeBN.txt
		read tam_par_p

		#He añadido una explicación más detallada del error de introducción de opción.
		while ! mayor_cero $tam_par_p
		do
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
			echo -ne " Introduce tamaño de la partición $(($p+1)): "
			echo -ne " Introduce tamaño de la partición $(($p+1)): " >> ./Informes/informeCOLOR.txt
			echo -ne " Introduce tamaño de la partición $(($p+1)): " >> ./Informes/informeBN.txt
			read tam_par_p
			echo $tam_par_p >> ./Informes/informeCOLOR.txt
			echo $tam_par_p >> ./Informes/informeBN.txt
		done

		tam_par[$p]=$tam_par_p
	}
	
	###  QUANTUM  ###

	#Lectura del quantum.
	clear
	imprime_cabecera_larga
	imprime_info_datos
	echo -n " Introduce el quantum de ejecución: "
	echo -n " Introduce el quantum de ejecución: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el quantum de ejecución: " >> ./Informes/informeBN.txt
	read quantum
	echo $quantum >> ./Informes/informeCOLOR.txt
	echo $quantum >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $quantum
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduce el quantum de ejecución: "
		echo -n " Introduce el quantum de ejecución: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el quantum de ejecución: " >> ./Informes/informeBN.txt
		read quantum
		echo $quantum >> ./Informes/informeCOLOR.txt
		echo $quantum >> ./Informes/informeBN.txt
	done

	clear
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
		echo -n " Introduce el tiempo de llegada a CPU del proceso $num_proc: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el tiempo de llegada a CPU del proceso $num_proc: " >> ./Informes/informeBN.txt
		read entrada
		echo $entrada >> ./Informes/informeCOLOR.txt
		echo $entrada >> ./Informes/informeBN.txt

		#He añadido una explicación más detallada del error de introducción de opción.
		while ! mayor_cero $entrada
		do
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
			echo -n " Introduce el tiempo de llegada a CPU del proceso $num_proc: "
			echo -n " Introduce el tiempo de llegada a CPU del proceso $num_proc: " >> ./Informes/informeCOLOR.txt
			echo -n " Introduce el tiempo de llegada a CPU del proceso $num_proc: " >> ./Informes/informeBN.txt
			read entrada
			echo $entrada >> ./Informes/informeCOLOR.txt
			echo $entrada >> ./Informes/informeBN.txt
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
		echo -n " Introduce el tiempo en CPU del proceso $num_proc: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el tiempo en CPU del proceso $num_proc: " >> ./Informes/informeBN.txt
		read rafaga
		echo $rafaga >> ./Informes/informeCOLOR.txt
		echo $rafaga >> ./Informes/informeBN.txt

		#He añadido una explicación más detallada del error de introducción de opción.
		while ! mayor_cero $rafaga
		do
 			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
			echo -n " Introduce el tiempo en CPU del proceso $num_proc: "
			echo -n " Introduce el tiempo en CPU del proceso $num_proc: " >> ./Informes/informeCOLOR.txt
			echo -n " Introduce el tiempo en CPU del proceso $num_proc: " >> ./Informes/informeBN.txt
			read rafaga
			echo $rafaga >> ./Informes/informeCOLOR.txt
			echo $rafaga >> ./Informes/informeBN.txt
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
		echo -n " Introduce la memoria del proceso $num_proc: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce la memoria del proceso $num_proc: " >> ./Informes/informeBN.txt
		read memo_proc
		echo $memo_proc >> ./Informes/informeCOLOR.txt
		echo $memo_proc >> ./Informes/informeBN.txt

		#He añadido una explicación más detallada del error de introducción de opción.
		while ! mayor_cero $memo_proc
		do
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
			echo -n " Introduce la memoria del proceso $num_proc: "
			echo -n " Introduce la memoria del proceso $num_proc: " >> ./Informes/informeCOLOR.txt
			echo -n " Introduce la memoria del proceso $num_proc: " >> ./Informes/informeBN.txt
			read memo_proc
			echo $memo_proc >> ./Informes/informeCOLOR.txt
			echo $memo_proc >> ./Informes/informeBN.txt
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
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> ./Informes/informeBN.txt
			echo -n " Introduce la memoria del proceso $num_proc: "
			echo -n " Introduce la memoria del proceso $num_proc: " >> ./Informes/informeCOLOR.txt
			echo -n " Introduce la memoria del proceso $num_proc: " >> ./Informes/informeBN.txt
			read memo_proc
			echo $memo_proc >> ./Informes/informeCOLOR.txt
			echo $memo_proc >> ./Informes/informeBN.txt
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
	imprime_cabecera_larga
	imprime_info_datos_aleatorios
	echo -n " Introduzca numero de particiones mínimo: "
	echo -n " Introduzca numero de particiones mínimo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduzca numero de particiones mínimo: " >> ./Informes/informeBN.txt
	read n_par_min
	echo $n_par_min >> ./Informes/informeCOLOR.txt
	echo $n_par_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $n_par_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduzca numero de particiones mínimo: "
		echo -n " Introduzca numero de particiones mínimo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduzca numero de particiones mínimo: " >> ./Informes/informeBN.txt
		read n_par_min
		echo $n_par_min >> ./Informes/informeCOLOR.txt
		echo $n_par_min >> ./Informes/informeBN.txt
	done

	###  NÚMERO DE PARTICIONES MÁXIMO  ###

	clear
	imprime_cabecera_larga
	imprime_info_datos_aleatorios
	echo -n " Introduzca numero de particiones máximo: "
	echo -n " Introduzca numero de particiones máximo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduzca numero de particiones máximo: " >> ./Informes/informeBN.txt
	read n_par_max
	echo $n_par_max >> ./Informes/informeCOLOR.txt
	echo $n_par_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE NÚMERO DE PARTICIONES  ###
	
	#He fusionado la comprobación de mayor que cero y mayor que número de particiones mínimo porque me parece más elegante.
	while ! mayor_cero $n_par_max || [ $n_par_max -lt $n_par_min ]
	do
		if ! mayor_cero $n_par_max	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduzca numero de particiones máximo: "
		echo -n " Introduzca numero de particiones máximo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduzca numero de particiones máximo: " >> ./Informes/informeBN.txt
		read n_par_max
		echo $n_par_max >> ./Informes/informeCOLOR.txt
		echo $n_par_max >> ./Informes/informeBN.txt
	done

	#Asignación aleatoria del número de particiones en el rango.
	n_par=`shuf -i $n_par_min-$n_par_max -n 1`

	###  TAMAÑO DE PARTICIONES MÍNIMO  ###

	clear
	imprime_cabecera_larga
	imprime_info_datos_aleatorios
	echo -n " Introduce tamaño de particiones mínimo: "
	echo -n " Introduce tamaño de particiones mínimo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce tamaño de particiones mínimo: " >> ./Informes/informeBN.txt
	read tam_par_min
	echo $tam_par_min >> ./Informes/informeCOLOR.txt
	echo $tam_par_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $tam_par_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduzca tamaño de particiones mínimo: "
		echo -n " Introduzca tamaño de particiones mínimo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduzca tamaño de particiones mínimo: " >> ./Informes/informeBN.txt
		read tam_par_min
		echo $tam_par_min >> ./Informes/informeCOLOR.txt
		echo $tam_par_min >> ./Informes/informeBN.txt
	done

	###  TAMAÑO DE PARTICIONES MÁXIMO  ###

	clear
	imprime_cabecera_larga
	imprime_info_datos_aleatorios
	echo -n " Introduce tamaño de particiones máximo: "
	echo -n " Introduce tamaño de particiones máximo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce tamaño de particiones máximo: " >> ./Informes/informeBN.txt
	read tam_par_max
	echo $tam_par_max >> ./Informes/informeCOLOR.txt
	echo $tam_par_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE TAMAÑO DE PARTICIONES  ###
	
	#He fusionado la comprobación de mayor que cero y mayor que tamaño de particiones mínimo porque me parece más elegante.
	while ! mayor_cero $tam_par_max || [ $tam_par_max -lt $tam_par_min ]
	do
		if ! mayor_cero $tam_par_max	#He añadido una explicación más detallada del error de introducción de opción.	
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduzca tamaño de particiones máximo: "
		echo -n " Introduzca tamaño de particiones máximo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduzca tamaño de particiones máximo: " >> ./Informes/informeBN.txt
		read tam_par_max
		echo $tam_par_max >> ./Informes/informeCOLOR.txt
		echo $tam_par_max >> ./Informes/informeBN.txt
	done	

	#Asignación aleatoria del tamaño de particiones en el rango.
	for ((p=0; p < $n_par; p++))
	{
		tam_par[$p]=`shuf -i $tam_par_min-$tam_par_max -n 1`
	}

	###  QUÁNTUM MÍNIMO  ###

	clear
	imprime_cabecera_larga
	imprime_info_datos_aleatorios		
	echo -n " Introduce el quantum de ejecución mínimo: "
	echo -n " Introduce el quantum de ejecución mínimo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el quantum de ejecución mínimo: " >> ./Informes/informeBN.txt
	read quantum_min
	echo $quantum_min >> ./Informes/informeCOLOR.txt
	echo $quantum_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $quantum_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduce el quantum de ejecución mínimo: "
		echo -n " Introduce el quantum de ejecución mínimo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el quantum de ejecución mínimo: " >> ./Informes/informeBN.txt
		read quantum_min
		echo $quantum_min >> ./Informes/informeCOLOR.txt
		echo $quantum_min >> ./Informes/informeBN.txt
	done

	###  QUÁNTUM MÁXIMO  ###

	clear
	imprime_cabecera_larga
	imprime_info_datos_aleatorios
	echo -n " Introduce el quantum de ejecución máximo: "
	echo -n " Introduce el quantum de ejecución máximo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el quantum de ejecución máximo: " >> ./Informes/informeBN.txt
	read quantum_max
	echo $quantum_max >> ./Informes/informeCOLOR.txt
	echo $quantum_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE QUÁNTUM  ###

	#He fusionado la comprobación de mayor que cero y mayor que quántum mínimo porque me parece más elegante.
	while ! mayor_cero $quantum_max || [ $quantum_max -lt $quantum_min ]
	do
		if ! mayor_cero $quantum_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce el quantum de ejecución máximo: "
		echo -n " Introduce el quantum de ejecución máximo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el quantum de ejecución máximo: " >> ./Informes/informeBN.txt
		read quantum_max
		echo $quantum_max >> ./Informes/informeCOLOR.txt
		echo $quantum_max >> ./Informes/informeBN.txt
	done

	#Asignación aleatoria del quántum en el rango.
	quantum=`shuf -i $quantum_min-$quantum_max -n 1`

	clear
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
	echo -n " Introduce el número de procesos mínimo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el número de procesos mínimo: " >> ./Informes/informeBN.txt
	read num_proc_min
	echo $num_proc_min >> ./Informes/informeCOLOR.txt
	echo $num_proc_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $num_proc_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduce el número de procesos mínimo: "
		echo -n " Introduce el número de procesos mínimo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el número de procesos mínimo: " >> ./Informes/informeBN.txt
		read num_proc_min
		echo $num_proc_min >> ./Informes/informeCOLOR.txt
		echo $num_proc_min >> ./Informes/informeBN.txt
	done

	###  NÚMERO DE PROCESOS MÁXIMO  ###

	imprimir_tabla_procesos_aleatorios
	echo -n " Introduce el número de procesos máximo: "
	echo -n " Introduce el número de procesos máximo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el número de procesos máximo: " >> ./Informes/informeBN.txt
	read num_proc_max
	echo $num_proc_max >> ./Informes/informeCOLOR.txt
	echo $num_proc_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE NÚMERO DE PROCESOS  ###

	#He fusionado la comprobación de mayor que cero y mayor que número de procesos mínimo porque me parece más elegante.
	while ! mayor_cero $num_proc_max || [ $num_proc_max -lt $num_proc_min ]
	do
		if ! mayor_cero $num_proc_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce el número de procesos máximo: "
		echo -n " Introduce el número de procesos máximo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el número de procesos máximo: " >> ./Informes/informeBN.txt
		read num_proc_max
		echo $num_proc_max >> ./Informes/informeCOLOR.txt
		echo $num_proc_max >> ./Informes/informeBN.txt
	done
	
	#Asignación aleatoria del número de procesos en el rango.
	num_proc=`shuf -i $num_proc_min-$num_proc_max -n 1`

	###   TIEMPO DE LLEGADA MÍNIMO  ###

	imprimir_tabla_procesos_aleatorios
	echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: "
	echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: " >> ./Informes/informeBN.txt
	read entrada_min
	echo $entrada_min >> ./Informes/informeCOLOR.txt
	echo $entrada_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $entrada_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: "
		echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el tiempo de llegada mínimo a CPU de los procesos: " >> ./Informes/informeBN.txt
		read entrada_min
		echo $entrada_min >> ./Informes/informeCOLOR.txt
		echo $entrada_min >> ./Informes/informeBN.txt
	done

	###   TIEMPO DE LLEGADA MÁXIMO  ###

	imprimir_tabla_procesos_aleatorios
	echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: "
	echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: " >> ./Informes/informeBN.txt
	read entrada_max
	echo $entrada_max >> ./Informes/informeCOLOR.txt
	echo $entrada_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE TIEMPOS DE LLEGADA  ###

	#He fusionado la comprobación de mayor que cero y mayor que llegada mínima porque me parece más elegante.
	while ! mayor_cero $entrada_max || [ $entrada_max -lt $entrada_min ]
	do
		if ! mayor_cero $entrada_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: "
		echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el tiempo de llegada máximo a CPU de los procesos: " >> ./Informes/informeBN.txt
		read entrada_max
		echo $entrada_max >> ./Informes/informeCOLOR.txt
		echo $entrada_max >> ./Informes/informeBN.txt
	done

	###  RÁFAGA MÍNIMA  ###

	imprimir_tabla_procesos_aleatorios
	echo -n " Introduce la ráfaga mínima de CPU de los procesos: "
	echo -n " Introduce la ráfaga mínima de CPU de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce la ráfaga mínima de CPU de los procesos: " >> ./Informes/informeBN.txt
	read rafaga_min
	echo $rafaga_min >> ./Informes/informeCOLOR.txt
	echo $rafaga_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rafaga_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduce la ráfaga mínima de CPU de los procesos: "
		echo -n " Introduce la ráfaga mínima de CPU de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce la ráfaga mínima de CPU de los procesos: " >> ./Informes/informeBN.txt
		read rafaga_min
		echo $rafaga_min >> ./Informes/informeCOLOR.txt
		echo $rafaga_min >> ./Informes/informeBN.txt
	done

	###  RÁFAGA MÁXIMA  ###

	imprimir_tabla_procesos_aleatorios
	echo -n " Introduce la ráfaga máxima de CPU de los procesos: "
	echo -n " Introduce la ráfaga máxima de CPU de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce la ráfaga máxima de CPU de los procesos: " >> ./Informes/informeBN.txt
	read rafaga_max
	echo $rafaga_max >> ./Informes/informeCOLOR.txt
	echo $rafaga_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE RÁFAGA  ###

	#He fusionado la comprobación de mayor que cero y mayor que ráfaga mínima porque me parece más elegante.
	while ! mayor_cero $rafaga_max || [ $rafaga_max -lt $rafaga_min ]
	do
		if ! mayor_cero $rafaga_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then 
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else  	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce la ráfaga máxima de CPU de los procesos: "
		echo -n " Introduce la ráfaga máxima de CPU de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce la ráfaga máxima de CPU de los procesos: " >> ./Informes/informeBN.txt
		read rafaga_max
		echo $rafaga_max >> ./Informes/informeCOLOR.txt
		echo $rafaga_max >> ./Informes/informeBN.txt
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
	echo -n " Introduce la memoria mínima de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce la memoria mínima de los procesos: " >> ./Informes/informeBN.txt
	read memo_proc_min
	echo $memo_proc_min >> ./Informes/informeCOLOR.txt
	echo $memo_proc_min >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE MEMORIA MÍNIMA MAYOR QUE CERO Y MENOR QUE TAMAÑO DE PARTICIONES  ###

	#He fusionado las comprobaciones de mayor que cero y menor que partición máxima para evitar la situación que se daba al poder introducir
	#un valor correcto mayor que cero primero, pero luego un valor incorrecto mayor que la partición máxima y en el reintento un valor"correcto" 
	#menor que la partición máxima pero menor que 0 o directamente no un número.
	while ! mayor_cero $memo_proc_min || [ $memo_proc_min -gt $tam_par_max_efec ]
	do
		if ! mayor_cero $memo_proc_min 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else #Si la memoria mínima de los procesos es mayor que la mayor partición.
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce la memoria mínima de los procesos: "
		echo -n " Introduce la memoria mínima de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce la memoria mínima de los procesos: " >> ./Informes/informeBN.txt
		read memo_proc_min
		echo $memo_proc_min >> ./Informes/informeCOLOR.txt
		echo $memo_proc_min >> ./Informes/informeBN.txt
	done

	###  MEMORIA MÁXIMA  ###

	imprimir_tabla_procesos_aleatorios
	echo -n " Introduce la memoria máxima de los procesos: "
	echo -n " Introduce la memoria máxima de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce la memoria máxima de los procesos: " >> ./Informes/informeBN.txt
	read memo_proc_max
	echo $memo_proc_max >> ./Informes/informeCOLOR.txt
	echo $memo_proc_max >> ./Informes/informeBN.txt

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
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		elif [ $memo_proc_max -gt $tam_par_max_efec ] 	#Si la memoria máxima de los procesos es mayor que la mayor partición.
		then
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> ./Informes/informeBN.txt
		else 
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce la memoria máxima de los procesos: "
		echo -n " Introduce la memoria máxima de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce la memoria máxima de los procesos: " >> ./Informes/informeBN.txt
		read memo_proc_max
		echo $memo_proc_max >> ./Informes/informeCOLOR.txt
		echo $memo_proc_max >> ./Informes/informeBN.txt
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

	clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo -n " Introduzca rango de número de particiones mínimo: "
	echo -n " Introduzca rango de número de particiones mínimo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduzca rango de número de particiones mínimo: " >> ./Informes/informeBN.txt
	read rango_n_par_min
	echo $rango_n_par_min >> ./Informes/informeCOLOR.txt
	echo $rango_n_par_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_n_par_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduzca rango de número de particiones mínimo: "
		echo -n " Introduzca rango de número de particiones mínimo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduzca rango de número de particiones mínimo: " >> ./Informes/informeBN.txt
		read rango_n_par_min
		echo $rango_n_par_min >> ./Informes/informeCOLOR.txt
		echo $rango_n_par_min >> ./Informes/informeBN.txt
	done

	###  RANGO DE NÚMERO DE PARTICIONES MÁXIMO  ###

	clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo -n " Introduzca rango de número de particiones máximo: "
	echo -n " Introduzca rango de número de particiones máximo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduzca rango de número de particiones máximo: " >> ./Informes/informeBN.txt
	read rango_n_par_max
	echo $rango_n_par_max >> ./Informes/informeCOLOR.txt
	echo $rango_n_par_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE NÚMERO DE PARTICIONES  ###
	
	#He fusionado la comprobación de mayor que cero y mayor que número de particiones mínimo porque me parece más elegante.
	while ! mayor_cero $rango_n_par_max || [ $rango_n_par_max -lt $rango_n_par_min ]
	do
		if ! mayor_cero $rango_n_par_max	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
			
		else	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduzca rango de número de particiones máximo: "
		echo -n " Introduzca rango de número de particiones máximo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduzca rango de número de particiones máximo: " >> ./Informes/informeBN.txt
		read rango_n_par_max
		echo $rango_n_par_max >> ./Informes/informeCOLOR.txt
		echo $rango_n_par_max >> ./Informes/informeBN.txt
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

	clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo -n " Introduce rango de tamaño de particiones mínimo: "
	echo -n " Introduce rango de tamaño de particiones mínimo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce rango de tamaño de particiones mínimo: " >> ./Informes/informeBN.txt
	read rango_tam_par_min
	echo $rango_tam_par_min >> ./Informes/informeCOLOR.txt
	echo $rango_tam_par_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_tam_par_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduzca rango de tamaño de particiones mínimo: "
		echo -n " Introduzca rango de tamaño de particiones mínimo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduzca rango de tamaño de particiones mínimo: " >> ./Informes/informeBN.txt
		read rango_tam_par_min
		echo $rango_tam_par_min >> ./Informes/informeCOLOR.txt
		echo $rango_tam_par_min >> ./Informes/informeBN.txt
	done

	###  RANGO DE TAMAÑO DE PARTICIONES MÁXIMO  ###

	clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo -n " Introduce rango de tamaño de particiones máximo: "
	echo -n " Introduce rango de tamaño de particiones máximo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce rango de tamaño de particiones máximo: " >> ./Informes/informeBN.txt
	read rango_tam_par_max
	echo $rango_tam_par_max >> ./Informes/informeCOLOR.txt
	echo $rango_tam_par_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE TAMAÑO DE PARTICIONES  ###
	
	#He fusionado la comprobación de mayor que cero y mayor que tamaño de particiones mínimo porque me parece más elegante.
	while ! mayor_cero $rango_tam_par_max || [ $rango_tam_par_max -lt $rango_tam_par_min ]
	do
		if ! mayor_cero $rango_tam_par_max	#He añadido una explicación más detallada del error de introducción de opción.	
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduzca rango de tamaño de particiones máximo: "
		echo -n " Introduzca rango de tamaño de particiones máximo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduzca rango de tamaño de particiones máximo: " >> ./Informes/informeBN.txt
		read rango_tam_par_max
		echo $rango_tam_par_max >> ./Informes/informeCOLOR.txt
		echo $rango_tam_par_max >> ./Informes/informeBN.txt
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

	clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios		
	echo -n " Introduce el rango de quantum de ejecución mínimo: "
	echo -n " Introduce el rango de quantum de ejecución mínimo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el rango de quantum de ejecución mínimo: " >> ./Informes/informeBN.txt
	read rango_quantum_min
	echo $rango_quantum_min >> ./Informes/informeCOLOR.txt
	echo $rango_quantum_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_quantum_min
	do
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduce el rango de quantum de ejecución mínimo: "
		echo -n " Introduce el rango de quantum de ejecución mínimo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el rango de quantum de ejecución mínimo: " >> ./Informes/informeBN.txt
		read rango_quantum_min
		echo $rango_quantum_min >> ./Informes/informeCOLOR.txt
		echo $rango_quantum_min >> ./Informes/informeBN.txt
	done

	###  RANGO DE QUÁNTUM MÁXIMO  ###

	clear
	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo -n " Introduce el rango de quantum de ejecución máximo: "
	echo -n " Introduce el rango de quantum de ejecución máximo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el rango de quantum de ejecución máximo: " >> ./Informes/informeBN.txt
	read rango_quantum_max
	echo $rango_quantum_max >> ./Informes/informeCOLOR.txt
	echo $rango_quantum_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE QUÁNTUM  ###

	#He fusionado la comprobación de mayor que cero y mayor que quántum mínimo porque me parece más elegante.
	while ! mayor_cero $rango_quantum_max || [ $rango_quantum_max -lt $rango_quantum_min ]
	do
		if ! mayor_cero $rango_quantum_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce el rango de quantum de ejecución máximo: "
		echo -n " Introduce el rango de quantum de ejecución máximo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el rango de quantum de ejecución máximo: " >> ./Informes/informeBN.txt
		read rango_quantum_max
		echo $rango_quantum_max >> ./Informes/informeCOLOR.txt
		echo $rango_quantum_max >> ./Informes/informeBN.txt
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

	clear
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
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo -n " Introduce el rango de procesos mínimo: "
	echo -n " Introduce el rango de procesos mínimo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el rango de procesos mínimo: " >> ./Informes/informeBN.txt
	read rango_num_proc_min
	echo $rango_num_proc_min >> ./Informes/informeCOLOR.txt
	echo $rango_num_proc_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_num_proc_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduce el rango de procesos mínimo: "
		echo -n " Introduce el rango de procesos mínimo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el rango de procesos mínimo: " >> ./Informes/informeBN.txt
		read rango_num_proc_min
		echo $rango_num_proc_min >> ./Informes/informeCOLOR.txt
		echo $rango_num_proc_min >> ./Informes/informeBN.txt
	done

	###  RANGO DE PROCESOS MÁXIMO  ###

	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo -n " Introduce el rango de procesos máximo: "
	echo -n " Introduce el rango de procesos máximo: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el rango de procesos máximo: " >> ./Informes/informeBN.txt
	read rango_num_proc_max
	echo $rango_num_proc_max >> ./Informes/informeCOLOR.txt
	echo $rango_num_proc_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE NÚMERO DE PROCESOS  ###

	#He fusionado la comprobación de mayor que cero y mayor que número de procesos mínimo porque me parece más elegante.
	while ! mayor_cero $rango_num_proc_max || [ $rango_num_proc_max -lt $rango_num_proc_min ]
	do
		if ! mayor_cero $rango_num_proc_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce el rango de procesos máximo: "
		echo -n " Introduce el rango de procesos máximo: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el rango de procesos máximo: " >> ./Informes/informeBN.txt
		read rango_num_proc_max
		echo $rango_num_proc_max >> ./Informes/informeCOLOR.txt
		echo $rango_num_proc_max >> ./Informes/informeBN.txt
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
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: "
	echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: " >> ./Informes/informeBN.txt
	read rango_entrada_min
	echo $rango_entrada_min >> ./Informes/informeCOLOR.txt
	echo $rango_entrada_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_entrada_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: "
		echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el rango de tiempo de llegada mínimo a CPU de los procesos: " >> ./Informes/informeBN.txt
		read rango_entrada_min
		echo $rango_entrada_min >> ./Informes/informeCOLOR.txt
		echo $rango_entrada_min >> ./Informes/informeBN.txt
	done

	###   RANGO DE TIEMPO DE LLEGADA MÁXIMO  ###

	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: "
	echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: " >> ./Informes/informeBN.txt
	read rango_entrada_max
	echo $rango_entrada_max >> ./Informes/informeCOLOR.txt
	echo $rango_entrada_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE TIEMPOS DE LLEGADA  ###

	#He fusionado la comprobación de mayor que cero y mayor que llegada mínima porque me parece más elegante.
	while ! mayor_cero $rango_entrada_max || [ $rango_entrada_max -lt $rango_entrada_min ]
	do
		if ! mayor_cero $rango_entrada_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else 	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: "
		echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el rango de tiempo de llegada máximo a CPU de los procesos: " >> ./Informes/informeBN.txt
		read rango_entrada_max
		echo $rango_entrada_max >> ./Informes/informeCOLOR.txt
		echo $rango_entrada_max >> ./Informes/informeBN.txt
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
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: "
	echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: " >> ./Informes/informeBN.txt
	read rango_rafaga_min
	echo $rango_rafaga_min >> ./Informes/informeCOLOR.txt
	echo $rango_rafaga_min >> ./Informes/informeBN.txt

	#He añadido una explicación más detallada del error de introducción de opción.
	while ! mayor_cero $rango_rafaga_min
	do
		echo " Entrada no válida, por favor introduce un número natural mayor que cero"
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: "
		echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el rango de ráfaga mínima de CPU de los procesos: " >> ./Informes/informeBN.txt
		read rango_rafaga_min
		echo $rango_rafaga_min >> ./Informes/informeCOLOR.txt
		echo $rango_rafaga_min >> ./Informes/informeBN.txt
	done

	###  RANGO DE RÁFAGA MÁXIMA  ###

	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: "
	echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: " >> ./Informes/informeBN.txt
	read rango_rafaga_max
	echo $rango_rafaga_max >> ./Informes/informeCOLOR.txt
	echo $rango_rafaga_max >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE NÚMERO MAYOR QUE CERO Y DE RANGOS DE RÁFAGA  ###

	#He fusionado la comprobación de mayor que cero y mayor que ráfaga mínima porque me parece más elegante.
	while ! mayor_cero $rango_rafaga_max || [ $rango_rafaga_max -lt $rango_rafaga_min ]
	do
		if ! mayor_cero $rango_rafaga_max 	#He añadido una explicación más detallada del error de introducción de opción.
		then 
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else  	#Límite máximo inferior al mínimo.
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: "
		echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el rango de ráfaga máxima de CPU de los procesos: " >> ./Informes/informeBN.txt
		read rango_rafaga_max
		echo $rango_rafaga_max >> ./Informes/informeCOLOR.txt
		echo $rango_rafaga_max >> ./Informes/informeBN.txt
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
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo -n " Introduce el rango de memoria mínima de los procesos: "
	echo -n " Introduce el rango de memoria mínima de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el rango de memoria mínima de los procesos: " >> ./Informes/informeBN.txt
	read rango_memo_proc_min
	echo $rango_memo_proc_min >> ./Informes/informeCOLOR.txt
	echo $rango_memo_proc_min >> ./Informes/informeBN.txt

	###  COMPROBACIÓN DE MEMORIA MÍNIMA MAYOR QUE CERO Y MENOR QUE TAMAÑO DE PARTICIONES  ###

	#He fusionado las comprobaciones de mayor que cero y menor que partición máxima para evitar la situación que se daba al poder introducir
	#un valor correcto mayor que cero primero, pero luego un valor incorrecto mayor que la partición máxima y en el reintento un valor"correcto" 
	#menor que la partición máxima pero menor que 0 o directamente no un número.
	while ! mayor_cero $rango_memo_proc_min || [ $rango_memo_proc_min -gt $tam_par_max_efec ]
	do
		if ! mayor_cero $rango_memo_proc_min 	#He añadido una explicación más detallada del error de introducción de opción.
		then
			echo " Entrada no válida, por favor introduce un número natural mayor que cero"
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		else #Si la memoria mínima de los procesos es mayor que la mayor partición.
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce el rango de memoria mínima de los procesos: "
		echo -n " Introduce el rango de memoria mínima de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el rango de memoria mínima de los procesos: " >> ./Informes/informeBN.txt
		read rango_memo_proc_min
		echo $rango_memo_proc_min >> ./Informes/informeCOLOR.txt
		echo $rango_memo_proc_min >> ./Informes/informeBN.txt
	done

	###  RANGO DE MEMORIA MÁXIMA  ###

	imprime_cabecera_larga
	imprime_info_datos_rangos_aleatorios
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo -n " Introduce el rango de memoria máxima de los procesos: "
	echo -n " Introduce el rango de memoria máxima de los procesos: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce el rango de memoria máxima de los procesos: " >> ./Informes/informeBN.txt
	read rango_memo_proc_max
	echo $rango_memo_proc_max >> ./Informes/informeCOLOR.txt
	echo $rango_memo_proc_max >> ./Informes/informeBN.txt

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
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor introduce un número natural mayor que cero" >> ./Informes/informeBN.txt
		elif [ $rango_memo_proc_max -gt $tam_par_max_efec ] 	#Si la memoria máxima de los procesos es mayor que la mayor partición.
		then
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición"
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, la memoria que ocupa el proceso no ha de ser mayor al tamaño de la mayor partición" >> ./Informes/informeBN.txt
		else 
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo"
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeCOLOR.txt
			echo " Entrada no válida, por favor, introduce un límite máximo mayor al mínimo" >> ./Informes/informeBN.txt
		fi
		echo -n " Introduce el rango de memoria máxima de los procesos: "
		echo -n " Introduce el rango de memoria máxima de los procesos: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce el rango de memoria máxima de los procesos: " >> ./Informes/informeBN.txt
		read rango_memo_proc_max
		echo $rango_memo_proc_max >> ./Informes/informeCOLOR.txt
		echo $rango_memo_proc_max >> ./Informes/informeBN.txt
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
### Parámetros:
	# $1 -> Nombre del fichero a leer en el directorio FDatos, o "last" para el fichero de última ejecución. 
lectura_fichero()
{
	n_linea=0
	num_proc=0
	procesos_ejecutables=0

	#Si el parámetro es "last", carga el fichero DatosLast.txt del directorio FLast. Si no, carga el fichero pasado en el parámetro del directorio FDatos.
	if [[ $1 == "last" ]]
	then
		cp ./FLast/DatosLast.txt copia.txt 
	else 
		cp ./FDatos/"$1" copia.txt
	fi

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
						echo -e "Error al leer los procesos del fichero $1.txt"
						read -p "close" x
					;;
				esac

				let dat_proc_leidos=dat_proc_leidos+1
			done

			let num_proc=num_proc+1 #Suma el número de procesos leídos.
		fi
		let n_linea=n_linea+1 #Suma el número de líneas leídas.
	done < $fich

	ordenacion_procesos
	rm $fich
}


### Lee los datos desde un fichero de rangos.
### Parámetros:
	# $1 -> Nombre del fichero a leer en el directorio FRangos, o "last" para el fichero de última ejecución. 
lectura_fichero_rangos()
{
	n_linea=0
	procesos_ejecutables=0

	#Si el parámetro es "last", carga el fichero DatosRangosLast.txt del directorio FLast. Si no, carga el fichero pasado en el parámetro del directorio FRangos.
	if [[ $1 == "last" ]]
	then
		cp ./FLast/DatosRangosLast.txt copia.txt 
	else 
		cp ./FRangos/"$1" copia.txt
	fi

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
				echo -e "Error al leer los procesos del fichero $1.txt"
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

	ordenacion_procesos
	rm $fich
}

### Lee los datos desde un fichero de rangos aleatorios.
### Parámetros:
	# $1 -> Nombre del fichero a leer en el directorio FRangosAleatorios, o "last" para el fichero de última ejecución. 
lectura_fichero_rangos_aleatorios()
{
	n_linea=0
	procesos_ejecutables=0

	#Si el parámetro es "last", carga el fichero DatosRangosAleatoriosLast.txt del directorio FLast. Si no, carga el fichero pasado en el parámetro del directorio FRangosAleatorios.
	if [[ $1 == "last" ]]
	then
		cp ./FLast/DatosRangosAleatoriosLast.txt copia.txt 
	else 
		cp ./FRangosAleatorios/"$1" copia.txt
	fi

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
				echo -e "Error al leer los procesos del fichero $1.txt"
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

	ordenacion_procesos
	rm $fich
}


### Función que sirve como capa adicional para la selección de ficheros en vez de introducir el nombre exacto a mano.
### Agrupa la muestra de ficheros disponibles y la lectura en una interfaz más amigable.
### Parámetros:
	# $1 -> 1 para FDatos, 2 para FRangos, 3 para FRangosAleatorios.
leerFichero()
{
	case $1 in
		1)
			#Se buscan los ficheros del directorio FDatos.
			ls ./FDatos | grep .txt > listado.temp
		;;
		2)
			#Se buscan los ficheros del directorio FDatosRangos
			ls ./FRangos | grep .txt > listado.temp
		;;
		3)
			#Se buscan los ficheros del directorio FDatosRangosAleatorios
			ls ./FRangosAleatorios | grep .txt > listado.temp
		;;
		*)
			#Error de parámetro.
			echo " Error al introducir el parámetro en leerFichero."
		;;
	esac

	i=0

	while read line
	do
		for fich in $line 					#Para cada fichero en el archivo,
		do
			listaFicheros[$i]=$fich 		#Lo guardo en una lista.
			echo -e " $(($i+1)) - $fich" 	#Lo imprimo por pantalla con un número (= índice de lista +1).
			let i=i+1 						#Aumento el índice.
		done
	done < listado.temp

	echo -n " Introduce uno de los ficheros del listado: "
	echo -n " Introduce uno de los ficheros del listado: " >> ./Informes/informeCOLOR.txt
	echo -n " Introduce uno de los ficheros del listado: " >> ./Informes/informeBN.txt
	read fich
	echo $fich >> ./Informes/informeCOLOR.txt
	echo $fich >> ./Informes/informeBN.txt

	#Si el valor introducido es menor que 1 o mayor que el número de ficheros, es erróneo y se pide otra vez.
	while [ $fich -gt ${#listaFicheros[@]} ] || [ $fich -le 0 ]
	do
		echo " Entrada no válida, el valor de fichero introducido debe ser un número asociado a un fichero de la lista."
		echo " Entrada no válida, el valor de fichero introducido debe ser un número asociado a un fichero de la lista." >> ./Informes/informeCOLOR.txt
		echo " Entrada no válida, el valor de fichero introducido debe ser un número asociado a un fichero de la lista." >> ./Informes/informeBN.txt
		echo -n " Introduce uno de los ficheros del listado: "
		echo -n " Introduce uno de los ficheros del listado: " >> ./Informes/informeCOLOR.txt
		echo -n " Introduce uno de los ficheros del listado: " >> ./Informes/informeBN.txt
		read fich
		echo $fich >> ./Informes/informeCOLOR.txt
		echo $fich >> ./Informes/informeBN.txt
	done

	#Borro el archivo temporal.
	rm -r listado.temp

	#Lectura de los datos del fichero.
	case $1 in
		1)
			#Lectura de fichero de datos.
			lectura_fichero ${listaFicheros[$(($fich-1))]}
		;;
		2)
			#Lectura de fichero de rangos.
			lectura_fichero_rangos ${listaFicheros[$(($fich-1))]}
		;;
		3)
			#Lectura de fichero de datos.
			lectura_fichero_rangos_aleatorios ${listaFicheros[$(($fich-1))]}
		;;
		*)
			#Error de parámetro.
			echo " Error al introducir el parámetro en leerFichero."
		;;
	esac
}


### Función para guardar datos en un fichero con nombre elegido en el directorio Datos.
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

	mv "$1".txt ./FDatos
}


### Función para guardar datos en un fichero con nombre elegido en el directorio DatosRangos.
#He eliminado las funciones "meterAficheroUltimos_aleatorio" y "meterAficheroNuevo_aleatorio" y las he agrupado en ésta, dado que al seleccionar la opción ya se puede pasar como parámetro datos.txt.
meterAficheroRangos()
{
	echo "Rangos del número de particiones" > "$1".txt
	echo "$n_par_min $n_par_max" >> "$1".txt
	echo "Rangos del tamaño de particiones" >> "$1".txt
	echo "$tam_par_min $tam_par_max" >> "$1".txt
	echo "Rangos del quantum" >> "$1".txt
	echo "$quantum_min $quantum_max" >> "$1".txt
	echo "Rango del número de procesos" >> "$1".txt
	echo "$num_proc_min $num_proc_max" >> "$1".txt
	echo "Rangos del tiempo de llegada)" >> "$1".txt
	echo "$entrada_min $entrada_max" >> "$1".txt
	echo "Rangos del tiempo de ejecución" >> "$1".txt
	echo "$rafaga_min $rafaga_max" >> "$1".txt
	echo "Rangos de la memoria de cada proceso" >> "$1".txt
	echo "$memo_proc_min $memo_proc_max" >> "$1".txt

	mv "$1".txt ./FRangos
}


### Función para guardar datos en un fichero con nombre elegido en el directorio DatosRangosAleatorios.
meterAficheroRangosAleatorios()
{
	echo "Rangos del número de particiones" > "$1".txt
	echo "$rango_n_par_min $rango_n_par_max" >> "$1".txt
	echo "Rangos del tamaño de particiones" >> "$1".txt
	echo "$rango_tam_par_min $rango_tam_par_max" >> "$1".txt
	echo "Rangos del quantum" >> "$1".txt
	echo "$rango_quantum_min $rango_quantum_max" >> "$1".txt
	echo "Rango del número de procesos" >> "$1".txt
	echo "$rango_num_proc_min $rango_num_proc_max" >> "$1".txt
	echo "Rangos del tiempo de llegada)" >> "$1".txt
	echo "$rango_entrada_min $rango_entrada_max" >> "$1".txt
	echo "Rangos del tiempo de ejecución" >> "$1".txt
	echo "$rango_rafaga_min $rango_rafaga_max" >> "$1".txt
	echo "Rangos de la memoria de cada proceso" >> "$1".txt
	echo "$rango_memo_proc_min $rango_memo_proc_max" >> "$1".txt

	mv "$1".txt ./FRangosAleatorios
}


### Imprime los datos de los procesos introducidos a mano hasta el momento.
imprimir_tabla_procesos()
{
	clear
	imprime_cabecera_larga
	imprime_info_datos
	imprimir_tabla
}


### Imprime los datos de los procesos generados con rangos hasta el momento.
imprimir_tabla_procesos_aleatorios()
{
	clear
	imprime_cabecera_larga
	imprime_info_datos_aleatorios
	imprimir_tabla
}


### Imprime los datos de los procesos generados con rangos de rangos hasta el momento.
imprimir_tabla_procesos_rangos_aleatorios()
{
	clear
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

		echo -ne " \e[${color[$colimp]}mP" >> ./Informes/informeCOLOR.txt
		printf "%02d " "${NUMPROC[$pr]}" >> ./Informes/informeCOLOR.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> ./Informes/informeCOLOR.txt
		printf "%3s " "${TEJ[$pr]}" >> ./Informes/informeCOLOR.txt
		printf "%3s " "${MEMORIA[$pr]}" >> ./Informes/informeCOLOR.txt
		echo -e $resetColor >> ./Informes/informeCOLOR.txt

		echo -ne " P" >> ./Informes/informeBN.txt
		printf "%02d " "${NUMPROC[$pr]}" >> ./Informes/informeBN.txt
		printf "%3s " "${T_ENTRADA[$pr]}" >> ./Informes/informeBN.txt
		printf "%3s " "${TEJ[$pr]}" >> ./Informes/informeBN.txt
		printf "%3s " "${MEMORIA[$pr]}" >> ./Informes/informeBN.txt
		echo "" >> ./Informes/informeBN.txt
	done
}


### Ordena los procesos por tiempo de llegada.
ordenacion_procesos()
{
	for(( pr=0; pr<$num_proc; pr++ ))								#Para cada proceso,
	do
		ordenado[$pr]=0												#Lo marco como no ordenado.
	done

	for(( prf=0; prf<$num_proc; prf++ ))							#Para cada posición nueva de proceso,
	do
		menor_t_entr=${T_ENTRADA_I[0]}
		proceso_menor=-1
		for(( pri=0; pri<$num_proc; pri++ ))						#Por cada proceso a ordenar,
		do
			if [[ ${T_ENTRADA_I[$pri]} -lt $menor_t_entr ]]	&& [[ ${ordenado[$pri]} -eq 0 ]]		#Si el tiempo de entrada del pri es menor que el menor hasta el momento y no está ordenado,
			then
				menor_t_entr=${T_ENTRADA_I[$pri]}					#Actualizo el menor tiempo de entrada encontrado.
				proceso_menor=$pri 									#Guardo el índice del proceso con menor tiempo de llegada encontrado.
			fi
		done

		if [[ $proceso_menor -eq -1 ]]								#Si la referencia de índice al proceso menor sigue siendo -1 (el proceso 0 tiene el menor tiempo de entrada de los restantes),
		then
			proceso_menor=0
		fi

		NUMPROC[$prf]=${NUMPROC_I[$proceso_menor]}					#Pongo el proceso con menor tiempo de llegada encontrado en la siguiente posición de los arrays finales.		
		T_ENTRADA[$prf]=${T_ENTRADA_I[$proceso_menor]}
		TEJ[$prf]=${T_EJECUCION_I[$proceso_menor]}
		MEMORIA[$prf]=${MEMORIA_I[$proceso_menor]}

		ordenado[$proceso_menor]=1 									#Marco el proceso como ordenado.
	done
}


### Ordena los procesos por tiempo de llegada con quicksort.
ordenacion_procesos_quicksort()
{
	#Elegir el pivote para quicksort.
	len=$((${#$1}-1))
	if [[ ${#$1} -gt 2 ]]
	then
		let pivote=${$1[0]}+${$1[len]}+${$1[len/2]}
		let pivote=pivote/3

	elif [[ ${#$1} -eq 2 ]]
	then
		let pivote=${$1[0]}+${$1[1]}
		let pivote=pivote/2
	else 
		pivote=${$1[0]}
	fi

	arrayIzquierdo=

	return 


}


### Función para elegir el modo de ejecución del algoritmo.
modo_ejecucion()
{
	clear
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

	clear
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
		chartll=${#T_ENTRADA[contespacios1]}

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
		chartej=${#TEJ[contespacios2]}

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
		charmem=${#MEMORIA[contespacios3]}

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
	echo -ne " ┌────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo -ne "┬────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo -ne "┬────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo -ne "┬────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo -ne "┬──────┬──────┬──────┬─────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo "┬──────────────────┐" >> ./Informes/informeCOLOR.txt


	echo -ne " │ Ref" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne " " >> ./Informes/informeCOLOR.txt
	done
	echo  -ne "│ Tll" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne " " >> ./Informes/informeCOLOR.txt
	done
	echo -ne "│ Tej" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne " " >> ./Informes/informeCOLOR.txt
	done
	echo -ne "│ Mem" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne " " >> ./Informes/informeCOLOR.txt
	done
	echo -ne "│ Tesp │ Tret │ Trej │ Part" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne " " >> ./Informes/informeCOLOR.txt
	done
	echo "│ Estado           │" >> ./Informes/informeCOLOR.txt


	echo -ne " ├────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo -ne "┼────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo -ne "┼────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo -ne "┼────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo -ne "┼──────┼──────┼──────┼─────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo "┼──────────────────┤" >> ./Informes/informeCOLOR.txt


	for((xp = 0; xp < $num_proc; xp++ ))
	do
		if [ $xp -ge 5 ]
		then
			let colimp=xp%5
		else
			colimp=$xp
		fi

		#Ahora los datos aparecen entablados
		printf " │ " >> ./Informes/informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}mP" >> ./Informes/informeCOLOR.txt
		printf "%02d" "${NUMPROC[$xp]}" >> ./Informes/informeCOLOR.txt
		for (( l = 0; l < ($espacios_num_proc_tabla - 2); l++))
		do
			echo -ne " "
		done
		echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt

		printf " │ " >> ./Informes/informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> ./Informes/informeCOLOR.txt
		printf "%3s" "${T_ENTRADA[$xp]}" >> ./Informes/informeCOLOR.txt
		echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt

		printf " │ " >> ./Informes/informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> ./Informes/informeCOLOR.txt
		printf "%3s" "${TEJ[$xp]}" >> ./Informes/informeCOLOR.txt
		echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt

		printf " │ " >> ./Informes/informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> ./Informes/informeCOLOR.txt
		printf "%3s" "${MEMORIA[$xp]}" >> ./Informes/informeCOLOR.txt
		echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt

		printf " │ " >> ./Informes/informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> ./Informes/informeCOLOR.txt
		printf "%4s" "${TES[$xp]}" >> ./Informes/informeCOLOR.txt
		echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt

		printf " │ " >> ./Informes/informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> ./Informes/informeCOLOR.txt
		printf "%4s" "${TRET[$xp]}" >> ./Informes/informeCOLOR.txt
		echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt

		printf " │ " >> ./Informes/informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> ./Informes/informeCOLOR.txt
		printf "%4s" "${TREJ[$xp]}" >> ./Informes/informeCOLOR.txt
		echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt


		if [[ PART[$xp] -eq -1 ]]
		then
			part_displ="-"
		else 
			let part_displ=${PART[$xp]}+1
		fi
		printf " │ " >> ./Informes/informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> ./Informes/informeCOLOR.txt
		printf "%4s" "$part_displ" >> ./Informes/informeCOLOR.txt
		echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt

		printf " │ " >> ./Informes/informeCOLOR.txt
		echo -ne "\e[${color[$colimp]}m" >> ./Informes/informeCOLOR.txt
		if [[ ${ESTADO[$xp]} == "Ejecucion" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeCOLOR.txt
			echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt
			printf "        │ " >> ./Informes/informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "Fuera de Sistema" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeCOLOR.txt
			echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt
			printf " │ " >> ./Informes/informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "En pausa" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeCOLOR.txt
			echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt
			printf "         │ " >> ./Informes/informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "En memoria" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeCOLOR.txt
			echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt
			printf "       │ " >> ./Informes/informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "En espera" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeCOLOR.txt
			echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt
			printf "        │ " >> ./Informes/informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "Bloqueado" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeCOLOR.txt
			echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt
			printf "        │ " >> ./Informes/informeCOLOR.txt
		fi
		if [[ ${ESTADO[$xp]} == "Terminado" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeCOLOR.txt
			echo -ne "\e[0m" >> ./Informes/informeCOLOR.txt
			printf "        │ " >> ./Informes/informeCOLOR.txt
		fi
		echo -e "\e[0m" >> ./Informes/informeCOLOR.txt

		memlibre[$xp]=$(( ${tam_par[$i]} - ${MEMORIA[$xp]} ))
	done

	echo -ne " └────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo -ne "┴────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done

	echo -ne "┴────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo -ne "┴────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo -ne "┴──────┴──────┴──────┴─────" >> ./Informes/informeCOLOR.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> ./Informes/informeCOLOR.txt
	done
	echo "┴──────────────────┘" >> ./Informes/informeCOLOR.txt

	#Tabla principal, que se ajusta a los datos introducidos, para el informe a blanco y negro
	echo -ne " ┌────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo -ne "┬────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo -ne "┬────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo -ne "┬────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo -ne "┬──────┬──────┬──────┬─────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo "┬──────────────────┐" >> ./Informes/informeBN.txt

	echo -ne " │ Ref" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne " " >> ./Informes/informeBN.txt
	done
	echo  -ne "│ Tll" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne " " >> ./Informes/informeBN.txt
	done
	echo -ne "│ Tej" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne " " >> ./Informes/informeBN.txt
	done
	echo -ne "│ Mem" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne " " >> ./Informes/informeBN.txt
	done
	echo -ne "│ Tesp │ Tret │ Trej │ Part" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne " " >> ./Informes/informeBN.txt
	done
	echo "│ Estado           │" >> ./Informes/informeBN.txt

	echo -ne " ├────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo -ne "┼────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo -ne "┼────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo -ne "┼────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo -ne "┼──────┼──────┼──────┼─────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo "┼──────────────────┤" >> ./Informes/informeBN.txt

	for((xp=0; xp<$num_proc; xp++ ))
	do
		if [ $xp -ge 5 ]
		then
			let colimp=$xp%5
		else
			colimp=$xp
		fi

		#Ahora los datos aparecen entablados
		printf " │ " >> ./Informes/informeBN.txt
		echo -ne "P" >> ./Informes/informeBN.txt
		printf "%02d" "${NUMPROC[$xp]}" >> ./Informes/informeBN.txt
		for (( l = 0; l < ($espacios_num_proc_tabla - 2); l++))
		do
			echo -ne " "
		done

		printf " │ " >> ./Informes/informeBN.txt
		printf "%3s" "${T_ENTRADA[$xp]}" >> ./Informes/informeBN.txt

		printf " │ " >> ./Informes/informeBN.txt
		printf "%3s" "${TEJ[$xp]}" >> ./Informes/informeBN.txt

		printf " │ " >> ./Informes/informeBN.txt
		printf "%3s" "${MEMORIA[$xp]}" >> ./Informes/informeBN.txt

		printf " │ " >> ./Informes/informeBN.txt
		printf "%4s" "${TES[$xp]}" >> ./Informes/informeBN.txt

		printf " │ " >> ./Informes/informeBN.txt
		printf "%4s" "${TRET[$xp]}" >> ./Informes/informeBN.txt

		printf " │ " >> ./Informes/informeBN.txt
		printf "%4s" "${TREJ[$xp]}" >> ./Informes/informeBN.txt

		if [[ PART[$xp] -eq -1 ]]
		then
			part_displ="-"
		else 
			let part_displ=${PART[$xp]}+1
		fi
		printf " │ " >> ./Informes/informeBN.txt
		printf "%4s" "$part_displ" >> ./Informes/informeBN.txt

		printf " │ " >> ./Informes/informeBN.txt
		if [[ ${ESTADO[$xp]} == "Ejecucion" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeBN.txt
			printf "        │ " >> ./Informes/informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "Fuera de Sistema" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeBN.txt
			printf " │ " >> ./Informes/informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "En pausa" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeBN.txt
			printf "         │ " >> ./Informes/informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "En memoria" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeBN.txt
			printf "       │ " >> ./Informes/informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "En espera" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeBN.txt
			printf "        │ " >> ./Informes/informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "Bloqueado" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeBN.txt
			printf "        │ " >> ./Informes/informeBN.txt
		fi
		if [[ ${ESTADO[$xp]} == "Terminado" ]]
		then
			printf "${ESTADO[$xp]}" >> ./Informes/informeBN.txt
			printf "        │ " >> ./Informes/informeBN.txt
		fi
		echo -e "" >> ./Informes/informeBN.txt

		memlibre[$xp]=$(( ${tam_par[$i]} - ${MEMORIA[$xp]} ))
	done

	echo -ne " └────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_num_proc_tabla - 1); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo -ne "┴────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayortll_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done

	echo -ne "┴────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayortej_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo -ne "┴────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_mayormem_tabla - 2); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo -ne "┴──────┴──────┴──────┴─────" >> ./Informes/informeBN.txt
	for (( l = 0; l < ($espacios_n_par_tabla - 3); l++))
	do
		echo -ne "─" >> ./Informes/informeBN.txt
	done
	echo "┴──────────────────┘" >> ./Informes/informeBN.txt

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
		printf " Tesp medio = 0.00\t" >> ./Informes/informeCOLOR.txt
		printf " Tesp medio = 0.00\t" >> ./Informes/informeBN.txt
	else
		med_t_esp=$(awk -v num1=$sum_t_esp -v num2=$cont_t_esp 'BEGIN {print num1/num2}')
		LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $med_t_esp
		LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $med_t_esp >> ./Informes/informeCOLOR.txt
		LC_NUMERIC="en_US.UTF-8" printf " T medio de espera = %0.2f\t" $med_t_esp >> ./Informes/informeBN.txt
	fi
	if [[ $tretmed -eq 0 ]]
	then
		printf " Tret medio = 0.00\n"
		printf " Tret medio = 0.00\n" >> ./Informes/informeCOLOR.txt
		printf " Tret medio = 0.00\n" >> ./Informes/informeBN.txt
	else
		med_t_ret=$(awk -v num1=$sum_t_ret -v num2=$cont_t_ret 'BEGIN {print num1/num2}')
		LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $med_t_ret
		LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $med_t_ret >> ./Informes/informeCOLOR.txt
		LC_NUMERIC="en_US.UTF-8" printf " T medio de retorno = %0.2f\n" $med_t_ret >> ./Informes/informeBN.txt
	fi

	echo -n " Cola RR: "
	echo -n " Cola RR: " >> ./Informes/informeCOLOR.txt
	echo -n " Cola RR: " >> ./Informes/informeBN.txt
	for(( i = 1; i < ${#colaprocs[@]}; i++ ))
	do
		if [  ${colaprocs[$i]} -ge 5 ]
		then
			let colimp=${colaprocs[$i]}%5
		else
			colimp=${colaprocs[$i]}
		fi

		printf "\e[${color[$colimp]}mP%02d$resetColor " "$((${colaprocs[$i]}+1))"
		printf "\e[${color[$colimp]}mP%02d$resetColor " "$((${colaprocs[$i]}+1))" >> ./Informes/informeCOLOR.txt
		printf "P%02d " "$((${colaprocs[$i]}+1))" >> ./Informes/informeBN.txt
	done
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt

	actualizar_bm

	#actualizar_bt
	imprimir_bt

	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
	echo "---------------------------------------------------------" >> ./Informes/informeCOLOR.txt
	echo "---------------------------------------------------------" >> ./Informes/informeBN.txt
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt

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
	echo -e " ${cad_top_tab_pa[@]}" >> ./Informes/informeCOLOR.txt
	echo -e " ${cad_top_tab_pa[@]}" >> ./Informes/informeBN.txt
	echo -e " ${cad_datos_tab_pa[@]}"
	echo -e " ${cad_datos_tab_pa[@]}" >> ./Informes/informeCOLOR.txt
	echo -e " ${cad_datos_tab_pa[@]}" >> ./Informes/informeBN.txt
	echo -e " ${cad_bot_tab_pa[@]}"
	echo -e " ${cad_bot_tab_pa[@]}" >> ./Informes/informeCOLOR.txt
	echo -e " ${cad_bot_tab_pa[@]}" >> ./Informes/informeBN.txt
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

	#Inicio de las cadenas de la BM.
	cad_particiones="    |"
	cad_proc_bm="    |"
	cad_mem_col=" BM |"
	cad_mem_byn=" BM |"
	cad_can_mem="    |"

	#Variable para contar la memoria representada.
	mem_rep=0

	#Columnas que quedan en la consola a la derecha de la barra inicial en la BM (5 espacios) menos un espacio a la derecha.
	columnas_bm=$(($(tput cols)-6))

	#Columnas impresas en la consola después de la barra inicial.
	caracteres_impresos=0

		
	for ((pa=0; pa<$n_par; pa++))													#Para cada partición,
	do
		for (( uni_par=1; uni_par<=${tam_par[$pa]}; uni_par++ ))					#Para cada unidad imprimible de la partición (su tamaño).
		do
			#Actualizo los caracteres impresos antes para saber lo que se ocupará de antemano.
			if [[ $uni_par -eq ${tam_par[$pa]} ]] && [[ $pa -ne $(($n_par-1)) ]] 	#Si es la última unidad (el final de la partición), y no es la última partición,
			then
				let caracteres_impresos=caracteres_impresos+$tam_unidad_bm+1 		#Actualizo los caracteres impresos con el tamaño de la unidad y el espacio entre particiones.
			else
				let caracteres_impresos=caracteres_impresos+$tam_unidad_bm 			#Actualizo los caracteres impresos con el tamaño de la unidad.
			fi

			#Cortar a la siguiente línea la unidad de memoria.
			if [[ $caracteres_impresos -gt $columnas_bm ]] 							#Si va a haber más caracteres impresos que espacio en la pantalla,
			then
				echo -e "${cad_particiones[@]}"										#Represento lo que llevo de barra de memoria.
				echo -e "${cad_particiones[@]}" >> ./Informes/informeCOLOR.txt
				echo -e "${cad_particiones[@]}" >> ./Informes/informeBN.txt

				echo -e "${cad_proc_bm[@]}"
				echo -e "${cad_proc_bm[@]}" >> ./Informes/informeCOLOR.txt
				echo -e "${cad_proc_bm[@]}" >> ./Informes/informeBN.txt

				echo -e "${cad_mem_col[@]}"
				echo -e "${cad_mem_col[@]}" >> ./Informes/informeCOLOR.txt
				echo -e "${cad_mem_byn[@]}" >> ./Informes/informeBN.txt

				echo -e "${cad_can_mem[@]}"
				echo -e "${cad_can_mem[@]}" >> ./Informes/informeCOLOR.txt
				echo -e "${cad_can_mem[@]}" >> ./Informes/informeBN.txt

				cad_particiones="     "												#Reseteo las cadenas con el margen izquierdo de la cabecera de la barra.
				cad_proc_bm="     "
				cad_mem_col="     "
				cad_mem_byn="     "
				cad_can_mem="     "
				columnas_bm=$(($(tput cols)-6)) 									#Reseteo las columnas que quedan libres.
				if [[ $uni_par -eq ${tam_par[$pa]} ]] && [[ $pa -ne $(($n_par-1)) ]] #Si es la última unidad (el final de la partición), y no es la última partición,
				then
					let caracteres_impresos=$tam_unidad_bm+1 						#Reseteo los caracteres impresos con el tamaño de la unidad y el espacio entre particiones.
				else
					let caracteres_impresos=$tam_unidad_bm 							#Reseteo los caracteres impresos con el tamaño de la unidad.
				fi
			fi

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
					*)																#7 o más caracteres, (no debería tener nunca 0, 1 o 2 caracteres, ni valores negativos)
						for (( esp=0; esp<($tam_unidad_bm); esp++ ))				#Por lo que queda de unidad (sin restar nada porque en 7 o más caracteres ya se escribió toda la partición en la primera unidad),
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
			fi


			##Montaje de la cadena de procesos en la barra de memoria.
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
			fi


			## Montaje de la cadena de cantidad de memoria en la barra de memoria.
			if [[ $uni_par -eq 1 ]]														#Si es la primera unidad de la partición,
			then
				for (( esp=0; esp<$(($tam_unidad_bm-${#mem_rep})); esp++ ))				#Por lo que ocupe la unidad menos lo que ocupa escribir la memoria,
				do
					cad_can_mem=${cad_can_mem[@]}" "									#Añado un espacio.
				done
				cad_can_mem=${cad_can_mem[@]}"$mem_rep"									#Añado la cifra de memoria que se ha representado.
			elif [[ ${PROC[$pa]} -ne -1 ]] && [[ $uni_par -eq $((${MEMORIA[${PROC[$pa]}]}+1)) ]]	#Si tiene un proceso y es la unidad siguiente a lo que ocupa,
			then																		
				memo_proc=${MEMORIA[${PROC[$pa]}]}										#Guardo lo que ocupa el proceso en una variable.
				let mem_rep=mem_rep+memo_proc											#Actualizo la cantidad de memoria representada.
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

			if [[ $uni_par -eq ${tam_par[$pa]} ]] 										#Si es la última unidad de la partición,
			then
				if [[ ${PROC[$pa]} -eq -1 ]]											#Si no había un proceso,
				then
					let mem_rep=mem_rep+${tam_par[$pa]}									#Actualizo la memoria representada con el tamaño de la partición.
				else 																	#Si había un proceso,
					let mem_rep=mem_rep-memo_proc+${tam_par[$pa]}						#Actualizo la memoria representada con el tamaño de la partición menos la memoria que se sumó del proceso.
				fi
			fi

			if [[ $uni_par -eq ${tam_par[$pa]} ]] && [[ $pa -ne $(($n_par-1)) ]] 		#Si es la última unidad (el final de la partición), y no es la última partición,
			then
				cad_can_mem=${cad_can_mem[@]}" "										#Añado un espacio entre particiones.
			fi
		done
	done


	let ocup_mem_total=4+${#memoria_total}												#Calculo lo que ocupa escribir la memoria total (mas 5 de barra, espacio, M, =, y espacio final.
	if [[ $ocup_mem_total -gt $(($columnas_bm-$caracteres_impresos)) ]]					#Si va a ocupar más de lo que queda de pantalla,
	then
		echo -e "${cad_particiones[@]}"													#Represento lo que llevo de barra de memoria.
		echo -e "${cad_particiones[@]}" >> ./Informes/informeCOLOR.txt
		echo -e "${cad_particiones[@]}" >> ./Informes/informeBN.txt

		echo -e "${cad_proc_bm[@]}"
		echo -e "${cad_proc_bm[@]}" >> ./Informes/informeCOLOR.txt
		echo -e "${cad_proc_bm[@]}" >> ./Informes/informeBN.txt

		echo -e "${cad_mem_col[@]}"
		echo -e "${cad_mem_col[@]}" >> ./Informes/informeCOLOR.txt
		echo -e "${cad_mem_byn[@]}" >> ./Informes/informeBN.txt

		echo -e "${cad_can_mem[@]}"
		echo -e "${cad_can_mem[@]}" >> ./Informes/informeCOLOR.txt
		echo -e "${cad_can_mem[@]}" >> ./Informes/informeBN.txt

		cad_particiones="     "															#Reseteo las cadenas con el margen izquierdo de la cabecera de la barra.
		cad_proc_bm="     "
		cad_mem_col="     "
		cad_mem_byn="     "
		cad_can_mem="     "
	fi

	## Añado la memoria total a las cadena.
	cad_particiones=${cad_particiones[@]}"| "
	cad_proc_bm=${cad_proc_bm[@]}"| "
	cad_mem_col=${cad_mem_col[@]}"| M=$memoria_total"
	cad_mem_byn=${cad_mem_byn[@]}"| M=$memoria_total"
	cad_can_mem=${cad_can_mem[@]}"| "

	## Representacion de la Barra de Memoria.
	echo -e "${cad_particiones[@]}"
	echo -e "${cad_particiones[@]}" >> ./Informes/informeCOLOR.txt
	echo -e "${cad_particiones[@]}" >> ./Informes/informeBN.txt

	echo -e "${cad_proc_bm[@]}"
	echo -e "${cad_proc_bm[@]}" >> ./Informes/informeCOLOR.txt
	echo -e "${cad_proc_bm[@]}" >> ./Informes/informeBN.txt

	echo -e "${cad_mem_col[@]}"
	echo -e "${cad_mem_col[@]}" >> ./Informes/informeCOLOR.txt
	echo -e "${cad_mem_byn[@]}" >> ./Informes/informeBN.txt

	echo -e "${cad_can_mem[@]}"
	echo -e "${cad_can_mem[@]}" >> ./Informes/informeCOLOR.txt
	echo -e "${cad_can_mem[@]}" >> ./Informes/informeBN.txt
		
	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
}


### Calcula el tamaño necesario de las unidades para la barra de tiempo. En una función aparte para ejecutarlo solo una vez al principio.
iniciar_bt()
{
	#Calculo el tamaño del espacio representado en la barra por cada unidad de tiempo en función del tamaño del mayor tiempo de entrada.
	sumatorio=0
	for ((pr=0; pr<$num_proc; pr++ ))
	do
		let sumatorio=${T_ENTRADA[$pr]}+${TEJ[$pr]}
	done
	tam_unidad_bt=3
	#Si va a haber procesos que lleven el tiempo a más de 3 cifras, se aumenta el tamaño de la unidad de tiempo.
	if [[ $((${#sumatorio}+1)) -gt $tam_unidad_bt ]]
	then
		tam_unidad_bt=$((${#sumatorio}+1))
	fi
}


### Actualiza las cadenas de la barra de tiempo añadiendo otra unidad de tiempo.
actualizar_bt()
{
	for((pr=0; pr<$num_proc; pr++))																			#Bucle para contar los procesos que están fuera del sistema.
	do
		if [[ ${ESTADO[$pr]} == "Fuera de Sistema" ]]
		then
			let fuera_sist=fuera_sist+1
		fi
	done

	## Adición de la cadena de procesos en la barra de tiempo.
	cad_uni_proc_col_bt=" "
	esp_ocupado=0																							#Espacio ocupado al escribir el proceso.
	if [ ! -z $proc_actual ] && ([ -z $proc_ante ]||[ $proc_ante -ne $proc_actual ])						#Si hay un proceso en ejecución y no hay anterior o es distinto al actual,
	then
		if [[ $proc_actual -ge 5 ]] 																		#Condicional para ajustar el color del proceso.
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
			cad_proc_col_bt[$tiempo_transcurrido]="\e[${color[$colimp]}mP${NUMPROC[$proc_actual]}\e[0m"	#Añado el proceso sin el 0 delante en color a la cadena de color.
			cad_proc_byn_bt[$tiempo_transcurrido]="P${NUMPROC[$proc_actual]}"								#Añado el proceso sin el 0 delante a la cadena en blanco y negro.
		fi
		esp_ocupado=3																						#Actualizo el espacio ocupado por el proceso.
	fi
	
	for (( esp=0; esp<$tam_unidad_bt-$esp_ocupado; esp++ ))													#Por cada hueco hasta completar la unidad menos lo ocupado por el proceso (si no había, 0),
	do
		cad_proc_col_bt[$tiempo_transcurrido]=${cad_proc_col_bt[$tiempo_transcurrido]}" "					#Añado un espacio.
		cad_proc_byn_bt[$tiempo_transcurrido]=${cad_proc_byn_bt[$tiempo_transcurrido]}" "
	done


	## Adición de la cadena de cuadrados en la barra de tiempo.
	if [[ ! -z $proc_actual ]] 																				#Si hay un proceso en ejecución,
	then
		if [[ $proc_actual -ge 5 ]] 																		#Condicional para ajustar el color del proceso.
		then
			let colimp=proc_actual%5
		else
			colimp=$proc_actual
		fi

		for(( esp=0; esp<$tam_unidad_bt; esp++ ))															#Por lo que ocupa la unidad,
		do
			cad_tie_col[$tiempo_transcurrido]="${cad_tie_col[$tiempo_transcurrido]}\e[${color[$colimp]}m\u2588\e[0m"	#Añado un cuadrado de color a la cadena de color.
			cad_tie_byn[$tiempo_transcurrido]="${cad_tie_byn[$tiempo_transcurrido]}\u2588"								#Añado un cuadrado blanco a la cadena en blanco y negro.
		done
	else 																									#Si no hay un proceso en ejecución,
		for (( esp=0; esp<$tam_unidad_bt; esp++ ))															#Por cada hueco hasta completar la unidad,
		do
			cad_tie_col[$tiempo_transcurrido]="${cad_tie_col[$tiempo_transcurrido]}\u2588"					#Añado un cuadrado blanco.
			cad_tie_byn[$tiempo_transcurrido]="${cad_tie_byn[$tiempo_transcurrido]}\u2588"		
		done
	fi


	## Adición de la cadena de cantidad de tiempo en la barra de tiempo.
	for (( esp=0; esp<$tam_unidad_bt-${#tiempo_transcurrido}; esp++ ))										#Por cada hueco de la unidad menos lo que ocupe el tiempo,
	do
		cad_can_tie[$tiempo_transcurrido]=${cad_can_tie[$tiempo_transcurrido]}" "							#Añado un espacio.
	done
	#Si es t=0, hay un evento, se acaba el quantum de un proceso en ejecución, el quantum es 1, o no hay proceso pero sí hay anterior,
	if [[ $tiempo_transcurrido -eq 0 ]] || [[ $evento = 1 ]] || [[ $((${T_EJEC[$proc_actual]} % $quantum)) = 1 ]] || [[ $quantum = 1 ]] || ([[ -z $proc_actual ]] && [[ ! -z $proc_ante ]])
	then
		cad_can_tie[$tiempo_transcurrido]=${cad_can_tie[$tiempo_transcurrido]}"$tiempo_transcurrido"		#Añado el tiempo.
	else 
		for (( esp=0; esp<${#tiempo_transcurrido}; esp++ ))													#Por lo que ocuparía el tiempo,
		do
			cad_can_tie[$tiempo_transcurrido]=${cad_can_tie[$tiempo_transcurrido]}" " 						#Añado un espacio.
		done
	fi
}


### Representación de la Barra de Tiempo.
imprimir_bt()
{
	columnas_bt=$(($(tput cols)-6))											#5 espacios de cabecera a la izquierda y un espacio de margen a la derecha. 
	
	prim_linea_proc=true
	prim_linea_tie=true
	prim_linea_can_tie=true

	let unidades_pantalla=columnas_bt/tam_unidad_bt 						#Calculo cuántas unidades caben en lo que queda de pantalla.
	if [[ $(($tiempo_transcurrido+1)) -lt $unidades_pantalla ]]				#Si no hay tantas unidades de tiempo que representar,
	then
		unidades_posibles=$(($tiempo_transcurrido+1))						#Lo ajusto al tiempo actual (+1 para el t=0).
	else 																	#Si no se pasan,
		unidades_posibles=$unidades_pantalla								#Las unidades posibles son todas las que caben en pantalla.
	fi

	uds_impresas_pro=0 														#Contador de las unidades impresas en la cadena de procesos.
	uds_impresas_tie=0 														#Contador de las unidades impresas en la cadena de procesos.
	uds_impresas_can_tie=0 													#Contador de las unidades impresas en la cadena de procesos.
	lineas_impresas_bt=0 													#Contador de lineas adicionales impresas.

	while [[ $uds_impresas_tie -lt ${#cad_tie_col[@]} ]]					#Mientras queden unidades de tiempo que representar (<= para el t=0),
	do
		columnas_bt=$(($(tput cols)-6)) 									#Reseteo el valor de columnas restantes.
		let unidades_pantalla=columnas_bt/tam_unidad_bt 					#Calculo cuántas unidades caben en lo que queda de pantalla.
		if [[ $unidades_pantalla -gt $((${#cad_tie_col[@]}-$uds_impresas_tie)) ]]	#Si las unidades posibles se va a pasar de las necesarias,
		then
			unidades_posibles=$((${#cad_tie_col[@]}-$uds_impresas_tie))		#Ajusto el valor a las que quedan por imprimir.
		else 																#Si no se pasan,
			unidades_posibles=$unidades_pantalla							#Las unidades posibles son todas las que caben en pantalla.
		fi


		## Impresión de cadena de procesos.
		echo ""
		echo "" >> ./Informes/informeCOLOR.txt
		echo "" >> ./Informes/informeBN.txt
		if $prim_linea_proc													#Si es la primera línea de la barra,
		then
			echo -n "    |"													#Imprimo la cabecera con la barra en una nueva línea.
			echo -n "    |" >> ./Informes/informeCOLOR.txt
			echo -n "    |" >> ./Informes/informeBN.txt
			prim_linea_proc=false 											#Ya no es la primera línea.
		else 																#Si no es la primera línea de la barra,
			echo -n "     "													#Imprimo la cabecera de espacios en una nueva línea.
			echo -n "     " >> ./Informes/informeCOLOR.txt
			echo -n "     " >> ./Informes/informeBN.txt
			let lineas_impresas_bt=lineas_impresas_bt+1
		fi
		for (( uni=0; uni<$unidades_posibles; uni++ ))						#Para cada unidad que cabe en la línea,
		do
			let uni_linea=uni+unidades_pantalla*lineas_impresas_bt			#Calculo el índice a imprimir según las lineas impresas anteriormente.
			echo -ne "${cad_proc_col_bt[$uni_linea]}"						#Imprimo la unidad en la misma línea.
			echo -ne "${cad_proc_col_bt[$uni_linea]}" >> ./Informes/informeCOLOR.txt
			echo -ne "${cad_proc_byn_bt[$uni_linea]}" >> ./Informes/informeBN.txt
			let uds_impresas_pro=uds_impresas_pro+1 						#Sumo el contador de unidades impresas.
			let columnas_bt=columnas_bt-tam_unidad_bt 						#Resto el contador de columnas restantes.
		done

		if [[ $uds_impresas_pro -eq ${#cad_proc_col_bt[@]} ]] && [[ $columnas_bt -ge $((${#tiempo_transcurrido}+4)) ]]
		then
			printf "|"
			printf "|" >> ./Informes/informeCOLOR.txt
			printf "|" >> ./Informes/informeBN.txt
		fi


		## Impresión de cadena de tiempo.
		echo ""
		echo "" >> ./Informes/informeCOLOR.txt
		echo "" >> ./Informes/informeBN.txt
		if $prim_linea_tie 													#Si es la primera línea de la barra,
		then
			echo -n " BT |"													#Imprimo la cabecera con la barra en una nueva línea.
			echo -n " BT |" >> ./Informes/informeCOLOR.txt
			echo -n " BT |" >> ./Informes/informeBN.txt
			prim_linea_tie=false 											#Ya no es la primera línea.
		else 																#Si no es la primera línea de la barra,
			echo -n "     "													#Imprimo la cabecera de espacios en una nueva línea.
			echo -n "     " >> ./Informes/informeCOLOR.txt
			echo -n "     " >> ./Informes/informeBN.txt
		fi
		for (( uni=0; uni<$unidades_posibles; uni++ ))						#Para cada unidad que cabe en la línea,
		do
			let uni_linea=uni+unidades_pantalla*lineas_impresas_bt			#Calculo el índice a imprimir según las lineas impresas anteriormente.
			echo -ne "${cad_tie_col[$uni_linea]}"							#Imprimo la unidad en la misma línea.
			echo -ne "${cad_tie_col[$uni_linea]}" >> ./Informes/informeCOLOR.txt
			echo -ne "${cad_tie_byn[$uni_linea]}" >> ./Informes/informeBN.txt
			let uds_impresas_tie=uds_impresas_tie+1 						#Sumo el contador de unidades impresas.
		done

		if [[ $uds_impresas_tie -eq ${#cad_tie_col[@]} ]] && [[ $columnas_bt -ge $((${#tiempo_transcurrido}+4)) ]]
		then
			printf "| T=$tiempo_transcurrido"
			printf "| T=$tiempo_transcurrido" >> ./Informes/informeCOLOR.txt
			printf "| T=$tiempo_transcurrido" >> ./Informes/informeBN.txt
		fi


		## Impresión de cadena de cantidad de tiempo.
		echo ""
		echo "" >> ./Informes/informeCOLOR.txt
		echo "" >> ./Informes/informeBN.txt
		if $prim_linea_can_tie												#Si es la primera línea de la barra,
		then
			echo -n "    |"													#Imprimo la cabecera con la barra en una nueva línea.
			echo -n "    |" >> ./Informes/informeCOLOR.txt
			echo -n "    |" >> ./Informes/informeBN.txt
			contCarac=0
			prim_linea_can_tie=false 										#Ya no es la primera línea.
		else 																#Si no es la primera línea de la barra,
			echo -n "     "													#Imprimo la cabecera de espacios en una nueva línea.
			echo -n "     " >> ./Informes/informeCOLOR.txt
			echo -n "     " >> ./Informes/informeBN.txt
		fi
		for (( uni=0; uni<$unidades_posibles; uni++, contCarac++ ))			#Para cada unidad que cabe en la línea, 
		do
			let uni_linea=uni+unidades_pantalla*lineas_impresas_bt			#Calculo el índice a imprimir según las lineas impresas anteriormente.
			echo -ne "${cad_can_tie[$uni_linea]}"							#Imprimo la unidad en la misma línea.
			echo -ne "${cad_can_tie[$uni_linea]}" >> ./Informes/informeCOLOR.txt
			echo -ne "${cad_can_tie[$uni_linea]}" >> ./Informes/informeBN.txt
			let uds_impresas_can_tie=uds_impresas_can_tie+1 				#Sumo el contador de unidades impresas.
		done

		if [[ $uds_impresas_can_tie -eq ${#cad_can_tie[@]} ]] && [[ $columnas_bt -ge $((${#tiempo_transcurrido}+4)) ]]
		then
			printf "|"
			printf "|" >> ./Informes/informeCOLOR.txt
			printf "|" >> ./Informes/informeBN.txt
		fi
	done

	if [[ $columnas_bt -lt $((${#tiempo_transcurrido}+4)) ]]
	then
		echo ""
		printf "     |"
		echo "" >> ./Informes/informeCOLOR.txt
		printf "     |" >> ./Informes/informeCOLOR.txt
		echo "" >> ./Informes/informeBN.txt
		printf "     |" >> ./Informes/informeBN.txt

		echo ""
		printf "     | T=$tiempo_transcurrido"
		echo "" >> ./Informes/informeCOLOR.txt
		printf "     | T=$tiempo_transcurrido" >> ./Informes/informeCOLOR.txt
		echo "" >> ./Informes/informeBN.txt
		printf "     | T=$tiempo_transcurrido" >> ./Informes/informeBN.txt

		echo ""
		printf "     |"
		echo "" >> ./Informes/informeCOLOR.txt
		printf "     |" >> ./Informes/informeCOLOR.txt
		echo "" >> ./Informes/informeBN.txt
		printf "     |" >> ./Informes/informeBN.txt
	fi

	echo ""
	echo "" >> ./Informes/informeCOLOR.txt
	echo "" >> ./Informes/informeBN.txt
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
		if [[ $mayortll -lt ${T_ENTRADA[$pr]} ]]
		then
			mayortll=${T_ENTRADA[$pr]}
		fi

		#Tiempo de ejecución.
		if [[ $mayortej -lt ${TEJ[$pr]} ]]
		then
			mayortej=${TEJ[$pr]}
		fi

		#Espacio en memoria.
		if [[ $mayormem -lt ${MEMORIA[$pr]} ]]
		then
			mayormem=${MEMORIA[$pr]}
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
		PART[$pr]=-1
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
	for(( pr=0; pr<$num_proc; pr++ ))													#Para cada proceso,
	do
		mayor_tam_par=0 																#LLeva el registro del mayor tamaño de partición vacía.
		part_vacia_mayor=-1 															#Índice de la partición vacía con mayor tamaño.
		for (( pa=0; pa<n_par; pa++ ))													#Para cada partición,
		do
			if [[ ${PROC[$pa]} -eq -1 ]] && [[ ${tam_par[$pa]} -gt  $mayor_tam_par ]]	#Si no tiene un proceso (está vacía), y su tamaño es mayor al anterior mayor tamaño,
			then
				mayor_tam_par=${tam_par[$pa]}											#Actualiza el valor del mayor tamaño de partición vacía.
				part_vacia_mayor=$pa 													#Actualiza el índice de la partición vacía con mayor tamaño.
			fi
		done

		#Si el proceso puede entrar en memoria y cabe en la partición mayor,
		if [[ ${TIEMPO[$pr]} != 0 ]] && [[ $tiempo_transcurrido -ge ${T_ENTRADA[$pr]} ]] && [[ ${EN_MEMO[$pr]} == "S/E" ]] && [[ ${MEMORIA[$pr]} -le $mayor_tam_par ]]
		then
			EN_MEMO[$pr]="Si"															#Cambia el estado del proceso.
			PART[$pr]=$part_vacia_mayor 												#Asigna la partición al proceso.
			PROC[$part_vacia_mayor]=$pr 												#Asigna el proceso a la partición.
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

### Copia estados para compararlo con el estado del mismo proceso más tarde y ver si este ha cambiado.
copiar_estados()
{
	for(( pr=0; pr<$num_proc; pr++ ))
	do
		ESTADOANT[$pr]=${ESTADO[$pr]}
	done
}

### Comparación de si un proceso ha cambiado de estado para pausar el algoritmo (Y pulsar intro para seguir, o esperar, o esperar un instante, dependiendo de lo elegido)
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

	contador=0
	pvez=0
	ultvez=0
	nulcontrol=0
	escritos=0

	inicializar	#Setea valores iniciales.
	proc_ante=$proc_actual	#Actualizo la referencia de proceso anterior.																					

	calcularcol

	#El bucle se repite hasta que no queden procesos por ejecutar
	while [ $procesos_terminados -lt $num_proc ]
	do
		calcularcol
		cola_act=0
		meterenmemo
		cola
		proc_ante=$proc_actual	#Actualizo la referencia de proceso anterior.
		proc_actual=${colaprocs[0]}

		copiar_estados
		asignar_estados
		comparar_estados

		actualizar_bt

		#Ahora aparece en el texto de la BT un proceso y el tiempo transcurrido si termina su quántum, aunque sea el unico proceso en memoria.
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
		let tiempo_transcurrido=tiempo_transcurrido+1


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
			let procesos_terminados=procesos_terminados+1
		fi
	done

	actualizar_bt

	ultvez=1
	tabla_ejecucion
}



if [[ -e archivo.temp ]]
then
	rm archivo.temp
fi
if [[ -e ./Informes/informeCOLOR.txt ]]
then
	rm ./Informes/informeCOLOR.txt
fi
if [[ -e ./Informes/informeBN.txt ]]
then
	rm ./Informes/informeBN.txt
fi

#Inicio del script (Con alumno nuevo 2022) para los 2 informes.
clear
echo "---------------------------------------------------------------------" >> ./Informes/informeCOLOR.txt
echo "|                                                                   |" >> ./Informes/informeCOLOR.txt
echo "|                         INFORME DE PRÁCTICA                       |" >> ./Informes/informeCOLOR.txt
echo "|                         GESTIÓN DE PROCESOS                       |" >> ./Informes/informeCOLOR.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeCOLOR.txt
echo "|     Antiguo alumno:                                               |" >> ./Informes/informeCOLOR.txt
echo "|     Alumno: Mario Juez Gil                                        |" >> ./Informes/informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeCOLOR.txt
echo "|     Grado en ingeniería informática (2012-2013)                   |" >> ./Informes/informeCOLOR.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeCOLOR.txt
echo "|     Alumno: Omar Santos Bernabe                                   |" >> ./Informes/informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeCOLOR.txt
echo "|     Grado en ingeniería informática (2014-2015)                   |" >> ./Informes/informeCOLOR.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeCOLOR.txt
echo "|     Alumnos:                                                      |" >> ./Informes/informeCOLOR.txt
echo "|     Alumno: Alvaro Urdiales Santidrian                            |" >> ./Informes/informeCOLOR.txt
echo "|     Alumno: Javier Rodriguez Barcenilla                           |" >> ./Informes/informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeCOLOR.txt
echo "|     Grado en ingeniería informática (2015-2016)                   |" >> ./Informes/informeCOLOR.txt
echo "|                                                                   |" >> ./Informes/informeCOLOR.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeCOLOR.txt
echo "|     Alumno: Gonzalo Burgos de la Hera                             |" >> ./Informes/informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeCOLOR.txt
echo "|     Grado en ingeniería informática (2019-2020)                   |" >> ./Informes/informeCOLOR.txt
echo "|                                                                   |" >> ./Informes/informeCOLOR.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeCOLOR.txt
echo "|     Alumno: Lucas Olmedo Díez                                     |" >> ./Informes/informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeCOLOR.txt
echo "|     Grado en ingeniería informática (2021-2022)                   |" >> ./Informes/informeCOLOR.txt
echo "|                                                                   |" >> ./Informes/informeCOLOR.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeCOLOR.txt
echo "|     Alumno: Miguel Díaz Hernando                                  |" >> ./Informes/informeCOLOR.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeCOLOR.txt
echo "|     Grado en ingeniería informática (2022-2023)                   |" >> ./Informes/informeCOLOR.txt
echo "|                                                                   |" >> ./Informes/informeCOLOR.txt
echo "---------------------------------------------------------------------" >> ./Informes/informeCOLOR.txt
echo "" >> ./Informes/informeCOLOR.txt
echo "---------------------------------------------------------------------" >> ./Informes/informeBN.txt
echo "|                                                                   |" >> ./Informes/informeBN.txt
echo "|                         INFORME DE PRÁCTICA                       |" >> ./Informes/informeBN.txt
echo "|                         GESTIÓN DE PROCESOS                       |" >> ./Informes/informeBN.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeBN.txt
echo "|     Antiguo alumno:                                               |" >> ./Informes/informeBN.txt
echo "|     Alumno: Mario Juez Gil                                        |" >> ./Informes/informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeBN.txt
echo "|     Grado en ingeniería informática (2012-2013)                   |" >> ./Informes/informeBN.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeBN.txt
echo "|     Alumno: Omar Santos Bernabe                                   |" >> ./Informes/informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeBN.txt
echo "|     Grado en ingeniería informática (2014-2015)                   |" >> ./Informes/informeBN.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeBN.txt
echo "|     Alumnos:                                                      |" >> ./Informes/informeBN.txt
echo "|     Alumno: Alvaro Urdiales Santidrian                            |" >> ./Informes/informeBN.txt
echo "|     Alumno: Javier Rodriguez Barcenilla                           |" >> ./Informes/informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeBN.txt
echo "|     Grado en ingeniería informática (2015-2016)                   |" >> ./Informes/informeBN.txt
echo "|                                                                   |" >> ./Informes/informeBN.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeBN.txt
echo "|     Alumno: Gonzalo Burgos de la Hera                             |" >> ./Informes/informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeBN.txt
echo "|     Grado en ingeniería informática (2019-2020)                   |" >> ./Informes/informeBN.txt
echo "|                                                                   |" >> ./Informes/informeBN.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeBN.txt
echo "|     Alumno: Lucas Olmedo Díez                                     |" >> ./Informes/informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeBN.txt
echo "|     Grado en ingeniería informática (2021-2022)                   |" >> ./Informes/informeBN.txt
echo "|                                                                   |" >> ./Informes/informeBN.txt
echo "|             -------------------------------------------           |" >> ./Informes/informeBN.txt
echo "|     Alumno: Miguel Díaz Hernando                                  |" >> ./Informes/informeBN.txt
echo "|     Sistemas Operativos 2º Semestre                               |" >> ./Informes/informeBN.txt
echo "|     Grado en ingeniería informática (2022-2023)                   |" >> ./Informes/informeBN.txt
echo "|                                                                   |" >> ./Informes/informeBN.txt
echo "---------------------------------------------------------------------" >> ./Informes/informeBN.txt
echo "" >> ./Informes/informeBN.txt


imprime_cabecera_larga
lee_datos

#Guardado incondicional en datosLast.txt.
meterAfichero DatosLast
mv ./FDatos/DatosLast.txt ./FLast
if [[ $dat_fich -ge 4 ]]
then
	meterAficheroRangos DatosRangosLast
	mv ./FRangos/DatosRangoslast.txt ./FLast
fi
if [[ $dat_fich -ge 7 ]]
then
	meterAficheroRangosAleatorios DatosRangosAleatoriosLast
	mv ./FRangosAleatorios/DatosRangosAleatoriosLast.txt ./FLast
fi

#Condicional que determinará el guardado de los datos manuales.
if [[ $opcion_guardado_datos -eq 1 || $nombre_fichero_datos == "DatosDefault" ]]
then
		meterAfichero DatosDefault
elif [[ $opcion_guardado_datos -eq 2 ]] && [[ $nombre_fichero_datos != "DatosDefault" ]]
then
		meterAfichero "$nombre_fichero_datos"
fi

if [[ $opcion_guardado_datos_rangos -eq 1 || $nombre_fichero_datos_rangos == "DatosRangosDefault" ]]
then
		meterAficheroRangos DatosRangosDefault
elif [[ $opcion_guardado_datos_rangos -eq 2 ]] && [[ $nombre_fichero_datos_rangos != "DatosRangosDefault" ]]
then
		meterAficheroRangos "$nombre_fichero_datos_rangos"
fi

if [[ $opcion_guardado_datos_rangos_aleatorios -eq 1 || $nombre_fichero_datos_rangos_aleatorios == "DatosRangosAleatoriosDefault" ]] 
then
	meterAficheroRangosAleatorios DatosRangosAleatoriosDefault
elif [[ $opcion_guardado_datos_rangos_aleatorios -eq 2 ]] && [[ $nombre_fichero_datos_rangos_aleatorios != "DatosRangosAleatoriosDefault" ]]
then
	meterAficheroRangosAleatorios "$nombre_fichero_datos_rangos_aleatorios"
fi


clear
echo "      > ROUND ROBIN" >> ./Informes/informeCOLOR.txt
echo "      > ROUND ROBIN" >> ./Informes/informeBN.txt

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


clear

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
	cat ./Informes/informeBN.txt
fi

read -p " ¿Quieres abrir el informe a color? ([s],n): " datos_color

while [ "${datos_color}" != "" -a "${datos_color}" != "s" -a "${datos_color}" != "n" ]
do
	read -p "Entrada no válida, vuelve a intentarlo. ¿Quieres abrir el informe a Color? ([s],n): " datos_color
done

if [[ $datos_color = "s" || $datos_color = "" ]]
then
	cat ./Informes/informeCOLOR.txt
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