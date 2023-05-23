#!/bin/bash

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

 	read -p "fichero leido y copiado" x 

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
						read -p "close"
					;;
				esac

				let dat_proc_leidos=dat_proc_leidos+1
			done

			let num_proc=num_proc+1 #Suma el número de procesos leídos.
		fi
		let n_linea=n_linea+1 #Suma el número de líneas leídas.
	done < $fich

	rm $fich
}



lectura_fichero "datos.txt"

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