#!/bin/bash

# HDD Tester Xtreme (HTX)
# Author: John Sanderson
# Email: john.sanderson@siliconmechanics.com
# Copyright (c) 2014 Silicon Mechanics, Inc.
# Version: v1.1-240SX

# !! This version is propriety for 240sx.support.simech.com

# Needed Tools:
# sginfo
# lsblk
# smartctl

if [ ! `command -v sginfo` ] || [ ! `command -v lsblk` ] || [ ! `command -v smartctl` ] || [ ! `command -v badblocks` ]; then
	echo "Script could not locate one or more of the following:"
	echo "sginfo"
	echo "lsblk"
	echo "smartctl"
	echo "badblocks"
	echo "These are required for the script to operate."
	exit
fi

# check for root user
if [ ! $UID -eq 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# vars
trap ctrl_c INT

red='\e[1;31m'
green='\e[1;32m'
nc='\e[0;39m'

# scp
# boost.support.simech.com is hosted on brz/frs nexentastor appliances
server="boost.support.simech.com"
rdir="/volumes/pool0/support/HDD_Logs/"

error_bail () {
	echo "$1 somehow failed. Check htx.log.";
}

ctrl_c() {
	# kill SMART tests if script is exited
	for i in "${devices[@]}"; do
		hdd_data
		smartctl -X /dev/$i &> htx.log
	done
	echo
	echo "Script terminated early. Test(s) canceled."
	cleanup
	exit 1
}

cleanup () {
	#rm sd*.bb &> /dev/null
	#rm *-badblocks.txt &> /dev/null
	#rm *-SMART.txt &> /dev/null
	#rm *-bb.tmp 
echo ""
}

test_status () {
for i in "${devices[@]}"; do
if [ "`smartctl -l selftest /dev/$i | grep NOW`" ] || [ "`ps aux | grep "[b]adblocks -v.* /dev/$i"`" ] ; then
	echo -e "${red}Test already in progress on /dev/$i. Skipping.${nc}"
	devices=(${devices[@]//$i*})
fi
done
}

check_devices () {
	if [ ${#devices[@]} = 0 ]; then
    echo "No valid devices. Exiting."
    exit 1
fi
}

hdd_data () {
		# figure out serial
		serial=(`sginfo -s /dev/$i | grep "Serial" | cut -c 15- | grep [a-zA-Z0-9] | tr -d "'"`)
		# figure out model
		model=`sginfo /dev/$i | grep "Product" | cut -c 9- |sed -e 's/^ *//' -e 's/ *$//'`
		# figure out enclosure/slot

}

locate () {
	for i in "${devices[@]}"; do
	hdd_data
	echo "Do you want to turn blink on or off for /dev/$i? (on/off)"
	read onoff
	if [[ "$onoff" == "on" ]] || [[ "$onoff" == "off" ]]; then
	lserial=(`echo $serial | cut -c1-8`)
	locate_data $lserial $onoff
	if [[ "$onoff" == "on" ]]; then
		echo "Blink turned ON for /dev/$i."
	else
		echo "Blink turned OFF for /dev/$i."
	fi
else
	echo 'Invalid entry. Please specify "on", or "off"'
	exit 1
fi
done
exit 1
}

locate_data () {
	# $1 = serial $2 = on/off
	enclosure=(`sas2ircu 0 DISPLAY | grep -B 8 "${1}" | awk '/Enclosure #.*:.*[0-9]/ {print $4}'`)
	slot=(`sas2ircu 0 DISPLAY | grep -B 8 "${1}" | awk '/Slot #.*:.*[0-9]/ {print $4}'`)
	sas2ircu 0 locate $enclosure:$slot $2 &> htx.log
}

verify () {
for i in "${string[@]}"; do
	if [[ `ls /dev/$i 2>/dev/null` ]]; then
		devices+=($i)
	else
		echo -e "${red}/dev/$i doesn't exist. Skipping.${nc}"
	fi
done
}

# alternative way to gather data
#gather_data () {
#IFS=$'\n'
#hdd_info=(`sas2ircu 0 DISPLAY | awk '/Slot #.*:.*[0-9]/ {slot=$4} /Model Number.*:.*[a-ZA-Z0-9]/ {model=$4$5} /Serial No.*:.*[a-ZA-Z0-9]/ {serial=$4$5} /Protocol.*:.*[a-zA-Z]/ {print enclosure, slot, model, serial, $3}' | grep -Ev 'SAS2X36'`)
#unset IFS
#}

#list_hdd () {
#	echo "Device listing:"
#	for i in "${hdd_info[@]}"; do
#		words=(`echo $i`)
#		printf "     Slot: %s Model: %s Serial: %s Interface: %s\n" ${words[0]} ${words[1]} ${words[2]} ${words[3]}
#	done
#}



dev_info () {
	echo "Device: /dev/$i"
	echo "Model: $model"
	echo "Serial: $serial"
}

list_hdd () {
for i in "${devices[@]}"; do
	hdd_data
	dev_info
	echo
done
}

smart_health (){
for i in "${devices[@]}"; do
	hdd_data
	#sas
	if [[ `smartctl -H /dev/$i | grep 'SMART Health Status: OK'` ]]; then
		echo
		dev_info
		echo -e "SMART Health: ${green}OK${nc}"
		smart_errors
		echo
	#sata
	elif [[ `smartctl -H /dev/$i | grep 'PASSED'` ]]; then
		echo
		dev_info
		echo -e "SMART Health: ${green}OK${nc}"
		smart_errors
		echo
	else
	#failed
		echo
		dev_info
		echo -e "SMART Health: ${red}FAILED${nc}"
		smart_errors
		echo
	fi
done
}

badblocks_health () {
for i in "${devices[@]}"; do
	hdd_data
		if [ -s ${serial}-badblocks.txt ]; then
			echo
			dev_info
			echo -e "Badblocks test: ${red}FAILED!${nc} Check log file."
		else
			echo
			dev_info
			echo -e "Badblocks test: ${green}PASSED${nc}"
		fi
done
}

smart_errors () {
errors=(`smartctl -l error /dev/$i | awk '/Non-medium error count/ {print $4}' | bc`)
if [[ $errors -gt 500 ]]; then
	echo -e "${red}Drive Non-medium error count is high: $errors ${nc}"
	echo -e "${red}RMA Drive.${nc}"
fi
}

usage () {
	echo
	echo "HDD Tester Xtreme (HTX)"
	echo
	echo "Usage:"
	echo "-a       Run commands on all devices"
	echo "-d       Specify specific device(s)"
	echo "-l       List device/model/serial"
	echo "-f       Blink specified device"
	echo
	echo "-s       SMART test"
	echo "-b       Badblocks test"
	echo
	echo "Example: htx -s -d 'sdb sdc'"
	echo
	exit
}


# read script opts
while getopts "aslbd:f:" options; do
  case $options in
a)
	a=1
	d=0
	devices=(`lsblk |awk '/^sd./' |grep -o sd[b-z]`)
;;
s)
	s=1
;;
l)
	l=1
	devices=(`lsblk |awk '/^sd./' |grep -o sd[b-z]`)
;;
b)
	b=1
;;
d)
	d=1
	a=0
	devices=()
	string=(`echo $OPTARG | tr ' ' '\n'`)
