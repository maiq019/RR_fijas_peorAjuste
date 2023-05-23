#!/bin/bash

#pregunta si se desea introducir mas datos a la función
new_proc()
{
	read -p "¿desea intoducir un proceso nuevo? ([s]/n) " proc_new

	while [ "${proc_new}" != "" -a "${proc_new}" != "s" -a "${proc_new}" != "n" ]
	do
		read -p "Entrada no válida, vuelve a intentarlo. ¿desea intoducir un proceso nuevo? ([s]/n) " proc_new
	done	 
}

procesos_ejecutables=0

while [[ $proc_new = "s" || $proc_new = "" ]]
do
	let procesos_ejecutables=procesos_ejecutables+1
	echo "número de procesos: $procesos_ejecutables"
	new_proc
done

echo "pulse cualquier tecla para salir"
read x