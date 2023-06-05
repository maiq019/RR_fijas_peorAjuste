#!/bin/bash

contiene()
{
    local n=$#
    local value=${!n}

    for (( i=1; i<$#; i++ )) 
    do
        if [ "${!i}" == "${value}" ]
        then
        	echo "y"
            return 0
        fi
    done
    echo "n"
    return 1
}

lectura_fichero()
{
	cp ./DatosPrueba/"$1" copia.txt
	fich="copia.txt"

	cat $fich

	rm $fich 
}

ls ./DatosPrueba | grep .txt | grep -v informeBN.txt | grep -v informeCOLOR.txt > listado.temp
cat listado.temp

read -p " Elija un fichero de la lista: " fich

while [ ! -f ./DatosPrueba/"$fich" ] #Si el fichero no existe, lectura erronea.
do
	echo " Entrada no válida, el fichero no se ha encontrado o no existe"
	echo -n " Introduce uno de los ficheros del listado:"
	read fich
done

#Lectura de los datos del fichero.
rm -r listado.temp #Borra el temporal.
#Lectura de los datos del fichero.
lectura_fichero "$fich"