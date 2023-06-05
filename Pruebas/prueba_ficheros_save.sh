#!/bin/bash

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

	mv "$1".txt ./DatosPrueba
}


read -p "introduzca número de particiones: " n_par

for (( pa=0; pa<n_par; pa++ ))
do
	read -p "introduzca tamaño de particion $(($pa+1)): " tam_pa
	tam_par[pa]=$tam_pa 
done

read -p "introduzca quántum: " quantum

echo ""
echo -e " Número de particiones: $n_par\n"
echo -e " Tamaño de particiones: ${tam_par[@]}\n"
echo -e " Quantum:               $quantum\n"
echo ""
read -p "meter a fichero (enter)" x 

meterAfichero DatosPrueba

