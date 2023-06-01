#!/bin/bash

cad_pro=""
cad_tie_col=""
tam_unidad_bt=5

### Actualiza la cadena de cuadraditos de la barra de tiempo añadiendo otra unidad de tiempo.
actualizar_bt_linea()
{
	color=(96 95 94 92 91)
	if [[ $proc_actual -ne 0 ]] 																			#Si hay un proceso en ejecución,
	then
		
		colimp=$(($proc_actual-1))

		for(( esp=0; esp<$tam_unidad_bt-3; esp++ ))															#Por lo que ocupa la unidad,
		do
			cad_pro[$tiempo_transcurrido]=${cad_pro[$tiempo_transcurrido]}" "
		done
		cad_pro[$tiempo_transcurrido]=${cad_pro[$tiempo_transcurrido]}"  \e[${color[$colimp]}mP0$proc_actual\e[0m"

		for(( esp=0; esp<$tam_unidad_bt; esp++ ))															#Por lo que ocupa la unidad,
		do
			cad_tie_col[$tiempo_transcurrido]=${cad_tie_col[$tiempo_transcurrido]}"\e[${color[$colimp]}m\u2588\e[0m"	#Añado un cuadrado de color a la cadena de color.
		done
		
	else 																									#Si no hay un proceso en ejecución,
		for (( esp=0; esp<$tam_unidad_bt; esp++ ))															#Por cada hueco hasta completar la unidad,
		do
			cad_pro[$tiempo_transcurrido]=${cad_pro[$tiempo_transcurrido]}" "
			cad_tie_col[$tiempo_transcurrido]=${cad_tie_col[$tiempo_transcurrido]}"\u2588"					#Añado un cuadrado blanco.
		done
	fi
}

Tej=10
tiempo_transcurrido=0

while [[ $tiempo_transcurrido -le $Tej ]]
do
	proc_actual=`shuf -i 0-5 -n 1`
	echo ""
	echo "iteración $tiempo_transcurrido"
	echo "tamaño de cadena: ${#cad_tie_col[@]}"
	echo "proceso $proc_actual"
	
	actualizar_bt_linea

	echo -n "    |"
	for (( uni=0; uni<=$tiempo_transcurrido; uni++ ))
	do
		echo -ne "${cad_pro[$uni]}"
	done
	echo "|"

	echo -n " BT |"
	for uni in ${cad_tie_col[@]}
	do
		echo -ne $uni
	done
	echo -e "| T=$tiempo_transcurrido"

	let tiempo_transcurrido=tiempo_transcurrido+1
	
	echo ""
	read -p "continuar" x
done

read -p "close" x