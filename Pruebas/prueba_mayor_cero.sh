#!/bin/bash

mayor_cero()
{
	if ! [[ $1 =~ ^[1-9][0-9]*$ ]]
	then
		return 1
	else
		return 0
	fi
}

read -p "introduce un numero: " numero
while ! mayor_cero $numero
do
	echo "No valido, introduce numero"
	read numero
done

echo "numero: $numero"
read -p "close" x