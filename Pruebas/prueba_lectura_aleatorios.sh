#!/bin/bash

### Lee los datos desde un fichero de rangos.
lectura_fichero_aleatorio()
{
	n_linea=0
	num_proc=0
	linea=0
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

	echo $fich

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
		T_ENTRADA_I[$i]=`shuf -i $entrada_min-$entrada_max -n 1`
		PROCESOS_I[$i]=`shuf -i $rafaga_min-$rafaga_max -n 1`
		MEMORIA_I[$i]=`shuf -i $memo_proc_min-$memo_proc_max -n 1`
	done

	rm $fich
}


lectura_fichero_aleatorio "datosrangosRNG.txt"

read -p "fichero interpretado" x

echo "Número de particiones: $n_par"
read -p "" x
echo "tamaño de particiones: ${tam_par[@]}"
read -p "" x
echo "Quántum: $quantum"
read -p "" x
echo " "
echo "Nproceso  Llegada  ráfaga  memoria"
for (( pr=0; pr<num_proc; pr++ ))
do
	echo "  $pr       ${T_ENTRADA_I[$pr]}        ${PROCESOS_I[$pr]}       ${MEMORIA_I[$pr]}"
done

read -p "close" x