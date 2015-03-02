#!/bin/bash
# Silicon Mechanics Lumberjack
# It gathers the logs!
# Filename: sm-lumberjack.sh

# This script collects log, files, and command output for diagnostics and issue resolution.

# Version Date: 3/2/15
version="1.3.3"

# Script
script="sm-lumberjack"
script_location=$(echo "$PWD")

printf "Silicon Mechanics Lumberjack (sm-lumberjack) ${version}\nThis script collects logs, files, and command output for diagnostics.\nSupported on: RHEL 6/7, CentOS 5-7, Scientific Linux 6/7, Ubuntu 10-14, Debian 6/7, SUSE 12/13\n"

# Check OS
OS=$(uname -s)
if [[ $OS != 'Linux' ]]; then
	printf "This script can only be run on Linux systems.\nYour OS is: ${OS}\nExiting.\n"
	exit 1
fi

# Ensure only root can run the script
if [[ $EUID -ne 0 ]]; then
   printf "This script must be run as root. Exiting.\n" 1>&2
   exit 1
fi

confirm () {
    read -r -p "${1:-Continue? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
            true
            return 0
            ;;
        *)
            false
            ${2:-exit}
            return 1
            ;;
    esac
}
confirm

timer()
{
    if [[ $# -eq 0 ]]; then
        echo $(date '+%s')
    else
        local  stime=$1
        etime=$(date '+%s')

        if [[ -z "$stime" ]]; then stime=$etime; fi

        dt=$((etime - stime))
        ds=$((dt % 60))
        dm=$(((dt / 60) % 60))
        dh=$((dt / 3600))
        printf '%d:%02d:%02d' $dh $dm $ds
    fi
}
tmr=$(timer)

# Date
now=$(date +"%Y-%m-%d-%H-%M-%S-%Z")

hostname=`hostname`

# Working directory
workdir="/tmp/sm-lumberjack"



# Output directories
ipmidir="$workdir/ipmi"
dmidir="$workdir/dmi"
diskdir="$workdir/disk"
lsidir="$workdir/lsi"
pci_devicesdir="$workdir/pci_devices"
networkdir="$workdir/network"
nameservicesdir="$workdir/nameservices"
osdir="$workdir/os"
systemdir="$workdir/system"
performancedir="$workdir/performance"
scriptdir="$workdir/$script"

# Create directories
dirarray=($ipmidir $dmidir $diskdir $lsidir $pci_devicesdir $networkdir $nameservicesdir $osdir $systemdir $performancedir $scriptdir)

# Create directories
for i in "${dirarray[@]}"; do
mkdir -p $i
done

# Copy script into output location
cp $script.sh $scriptdir &> /dev/null &

# Log file
log="$scriptdir/$script.log"
touch $log

# Start log
exec > >(tee $log)
exec 2>&1

# Set OS variable
os="unknown"
if [[ `uname -a | grep Ubuntu` ]]; then
	os=ubuntu
elif [[ `uname -a | grep Linux` ]]; then
	os=linux
fi

if [[ -r /etc/SuSE-release ]]; then
	os=suse
fi

if [[ `cat /etc/issue | grep -i Debian` ]]; then
	os=debian
fi

if [[ "$os" == "linux" ]]; then
	pkgmgr=yum
elif [[ "$os" == "suse" ]]; then
	pkgmgr=zypper
elif [[ "$os" == "ubuntu" || $"os" == "debian" ]]; then
	pkgmgr=apt-get
fi

printf "Starting...\n"	
sleep 2

# Function to check if package install failed
check_failed () {
	if [ $? != 0 ]; then
		printf "$1 install failed.."
	fi
}

# Function to install packages
install () {
	printf "$1 not found. This package may provide important diagnostic information.\n"
	if confirm "Attempt to install from repository? [y/N]" "echo Skipping install.."; then
		installlog=$(echo $pkgmgr install -y $1 | tr A-Z a-z | sed -e 's/[^a-zA-Z0-9\-]/-/g')
		printf "Attempting to install $1..\n"
		$pkgmgr install -y $1 1> ${dir}/${installlog}.out 2> ${dir}/${installlog}.err
		check_failed
	fi
}

# Simple function to log finished log gathering sections
finished () {
	printf "\n"
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


# DMI
dir=$dmidir

printf "Gathering DMI information..\n"
if [[ "$os" == "ubuntu" || "$os" == "debian" ]]; then
	if ! [[ `dpkg --get-selections | grep -v deinstall | grep dmidecode` ]]; then
	install "dmidecode"
fi
elif [[ "$os" == "linux"  || "$os" == "suse" ]]; then
	if ! [[ `rpm -qa | grep dmidecode` ]]; then
	install "dmidecode"
fi
fi

run_cmd "dmidecode"
run_cmd "dmidecode -t bios"
run_cmd "dmidecode -t system"
run_cmd "dmidecode -t baseboard"
run_cmd "dmidecode -t chassis"
run_cmd "dmidecode -t processor"
run_cmd "dmidecode -t cache"
run_cmd "dmidecode -t memory"
run_cmd "dmidecode -t slot"

# DMI finished

# IPMI
dir=$ipmidir


printf "Gathering IPMI information..\n"
if [[ "$os" == "ubuntu" || "$os" == "debian" ]]; then
	if ! [[ `dpkg --get-selections | grep -v deinstall |grep ipmitool` ]]; then
		install "ipmitool"
		run_cmd "modprobe ipmi_msghandler"
		run_cmd "modprobe ipmi_devintf"
		run_cmd "modprobe ipmi_si"
	fi
elif [[ "$os" == "linux" ]]; then
	if ! [ `rpm -qa | grep ipmitool` ] || ! [ `rpm -qa | grep OpenIPMI-libs` ]; then
		install "OpenIPMI OpenIPMI-tools"
		run_cmd "chkconfig ipmi on"
		run_cmd "service ipmi start"
	fi
elif [[ "$os" == "suse" ]]; then
	if ! [ `rpm -qa | grep ipmitool` ]; then
		install "OpenIPMI OpenIPMI-tools"
	fi
fi

run_cmd "ipmitool fru"
run_cmd "ipmitool mc info"
run_cmd "ipmitool lan print"
run_cmd "ipmitool sel"
run_cmd "ipmitool sel list"
run_cmd "ipmitool chassis status"
run_cmd "ipmitool sensor"

# IPMI finished

# LSI
dir=$lsidir


#if [[ `lspci | grep -i LSI` ]]; then
	if confirm "Gather LSI RAID information? [y/N]" "echo Skipping LSI information.."; then
		printf "Gathering LSI information..\n"
		run_cmd "wget -O $lsidir/lsigetlunix.sh --no-check-certificate https://raw.githubusercontent.com/jjsx/scripts/master/lsiget062514/lsigetlunix.sh" #lsiget.sh
		run_cmd "wget -O $lsidir/all_cli --no-check-certificate https://github.com/jjsx/scripts/raw/master/lsiget062514/all_cli" #all_cli
		run_cmd "chmod +x $lsidir/lsigetlunix.sh"
		cd $lsidir
		run_cmd "$lsidir/lsigetlunix.sh -B"
		cd $script_location
	fi
#fi

# LSI finished

# HDD
dir=$diskdir

printf "Gathering disk information..\n"
run_cmd "fdisk -l"
run_cmd "df -Th"
run_cmd "mount"
run_cmd "lvm pvdisplay"
run_cmd "lvm version"
run_cmd "lvm vgs"
run_cmd "lvm dumpconfig"
run_cmd "lvm pvscan"
run_cmd "lsblk"

grab "/proc/mdstat"
grab "/etc/mdadm.conf"
grab "/proc/scsi/scsi"
grab "/proc/partitions"
grab "/proc/diskstats"

# Check if SmartmonTools is installed
if [[ "$os" == "ubuntu" || "$os" == "debian" ]]; then
	if ! [[ `dpkg --get-selections | grep -v deinstall |grep smartmontools` ]]; then
	install "smartmontools"
fi
elif [[ "$os" == "linux"  || "$os" == "suse" ]]; then
	if ! [[ `rpm -qa | grep smartmontools` ]]; then
	install "smartmontools"
fi
fi

# Gather HDD SMART information
dir=$diskdir/smart
mkdir -p $diskdir/smart
for hd in $(ls /dev/sd[a-z] | sed 's/.*\///'); do
	mkdir -p $diskdir/smart/$hd
	smartctl -x /dev/$hd 1> $diskdir/smart/$hd/$hd.out 2> $diskdir/smart/$hd/$hd.err
done

# HDD finished

# PCI Devices
dir=$pci_devicesdir

printf "Gathering PCI device information..\n"
run_cmd "lspci -vvv"

# PCI devices finished

# Network
dir=$networkdir

printf "Gathering network information..\n"
run_cmd "ifconfig -a"
run_cmd "modinfo e1000"
run_cmd "modinfo ixgbe"
run_cmd "modinfo igb"

grab "/etc/networks"
grab "/etc/hosts"


if [[ "$os" == "ubuntu" || "$os" == "debian" ]]; then
	grab "/etc/network/interfaces"
elif [[ "$os" == "linux" ]]; then
	for i in `ls /etc/sysconfig/network-scripts/ifcfg-* 2> /dev/null |sed 's/.*\///'`; do cp /etc/sysconfig/network-scripts/$i $networkdir/$i &> /dev/null; done
fi

# Network finished

# Name Services
dir=$nameservicesdir

printf "Gathering name service information..\n"

grab "/etc/resolv.conf"
grab "/etc/nsswitch.conf"

# Name Services finished

# Operating System
dir=$osdir

printf "Gathering OS information..\n"
run_cmd "uname -a"
run_cmd "ps aux"
run_cmd "whoami"
run_cmd "top -b -n 1"
run_cmd "lsmod"

grab "/etc/fstab"
grab "/etc/issue"
grab "/var/log/boot.log"
grab "/proc/version"
grab "/etc/rsyslog.conf"

# Gather kernel logs
if [[ "$os" == "ubuntu" || "$os" == "debian" ]]; then
	for i in $(ls /var/log/syslog* |sed 's/.*\///'); do cp /var/log/$i $osdir/$i; done
elif [[ "$os" == "linux"  || "$os" == "suse" ]]; then
	for i in $(ls /var/log/messages* |sed 's/.*\///'); do cp /var/log/$i $osdir/$i; done
fi

grab "/var/log/dmesg"
grab "/etc/ntp.conf"

# Operating System finished

# System
dir=$systemdir

printf "Gathering system hardware information..\n"
run_cmd "free -g"
run_cmd "lscpu"
run_cmd "nproc"

grab "/proc/meminfo"
grab "/proc/cpuinfo"
grab "/proc/filesystems"
grab "/proc/stat"

# Grab EDAC corrected errors
if [[ `lsmod | grep edac` ]]; then
	edac=1
	tar -czf $systemdir/edac_ce_count.tar.gz /sys/devices/system/edac/mc/mc*/csrow*/ch*_ce_count 1> $systemdir/tar-czf-edac-ce-count.tar.gz.out 2> $systemdir/tar-czf-edac-ce-count.tar.gz.err
fi

# Check if MCELog is installed
if [[ "$os" == "ubuntu" || "$os" == "debian" ]]; then
	if ! [[ `dpkg --get-selections | grep -v deinstall | grep mcelog` ]]; then
	install "mcelog"
fi
elif [[ "$os" == "linux"  || "$os" == "suse" ]]; then
	if ! [[ `rpm -qa | grep mcelog` ]]; then
	install "mcelog"
fi
fi

grab "/etc/mcelog/mcelog.conf"
grab "/var/log/mcelog"

# System finished

# Performance
dir=$performancedir

# Wait for commands to finish
printf "Finishing up.."
wait
printf "\n"
# Generate statistic file

stats_file="$scriptdir/$script.stats"

printf "Lumberjack ($version) run stats\n" >> $stats_file
printf "Date Ran: $now\n" >> $stats_file
printf "Time Elapsed: %s\n" $(timer $tmr) >> $stats_file
md5=$(md5sum $script.sh)
printf "Script md5sum: $md5\n" >> $stats_file
printf "Operating System: $(head -n 1 /etc/issue)\n\n" >> $stats_file

printf "Motherboard Information:\n" >> $stats_file
mbmodel=$(cat $dmidir/dmidecode--t-baseboard.out | awk '/Product Name/ {print $3}')
printf "Model: $mbmodel\n" >> $stats_file
biosfw=$(cat $dmidir/dmidecode--t-bios.out | awk '/Version/ {print $2}')
printf "BIOS Firmware Revision: $biosfw\n" >> $stats_file
ipmifw=$(cat $ipmidir/ipmitool-mc-info.out | awk '/Firmware Revision/ {print $4}')
printf "IPMI Firmware Revision: $ipmifw\n\n" >> $stats_file

# Stats - CPU
printf "CPU Information:\n" >> $stats_file
cpus=$(cat /proc/cpuinfo | grep "model name" | sort | uniq | sed 's/.*://')
cpucount=$(cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l)
printf "$cpucount x $cpus\n\n" >> $stats_file

# Stats - RAM
dimmcount=$(cat $dmidir/dmidecode--t-memory.out | awk '/Size: [0-9]/' | wc -l)
totalram=$(cat $dmidir/dmidecode--t-memory.out | awk '/Size: [0-9]/ {print $2}' | head -1)
printf "RAM Information:\n" >> $stats_file
printf "$dimmcount x $totalram MB\n\n" >> $stats_file
printf "Populated DIMM Slots:\n" >> $stats_file
cat $dmidir/dmidecode--t-memory.out |grep -A 3 "Size: [0-9]" |awk '/Locator/ {print $2}' >> $stats_file
printf "\n" >> $stats_file

# Stats - Issues Found
printf "Analysis results:\n" >> $stats_file

# Stats - IPMI
if [[ `cat $ipmidir/ipmitool-sel-list.out | grep [1-9]` ]]; then
printf "EVENTS in IPMI SEL.\n" >> $stats_file
else
	printf "No events in IPMI SEL.\n" >> $stats_file
fi

# Stats - EDAC corrected errors
if [[ $edac == 1 ]]; then
	if [[ `grep -a "[1-9]" /sys/devices/system/edac/mc/mc*/csrow*/ch*_ce_count` ]]; then
	printf "ERRORS in EDAC:\n" >> $stats_file
	grep -a "[1-9]" /sys/devices/system/edac/mc/mc*/csrow*/ch*_ce_count >> $stats_file
else
	printf "No errors in EDAC.\n" >> $stats_file
fi
fi

# Stats - Hardware Errors
#if [[ `dmesg | grep -i "Hardware Error"` || `dmesg | grep -i "Machine Check Exception"` ]]; then
#	printf "ERRORS in dmesg.\n" >> $stats_file
#else
#	printf "No errors in dmesg.\n" >> $stats_file
#fi

if [[ -f "/var/log/mcelog" ]]; then
	if [[ -s "/var/log/mcelog" ]]; then
		printf "ERRORS - /var/log/mcelog.\n" >> $stats_file
	fi
else
	printf "No errors - /var/log/mcelog.\n" >> $stats_file
fi

# Generate .tar.gz file
tar -czf $script-$hostname-$now.tar.gz -C /$workdir .
if [ $? != 0 ]; then
	printf "Could not create tar.gz output file. Please e-mail support the '$script.log' file located in the current directory.\n"
	cp "$log" .
fi


if [[ -f ${script}-${hostname}-${now}.tar.gz ]]; then
	printf "Output file: ${script}-${hostname}-${now}.tar.gz\n"
fi

# Clean up working directory
rm -r $workdir &> /dev/null
