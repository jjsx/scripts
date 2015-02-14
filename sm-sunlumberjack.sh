#!/bin/bash
# Silicon Mechanics SunOS Lumberjack
# It gathers the logs!
# Filename: sm-sunlumberjack.sh
# Copyright (c) 2014 Silicon Mechanics, Inc.

# !!! DO NOT EDIT THIS SCRIPT WITHOUT PERMISSION FROM SILICON MECHANICS SUPPORT. IMPROPER EDITING MAY CAUSE IRREVERSIBLE DAMAGE. !!!

# This script collects log, files, and command output for diagnostics and issue resolution.

# Version Date: 10/15/14
version="1.2.1"
name="sm-sunlumberjack"

script="sm-sunlumberjack"

printf "Silicon Mechanics SunOS Lumberjack (sm-sunlumberjack) ${version}\nThis script collects logs, files, and command output for diagnostics.\nSupported on: SunOS, OpenIndiana, NexentaStor, OpenSolaris, Illumos\n"
sleep 3

# make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   printf "This script must be run as root. Exiting.\n" 1>&2
   exit 1
fi

# make sure its a sun based os
OS=$(uname -s)
if [[ $OS != 'SunOS' ]]; then
	printf "This script can only be run on SunOS systems.\n"
	printf "Your OS is: ${OS}\n".
	printf "Exiting.\n"
	exit 1
fi

printf "Starting...\n"	
sleep 2

# Date
now=$(date +"%Y-%m-%d-%H-%M-%S-%Z")

hostname=`hostname`
workdir="/tmp/sm-sunlumberjack"

cifsdir="$workdir/cifs"
comstardir="$workdir/comstar"
diskdir="$workdir/disk"
hbasdir="$workdir/hbas"
pci_devicesdir="$workdir/pci_devices"
devfsdir="$workdir/devfs"
networkdir="/$workdir/network"
nfsdir="$workdir/nfs"
kerneldir="$workdir/kernel"
nsdir="$workdir/nameservices"
osdir="$workdir/os"
servicesdir="$workdir/services"
systemdir="$workdir/system"
fmadir="$workdir/fma"
performancedir="$workdir/performance"
zfsdir="$workdir/zfs"
ipmidir="$workdir/ipmi"


dirarray=($workdir $ipmidir $cifsdir $comstardir $diskdir $hbasdir $pci_devicesdir $devfsdir $networkdir $nfsdir $kerneldir $nsdir $osdir $servicesdir $systemdir $fmadir $performancedir $zfsdir $scriptdir)

# Log file
log="$scriptdir/$script.log"

#create directories
for i in "${dirarray[@]}"; do
mkdir -p $i
done

# Copy script into output location
cp $script.sh $scriptdir &> /dev/null

# Simple function to log finished log gathering sections
finished () {
	printf " done.\n"
	sleep 1
}

# Function to run commands and create output files
run_cmd () {
	runlog=$(echo $1 | tr A-Z a-z | sed -e 's/[^a-zA-Z0-9\-]/-/g')
	$1 1> ${dir}/${runlog}.out 2> ${dir}/${runlog}.err
}

# Function to copy files to output directory
grab () {
	grabfile=$(echo $1 | sed 's!.*/!!')
	cp $1 ${dir}/${grabfile} &> /dev/null
}

#cifs
dir=$cifsdir

printf "Gathering CIFS information.."

for dir in $(mount|grep ^/volumes |awk '{print $1}'); do echo $dir:; /usr/sun/bin/ls -avd $dir; echo ''; done > $cifsdir/for-dir-in-mount-grep-volumes-awk-print-1-do-echo-dir-usr-sun-bin-ls-avd-dir-done.out 2>&1 &

grab "/var/smb/smbpasswd"

run_cmd "idmap dump"
run_cmd "idmap dump -nv"
run_cmd "idmap list"
run_cmd "sharemgr show -vp -P smb"
run_cmd "smbadm list -v"
run_cmd "smbadm show -mp"
run_cmd "sharectl get smb"
run_cmd "smbstat -c 1 60" &
run_cmd "smbstat -razn 1 60" &
run_cmd "smbstat -t 1 60" &
run_cmd "smbstat -u 1 60" &
run_cmd "svccfg -s svc:/system/idmap listprop"

# cifs finished
finished

