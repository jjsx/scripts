#!/usr/bin/bash

# disk-location.sh
# Author: John Sanderson <john.sanderson@siliconmechanics.com> <https://github.com/jjsx>
# this script essentially outputs "zpool status" with the jbod/slot/model for each device in the pool
# it also will output unallocated disks with their jbod/slot/model
# v0.1 (4/7/2015)
# supported on nexentastor 3x/4x

log=disk-location.log
# Start log
exec > >(tee $log)
exec 2>&1

echo "Gathering information, please wait... (may take a few minutes)"
# dump slotmap
nmc -c "show lun slotmap" | awk '/c*t*d0.*jbod/ {print $1,$2,$3}' > /tmp/slotmap
# dump jbod info
nmc -c "show jbod all" > /tmp/jbod-all
# create wwn array
wwn_list=$(cat /tmp/slotmap | awk '/c*t*d0/ {print $1}')
# dump zpool status
zpool status | egrep 'pool:|mirror|raidz2|raidz1|raidz3|logs|cache|spares|c*t*d0' | awk '{print $1,$2}' > /tmp/zpool-status

declare -A darray

for i in ${wwn_list[@]}; do
phyloc=$(cat /tmp/slotmap | grep $i | awk '{print $2,"slot:"$3}')
model=$(cat /tmp/jbod-all | grep $i | awk '{print $5}')
darray[$i]=$phyloc; # assign enclosure/slot ($phyloc) to each device in $wwn_list
sed -i '/'$i'/c\
'$i' '"${darray[$i]}"' model: '"$model"'\
' /tmp/zpool-status
done

echo "========= DRIVE LOCATIONS FOR DISKS IN ZPOOL(S) ========="
cat /tmp/zpool-status
echo
echo
echo "========= UNALLOCATED DISK(S) ========="
unalloc=$(cat /tmp/jbod-all | grep "c*t*d0.*-" | awk '{print $2}')
for i in ${unalloc[@]}; do
model=$(cat /tmp/jbod-all | grep $i | awk '{print $5}')
location=$(cat /tmp/slotmap | grep $i | awk '{print $1,$2,"slot:"$3}')
echo "$location model: $model"
done
echo
echo
echo "Output file: $log"


#for i in ${!darray[@]}; do
#echo "disk  :   $i";
#echo "loc   :   ${darray[$i]}";
#echo "pool  :   $pool"
#echo "vdev  :   $vdev"
#echo
#done

#vdev=$(cat /tmp/zpool-status | sed '/$i/q' | ggrep -E 'pool:|mirror|raidz2|raidz1|logs|cache|spares|$i' | ggrep -B1 "$i" | awk '{print $1}' | head -n 1)
#pool=$(cat /tmp/zpool-status | sed '/$i/q' | ggrep -E 'pool:|mirror|raidz2|raidz1|logs|cache|spares|$i' | grep "pool:" | tail -1)