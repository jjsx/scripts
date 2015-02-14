#!/usr/bin/bash

# this script will run smartctl -x on every disk in /dev/rdsk and grep for error count.

# cleanup old/dangling device links
echo "Cleaning up old device links..."
devfsadm -C &> /dev/null

# run smartctl on all drives
echo "Gathering SMART data..."
for hd in /dev/rdsk/c*t*d; do
	smartctl -x $hd -d scsi | grep -E -i -A 7 "logical unit id|error counter log" >> /tmp/smart-collector.log
done
echo "Complete. Output file: /tmp/smart-collector.log"