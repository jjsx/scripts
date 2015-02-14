#!/usr/bin/bash

hba_count=$(sas2ircu LIST | grep .*:.*:.*:.* | awk '{print $1}' | tail -1)
hba_count=$((hba_count))

while [ "$hba_count" -ge "0" ]; do
hba_num=$((hba_count))

for i in $(sas2ircu $hba_num DISPLAY |grep -A 2 -i "device is a hard disk" | grep -A 1 "Enclosure #" | awk '{print $4}' | tr "\\n" " " | sed 's/\([:]\)\1\+/\1 /g' | sed 's/ /:/g' | sed 's/::/ /g'); do
sas2ircu $hba_num LOCATE $i OFF
sleep 0.5
echo "sas2ircu $hba_num LOCATE $i OFF"
done
hba_count=$(($hba_count - 1))
done