#comstar
dir=$comstardir

printf "Gathering iSCSI/comstar information.."

run_cmd "echo '*stmf_trace_buf/s' | mdb -k"
run_cmd "echo 'stmf_cur_ntasks/D' | mdb -k"
run_cmd "echo 'stmf_nworkers_cur/D' | mdb -k"
run_cmd "echo '::iscsi_tgt -acgstbS' | mdb -k"
run_cmd "sbdadm list-lu"
run_cmd "echo '::iscsi_tpg -R' | mdb -k"
run_cmd "echo '::iscsi_conn -av' | mdb -k"
run_cmd "itadm list-initiator -v"
run_cmd "itadm list-target -v"
run_cmd "itadm list-tpg -v"
run_cmd "iscsiadm list discovery-address -v"
run_cmd "iscsiadm list isns-server -v"
run_cmd "iscsiadm list static-config"
run_cmd "iscsiadm list target-param"
run_cmd "iscsiadm list discovery"
run_cmd "stmfadm list-hg -v"
run_cmd "stmfadm list-lu -v"
run_cmd "stmfadm list-state"
run_cmd "stmfadm list-target -v"
run_cmd "stmfadm list-tg -v"

grab "/kernel/drv/stmf_sbd.conf"

for lu in $(stmfadm list-lu|cut -d' ' -f3); do echo '';echo $lu;echo '';stmfadm list-view -l $lu; done > $comstardir/stmfadm-list-view-l-lu.out 2>&1 &

#comstar finished
finished

#disk
dir=$diskdir
printf "Gathering disk information.."

# cleanup old/dangling device links
run_cmd "devfsadm -Cv"

run_cmd "echo ::mptsas -t | mdb -k"
run_cmd "cfgadm -alo show_SCSI_LUN"
run_cmd "cfgadm -alv"
run_cmd "iostat -En"
run_cmd "kstat -p sderr:*:sd*err:*[Ee]rrors "

grab "/kernel/drv/mpt_sas.conf"
grab "/kernel/drv/scsi_vhci.conf"
grab "/kernel/drv/sd.conf"

# run smartctl on all drives
for hd in /dev/rdsk/c*t*d[0-9]; do
        smartctl -x $hd -d scsi 1> $diskdir/smart-collector.out 2> $diskdir/smart-collector.err
done

for a in $(mpathadm list LU | grep 'dev'); do mpathadm show LU $a; done > $diskdir/for-a-in-mpathadm-list-lu-grep-dev-do-mpathadm-show-lu-a-done.out 2>&1 &

for i in $(sas2ircu LIST 2> /dev/null |awk '/.*:.*:.*:.*/ {print $1}'); do
	sas2ircu $i DISPLAY 1> $diskdir/sas2ircu-$i-display.out 2> $diskdir/sas2ircu-$i-display.err &
done

#disk finished
finished


#hbas
dir=$hbasdir

printf "Gathering HBA information.."

run_cmd "sas2ircu LIST"
run_cmd "echo '::fcptrace' | mdb -k"
run_cmd "echo '::fptrace' | mdb -k"
run_cmd "fcadm hba-port -l"
run_cmd "fcinfo hba-port -e"
run_cmd "fcinfo hba-port -i"
run_cmd "fcinfo hba-port -l"
run_cmd "fcinfo hba-port -t"
run_cmd "fcinfo logical-unit -v"
run_cmd "mpathadm list logical-unit"

#hbas finished
finished


#pci_devices
dir=$pci_devicesdir

printf "Gathering PCI device information.."

run_cmd "lspci -vvv "
run_cmd "prtconf -D"
run_cmd "prtconf -v"
run_cmd "prtconf -vP"

#pci_devices finished
finished


#devfs
dir=$devfsdir

printf "Gathering devfs information.."

run_cmd "devfsadm -Csv"
run_cmd "ls -al /dev/"
run_cmd "ls -al /dev/cfg"
run_cmd "ls -al /devices"

grab "/etc/path_to_inst"

#devfs finished
finished

#network
dir=$networkdir

printf "Gathering network information.."

