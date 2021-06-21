#!/bin/bash
# ram.sh
# Anderson Morais
# Jan/12/2017 - Jun/20/2021
# clears the cache every 30 minutes and writes the amount of memory used

## who am i? ##
script_path=$(readlink -f ${BASH_SOURCE[0]})
 
## delete last component from $script_path - script name ##
## directory of the logs is the same where the script is ##
dir_d="$(dirname $script_path)/logs/"

## name of the log's file ##
## one file per day ##
file_f="$(date '+d%dm%my%Y').txt"

## in Gigabytes ##
# swap_in_use=$(swapon --show | awk '{ print $4 }' | tail -n 1)
## in Megabytes ##
swap_in_use=$(free -m | awk '{ print $3 }' | tail -n 1)
swap_in_use=${swap_in_use//[!0-9]}

## entire path to log file ##
path_p="${dir_d}${file_f}"

## Swappiness is the kernel parameter that defines how much (and how often) ##
## your Linux kernel will copy RAM contents to swap. ##
swappiness_s=$(cat /proc/sys/vm/swappiness)

## it will be true if log's file exists
file_exist=false

if ! test -d ${dir_d}; then
	mkdir "${dir_d}"
fi
if ! test -f ${path_p}; then
	touch "${path_p}"
fi

if test -f ${path_p}; then
	file_exist=true
	date '+%Hh%Mm%Ss' >> ${path_p}
	echo "Swappiness: ${swappiness_s}" >> ${path_p}	
fi

if [[ ${swap_in_use} -ge 1000 ]]; then
	if ${swappiness} -ge 15; then
		# reduces the use of swap
		sysctl vm.swappiness=15
		# cache
		sysctl vm.vfs_cache_pressure=50
	fi

	if ${file_exist}; then
		echo "Swappiness after reduced size: $(cat /proc/sys/vm/swappiness)" >> ${path_p}		
		echo 'Memory before clean:' >> ${path_p}
		free -m >> ${path_p}
		echo '' >> ${path_p}
	fi

	## turn off swap ##
	swapoff -a
	## saves the cache in the disc ##
	sync
	## clean the cache ##
	sysctl -w vm.drop_caches=3 
	swapon -a

	if ${file_exist}; then
		echo 'Memory after clean:' >> ${path_p}
		## write the ram used at the moment ##
		free -m >> ${path_p}
	fi		
else
	if ${file_exist}; then
		echo 'Swap OK' >> ${path_p}
	fi
fi

if ${file_exist}; then
	echo "------------------------------- ------------------------------" >> ${path_p}
fi

# free -m