#!/bin/sh

# the purpose of this script is to flash HDD firmware using storcli
# tested using storcli v1.07.07
# may or may not work on other versions..


# preset variables

# location of storcli
sc=/usr/bin/storcli

# model to flash
m=ST4000NM0023

# firmware file location
fw=/root/0004.lod


$sc /call/eall/sall show all |grep -B6 .*\:.*$m | awk -F '\n' 'ln ~ /^$/ { ln = "matched"; print $1 } $1 ~ /^--$/ { ln = "" }' |grep -o '/c.*/e.*/s.*[0-9]' > drives

dl=drives

# create array
while read line; do
arr[$c]=$line # store line
c=$(expr $c + 1) # increase counter by 1
done < $dl

# uncomment this to check array.. should output array contents
# let i=0
# while (( ${#arr[@]} > i )); do 
#     printf "${arr[i++]}\n"
# done

# simple function to report errors
function error_bail {
	echo "$1 somehow failed. Exiting.";
		exit 1
	return
}

n=$(wc -l < drives)
echo "Found $n $m to flash."
echo "Starting..."
echo ""

# flashing procedure
for i in "${arr[@]}"; do
	echo "$i"
	$sc $i download src=$fw
	sleep 10
	$sc $i show all | grep "Revision"
	echo ""
	echo "--"
	if [ $? != 0 ]; then
	error_bail "Flashing"
	return;
fi
done

# output fw revision for each disk
for i in "${arr[@]}"; do
	echo "$i"
	$sc $i show all |grep "Revision"
	if [ $? != 0 ]; then
	error_bail "Validating"
	return;
fi
done

# remove temp drive file
rm -f drives &> /dev/null

# done
echo "Complete."
