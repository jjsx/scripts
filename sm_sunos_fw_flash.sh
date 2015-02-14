#!/bin/sh

# this script is to be used to hdd firmware on nexenta/solaris using smartmon-ux

echo "Enter location of the HDD list file"
read hddlist

if [ ! -f $hddlist ]; then
    echo "File not found!"
    exit
fi

echo "Enter location of firmware file"
read fw

if [ ! -f $fw ]; then
    echo "File not found!"
    exit
fi

echo "Enter pool name"
read pool

# create variable array w/ hdd list file
while read line; do
arr[$c]=$line # store line
c=$(expr $c + 1) # increase counter by 1
done < $hddlist
 
# offline fmd
echo "offlining fmd service.."
svcadm disable -s svc:/system/fmd:default &> /dev/null

# uncomment this to check array.. should be contents of /
# let i=0
# while (( ${#arr[@]} > i )); do
#     printf "${arr[i++]}\n"
# done

# simple function to report errors
function error_bail {
	echo "$1 somehow failed, exiting.";
		exit 1
	return
}

for i in "${arr[@]}"; do
	echo "$i : offlining.."
	zpool offline $pool $i
	if [ $? != 0 ]; then
	error_bail "offlining"
	return;
fi
	echo "$i : flashing firmware.."
	/etc/smartmon-ux -flash $fw -confirm /dev/rdsk/$i &> /dev/null
	if [ $? != 0 ]; then
	error_bail "flashing"
	return;
fi
	echo "$i : onlining.."
	zpool online $pool $i
	if [ $? != 0 ]; then
	error_bail "onlining"
	return;
fi
	echo "$i : done.."
	echo "--"
done

# online fmd
echo "onlining fmd service.."
svcadm enable -s svc:/system/fmd:default &> /dev/null
fmadm reset zfs-diagnosis &> /dev/null
fmadm reset zfs-retire &> /dev/null
echo "done."