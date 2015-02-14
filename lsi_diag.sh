#!/usr/bin/bash
# this script will collect diagnostic information from lsi hba's using lsiutil
# date: 1/20/14
# filename: lsi_diag.sh
# 'lsiutil' required in script directory

program="lsiutil" #lsiutil is needed
script="lsi_diag" #script name
node=$(hostname) #hostname
now=$(date +"%Y-%m-%d-%H-%M-%S-%Z") #date
log="$script-$node-$now.log" #logfile


if [ -f $program ]; then
	hba_count=$(./lsiutil < /dev/null |awk '/MPT Port.* found/ {print $1}') # hba count
	hba_count=$((hba_count))
	echo "HBA Count: $hba_count" >> $log
	echo "" | ./lsiutil >> $log
	while [ "$hba_count" -gt "0" ]; do
		hba_num=$((hba_count)) # set current hba we working with
		echo "12" | ./lsiutil -p $hba_num 20 >> $log # phy counters (diagnostics/errors)
		echo "HBA $hba_num Diagnostics/Error Count logged"
		./lsiutil -p $hba_num -i -s >> $log # port settings, targets, firmware
		echo "HBA $hba_num Settings/Firmware/Targets logged"
		hba_count=$(($hba_count - 1)) # count down
	done
	echo "Output file: $log"
else
	echo "'$program' not in script directory, exiting" # 'lsiutil' was not found in directory?
	exit 1
fi