grab "/etc/default/inetinit"
grab "/etc/netmasks"
grab "/etc/hostname*"
grab "/etc/nodename"
grab "/etc/hosts"
grab "/kernel/drv/bnx.conf"
grab "/kernel/drv/bnxe.conf"
grab "/kernel/drv/e1000g.conf"
grab "/kernel/drv/igb.conf"
grab "/kernel/drv/ixgbe.conf"

run_cmd "dladm show-aggr"
run_cmd "dladm show-aggr -L"
run_cmd "dladm show-aggr -s"
run_cmd "dladm show-aggr -x"
run_cmd "dladm show-link"
run_cmd "dladm show-vlan"
run_cmd "dladm show-linkprop"
run_cmd "dladm show-phys"
run_cmd "dladm show-phys -m"
run_cmd "ifconfig -a"
run_cmd "ipmpadm"
run_cmd "ipmpstat -n -a"
run_cmd "ipmpstat -n -g"
run_cmd "ipmpstat -n -i"
run_cmd "ipmpstat -n -p"
run_cmd "ipmpstat -n -t"
run_cmd "kstat -p aggr:*:statistics:*[Ee]rror*"
run_cmd "kstat -p link:*:*:*[Ee]rr*"
run_cmd "netstat -ina"
run_cmd "netstat -pn"
run_cmd "netstat -rna"
run_cmd "netstat -s"
run_cmd "sharemgr show -vp"
run_cmd "domainname"

for a in $(dladm show-link -p -o LINK | sed -e 's/[0-9]$//g' | uniq); do kstat -p $a:*|grep -i err; done > $networkdir/for-a-in-dladm-show-link-p-o-LINK-sed-uniq-do-kstat-p-grep-i-err-done.out 2>&1 &

#network finished
finished

#nfs
dir=$nfsdir

printf "Gathering NFS information.."

run_cmd "svccfg -s svc:/network/nfs/server:default listprop"
run_cmd "sharectl get nfs"
run_cmd "nfsstat -s"
run_cmd "sharemgr show -vp -P nfs"
run_cmd "showmount -a -e"
run_cmd "dfshares"
run_cmd "dfmounts"

grab "/etc/default/nfs"
grab "/etc/nfssec.conf"
grab "/etc/defaultdomain"

#nfs finished
finished


#kernel
dir=$kerneldir
printf "Gathering kernel information.."

run_cmd "kstat -p -Td 10 6" &
run_cmd "echo ::kmastat -m | mdb -k"
run_cmd "echo ::kmem_slabs | mdb -k"
run_cmd "echo kmem_flags/X | mdb -k"
run_cmd "ls -la $(dumpadm | grep 'Savecore directory:' | cut -d' ' -f3)"
run_cmd "echo '::system' | mdb -k"
run_cmd "echo ::interrupts -d | mdb -k"
run_cmd "echo ::memstat | mdb -k | tail -n2"

grab "/etc/dumpadm.conf"
grab "/etc/system"

for i in $(ls /var/adm/messages* |sed 's/.*\///'); do cp /var/adm/$i $kerneldir/$i; done
for i in $(ls /kernel/drv/fc*.conf 2> /dev/null |sed 's/.*\///'); do cp /kernel/drv/$i $kerneldir/$i; done
for i in $(ls /kernel/drv/ql*.conf 2> /dev/null |sed 's/.*\///'); do cp /kernel/drv/$i $kerneldir/$i; done

#kernel finished
finished

# name services
dir=$nsdir

printf "Gathering name service information.."

run_cmd "grep -H '' /var/yp/binding/*/ypservers"

for i in $(ls /etc/nsswitch.* 2> /dev/null |sed 's/.*\///'); do cp /etc/$i $nsdir/$i; done

grab "/var/ldap/ldap_client_file"
grab "/etc/resolv.conf"

# name services finished
finished


#os
dir=$osdir

printf "Gathering OS information.."

grab "/etc/default/init"
grab "/etc/inet/ntp.conf"
grab "/etc/krb5/krb5.conf"
grab "/etc/krb5/warn.conf"
grab "/etc/pam.conf"
grab "/etc/rsyncd.conf"
grab "/etc/shareiscsi.target"
grab "/etc/vfstab"
grab "/root/.bash_history"

for i in $(ls /var/log/syslog* |sed 's/.*\///'); do cp /var/log/$i $osdir/$i; done

run_cmd "last reboot"
run_cmd "ntpq -np"

# os finished
finished

#services
dir=$servicesdir

