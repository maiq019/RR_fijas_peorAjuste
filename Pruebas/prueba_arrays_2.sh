#!/bin/bash

array=""
tam=4

for (( pos=0; pos<10; pos++ ))
do
	for (( esp=0; esp<$tam; esp++ ))
	do
		array[$pos]=${array[$pos]}"$pos"
	done
	array[$pos]=${array[$pos]}" "
done

echo ${array[@]}

read -p "close" x