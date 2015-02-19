#!/bin/bash
now=$(date +"%Y-%m-%d-%H-%M-%S-%Z")
script="smux-fw-flash"
hostname=`hostname`
version="2.0"
log="$script-$hostname-$now.log"

# author: john sanderson
# https://github.com/jjsx
# date: 2/14/15
# this script is to be used to hdd firmware on nexenta/solaris using smartmon-ux
# smux-fw-flash.sh

# DO NOT EDIT!! DO NOT EDIT!! DO NOT EDIT!! DO NOT EDIT!! DO NOT EDIT!! DO NOT EDIT!! DO NOT EDIT!! 
# IMPROPER EDITING OF THIS SCRIPT CAN CAUSE IRREVERSIBLE HARDWARE DAMAGE. 
# DO NOT EDIT!! DO NOT EDIT!! DO NOT EDIT!! DO NOT EDIT!! DO NOT EDIT!! DO NOT EDIT!! DO NOT EDIT!! 



echo "== smartmon-ux HDD flashing script =="
echo ""
echo "This script is used to flash firmware on HDD's using smartmon-ux."
echo "Supported on OpenIndiana 151aX / NexentaStor 3.X/4.X"
echo "SATA drives are not supported, only SAS."
echo "You will be prompt to enter the name of the HDD model you wish to flash, and firmware file."
echo "A licensed copy of santools smartmon-ux is required. Default location is assumed in /usr/bin/smartmon-ux"
sleep 2
echo ""
echo "!! ONLY RUN THIS SCRIPT ONLY IF PROVIDED WITH PROPER INSTRUCTIONS !!"
echo "You are liable for any damage(s) incurred due to improper use or editing of this script."
echo ""
sleep 5

confirm () {
    read -r -p "${1:-Continue? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            exit
            ;;
    esac
}
confirm

smux="/usr/bin/smartmon-ux"


while [ ! -e $smux ]; do
	echo "smartmon-ux not found in $smux"
	echo "Enter location of smartmon-ux:"
	echo "(include '.' if current directory, i.e. './smartmon-ux', otherwise ex. '/path/to/smartmon-ux'"
	read smux
done

printf "Running device cleanup..\n"
devfsadm -C

hdd_models=(`iostat -En | sed -n 's/^.*Product//p' | awk '{print $2}' | sort | uniq`)
dm=0
while [ $dm == 0 ] ; do
	echo "Available disk models:"
	echo ${hdd_models[@]}
	echo "Enter HDD model to flash:"
	read hdd_model
	for i in "${hdd_models[@]}"; do
    if [ "$i" == "$hdd_model" ] ; then
    	dm=1
    fi
	done
done

echo "Enter the full path of the firmware file to flash:"
echo "(NOTE: There is no validation on the file)"
read fw_file
while [ ! -e $fw_file ]; do
	echo "Enter the full path of the firmware file to flash:"
	echo "(NOTE: There is no validation on the file)"
	read fw_file
done

if [ ! $3 ]; then
echo "Enter desired firmware revision:"
echo "(Not the same as the file name. ex. '0004')"
read desired_fw
fi

if [ ! $4 ]; then
echo "Enter pool name that owns the disks so they can be offlined (leave null if not in a pool):"
read pool_name
fi
while [ ! `zpool status $pool_name | grep -i "pool: $pool_name" | awk '{print $2}'` ]; do
	echo "Enter pool name that owns the disks so they can be offlined:"
	read pool_name
done

hdd_wwn=(`iostat -En |ggrep -B 1 $hdd_model | ggrep -i c*t*d0 | awk '{print $1}'`)
hdd_array=()
for i in "${hdd_wwn[@]}"; do
hdd_fw=$(iostat -En |ggrep -A 1 $i | awk '/Revision/ {print $6}')
if [ $hdd_fw != $desired_fw ]; then
hdd_array+=($i)
fi
done
hdd_count=$(echo ${hdd_array[@]} | tr ' ' '\n' | wc -l | xargs)

if [[ $hdd_count == "1" ]]; then
	echo "All $hdd_model are on your desired firmware: $desired_fw"
	echo "Exiting."
	exit
fi
echo "Found ($hdd_count) $hdd_model to flash firmware on:"
echo ${hdd_array[@]}
confirm


# offline fmd
echo "Disabling FMA Service.."
svcadm disable -s svc:/system/fmd:default >> $log 2>&1

die() {
	# var dump
	printf "variable dump:\nsmux $smux\nhdd_model $hdd_model\nfw_file $fw_file\ndesired_fw $desired_fw\npool_name $pool_name\nhdd_wwn ${hdd_wwn[@]}\nhdd_array ${hdd_array[@]}\nhdd_count $hdd_count\nfailure message:\n" >> $log 2>&1
	echo "$1 failed, exiting." >> $log
	echo "$1 failed, exiting."
	echo "Review log file: $log"
		exit 1
	return
}

for i in "${hdd_array[@]}"; do
	if [ `zpool status $pool_name | grep $i | awk '{print $1}'` ]; then
		echo "Offlining: $i"
		zpool offline $pool_name $i >> $log 2>&1
		if [ $? != 0 ]; then
		die "offlining $i"
		return;
		fi
	

		echo "Flashing firmware: $i"
		$smux -flash $fw_file -confirm /dev/rdsk/$i >> $log 2>&1
		if [ $? != 0 ]; then
		die "flashing $i"
		return;
		sleep 5
		fi

		echo "Onlining: $i"
		zpool online $pool_name $i >> $log 2>&1
		if [ $? != 0 ]; then
		die "onlining $i"
		return;
		fi

		echo "Done: $i"
		echo ""
else
		echo "Flashing firmware: $i"
		$smux -flash $fw_file -confirm /dev/rdsk/$i >> $log 2>&1
		if [ $? != 0 ]; then
		die "flashing $i"
		return;
		sleep 5
		fi
	fi
done

# online fmd
echo "Enabling FMD Service.."
svcadm enable -s svc:/system/fmd:default >> $log 2>&1
fmadm reset zfs-diagnosis >> $log 2>&1
fmadm reset zfs-retire >> $log 2>&1
echo "Script complete. Note that although the new firmware takes effect immediately, certain OS tools such as iostat will show the old version until a reboot."
echo "Suggestion: Run 'zpool status' and make sure all drives are online."