printf "Gathering services information.."

run_cmd "du -sh /var/svc/log/"
run_cmd "svcs -a"
run_cmd "svcs -p"
run_cmd "svcs -xv"

for i in $(ls /var/svc/log/* |sed 's/.*\///'); do cp /var/svc/log/$i $servicesdir/$i; done
for file in $(ls /var/svc/log/*.log); do echo '-----';echo $file;echo '-----';echo '';tail -n 5000 $file;echo '';done > $servicesdir/for-file-in-ls-varsvcloglog-do-echo-file-echo-tail-n5000-file-done.out 2>&1 &
for svc in $(svcs -a|grep -i 'auto-'|awk -F' ' '{print $3}'); do echo $svc;echo ''; svccfg -s $svc listprop; echo ''; done > $servicesdir/for-svc-in-svcs-a-grep-i-auto-awk-F-print-3-echo-svc-svccfg-s-svc-listprop-echo-done.out 2>&1 &

# services finished
finished

# system
dir=$systemdir

printf "Gathering system information.."

run_cmd "uptime"
run_cmd "ptree -a"
run_cmd "smbios -x"
run_cmd "kstat -m cpu_info"
run_cmd "df -h"
run_cmd "smbios"
run_cmd "prtdiag -v"
run_cmd "prtpicl -v"

grab "/etc/passwd"

# system finished
finished

#fma
dir=$fmadir

printf "Gathering FMA information.."

run_cmd "fmdump -eVt 30day"
run_cmd "fmdump -Vm -t 30day"
run_cmd "fmadm faulty"
run_cmd "fmdump -e"
run_cmd "fmadm config"
run_cmd "fmstat"
run_cmd "fmstat -a"
run_cmd "fmstat -t"

for i in $(ls /usr/lib/fm/fmd/plugins/*.conf |sed 's/.*\///'); do cp /usr/lib/fm/fmd/plugins/$i $fmadir/$i; done

# fma finished
finished

#performance
dir=$performancedir

printf "Gathering performance information.."

run_cmd "iostat -Td -xn 1 60" &
run_cmd "mpstat -Td 1 60" &
run_cmd "intrstat -Td 1 60" &
run_cmd "kstat -p link"
run_cmd "prstat -dd -mL -n 60 1 60" &
run_cmd "vmstat -s"
run_cmd "vmstat -Td 1 60" &

# performance finished
finished

#zfs
dir=$zfsdir

printf "Gathering ZFS information.."

run_cmd "kstat -n arcstats"
run_cmd "echo ::zfs_params | mdb -k"
run_cmd "echo metaslab_min_alloc_size/D | mdb -k "
run_cmd "echo ::spa -c | mdb -k"
run_cmd "echo ::arc | mdb -k"
run_cmd "zdb -C"
run_cmd "zdb -l /dev/dsk/*s0"
run_cmd "zpool get cachefile | nawk 'NR > 1 {print $3}' | egrep -v '^-$' | xargs -n 1 zdb -C"
run_cmd "zpool iostat -Td -v 1 60" &
run_cmd "zpool history -il"
run_cmd "zfs list -t all -o all"
run_cmd "zfs get -p all"
run_cmd "zfs upgrade -v"
run_cmd "zpool list -o all"
run_cmd "zpool status -Dv"
run_cmd "fsstat -a -Td zfs 1 60" &
run_cmd "fsstat -f -Td zfs 1 60" &
run_cmd "fsstat -i -Td zfs 1 60" &
run_cmd "fsstat -n -Td zfs 1 60" &
run_cmd "fsstat -v -Td zfs 1 60" &
run_cmd "echo '::stacks -m zfs' | mdb -k"

# zfs finished
finished

# Wait for commands to finish
printf "Finishing up.. (this will take a minute)"
sleep 60

tar -czf $script-$hostname-$now.tar.gz $workdir &> $log
if [ $? != 0 ]; then
	printf "Could not create tar.gz output file. Please e-mail support the $script.log file located in the current directory.\n"
	cp "$log" .
fi

if [[ `ls ${script}-${hostname}-${now}.tar.gz` ]]; then
	finished
	sleep 1
	printf "Output file: ${script}-${hostname}-${now}.tar.gz\n"
fi

#cleanup
rm -r $workdir &> /dev/null

