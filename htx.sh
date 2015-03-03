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
server="10.21.1.8"
rdir="/volumes/pool0/support/HDD_Logs/"

#work dir
workdir="/tmp/htx/$$"
mkdir -p $workdir

#log=
log="$workdir/htx.log"

error_bail () {
	echo "$1 somehow failed. Check $log";
}

clearlastline() {
        tput cuu 1 && tput el
}

countdown () {
secs=$1
while [ $secs -gt 0 ]; do
   echo "${2:-} $secs seconds"
   sleep 1
   clearlastline
   : $((secs--))
done
}

ctrl_c() {
	# kill SMART tests if script is exited
	for i in "${devices[@]}"; do
		hdd_data
		smartctl -X /dev/$i &> $log
	done
	echo
	echo "Script terminated early. Test(s) canceled."
	cleanup
	exit 1
}

cleanup () {
	rm -rf $workdir &> /dev/null
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
	serial=(`sginfo -s /dev/$i | awk '/Serial Number/ {print $4}' | sed "s/'/ /g"`)
	# figure out model
	model=`sginfo -i /dev/$i | awk '/Product:/ {print $2}'`
	# figure out enclosure/slot
	# something something something
	# firmware rev
	firmware=(`sginfo -i /dev/$i | awk '/Revision level/ {print $3}'`)

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
	sas2ircu 0 locate $enclosure:$slot $2 &> $workdir
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
	echo "Firmware: $firmware"
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
		if [ -s $workdir/${serial}-badblocks.txt ]; then
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
	echo -e "${red}If this is a Seagate drive, RMA it. Otherwise, ignore.${nc}"
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
	echo "-p       Performance test"
	echo
	echo "Example: htx -s -b -p -d 'sdb sdc'"
	echo
	exit
}


# read script opts
while getopts "aslbpd:f:" options; do
  case $options in
a)
	a=1
	d=0
	devices=(`lsblk | grep -vE '465.8G|^--$' | awk '/^sd.*/ {print $1}'`)
;;
s)
	s=1
;;
p)
	p=1
;;
l)
	l=1
	devices=(`lsblk | grep -vE '465.8G|^--$' | awk '/^sd.*/ {print $1}'`)
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
			smartctl -t short /dev/$i &> $log
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
	        smartctl -a /dev/$i > $workdir/${serial}-SMART.txt
	        ssh $server "mkdir -p /volumes/pool0/support/HDD_Logs/$serial"
	        scp "$workdir/${serial}-SMART.txt" "$server:$rdir$serial" &> $log
	        if [ $? != 0 ]; then
				error_bail "Transferring SMART log(s)"
			fi
	        rm $workdir/${serial}-SMART.txt &> $log
	done
	echo "SMART data transferred to storage."
fi

if [ "$b" == "1" ]; then
	for i in "${devices[@]}"; do
	hdd_data
	badblocks -b 4096 -c 300000 -p 0 -v -w -o $workdir/${serial}-badblocks.txt -s /dev/$i &> $workdir/$i-bb.tmp &
	bb_pid=$!
	pid_array+=($bb_pid)
	echo $bb_pid > $workdir/$i-pid-bb.tmp
	done
	echo "Badblock test(s) started on: ${devices[@]}"
	declare -A a_devices
	#a_devices="${devices[@]}"
	#cat $workdir/$i-bb.tmp |grep -oh ".[0-9]..[0-9]%.*errors)" |sort -n|tail -1
		while ps -p ${pid_array[@]} > /dev/null; do # while a pid exists that badblocks created
			for i in "${devices[@]}"; do # this container checks the file and updates below var to the current % done elapsed and error count
				bbp=("`cat $workdir/$i-bb.tmp |grep -oh ".[0-9]..[0-9]%.*errors)" |sort -n|tail -1`") # assigns % done, elapsed, and error count to var
				a_devices[$i]="$bbp" # adds each device we are testing to "a_devices" var array
			done
			for i in "${!a_devices[@]}"; do # for each item in array
				pid=(`cat $workdir/$i-pid-bb.tmp`) # badblocks pid
				if ps -p $pid > /dev/null; then # if badblocks pid exists
					echo "/dev/$i ${a_devices[$i]}" # echo device current status
				fi
			done 
			countdown 30 "Refreshing in" # refresh display every 30 seconds
			for i in "${!a_devices[@]}"; do # clean screen
				tput cuu1 # move mouse up 1 line
				tput el # delete line
			done
		done

	echo "Badblocks test(s) finished."
	badblocks_health

	# ship badblocks data
	for i in "${devices[@]}"; do
		hdd_data
	        ssh $server "mkdir -p $rdir$serial"
	        scp "$workdir/${serial}-badblocks.txt" "$server:$rdir$serial" &> $log
			if [ $? != 0 ]; then
				error_bail "Transferring badblocks log(s)"
			fi
			rm $workdir/${serial}-badblocks.txt &> $log
	done
			echo "Badblocks data transferred to storage."
fi


perf_results () {
for i in "${devices[@]}"; do
	hdd_data
	echo
	dev_info
	ws=$(cat $workdir/$i-pt-w.out | awk '/bytes/ {print $8, $9}')
	rs=$(cat $workdir/$i-pt-r.out | awk '/bytes/ {print $8, $9}')
	echo -e "Write Speed: ${green}${ws}${nc}"
	echo -e "Read Speed: ${green}${rs}${nc}"
	echo
done
}

# performance test if -p
if [ "$p" == "1" ]; then
	echo "[BETA] Performance test(s) started on: ${devices[@]}"
	echo "Please wait..."
	for i in "${devices[@]}"; do
		hdd_data
		hide="if"
		dd ${hide}=/dev/$i of=$workdir/${i}_testfile bs=1M count=100 oflag=dsync &> $workdir/$i-pt-w.out &
		#echo "dd ${hide}=/dev/$i of=$workdir/$i_testfile bs=1M count=256 oflag=dsync &> $workdir/$i-pt-w.out"
		ptw_pid=$!
		ptw_pid_array+=($ptw_pid)
	done
	wait
	for i in "${devices[@]}"; do
		dd ${hide}=$workdir/${i}_testfile of=/dev/$i bs=1M count=100 oflag=dsync &> $workdir/$i-pt-r.out &
		#echo "dd ${hide}=/usr/bin/pt_testfile of=/dev/$i bs=1M count=256 oflag=dsync &> $workdir/$i-pt-r.out"
		ptr_pid=$!
		ptr_pid_array+=($ptr_pid)
		echo $ptw_pid > $workdir/$i-pt-w.pid
		echo $ptr_pid > $workdir/$i-pw-r.pid
	done
	wait
	#echo "PTW ARRAY"
	#echo ${ptw_pid_array[@]}
	#echo "PTR ARRAY"
	#echo ${ptr_pid_array[@]}
	#echo "PT READ"
	#ps -p ${ptr_pid_array[@]}
	#echo "PT WRITE"
	#ps -p ${ptw_pid_array[@]}

	echo "Performance test(s) finished."
	perf_results
fi

cleanup