;;
f)
	f=1
	devices=()
	string=(`echo $OPTARG | tr ' ' '\n'`)
;;
\?)
usage
exit 1
;;
:)
echo "Option -$OPTARG requires an argument." >&2
exit 1
;;
  esac
done

# no flags
if [ -z $1 ]; then
	usage
fi

# list hdds if -l
if [ "$l" == "1" ]; then
	list_hdd
	exit 1
fi

# locate if -f
if [ "$f" == "1" ]; then
	verify
	check_devices
	locate
	exit 1
fi

# make sure user specifies -a or -d, unless -f is specified
if [[ "$f" != "1" ]]; then
if [[ -z $a ]] || [[ -z $d ]]; then
	echo
	echo -e "${red}You didn't specify any devices to test!${nc}"
	usage
	exit 1
fi
fi


if [[ `echo $@ |grep -e "-d" | grep -e "-a"` ]]; then
	echo
	echo -e "${red}You can't specify '-a' and '-d'!${nc}"
	usage
	exit 1
fi

verify
check_devices

# before doing any tests, check to see if any drives are undergoing tests
test_status

# start smart test if -s
if [ "$s" == "1" ]; then

	# begin smart checks
		for i in "${devices[@]}"; do
			smartctl -t short /dev/$i &> htx.log
		done
		echo "SMART test(s) started on: ${devices[@]}"
		echo "Please wait..."

	# wait for test to complete
	for i in "${devices[@]}"; do
		while [[ `smartctl -l selftest /dev/$i | grep NOW` ]]; do
			sleep 1
		done
	done

	echo
	echo "SMART Health:"
	smart_health

	# ship smart data
	for i in "${devices[@]}"; do
		hdd_data
	        smartctl -a /dev/$i > ${serial}-SMART.txt
	        ssh $server "mkdir -p /volumes/pool0/support/HDD_Logs/$serial"
	        scp "${serial}-SMART.txt" "$server:$rdir$serial" &> htx.log
	        if [ $? != 0 ]; then
				error_bail "Transferring SMART log(s)"
			fi
	        rm ${serial}-SMART.txt &> htx.log
	done
echo "SMART data transferred to storage."
fi

if [ "$b" == "1" ]; then
	for i in "${devices[@]}"; do
	hdd_data
	badblocks -v -o ${serial}-badblocks.txt /dev/$i &> $i-bb.tmp &
	bb_pid=$!
	pid_array+=($bb_pid)
	echo $bb_pid > $i-pid-bb.tmp
	done
	echo "Badblock test(s) started on: ${devices[@]}"
	declare -A a_devices
	#a_devices="${devices[@]}"
		while ps -p ${pid_array[@]} > /dev/null; do
			for i in "${devices[@]}"; do
				bbp=("`cat $i-bb.tmp |grep -oh ".[0-9]..[0-9]%.*errors)" |sort -n|tail -1`")
				a_devices[$i]="$bbp"
				#echo -ne " /dev/$i $bbp"\\r
			done
			for i in "${!a_devices[@]}"; do
				#echo "key  : $i"
				#echo "value: ${a_devices[$i]}"
				pid=(`cat $i-pid-bb.tmp`)
				if ps -p $pid > /dev/null; then
				echo -n -e " /dev/$i ${a_devices[$i]}\r"
				#printf "/dev" "$i" "${a_devices[$i]}"\r
				#printf "/dev/%s %s" $i ${a_devices[$i]}
				fi
				sleep 1
			done
		done

	echo "Badblocks test(s) finished."
	badblocks_health

	# ship badblocks data
	for i in "${devices[@]}"; do
		hdd_data
	        ssh $server "mkdir -p $rdir$serial"
	        scp "${serial}-badblocks.txt" "$server:$rdir$serial" &> htx.log
			if [ $? != 0 ]; then
				error_bail "Transferring badblocks log(s)"
			fi
			rm ${serial}-badblocks.txt &> htx.log
	done
			echo "Badblocks data transferred to storage."
	fi

cleanup