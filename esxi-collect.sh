#/bin/sh

vers=4.0
printf "[ ESXI-collect Version $vers ]\n"


if [[ -d "/var/tmp/ESX-VMware" ]]
then
    printf "Clearing out old collection data...\n"
    /bin/rm /var/tmp/ESX-VMware/*
fi

if [[ ! -d "/var/tmp/ESX-VMware" ]]
then
    printf "[ Creating directory /var/tmp/ESX-VMware ]\n"
    /bin/mkdir -p /var/tmp/ESX-VMware
fi
printf "Starting: `date`\n" 
printf "Starting: `date`\n" >> /var/tmp/ESX-VMware/run-time.txt
date=`date "+%m.%d.%Y:%H.%M"`
printf "Collecting ISCSI\n"
printf "[ Iscsi information --> .....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI Session List --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli iscsi session list >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI Target Portal --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli iscsi adapter target portal list >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI Network Portal List --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli iscsi networkportal  list >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI Physical Network Portal List --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli iscsi physicalnetworkportal list >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI Logical Network Portal List --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli iscsi logicalnetworkportal  list >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI Plugin List --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli iscsi plugin list >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI Software List --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli iscsi software get >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI VAAI Info --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli system settings advanced list -o /DataMover/HardwareAcceleratedInit >> /var/tmp/ESX-VMware/iscsi.txt
esxcli system settings advanced list --option /VMFS3/HardwareAcceleratedLocking >> /var/tmp/ESX-VMware/iscsi.txt
esxcli system settings advanced list --option /DataMover/HardwareAcceleratedMove >> /var/tmp/ESX-VMware/iscsi.txt
esxcli system settings advanced list --option /VMFS3/EnableBlockDelete >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI San Stats --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli storage san iscsi stats get >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI Portal List --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli nc -z target_ip 3260  >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI SAN List --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli storage san iscsi list  >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ ISCSI Core Device Partition GUID --> ....................................]\n" >> /var/tmp/ESX-VMware/iscsi.txt
esxcli storage core device partition showguid  >> /var/tmp/ESX-VMware/iscsi.txt
printf "Collecting Network Info\n"
esxcli system settings advanced list --option /Migrate/NetTimeout >> /var/tmp/ESX-VMware/Net-Migration-info.txt
printf "[ VMotion Information --> ..........................]\n" >> /var/tmp/ESX-VMware/VMotion-info.txt
esxcli system settings advanced list --option /Migrate/VMotionStreamHelpers >> /var/tmp/ESX-VMware/VMotion-info.txt
esxcli system settings advanced list --option /Migrate/VMotionLatencySensitivity >> /var/tmp/ESX-VMware/VMotion-info.txt
esxcli system settings advanced list --option /Migrate/VMotionStreamDisable >> /var/tmp/ESX-VMware/VMotion-info.txt
esxcli system settings advanced list --option /Migrate/MigrateCpuSharesRegular >> /var/tmp/ESX-VMware/VMotion-info.txt
esxcli system settings advanced list --option  /Migrate/Vmknic >> /var/tmp/ESX-VMware/VMotion-info.txt
esxcli system settings advanced list --option /Migrate/DiskOpsEnabled >> /var/tmp/ESX-VMware/VMotion-info.txt
esxcli system settings advanced list --option /SvMotion/SvMotionAvgDisksPerVM >> /var/tmp/ESX-VMware/VMotion-info.txt
esxcli system settings advanced list --option /XvMotion/VMFSOptimizations >> /var/tmp/ESX-VMware/VMotion-info.txt
printf "[ Network/Switch/IP Information --> ..........................]\n" >> /var/tmp/ESX-VMware/network-info.txt
printf "[ VSwitch Standard List --> ....................................]\n" >> /var/tmp/ESX-VMware/network-info.txt
esxcli network vswitch standard list >> /var/tmp/ESX-VMware/network-info.txt
printf "[ IPv4 route info --> ....................................]\n" >> /var/tmp/ESX-VMware/network-info.txt
esxcli network ip route ipv4    list  >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ DNS Server info --> ....................................]\n" >> /var/tmp/ESX-VMware/network-info.txt
esxcli network ip dns server    list  >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ IP Connection info --> ....................................]\n" >> /var/tmp/ESX-VMware/network-info.txt
esxcli network ip connection    list  >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ IP Interface info --> ....................................]\n" >> /var/tmp/ESX-VMware/network-info.txt
esxcli network ip interface     list  >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ NIC List --> ....................................]\n" >> /var/tmp/ESX-VMware/network-info.txt
esxcli network nic list  >> /var/tmp/ESX-VMware/iscsi.txt
printf "[ NIC stats --> ...............................................]\n" >> /var/tmp/ESX-VMware/network-info.txt
esxcli network nic list | grep vmnic | awk '{print $1}' | xargs -n 1 esxcli network nic stats get -n  >> /var/tmp/ESX-VMware/network-info.txt
printf "Collecting VM Information\n"
printf "[ Running VM Information --> ..................................]\n" >> /var/tmp/ESX-VMware/vm-info.txt
esxcli vm process list  >> /var/tmp/ESX-VMware/iscsi.txt
esxcli network vm list  >> /var/tmp/ESX-VMware/iscsi.txt
printf "Collecting Storage Information\n"
printf "[ Storage information --> .....................................]\n" >> /var/tmp/ESX-VMware/Storage-Info.txt
esxcli storage core device stats get  >> /var/tmp/ESX-VMware/Storage-Info.txt
esxcli storage core device vaai status get  >> /var/tmp/ESX-VMware/Storage-Info.txt
esxcli system settings advanced list --option /Scsi/PassthroughLocking >> /var/tmp/ESX-VMware/Storage-Info.txt
printf "[ List the paths currently claimed by the VMware NMP Multipath Plugin ]\n" >> /var/tmp/ESX-VMware/Storage-Info.txt
esxcli storage nmp path list  >> /var/tmp/ESX-VMware/Storage-Info.txt
esxcli storage nmp device list  >> /var/tmp/ESX-VMware/Storage-Info.txt
printf "[ Storage Filesystem List --> ..................................]\n" >> /var/tmp/ESX-VMware/Storage-Info.txt
esxcli storage filesystem list  >> /var/tmp/ESX-VMware/Storage-Info.txt
printf "[ Storage Paths list --> .......................................]\n" >> /var/tmp/ESX-VMware/Storage-Info.txt
esxcli storage core path list  >> /var/tmp/ESX-VMware/Storage-Info.txt
printf "[ Storage Adapter List --> .....................................]\n" >> /var/tmp/ESX-VMware/Storage-Info.txt
esxcli storage core adapter list  >> /var/tmp/ESX-VMware/Storage-Info.txt
printf "[ Storage Paths Stats --> ......................................]\n" >> /var/tmp/ESX-VMware/Storage-Info.txt
esxcli storage core path stats get >> /var/tmp/ESX-VMware/Storage-Info.txt
printf "[ Collecting NFS data --> ......................................]\n" >> /var/tmp/ESX-VMware/Storage-Info.txt
esxcli storage nfs list >> /var/tmp/ESX-VMware/NFS-Info.txt
esxcli system settings advanced list --option /NFS/LockUpdateTimeout >> /var/tmp/ESX-VMware/NFS-Info.txt
esxcli system settings advanced list --option /NFS/DiskFileLockUpdateFreq >> /var/tmp/ESX-VMware/NFS-Info.txt
esxcli system settings advanced list --option /NFS/LockRenewMaxFailureNumber >> /var/tmp/ESX-VMware/NFS-Info.txt
printf "Collecting System/Hardware Information\n"
printf "[ System/Hardware information --> ..............................]\n" >> /var/tmp/ESX-VMware/System-Info.txt
esxcli system hostname get >> /var/tmp/ESX-VMware/System-Info.txt
esxcli hardware pci list | grep "Device Name"  >> /var/tmp/ESX-VMware/Hardware-Info.txt
esxcli hardware cpu global get >> /var/tmp/ESX-VMware/Hardware-Info.txt
esxcli hardware memory     get >> /var/tmp/ESX-VMware/Hardware-Info.txt
esxcli hardware clock      get >> /var/tmp/ESX-VMware/Hardware-Info.txt
esxcli hardware platform   get >> /var/tmp/ESX-VMware/Hardware-Info.txt
printf "Collecting Software Information\n"
printf "[ System Software Information --> ..............................]\n" >> /var/tmp/ESX-VMware/Software.txt
esxcli software profile    get >> /var/tmp/ESX-VMware/iscsi.txt >> /var/tmp/ESX-VMware/Software.txt
esxcli software vib list >> /var/tmp/ESX-VMware/iscsi.txt >> /var/tmp/ESX-VMware/Software.txt
printf "Stopping: `date`\n" 
printf "Stopping: `date`\n" >> /var/tmp/ESX-VMware/run-time.txt

printf "Packaging data....\n"
cd /var/tmp/
/bin/tar  cpf esxcollect.tar ESX-VMware
/bin/gzip /var/tmp/esxcollect.tar
/bin/mv   /var/tmp/esxcollect.tar.gz  /var/tmp/esxcollect-`uname -n`.tar.gz


printf "SCP/FTP the file /var/tmp/esxcollect-$date.tar.gz off the server and/or attach to the Support Case \n"

printf "Completed: `date`\n"

