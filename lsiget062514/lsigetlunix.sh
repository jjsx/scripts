#!/bin/sh
#
# File:  lsigetlunix.sh (Don't change this line, used in Solaris grep test)
#
# 
# See Readme.txt (Embedded further down)
#
#  How to run it:
#    1) Copy the included files to a file system with available space. 
#       In general, the size of the data collected is at least as big as the total size of
#       all log files.
#    3) Run it:   ./lsigetlunix.sh -H <enter> for help screen
#
# 
#  What to do when the script ends:
#    1) Send the .tgz file to Technical Support or to the FAE that you are in contact with.
# 
#  What to do when receiving the .tgz file:
#    1) Extract
#    3) Verify files are not empty & Controller_Cx.txt and/or Adapter_Ax.txt files are present.
#    4) Analyze the collected data 
#
#
#
# 02/20/10 - To many major changes have occurred to document them all. Revamped capture script that supports 3ware, MegaRAID
#	     & HBA's. All changes from here on out to be documented. 
# 02/21/10 - Grep'ed disk specific parameters together for easier troubleshooting for 3ware, already on MegaRAID. Added modpgctl.
# 02/22/10 - Fixed HBA version reporting.
# 02/24/10 - Changing export to x=y for FreeBSD, may break MacOS or Solaris, need to verify. Changed -? to -H for Help, 
#            reserved on FreeBSD. Grep MegaRAID specific info in FreeBSD messages file. 
# 02/25/10 - Fixed grepped disk specific parameters for multiple controllers on 3ware. Added FreeBSD Support for MegaRAID & HBA.
# 	     Cleaned up CLI naming/arch. Excluded all MegaRAID/HBA sections if MacOS. Changed to gunzip instead of tar -zxvf for 
#            Solaris. Added MegaRAID specific logging for Solaris. Added additional files to cleanup. 
# 04/10/10 - Added check for "OS_LSI"="" (Ubuntu others?), added check for iuCRC on MegaRAID. 
# 06/19/10 - Rearranged data for easier troubleshooting, less use of MegaCli, more grepping of master file for better performance.
#	     Created separate files for pdlist/adpalilog/adpallinfo/fwtermlog & added master file name to all as well as 
#	     adapter_ax.txt file (fwtermlog and all relevant data still in adapter_ax.txt file. Created separate files for grepped
#            fwtermlog errors to make it easier to read fwtermlog (instead of appending to end).
#
# 06/20/10 - GCA Release - Updated MegaCli to 10M05, updated help, fwtermlog errors in separate subdir.
#
# 09/14/10 - Added workaround for customer distribution. Updated MegaCli to 10M08. Updated tw_cli to 10.2 (esx35/40 still at 9.5.3)
# 09/15/10 - Replaced bad tw_cli images, readme update.
# 10/11/10 - Added beta 64bit MegaCli for FreeBSD
# 10/13/10 - Added 10M10/8.00.39 32/64bit MegaCli for FreeBSD, updated obsolete 3ware links to lsi.
# 10/25/10 - Changed uname -i to uname -s on custom OS check. Added 10M09/8.00.40 32bit MegaCli as 32/64bit for FreeBSD
# 11/24/10 - Added RC 10M09 8.00.36/8.00.39 32/64bit FreeBSD MegaCli's
# 02/16/11 - Added vars to internal util. Grabbing contents of /boot and menu.lst, updated cversions for 3w & MR.
# 03/11/11 - Updated MegaCli to 10M09P3/8.00.046 (10M10), Internal util to 1.66
# 03/17/11 - Added mrmonitor and vivaldiframeworkd status check.
# 03/25/11 - Fixed "mrmonitord: error while loading shared libraries: libxerces-c.so.28: cannot open shared object file: No such 
#            file or directory" error, now check "/etc/init.d/mrmonitor -v" instead of "mrmonitord -v". Updating ELF query, DS 3,
#            misc command additions and formatting changes. Updated MegaCli to 10M12/8.01.06 for all OSs but FreeBSD. Updated 
#            HBA section to better support Warp, still need seperate cli. Added troublshooting tip for Solaris script issue.
#	     Started to use new adpalilog driver version feature, doesn't rely on modinfo which can provide false info as to whats 
#	     loaded.	
# 3/28/11  - Replaced bad copy of tw_cli for Solaris. Solaris old default shell workaround.		
# 3/28/11  - Additional hostname variable support.		
# 3/31/11  - GCA Release - Added -i for OSTYPE grep for all OSs, FreeBSD 6.1 uses lowercase. Replaced bad copy of tw_cli for FreeBSD.
# 06/17/11 - Added BETA MegaCli(64) from 11M06
# 09/28/11 - Added tw_cli from 10.2.1 code set, fixed issue with show diag not working with older fw.
# 09/30/11 - Moved /conf create and some file copies to main subdir creation section, cleaned up file cleanup logic on close/continue.
# 10/06/11 - Upgraded internal util to 1.67.
# 10/07/11 - Cleaned up grep of messages, for drivers, i.e. "kernel: driver" not valid in all distributions/versions.
# 10/09/11 - Added check for MR LD consistency, MR PCI Info, lsipci -t and grep for only 1st driver instance in Adpalilog.
# 01/27/12 - Updated MegaCli(64) to 8.02.21-1/11M08P3, added lsscsi support, perfmode.
# 02/02/12 - Added option 17 to internal util.
# 03/14/12 - Updated Linux MegaCli(64) to 8.03.07(Beta) to support the Linux 3.x Kernel.
# 05/24/12 - Added collection of WarpDrive info and ddoemcli exec files to 
#            support collection.  Added collection of Nytro XD info.
#            Updated MegaCli and MegaCli64 to 8.04.07 for Linux, FreeBSD, and
#            Solaris.
# 09/21/12 - Update collection of WarpDrive info to use lsi_diag.sh script if
#            available.  Added collection of Nytro MegaRAID info. 
#            Updated internal util to 1.69 and dd*cli to 01.250.41.10.
#            Updated MegaCli to 8.04.52 for Linux to pull in new commands for
#            Nytro MegaRAID.
# 11/15/12 - Added filtering for additional error messages. Updated 3ware errorcodes/aens to 9.5.5.1. 
#
# 01/23/13 - Cleaned up some old KB references. Changed clean up list/create script, got rid of old dependencies. Deleted all versions 
#            of MegaCli except for Solaris, still a dependency issue and replaced with Phase 3/1.02.08 storcli, still keeping MegaCli 
#            syntax for now and will add storcli syntax overtime. Updated 3ware & MR AEN grep list to 10.2.2.1 & 5.5 respectively.
#
# 02/16/13 - AEC and DPMSTAT added for MegaRAID. Added /MegaRAID/storcli, MegaCli and AENs/Info, Warning, Critical & Fatal subdirs. 
#            Added storcli output. Fixed indentation for if/for statements until end of storcli section. General cleanup and house keeping.
#
# 02/27/13 - Additionally seperated AENs controller/type, compared pds by all variables, started to compare MR controllers by all variables.
#	     Pulled Sco cli's/build. Partial update of cversions_MR. Added driver build scripts and notes. Added vall show all for storcli.	
#	     Display all available temperature info. Support for udevadm & udevinfo. Fixed file clean up. Check if MR adapter exists before 
#	     capturing data with storcli.
#
# 03/02/13 - Added missing cx/vd/pd status/state checks with storcli.	
#
# 03/06/13 - Pulled out udevadm support - Hung OpenSuse 12.2 32bit and Centos 6.3 64bit. Fixed AEN seperation, mrmonitord and MSM have different formating of output.
#	
# 03/08/13 - Added /cx/eall show status, fixed comment when using lower case for variables, updated storcli to 1.03.11 (5.6).
#
# 04/26/13 - Added /cx show bios for storcli, Updated storcli to 1.04.07 (beta) except for Solaris. Issue with Solaris build currently. Beta drop of storcli adds NMR support.
#
# 05/29/13 - Added /cx/cv as /cx/bbu doesn't get cv info anymore with storcli. 1.04.07 storcli is now cga and part of the 5.7 release.
#
# 08/02/13 - Added grep for "PCIE Link Status/Ctrl" in termlog for PCI-E link speed, in 2208 only. Need PR to include in "show pci" fro storcli.
#
# 11/26/13 - Added 25-2-0-0 dump on HBA. Updated storcli to 1.06.03 (5.9) for FreeBSD/Linux/Solaris, libstorelibir-2.so.14.07-0 included for Linux to support /XD.
#	     Updated internal util to 1.70. Updated dcli to 111.00.01.00. Added all /XD show commands. Added -power, -dump & -getpowerval to dcli output fro WD.
#
# 12/04/13 - Fixed solaris support, added "export LD_LIBRARY_PATH=/usr/sfw/lib" for libstdc++.so.6 & libgcc_s.so.1 for storcli. Solaris 10 does not have 
#            /usr/gnu/bin/grep  that supports the -A option so some comparisons of storcli output are not done. Fixed > null to > /dev/null in two locations. 
#	     Fixed some exports for Solaris. Replaced all "if [ -e" options with -f. 2>&1 for whoami and groups output. 
#
# 01/07/14 - Replaced "if [ -f" with "if [ -e" on all checks for /sys/block/sdx. Increased 3ware smartctl support to 128 disks IF smartctl supports it. Moved creation of
# 	     sd_letter.txt before controller specific section to avoid duplication of sd entries. Fix smartctl capture on new 5.43 smartmontools, requires "sat+" for SATA disks.
#            Changed Readme to reflect MacOS is no longer being tested with this script but support was not explicitly removed.	
#
# 01/12/14 - Changed test for autobgi check to "No VDs have been configured". Fixed indentation formatting on "Solaris Work Around". Eliminated 2 "Solaris Work Arounds"
#	     on the Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt file. Added show eghs and removed old syntax. Fixed MR DPM output file comments.
#
# 01/26/14 - Added Progress & Obsolete as AEN severities to manage. Updated AENs to MR 6.2/storelib 4.14.
#
# 02/06/14 - Added lvm info capture, vgs, lvs, pvs, lvdisplay, pvdisplay & lvm.conf to /lvm
#
# 02/22/14 - Fixed Call_Eall_Sall_show_all-Compare-All-Parms.txt output, inquiry string going to Call_Eall_Sall_show_all-Compare-All-Parms_Cx.txt
#	     Added test to only do /cx/cv or bbu show/all if the device is present, storcli bug workaround. Removed duplicate file name in /call/eall show status output.
#	     Took PD wrcache out of /call/eall/sall output, set per VD, not PD.	Fixed Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt output, drives line had typo.
#            Added status to Call_show_all-Compare-All-Parms.txt
#
# 03/02/14 - Adding VMWare support, removed all tr commands on in common OS commands. Updated all storcli images to 6.2/1.07.07 except Solaris, need Solaris system to extract pkg file.
#            Updated all tw_cli images to 10.2.2.1/2.00.11.022. Updated all internal util images except 32bit lunux to 1.71, not available. Only including 32bit storcli/LSI WarpDrive Management Utility/internal util
#            binaries, tw_cli requires 32/64 bit versions. Dont do tw_cli /cx/px show smart/all in vmware, segfault, open defect, do each unique attribute - smart.
#	     Made date '+%H:%M:%S.%N' conditional on OS, vmware is date '+%H:%M:%S. Copying /etc/* & /var/log/*. Replaceing vmware tw_cli with  2.00.11.016esxi due to segfaults.
#	     Redirect stderr for internal util to "2>>./$fileName/script_workspace/lsiget_errorlog.txt" as its a linux util and produces the following errors on vmware "sh: /sbin/modprobe: not found"
#            and "mknod: /dev/mptctl: Function not implemented". Rearranged initial varialbles. Added esxcli output, combined common binaries under common OS section. Put all lsi product data
#            under /LSI_Products. Have only tested vmware 5.1.0, allow script to run on 5.x, 4.x & 3.x, BETA ONLY!
#            
# 03/11/14 - Added support for VMWare 5.5.0 & 4.1.0. Added back all 64bit binaries that I removed. If 64bit OS, try 64bit utils, if it doesnt work try the 32bit versions.
#            Changed some of the cli logic. 
#
# 03/17/14 - Made dmesg collection conditional. Added capture of /var/log/vmware conditionaly. Piped standard out on a number of cli commands to ./$fileName/script_workspace/lsiget_errorlog.txt in 
#            order to avoid "/bin/sh: /usr/libexec/pci-info: not found" errors on VMWare 4.1. Segregated esxcli 4.x and 5.x commands.
#
# 03/21/14 - Added dmidecode/biosdecode & dvpdecode commands.
#
# 04/04/14 - Removed Linux only test for smartctl, should work in FreeBSD as well. Added EID 252 for Nytro pddffdiag  dump.
#
# 04/23/14 - Got rid of _all output for internal tool.
#
# 06/23/14 - Changed grep string for CV detection from SuperCaP to Cachevault_Info. Released version only includes Linux/FreeBSD/VmWare, Solaris cli's need to be added, script tested.
#
# 06/25/14 - Added "fdisk -lu" collection, updated storcli to (6.3) 1.09.08 on for linux/freebsd/vmware. Added SKIP_XD variable as storcli 1.08.09 segfaults on /xd show with Invader.
#
#set -x
# grep as variable, for Solaris - grep=/usr/xpg4/bin/grep for -xe and /usr/gnu/bin/grep for -A
###########################################################################################################################
# Initialize Variables
###########################################################################################################################
#Script
Capture_Script_Version=062514
echo Capture_Script_Version_$Capture_Script_Version
TWGETLUNIXSTARTutc=`date -u`
TWGETLUNIXSTART=`date`
BASECMD=$0
OS_LSI=
grep=grep
CLEANED_UP=NO
udevinfo_Existing=
VMWARE_SUPPORTED=
VMWARE_4x=
VMWARE_5x=

#3ware
TWPRINTFILENAME=
TWGETDIRECTORYKEEP=
TWGETBATCHMODE=
TWGETPARTIALMODE=STANDARD
TWGETMONITORMODE=
TW_Help_Screen=
TWPROMPTFORCOMMENT=
CLI_NAME=tw_cli
CLI_LOCATION=./
TWcomment=
tw_hostname=
tw_host=
OLD_EVT_CAP_EXIST=NO
NEW_EVT_CAP_EXIST=NO
TW_ECHO_AEC=
TW_ECHO_PMSTAT=
ex_enclosurenums=
TWPARTIALCAP=

#MegaRAID
MCLI_NAME=
MCLI_LOCATION=./
num_mraid_adapters=
LimitMegaCliCMDs=
MR_ECHO_AEC=
MR_ECHO_PMSTAT=

#WarpDrive
DCLI_NAME=
SKIP_XD=YES

#HBA
LSUT_NAME=
lsut_Bundled_work=NO
NO_LSI_HBAs=YES



###########################################################################################################################
# Set OS type - Need first, initially for correct grep version.
###########################################################################################################################

if [ `echo $OSTYPE | $grep -i linux` ] ; then
	OS_LSI=linux
fi

if [ `uname -s | grep VMkernel` ] ; then
	OS_LSI=vmware
fi

#Unique vmware versions

if [ "$OS_LSI" = "vmware" ] ; then
	if [ `uname -r | grep 5.5.0` ] ; then
		OS_LSI=vmware_5.5.0
	fi
fi

if [ "$OS_LSI" = "vmware" ] ; then
	if [ `uname -r | grep 5.1.0` ] ; then
		OS_LSI=vmware_5.1.0
	fi
fi

if [ "$OS_LSI" = "vmware" ] ; then
	if [ `uname -r | grep 4.1.0` ] ; then
		OS_LSI=vmware_4.1.0
	fi
fi

if [ "$OS_LSI" = "vmware" ] ; then
	if [ `uname -r | grep 5.` ] ; then
		OS_LSI=vmware_5.X_Not_Tested
	fi
fi

if [ "$OS_LSI" = "vmware" ] ; then
	if [ `uname -r | grep 4.` ] ; then
		OS_LSI=vmware_4.X_Not_Tested
	fi
fi

if [ "$OS_LSI" = "vmware" ] ; then
	if [ `uname -r | grep 3.` ] ; then
		OS_LSI=vmware_3.X_Not_Tested
	fi
fi

#Unique vmware options, ADD new supported versions
if [ "$OS_LSI" = "vmware_5.5.0" ]; then VMWARE_SUPPORTED=YES; fi
if [ "$OS_LSI" = "vmware_5.5.0" ]; then VMWARE_5x=YES; fi
if [ "$OS_LSI" = "vmware_5.1.0" ]; then VMWARE_SUPPORTED=YES; fi
if [ "$OS_LSI" = "vmware_5.1.0" ]; then VMWARE_5x=YES; fi
if [ "$OS_LSI" = "vmware_4.1.0" ]; then VMWARE_SUPPORTED=YES; fi
if [ "$OS_LSI" = "vmware_4.1.0" ]; then VMWARE_4x=YES; fi
if [ "$OS_LSI" = "vmware_5.X_Not_Tested" ]; then VMWARE_SUPPORTED=YES; fi
if [ "$OS_LSI" = "vmware_5.X_Not_Tested" ]; then VMWARE_5x=YES; fi
if [ "$OS_LSI" = "vmware_4.X_Not_Tested" ]; then VMWARE_SUPPORTED=YES; fi
if [ "$OS_LSI" = "vmware_4.X_Not_Tested" ]; then VMWARE_4x=YES; fi
if [ "$OS_LSI" = "vmware_3.X_Not_Tested" ]; then VMWARE_SUPPORTED=YES; fi

if [ "$OS_LSI" = "vmware" ] ; then
	OS_LSI=vmware_unsupported_version
fi


if [ `echo $OSTYPE | $grep -i FreeBSD` ] ; then
	OS_LSI=freebsd
fi

if [ `echo $OSTYPE | $grep -i darwin` ] ; then
	OS_LSI=macos
fi

if [ "$OS_LSI" = "" ] ; then
	if [ `uname -s | $grep -i NIKOS` ] ; then
		OS_LSI=freebsd
		HOST=`uname -n`
	fi
fi

if [ "$OS_LSI" = "vmware_unsupported_version" ] ; then
	echo "Not a supported version of VMWare for lsiget yet, new feature"
	exit
fi

if [ "$OS_LSI" = "" ] ; then
	echo "OS_LSI is not set, either not a valid OS for this script or try running;"
	echo "sudo bash $BASECMD -D -Q"
	exit
fi

if [ `uname | $grep -i SunOS` ] ; then
	OS_LSI=solaris
#Needed for -xe			
		if [ -f /usr/xpg4/bin/grep ] ; then 
			grep=/usr/xpg4/bin/grep
			else
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""
			echo "This script requires /usr/xpg4/bin/grep that supports grep -xe to work correctly!"
			echo ""
			echo ""
			echo ""
			echo ""
			echo ""
			exit
		fi
#Needed for -A
		if [ -f /usr/gnu/bin/grep ] ; then 
			grepA=/usr/gnu/bin/grep
# This script should have /usr/gnu/bin/grep that supports grep -A but will run without it.
		fi
	if [ -f /usr/sfw/lib/libstdc++.so.6 ] ; then
		if [ -f /usr/sfw/lib/libgcc_s.so.1 ] ; then
			LD_LIBRARY_PATH=/usr/sfw/lib:$LD_LIBRARY_PATH
			export LD_LIBRARY_PATH
		fi	

	fi
./storcli show > /dev/null 2>&1
	if [ "$?" -eq "137" ]; then
		echo ""
		echo ""
		echo ""
		echo ""
		echo ""
		echo "The storcli cli requires libstdc++.so.6 & libgcc_s.so.1, they were not loacated in /usr/sfw/lib or in the LD_LIBRARY_PATH"
		echo ""
		echo ""
		echo ""
		echo ""
		echo ""
		exit
	fi
fi


#Shell work around for Solaris
#Checks in case script was exiting prematurely
if [ "$OS_LSI" = "solaris" ] ; then
# Do NOT have re_execute_variable_shell.txt on this FIRST clean up function!
	for i in CtDbg.log MegaSAS.log CmdTool.log lsut MegaRAID_Terminology.txt Build_all_driver_source.sh Sense-Key_ASC-ASCQ_Opcodes_SBC4R16.txt cversions_3w.txt cversions_MR.txt cversions_HBA.txt create freebsd_tw_cli.32 freebsd_tw_cli.64 linux_lsut.32 linux_lsut.64 linux_tw_cli.32 linux_tw_cli.64 macos_tw_cli.32 lsut32 lsut64 solaris_lsut.i386 solaris_storcli solaris_tw_cli.32 vmware_tw_cli.esxi dcli32 dcli64 freebsd_dcli.32 freebsd_dcli.64 linux_dcli.32 linux_dcli.64 solaris_dcli.i386 linux_storcli64 linux_storcli linux_libstorelibir-2.so.14.07-0 solaris_storcli vmware_storcli vmware_libstorelib.so freebsd_storcli64 freebsd_storcli ; do
		if [ -f $i ] ; then
			if [ -f re_execute_variable_shell.txt ] ; then  
				rm -f re_execute_variable_shell.txt $i
			fi
		fi
	done
fi

if [ "$OS_LSI" = "solaris" ] ; then
	if [ ! -f re_execute_variable_shell.txt ] ; then  
		if [ -f /usr/xpg4/bin/sh ] ; then 
			date >> re_execute_variable_shell.txt
			echo "exec /usr/xpg4/bin/sh $0 $*" >> re_execute_variable_shell.txt
			exec /usr/xpg4/bin/sh $0 $* 
		fi
		if [ -f /bin/bash ] ; then 
			date >> re_execute_variable_shell.txt
			echo "exec /bin/bash $0 $*" >> re_execute_variable_shell.txt
			exec /bin/bash $0 $*
		fi
	fi
fi

###################################################
#Time Stamp
###################################################

if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
	date '+%H:%M:%S.%N'
fi
if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
	date '+%H:%M:%S'
fi

###################################################

GetKeystroke () { 
  # no read -r in sh
  trap "" 2 3 
  oldSttySettings=`stty -g` 
  stty -echo raw 
  echo "`dd count=1 2> /dev/null`" 
  stty $oldSttySettings 
  trap 2 3 
} 

WaitContinueOrQuit () { 
  # no read -r in sh
  keyStroke="" 
  while [ "$keyStroke" != "C" ] && [ "$keyStroke" != "c" ]
  do 
    if [ "$keyStroke" = "Q" ] || [ "$keyStroke" = "q" ]; then
      	if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
		date '+%H:%M:%S.%N'
	fi
	if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
		date '+%H:%M:%S'
	fi
      exit
    fi

    echo "Type C to continue or Q to Quit." 
    echo "...................................................................................................."
    keyStroke=`GetKeystroke` 
  done
}

WaitQuit () { 
  # no read -r in sh
  keyStroke="" 
  while [ 1 ]
  do 
    if [ "$keyStroke" = "Q" ] || [ "$keyStroke" = "q" ]; then
      	if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
		date '+%H:%M:%S.%N'
	fi
	if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
		date '+%H:%M:%S'
	fi
      exit
    fi

    echo "Type Q to Quit." 
    echo "...................................................................................................."
    keyStroke=`GetKeystroke` 
  done
}


 
###########################################################################################################################
# Verify all capture script files exist or exit.
###########################################################################################################################

for i in Readme.txt all_cli ; do
	if [ ! -f $i ] ; then echo "$i missing"

		#cho ".................................................||................................................."
		#echo "" 
		echo "\"$BASECMD -H\" provides a help screen."
		echo "" 
		echo "This is not a valid lsigetlunix.sh installation. This script is available at;"
		echo "" 
		echo "http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=8264"
		echo "" 
		echo "All files included in the original lsigetlunix_xxx_xxxxxx.tgz file MUST be kept"
		echo "in the same subdir as lsigetlunix.sh."
		echo "" 
		echo "" 
		if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
			date '+%H:%M:%S.%N'
		fi
		if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
			date '+%H:%M:%S'
		fi
		exit
	fi
done	     


###########################################################################################################################
# Command Line Options
# Looking for comments that are not command line options.
# Only 1 comment allowed, lowest variable # wins.
###########################################################################################################################

#-e vs -xe may not make a difference but need to verify on all other OS's, will verify eventually.
#Dont remember why I switched from -e to -xe, may be a corner case.
if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
	if [ "$6" != "" ] ; then 
		echo $6 | $grep -xe -M -xe -P -xe -D -xe -B -xe -Q -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -m -xe -p -xe -d -xe -b -xe -q -xe -e_aec -xe -e_dpmstat -xe -e_aec_dpmstat -xe -g_aec -xe -g_dpmstat -xe -g_aec_dpmstat -xe -mrwa -xe -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$6"
			fi
	fi
	if [ "$5" != "" ] ; then 
		echo $5 | $grep -xe -M -xe -P -xe -D -xe -B -xe -Q -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -m -xe -p -xe -d -xe -b -xe -q -xe -e_aec -xe -e_dpmstat -xe -e_aec_dpmstat -xe -g_aec -xe -g_dpmstat -xe -g_aec_dpmstat -xe -mrwa -xe -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$5"
			fi
	fi
	if [ "$4" != "" ] ; then 
		echo $4 | $grep -xe -M -xe -P -xe -D -xe -B -xe -Q -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -m -xe -p -xe -d -xe -b -xe -q -xe -e_aec -xe -e_dpmstat -xe -e_aec_dpmstat -xe -g_aec -xe -g_dpmstat -xe -g_aec_dpmstat -xe -mrwa -xe -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$4"
			fi
	fi
	if [ "$3" != "" ] ; then 
		echo $3 | $grep -xe -M -xe -P -xe -D -xe -B -xe -Q -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -m -xe -p -xe -d -xe -b -xe -q -xe -e_aec -xe -e_dpmstat -xe -e_aec_dpmstat -xe -g_aec -xe -g_dpmstat -xe -g_aec_dpmstat -xe -mrwa -xe -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$3"
			fi
	fi
	if [ "$2" != "" ] ; then 
		echo $2 | $grep -xe -M -xe -P -xe -D -xe -B -xe -Q -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -m -xe -p -xe -d -xe -b -xe -q -xe -e_aec -xe -e_dpmstat -xe -e_aec_dpmstat -xe -g_aec -xe -g_dpmstat -xe -g_aec_dpmstat -xe -mrwa -xe -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$2"
			fi
	fi
	if [ "$1" != "" ] ; then 
		echo $1 | $grep -xe -M -xe -P -xe -D -xe -B -xe -Q -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -m -xe -p -xe -d -xe -b -xe -q -xe -e_aec -xe -e_dpmstat -xe -e_aec_dpmstat -xe -g_aec -xe -g_dpmstat -xe -g_aec_dpmstat -xe -mrwa -xe -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$1"
			fi
	fi
fi

if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
	if [ "$6" != "" ] ; then 
		echo $6 | $grep -e -M -e -P -e -D -e -B -e -Q -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -m -e -p -e -d -e -b -e -q -e -e_aec -e -e_dpmstat -e -e_aec_dpmstat -e -g_aec -e -g_dpmstat -e -g_aec_dpmstat -e -mrwa -e -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$6"
			fi
	fi
	if [ "$5" != "" ] ; then 
		echo $5 | $grep -e -M -e -P -e -D -e -B -e -Q -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -m -e -p -e -d -e -b -e -q -e -e_aec -e -e_dpmstat -e -e_aec_dpmstat -e -g_aec -e -g_dpmstat -e -g_aec_dpmstat -e -mrwa -e -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$5"
			fi
	fi
	if [ "$4" != "" ] ; then 
		echo $4 | $grep -e -M -e -P -e -D -e -B -e -Q -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -m -e -p -e -d -e -b -e -q -e -e_aec -e -e_dpmstat -e -e_aec_dpmstat -e -g_aec -e -g_dpmstat -e -g_aec_dpmstat -e -mrwa -e -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$4"
			fi
	fi
	if [ "$3" != "" ] ; then 
		echo $3 | $grep -e -M -e -P -e -D -e -B -e -Q -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -m -e -p -e -d -e -b -e -q -e -e_aec -e -e_dpmstat -e -e_aec_dpmstat -e -g_aec -e -g_dpmstat -e -g_aec_dpmstat -e -mrwa -e -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$3"
			fi
	fi
	if [ "$2" != "" ] ; then 
		echo $2 | $grep -e -M -e -P -e -D -e -B -e -Q -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -m -e -p -e -d -e -b -e -q -e -e_aec -e -e_dpmstat -e -e_aec_dpmstat -e -g_aec -e -g_dpmstat -e -g_aec_dpmstat -e -mrwa -e -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$2"
			fi
	fi
	if [ "$1" != "" ] ; then 
		echo $1 | $grep -e -M -e -P -e -D -e -B -e -Q -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -m -e -p -e -d -e -b -e -q -e -e_aec -e -e_dpmstat -e -e_aec_dpmstat -e -g_aec -e -g_dpmstat -e -g_aec_dpmstat -e -mrwa -e -h > /dev/null 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$1"
			fi
	fi
fi


# Checking command line variables for options.
# Competing options are not allowed.

for i in $*; do
  if [ "$i" = "-P" ] || [ "$i" = "-p" ]; then TWPRINTFILENAME=YES ; fi
  if [ "$i" = "-D" ] || [ "$i" = "-d" ]; then TWGETDIRECTORYKEEP=YES ; fi
  if [ "$i" = "-Q" ] || [ "$i" = "-q" ]; then TWGETBATCHMODE=QUIET ; fi
  if [ "$i" = "-B" ] || [ "$i" = "-b" ]; then TWGETBATCHMODE=BATCH ; fi
  if [ "$i" = "-E_AEC" ] || [ "$i" = "-e_aec" ]; then TWGETPARTIALMODE=E_AEC ; fi
  if [ "$i" = "-E_DPMSTAT" ] || [ "$i" = "-e_dpmstat" ] ; then TWGETPARTIALMODE=E_DPMSTAT ; fi
  if [ "$i" = "-E_AEC_DPMSTAT" ]  || [ "$i" = "-e_aec_dpmstat" ]; then TWGETPARTIALMODE=E_AEC_DPMSTAT ; fi
  if [ "$i" = "-G_AEC" ] || [ "$i" = "-g_aec" ] ; then TWGETPARTIALMODE=G_AEC ; fi
  if [ "$i" = "-G_DPMSTAT" ] || [ "$i" = "-g_dpmstat" ] ; then TWGETPARTIALMODE=G_DPMSTAT ; fi
  if [ "$i" = "-G_AEC_DPMSTAT" ] || [ "$i" = "-g_aec_dpmstat" ] ; then TWGETPARTIALMODE=G_AEC_DPMSTAT ; fi
  if [ "$i" = "-M" ] || [ "$i" = "-m" ]; then TWGETMONITORMODE=MONITOR ; fi
  if [ "$i" = "-MRWA" ] ; then LimitMegaCliCMDs=YES ; fi
  if [ "$i" = "-H" ] || [ "$i" = "-h" ]; then TW_Help_Screen=YES ; fi
done

###########################################################################################################################
# Option Override
###########################################################################################################################

if [ "$TWGETMONITORMODE" = "MONITOR" ] ; then TWGETPARTIALMODE=STANDARD ; fi

if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
	if [ "$TWGETBATCHMODE" = "" ]; then
	   # solaris 10 doesn't support -u option
	   if [ `id | awk '{print $1}'` = "uid=0(root)" ]; then
	      TWGETBATCHMODE=QUIET
	   fi
	fi
fi
###########################################################################################################################
# Bypass Comment prompt
###########################################################################################################################

if [ "$TWGETPARTIALMODE" = "E_AEC" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "E_DPMSTAT" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "E_AEC_DPMSTAT" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETBATCHMODE" = "BATCH" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETBATCHMODE" = "QUIET" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWcomment" != "" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "G_AEC_DPMSTAT" ] ; then TWPARTIALCAP=YES ; fi
if [ "$TWGETPARTIALMODE" = "G_AEC" ] ; then TWPARTIALCAP=YES ; fi
if [ "$TWGETPARTIALMODE" = "G_DPMSTAT" ] ; then TWPARTIALCAP=YES ; fi

###########################################################################################################################
# Help Screen
###########################################################################################################################

if [ "$TW_Help_Screen" = "YES" ] ; then

	#cho ".................................................||................................................."
	echo "" 
	echo "LSI HBA/MegaRAID/3ware Data collection script for Linux, FreeBSD, & Solaris X86 (sh shell)." 
	echo "This script will collect system logs and info as well as controller, disk and"
	echo "enclosure info for debugging purposes. All files included in the original" 
	echo "lsigetlunix_xxxxxx.tgz file MUST be kept in the same subdir as lsigetlunix.sh."
	echo "You MUST have root access rights to run this script, su/sudo/root/etc. The latest version of this"
	echo "script as well as information on what data can be collected manually can be found at;"
	echo ""
	echo "http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=8264"
	echo ""
	echo "OR"
	echo ""
	echo "ftp0.lsil.com"
	echo "User:tsupport"
	echo "Password:tsupport"
	echo "/outgoing_perm/CaptureScripts  (Usually newer scripts than KB article)"
	echo ""
	echo "To automatically get the latest script you can download the following file & grep for the current"
	echo "latest file. This ensures support will always have access to the latest data to speed up the support"
	echo "process." 
	echo ""
	echo "Example;"
	echo ""
	echo "/outgoing_perm/CaptureScripts/Latest_Script_Versions.txt"
	echo "#Used for automated remote script updates"
	echo "LatestFreebsd#lsigetfreebsd_062012.tgz"
	echo "LatestLinux#lsigetlinux_062012.tgz"
	echo "LatestLunix#lsigetlunix_062012.tgz"
	echo "LatestMacOS#lsigetmacos_062012.tgz"
	echo "LatestSolaris#lsigetsolaris_062012.tgz"
	echo "LatestWin#lsigetwin_062012.tgz"
	echo ""
	echo "This script is being packaged for all supported linux/Unix based OS's"
	echo "together as well as individually for each OS with different bundled" 
	echo "utilities. The exact same script is used in all cases, this is being done" 
	echo "to cut down on the size of the full .tgz file."
	echo ""
	echo "	lsigetlunix_xxxxxx.tgz   - Linux/Unix - FreeBSD/Linux/Solaris"
	echo "	lsigetfreebsd_xxxxxx.tgz - FreeBSD"
	echo "	lsigetlinux_xxxxxx.tgz   - Linux"   
	echo "	lsigetmacos_xxxxxx.tgz   - MacOS (MacOS - Not currently tested, support not explicitly removed though)"
	echo "	lsigetsolaris_xxxxxx.tgz - Solaris"
	echo "	lsigetvmware_xxxxxx.tgz  - VMWare  (currently - Not Supported)"
	echo ""
	echo "Optional Command Line Options:"
	echo "$BASECMD [Comment] [Option(s)]"		
	echo 'Comment: Enclose noncontiguous strings in double quotes "My Comments"' 
	echo "Option:" 
	echo "-P             = PRINT filename in ./LSICAPTUREFILES.TXT for batch automation."
	echo "-D             = Working DIRECTORY is not deleted."
	echo "-Q             = QUIET Mode - No keystrokes required unless error."
	echo "-B             = BATCH Mode - No keystrokes required."
	echo "-E_AEC         = Clear and ENABLE AEC. !Under Direction Only!" 
	echo "-E_DPMSTAT     = Clear and ENABLE DPMSTAT."
	echo "-E_AEC_DPMSTAT = Clear and ENABLE AEC and DPMSTAT. !Under Direction Only!" 
	echo "-G_AEC         = Disable and GET AEC Logs, IF enabled. !Under Direction Only!" 
	echo "-G_DPMSTAT     = Disable and GET DPMSTAT Logs, IF enabled."
	echo "-G_AEC_DPMSTAT = Disable and GET AEC/DPMSTAT Logs, IF enabled. !Under Direction Only!" 
	echo "-M             = MONITOR Mode - Standard and daily/targeted logging. (3ware Only)"  
	echo "-MRWA          = MegaRAID Work Around - Limit commands for compatibility issues with old code" 		
	echo "-H             = This Help Screen."
	echo ""
	echo "Example $BASECMD -D -Q \"This is my comment\""
	echo "Runs the standard script leaving the working directory, without prompts" 
	echo "and leaves a comment."
	echo ""
	echo "Example $BASECMD -Q \"This is my comment\" -D -M"
	echo "Runs the standard script leaving the working directory, without prompts" 
	echo "and leaves a comment, once done the script stays resident in Monitor Mode."
	echo ""
	echo "Notes:" 
	echo "Send just the created .tar.gz file as is to your support rep."
	echo ""
	echo "AEC = Advanced Event Capture - This is an unreleased INTERNAL option!" 
	echo "Do NOT use AEC without being directed to by Technical Support or an FAE! (3ware Only)"
	echo ""
	echo "DPMSTAT = Disk Performance Monitoring Statistics - Captures performance"
	echo "related information on a controller/disk basis. Detailed information can" 
	echo "found in the 9.5.1 or later Users Guide available at; (3ware Only)"
	echo ""
	echo "http://www.lsi.com/channel/products/raid_controllers/sata_sas/3ware_9750-8e/index.html"
	echo ""
	echo "All of the -G_* "GET" Options are done automatically if AEC or DPMSTAT was"
	echo 'enabled previously with the -E_* "ENABLE" options by default. The -G_*' 
	echo "options are meant for quick repetitive results without getting other system"
	echo "information. Normally you should run the standard $BASECMD file without"
	echo "a -G_* option to provide as much info as possible. (3ware Only)"
	echo ""
	echo "If there are competing comments the lowest variable number wins."
	echo "If there are contradictory options the lowest variable number with the"
	echo "option order listed in the help wins. Valid combinations would be;"
	echo "-D or -D with -B or -Q any -E_* or -G_* option by itself or in conjunction"
	echo "with a -D and -B/-Q option. -E_* is allowed with -D but has no effect as" 
	echo "there is no working directory created."
	echo ""
	echo "Monitor Mode = Runs the standard capture script and then remains resident"
	echo 'logging "show diag" approx. every 24 hours and also monitors for three' 
	echo "specific AEN's (Controller Reset/Degraded Array/Rebuild Started). If any"
	echo 'of these are encountered a final "show diag" will be done and the script' 
	echo "will finish normally. Use to capture the internal printlog/buf prior to"
	echo "the buffer being overwritten. Run a standard capture after Monitor Mode completes. (3ware Only)"
	echo ""
	echo "MRWA = MegaRAID Work Around - Limits the MegaCli(64) commands that are run."
	echo "MegaCli has been seen to hang in some cases when running the 92xx controllers with"
	echo "pre 4.1.1 FW and/or driver versions. Currently this switch bypasses the encinfo & adplilog"
	echo "parameters. Instead of using this switch it is recommended to upgrade your code as this"
	echo "work around is not always 100% effective. See the troubleshooting section for more information."
	echo ""
	echo "Trouble Shooting Script Issues -"
	echo ""
	echo "I. Ubuntu 9.04"
	echo "sudo $BASECMD -D -Q"
	echo "Tue Sep 22 17:06:32 PDT 2009"
	echo "export: 3: 22: bad variable name"
	echo ""
	echo "Run;"
	echo "sudo bash $BASECMD -D -Q"
	echo ""
	echo "II. Script hangs with MegaRAID Controller"
	echo ""
	echo "If you are positive the script is hung, CTRL-C the process, wait 3 minutes."
	echo "If the prompt doesn't come back kill the term window, do a ps -ea, note the"
	echo "# of any lsigetlunix.sh or MegaCli(64) processes. Do a kill -9 process-number"
	echo "for each process. If any can't be killed, wait 3 minutes, there is a 180 second"
	echo "timeout on MegaCli. Upgrade your driver/fw/capture script to the latest version and"
	echo "try again. If you cant upgrade or if you still have problems try the -MRWA switch."
	echo "If you still have problems manually zip the subdirectory structure and "
	echo "email it to your support rep."
	echo ""
	echo "III. Fails to run on Solaris - Error is "$BASECMD: test: argument expected""
	echo "Old version of Bourne shell is loaded by default, the following two shells were tried automatically"
	echo "/bin/sh was changed to /usr/xpg4/bin/sh and then /bin/bash"
	echo "depending on what is installed on the system, you can try others, i.e. csh/ksh or install a" 
	echo "supported shell..."
	echo ""
	echo "Recommended Code Set/Release Versions"
	echo ""
	echo "3ware-"
	echo ""
	echo "This script should run with any release between 7.6.0 & 10.2.2.1 on the 7k, 8k & 9k family of"
	echo "controllers. If you are running an earlier Code Set you can still run this script as it also"
	echo "captures system information. If you are using a latter Code Set you should obtain"
	echo "the latest script file set at the following link; http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=8264"	 
	echo ""
	echo "HOWEVER - It is recommended to update to the latest code base in general."
	echo "10.2.2.1 utilities are backwards compatible to 7xxx, 8xxx, 95xx and 96xx controllers."
	echo "10.2.2.1 drivers are for 6Gb controllers ONLY."
	echo "10.2.2.1 firmware is for 6Gb controllers ONLY."
	echo "9.5.5.1 drivers are backwards compatible to 95xx and 96xx controllers."
	echo "9.5.5.1 firmware is only compatible with 96xx controllers."
	echo ""
	echo "97xx - 5.12.00.016FW(10.2.2.1) for 9750 & 10.0 utilities & drivers"
	echo "96xx - Highly Recommend 4.10.00.027FW(9.5.5.1) for 9690SA/9650SE & 9.5.3 utilities & drivers"
	echo "9550/9590 - Highly Recommend 3.08.00.029FW(9.4.3) & 9.5.5.1 utilities & drivers"
	echo "9500S - Highly Recommend 2.08.00.009FW(9.3.0.8), use 9.5.5.1 utilities & drivers"
	echo "7/8xxx - Require 1.05.00.068FW(7.7.1), use 7.7.1 or latest OS included drivers & 9.5.3 utilities"
	echo ""
	echo "3ware Drivers/FW/Utilities/Docs"
	echo "http://www.lsi.com/channel/ChannelDownloads/"
	echo ""
	echo "MegaRAID -"
	echo ""
	echo "This script should run with any release between 3.1 & 5.5 on the 82xx, 83xx, 84xx, 87xx,"
	echo "88xx & 92xx family of controllers. If you are running an earlier Code Set you can still run"
	echo "this script as it also captures system information. If you are using a latter Code Set you" 
	echo "should obtain the latest script file set at the following link;" 
	echo "http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=8264"	 
	echo ""
	echo "HOWEVER - It is recommended to update to the latest code base in general."
	echo "5.5 utilities are backwards compatible to 82xx, 83xx, 84xx, 87xx, 88xx, and 92xx controllers."
	echo "5.5 drivers are backwards compatible to 83xx, 84xx, 87xx, 88xx, and 92xx controllers."
	echo "5.5 firmware is only compatible with 9265/9266/9285 controllers."
	echo "4.9 firmware is only compatible with 9260/9261/9280 controllers."
	echo ""
	echo "HBA/MegaRAID Drivers/FW/Utilities/Docs"
	echo "http://www.lsi.com/channel/ChannelDownloads/"
	echo ""
	echo "Check the ftp site for code updates as well, the MegaRAID Web site updates lag sometimes."
	echo "FTP Site - 3ware/HBA/MegaRAID"
	echo "ftp0.lsil.com"
	echo "User:tsupport"
	echo "Password:tsupport"
	echo "/outgoing_perm/Official_MegaRAID_Releases/"
	echo ""
	echo "HBA -"
	echo ""
	echo "This script should run with any LSI HBA using an mpt based driver."
	echo ""
	echo "Capture Script Version: $Capture_Script_Version"
	echo ""
	if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
		date '+%H:%M:%S.%N'
	fi
	if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
		date '+%H:%M:%S'
	fi
	exit
fi
	

###########################################################################################################################
# Comment check
###########################################################################################################################

if [ "$TWPROMPTFORCOMMENT" != "NO" ] ; then

	#Update on Code Set Change
	#cho ".................................................||................................................."
	echo ""
	echo "\"$BASECMD -H\" provides a help screen."
	echo ""
	echo "To associate a user comment with this data capture session pass the comment as a variable."
	#echo "comment as a variable." 
	echo ""						  
	echo "Example;"
	echo "$BASECMD \"Case 123456-123456789 – performance problems after upgrade\""
	echo ""
	echo 'NOTE: Noncontiguous strings must be in double quotes "My Comments".' 	  
	echo ""
	echo ""
	 
	WaitContinueOrQuit

fi


###########################################################################################################################
# Set architecture, i.e. check to see if 64-bit or 32 bit
###########################################################################################################################

if [ `uname -m | $grep 64` ] ; then
	Arch32or64=64
	else
	Arch32or64=32
fi

###########################################################################################################################
# Clean up
###########################################################################################################################


	for i in re_execute_variable_shell.txt CtDbg.log MegaSAS.log CmdTool.log lsut MegaRAID_Terminology.txt Build_all_driver_source.sh Sense-Key_ASC-ASCQ_Opcodes_SBC4R16.txt cversions_3w.txt cversions_MR.txt cversions_HBA.txt create  freebsd_tw_cli.32 freebsd_tw_cli.64 lsut32 lsut64 linux_lsut.32 linux_lsut.64 linux_tw_cli.32 linux_tw_cli.64 macos_tw_cli.32 solaris_lsut.i386 solaris_storcli solaris_tw_cli.32 vmware_tw_cli.esxi dcli32 dcli64 freebsd_dcli.32 freebsd_dcli.64 linux_dcli.32 linux_dcli.64 solaris_dcli.i386 linux_storcli64 linux_storcli linux_libstorelibir-2.so.14.07-0 solaris_storcli vmware_storcli vmware_libstorelib.so freebsd_storcli64 freebsd_storcli ; do
	if [ -f ./$i ] ; then
		rm -f ./$i
	fi
done


CLEANED_UP=YES

###########################################################################################################################
# Unpack files - Gunzip used as tar -zxvf not supported on Solaris
###########################################################################################################################

if [ -f ./all_cli ] ; then
	gunzip < all_cli | tar xvf - > /dev/null 2>&1
fi

CLEANED_UP=NO

###########################################################################################################################
# Rename appropriate 3ware cli based on OS type
###########################################################################################################################

if [ "$OS_LSI" = "linux" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		mv -f linux_tw_cli.64 tw_cli
	fi
	if [ "$Arch32or64" = "32" ] ; then
		mv -f linux_tw_cli.32 tw_cli
	fi
fi

if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		mv -f vmware_tw_cli.esxi tw_cli
	fi
	if [ "$Arch32or64" = "32" ] ; then
		mv -f vmware_tw_cli.esxi tw_cli
	fi
fi

if [ "$OS_LSI" = "freebsd" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		mv -f freebsd_tw_cli.64 tw_cli
	fi
	if [ "$Arch32or64" = "32" ] ; then
		mv -f freebsd_tw_cli.32 tw_cli
	fi
fi

# Only 32bit CLI as of 10.2.2.1
if [ "$OS_LSI" = "macos" ] ; then
	mv -f macos_tw_cli.32 tw_cli
fi

if [ "$OS_LSI" = "solaris" ] ; then
	mv -f solaris_tw_cli.32 tw_cli
fi

###########################################################################################################################
# Use the bundled tw_cli, if it doesn't work try the existing tw_cli.
###########################################################################################################################


./tw_cli help > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
	#Bundled tw_cli didn't execute or driver not loaded
	tw_cli_Bundled_work=NO
	else
	#Bundled tw_cli executed
	tw_cli_Bundled_work=YES
fi

if [ "$tw_cli_Bundled_work" = "YES" ]; then
	./tw_cli show | $grep "No controller found" > /dev/null 2>&1
	if [ "$?" -eq "0" ]; then
		#Bundled tw_cli didn't work or driver not loaded
		tw_cli_Bundled_work=NO
		else
		#Bundled tw_cli worked
		tw_cli_Bundled_work=YES
	fi
fi

###########################################################################################################################
# Check tw_cli existing version 
###########################################################################################################################

{ tw_cli help > /dev/null 2>&1; } 2>/dev/null
if [ "$?" -eq "0" ]; then
	#Existing tw_cli present
	tw_cli_Existing=YES
	else
	#Existing tw_cli not present
	tw_cli_Existing=NO
fi

if [ "$tw_cli_Existing" = "YES" ]; then
	tw_cli show 2>&1 | $grep "No controller found" > /dev/null 2>&1
	if [ "$?" -eq "0" ]; then
		#Existing tw_cli didn't work or driver not loaded
		tw_cli_Existing_work=NO
		else
		#Existing tw_cli worked
		tw_cli_Existing_work=YES
	fi
fi

if [ "$tw_cli_Bundled_work" = "YES" ]; then 
	CLI_LOCATION=./
	tw_cli_Functional=YES
	else
	if [ "$tw_cli_Existing_work" = "YES" ]; then 
		CLI_LOCATION=
		tw_cli_Functional=YES
		else
		tw_cli_Functional=NO 
	fi
fi


###########################################################################################################################
# Rename appropriate MegaRAID cli based on OS type
###########################################################################################################################


if [ "$OS_LSI" = "linux" ] ; then
	mv -f linux_libstorelibir-2.so.14.07-0 libstorelibir-2.so.14.07-0
	if [ "$Arch32or64" = "64" ] ; then
		MCLI_NAME64=linux_storcli64
		MCLI_NAME32=linux_storcli 
		./$MCLI_NAME64 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
		if [ "$?" = "0" ]; then
			mv -f linux_storcli64 storcli64
			MCLI_NAME=storcli64
			#Bundled cli executed
			mcli_Bundled_work=YES
			else
			./$MCLI_NAME32 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
			if [ "$?" = "0" ]; then
				mv -f linux_storcli storcli
				MCLI_NAME=storcli
				#Bundled cli executed
				mcli_Bundled_work=YES
			fi
		fi
		if [ "$MCLI_NAME" = " " ] ; then 
			#Bundled cli did not execute
			mcli_Bundled_work=NO
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		MCLI_NAME32=linux_storcli 
		./$MCLI_NAME32 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
		if [ "$?" = "0" ]; then
			mv -f linux_storcli storcli
			MCLI_NAME=storcli
			#Bundled cli executed
			mcli_Bundled_work=YES
		fi
		if [ "$MCLI_NAME" = " " ] ; then 
			#Bundled cli did not execute
			mcli_Bundled_work=NO
		fi			
	fi
fi

if [ "$OS_LSI" = "freebsd" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		MCLI_NAME64=freebsd_storcli64
		MCLI_NAME32=freebsd_storcli 
		./$MCLI_NAME64 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
		if [ "$?" = "0" ]; then
			mv -f freebsd_storcli64 storcli64
			MCLI_NAME=storcli64
			#Bundled cli executed
			mcli_Bundled_work=YES
			else
			./$MCLI_NAME32 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
			if [ "$?" = "0" ]; then
				mv -f freebsd_storcli storcli
				MCLI_NAME=storcli
				#Bundled cli executed
				mcli_Bundled_work=YES
			fi
		fi
		if [ "$MCLI_NAME" = " " ] ; then 
			#Bundled cli did not execute
			mcli_Bundled_work=NO
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		MCLI_NAME32=freebsd_storcli 
		./$MCLI_NAME32 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
		if [ "$?" = "0" ]; then
			mv -f freebsd_storcli storcli
			MCLI_NAME=storcli
			#Bundled cli executed
			mcli_Bundled_work=YES
		fi
		if [ "$MCLI_NAME" = " " ] ; then 
			#Bundled cli did not execute
			mcli_Bundled_work=NO
		fi			
	fi
fi


#Only 32bit currently
if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
	mv -f vmware_libstorelib.so libstorelib.so
	if [ "$Arch32or64" = "64" ] ; then
		MCLI_NAME64=vmware_storcli
		MCLI_NAME32=vmware_storcli 
		./$MCLI_NAME64 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
		if [ "$?" = "0" ]; then
			mv -f vmware_storcli storcli
			MCLI_NAME=storcli
			#Bundled cli executed
			mcli_Bundled_work=YES
			else
			./$MCLI_NAME32 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
			if [ "$?" = "0" ]; then
				mv -f vmware_storcli storcli
				MCLI_NAME=storcli
				#Bundled cli executed
				mcli_Bundled_work=YES
			fi
		fi
		if [ "$MCLI_NAME" = " " ] ; then 
			#Bundled cli did not execute
			mcli_Bundled_work=NO
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		MCLI_NAME32=vmware_storcli 
		./$MCLI_NAME32 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
		if [ "$?" = "0" ]; then
			mv -f vmware_storcli storcli
			MCLI_NAME=storcli
			#Bundled cli executed
			mcli_Bundled_work=YES
		fi
		if [ "$MCLI_NAME" = " " ] ; then 
			#Bundled cli did not execute
			mcli_Bundled_work=NO
		fi			
	fi
fi

#Only 32bit currently
if [ "$OS_LSI" = "solaris" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		MCLI_NAME64=solaris_storcli
		MCLI_NAME32=solaris_storcli 
		./$MCLI_NAME64 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
		if [ "$?" = "0" ]; then
			mv -f solaris_storcli storcli
			MCLI_NAME=storcli
			#Bundled cli executed
			mcli_Bundled_work=YES
			else
			./$MCLI_NAME32 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
			if [ "$?" = "0" ]; then
				mv -f solaris_storcli storcli
				MCLI_NAME=storcli
				#Bundled cli executed
				mcli_Bundled_work=YES
			fi
		fi
		if [ "$MCLI_NAME" = " " ] ; then 
			#Bundled cli did not execute
			mcli_Bundled_work=NO
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		MCLI_NAME32=solaris_storcli 
		./$MCLI_NAME32 adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1
		if [ "$?" = "0" ]; then
			mv -f solaris_storcli storcli
			MCLI_NAME=storcli
			#Bundled cli executed
			mcli_Bundled_work=YES
		fi
		if [ "$MCLI_NAME" = " " ] ; then 
			#Bundled cli did not execute
			mcli_Bundled_work=NO
		fi			
	fi
fi

###########################################################################################################################
# Use the bundled MegaCli, if it doesn't work try the existing MegaCli
###########################################################################################################################
if [ "$OS_LSI" != "macos" ] ; then


	if [ "$mcli_Bundled_work" = "YES" ]; then
		./$MCLI_NAME adpcount nolog | $grep "Controller Count: 0." > /dev/null 2>&1
		if [ "$?" = "0" ]; then
			mcli_Functional=NO
			else
			mcli_Functional=YES
		fi
	fi

###########################################################################################################################
# Check existing version - Only checks for MegaCli in path, doesn't look in /opt/MegaRAID/MegaCli
###########################################################################################################################

	{ $MCLI_NAME adpcount nolog | $grep "Controller Count:" > /dev/null 2>&1; } 2>/dev/null
	if [ "$?" = "0" ]; then
	#Existing cli present
		mcli_Existing=YES
		else
	#Existing cli not present
		mcli_Existing=NO
	fi
	
	if [ "$mcli_Existing" = "YES" ]; then
		$MCLI_NAME adpcount nolog | $grep "Controller Count: 0." > /dev/null 2>&1
		if [ "$?" = "0" ]; then
	#Existing cli didn't work or driver not loaded
			mcli_Existing_work=NO
			else
	#Existing cli worked
			mcli_Existing_work=YES
		fi
	fi
	
	if [ "$mcli_Bundled_work" = "YES" ]; then 
		MCLI_LOCATION=./
		mcli_Functional=YES
		else
			if [ "$mcli_Existing_work" = "YES" ]; then 
				MCLI_LOCATION=
				mcli_Functional=YES
				else
				mcli_Functional=NO 
			fi
	fi

# Return if MacOS
fi


###########################################################################################################################
# Extract appropriate internal util based on OS type
###########################################################################################################################

if [ "$OS_LSI" = "linux" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		LSUT_NAME64=linux_lsut.64
		LSUT_NAME32=linux_lsut.32
		./$LSUT_NAME64 0 2>/dev/null | $grep "Chip Vendor" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f linux_lsut.64 lsut64
			LSUT_NAME=lsut64
			#Bundled cli executed
			lsut_Bundled_work=YES
			NO_LSI_HBAs=NO
			else
			./$LSUT_NAME32 0 2>/dev/null | $grep "Chip Vendor" 1>/dev/null 
			if [ "$?" = "0" ]; then
				mv -f linux_lsut.32 lsut32
				LSUT_NAME=lsut32
				#Bundled cli executed
				lsut_Bundled_work=YES
				NO_LSI_HBAs=NO
			fi
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			lsut_Bundled_work=NO
			NO_LSI_HBAs=YES
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		LSUT_NAME32=linux_lsut.32
		./$LSUT_NAME32 0 2>/dev/null | $grep "Chip Vendor" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f linux_lsut.32 lsut32
			LSUT_NAME=lsut32
			#Bundled cli executed
			lsut_Bundled_work=YES
			NO_LSI_HBAs=NO
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			lsut_Bundled_work=NO
			NO_LSI_HBAs=YES
		fi			
	fi
fi

#Useing 32bit linux lsut
if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		LSUT_NAME64=linux_lsut.32
		LSUT_NAME32=linux_lsut.32
		./$LSUT_NAME64 0 2>/dev/null | $grep "Chip Vendor" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f linux_lsut.32 lsut32
			LSUT_NAME=lsut32
			#Bundled cli executed
			lsut_Bundled_work=YES
			NO_LSI_HBAs=NO
			else
			./$LSUT_NAME32 0 2>/dev/null | $grep "Chip Vendor" 1>/dev/null 
			if [ "$?" = "0" ]; then
				mv -f linux_lsut.32 lsut32
				LSUT_NAME=lsut32
				#Bundled cli executed
				lsut_Bundled_work=YES
				NO_LSI_HBAs=NO
			fi
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			lsut_Bundled_work=NO
			NO_LSI_HBAs=YES
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		LSUT_NAME32=linux_lsut.32
		./$LSUT_NAME32 0 2>/dev/null | $grep "Chip Vendor" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f linux_lsut.32 lsut32
			LSUT_NAME=lsut32
			#Bundled cli executed
			lsut_Bundled_work=YES
			NO_LSI_HBAs=NO
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			lsut_Bundled_work=NO
			NO_LSI_HBAs=YES
		fi			
	fi
fi


if [ "$OS_LSI" = "solaris" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		LSUT_NAME64=solaris_lsut.i386
		LSUT_NAME32=solaris_lsut.i386
		./$LSUT_NAME64 0 2>/dev/null | $grep "Chip Vendor" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f solaris_lsut.i386 lsut32
			LSUT_NAME=lsut32
			#Bundled cli executed
			lsut_Bundled_work=YES
			NO_LSI_HBAs=NO
			else
			./$LSUT_NAME32 0 2>/dev/null | $grep "Chip Vendor" 1>/dev/null 
			if [ "$?" = "0" ]; then
				mv -f solaris_lsut.i386 lsut32
				LSUT_NAME=lsut32
				#Bundled cli executed
				lsut_Bundled_work=YES
				NO_LSI_HBAs=NO
			fi
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			lsut_Bundled_work=NO
			NO_LSI_HBAs=YES
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		LSUT_NAME32=solaris_lsut.i386
		./$LSUT_NAME32 0 2>/dev/null | $grep "Chip Vendor" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f solaris_lsut.i386 lsut32
			LSUT_NAME=lsut32
			#Bundled cli executed
			lsut_Bundled_work=YES
			NO_LSI_HBAs=NO
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			lsut_Bundled_work=NO
			NO_LSI_HBAs=YES
		fi			
	fi
fi



###########################################################################################################################
# Extract appropriate ddcli based on OS type
###########################################################################################################################

if [ "$OS_LSI" = "linux" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		DCLI_NAME64=linux_dcli.64
		DCLI_NAME32=linux_dcli.32
		./$DCLI_NAME64 0 2>/dev/null | $grep "LSI WarpDrive Management Utility:" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f linux_dcli.64 dcli64
			DCLI_NAME=dcli64
			#Bundled cli executed
			dcli_Bundled_work=YES
			else
			./$DCLI_NAME32 0 2>/dev/null | $grep "LSI WarpDrive Management Utility:" 1>/dev/null 
			if [ "$?" = "0" ]; then
				mv -f linux_dcli.32 dcli32
				DCLI_NAME=lsut32
				#Bundled cli executed
				dcli_Bundled_work=YES
			fi
		fi
		if [ "$DCLI_NAME" = " " ] ; then 
			#Bundled cli did not execute
			dcli_Bundled_work=NO
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		DCLI_NAME32=linux_dcli.32
		./$DCLI_NAME32 0 2>/dev/null | $grep "LSI WarpDrive Management Utility:" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f linux_dcli.32 dcli32
			DCLI_NAME=lsut32
			#Bundled cli executed
			dcli_Bundled_work=YES
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			dcli_Bundled_work=NO
		fi			
	fi
fi

if [ "$OS_LSI" = "freebsd" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		DCLI_NAME64=freebsd_dcli.64
		DCLI_NAME32=freebsd_dcli.32
		./$DCLI_NAME64 0 2>/dev/null | $grep "LSI WarpDrive Management Utility:" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f freebsd_dcli.64 dcli64
			DCLI_NAME=dcli64
			#Bundled cli executed
			dcli_Bundled_work=YES
			else
			./$DCLI_NAME32 0 2>/dev/null | $grep "LSI WarpDrive Management Utility:" 1>/dev/null 
			if [ "$?" = "0" ]; then
				mv -f freebsd_dcli.32 dcli32
				DCLI_NAME=lsut32
				#Bundled cli executed
				dcli_Bundled_work=YES
			fi
		fi
		if [ "$DCLI_NAME" = " " ] ; then 
			#Bundled cli did not execute
			dcli_Bundled_work=NO
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		DCLI_NAME32=freebsd_dcli.32
		./$DCLI_NAME32 0 2>/dev/null | $grep "LSI WarpDrive Management Utility:" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f freebsd_dcli.32 dcli32
			DCLI_NAME=lsut32
			#Bundled cli executed
			dcli_Bundled_work=YES
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			dcli_Bundled_work=NO
		fi			
	fi
fi

if [ "$OS_LSI" = "solaris" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		DCLI_NAME64=solaris_dcli.i386
		DCLI_NAME32=solaris_dcli.i386
		./$DCLI_NAME64 0 2>/dev/null | $grep "LSI WarpDrive Management Utility:" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f solaris_dcli.i386 dcli32
			DCLI_NAME=dcli32
			#Bundled cli executed
			dcli_Bundled_work=YES
			else
			./$DCLI_NAME32 0 2>/dev/null | $grep "LSI WarpDrive Management Utility:" 1>/dev/null 
			if [ "$?" = "0" ]; then
				mv -f solaris_dcli.i386 dcli32
				DCLI_NAME=lsut32
				#Bundled cli executed
				dcli_Bundled_work=YES
			fi
		fi
		if [ "$DCLI_NAME" = " " ] ; then 
			#Bundled cli did not execute
			dcli_Bundled_work=NO
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		DCLI_NAME32=freebsd_dcli.32
		./$DCLI_NAME32 0 2>/dev/null | $grep "LSI WarpDrive Management Utility:" 1>/dev/null 
		if [ "$?" = "0" ]; then
			mv -f solaris_dcli.i386 dcli32
			DCLI_NAME=lsut32
			#Bundled cli executed
			dcli_Bundled_work=YES
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			dcli_Bundled_work=NO
		fi			
	fi
fi


###########################################################################################################################
# IF tw_cli and MegaCli not functional
###########################################################################################################################
	
if [ "$tw_cli_Functional" = "NO" ]; then
	if [ "$mcli_Functional" = "NO" ]; then
		if [ "$NO_LSI_HBAs" = "YES" ]; then
			### 
			#cho ".................................................||................................................."
			echo "...................................................................................................."
			echo "################## No CLI installed, or CLI incompatible -- CLI will not be used. ##################"
			echo "################################################ OR ################################################"
			echo "################# You do not have root privileges which are required to run the CLI ################"
			echo ""
			echo "\"$BASECMD -H\" provides a help screen."
			echo ""
###########################################################################################################################
# Done with MegaCli!
###########################################################################################################################

###########################################################################################################################
# Clean up
###########################################################################################################################



				for i in re_execute_variable_shell.txt CtDbg.log MegaSAS.log CmdTool.log lsut MegaRAID_Terminology.txt Build_all_driver_source.sh Sense-Key_ASC-ASCQ_Opcodes_SBC4R16.txt cversions_3w.txt cversions_MR.txt cversions_HBA.txt create  freebsd_tw_cli.32 freebsd_tw_cli.64 lsut32 lsut64 linux_lsut.32 linux_lsut.64 linux_tw_cli.32 linux_tw_cli.64 macos_tw_cli.32 solaris_lsut.i386 solaris_storcli solaris_tw_cli.32 vmware_tw_cli.esxi dcli32 dcli64 freebsd_dcli.32 freebsd_dcli.64 linux_dcli.32 linux_dcli.64 solaris_dcli.i386 linux_storcli64 linux_storcli linux_libstorelibir-2.so.14.07-0 solaris_storcli vmware_storcli vmware_libstorelib.so freebsd_storcli64 freebsd_storcli ; do
				if [ -f ./$i ] ; then
					rm -f ./$i
				fi
			done

CLEANED_UP=YES

				if [ "$TWGETBATCHMODE" != "BATCH" ] ; then
					WaitContinueOrQuit
				fi
		fi
	fi
fi

###########################################################################################################################
# Unpack files - Chose to Continue
###########################################################################################################################

if [ -f ./all_cli ] ; then
	gunzip < all_cli | tar xvf - > /dev/null 2>&1
fi

CLEANED_UP=NO


###########################################################################################################################
# Create unique file/subdirectory name
###########################################################################################################################

if [ "$OS_LSI" = "linux" ]; then tw_host=$HOSTNAME; fi
if [ "$VMWARE_SUPPORTED" = "YES" ]; then tw_host=`hostname`; fi
if [ "$OS_LSI" = "freebsd" ]; then tw_host=$HOST; fi
if [ "$OS_LSI" = "macos" ]; then tw_host=$HOSTNAME; fi
if [ "$OS_LSI" = "solaris" ]; then tw_host=`hostname`; fi

tw_hostname=`echo $tw_host | cut -d. -f1`
todayDate=`date '+DATE:%m%d%y' | cut -d: -f2`
currentTime=`date '+TIME:%H%M%S' | cut -d: -f2`

if [ "$TWGETPARTIALMODE" = "STANDARD" ] ; then TWdescriptor=lsi; fi
if [ "$TWGETPARTIALMODE" = "G_AEC" ] ; then TWdescriptor=AEC; fi
if [ "$TWGETPARTIALMODE" = "G_DPMSTAT" ] ; then TWdescriptor=DPMSTAT; fi
if [ "$TWGETPARTIALMODE" = "G_AEC_DPMSTAT" ] ; then TWdescriptor=AEC_DPMSTAT; fi
if [ "$TWGETMONITORMODE" = "MONITOR" ] ; then TWdescriptor=MONITOR; fi

fileName=$TWdescriptor.$OS_LSI.$tw_hostname.$todayDate.$currentTime

###########################################
# 3W - Not required for Enable Feature switches
###########################################
if [ "$TWGETPARTIALMODE" != "E_DPMSTAT" ]; then
	if [ "$TWGETPARTIALMODE" != "E_AEC" ]; then
		if [ "$TWGETPARTIALMODE" != "E_AEC_DPMSTAT" ]; then
#

			mkdir $fileName
			mkdir $fileName/script_workspace
			mkdir $fileName/LSI_Products
			mkdir $fileName/LSI_Products/3ware
			mkdir $fileName/LSI_Products/MegaRAID
			mkdir $fileName/LSI_Products/MegaRAID/Notes_Scripts
			mkdir $fileName/LSI_Products/MegaRAID/storcli
			mkdir $fileName/LSI_Products/MegaRAID/MegaCli
			mkdir $fileName/LSI_Products/MegaRAID/AENs
			mkdir $fileName/LSI_Products/MegaRAID/FWTermLog
			mkdir $fileName/LSI_Products/HBA
			

			if [ "$CLEANED_UP" = "NO" ]; then
				cp cversions_3w.txt ./$fileName/script_workspace
				cp cversions_MR.txt ./$fileName/script_workspace
				cp cversions_HBA.txt ./$fileName/script_workspace
				cp $BASECMD ./$fileName/script_workspace
				cp Sense-Key_ASC-ASCQ_Opcodes_SBC4R16.txt ./$fileName/script_workspace
				if [ "$OS_LSI" = "linux" ] ; then	
					cp Build_all_driver_source.sh ./$fileName/LSI_Products/MegaRAID/Notes_Scripts
				fi
				cp MegaRAID_Terminology.txt ./$fileName/LSI_Products/MegaRAID/Notes_Scripts
			fi

			if [ "$TWPRINTFILENAME" = "YES" ]; then echo $fileName.tar.gz >> LSICAPTUREFILES.TXT; fi



###########################################################################################################################
# 3W - Rename any old AEC files
###########################################################################################################################
			for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ; do #Support for Controller IDs 0-15
				if [ -f evtcapture_c$i.dat ]; then OLD_EVT_CAP_EXIST=YES > /dev/null 2>&1 ; fi	
			
				if [ "$OLD_EVT_CAP_EXIST" = "YES" ]; then 
					if [ ! -d PreExisting_AEC_$fileName ]; then mkdir PreExisting_AEC_$fileName ; fi	
				fi
			
				if [ -f evtcapture_c$i.dat ]; then mv evtcapture_c$i.dat PreExisting_AEC_$fileName > /dev/null 2>&1 ; fi
			
			done

###########################################################################################################################
# MR - Rename any old AEC files
# Reuseing OLD_EVT_CAP_EXIST= variable from 3w, any error should get piped to /dev/null on missing file
###########################################################################################################################
			if [ "$OS_LSI" != "macos" ] ; then
			
				for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ; do #Support for Adapter IDs 0-15
					if [ -f evtcapture_a$i.dat ]; then OLD_EVT_CAP_EXIST=YES > /dev/null 2>&1 ; fi	
				
					if [ "$OLD_EVT_CAP_EXIST" = "YES" ]; then 
						if [ ! -d PreExisting_AEC_$fileName ]; then mkdir PreExisting_AEC_$fileName ; fi	
					fi
				
					if [ -f evtcapture_a$i.dat ]; then mv evtcapture_a$i.dat PreExisting_AEC_$fileName > /dev/null 2>&1 ; fi
				
				done
			fi
###########################################################################################################################
# 3W - For G_*
# Disabling and Getting Advanced Event Capture (AEC) IF Enabled
# Advanced Event Capture must be first or the log gets filled with IOCTLs
###########################################################################################################################
			if [ "$TWGETPARTIALMODE" != "STANDARD" ]; then
				if [ "$TWGETPARTIALMODE" != "G_DPMSTAT" ]; then

					for i in $($CLI_LOCATION$CLI_NAME show | $grep ^c | cut -b 2-3); do #Support for Controller IDs 0-99
						if $CLI_LOCATION$CLI_NAME /c$i show capture 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "  State =" > /dev/null 2>&1 ; then
							$CLI_LOCATION$CLI_NAME /c$i set capture=stop > /dev/null 2>&1	 
							$CLI_LOCATION$CLI_NAME /c$i get capture > /dev/null 2>&1
							$CLI_LOCATION$CLI_NAME /c$i set capture=disable > /dev/null 2>&1
							if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
							if [ ! -d ./$fileName/LSI_Products/3ware/AEC ];then mkdir ./$fileName/LSI_Products/3ware/AEC ; fi
						
							if [ -f evtcapture_c$i.dat ]; then mv evtcapture_c$i.dat ./$fileName/LSI_Products/3ware/AEC > /dev/null 2>&1 ; fi
							TW_ECHO_AEC=YES
						fi
					done

###########################################################################################################################
# MR - For G_*
# Disabling and Getting Advanced Event Capture (AEC) IF Enabled
# Advanced Event Capture must be first or the log gets filled with IOCTLs
###########################################################################################################################

					if [ "$OS_LSI" != "macos" ] ; then
					
# storcli syntax not available for aec/dpmstat
						
						for i in $($CLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
							if $CLI_LOCATION$MCLI_NAME adpaec show a$i nolog 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "AEC enabled :" > /dev/null 2>&1 ; then
								$CLI_LOCATION$MCLI_NAME  adpaec stop a$i nolog > /dev/null 2>&1	 
								$CLI_LOCATION$MCLI_NAME adpaec get -f evtcapture_a$i.dat a$i nolog > /dev/null 2>&1
								$CLI_LOCATION$MCLI_NAME adpaec disable a$i nolog > /dev/null 2>&1
							
								if [ ! -d ./$fileName/LSI_Products/MegaRAID/AEC ];then mkdir ./$fileName/LSI_Products/MegaRAID/AEC ; fi
							
								if [ -f evtcapture_a$i.dat ]; then mv evtcapture_a$i.dat ./$fileName/LSI_Products/MegaRAID/AEC > /dev/null 2>&1 ; fi
								MR_ECHO_AEC=YES
							fi
						done
					
					fi

###

					if [ "$TW_ECHO_AEC" = "YES" ]; then
						echo "Disabling and Getting Advanced Event Capture (AEC) for 3ware....."
					fi
					
					if [ "$MR_ECHO_AEC" = "YES" ]; then
						echo "Disabling and Getting Advanced Event Capture (AEC) for MegaRAID....."
					fi

###########################################
# Return for TWGETPARTIALMODE != STANDARD & G_DPMSTAT
###########################################
				fi
			fi 
#

###########################################################################################################################
# 3W - Standard
# Disabling and Getting Advanced Event Capture (AEC) IF Enabled
# Advanced Event Capture must be first or the log gets filled with IOCTLs
###########################################################################################################################
			if [ "$TWGETPARTIALMODE" != "G_AEC" ]; then
				if [ "$TWGETPARTIALMODE" != "G_AEC_DPMSTAT" ]; then
					if [ "$TWGETPARTIALMODE" != "G_DPMSTAT" ]; then
			
						for i in $($CLI_LOCATION$CLI_NAME show | $grep ^c | cut -b 2-3); do #Support for Controller IDs 0-99
							if $CLI_LOCATION$CLI_NAME /c$i show capture 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "  State = Enabled" > /dev/null 2>&1 ; then
								$CLI_LOCATION$CLI_NAME /c$i set capture=stop > /dev/null 2>&1	 
								$CLI_LOCATION$CLI_NAME /c$i get capture > /dev/null 2>&1
								$CLI_LOCATION$CLI_NAME /c$i set capture=disable > /dev/null 2>&1
								if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi							
								if [ ! -d ./$fileName/LSI_Products/3ware/AEC ];then mkdir ./$fileName/LSI_Products/3ware/AEC ; fi
							
								if [ -f evtcapture_c$i.dat ]; then mv evtcapture_c$i.dat ./$fileName/LSI_Products/3ware/AEC > /dev/null 2>&1 ; fi
								TW_ECHO_AEC=YES
							fi
						done

###########################################################################################################################
# MR - Standard
# Disabling and Getting Advanced Event Capture (AEC) IF Enabled
# Advanced Event Capture must be first or the log gets filled with IOCTLs
###########################################################################################################################

						if [ "$OS_LSI" != "macos" ] ; then
						
							for i in $($CLI_LOCATION$MCLI_NAME show  | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
								if $CLI_LOCATION$MCLI_NAME adpaec show  a$i nolog 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "AEC enabled : Yes" > /dev/null 2>&1 ; then
									$CLI_LOCATION$MCLI_NAME adpaec stop a$i nolog > /dev/null 2>&1	 
									$CLI_LOCATION$MCLI_NAME adpaec get -f evtcapture_a$i.dat a$i nolog > /dev/null 2>&1
									$CLI_LOCATION$MCLI_NAME adpaec disable a$i nolog > /dev/null 2>&1
									
									if [ ! -d ./$fileName/LSI_Products/MegaRAID/AEC ];then mkdir ./$fileName/LSI_Products/MegaRAID/AEC ; fi
									
									if [ -f evtcapture_a$i.dat ]; then mv evtcapture_a$i.dat ./$fileName/LSI_Products/MegaRAID/AEC > /dev/null 2>&1 ; fi
									MR_ECHO_AEC=YES
								fi
							done
						 
						fi

###

						if [ "$TW_ECHO_AEC" = "YES" ]; then
							echo "Disabling and Getting Advanced Event Capture (AEC) for 3ware....."
						fi
						
						if [ "$MR_ECHO_AEC" = "YES" ]; then
							echo "Disabling and Getting Advanced Event Capture (AEC) for MegaRAID....."
						fi

###########################################
# 3W - Return for skipping Standard AEC Get
###########################################
					fi  
				fi 
			fi
	


###########################################
# 3W - Return for skipping mkdir & Disable/Get AEC
###########################################
		fi # E_AEC_DPMSTAT
	fi # E_AEC

	

###########################################
# Not required for 
###########################################
	if [ "$TWGETPARTIALMODE" != "G_AEC" ]; then
		if [ "$TWGETPARTIALMODE" != "G_AEC_DPMSTAT" ]; then
			if [ "$TWGETPARTIALMODE" != "G_DPMSTAT" ]; then
				if [ "$TWGETPARTIALMODE" != "E_DPMSTAT" ]; then
					if [ "$TWGETPARTIALMODE" != "STANDARD" ]; then
	

###########################################################################################################################
# 3W - Clearing and Enabling Advanced Event Capture (AEC)
###########################################################################################################################

						if [ "$tw_cli_Functional" != "NO" ]; then
	
							echo "Clearing and Enabling Advanced Event Capture (AEC) for 3ware..."
							for i in $($CLI_LOCATION$CLI_NAME show | $grep ^c | cut -b 2-3); do #Support for Controller IDs 0-99
								if $CLI_LOCATION$CLI_NAME /c$i set capture=disable > /dev/null 2>&1; then	 
									$CLI_LOCATION$CLI_NAME /c$i set capture=enable numevents=150000 > /dev/null 2>&1 
									$CLI_LOCATION$CLI_NAME /c$i set capturemode=stopped > /dev/null 2>&1 
									$CLI_LOCATION$CLI_NAME /c$i set capture=start > /dev/null 2>&1
								fi
							done
							
						fi

###########################################################################################################################
# MR - Clearing and Enabling Advanced Event Capture (AEC)
###########################################################################################################################

						if [ "$OS_LSI" != "macos" ] ; then
						
							if [ "$mcli_Functional" != "NO" ]; then
							
								echo "Clearing and Enabling Advanced Event Capture (AEC) for MegaRAID..."
								for i in $($CLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
									if $CLI_LOCATION$MCLI_NAME adpaec disable a$i nolog > /dev/null 2>&1; then	 
										$CLI_LOCATION$MCLI_NAME adpaec start numevents 150000 a$i nolog > /dev/null 2>&1 
									fi
								done
							
							fi
						
						fi
	
						if [ "$tw_cli_Functional" = "NO" ]; then
							if [ "$mcli_Functional" = "NO" ]; then
								#cho ".................................................||................................................."
								echo "...................................................................................................."
								echo "################## No CLI installed, or CLI incompatible -- CLI will not be used. ##################"
								echo "################################################ OR ################################################"
								echo "################# You do not have root privileges which are required to run tw_cli. ################"
								echo ""
								echo "\"$BASECMD -H\" provides a help screen."
								echo ""
							fi
						fi
###########################################
# Return for skipping Clear & Enable AEC
###########################################
					fi # STANDARD
				fi # E_DPMSTAT
			fi # G_DPMSTAT
		fi # G_AEC_DPMSTAT
	fi # G_AEC


###########################################
# If E_AEC exit
###########################################
	if [ "$TWGETPARTIALMODE" = "E_AEC" ]; then 
		if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
			date '+%H:%M:%S.%N'
		fi
		if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
			date '+%H:%M:%S'
		fi

###########################################################################################################################
# Clean up
###########################################################################################################################


			for i in re_execute_variable_shell.txt CtDbg.log MegaSAS.log CmdTool.log lsut MegaRAID_Terminology.txt Build_all_driver_source.sh Sense-Key_ASC-ASCQ_Opcodes_SBC4R16.txt cversions_3w.txt cversions_MR.txt cversions_HBA.txt create  freebsd_tw_cli.32 freebsd_tw_cli.64 lsut32 lsut64 linux_lsut.32 linux_lsut.64 linux_tw_cli.32 linux_tw_cli.64 macos_tw_cli.32 solaris_lsut.i386 solaris_storcli solaris_tw_cli.32 vmware_tw_cli.esxi dcli32 dcli64 freebsd_dcli.32 freebsd_dcli.64 linux_dcli.32 linux_dcli.64 solaris_dcli.i386 linux_storcli64 linux_storcli linux_libstorelibir-2.so.14.07-0 solaris_storcli vmware_storcli vmware_libstorelib.so freebsd_storcli64 freebsd_storcli ; do
			if [ -f ./$i ] ; then
				rm -f ./$i
			fi
		done
		
		CLEANED_UP=YES
		
		exit 
	fi
#

###########################################
# Return for E_DPMSTAT
###########################################
fi # E_DPMSTAT
#

###########################################
# Not required for 
###########################################
if [ "$TWGETPARTIALMODE" != "G_AEC" ]; then
	if [ "$TWGETPARTIALMODE" != "G_AEC_DPMSTAT" ]; then
		if [ "$TWGETPARTIALMODE" != "G_DPMSTAT" ]; then
			if [ "$TWGETPARTIALMODE" != "STANDARD" ]; then
#

###########################################################################################################################
# 3W - Clearing and Enabling Disk Performance Monitoring Statistics (DPMSTAT) 
###########################################################################################################################

				if [ "$tw_cli_Functional" != "NO" ]; then

					echo "Clearing and Enabling Disk Performance Monitoring Statistics (DPMSTAT) for 3ware..."
					for i in $($CLI_LOCATION$CLI_NAME show | $grep ^c | cut -b 2-3); do #Support for Controller IDs 0-99
						if $CLI_LOCATION$CLI_NAME /c$i show pmstat 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "Instantaneous" > /dev/null 2>&1; then	 
					
							for l in $($CLI_LOCATION$CLI_NAME /c$i show 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep ^p | $grep -v NOT-PRESENT | cut -b 2-4); do #Supports up to 999 Ports per Controller.
								$CLI_LOCATION$CLI_NAME /c$i/p$l set pmstat=clear type=ra > /dev/null 2>&1 
								$CLI_LOCATION$CLI_NAME /c$i/p$l set pmstat=clear type=lct > /dev/null 2>&1 
								$CLI_LOCATION$CLI_NAME /c$i/p$l set pmstat=clear type=ext > /dev/null 2>&1 
							done
							$CLI_LOCATION$CLI_NAME /c$i set pmstat=on > /dev/null 2>&1 
						fi
					done
					
				fi

###########################################################################################################################
# MR - Clearing and Enabling Disk Performance Monitoring Statistics (DPMSTAT)
###########################################################################################################################

				if [ "$OS_LSI" != "macos" ] ; then
				
					if [ "$mcli_Functional" != "NO" ]; then
					
						echo "Clearing and Enabling Disk Performance Monitoring Statistics (DPMSTAT) for MegaRAID..."
						for i in $($CLI_LOCATION$MCLI_NAME show  | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
							if $CLI_LOCATION$MCLI_NAME adpgetprop dpmenable a$i nolog 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "DPM is " > /dev/null 2>&1; then	 
						
								$CLI_LOCATION$MCLI_NAME dpmstat clear lct a$i nolog > /dev/null 2>&1 
								$CLI_LOCATION$MCLI_NAME dpmstat clear hist a$i nolog > /dev/null 2>&1 
								$CLI_LOCATION$MCLI_NAME dpmstat clear ra a$i nolog > /dev/null 2>&1 
								$CLI_LOCATION$MCLI_NAME dpmstat clear ext a$i nolog > /dev/null 2>&1 
								$CLI_LOCATION$MCLI_NAME adpsetprop dpmenable 1 a$i nolog > /dev/null 2>&1 
						
							fi
						done
					
					fi
				
				fi


				if [ "$tw_cli_Functional" = "NO" ]; then
					if [ "$mcli_Functional" = "NO" ]; then
						#cho ".................................................||................................................."
						echo "...................................................................................................."
						echo "################## No CLI installed, or CLI incompatible -- CLI will not be used. ##################"
						echo "################################################ OR ################################################"
						echo "################# You do not have root privileges which are required to run tw_cli. ################"
						echo ""
						echo "\"$BASECMD -H\" provides a help screen."
						echo ""
					fi
				fi

###########################################
# If E_DPMSTAT or E_AEC_DPMSTAT exit
###########################################
				if [ "$TWGETPARTIALMODE" = "E_DPMSTAT" ]; then 
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N'
					fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S'
				fi

###########################################################################################################################
# Clean up
###########################################################################################################################


						for i in re_execute_variable_shell.txt CtDbg.log MegaSAS.log CmdTool.log lsut MegaRAID_Terminology.txt Build_all_driver_source.sh Sense-Key_ASC-ASCQ_Opcodes_SBC4R16.txt cversions_3w.txt cversions_MR.txt cversions_HBA.txt create  freebsd_tw_cli.32 freebsd_tw_cli.64 lsut32 lsut64 linux_lsut.32 linux_lsut.64 linux_tw_cli.32 linux_tw_cli.64 macos_tw_cli.32 solaris_lsut.i386 solaris_storcli solaris_tw_cli.32 vmware_tw_cli.esxi dcli32 dcli64 freebsd_dcli.32 freebsd_dcli.64 linux_dcli.32 linux_dcli.64 solaris_dcli.i386 linux_storcli64 linux_storcli linux_libstorelibir-2.so.14.07-0 solaris_storcli vmware_storcli vmware_libstorelib.so freebsd_storcli64 freebsd_storcli ; do
						if [ -f ./$i ] ; then
							rm -f ./$i
						fi
					done
					
					CLEANED_UP=YES
					
					exit
				fi
				if [ "$TWGETPARTIALMODE" = "E_AEC_DPMSTAT" ]; then 
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N'
					fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S'
				fi

###########################################################################################################################
# Clean up
###########################################################################################################################


						for i in re_execute_variable_shell.txt CtDbg.log MegaSAS.log CmdTool.log lsut MegaRAID_Terminology.txt Build_all_driver_source.sh Sense-Key_ASC-ASCQ_Opcodes_SBC4R16.txt cversions_3w.txt cversions_MR.txt cversions_HBA.txt create  freebsd_tw_cli.32 freebsd_tw_cli.64 lsut32 lsut64 linux_lsut.32 linux_lsut.64 linux_tw_cli.32 linux_tw_cli.64 macos_tw_cli.32 solaris_lsut.i386 solaris_storcli solaris_tw_cli.32 vmware_tw_cli.esxi dcli32 dcli64 freebsd_dcli.32 freebsd_dcli.64 linux_dcli.32 linux_dcli.64 solaris_dcli.i386 linux_storcli64 linux_storcli linux_libstorelibir-2.so.14.07-0 solaris_storcli vmware_storcli vmware_libstorelib.so freebsd_storcli64 freebsd_storcli ; do
						if [ -f ./$i ] ; then
							rm -f ./$i
						fi
					done
					
					CLEANED_UP=YES
					
					exit
				fi


###########################################
# Return for skipping Clear & Enable DPMSTAT
###########################################
			fi # STANDARD
		fi # G_DPMSTAT
	fi # G_AEC_DPMSTAT
fi # G_AEC
#


###########################################################################################################################
# 3W - PMSTAT Data Collection for G_*
###########################################################################################################################
if [ "$TWGETPARTIALMODE" != "E_AEC_DPMSTAT" ]; then 
	if [ "$TWGETPARTIALMODE" != "E_AEC" ]; then 
		if [ "$TWGETPARTIALMODE" != "E_DPMSTAT" ]; then 
			if [ "$TWGETPARTIALMODE" != "STANDARD" ]; then 
				if [ "$TWGETPARTIALMODE" != "G_AEC" ]; then


					for i in $($CLI_LOCATION$CLI_NAME show | $grep ^c | cut -b 2-3); do #Support for Controller IDs 0-99
						if $CLI_LOCATION$CLI_NAME /c$i show pmstat 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "Performance Monitor:" > /dev/null 2>&1 ; then
				
							TW_ECHO_PMSTAT=YES
							if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
							if [ ! -d ./$fileName/LSI_Products/3ware/PMSTAT ]; then mkdir ./$fileName/LSI_Products/3ware/PMSTAT ; fi
				
								$CLI_LOCATION$CLI_NAME /c$i set pmstat=off > /dev/null 2>&1 
						
						
				
								#cho ".................................................||................................................."
								echo ".................................../tw_cli /c$i show pmstat type=inst................................" >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_INST_C$i.txt
								$CLI_LOCATION$CLI_NAME /c$i show pmstat type=inst 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_INST_C$i.txt 2>&1
						
								#cho ".................................................||................................................."
								echo ".................................../tw_cli /c$i show pmstat type=ra.................................." >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_RA_C$i.txt
								$CLI_LOCATION$CLI_NAME /c$i show pmstat type=ra 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_RA_C$i.txt 2>&1
						
						
								#cho ".................................................||................................................."
								echo ".................................../tw_cli /c$i show pmstat type=ext................................." >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_EXT_C$i.txt
								$CLI_LOCATION$CLI_NAME /c$i show pmstat type=ext 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_EXT_C$i.txt 2>&1
						
								for l in $($CLI_LOCATION$CLI_NAME /c$i show 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep ^p | $grep -v NOT-PRESENT | cut -b 2-4); do #Supports up to 999 Ports per Controller.
									#cho ".................................................||................................................."
									echo "............................../tw_cli /c$i/p$l show pmstat type=histdata.............................." >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_HISTDATA_C$i.txt
									$CLI_LOCATION$CLI_NAME /c$i/p$l show pmstat type=histdata >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_HISTDATA_C$i.txt 2>&1
											
									#cho ".................................................||................................................."
									echo "............................../tw_cli /c$i/p$l show pmstat type=lct..................................." >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_LCT_C$i.txt
									$CLI_LOCATION$CLI_NAME /c$i/p$l show pmstat type=lct >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_LCT_C$i.txt 2>&1
						
							
								done
							fi
					done

###########################################################################################################################
# MR - PMSTAT Data Collection for G_*
###########################################################################################################################

					if [ "$OS_LSI" != "macos" ] ; then
					
						for i in $($CLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
							if $CLI_LOCATION$MCLI_NAME adpgetprop dpmenable a$i nolog 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "DPM is " > /dev/null 2>&1; then	
					
								MR_ECHO_PMSTAT=YES
					
								if [ ! -d ./$fileName/LSI_Products/MegaRAID/PMSTAT ]; then mkdir ./$fileName/LSI_Products/MegaRAID/PMSTAT ; fi
					
								$CLI_LOCATION$MCLI_NAME adpsetprop dpmenable 0 a$i nolog > /dev/null 2>&1 
							
								for l in $($CLI_LOCATION$MCLI_NAME /c$i/eall/sall show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -d" " -f1); do #Supports all disks on Controller.
					
									#cho ".................................................||................................................."
									echo "......................./$MCLI_NAME dpmstat dsply lct physdrv[$l] a$i nolog.........................." >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_LCT_A$i.txt
									$CLI_LOCATION$MCLI_NAME dpmstat dsply lct physdrv[$l] a$i nolog >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_LCT_A$i.txt 2>&1
						
									#cho ".................................................||................................................."
									echo "........................../$MCLI_NAME dpmstat hist physdrv[$l] a$i nolog............................" >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_HIST_A$i.txt
									$CLI_LOCATION$MCLI_NAME dpmstat dsply hist physdrv[$l] a$i nolog >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_HIST_A$i.txt 2>&1
						
									#cho ".................................................||................................................."
									echo ".........................../$MCLI_NAME dpmstat ra physdrv[$l] a$i nolog............................." >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_RA_A$i.txt
									$CLI_LOCATION$MCLI_NAME dpmstat dsply ra physdrv[$l] a$i nolog >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_RA_A$i.txt 2>&1
						
									#cho ".................................................||................................................."
									echo "........................../$MCLI_NAME dpmstat ext physdrv[$l] a$i nolog............................." >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_EXT_A$i.txt
									$CLI_LOCATION$MCLI_NAME dpmstat dsply ext physdrv[$l] a$i nolog >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_EXT_A$i.txt 2>&1
						
					
					
								done
							fi
						done
					
					fi

###


					if [ "$TW_ECHO_PMSTAT" = "YES" ]; then
						echo "Disabling and Getting Disk Performance Monitoring Statistics (DPMSTAT) for 3ware....."
					fi
					
					if [ "$MR_ECHO_PMSTAT" = "YES" ]; then
						echo "Disabling and Getting Disk Performance Monitoring Statistics (DPMSTAT) for MegaRAID....."
					fi

###########################################
# Return for skipping DPMSTAT collection for G_*
###########################################
				fi
			fi
		fi
	fi
fi 
#

###########################################################################################################################
# 3W - PMSTAT Data Collection Standard
###########################################################################################################################
if [ "$TWGETPARTIALMODE" != "G_AEC_DPMSTAT" ]; then 
	if [ "$TWGETPARTIALMODE" != "G_DPMSTAT" ]; then 
		if [ "$TWGETPARTIALMODE" != "G_AEC" ]; then 



			for i in $($CLI_LOCATION$CLI_NAME show | $grep ^c | cut -b 2-3); do #Support for Controller IDs 0-99
				if $CLI_LOCATION$CLI_NAME /c$i show pmstat 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "Performance Monitor: ON" > /dev/null 2>&1 ; then
		
					TW_ECHO_PMSTAT=YES
					if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
					if [ ! -d ./$fileName/LSI_Products/3ware/PMSTAT ]; then mkdir ./$fileName/LSI_Products/3ware/PMSTAT ; fi
			
					$CLI_LOCATION$CLI_NAME /c$i set pmstat=off > /dev/null 2>&1 
					
								
					#cho ".................................................||................................................."
					echo ".................................../tw_cli /c$i show pmstat type=inst................................" >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_INST_C$i.txt
					$CLI_LOCATION$CLI_NAME /c$i show pmstat type=inst 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_INST_C$i.txt 2>&1
			
					#cho ".................................................||................................................."
					echo ".................................../tw_cli /c$i show pmstat type=ra.................................." >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_RA_C$i.txt
					$CLI_LOCATION$CLI_NAME /c$i show pmstat type=ra 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_RA_C$i.txt 2>&1
			
			
					#cho ".................................................||................................................."
					echo ".................................../tw_cli /c$i show pmstat type=ext................................." >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_EXT_C$i.txt
					$CLI_LOCATION$CLI_NAME /c$i show pmstat type=ext 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_EXT_C$i.txt 2>&1
			
					for l in $($CLI_LOCATION$CLI_NAME /c$i show 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep ^p | $grep -v NOT-PRESENT | cut -b 2-4); do #Supports up to 999 Ports per Controller.
						#cho ".................................................||................................................."
						echo "............................../tw_cli /c$i/p$l show pmstat type=histdata.............................." >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_HISTDATA_C$i.txt
						$CLI_LOCATION$CLI_NAME /c$i/p$l show pmstat type=histdata 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_HISTDATA_C$i.txt 2>&1
								
						#cho ".................................................||................................................."
						echo "............................../tw_cli /c$i/p$l show pmstat type=lct..................................." >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_LCT_C$i.txt
						$CLI_LOCATION$CLI_NAME /c$i/p$l show pmstat type=lct 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/3ware/PMSTAT/PMSTAT_LCT_C$i.txt 2>&1
			
					done
				fi
			done

###########################################################################################################################
# MR - PMSTAT Data Collection Standard
###########################################################################################################################

			if [ "$OS_LSI" != "macos" ] ; then
			
				for i in $($CLI_LOCATION$MCLI_NAME show 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
					if $CLI_LOCATION$MCLI_NAME adpgetprop dpmenable a$i nolog 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "DPM is Enabled on Adapter" > /dev/null 2>&1; then	
				
						MR_ECHO_PMSTAT=YES
				
						if [ ! -d ./$fileName/LSI_Products/MegaRAID/PMSTAT ]; then mkdir ./$fileName/LSI_Products/MegaRAID/PMSTAT ; fi
				
							$CLI_LOCATION$MCLI_NAME adpsetprop dpmenable 0 a$i nolog > /dev/null 2>&1 
							
							for l in $($CLI_LOCATION$MCLI_NAME /c$i/eall/sall show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -d" " -f1); do #Supports all disks on Controller.
					
								#cho ".................................................||................................................."
								echo "......................./$MCLI_NAME dpmstat dsply lct physdrv[$l] a$i nolog............................" >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_LCT_A$i.txt
								$CLI_LOCATION$MCLI_NAME dpmstat dsply lct physdrv[$l] a$i nolog >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_LCT_A$i.txt 2>&1
						
								#cho ".................................................||................................................."
								echo "......................./$MCLI_NAME dpmstat hist lct physdrv[$l] a$i nolog............................" >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_HIST_A$i.txt
								$CLI_LOCATION$MCLI_NAME dpmstat dsply hist physdrv[$l] a$i nolog >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_HIST_A$i.txt 2>&1
						
								#cho ".................................................||................................................."
								echo "......................./$MCLI_NAME dpmstat ra lct physdrv[$l] a$i nolog............................" >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_RA_A$i.txt
								$CLI_LOCATION$MCLI_NAME dpmstat dsply ra physdrv[$l] a$i nolog >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_RA_A$i.txt 2>&1
						
								#cho ".................................................||................................................."
								echo "......................./$MCLI_NAME dpmstat ext lct physdrv[$l] a$i nolog............................" >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_EXT_A$i.txt
								$CLI_LOCATION$MCLI_NAME dpmstat dsply ext physdrv[$l] a$i nolog >> ./$fileName/LSI_Products/MegaRAID/PMSTAT/PMSTAT_EXT_A$i.txt 2>&1
						
							done
						fi
				done

			fi

###

			if [ "$TW_ECHO_PMSTAT" = "YES" ]; then
				echo "Disabling and Getting Disk Performance Monitoring Statistics (DPMSTAT) for 3ware....."
			fi
			
			if [ "$MR_ECHO_PMSTAT" = "YES" ]; then
				echo "Disabling and Getting Disk Performance Monitoring Statistics (DPMSTAT) for MegaRAID....."
			fi

###########################################
# Return for skipping DPMSTAT collection for standard
###########################################
		fi
	fi
fi


###########################################################################################################################
# Starting 3ware Controller Data Collection
###########################################################################################################################

# List of 3ware controller numbers
$CLI_LOCATION$CLI_NAME show | $grep ^c | cut -b 2-3 > ./$fileName/script_workspace/controller_numbers.txt
#if [ -s ./$fileName/script_workspace/controller_numbers.txt ] ; then
	if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
	#echo "Starting 3ware Controller Data Collection..."
#fi

for i in $($CLI_LOCATION$CLI_NAME show | $grep ^c | cut -b 2-3); do #Support for Controller IDs 0-99
	#cho ".................................................||................................................."
	echo $fileName >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
	echo "............................................/tw_cli show............................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
	$CLI_LOCATION$CLI_NAME show >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
	echo "......................................../tw_cli /c$i show all........................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
	$CLI_LOCATION$CLI_NAME /c$i show all 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
	echo "Collecting Controller Information for 3ware Controller C$i..."
done


###########################################
# If G_* Grab MR show/show all equivilent
###########################################
if [ "$TWPARTIALCAP" = "YES" ]; then

	for i in $($CLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
		#cho ".................................................||................................................."
		echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
		echo "........................................./$MCLI_NAME show............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
		$CLI_LOCATION$MCLI_NAME show 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		echo "................................../$MCLI_NAME /c$i show all.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
		$CLI_LOCATION$MCLI_NAME /c$i show all 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		echo "Collecting Controller Information for MegaRAID Controller C$i..."
	done
fi





###########################################
# If G_* skip to the end
###########################################
if [ "$TWPARTIALCAP" != "YES" ]; then
#
	if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
	for i in $($CLI_LOCATION$CLI_NAME show | $grep ^c | cut -b 2-3); do #Support for Controller IDs 0-99
		echo "Collecting Unit Information for Controller C$i..."
		for k in $($CLI_LOCATION$CLI_NAME /c$i show 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep ^u | cut -b 2-4); do #Supports up to 999 Units per Controller.
			#cho ".................................................||................................................."
			echo "....................................../tw_cli /c$i/u$k show all......................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$CLI_LOCATION$CLI_NAME /c$i/u$k show all >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
	
			#cho ".................................................||................................................."
			echo ".................................../tw_cli /c$i/u$k show writedpo....................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$CLI_LOCATION$CLI_NAME /c$i/u$k show writedpo >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
		done	


		echo "Collecting Port Information for Controller C$i..."
		echo "This may take a few minutes..."

		#work around for bug in tw_cli 2.00.11.022, segfault in /cx/px show smart/all - Works with included build
		#if [ "$VMWARE_SUPPORTED" != "YES" ] ; then	
			for l in $($CLI_LOCATION$CLI_NAME /c$i show 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep ^p | $grep -v NOT-PRESENT | cut -b 2-4); do #Supports up to 999 Ports per Controller.
				#cho ".................................................||................................................."
				echo "....................................../tw_cli /c$i/p$l show all......................................." >> ./$fileName/script_workspace/px_show_all_c$i.txt
				$CLI_LOCATION$CLI_NAME /c$i/p$l show all >> ./$fileName/script_workspace/px_show_all_c$i.txt
			done
		#fi
		#if [ "$VMWARE_SUPPORTED" = "YES" ] ; then	
		#	for l in $($CLI_LOCATION$CLI_NAME /c$i show 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep ^p | $grep -v NOT-PRESENT | cut -b 2-4); do #Supports up to 999 Ports per Controller.
		#		#cho ".................................................||................................................."
		#		echo "....................................../tw_cli /c$i/p$l show all......................................." >> ./$fileName/script_workspace/px_show_all_c$i.txt
		#		for m in status model firmware serial capacity driveinfo ncq identify lspeed ports connections drvintf wwn rasect pohrs temperature spindlespd ; do
		#			$CLI_LOCATION$CLI_NAME /c$i/p$l show $m >> ./$fileName/script_workspace/px_show_all_c$i.txt 2> /dev/null 
		#		done
		#	done
		#fi

		if [ -f ./$fileName/script_workspace/px_show_all_c$i.txt ]; then 
			#cho ".................................................||................................................."
			echo ".............................................Disk Model............................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$grep "Model =" ./$fileName/script_workspace/px_show_all_c$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			echo ".......................................SAS Only - Drive Type........................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$grep "Drive Type =" ./$fileName/script_workspace/px_show_all_c$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			echo "...........................................Disk Firmware............................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$grep "Firmware Version =" ./$fileName/script_workspace/px_show_all_c$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			echo "...........................................Disk Serial #............................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$grep "Serial =" ./$fileName/script_workspace/px_show_all_c$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			echo "...........................................Disk Capacity............................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$grep "Capacity =" ./$fileName/script_workspace/px_show_all_c$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			#cho ".................................................||................................................."
			echo ".......................................Disk Reallocated Sectors....................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$grep "Reallocated Sectors =" ./$fileName/script_workspace/px_show_all_c$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			echo "..........................................Disk Temperature.........................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$grep "Temperature =" ./$fileName/script_workspace/px_show_all_c$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			echo "..........................................Disk Link Speed..........................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$grep "Link Speed =" ./$fileName/script_workspace/px_show_all_c$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			#cho ".................................................||................................................."
			echo "......................................SATA Only - NCQ Enabled......................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$grep "NCQ Enabled" ./$fileName/script_workspace/px_show_all_c$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			echo ".....................................SAS Only - Queuing Enabled....................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$grep "Queuing Enabled =" ./$fileName/script_workspace/px_show_all_c$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
		fi	



		#cho ".................................................||................................................."
		echo "................................../tw_cli /c$i show alarms reverse..................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
		$CLI_LOCATION$CLI_NAME /c$i show alarms reverse 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
		
		for CLI_ARG in rebuild rebuildrate rebuildmode verify verifyrate verifymode selftest forcedrivecacheon avmode lbareorder modepgctl phy iostat pmstat capture ; do
			#cho ".................................................||................................................."
			echo "....................................../tw_cli /c$i show $CLI_ARG......................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$CLI_LOCATION$CLI_NAME /c$i show $CLI_ARG 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
		done



		#cho ".................................................||................................................."
		echo "....................................../tw_cli /c$i/bbu show all......................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
		$CLI_LOCATION$CLI_NAME /c$i/bbu show all >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
	
	
		echo "Collecting /Cx/Ex Enclosure Information for Controller C$i..."	
		for j in $($CLI_LOCATION$CLI_NAME show | $grep ^/c$i/e | cut -d/ -f3 | cut -b 2-4); do #Supports up to 999 Enclosure IDs
			#cho ".................................................||................................................."
			echo "......................................./tw_cli /c$i/e$j show all......................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
			$CLI_LOCATION$CLI_NAME /c$i/e$j show all >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
		done
	
	
	
		echo "Collecting /Ex Enclosure Information for Controller C$i..."
		for j in $($CLI_LOCATION$CLI_NAME show | $grep ^e | cut -b 2-4); do  #Supports up to 999 Enclosure IDs 
			for k in $($CLI_LOCATION$CLI_NAME /e$j show | $grep ^e | cut -d/ -f2 | cut -b2-3); do #Supports up to 999 Controller IDs
				if [ "$k" = "$i" ]; then # To keep the output in sync with the script flow, otherwise /ex prints at the top of output file.
					#cho ".................................................||................................................."
					echo "...................................../tw_cli /e$j show protocol......................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
					$CLI_LOCATION$CLI_NAME /e$j show protocol >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
					echo "......................................./tw_cli /e$j show all......................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
					$CLI_LOCATION$CLI_NAME /e$j show all >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
				fi
			done
		done
	
		if [ -f ./$fileName/script_workspace/px_show_all_c$i.txt ]; then 
			cat ./$fileName/script_workspace/px_show_all_c$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
		fi	
	
	
		#cho ".................................................||................................................."
		echo "......................................../tw_cli /c$i show diag......................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
		echo ".........The diag output has been processed by strings in order to be viewable by GEDIT............." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
		echo "......................The degree symbol was deleted to maintain formatting.........................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
		echo "..............................The unmodified output is available in ................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
		echo "............../$fileName/script_workspace/raw_diag_C$i.txt................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
		echo "...................................................................................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
		#cho ".................................................||................................................."
		$CLI_LOCATION$CLI_NAME /c$i show diag 2>>./$fileName/script_workspace/lsiget_errorlog.txt > ./$fileName/script_workspace/raw_diag_C$i.txt 2>&1
		
		#No tr in vmware
		if [ "$VMWARE_SUPPORTED" != "YES" ] ; then	
			#strings was deleting the degree symbol and changing the format, tr deletes the symbol but maintains format
			cat ./$fileName/script_workspace/raw_diag_C$i.txt | tr -d ° | strings > ./$fileName/script_workspace/strings_diag_C$i.txt
			cat ./$fileName/script_workspace/strings_diag_C$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
		fi
		if [ "$VMWARE_SUPPORTED" = "YES" ] ; then	
			cat ./$fileName/script_workspace/raw_diag_C$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt 2>&1
		fi
###########################################################################################################################
# 3ware Diag Output Error Checking
###########################################################################################################################


		if [ -f ./$fileName/script_workspace/strings_diag_C$i.txt ]; then 
			$grep "Check power cycles" ./$fileName/script_workspace/strings_diag_C$i.txt > /dev/null
			if [ "$?" -eq "0" ]; then
				#cho ".................................................||................................................."
				echo ".....................tw_cli /c$i show diag - contains Drive Power Cycle Checks......................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
				echo ".If the power cycle number is increasing this usually signifies a power supply or backplane problem." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
				$grep "Check power cycles" ./$fileName/script_workspace/strings_diag_C$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
				echo "......................tw_cli /c$i show diag - contains Drive Power Cycle Checks......................" >> ./$fileName/LSI_Products/3ware/diag_CPC_C$i.txt
				echo ".If the power cycle number is increasing this usually signifies a power supply or backplane problem." >> ./$fileName/LSI_Products/3ware/diag_CPC_C$i.txt
				$grep "Check power cycles" ./$fileName/script_workspace/strings_diag_C$i.txt >> ./$fileName/LSI_Products/3ware/diag_CPC_C$i.txt
			fi
		fi

		if [ -f ./$fileName/script_workspace/strings_diag_C$i.txt ]; then 
			egrep "Assert|.cpp" ./$fileName/script_workspace/strings_diag_C$i.txt > /dev/null
			if [ "$?" -eq "0" ]; then
				#cho ".................................................||................................................."
				echo ".............................tw_cli /c$i show diag - contains Asserts................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
				echo "..................This is evidence of a possible FW bug, contact your support rep!.................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
				egrep "Assert|.cpp" ./$fileName/script_workspace/strings_diag_C$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
				echo ".............................tw_cli /c$i show diag - contains Asserts................................" >> ./$fileName/LSI_Products/3ware/diag_Assert_C$i.txt
				echo "..................This is evidence of a possible FW bug, contact your support rep!.................." >> ./$fileName/LSI_Products/3ware/diag_Assert_C$i.txt
				egrep "Assert|.cpp" ./$fileName/script_workspace/strings_diag_C$i.txt >> ./$fileName/LSI_Products/3ware/diag_Assert_C$i.txt
			fi
		fi


		if [ -f ./$fileName/script_workspace/strings_diag_C$i.txt ]; then 
			egrep "BT1680" ./$fileName/script_workspace/strings_diag_C$i.txt > /dev/null
			if [ "$?" -eq "0" ]; then
				#cho ".................................................||................................................."
				echo ".............................tw_cli /c$i show diag - contains BT1680................................" >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
				echo "....................................The controller should be RMAed.................................." >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
				egrep "BT1680" ./$fileName/script_workspace/strings_diag_C$i.txt >> ./$fileName/LSI_Products/3ware/Controller_C$i.txt
				echo ".............................tw_cli /c$i show diag - contains BT1680................................" >> ./$fileName/LSI_Products/3ware/diag_BT1680_C$i.txt
				echo "....................................The controller should be RMAed.................................." >> ./$fileName/LSI_Products/3ware/diag_BT1680_C$i.txt
				egrep "BT1680" ./$fileName/script_workspace/strings_diag_C$i.txt >> ./$fileName/LSI_Products/3ware/diag_Assert_C$i.txt
			fi
		fi


#done for controller #ing i.e. $i
	done

###########################################################################################################################
# 3ware Smartctl Data Collection if Smartctl is installed
# Start Linux Only Section for now
# Must test on other OS's
###########################################################################################################################

	if [ -s ./$fileName/script_workspace/controller_numbers.txt ] ; then


### Commented out linux only test, 


#		if [ "$OS_LSI" = "linux" ] ; then 
			smartctl -h > /dev/null 2>&1
			if [ "$?" -eq "0" ] ; then
				echo "Starting 3ware Smartctl Data Collection for Controller C$i..."
				if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
				if [ ! -d ./$fileName/LSI_Products/3ware/SMARTCTL ] ; then mkdir ./$fileName/LSI_Products/3ware/SMARTCTL ; fi

				for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ; do #Supports up to 16 character device node entries
					for j in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 ; do #Supports up to 128 Disks per controller, smartctl limitation still 16 as of 5.39??
				#		#cho ".................................................||................................................."
						smartctl -i -d 3ware,$j /dev/twa$i | egrep "START OF INFORMATION SECTION|Serial number:" 1>/dev/null # Test for instances that exist
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "..........Port $j, TWA # is in order of Controller number, not equal too, lowest to highest.........." >> ./$fileName/LSI_Products/3ware/SMARTCTL/TWA$i.txt 2>&1
							echo "..................................smartctl -a -d 3ware,$j /dev/twa$i.................................." >> ./$fileName/LSI_Products/3ware/SMARTCTL/TWA$i.txt 2>&1
							smartctl -a -d 3ware,$j /dev/twa$i >> ./$fileName/LSI_Products/3ware/SMARTCTL/TWA$i.txt 2>&1
						fi
					done
				done

				for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ; do #Supports up to 16 character device node entries
					for j in 0 1 2 3 4 5 6 7 8 9 10 11 ; do #Supports up to 12 Disks per controller, max port count for 7/8xxx controllers
				#		#cho ".................................................||................................................."
						smartctl -i -d 3ware,$j /dev/twe$i | egrep "START OF INFORMATION SECTION|Serial number:" 1>/dev/null # Test for instances that exist
						if [ "$?" -eq "0" ]; then
							#cho ".................................................||................................................."
							echo "..........Port $j, TWE # is in order of Controller number, not equal too, lowest to highest.........." >> ./$fileName/LSI_Products/3ware/SMARTCTL/TWE$i.txt 2>&1
							echo "..................................smartctl -a -d 3ware,$j /dev/twe$i.................................." >> ./$fileName/LSI_Products/3ware/SMARTCTL/TWE$i.txt 2>&1
							smartctl -a -d 3ware,$j /dev/twe$i >> ./$fileName/LSI_Products/3ware/SMARTCTL/TWE$i.txt 2>&1
						fi
					done
				done

# return for smartctl -h
			fi
# return for OS_LSI=linux
#		fi
# return for if controller_numbers.txt greater than 0 bytes
	fi

#
# End Linux Only Section
#

###########################################################################################################################
# LSI HBA 
###########################################################################################################################
	if [ "$NO_LSI_HBAs" != "YES" ] ; then 
		echo "Starting the LSI HBA Data Collection..."
	
		for i in $(./$LSUT_NAME 0 2>>./$fileName/script_workspace/lsiget_errorlog.txt | awk 'BEGIN{prt=0}{if (prt==1) print $0; else if ($3=="Chip") prt=1}' | $grep LSI | cut -d. -f1); do # Support for unlimited HBAs
		
			#cho ".................................................||................................................."
			echo $fileName >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			echo "..............................................LSITool..............................................." >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			./$LSUT_NAME 0 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			echo "" >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			echo ".............................................LSITool 1.............................................." >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			./$LSUT_NAME -p $i 1 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			echo ".............................................LSITool 8.............................................." >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			./$LSUT_NAME -p $i 8 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			echo ".............................................LSITool 16............................................." >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			./$LSUT_NAME -p $i 16 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			echo ".............................................LSITool 17............................................." >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			./$LSUT_NAME -p $i 17 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			echo "..........................................LSITool 25-2-0-0.........................................." >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			./$LSUT_NAME -p $i -a 25,2,0,0 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			echo ".............................................LSITool 42............................................." >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			./$LSUT_NAME -p $i 42 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			echo ".............................................LSITool 47............................................." >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			./$LSUT_NAME -p $i 47 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			echo "...........................................LSITool 21-1-2..........................................." >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			./$LSUT_NAME -p $i -a 21,1,2,0,0 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/HBA/1_8_16_17_25-2-0-0_42_47_21-1-2_hba$i.txt
			
			
			#echo "............................................LSITool 100............................................." >> ./$fileName/LSI_Products/HBA/100_hba$i.txt
			./$LSUT_NAME -p $i 100 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/HBA/100_hba$i.txt >> ./$fileName/LSI_Products/HBA/100_hba$i.txt
			
			echo "REM lsipage is an LSI internal utility" > ./$fileName/LSI_Products/HBA/100_hba$i.bat
			echo "copy 100_hba$i.txt 100_hba$i" >> ./$fileName/LSI_Products/HBA/100_hba$i.bat
			echo "lsipage -h -i 100_hba$i" >> ./$fileName/LSI_Products/HBA/100_hba$i.bat
			echo "del 100_hba$i" >> ./$fileName/LSI_Products/HBA/100_hba$i.bat
		done
	fi

###########################################################################################################################
# Starting MegaCli MegaRAID Controller Data Collection
###########################################################################################################################
	if [ "$OS_LSI" != "macos" ] ; then


# Used with smartctl, dont want duplicates with multiple controllers.
		for j in a b c d e f g h i j k l m n o p q r s t u v w x y z ; do
		if [ -e /sys/block/sd$j ] ; then echo $j >> ./$fileName/script_workspace/sd_letters.txt ; fi
		done
	
		#MegaRAID Adapter #'s
		#Changed to storcli syntax to avoid using tr
		$MCLI_LOCATION$MCLI_NAME show ctrlcount | grep "Controller Count" | cut -d" " -f 4 > ./$fileName/script_workspace/num_mraid_adapters.txt
		if [ -n `cat ./$fileName/script_workspace/num_mraid_adapters.txt` ] ; then
			for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ; do
				if [ "$i" -lt "`cat ./$fileName/script_workspace/num_mraid_adapters.txt`" ] ; then echo $i >> ./$fileName/script_workspace/adapter_numbers.txt ; fi
			done
		fi
	
# Make sure at least 1 MegaRAID Adapter is identified
		if [ -f ./$fileName/script_workspace/adapter_numbers.txt ] ; then
	
			for i in `cat ./$fileName/script_workspace/adapter_numbers.txt` ; do #Support for all adapter IDs 



	
# MegaRAID Logical Disk #'s
				#Changed to storcli syntax to avoid using tr
				$MCLI_LOCATION$MCLI_NAME /c$i/vall show j | grep "DG/VD" | wc -l > ./$fileName/script_workspace/num_lds_A$i.txt
				if [ -n `cat ./$fileName/script_workspace/num_lds_A$i.txt` ] ; then
					for j in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255; do #Supports up to 256 LDs
						if [ "$j" -lt "`cat ./$fileName/script_workspace/num_lds_A$i.txt`" ] ; then
					 		echo $j >> ./$fileName/script_workspace/ld_numbers_A$i.txt
							else
					  		break
						fi
					done
				fi
	
				if [ "$LimitMegaCliCMDs" != "YES" ] ; then 
#MegaRAID Enclosure #'s
					$MCLI_LOCATION$MCLI_NAME encinfo a$i | grep "Device ID" | awk  '{ print $4 }' >> ./$fileName/script_workspace/enclosure_numbers_A$i.txt
				fi
	
#MegaRAID phy #'s
				$MCLI_LOCATION$MCLI_NAME phyerrorcounters a$i | grep "Phy No:" | awk '{ print $3 }' >> ./$fileName/script_workspace/phy_numbers_A$i.txt
	
#MegaRAID PCI data, used for grepping.
				$MCLI_LOCATION$MCLI_NAME adpgetpciinfo a$i nolog 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/script_workspace/pci_info_A$i.txt
	
#MegaRAID PDList data, used for grepping.
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt 2>&1
				$MCLI_LOCATION$MCLI_NAME pdlist a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt 2>&1
	
#MegaRAID Disk Device ID #'s
				$grep -e "Device Id:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt | cut -d" " -f3 >> ./$fileName/script_workspace/disk_dev_id_numbers_A$i.txt
	
#MegaRAID adpallinfo data, used for grepping.
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt 2>&1
				$MCLI_LOCATION$MCLI_NAME adpallinfo a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt 2>&1
	
#MegaRAID adpalilog data, used for grepping.
				if [ "$LimitMegaCliCMDs" != "YES" ] ; then
					echo $fileName >> ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAliLog_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpalilog a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAliLog_A$i.txt 2>&1
				fi
	
	
				#echo "Starting MegaRAID Adapter Data Collection with MegaCli syntax..."
				
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				echo "......................................./$MCLI_NAME adpcount.........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME adpcount nolog | $grep Count: >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo "............................................Adapter a$i.............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt ] ; then
					$grep -e "Product Name    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Memory Size     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Host Interface  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Serial No       :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "SAS Address     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "FW Package Build:" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "FW Version         :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Mfg. Date       :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "BBU             :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Battery FRU     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Serial Debugger :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "On board Expander:" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "On board Expander FW version :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Driver Name:" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAliLog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -m 1 -e "Driver Version:" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAliLog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "..............................................PCI Info.............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Bus Number      :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Device Number   :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Function Number :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					echo "..........................................MegaRAID PCI Info........................................." >> ./$fileName/Controller_Disk_Association.txt
					$grep -e "PCI information for Controller" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/Controller_Disk_Association.txt 2>&1
					$grep -e "Bus Number      :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/Controller_Disk_Association.txt 2>&1
					$grep -e "Device Number   :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/Controller_Disk_Association.txt 2>&1
					$grep -e "Function Number :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/Controller_Disk_Association.txt 2>&1
					echo "...............................................Errors..............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Memory Correctable Errors   :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Memory Uncorrectable Errors :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Any Offline VD Cache Preserved   :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#	$grep -e "ECC Bucket Count                 :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "...........................................Rate Settings............................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				#	$grep -e "Ecc Bucket Size                  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#	$grep -e "Ecc Bucket Leak Rate             :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Predictive Fail Poll Interval    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#	$grep -e "Interrupt Throttle Active Count  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#	$grep -e "Interrupt Throttle Completion    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Rebuild Rate                     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "PR Rate                          :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#	echo "Note: Resynch Rate is BgiRate" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "BGI Rate                         :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Check Consistency Rate           :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Reconstruction Rate              :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Physical Drive Coercion Mode     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo ".............................................Performance............................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Cache Flush Interval             :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Host Request Reordering          :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Load Balance Mode                :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop NCQDsply a$i nolog | $grep "NCQ" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop WBSupport a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop perfmode a$i nolog | $grep "Perf Tuned Mode :" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "................................Enclosures/Backplanes and Connectors................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Auto Detect BackPlane Enabled    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop ExposeEnclDevicesEnbl a$i nolog | $grep "Expose" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetconnectormode connectorall a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "........................................Alarms and Warnings........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Alarm                            :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Battery Warning                  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "........................................Rebuild and Hotspare........................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Auto Rebuild                     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Restore HotSpare on Insertion    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop AutoEnhancedImportDsply a$i nolog | $grep "Auto" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop MaintainPdFailHistoryEnbl a$i nolog | $grep "Maintain" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo ".............................................Copy Back.............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$MCLI_LOCATION$MCLI_NAME adpgetprop CopyBackDsbl a$i nolog | $grep "Copyback" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop SMARTCpyBkEnbl a$i nolog | $grep "Copyback" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop SSDSMARTCpyBkEnbl a$i nolog | $grep "Copyback" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo ".............................................PR and CC.............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Enable SSD Patrol Read                  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop PrCorrectUncfgdAreas a$i nolog | $grep "Unconfigured" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop AbortCCOnError a$i nolog | $grep "Abort" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "..........................................ELF/Advanced SW..........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$MCLI_LOCATION$MCLI_NAME elf getsafeid a$i nolog | $grep "Safe" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME elf rehostinfo a$i nolog | $grep "Needs"  >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME elf ControllerFeatures a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo ".............................................Encryption............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Security Key Assigned            :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Security Key Failed              :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Security Key Not Backedup        :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop UseFDEOnlyEncrypt a$i nolog | $grep "FDE Only Encryption:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "..........................................Power Management.........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Max Drives to Spinup at One Time :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Delay Among Spinup Groups        :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					echo "#### Dimmer Switch 1" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$MCLI_LOCATION$MCLI_NAME adpgetprop EnblSpinDownUnConfigDrvs a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					echo "#### Dimmer Switch 2" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$MCLI_LOCATION$MCLI_NAME adpgetprop DsblSpinDownHSP a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					echo "#### Dimmer Switch 3" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$MCLI_LOCATION$MCLI_NAME adpgetprop DefaultLdPSPolicy a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop DisableLdPsInterval a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop DisableLdPsTime a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop SpinDownTime a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop SpinUpEncDrvCnt a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpgetprop SpinUpEncDelay a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo ".............................................BIOS/Boot.............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$MCLI_LOCATION$MCLI_NAME adpbios dsply a$i nolog | $grep "BIOS" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpbootdrive get a$i nolog | $grep "boot" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#	$grep -e "Cluster Mode                     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "...............................................Drives..............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Virtual Drives    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Degraded        :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Offline         :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Physical Devices  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Disks           :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Critical Disks  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					$grep -e "Failed Disks    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
				fi
				
				#cho ".................................................||................................................."
				echo "....................................Adapter/System Time Sync A$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				echo "Adapter Date/Time:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				$MCLI_LOCATION$MCLI_NAME adpgettime a$i nolog | $grep -e "Date:" -e "Time:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				echo "System Date/Time:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				date >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				echo "System Date/Time UTC:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				date -u >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
				#cho ".................................................||................................................."
				echo ".............................../$MCLI_NAME getpreservedcachelist a$i.................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME getpreservedcachelist a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
				if [ -f ./$fileName/script_workspace/ld_numbers_A$i.txt ] ; then
					for j in `cat ./$fileName/script_workspace/ld_numbers_A$i.txt` ; do #Support for up to 256 LDs
						#cho ".................................................||................................................."
						echo "...................................../$MCLI_NAME ldinfo l$j a$i........................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
							date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
						if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
							date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
						$MCLI_LOCATION$MCLI_NAME ldinfo l$j a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo ".........................../$MCLI_NAME ldgetprop consistency l$j a$i..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
							date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
						if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
							date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
						$MCLI_LOCATION$MCLI_NAME ldgetprop consistency l$j a$i nolog | $grep "Virtual" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo "............................./$MCLI_NAME ldgetprop pspolicy l$j a$i...................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
							date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
						if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
							date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
						$MCLI_LOCATION$MCLI_NAME ldgetprop pspolicy l$j a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo ".....................................Init/CC/Recon Status l$j a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$MCLI_LOCATION$MCLI_NAME ldinit showprog l$j a$i nolog | $grep "Initialization" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME ldbi showprog l$j a$i nolog | $grep "Background" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME ldcc showprog l$j a$i nolog | $grep "Check" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME ldrecon showprog l$j a$i nolog | $grep "Reconstruction" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					done
				fi
				
				echo "..................................../$MCLI_NAME adppr info a$i........................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME adppr info a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."
			
				echo "................................../$MCLI_NAME adpccsched info a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi

				$MCLI_LOCATION$MCLI_NAME adpccsched info a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."
			
				echo ".................................../$MCLI_NAME pdgetmissing a$i......................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi

				$MCLI_LOCATION$MCLI_NAME pdgetmissing a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo "...................................Logical Disks & Physical Disks..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi

				$MCLI_LOCATION$MCLI_NAME ldpdinfo a$i nolog | $grep -e "Virtual Disk:" -e "RAID Level:" -e "Number Of Drives:" -e "PD:" -e "Enclosure Device ID:" -e "Slot Number:" -e "Device Id:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo ".....................................Physical Disk - Slot Number...................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				$grep -e "Slot Number:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo "......................................Physical Disk - Device Id....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				$grep -e "Device Id:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo ".....................................Physical Disk - Inquiry Data..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				$grep -e "Inquiry Data:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo ".....................................Physical Disk - SAS Address...................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				$grep -e "SAS Address" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo "....................................Physical Disk - Firmware state.................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				$grep -e "Firmware state:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo "....................................Physical Disk - Foreign State..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				$grep -e  "Foreign State:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo "...............................Physical Disk - Predictive Failure Count............................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				$grep -e "Predictive Failure Count:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo ".....................................Physical Disk - Link Speed....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				$grep -e "Link Speed:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo ".......................................Physical Disk - Type........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				$grep -e "PD Type:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo "......................................Physical Disk - Common........................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				$grep -e "Slot Number:" -e "Enclosure Device ID:" -e "Device Id:" -e "Inquiry Data:" -e "Firmware state:" -e "Predictive Failure Count:" -e "Link Speed:" -e "PD Type:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				
				
				if [ "$LimitMegaCliCMDs" != "YES" ] ; then 
					echo "Collecting Enclosure Information for Adapter A$i with MegaCli syntax..."
					#cho ".................................................||................................................."
					echo "....................................../$MCLI_NAME encinfo a$i........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi

					$MCLI_LOCATION$MCLI_NAME encinfo a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				fi
				
				echo "Collecting Information for Adapter A$i with MegaCli syntax..."
				
				#cho ".................................................||................................................."

#Solaris/storcli work around - segmentation fault 

				if [ "$OS_LSI" != "solaris" ] ; then
					echo "...................................../$MCLI_NAME adpbbucmd a$i........................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
	
					$MCLI_LOCATION$MCLI_NAME adpbbucmd a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				fi			

				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME cfgforeign scan a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME cfgforeign scan a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."
				echo "................................./$MCLI_NAME cfgforeign dsply a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME cfgforeign dsply a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."
				echo "................................/$MCLI_NAME cfgforeign preview a$i...................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME cfgforeign preview a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."
				
				echo "................................./$MCLI_NAME cfgfreespaceinfo a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME cfgfreespaceinfo a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."
				echo "............................/$MCLI_NAME cfgsave -f cfgsave_A$i.cfg a$i................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME cfgsave -f ./$fileName/LSI_Products/MegaRAID/MegaCli/cfgsave_A$i.cfg a$i nolog > /dev/null 2>&1
			
				#cho ".................................................||................................................."
				echo "............................/$MCLI_NAME adpeventlog geteventloginfo a$i..............................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME adpeventlog geteventloginfo a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."
				echo ".............../$MCLI_NAME adpeventlog getevents -f eventlog_getevents_A$i.txt a$i....................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME adpeventlog getevents -f ./$fileName/LSI_Products/MegaRAID/AENs/eventlog_getevents_A$i.txt a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."
				echo "........./$MCLI_NAME adpeventlog getsinceshutdown -f eventlog_getsinceshutdown_A$i.txt a$i............" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME adpeventlog getsinceshutdown -f ./$fileName/LSI_Products/MegaRAID/AENs/eventlog_getsinceshutdown_A$i.txt a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."
				echo "........./$MCLI_NAME adpeventlog getsincereboot -f eventlog_getsincereboot_A$i.txt a$i................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME adpeventlog getsincereboot -f ./$fileName/LSI_Products/MegaRAID/AENs/eventlog_getsincereboot_A$i.txt a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
			
				#cho ".................................................||................................................."
				echo "........./$MCLI_NAME adpeventlog includedeleted -f eventlog_includedeleted_A$i.txt a$i................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME adpeventlog includedeleted -f ./$fileName/LSI_Products/MegaRAID/AENs/eventlog_includedeleted_A$i.txt a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1

				
				#cho ".................................................||................................................."
				echo "...................................../$MCLI_NAME cfgdsply a$i.........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME cfgdsply a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
				echo "Collecting Logical Disk Information for Adapter A$i with MegaCli syntax..."
				#cho ".................................................||................................................."
				echo "...................................../$MCLI_NAME ldpdinfo a$i........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME ldpdinfo a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."
				echo "................................/$MCLI_NAME phyerrorcounters a$i......................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME phyerrorcounters a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
				for j in `cat ./$fileName/script_workspace/phy_numbers_A$i.txt` ; do
					#cho ".................................................||................................................."
					echo ".................................../$MCLI_NAME phyinfo phy$j a$i......................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME phyinfo phy$j a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				done
				#cho ".................................................||................................................."
				echo "............................../$MCLI_NAME directpdmapping dsply a$i..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME directpdmapping dsply a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."
				echo "Collecting Physical Disk Information for Adapter A$i with MegaCli syntax..."
				echo "....................................../$MCLI_NAME pdlist a$i.........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME pdlist a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				#cho ".................................................||................................................."

			

###########################################################################################################################
# MegaOEM INI dump if installed
###########################################################################################################################

				if [ -f /opt/MegaRAID/MegaOEM/MegaOEM ]; then 
					#cho ".................................................||................................................."
					echo "................................./opt/MegaRAID/MegaOEM/MegaOEM -v..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					/opt/MegaRAID/MegaOEM/MegaOEM -v >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					echo "...........................MegaOEM adpsettings write -f MFC_Settings_opt_A$i.ini a$i......................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					/opt/MegaRAID/MegaOEM/MegaOEM adpsettings write -f ./$fileName/LSI_Products/MegaRAID/MFC_Settings_opt_A$i.ini a$i >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi


				if [ -f ./MegaOEM ]; then 
					#cho ".................................................||................................................."
					echo ".............................................MegaOEM -v............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					./MegaOEM -v >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
		
					echo "...........................MegaOEM adpsettings write -f MFC_Settings_A$i.ini a$i......................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
					./MegaOEM adpsettings write -f ./$fileName/LSI_Products/MegaRAID/MFC_Settings_A$i.ini a$i >> ./$fileName/LSI_Products/MegaRAID/Adapter_A$i.txt
				fi

				MegaOEM -v > /dev/null 2>&1
				if [ "$?" -eq "0" ]; then 
					#cho ".................................................||................................................."
					echo ".............................................MegaOEM -v............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					MegaOEM -v >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
		
					echo "...........................MegaOEM adpsettings write -f MFC_Settings_path_A$i.ini a$i......................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
					MegaOEM adpsettings write -f ./$fileName/LSI_Products/MegaRAID/MFC_Settings_path_A$i.ini a$i >> ./$fileName/LSI_Products/MegaRAID/Adapter_A$i.txt
				fi


				echo "Collecting Internal Logs for Adapter A$i..."
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME fwtermlog dsply a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME fwtermlog dsply a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt 2>&1
				$MCLI_LOCATION$MCLI_NAME fwtermlog dsply a$i nolog >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt 2>&1



###########################################################################################################################
# MegaCli fwtermlog dsply Ax - fwtermlog error screening
# 
# Words to look out for... "Fatal firmware error: Line" Fault Panic BAIL_OUT Paused REC CRC Unrecoverable Sense "Battery Put to Sleep" 
###########################################################################################################################


				if [ -f ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt ]; then 
				$grep "Fatal firmware error: Line" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt > /dev/null
					if [ "$?" -eq "0" ]; then
					#cho ".................................................||................................................."
					echo "...............$MCLI_NAME fwtermlog dsply a$i - contains Fatal firmware error: Line...................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Fatal_FW_Error_FWTermLog_A$i.txt
					echo "........This indicates that a SERIOUS FW Issue has occurred, contact Tech. Support or your FAE......." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Fatal_FW_Error_FWTermLog_A$i.txt
					$grep "Fatal firmware error: Line" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Fatal_FW_Error_FWTermLog_A$i.txt
							
					fi
				fi
		
				if [ -f ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt ]; then 
				$grep " Fault " ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt > /dev/null
					if [ "$?" -eq "0" ]; then
					#cho ".................................................||................................................."
					echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains Fault............................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Fault_FWTermLog_A$i.txt
					echo "........This indicates that a SERIOUS FW Issue has occurred, contact Tech. Support or your FAE......." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Fault_FWTermLog_A$i.txt
					$grep " Fault " ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Fault_FWTermLog_A$i.txt
							
					fi
				fi
		
				if [ -f ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt ]; then 
				$grep "Panic" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt > /dev/null
					if [ "$?" -eq "0" ]; then
					#cho ".................................................||................................................."
					echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains Panic............................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Panic_FWTermLog_A$i.txt
					echo "........This indicates that a SERIOUS FW Issue has occurred, contact Tech. Support or your FAE......." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Panic_FWTermLog_A$i.txt
					$grep "Panic" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Panic_FWTermLog_A$i.txt
							
					fi
				fi
		
				if [ -f ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt ]; then 
				$grep "BAIL_OUT" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt > /dev/null
					if [ "$?" -eq "0" ]; then
					#cho ".................................................||................................................."
					echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains BAIL_OUT.........................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/BAIL_OUT_FWTermLog_A$i.txt
					echo "........This indicates that a SERIOUS FW Issue has occurred, contact Tech. Support or your FAE......." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/BAIL_OUT_FWTermLog_A$i.txt
					$grep "BAIL_OUT" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/BAIL_OUT_FWTermLog_A$i.txt
							
					fi
				fi
		
				if [ -f ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt ]; then 
				$grep "Paused" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt > /dev/null
					if [ "$?" -eq "0" ]; then
					#cho ".................................................||................................................."
					echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains Paused............................" >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Paused_FWTermLog_A$i.txt
					echo "....................................This should be investigated....................................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Paused_FWTermLog_A$i.txt
					$grep "Paused" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Paused_FWTermLog_A$i.txt
							
					fi
				fi
		
				if [ -f ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt ]; then 
				$grep -e "MPI2_EVENT_SAS_QUIESCE_RC_STARTED" -e "MPI2_EVENT_SAS_QUIESCE_RC_COMPLETED" -e "Test event: An unexpected data IO error occurred on PD" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt > /dev/null
					if [ "$?" -eq "0" ]; then
					#cho ".................................................||................................................."
					echo "..........................$MCLI_NAME fwtermlog dsply a$i - contains Test_Event............................" >> ./$fileName/LSI_Products/MegaRAID/Adapter_A$i.txt
					echo "....................................The controller should be RMAed.................................." >> ./$fileName/LSI_Products/MegaRAID/Adapter_A$i.txt
					echo "..........................$MCLI_NAME fwtermlog dsply a$i - contains Test_Event............................" >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Test_Event_FWTermLog_A$i.txt
					echo "....................................The controller should be RMAed.................................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Test_Event_FWTermLog_A$i.txt
					$grep -e "MPI2_EVENT_SAS_QUIESCE_RC_STARTED" -e "MPI2_EVENT_SAS_QUIESCE_RC_COMPLETED" -e "Test event: An unexpected data IO error occurred on PD" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Test_Event_FWTermLog_A$i.txt
							
					fi
				fi
		
		
				if [ -f ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt ]; then 
				$grep "REC" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt > /dev/null
					if [ "$?" -eq "0" ]; then
					#cho ".................................................||................................................."
					echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains REC..............................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/REC_FWTermLog_A$i.txt
					echo "....................................This should be investigated....................................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/REC_FWTermLog_A$i.txt
					$grep "REC" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/REC_FWTermLog_A$i.txt
							
					fi
				fi
		
				
				if [ -f ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt ]; then 
				$grep "Unrecoverable" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt > /dev/null
					if [ "$?" -eq "0" ]; then
					#cho ".................................................||................................................."
					echo "...................$MCLI_NAME fwtermlog dsply a$i - contains Unrecoverable............................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Unrecoverable_FWTermLog_A$i.txt
					echo "....................................This should be investigated....................................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Unrecoverable_FWTermLog_A$i.txt
					$grep "Unrecoverable" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Unrecoverable_FWTermLog_A$i.txt
							
					fi
				fi
		
				if [ -f ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt ]; then 
				$grep "CRC" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt > /dev/null
					if [ "$?" -eq "0" ]; then
					#cho ".................................................||................................................."
					echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains CRC..............................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/CRC_FWTermLog_A$i.txt
					echo "....................................This should be investigated....................................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/CRC_FWTermLog_A$i.txt
					$grep "CRC" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/CRC_FWTermLog_A$i.txt
							
					fi
				fi
				
				if [ -f ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt ]; then 
				$grep -i "Sense" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt > /dev/null
					if [ "$?" -eq "0" ]; then
					#cho ".................................................||................................................."
					echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains Sense............................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Sense_FWTermLog_A$i.txt
					echo "...........................................Informational............................................" >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Sense_FWTermLog_A$i.txt
					$grep -i "Sense" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/Sense_FWTermLog_A$i.txt
							
					fi
				fi
		
				if [ -f ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt ]; then 
				$grep -i "Battery Put to Sleep" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt > /dev/null
					if [ "$?" -eq "0" ]; then
					#cho ".................................................||................................................."
					echo "..................$MCLI_NAME fwtermlog dsply a$i - contains Battery Put to Sleep......................." >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/BatterySleep_FWTermLog_A$i.txt
					echo "...........................................Informational............................................" >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/BatterySleep_FWTermLog_A$i.txt
					$grep -i "Battery Put to Sleep" ./$fileName/LSI_Products/MegaRAID/FWTermLog/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/FWTermLog/BatterySleep_FWTermLog_A$i.txt
							
					fi
				fi



###########################################################################################################################
# MegaRAID Smartctl Data Collection if Smartctl is installed
# Start Linux Only Section for now
# Must test on other OS's
###########################################################################################################################

###Took out Linux only test

#				if [ "$OS_LSI" = "linux" ]; then 
				
					smartctl -h > /dev/null 2>&1
					if [ "$?" -eq "0" ] ; then
					# Smartctl added support for MegaRAID in 5.39
						if [ `smartctl -V | $grep release | cut -d" " -f3 | cut -d. -f1` -ge 5 ] ; then
							if [ `smartctl -V | $grep release | cut -d" " -f3 | cut -d. -f2` -ge 39 ] ; then

# Only have one sd letter associated per 
# controller to eliminate duplicate
# entries.
								if [ -f ./$fileName/script_workspace/sd_letters.txt ] ; then
									for j in `cat ./$fileName/script_workspace/sd_letters.txt` ; do #Supports up to 26 character device node entries
										for k in `cat ./$fileName/script_workspace/disk_dev_id_numbers_A$i.txt` ; do #Limit?
											smartctl -T permissive -i -d megaraid,$k /dev/sd$j | egrep "INQUIRY failed|No such device" > /dev/null 2>&1
												if [ "$?" -ne "0" ]; then
													echo $j > ./$fileName/script_workspace/sd_letter_A$i.txt
												fi
										done
									done
								fi	

# Differentiate SATA from SAS				
								if [ -f ./$fileName/script_workspace/sd_letter_A$i.txt ] ; then
									for j in `cat ./$fileName/script_workspace/sd_letter_A$i.txt` ; do #Supports up to 26 character device node entries
										for k in `cat ./$fileName/script_workspace/disk_dev_id_numbers_A$i.txt` ; do #Limit?
											smartctl -T permissive -i -d megaraid,$k /dev/sd$j | grep "SATA device detected" > /dev/null 2>&1
												if [ "$?" -ne "0" ]; then
													echo $k >> ./$fileName/script_workspace/sas_disk_dev_id_numbers_A$i.txt
													else	
													echo $k >> ./$fileName/script_workspace/sata_disk_dev_id_numbers_A$i.txt
												fi
										done
									done
								fi		
													
		
								echo "Starting MegaRAID Smartctl Data Collection for Controller C$i..."
								if [ ! -d ./$fileName/LSI_Products/MegaRAID/SMARTCTL ]; then mkdir ./$fileName/LSI_Products/MegaRAID/SMARTCTL ; fi

								#cho ".................................................||................................................."
								echo "...................All SAS disks are listed first and then all SATA disks follow...................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_A$i.txt 2>&1
								echo "...................................................................................................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_A$i.txt 2>&1

# SAS Disks		
								
								if [ -f ./$fileName/script_workspace/sd_letter_A$i.txt ] ; then
									if [ -f ./$fileName/script_workspace/sas_disk_dev_id_numbers_A$i.txt ] ; then
										for j in `cat ./$fileName/script_workspace/sd_letter_A$i.txt` ; do #Supports up to 26 character device node entries
											for k in `cat ./$fileName/script_workspace/sas_disk_dev_id_numbers_A$i.txt` ; do #Limit?
												#cho ".................................................||................................................."
												echo ".................................megaraid,$k is the Disk Device ID #................................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_A$i.txt 2>&1
												echo ".......................smartctl -T permissive -a -d megaraid,$k /dev/sd$j............................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_A$i.txt 2>&1
												smartctl -T permissive -a -d megaraid,$k /dev/sd$j >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_A$i.txt 2>&1
											done
										done
									fi
								fi

# SATA Disks

								if [ -f ./$fileName/script_workspace/sd_letter_A$i.txt ] ; then
									if [ -f ./$fileName/script_workspace/sata_disk_dev_id_numbers_A$i.txt ] ; then
										for j in `cat ./$fileName/script_workspace/sd_letter_A$i.txt` ; do #Supports up to 26 character device node entries
											for k in `cat ./$fileName/script_workspace/sata_disk_dev_id_numbers_A$i.txt` ; do #Limit?
												#cho ".................................................||................................................."
												echo ".................................megaraid,$k is the Disk Device ID #................................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_A$i.txt 2>&1
												echo ".......................smartctl -T permissive -a -d sat+megaraid,$k /dev/sd$j............................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_A$i.txt 2>&1
												smartctl -T permissive -a -d sat+megaraid,$k /dev/sd$j >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_A$i.txt 2>&1
											done
										done
									fi
								fi


# returns for smartctl -V
							fi
						fi
# return for smartctl -h
					fi
# return for OS_LSI=linux
#				fi

# Adapter number
			done



###########################################################################################################################
# Starting storcli MegaRAID Controller Data Collection
###########################################################################################################################
				
				
				
			echo "Starting MegaRAID Controller Data Collection with storcli..."
	

			echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
# Using /cx instead - need to get rid of duplicate "Controller =" entries.	
	
			#cho ".................................................||................................................."
			#echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt
			#echo ".................................../$MCLI_NAME /call show all........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt
			#$CLI_LOCATION$MCLI_NAME /call show all >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt
	
# Doesnt add additional data
			#cho ".................................................||................................................."
			#echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Dall_show_all.txt
			#echo "................................/$MCLI_NAME /call/dall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Dall_show_all.txt
			#$CLI_LOCATION$MCLI_NAME /call/dall show all >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Dall_show_all.txt
	
# Doing C$i/vall show all instead
			#cho ".................................................||................................................."
			#echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Vall_show_all.txt
			#echo "................................/$MCLI_NAME /call/vall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Vall_show_all.txt
			#$CLI_LOCATION$MCLI_NAME /call/vall show all >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Vall_show_all.txt
	
# Embeddedd in Controller_C$i	
			#cho ".................................................||................................................."
			#echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_show_all.txt
			#echo "................................../$MCLI_NAME /call/eall show all...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_show_all.txt
			#$CLI_LOCATION$MCLI_NAME /call/eall show all >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_show_all.txt

			#cho ".................................................||................................................."
			#echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_show_status.txt
			#echo "................................/$MCLI_NAME /call/eall show status..................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_show_status.txt
			#$CLI_LOCATION$MCLI_NAME /call/eall show status >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_show_status.txt
	
	
	
			#cho ".................................................||................................................."
			echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt
			echo ".............................../$MCLI_NAME /call/eall/sall show all...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt
			$CLI_LOCATION$MCLI_NAME /call/eall/sall show all >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt
		
			if [ -f ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt ]; then 
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...............................................Drives..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$CLI_LOCATION$MCLI_NAME /call/eall/sall show | $grep -e SATA -e SAS >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................Shield Counter.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Shield Counter =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Media Error Count.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Media Error Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Other Error Count.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Other Error Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Drive Temperature.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Drive Temperature =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "......................................Predictive Failure Count......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Predictive Failure Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...................................S.M.A.R.T alert flagged by drive................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "S.M.A.R.T alert flagged by drive =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".................................................SN................................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "SN =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".................................................WWN................................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "WWN =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Firmware Revision.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Firmware Revision =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".............................................Raw size..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Raw size =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................Coerced size............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Coerced size =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt | $grep -v "Non" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "..........................................Non Coerced size.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Non Coerced size =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................Device Speed............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Device Speed =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".............................................Link Speed............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Link Speed =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				#Per VD not PD
				#echo "..........................................Drive write cache............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#$grep "Drive write cache =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Logical Sector Size........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Logical Sector Size =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Physical Sector Size......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Physical Sector Size =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...........................................Drive position..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Drive position =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Enclosure position........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Enclosure position =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "........................................Connected Port Number......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Connected Port Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...........................................Sequence Number.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Sequence Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt | $grep -v "Predictive" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Commissioned Spare........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Commissioned Spare =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...........................................Emergency Spare.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Emergency Spare =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".............................Last Predictive Failure Event Sequence Number.........................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Last Predictive Failure Event Sequence Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".................................Successful diagnostics completion on..............................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Successful diagnostics completion on =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................SED Capable............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "SED Capable =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................SED Enabled..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "SED Enabled =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "..............................................Secured..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Secured =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...............................................Locked..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Locked =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Needs EKM Attention..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Needs EKM Attention =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................PI Eligible..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "PI Eligible =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "..........................................Wide Port Capable..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Wide Port Capable =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "................................Port # - Status - Linkspeed - SAS Address..........................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Gb/s   0x" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................Inquiry Data............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$CLI_LOCATION$MCLI_NAME /c$i/eall/sall show all j | $grep "Inquiry Data" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				
			fi	
		
	
			
			for i in $($CLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199


				#Work around for storcli bug

				$CLI_LOCATION$MCLI_NAME /c$i show 2>>./$fileName/script_workspace/lsiget_errorlog.txt | grep "iBBU" > /dev/null 2>&1
				if [ "$?" -eq "0" ]; then
				echo "iBBU is on Controller" > ./$fileName/script_workspace/BBU_PRESENT_C$i.txt
				fi
				$CLI_LOCATION$MCLI_NAME /c$i show 2>>./$fileName/script_workspace/lsiget_errorlog.txt | grep "Cachevault_Info" > /dev/null 2>&1
				if [ "$?" -eq "0" ]; then
				echo "SuperCaP is on Controller" > ./$fileName/script_workspace/SuperCaP_PRESENT_C$i.txt
				fi
				

				
			
				echo "Collecting Information for Controller C$i with storcli..."	
			
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt
				echo "..................................../$MCLI_NAME /c$i show all........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show all 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt
			
				echo "Collecting Enclosure Information for Controller C$i with storcli..."
			
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_show_all-status_C$i.txt
				echo "................................../$MCLI_NAME /c$i/eall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_show_all-status_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/eall show all >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_show_all-status_C$i.txt

				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/eall show status......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_show_all-status_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/eall show status >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_show_all-status_C$i.txt

		
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt
				echo ".............................../$MCLI_NAME /c$i/eall/sall show all...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/eall/sall show all >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt
			
	
# Not really "/call show all" - need to get rid of duplicate "Controller =" entries.
			
				$CLI_LOCATION$MCLI_NAME /c$i show all 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt		
			
			
			
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				echo "......................................./$MCLI_NAME show all.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME show all | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
		
				if [ -f ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt ]; then 
					#cho ".................................................||................................................."
					echo "................................................Time................................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Current Controller Date/Time" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Current System Date/time" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi	
			
				echo "Collecting Information for Controller C$i with storcli..."
				echo "Collecting Logical Disk Information for Controller C$i with storcli..."
			
				#cho ".................................................||................................................."
				echo "......................................./$MCLI_NAME /c$i show.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1

				#cho ".................................................||................................................."
				echo "..........................................PCI-E Link Speed.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show termlog 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "PCIE Link Status/Ctrl" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1


				#cho ".................................................||................................................."
				echo "..................................../$MCLI_NAME /c$i show bios........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show bios 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1

	
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/vall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/vall show all |2>>./$fileName/script_workspace/lsiget_errorlog.txt  sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt



				$CLI_LOCATION$MCLI_NAME /c$i/vall show autobgi 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "No VDs have been configured" > /dev/null 2>&1
				if [ "$?" -ne "0" ] ; then
					#cho ".................................................||................................................."
					echo "........................................VD Auto BGI Status.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i/vall show autobgi 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi



				$CLI_LOCATION$MCLI_NAME /c$i/vall/sall show rebuild 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "In progress" > /dev/null 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo "........................................Drive Rebuild Status........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i/vall/sall show rebuild 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi
					 
				$CLI_LOCATION$MCLI_NAME /c$i/vall/sall show copyback 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "In progress" > /dev/null 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo "........................................Drive CopyBack Status......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i/vall/sall show copyback 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi

				$CLI_LOCATION$MCLI_NAME /c$i/vall/sall show initialization 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "In progress" > /dev/null 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo ".....................................Drive Initialization Status...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i/vall/sall show initialization 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi

				$CLI_LOCATION$MCLI_NAME /c$i/vall/sall show erase 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "In progress" > /dev/null 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo ".........................................Drive Erase Status........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i/vall/sall show erase 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi



				$CLI_LOCATION$MCLI_NAME /c$i/vall show init 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "In progress" > /dev/null 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo ".......................................VD Initialization Status....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i/vall show init 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi

				$CLI_LOCATION$MCLI_NAME /c$i/vall show bgi 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "In progress" > /dev/null 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo ".................................VD Background Initialization Status................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i/vall show bgi 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi


				$CLI_LOCATION$MCLI_NAME /c$i/vall show cc 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "In progress" > /dev/null 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo "....................................VD Consistency Check Status....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i/vall show cc 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi

				$CLI_LOCATION$MCLI_NAME /c$i/vall show migrate 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "In progress" > /dev/null 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo "........................................VD Migration Status........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i/vall show migrate 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi



				$CLI_LOCATION$MCLI_NAME /c$i/vall show expansion 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "Controller has no VD" > /dev/null 2>&1
				if [ "$?" -ne "0" ] ; then
					#cho ".................................................||................................................."
					echo "........................................VD Expansion Status........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i/vall show expansion 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi



	
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i show freespace..................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show freespace 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
	
				#cho ".................................................||................................................."
				echo "...................................../$MCLI_NAME /c$i show cc......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show cc 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "...................................../$MCLI_NAME /c$i show pr......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show pr 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1

				#cho ".................................................||................................................."
				echo "................................./$MCLI_NAME /c$i show copyback....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show copyback 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1

				#cho ".................................................||................................................."
				echo "...................................../$MCLI_NAME /c$i show eghs....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show enableesmarter 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1

				#cho ".................................................||................................................."
				echo "................................/$MCLI_NAME /c$i show perfmode......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show perfmode 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1

				#cho ".................................................||................................................."
				echo ".................................../$MCLI_NAME /c$i show ds........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show ds 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1

				#cho ".................................................||................................................."
				echo ".................................../$MCLI_NAME /c$i show aso........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show aso 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1

				#cho ".................................................||................................................."
				echo "................................./$MCLI_NAME /c$i show bootdrive...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show bootdrive 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1

				#cho ".................................................||................................................."
				echo "................................./$MCLI_NAME /c$i show cachebypass.................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show cachebypass 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1


				$CLI_LOCATION$MCLI_NAME /c$i show preservedcache 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "No Virtual" > /dev/null 2>&1
				if [ "$?" -ne "0" ] ; then
					#cho ".................................................||................................................."
					echo ".............................../$MCLI_NAME /c$i show preservedcache................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i show preservedcache 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi


		
		
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/pall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/pall show all 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/eall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/eall show 2>>./$fileName/script_workspace/lsiget_errorlog.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
			
				if [ -f ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt ]; then 
					#cho ".................................................||................................................."
					echo "............................................Temperatures............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Temperature Sensor for" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "ROC temperature" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi	


				if [ -f ./$fileName/script_workspace/BBU_PRESENT_C$i.txt ] ; then
				#cho ".................................................||................................................."
				echo "..........................................iBBU Temperature.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/bbu show all 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep -m 1 Temperature >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				$CLI_LOCATION$MCLI_NAME /c$i/bbu show all 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "Over Temperature" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi
				
				if [ -f ./$fileName/script_workspace/SuperCaP_PRESENT_C$i.txt ] ; then
				#cho ".................................................||................................................."
				echo "..........................................CV Temperature............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/cv show all 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep -m 1 Temperature >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				$CLI_LOCATION$MCLI_NAME /c$i/cv show all 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "Over Temperature" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi
	
	
	
# MegaCli syntax - PR to add output to storcli
	
				#cho ".................................................||................................................."
				echo ".......................................Enclosure Temperature........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME encinfo a$i 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep -e "Temp Sensor                  :" -e "Temperature                  :" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
							
	
				echo "Collecting Physical Disk Information for Controller C$i with storcli..."
			
				if [ -f ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt ]; then 
					#cho ".................................................||................................................."
					echo ".........................................Drive Temperature.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Drive Temperature =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Media Error Count.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Media Error Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#cho ".................................................||................................................."
					echo "......................................Predictive Failure Count......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Predictive Failure Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................Device Speed............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Device Speed =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#cho ".................................................||................................................."
					echo "................................Port # - Status - Linkspeed - SAS Address..........................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#echo "...................................Port #/Status/Linkspeed/SAS Address.............................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Gb/s   0x" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
			
				fi	
	
	
				if [ -f ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt ]; then 
					echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."

					echo "...............................................Drives..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$CLI_LOCATION$MCLI_NAME /call/eall/sall show | $grep -e SATA -e SAS >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt

					#cho ".................................................||................................................."
					echo "............................................Shield Counter.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Shield Counter =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Media Error Count.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Media Error Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Other Error Count.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Other Error Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Drive Temperature.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Drive Temperature =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "......................................Predictive Failure Count......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Predictive Failure Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "...................................S.M.A.R.T alert flagged by drive................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "S.M.A.R.T alert flagged by drive =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".................................................SN................................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "SN =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".................................................WWN................................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "WWN =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Firmware Revision.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Firmware Revision =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".............................................Raw size..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Raw size =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................Coerced size............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Coerced size =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt | $grep -v "Non" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "..........................................Non Coerced size.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Non Coerced size =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................Device Speed............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Device Speed =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".............................................Link Speed............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Link Speed =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "..........................................Drive write cache............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Drive write cache =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Logical Sector Size........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Logical Sector Size =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Physical Sector Size......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Physical Sector Size =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "...........................................Drive position..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Drive position =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Enclosure position........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Enclosure position =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "........................................Connected Port Number......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Connected Port Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "...........................................Sequence Number.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Sequence Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt | $grep -v "Predictive" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Commissioned Spare........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Commissioned Spare =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "...........................................Emergency Spare.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Emergency Spare =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".............................Last Predictive Failure Event Sequence Number.........................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Last Predictive Failure Event Sequence Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".................................Successful diagnostics completion on..............................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Successful diagnostics completion on =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................SED Capable............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "SED Capable =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................SED Enabled..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "SED Enabled =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "..............................................Secured..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Secured =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "...............................................Locked..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Locked =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Needs EKM Attention..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Needs EKM Attention =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................PI Eligible..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "PI Eligible =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "..........................................Wide Port Capable..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Wide Port Capable =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "................................Port # - Status - Linkspeed - SAS Address..........................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Gb/s   0x" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."

					echo "............................................Inquiry Data............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$CLI_LOCATION$MCLI_NAME /c$i/eall/sall show all j | $grep "Inquiry Data" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
				

			
				fi	
			
				if [ -f ./$fileName/script_workspace/BBU_PRESENT_C$i.txt ] ; then			
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/bbu show all......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/bbu show all | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi

				if [ -f ./$fileName/script_workspace/SuperCaP_PRESENT_C$i.txt ] ; then
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/cv show all........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/cv show all | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi
		
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/fall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/fall show all | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo ".............................../$MCLI_NAME /c$i/fall import preview..................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i/fall import preview | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "................................./$MCLI_NAME /c$i show termlog........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$CLI_LOCATION$MCLI_NAME /c$i show termlog  >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
			
			
			
#done for controller #ing i.e. $i
			done
			

			#cho ".................................................||................................................."
			echo "..............................................Basics :.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
							
			#cho ".................................................||................................................."
			echo "............................................Controller #............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Controller =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt | $grep -v "Temperature" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...............................................Model #.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Model =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt | $grep -v "Support Config Page Model" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...........................................Serial Number #.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Serial Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "....................................Current Controller Date/Time...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Current Controller Date/Time =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "......................................Current System Date/time......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Current System Date/time =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "..............................................Mfg Date.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Mfg Date =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................Rework Date............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Rework Date =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................Revision No............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Revision No =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."

			#cho ".................................................||................................................."
			echo "..............................................Version :............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt

			echo ".......................................Firmware Package Build......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Firmware Package Build =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................Bios Version............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Bios Version =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...........................................NVDATA Version..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "NVDATA Version =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".........................................Boot Block Version........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Boot Block Version =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".........................................Bootloader Version........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Bootloader Version =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................Driver Name............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Driver Name =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...........................................Driver Version..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Driver Version =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."

			#cho ".................................................||................................................."
			echo "................................................Bus :..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt

			echo ".............................................Vendor Id.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Vendor Id =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt | $grep -v "SubVendor" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".............................................Device Id.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Device Id =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt | $grep -v "SubDevice" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................SubVendor Id............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "SubVendor Id =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................SubDevice Id............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "SubDevice Id =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...........................................Host Interface..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Host Interface =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "..........................................Device Interface.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Device Interface =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".............................................Bus Number............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Bus Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................Device Number..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Device Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...........................................Function Number.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Function Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt

			#cho ".................................................||................................................."
			echo "......................................Pending Images in Flash :....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt

			#cho ".................................................||................................................."
			echo ".............................................Image name............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Image name =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt

			#cho ".................................................||................................................."
			echo "..............................................Status :.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt

			#cho ".................................................||................................................."
			echo ".........................................Controller Status.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Controller Status =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".....................................Memory Correctable Errors......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Memory Correctable Errors =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "....................................Memory Uncorrectable Errors....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Memory Uncorrectable Errors =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".........................................ECC Bucket Count..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "ECC Bucket Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...................................Any Offline VD Cache Preserved..................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Any Offline VD Cache Preserved =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".............................................BBU Status............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "BBU Status =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "....................................Support PD Firmware Download...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Support PD Firmware Download =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".........................................Lock Key Assigned.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Lock Key Assigned =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...................................Failed to get lock key on bootup................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Failed to get lock key on bootup =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...................................Lock key has not been backed up.................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Lock key has not been backed up =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "..................................Bios was not detected during boot................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Bios was not detected during boot =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "......................Controller must be rebooted to complete security operation...................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Controller must be rebooted to complete security operation =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "................................A rollback operation is in progress................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "A rollback operation is in progress =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "..................................At least one PFK exists in NVRAM.................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "At least one PFK exists in NVRAM =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "..........................................SSC Policy is WB.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "SSC Policy is WB =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "................................Controller has booted into safe mode................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Controller has booted into safe mode =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt

	
			echo "##################################Supported Adapter Operations :####################################" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt

				
# Returns from - Make sure at least 1 MegaRAID Adapter is identified
		fi


###########################################################################################################################
# Component version number collection
###########################################################################################################################
#Get the MegaCli version that came bundled with the script
		if [ "$mcli_Bundled_work" = "YES" ]; then
			./$MCLI_NAME -v | grep -i StorCli | awk '{ print$6 }' > ./$fileName/script_workspace/mcli_Bundled_version.txt
		fi

# Get the MegaCli version that was pre-existing
		if [ "$tw_cli_Existing_work" = "YES" ]; then
			$MCLI_NAME -v | grep -i StorCli | awk '{ print$6 }' > ./$fileName/script_workspace/mcli_Existing_version.txt
		fi

###########################################################################################################################
# Done with MegaCli!
###########################################################################################################################				


# Return if MacOS for MegaRAID
	fi
###########################################################################################################################
# Script Version
###########################################################################################################################
###Update on Code Set Change
	echo "$Capture_Script_Version" > ./$fileName/script_workspace/lsigetlunix_version.txt

###########################################################################################################################
# Data to help troubleshoot script issues.
###########################################################################################################################


	#cho ".................................................||................................................."
	echo "............................whoami - user executing lsigetlunix.sh script..........................." >> ./$fileName/script_workspace/script_diag.txt
	whoami >> ./$fileName/script_workspace/script_diag.txt 2>&1
	#cho ".................................................||................................................."
	echo "..................groups - groups user executing lsigetlunix.sh script belongs to..................." >> ./$fileName/script_workspace/script_diag.txt
	groups >> ./$fileName/script_workspace/script_diag.txt 2>&1
	#cho ".................................................||................................................."
	echo "..........................ls -latr - files in subdir script was executed from......................." >> ./$fileName/script_workspace/script_diag.txt
	ls -latr >> ./$fileName/script_workspace/script_diag.txt
	#cho ".................................................||................................................."
	echo "....................................set - environment for script...................................." >> ./$fileName/script_workspace/script_diag.txt
	set >> ./$fileName/script_workspace/script_diag.txt 2>&1
	#cho ".................................................||................................................."
	echo "....................................env - environment for script...................................." >> ./$fileName/script_workspace/script_diag.txt
	env >> ./$fileName/script_workspace/script_diag.txt 2>&1
	echo "......................................Command Line and Options......................................" >> ./$fileName/script_workspace/script_diag.txt
	echo "$0 $@" > ./$fileName/script_workspace/cmd_line.txt
	TWCMDLINE=`cat ./$fileName/script_workspace/cmd_line.txt`
	

	export TWCMDLINE 
	

	echo "$0 $@" >> ./$fileName/script_workspace/script_diag.txt

###########################################################################################################################
# System capture comment
###########################################################################################################################
	if [ "$TWcomment" != "" ] ; then  echo "$TWcomment" > ./$fileName/Comment.txt ; fi


###########################################################################################################################
# Component version number collection
###########################################################################################################################
#Get the tw_cli version that came bundled with the script
	if [ "$tw_cli_Bundled_work" = "YES" ]; then
		./$CLI_NAME help 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep version | awk  '{ print $4 }' | sed -e 's/)//' > ./$fileName/script_workspace/tw_cli_Bundled_version.txt
	fi

# Get the tw_cli version that was pre-existing
	if [ "$tw_cli_Existing_work" = "YES" ]; then
		$CLI_NAME help 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep version | awk  '{ print $4 }' | sed -e 's/)//' > ./$fileName/script_workspace/tw_cli_Existing_version.txt
	fi


########################################################################################################################### 
###########################################################################################################################
# Common - Collect system information 
###########################################################################################################################
###########################################################################################################################


	echo "Collecting System info..."

	if [ -f re_execute_variable_shell.txt ] ; then
		mv  re_execute_variable_shell.txt ./$fileName/script_workspace
	fi

	uname -a > ./$fileName/uname-a.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	
	dmesg > /dev/null 2>&1
	if [ "$?" = "0" ]; then
	dmesg > ./$fileName/dmesg.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	if [ -d /var/log ]; then
		mkdir ./$fileName/var_log
		cp /var/log/* ./$fileName/var_log 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	if [ -d /var/log/vmware ]; then
		mkdir ./$fileName/var_log/vmware
		cp /var/log/vmware/* ./$fileName/var_log/vmware 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	if [ -d /etc ]; then
		mkdir ./$fileName/etc
		# removed entry here that took everything from /etc .. really?
	fi

#Brackets get rid of messages on FreeBSD if files don't exist.
#	{ cp -p /etc/*.conf ./$fileName/conf; } 2>>./$fileName/script_workspace/lsiget_errorlog.txt 
#	{ cp -p /etc/*release ./$fileName/; } 2>>./$fileName/script_workspace/lsiget_errorlog.txt


	for i in sysconfig/diskdump sysconfig/harddisks sysconfig/hwconf fstab raidtab ; do
		if [ -f /etc/$i ] ; then cp -p /etc/$i ./$fileName/etc ; fi
	done

	for i in a b c d e f g h i j k l m n o p q r s t u v w x y z;do
		for j in vendor model timeout;do
			if [ -e /sys/block/sd$i/device/$j ];then
				#cho ".................................................||................................................."
				echo "....................................cat /sys/block/sd$i/device/$j..................................." >> ./$fileName/sd_time_out_value.txt 2>&1
				cat /sys/block/sd$i/device/$j >> ./$fileName/sd_time_out_value.txt 2>&1
			fi
		done
	done

	if [ -d /proc ] && mkdir -p ./$fileName/proc; then
		for x in pci interrupts cpuinfo buddyinfo devices diskstats dma filesystems iomem ioports kallsyms mdstat meminfo misc modules mounts mtrr partitions pci slabinfo stat uptime version vmstat zoneinfo scsi ; do 
			if [ -f /proc/$x ] ; then
				cat /proc/$x > ./$fileName/proc/$x 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			fi
		done
	fi

	if [ -d /proc/sys/vm ]; then 
		for x in /proc/sys/vm/*; do 
			#cho ".................................................||................................................."
			echo "...................................................................................................." >> ./$fileName/proc/sys-vm.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			echo $x >> ./$fileName/proc/sys-vm.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			cat $x >> ./$fileName/proc/sys-vm.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		done
	fi

	if [ -d /proc/scsi/3w-xxxx ]; then 
		for x in /proc/scsi/3w-xxxx/*; do 
			#cho ".................................................||................................................."
			echo "...................................................................................................." >> ./$fileName/proc/scsi-3w-xxxx.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			echo $x >> ./$fileName/proc/scsi-3w-xxxx.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			cat $x >> ./$fileName/proc/scsi-3w-xxxx.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		done
	fi

	if [ -d /proc/scsi/3w-9xxx ]; then 
		for x in /proc/scsi/3w-9xxx/*; do 
			#cho ".................................................||................................................."
			echo "...................................................................................................." >> ./$fileName/proc/scsi-3w-9xxx.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			echo $x >> ./$fileName/proc/scsi-3w-9xxx.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			cat $x >> ./$fileName/proc/scsi-3w-9xxx.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		done
	fi
	
	if [ -d /proc/scsi/megaraid_sas ]; then 
		for x in /proc/scsi/megaraid_sas/*; do 
			#cho ".................................................||................................................."
			echo "...................................................................................................." >> ./$fileName/proc/scsi-megaraid_sas.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			echo $x >> ./$fileName/proc/scsi-megaraid_sas.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			cat $x >> ./$fileName/proc/scsi-megaraid_sas.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		done
	fi
	
	if [ -d /proc/scsi/sg ]; then 
		for x in /proc/scsi/sg/*; do 
			#cho ".................................................||................................................."
			echo "...................................................................................................." >> ./$fileName/proc/scsi-sg.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			echo $x >> ./$fileName/proc/scsi-sg.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			cat $x >> ./$fileName/proc/scsi-sg.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		done
	fi
	
	if [ -f /proc/scsi/scsi ]; then 
		for x in /proc/scsi/scsi; do 
			#cho ".................................................||................................................."
			echo "...................................................................................................." >> ./$fileName/proc/scsi-scsi.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			echo $x >> ./$fileName/proc/scsi-scsi.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			cat $x >> ./$fileName/proc/scsi-scsi.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		done
	fi
		
	
	[ -f /proc/bus/pci/devices ] && cat /proc/bus/pci/devices > ./$fileName/proc/pci-devices 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	[ -f /proc/bus/usb/devices ] && cat /proc/bus/usb/devices > ./$fileName/proc/usb-devices 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	[ -f /proc/bus/input/devices ] && cat /proc/bus/input/devices > ./$fileName/proc/input-devices 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	[ -f /proc/net/dev ] && cat /proc/net/dev > ./$fileName/proc/net-dev 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	
	uptime > /dev/null 2>&1
	if [ "$?" = "0" ]; then 
		uptime > ./$fileName/uptime.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	lsmod > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		lsmod > ./$fileName/lsmod.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi


	lspci > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		lspci > ./$fileName/lspci.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	lspci -e > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		lspci -e > ./$fileName/lspci-e.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	lspci -p > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		lspci -p > ./$fileName/lspci-p.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	lspci -t > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		lspci -t > ./$fileName/lspci-t.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	lspci -x > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		lspci -x > ./$fileName/lspci-x.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	lspci -vv > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		lspci -vv > ./$fileName/lspci-vv.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	lspci -vvv > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		lspci -vvv > ./$fileName/lspci-vvv.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	lspci -tvvv > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		lspci -tvvv > ./$fileName/lspci-tvvv.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	scanpci -v > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		scanpci -v > ./$fileName/scanpci-v.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	rpm -q -a -i > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		rpm -q -a -i > ./$fileName/rpm-q-a-i.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	df > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		df > ./$fileName/df.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	df -h > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		df -h > ./$fileName/df-h.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	df -ha > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		df -ha > ./$fileName/df-ha.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	df -hat > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		df -hat > ./$fileName/df-hat.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	df -haT > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		df -haT > ./$fileName/df-haT.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	df -Hai > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		df -Hai > ./$fileName/df-Hai.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	df -Hami > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		df -Hami > ./$fileName/df-Hami.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi


	who > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		who > ./$fileName/who.txt  2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	who -b > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		who -b > ./$fileName/who-b.txt  2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	who -m > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		who -m > ./$fileName/who-m.txt  2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi
	
	top -b -n 1 > /dev/null 2>&1
	if [ "$?" = "0" ]; then
	top -b -n 1 > ./$fileName/top-b-n1.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	top -l1 > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		top -l1 > ./$fileName/top-l1.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	if [ -d /boot ]; then ls -latr /boot > ./$fileName/boot.txt; fi

	if [ -f /boot/grub/menu.lst ]; then cp -p /boot/grub/menu.lst ./$fileName/; fi
	
	ps > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		ps > ./$fileName/ps.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	ps -e > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		ps -e > ./$fileName/ps-e.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	ps -ef > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		ps -ef > ./$fileName/ps-ef.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	ps -ea > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		ps -ea > ./$fileName/ps-ea.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	ps -auxw > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		ps -auxw > ./$fileName/ps-auxw.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	fdisk -l > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		fdisk -l > ./$fileName/fdisk-l.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	fdisk -lu > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		fdisk -lu > ./$fileName/fdisk-lu.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	vgs > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		if [ ! -d ./$fileName/lvm ]; then mkdir ./$fileName/lvm; fi
		vgs > ./$fileName/lvm/vgs.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi
	
	lvs > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		if [ ! -d ./$fileName/lvm ]; then mkdir ./$fileName/lvm; fi
		lvs > ./$fileName/lvm/lvs.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	pvs > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		if [ ! -d ./$fileName/lvm ]; then mkdir ./$fileName/lvm; fi
		pvs > ./$fileName/lvm/pvs.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	lvdisplay > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		if [ ! -d ./$fileName/lvm ]; then mkdir ./$fileName/lvm; fi
		lvdisplay > ./$fileName/lvm/lvdisplay.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	pvdisplay > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		if [ ! -d ./$fileName/lvm ]; then mkdir ./$fileName/lvm; fi
		pvdisplay > ./$fileName/lvm/pvdisplay.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	sysctl -a > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		sysctl -a > ./$fileName/sysctl-a.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	sysctl -ad > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		sysctl -ad > ./$fileName/sysctl-ad.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	sysctl -ah > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		sysctl -ah > ./$fileName/sysctl-ah.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi
	
	sysctl -adh > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		sysctl -adh > ./$fileName/sysctl-adh.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	vmstat > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		vmstat > ./$fileName/vmstat.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	vmstat -i > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		vmstat -i > ./$fileName/vmstat-i.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	dmidecode > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		dmidecode > ./$fileName/dmidecode.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	biosdecode > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		biosdecode > ./$fileName/biosdecode.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	vpddecode > /dev/null 2>&1
	if [ "$?" = "0" ]; then
		vpddecode > ./$fileName/vpddecode.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	if [ -f /etc/lvm/lvm.conf ] ; then 
		if [ ! -d ./$fileName/lvm ]; then mkdir ./$fileName/lvm; fi
		cp /etc/lvm/lvm.conf ./$fileName/lvm 2>>./$fileName/script_workspace/lsiget_errorlog.txt 
	fi


	lsscsi > /dev/null 2>&1

	if [ $? = 0 ] ; then
	
		#cho ".................................................||................................................."
		echo "...............................................lsscsi..............................................." >> ./$fileName/lsscsi-all.txt
		lsscsi  >> ./$fileName/lsscsi-all.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		for i in c d g H k l v ; do
			echo "..............................................lsscsi -$i............................................" >> ./$fileName/lsscsi-all.txt
			lsscsi -$i >> ./$fileName/lsscsi-all.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		done
	
		# Non standard out, leave separate
		echo "..............................................lsscsi -V............................................" >> ./$fileName/lsscsi-all.txt
		lsscsi -V >> ./$fileName/lsscsi-all.txt 2>&1 
		
		lsscsi -vg >> ./$fileName/lsscsi-vg.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		
		#cho ".................................................||................................................."
		echo "........................All lines lspci -vv with 'LSI' OR '3ware' in the line......................." >> ./$fileName/Controller_Disk_Association.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		lspci -vv | $grep -e LSI -e 3ware >> ./$fileName/Controller_Disk_Association.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		
		#cho ".................................................||................................................."
		echo ".............................................lsscsi -vg............................................." >> ./$fileName/Controller_Disk_Association.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		lsscsi -vg >> ./$fileName/Controller_Disk_Association.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		
		else

		#cho ".................................................||................................................."
		echo "...............lsscsi NOT installed! Recommend Installation if supported on this OS................." >> ./$fileName/Controller_Disk_Association.txt
	
	fi
	
	showsel  > /dev/null 2>&1
	if [ "$?" = "0" ] ; then
		showsel  > ./$fileName/showsel.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi
	
	lshw  > /dev/null 2>&1
	if [ "$?" = "0" ] ; then
		lshw > ./$fileName/lshw.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi


###########################################################################################################################
# Common - 3DM(2) data collection
###########################################################################################################################
	echo "Collecting 3DM(2) version info..."

#3dm data collection
	
	if [ -f  /usr/sbin/3dmd ]; then
		if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
		mkdir ./$fileName/LSI_Products/3ware/3DM
		strings /usr/sbin/3dmd | fgrep 1.13. > ./$fileName/LSI_Products/3ware/3DM/3dm_version.txt
	fi
	
	if [ -f  /etc/3dm.conf ]; then 
		if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
		cp /etc/3dm.conf ./$fileName/LSI_Products/3ware/3DM/ 
	fi

	if [ -f  /var/log/3w-aenlog.txt ]; then 
		if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
		cp /var/log/3w-* ./$fileName/LSI_Products/3ware/3DM/ 
	fi

#Other 3dm logs????

#3dm2 data collection
	if [ -f  /usr/sbin/3dm2 ]; then 
		if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
		mkdir ./$fileName/LSI_Products/3ware/3DM2 
	fi

###Update on Code Set Change
	for i in 2.00.00.038 2.01. 2.02. 2.03. 2.04. 2.05. 2.06. 2.07. 2.08. 2.09.; do
		if [ -f  /usr/sbin/3dm2 ]; then 
			strings /usr/sbin/3dm2 | fgrep $i >> ./$fileName/script_workspace/3dm2_api_ver.txt
		fi
	done

	if [ -f  ./$fileName/script_workspace/3dm2_api_ver.txt ]; then 
		if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
		grep -n . ./$fileName/script_workspace/3dm2_api_ver.txt | $grep 1: | cut -d: -f2 > ./$fileName/LSI_Products/3ware/3DM2/3dm2api_ver.txt
		grep -n . ./$fileName/script_workspace/3dm2_api_ver.txt | $grep 3: | cut -d: -f2 > ./$fileName/LSI_Products/3ware/3DM2/3dm2_ver.txt
	fi


	if [ -f /etc/3dm2/3dm2.conf ]; then 
		if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
		cp /etc/3dm2/3dm2.conf ./$fileName/LSI_Products/3ware/3DM2 
	fi

	cp /var/log/tdm_aen* ./$fileName/LSI_Products/3ware/3DM2 2>>./$fileName/script_workspace/lsiget_errorlog.txt

	if [ -f /opt/AMCC/log.txt ]; then cp /opt/AMCC/log.txt ./$fileName/LSI_Products/3ware/3DM2 2>>./$fileName/script_workspace/lsiget_errorlog.txt ; fi

	if [ -f /var/log/tw_mgmt.log ]; then 
		if [ -f ./$fileName/LSI_Products/3ware/3DM2 ]; then cp /var/log/tw_mgmt.log ./$fileName/LSI_Products/3ware/3DM2; else
			if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
			cp /var/log/tw_mgmt.log ./$fileName/LSI_Products/3ware/ 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		fi
	fi

#Other 3dm2 logs????

###########################################################################################################################
# MegaRAID Storage Manager Log files - Other Unix distros?
###########################################################################################################################



	if [ -d "$MSM_HOME"/MegaMonitor ] ; then
		mkdir ./$fileName/LSI_Products/MegaRAID/MSM
		echo "Collecting MSM logs..."
		cp "$MSM_HOME"/MegaMonitor/* ./$fileName/LSI_Products/MegaRAID/MSM 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		cp "$MSM_HOME"/*.log ./$fileName/LSI_Products/MegaRAID/MSM 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		cp "$MSM_HOME"/*.txt ./$fileName/LSI_Products/MegaRAID/MSM 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

	if [ "$MSM_HOME" = "" ] ; then
		if [ -d /usr/local/"MegaRAID Storage Manager"/MegaMonitor ] ; then
			mkdir ./$fileName/LSI_Products/MegaRAID/MSM
			echo "Collecting MSM logs..."
			cp /usr/local/"MegaRAID Storage Manager"/MegaMonitor/* ./$fileName/LSI_Products/MegaRAID/MSM 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			cp /usr/local/"MegaRAID Storage Manager"/*.log ./$fileName/LSI_Products/MegaRAID/MSM 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			cp /usr/local/"MegaRAID Storage Manager"/*.txt ./$fileName/LSI_Products/MegaRAID/MSM 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		fi
	fi

	if [ -f ./$fileName/LSI_Products/MegaRAID/MSM ] ; then
		if [ -f /etc/init.d/vivaldiframeworkd  ] ; then
			/etc/init.d/vivaldiframeworkd status 2 > ./$fileName/LSI_Products/MegaRAID/MSM/Status.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		fi
	fi

	if [ -f ./$fileName/LSI_Products/MegaRAID/MSM ] ; then
		if [ -f /etc/init.d/mrmonitor   ] ; then
			/etc/init.d/mrmonitor status 2 >> ./$fileName/LSI_Products/MegaRAID/MSM/Status.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			/etc/init.d/mrmonitor -v 2 >> ./$fileName/LSI_Products/MegaRAID/MSM/Status.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
			#Keep seperate, mrmonitord_version.txt used in other parts of the script
			/etc/init.d/mrmonitor -v | cut -d m -f 2 | cut -d r -f 2 > ./$fileName/LSI_Products/MegaRAID/MSM/mrmonitord_version.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		fi
	fi



###########################################################################################################################
# Nytro WarpDrive
###########################################################################################################################
	if [ -f /opt/lsidiag/lsi_diag.sh ]; then
		echo "Collecting WarpDrive info via lsi_diag.sh script..."
		mkdir $fileName/LSI_Products/WarpDrive
		cd $fileName/LSI_Products/WarpDrive
		/opt/lsidiag/lsi_diag.sh
		cd ../..
		
		else

		if [ -n "$DCLI_NAME" ]; then
			wdlist=`./$DCLI_NAME -listall | awk '{if ($1 == $1 + 0) print $1}'`
				if [ -n "$wdlist" ]; then
					wdcnt=`echo $wdlist | sed 's/\n/ /g' | awk '{print NF}'`
					echo "Collecting WarpDrive info... $wdcnt controller(s) found"
					mkdir ./$fileName/LSI_Products/WarpDrive
					./$DCLI_NAME -listall > $fileName/LSI_Products/WarpDrive/dcli-listall.txt 2>&1
					for i in $wdlist; do
							cd $fileName/LSI_Products/WarpDrive
							../../../$DCLI_NAME -c $i -paniclog -f extract > ./dcli-c$i-paniclog.txt 2>&1
							../../../$DCLI_NAME -c $i -dump dcli-c$i-dump.txt > /dev/null 2>&1	
							cd ../../..
							./$DCLI_NAME -c $i -getsmartlog -path $fileName/LSI_Products/WarpDrive/ > ./$fileName/LSI_Products/WarpDrive/dcli-c$i-smartlog.txt 2>&1
							./$DCLI_NAME -c $i -list   > $fileName/LSI_Products/WarpDrive/dcli-c$i-list.txt 2>&1
							./$DCLI_NAME -c $i -showvpd > $fileName/LSI_Products/WarpDrive/dcli-c$i-vpd.txt 2>&1
							./$DCLI_NAME -c $i -health > $fileName/LSI_Products/WarpDrive/dcli-c$i-health.txt 2>&1
							./$DCLI_NAME -c $i -power > $fileName/LSI_Products/WarpDrive/dcli-c$i-power.txt 2>&1
							./$DCLI_NAME -c $i -getpowerval > $fileName/LSI_Products/WarpDrive/dcli-c$i-powerval.txt 2>&1
					done
				fi
		fi

# collect lsidiag config and all collected event data
		lsiDiagCfgDir=
			if [ -d /etc/lsidiag ]; then
				lsiDiagCfgDir="/etc/lsidiag"

				else

				if [ -d /etc/sysconfig/lsidiag ]; then
					lsiDiagCfgDir="/etc/sysconfig/lsidiag"
				fi 
			fi 

			if [ -n "$lsiDiagCfgDir" ]; then
				mkdir -p ./$fileName/LSI_Products/WarpDrive/lsidiag
				mkdir -p ./$fileName/LSI_Products/WarpDrive/lsidiag/config
				cp $lsiDiagCfgDir/*.ini ./$fileName/LSI_Products/WarpDrive/lsidiag/config/.
				lsiDiagLogDir=`awk -F= '{if ($1 == "log_file_dir") print $2}' $lsiDiagCfgDir/diag_config.ini`
					if [ -n "$lsiDiagLogDir" ] && [ -d $lsiDiagLogDir ]; then
						cp -r $lsiDiagLogDir $fileName/lsidiag/log
					fi
			fi 
	fi


###########################################################################################################################
# Nytro XD (CCoH) - EOL, all dumped to one file - causes segfault on latest storcli 1.09.08 commenting out.
###########################################################################################################################
	
	if [ "$SKIP_XD" != "YES" ] ; then
		if [ -n "$MCLI_LOCATION$MCLI_NAME" ]; then
			$MCLI_LOCATION$MCLI_NAME /xd show >/dev/null 2>&1
				if [ $? -eq 0 ] ; then
					echo "Collecting Nytro XD info..."
					mkdir $fileName/LSI_Products/NytroXD
					#cho ".................................................||................................................."
					echo "......................................../$MCLI_NAME /xd show........................................" >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt
					$MCLI_LOCATION$MCLI_NAME /xd show  >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt 2>&1
					echo "................................./$MCLI_NAME /xd show type=cachedev................................." >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt
					$MCLI_LOCATION$MCLI_NAME /xd show type=cachedev >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt 2>&1
					echo "........................../$MCLI_NAME /xd show type=cachedev state=assigned........................." >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt
					$MCLI_LOCATION$MCLI_NAME /xd show type=cachedev state=assigned >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt 2>&1
					echo "........................./$MCLI_NAME /xd show type=cachedev state=unassigned........................" >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt
					$MCLI_LOCATION$MCLI_NAME /xd show type=cachedev state=unassigned >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt 2>&1
					echo "............................../$MCLI_NAME /xd show type=virtualdrive................................" >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt
					$MCLI_LOCATION$MCLI_NAME /xd show type=virtualdrive >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt 2>&1
					echo "......................./$MCLI_NAME /xd show type=virtualdrive state=assigned........................" >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt
					$MCLI_LOCATION$MCLI_NAME /xd show type=virtualdrive state=assigned >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt 2>&1
					echo "...................../$MCLI_NAME /xd show type=virtualdrive state=unassigned........................" >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt
					$MCLI_LOCATION$MCLI_NAME /xd show type=virtualdrive state=unassigned >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt 2>&1
					echo "..................................../$MCLI_NAME /xd show perfmon...................................." >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt
					$MCLI_LOCATION$MCLI_NAME /xd show perfmon >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt 2>&1
					echo "...................................../$MCLI_NAME /xd/wdall show....................................." >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt
					$MCLI_LOCATION$MCLI_NAME /xd/wdall show  >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt 2>&1
					echo "................................./$MCLI_NAME /xd/wdall show safeid.................................." >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt
					$MCLI_LOCATION$MCLI_NAME /xd/wdall show safeid >> ./$fileName/LSI_Products/NytroXD/NytroXD.txt 2>&1
				fi
		fi
	fi


###########################################################################################################################
# Nytro MegaRaid (CSA)
###########################################################################################################################
	if [ -n `cat ./$fileName/script_workspace/num_mraid_adapters.txt` ] ; then
		csa_list=`$MCLI_LOCATION$MCLI_NAME -cfgcachecadedsply -aall nolog 2>&1 | awk '{if ($1 == "Adapter:") print $2}'`
			if [ -n "$csa_list" ] ; then
				echo "Collecting Nytro MegaRAID info..."
				mkdir ./$fileName/LSI_Products/NytroMegaRAID
				$MCLI_LOCATION$MCLI_NAME -cfgcachecadedsply -aall nolog > $fileName/LSI_Products/NytroMegaRAID/mr-cfgcachecadedsply-all.txt 2>&1
				for i in $csa_list ; do
					for slot in 4 6 ; do
						$MCLI_LOCATION$MCLI_NAME -PDDffDiag -DumpSmartLog -PhysDrv[252:$slot] -a$i nolog > $fileName/LSI_Products/NytroMegaRAID/mr-smartlog-c$i-slot$slot.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME -PDDffDiag -DumpPanicLog -query -PhysDrv[252:$slot] -a$i nolog > $fileName/LSI_Products/NytroMegaRAID/mr-paniclog-query-c$i-slot$slot.txt 2>&1
						# Add check for valid panic logs and save them
					done
				done
			fi
	fi


###########################################################################################################################
echo "Collecting and Processing system logs/messages files..."
###########################################################################################################################
#Linux, FreeBSD
###########################################################################################################################
	if [ -f /var/log/messages ]; then cp -p /var/log/messages* ./$fileName/
		ls -latr ./$fileName/messages* > ./$fileName/script_workspace/all_copied_messages.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi
###########################################################################################################################
#VMWare
###########################################################################################################################
	if [ -f /var/log/vmkernel ]; then cp -p /var/log/vmkernel* ./$fileName/
		ls -latr ./$fileName/vmkernel* > ./$fileName/script_workspace/all_copied_messages.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi
###########################################################################################################################
#MacOS
###########################################################################################################################
	if [ -f /var/log/system.log ]; then cp -p /var/log/system.log* ./$fileName/
		ls -latr ./$fileName/system.log* > ./$fileName/script_workspace/all_copied_messages.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi
###########################################################################################################################
#Solaris
###########################################################################################################################
	if [ -f /var/adm/messages ]; then cp -p /var/adm/messages* ./$fileName/
		ls -latr ./$fileName/messages* > ./$fileName/script_workspace/all_copied_messages.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	fi

###########################################################################################################################
# Start additional info collection
###########################################################################################################################
	if [ -f ./local.sh ]; then
		echo "Collecting additional info via local.sh..."
		mkdir ./$fileName/addedInfo
		./local.sh ./$fileName/addedInfo
	fi 

###########################################################################################################################
#Start Linux Only Section
###########################################################################################################################

# Add udevadm and test if udevinfo exists

# Pulled out udevadm support - Hung OpenSuse 12.2 32bit and Centos 6.3 64bit.

#Device Mapping Info Linux
	for i in by-id by-label by-path by-uuid; do
		if [ -f  /dev/disk/$i ]; then ls -la /dev/disk/$i > ./$fileName/ls-la_dev_disk_$i.txt ; fi
	done


		
	{ udevinfo help > /dev/null 2>&1; } 2>>./$fileName/script_workspace/lsiget_errorlog.txt
	if [ "$?" -ne "127" ]; then
		#Existing tw_cli present
		udevinfo_Existing=YES
	else
		#Existing tw_cli not present
		udevinfo_Existing=NO
	fi


	if [ "$OS_LSI" = "linux" ]; then 

		echo "...................................................................................................." >> ./$fileName/modinfo.txt

		TwareDriver=`lsmod | awk '{print $1}' | $grep 3w`
		if [ "$?" -eq "0" ] ; then
			for i in $TwareDriver ;	do
				echo "LSI 3ware driver module name $i" >> ./$fileName/modinfo.txt
				modinfo $i >> ./$fileName/modinfo.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
				echo "...................................................................................................." >> ./$fileName/modinfo.txt
					if  modinfo -n $i >>/dev/null 2>>./$fileName/script_workspace/lsiget_errorlog.txt; then  
						if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
						cp -p `modinfo -n $i` ./$fileName/LSI_Products/3ware
					fi  
		
			done
		
			else
			
			echo "LSI 3ware driver module not installed or IN-Kernel driver used if driver installed." >> ./$fileName/modinfo.txt
			echo "...................................................................................................." >> ./$fileName/modinfo.txt
		fi

		MRSASDriver=`lsmod | awk '{print $1}' | $grep mega`
		
		if [ "$?" -eq "0" ] ; then
			for i in $MRSASDriver ;	do
				echo "LSI MegaRAID SAS driver module name $i" >> ./$fileName/modinfo.txt
				modinfo $i >> ./$fileName/modinfo.txt
				echo "...................................................................................................." >> ./$fileName/modinfo.txt
				if  modinfo -n $i >>/dev/null 2>>./$fileName/script_workspace/lsiget_errorlog.txt; then  
					cp -p `modinfo -n $i` ./$fileName/LSI_Products/MegaRAID
				fi  
		
			done
			
			else
			
			echo "LSI MegaRAID SAS driver module not installed or IN-Kernel driver used if driver installed." >> ./$fileName/modinfo.txt
			echo "...................................................................................................." >> ./$fileName/modinfo.txt
		fi
		
		LSISASDriver=`lsmod | awk '{print $1}' | $grep mpt`
		
		if [ "$?" -eq "0" ] ; then
			for i in $LSISASDriver ; do
				echo "LSI SAS HBA driver module name $i" >> ./$fileName/modinfo.txt
				modinfo $i >> ./$fileName/modinfo.txt
				echo "...................................................................................................." >> ./$fileName/modinfo.txt
				if  modinfo -n $i >>/dev/null 2>>./$fileName/script_workspace/lsiget_errorlog.txt; then  
					cp -p `modinfo -n $i` ./$fileName/LSI_Products/HBA
				fi  
	
			done
	
			else

			echo "LSI SAS HBA driver module not installed or IN-Kernel driver used if driver installed." >> ./$fileName/modinfo.txt
			echo "...................................................................................................." >> ./$fileName/modinfo.txt
		fi
		
		
		

		
		for t in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
			if [ -e /sys/block/sd$t ]; then

				if [ "$udevinfo_Existing" = "YES" ] ; then	
				#cho ".................................................||................................................."
				echo "....................................udevinfo-q_all-n_dev_sd$t......................................." >> ./$fileName/udevinfo-q_all-n.txt	
				udevinfo -q all -n /dev/sd$t >> ./$fileName/udevinfo-q_all-n.txt 2>> ./$fileName/script_workspace/lsiget_errorlog.txt
				else
				#cho ".................................................||................................................."
				#echo "....................................udevadm_info-a-n_dev_sd$t......................................." >> ./$fileName/udevadm_info-a-n.txt	
				echo "....................................Pulled out udevadm support - Hung OpenSuse 12.2 32bit and Centos 6.3 64bit........................................" >> ./$fileName/udevadm_info-a-n.txt					
				#udevadm info -a -n /dev/sd$t >> ./$fileName/udevadm_info-a-n.txt 2>> ./$fileName/script_workspace/lsiget_errorlog.txt
				fi
			fi
		done


		
		#
		#Add additional md data gathering lines
		#
		
		
		#
		#All 3ware Performance Tuning parameters should be gathered here!
		#
		echo "Collecting 3ware SD Device Performance Tuning Data..."
		
		for t in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
			if [ -e /sys/block/sd$t ]; then
		
		
		
				if [ "$udevinfo_Existing" = "YES" ] ; then		
				udevinfo -q all -n /dev/sd$t | $grep -e AMCC_ -e 3ware_ -e 9750- >> /dev/null 2>>./$fileName/script_workspace/lsiget_errorlog.txt
				#else
				#udevadm info -a -n /dev/sd$t | $grep -e AMCC -e 3ware -e 9750- >> /dev/null 2>>./$fileName/script_workspace/lsiget_errorlog.txt
				fi

				if [ "$?" -eq "0" ] ; then
					if [ ! -d ./$fileName/LSI_Products/3ware ];then mkdir ./$fileName/LSI_Products/3ware ; fi
					#cho ".................................................||................................................."
					echo "...................................................................................................." >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "Recommended settings are listed below for fw 3.08.00.004 & later." >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "For earlier fw use 64 for max_sectors. The latest code set should" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "be used for best performance. Feel free to experiment with" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "these setting for your particular environment, especially if you are" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "using the MD driver. These settings are primarily for the 95/6xx" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "class of controllers but may be beneficial for earlier controllers." >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "...................................................................................................." >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "See http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=5418 for more information of Performance Tuning." >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "...................................................................................................." >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "echo "128" > /sys/block/sd$t/queue/max_sectors_kb" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "echo "1024" > /sys/block/sd$t/queue/nr_requests" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
									if [ -f /sys/block/sd$t/queue/scheduler ]; then
									echo "echo "deadline" > /sys/block/sd$t/queue/scheduler" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
									fi
					echo "blockdev --setra 16384 /dev/sd$t" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "...................................................................................................."  >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "Note: setra MUST be done last otherwise it goes back to default!" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "...................................................................................................."  >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "........................................Current Settings for........................................" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
							udevinfo -q all -n /dev/sd$t >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
					echo "...................................................................................................."  >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
		
					echo "cat /sys/block/sd$t/queue/max_sectors_kb" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					cat /sys/block/sd$t/queue/max_sectors_kb >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
			
					echo "cat /sys/block/sd$t/queue/nr_requests" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					cat /sys/block/sd$t/queue/nr_requests >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					
					if [ -e /sys/block/sd$t/queue/scheduler ]; then 
						echo "cat /sys/block/sd$t/queue/scheduler" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
						cat /sys/block/sd$t/queue/scheduler >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					fi
					
					echo "blockdev --getra /dev/sd$t" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					blockdev --getra /dev/sd$t >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt        	
					
					echo "...................................................................................................."  >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "...................................................................................................."  >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "The following dumps all info in the /sys/block/sd$t/queue/ directory" >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					echo "...................................................................................................."  >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
		
					for j in /sys/block/sd$t/queue/*; do 
						echo $j >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt 2>&1
						cat $j >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt 2>&1
					done
					
					for j in /sys/block/sd$t/queue/iosched/*; do 
						echo $j `cat $j` >> ./$fileName/LSI_Products/3ware/3ware_Perf_Tuning_sd$t.txt
					done
				
						
				fi
			fi		
		done
		
		#
		#All Generic Performance Tuning parameters should be gathered here!
		#
		echo "Collecting Generic SD Device Performance Tuning Data..."
		echo "Collecting - parted -s /dev/sdX print..."
		echo "Note: An active mkfs will cause this script to pause..."
		for t in a b c d e f g h i j k l m n o p q r s t u v w x y z; do

			if [ -e /sys/block/sd$t ]; then
					
				#cho ".................................................||................................................."
				echo "...................................................................................................." >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "If this is NOT a 3ware device the recommendations may not apply!" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "The Generic version of the 3ware_Perf_Tuning_sdx.txt files are being created" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "since udevinfo -q all -n /dev/sd$t | $grep -e AMCC_ -e 3ware_ has not been" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "successful in all cases to identify a 3ware device. " >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "...................................................................................................." >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "See http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=5418 for more information of Performance Tuning." >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "...................................................................................................." >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "Recommended settings are listed below for fw 3.08.00.004 & later." >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "For earlier fw use 64 for max_sectors. The latest code set should" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "be used for best performance. Feel free to experiment with" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "these setting for your particular environment, especially if you are" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "using the MD driver. These settings are primarily for the 95/6xx" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "class of controllers but may be beneficial for earlier controllers." >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "...................................................................................................." >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "echo "128" > /sys/block/sd$t/queue/max_sectors_kb" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "echo "1024" > /sys/block/sd$t/queue/nr_requests" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt

				if [ -f /sys/block/sd$t/queue/scheduler ]; then
					echo "echo "deadline" > /sys/block/sd$t/queue/scheduler" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				fi

				echo "blockdev --setra 16384 /dev/sd$t" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "...................................................................................................."  >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "Note: setra MUST be done last otherwise it goes back to default!" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "...................................................................................................."  >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "........................................Current Settings for........................................" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				udevinfo -q all -n /dev/sd$t >> ./$fileName/Generic_Perf_Tuning_sd$t.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
				echo "...................................................................................................."  >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "cat /sys/block/sd$t/queue/max_sectors_kb" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				cat /sys/block/sd$t/queue/max_sectors_kb >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
		
				echo "cat /sys/block/sd$t/queue/nr_requests" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				cat /sys/block/sd$t/queue/nr_requests >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
		
				if [ -e /sys/block/sd$t/queue/scheduler ]; then 
					echo "cat /sys/block/sd$t/queue/scheduler" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
					cat /sys/block/sd$t/queue/scheduler >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				fi
		
				echo "blockdev --getra /dev/sd$t" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				blockdev --getra /dev/sd$t >> ./$fileName/Generic_Perf_Tuning_sd$t.txt        	
				
				echo "...................................................................................................."  >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "...................................................................................................."  >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "The following dumps all info in the /sys/block/sd$t/queue/ directory" >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				echo "...................................................................................................."  >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				
				for j in /sys/block/sd$t/queue/*; do 
					echo $j >> ./$fileName/Generic_Perf_Tuning_sd$t.txt 2>&1
					cat $j >> ./$fileName/Generic_Perf_Tuning_sd$t.txt 2>&1
				done
				
				for j in /sys/block/sd$t/queue/iosched/*; do 
					echo $j `cat $j` >> ./$fileName/Generic_Perf_Tuning_sd$t.txt
				done
				
				#cho ".................................................||................................................."
				echo ".....................................parted -s /dev/sd$t print......................................." >> ./$fileName/parted_print_sdX.txt
				parted -s /dev/sd$t print >> ./$fileName/parted_print_sdX.txt
				
			fi
		done
				
				
		echo "Notice: MR_MONITOR Error Codes are in Decimal, megasas_aen_polling Error Codes are in HEX, they report the same information." > ./$fileName/LSI_Products/MegaRAID/Hex_Decimal_Numbering_Conventions.txt
		echo "I.E. '"'megasas_aen_polling[1]: event code 0x0087'"' is the same as '"'MR_MONITOR[3226]: <MRMON135> Controller ID: 0  Global Hot Spare created: --:--:2'"'" >> ./$fileName/LSI_Products/MegaRAID/Hex_Decimal_Numbering_Conventions.txt
		echo "The MR_MONITOR error files have the Decimal equivalent embedded after the severity level for ease of identification." >> ./$fileName/LSI_Products/MegaRAID/Hex_Decimal_Numbering_Conventions.txt
		echo "The megasas error files have the Hex equivalent embedded after the severity level for ease of identification." >> ./$fileName/LSI_Products/MegaRAID/Hex_Decimal_Numbering_Conventions.txt
		
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with ' 3w' in the line#" > ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with 'MR_MONITOR' in the line#" > ./$fileName/LSI_Products/MegaRAID/AENs/mrmonitord_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with 'megasas' OR 'megaraid_sas' in the line#" > ./$fileName/LSI_Products/MegaRAID/megaraid_driver_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with 'kernel: mpt' OR '] mpt' in the line#" > ./$fileName/LSI_Products/HBA/hba_driver_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with 'MR_MONITOR' OR 'megasas' OR 'megaraid_sas' in the line#" > ./$fileName/LSI_Products/MegaRAID/megaraid_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with ' kernel: sd ' OR '] sd ' in the line#" > ./$fileName/OS_Disk_driver_messages.txt
		
		#Make sure zipped messages don't overwrite unzipped.
		
		for i in s.20 s.19 s.18 s.17 s.16 s.15 s.14 s.13 s.12 s.11 s.10 s.9 s.8 s.7 s.6 s.5 s.4 s.3 s.2 s.1 s.0 s; do
			if [ -f ./$fileName/message$i ]; then 
				if [ -f  ./$fileName/message$i.gz ]; then mv ./$fileName/message$i.gz ./$fileName/message$i.gz.dupe_name ; fi
			fi
		done


		
		#Checks for compressed/dated message files.
		
		gunzip ./$fileName/messages-????????.gz 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		ls ./$fileName/messages-???????? > ./$fileName/script_workspace/messages_dated.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		for i in $( cat ./$fileName/script_workspace/messages_dated.txt );do
			grep " 3w" $i >> ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt
			grep "MR_MONITOR" $i >> ./$fileName/LSI_Products/MegaRAID/AENs/mrmonitord_messages.txt
			grep "kernel: megasas" $i >> ./$fileName/LSI_Products/MegaRAID/megaraid_driver_messages.txt
			grep "kernel: mpt" $i >> ./$fileName/LSI_Products/HBA/hba_driver_messages.txt
			egrep "MR_MONITOR|kernel: megasas" $i >> ./$fileName/LSI_Products/MegaRAID/megaraid_messages.txt
			grep " kernel: sd " $i >> ./$fileName/OS_Disk_driver_messages.txt
		done
		
		
		for i in s.20 s.19 s.18 s.17 s.16 s.15 s.14 s.13 s.12 s.11 s.10 s.9 s.8 s.7 s.6 s.5 s.4 s.3 s.2 s.1 s.0 s; do
			if [ -f  ./$fileName/message$i.gz ]; then gunzip ./$fileName/message$i.gz ; fi
		done
		
		
		for i in s.20 s.19 s.18 s.17 s.16 s.15 s.14 s.13 s.12 s.11 s.10 s.9 s.8 s.7 s.6 s.5 s.4 s.3 s.2 s.1 s.0 s; do
			if [ -f ./$fileName/message$i ]; then $grep " 3w" ./$fileName/message$i >> ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then $grep "MR_MONITOR" ./$fileName/message$i >> ./$fileName/LSI_Products/MegaRAID/AENs/mrmonitord_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then egrep "megasas|megaraid_sas" ./$fileName/message$i >> ./$fileName/LSI_Products/MegaRAID/megaraid_driver_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then egrep "kernel: mpt|] mpt" ./$fileName/message$i >> ./$fileName/LSI_Products/HBA/hba_driver_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then egrep "MR_MONITOR|megasas|megaraid_sas" ./$fileName/message$i >> ./$fileName/LSI_Products/MegaRAID/megaraid_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then egrep " kernel: sd |] sd " ./$fileName/message$i >> ./$fileName/OS_Disk_driver_messages.txt ; fi
		done
		
		grep " (0x03:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x03_9000_ERROR.txt 
		grep " (0x04:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x04_9000_EVENT.txt 
		grep " (0x06:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x06_9000_DRIVER.txt 
		grep " (0x09:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x09_LINUX_OS.txt 
		grep " (0x0B:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0B_API.txt 
		grep " (0x0C:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0C_3DMPLUS.txt 
		grep " (0x0D:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0D_CLI.txt 
		grep " (0x0E:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0E_7000_ERROR.txt 
		grep " (0x0F:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0F_7000_EVENT.txt 
		grep " (0x11:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x11_7000_DRIVER.txt  
		
		for i in _x03_9000_ERROR _x04_9000_EVENT _x06_9000_DRIVER _x09_LINUX_OS _x0B_API _x0C_3DMPLUS _x0D_CLI _x0E_7000_ERROR _x0F_7000_EVENT _x11_7000_DRIVER; do
			if [ ! -s ./$fileName/LSI_Products/3ware/3ware_driver$i.txt ]; then rm ./$fileName/LSI_Products/3ware/3ware_driver$i.txt ; fi
		done
		
		grep " (0x03:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x03_9000_ERROR.txt 
		grep " (0x04:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x04_9000_EVENT.txt 
		grep " (0x06:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_9000_DRIVER.txt 
		grep " (0x09:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x09_LINUX_OS.txt 
		grep " (0x0B:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0B_API.txt 
		grep " (0x0C:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0C_3DMPLUS.txt 
		grep " (0x0D:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0D_CLI.txt 
		grep " (0x0E:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0E_7000_ERROR.txt 
		grep " (0x0F:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0F_7000_EVENT.txt 
		grep " (0x11:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x11_7000_DRIVER.txt  
		
		for i in _x03_9000_ERROR _x04_9000_EVENT _x06_9000_DRIVER _x09_LINUX_OS _x0B_API _x0C_3DMPLUS _x0D_CLI _x0E_7000_ERROR _x0F_7000_EVENT _x11_7000_DRIVER; do
			if [ ! -s ./$fileName/LSI_Products/3ware/OS_Disk_driver$i.txt ]; then rm ./$fileName/LSI_Products/3ware/OS_Disk_driver$i.txt ; fi
		done
		
		
		
# Final fi
	fi
#
# End Linux Only Section
#

###########################################################################################################################
#Start VMWare Only Section
###########################################################################################################################

	if [ "$VMWARE_SUPPORTED" = "YES" ]; then 

#Leftover from original 3.x/4.x vmware support	
#		TwareDriver=`vmkload_mod -b | awk '{print $1}' | $grep 3w`
#		if [ "$?" -eq "0" ] ; then
#			for i in $TwareDriver ; do
#				echo "3ware driver module name " $i "\n" >> ./$fileName/modinfo.txt
#				modinfo $i >> ./$fileName/modinfo.txt
#					if  modinfo -n $i >>/dev/null 2>>./$fileName/script_workspace/lsiget_errorlog.txt; then  
#						cp -p `modinfo -n $i` ./$fileName/
#					fi  
#
#			done
#
#			else
#
#			echo "Driver Module not installed or IN-Kernel Driver used if driver installed." >> ./$fileName/modinfo.txt
#		fi
#
#		echo "" >> ./$fileName/modinfo.txt
#
#		MRSASDriver=`vmkload_mod -b | awk '{print $1}' | $grep megaraid_sas`
#		if [ "$?" -eq "0" ] ; then
#			for i in $MRSASDriver ;	do
#				echo "MegaRAID SAS driver module name " $i "\n" >> ./$fileName/modinfo.txt
#				modinfo $i >> ./$fileName/modinfo.txt
#				if  modinfo -n $i >>/dev/null 2>>./$fileName/script_workspace/lsiget_errorlog.txt; then  
#					cp -p `modinfo -n $i` ./$fileName/
#				fi  
#		
#			done
#		
#			else
#			
#			echo "3ware MegaRAID SAS Driver Module not installed or IN-Kernel Driver used if driver installed." >> ./$fileName/modinfo.txt
#		fi

		vmkload_mod -l > ./$fileName/vmkload_mod-l.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		vmkload_mod -b > ./$fileName/vmkload_mod-b.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		
		if [ -d /proc/vmware ]; then
			for x in watchpoints vmkstor version uptime timers thermmon stats procstats pci mem log intr-tracker interrupts cpuinfo chipset ; do 
				if [ -f /proc/vmware/$x ] ; then
					cat /proc/vmware/$x > ./$fileName/proc/vmware-$x 2>>./$fileName/script_workspace/lsiget_errorlog.txt
				fi
			done
		fi

		if [ -d /proc/vmware/config/Disk ]; then
			for x in  UseReportLUN UseLunReset UseDeviceReset ThroughputCap SupportSparseLUN SPCmdsToSwitch SPBlksToSwitch SharesNormal SharesLow SharesHigh SectorMaxDiff SchedQuantum SchedQControlVMSwitches SchedQControlSeqReqs SchedNumReqOutstanding SANDevicesWithAPFailover RetryUnitAttention ResetThreadMin ResetThreadMax ResetThreadExpires ResetPeriod ResetOverdueLogPeriod ResetOnFailover ResetMaxRetries ResetLatency PreventVMFSOverwrite PathEvalTime MaxVCNotReadyTime MaxResetLatency MaxLUN MaxDS400NotReadyTime MaskLUNs EnableNaviReg DumpMaxRetries DiskMaxIOSize DelayOnBusy BandwidthCap ; do 
				if [ -f /proc/vmware/config/Disk/$x ] ; then
					cat /proc/vmware/config/Disk/$x > ./$fileName/proc/vmware-config-Disk-$x 2>>./$fileName/script_workspace/lsiget_errorlog.txt
				fi
			done
		fi
		
		if [ -d /proc/vmware/config/Scsi ]; then
			for x in TimeoutTMThreadRetry TimeoutTMThreadMin TimeoutTMThreadMax TimeoutTMThreadLatency TimeoutTMThreadExpires SCSITimeout_ScanTime SCSITimeout_ReabortTime ScsiRestartStalledQueueLatency ScsiRescanAllHbas ScanOnDriverLoad ReserveBacktrace PrintCmdErrors PassthroughLocking MaxReserveTotalTime MaxReserveTime MaxReserveBacktrace LogMultiPath LogAborts ConflictRetries CompareLUNNumber ; do 
				if [ -f /proc/vmware/config/Scsi/$x ] ; then
					cat /proc/vmware/config/Scsi/$x > ./$fileName/proc/vmware-config-Scsi-$x 2>>./$fileName/script_workspace/lsiget_errorlog.txt
				fi
			done
		fi
		
		
		echo "#All lines from all vmkernel files (vmkernel, vmkernel.0-20(.gz), vmkernel-????????(.gz) with '3w-9xxx or 3ware' in the line#" > ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt
		
		echo "#All lines from all vmkernel files (vmkernel, vmkernel.0-20(.gz), vmkernel-????????(.gz) with 'SCSI or Scsi' in the line#" > ./$fileName/OS_Disk_driver_messages.txt
		
		#Make sure zipped vmkernel don't overwrite unzipped.
		
		for i in l.20 l.19 l.18 l.17 l.16 l.15 l.14 l.13 l.12 l.11 l.10 l.9 l.8 l.7 l.6 l.5 l.4 l.3 l.2 l.1 l.0 s; do
			if [ -f ./$fileName/vmkerne$i ]; then 
				if [ -f  ./$fileName/vmkerne$i.gz ]; then mv ./$fileName/vmkerne$i.gz ./$fileName/vmkerne$i.gz.dupe_name ; fi
			fi
		done
		
		#Checks for compressed/dated vmkernel files.
		
		gunzip ./$fileName/vmkernel-????????.gz 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		ls ./$fileName/vmkernel-???????? > ./$fileName/script_workspace/messages_dated.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		for i in $( cat ./$fileName/script_workspace/messages_dated.txt );do
			grep "3w-9xxx\|3ware" $i >> ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt
			grep "SCSI\|Scsi" $i >> ./$fileName/OS_Disk_driver_messages.txt
		done
		
		
		for i in l.20 l.19 l.18 l.17 l.16 l.15 l.14 l.13 l.12 l.11 l.10 l.9 l.8 l.7 l.6 l.5 l.4 l.3 l.2 l.1 l.0 s; do
			if [ -f  ./$fileName/vmkerne$i.gz ]; then gunzip ./$fileName/vmkerne$i.gz ; fi
		done
		
		
		for i in l.20 l.19 l.18 l.17 l.16 l.15 l.14 l.13 l.12 l.11 l.10 l.9 l.8 l.7 l.6 l.5 l.4 l.3 l.2 l.1 l.0 s; do
			if [ -f ./$fileName/vmkerne$i ]; then $grep "3w-9xxx\|3ware" ./$fileName/vmkerne$i >> ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt ; fi
			if [ -f ./$fileName/vmkerne$i ]; then $grep "SCSI\|Scsi" ./$fileName/vmkerne$i >> ./$fileName/OS_Disk_driver_messages.txt ; fi
		done
		
		grep -i " (0x03:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x03_9000_ERROR.txt 
		grep -i " (0x04:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x04_9000_EVENT.txt 
		grep -i " (0x06:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x06_9000_DRIVER.txt 
		grep -i " (0x09:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x09_LINUX_OS.txt 
		grep -i " (0x0B:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0B_API.txt 
		grep -i " (0x0C:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0C_3DMPLUS.txt 
		grep -i " (0x0D:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0D_CLI.txt 
		grep -i " (0x0E:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0E_7000_ERROR.txt 
		grep -i " (0x0F:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0F_7000_EVENT.txt 
		grep -i " (0x11:0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x11_7000_DRIVER.txt  
		
		for i in _x03_9000_ERROR _x04_9000_EVENT _x06_9000_DRIVER _x09_LINUX_OS _x0B_API _x0C_3DMPLUS _x0D_CLI _x0E_7000_ERROR _x0F_7000_EVENT _x11_7000_DRIVER; do
			if [ ! -s ./$fileName/LSI_Products/3ware/3ware_driver$i.txt ]; then rm ./$fileName/LSI_Products/3ware/3ware_driver$i.txt ; fi
		done
		
		grep -i " (0x03:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x03_9000_ERROR.txt 
		grep -i " (0x04:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x04_9000_EVENT.txt 
		grep -i " (0x06:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_9000_DRIVER.txt 
		grep -i " (0x09:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x09_LINUX_OS.txt 
		grep -i " (0x0B:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0B_API.txt 
		grep -i " (0x0C:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0C_3DMPLUS.txt 
		grep -i " (0x0D:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0D_CLI.txt 
		grep -i " (0x0E:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0E_7000_ERROR.txt 
		grep -i " (0x0F:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0F_7000_EVENT.txt 
		grep -i " (0x11:0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x11_7000_DRIVER.txt  
		
		for i in _x03_9000_ERROR _x04_9000_EVENT _x06_9000_DRIVER _x09_LINUX_OS _x0B_API _x0C_3DMPLUS _x0D_CLI _x0E_7000_ERROR _x0F_7000_EVENT _x11_7000_DRIVER; do
			if [ ! -s ./$fileName/LSI_Products/3ware/OS_Disk_driver$i.txt ]; then rm ./$fileName/LSI_Products/3ware/OS_Disk_driver$i.txt ; fi
		done
		

		if [ "$VMWARE_5x" = "YES" ]; then 
		echo $fileName >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "####################################################################################################" >> ./$fileName/esxcli_output.txt	
		echo ".....................................esxcli hardware cpu list......................................." >> ./$fileName/esxcli_output.txt
		esxcli hardware cpu list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt 
		#cho ".................................................||................................................."
		echo "...................................esxcli hardware ipmi fru list...................................." >> ./$fileName/esxcli_output.txt
		esxcli hardware ipmi fru list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "...................................esxcli hardware ipmi sdr list...................................." >> ./$fileName/esxcli_output.txt
		esxcli hardware ipmi sdr list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "...................................esxcli hardware ipmi sel list...................................." >> ./$fileName/esxcli_output.txt
		esxcli hardware ipmi sel list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "..................................esxcli hardware bootdevice list..................................." >> ./$fileName/esxcli_output.txt
		esxcli hardware bootdevice list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo ".....................................esxcli hardware clock get......................................" >> ./$fileName/esxcli_output.txt
		esxcli hardware clock get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo ".....................................esxcli hardware memory get....................................." >> ./$fileName/esxcli_output.txt
		esxcli hardware memory get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "......................................esxcli hardware pci list......................................" >> ./$fileName/esxcli_output.txt
		esxcli hardware pci list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "....................................esxcli hardware platform get...................................." >> ./$fileName/esxcli_output.txt
		esxcli hardware platform get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "...................................esxcli hardware trustedboot get.................................." >> ./$fileName/esxcli_output.txt
		esxcli hardware trustedboot get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "####################################################################################################" >> ./$fileName/esxcli_output.txt	
		echo ".......................................esxcli network ip get........................................" >> ./$fileName/esxcli_output.txt		
		esxcli network ip get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "....................................esxcli network ip connection...................................." >> ./$fileName/esxcli_output.txt
		esxcli network ip connection 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "####################################################################################################" >> ./$fileName/esxcli_output.txt	
		echo "......................................esxcli software vib get......................................." >> ./$fileName/esxcli_output.txt		
		esxcli software vib get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo ".....................................esxcli software vib list......................................." >> ./$fileName/esxcli_output.txt
		esxcli software vib list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo ".................................esxcli software vib list | grep LSI................................" >> ./$fileName/esxcli_output.txt
		esxcli software vib list | grep LSI 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo ".................................esxcli software vib list | grep mpt................................" >> ./$fileName/esxcli_output.txt
		esxcli software vib list | grep mpt 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo ".................................esxcli software vib list | grep 3w................................." >> ./$fileName/esxcli_output.txt
		esxcli software vib list | grep 3w 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "####################################################################################################" >> ./$fileName/esxcli_output.txt	
		echo "................................esxcli storage core adapter stats get..............................." >> ./$fileName/esxcli_output.txt		
		esxcli storage core adapter stats get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "...................................esxcli storage core device list.................................." >> ./$fileName/esxcli_output.txt
		esxcli storage core device list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "..............................esxcli storage core device vaai status get............................" >> ./$fileName/esxcli_output.txt
		esxcli storage core device vaai status get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "..............................esxcli storage core device detached list.............................." >> ./$fileName/esxcli_output.txt
		esxcli storage core device detached list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo ".............................esxcli storage core device partition list.............................." >> ./$fileName/esxcli_output.txt
		esxcli storage core device partition list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "................................esxcli storage core device stats get................................" >> ./$fileName/esxcli_output.txt
		esxcli storage core device stats get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "...............................esxcli storage core device world list................................" >> ./$fileName/esxcli_output.txt
		esxcli storage core device world list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "####################################################################################################" >> ./$fileName/esxcli_output.txt	
		echo ".....................................esxcli system module list......................................" >> ./$fileName/esxcli_output.txt	
		esxcli system module list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "..............................esxcli system process stats running get..............................." >> ./$fileName/esxcli_output.txt
		esxcli system process stats running get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "....................................esxcli system process list......................................" >> ./$fileName/esxcli_output.txt
		esxcli system process list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "...................................esxcli system stats uptime get..................................." >> ./$fileName/esxcli_output.txt
		esxcli system stats uptime get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo ".....................................esxcli system hostname get....................................." >> ./$fileName/esxcli_output.txt
		esxcli system hostname get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo ".......................................esxcli system time get......................................." >> ./$fileName/esxcli_output.txt
		esxcli system time get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo ".......................................esxcli system uuid get......................................." >> ./$fileName/esxcli_output.txt
		esxcli system uuid get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "......................................esxcli system version get....................................." >> ./$fileName/esxcli_output.txt
		esxcli system version get 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		fi

		if [ "$VMWARE_4x" = "YES" ]; then 
		echo $fileName >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "####################################################################################################" >> ./$fileName/esxcli_output.txt	
		echo ".................................esxcli corestorage claimrule list.................................." >> ./$fileName/esxcli_output.txt
		esxcli corestorage claimrule list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt 
		#cho ".................................................||................................................."
		echo "...................................esxcli corestorage device list..................................." >> ./$fileName/esxcli_output.txt
		esxcli corestorage device list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "####################################################################################################" >> ./$fileName/esxcli_output.txt	
		echo "...................................esxcli network connection list..................................." >> ./$fileName/esxcli_output.txt		
		esxcli network connection list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "####################################################################################################" >> ./$fileName/esxcli_output.txt	
		echo ".......................................esxcli nmp device list......................................." >> ./$fileName/esxcli_output.txt		
		esxcli nmp device list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		#cho ".................................................||................................................."
		echo "####################################################################################################" >> ./$fileName/esxcli_output.txt	
		echo ".........................................esxcli vms vm list........................................." >> ./$fileName/esxcli_output.txt		
		esxcli vms vm list 2>>./$fileName/script_workspace/lsiget_errorlog.txt >> ./$fileName/esxcli_output.txt
		fi
		
# Final fi
	fi
#
# End VMWare Only Section
#

###########################################################################################################################
#Start FreeBSD Only Section
###########################################################################################################################

	if [ "$OS_LSI" = "freebsd" ]; then 
	
		devinfo -r > ./$fileName/devinfo-r.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		devinfo -ru > ./$fileName/devinfo-ru.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		devinfo -rv > ./$fileName/devinfo-rv.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		devinfo -ruv > ./$fileName/devinfo-ruv.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		pciconf -l -cv > ./$fileName/pciconf-l-cv.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		# kldstat like modinfo, kldload & kldunload are like modload & mod unload
		kldstat -v > ./$fileName/kldstat-v.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		camcontrol devlist  > ./$fileName/camcontrol_inquiry.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		pkg_info > ./$fileName/pkg_info.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		lsvfs > ./$fileName/lsvfs.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		
		df | $grep dev/ | cut -d "/" -f 3 | cut -d " " -f 1 > ./$fileName/script_workspace/df.out
		for i in $( cat ./$fileName/script_workspace/df.out );do
		dumpfs -m /dev/$i > ./$fileName/dumpfs-m_$i.txt
		done
		
		
		
		#
		#Add additional SW Raid data gathering lines
		#
		
		#
		#All 3ware Performance Tuning parameters should be gathered here!
		#
		echo "Collecting System Level Disk Performance Tuning Data..."
		#cho ".................................................||................................................."
		echo "...................................................................................................." >> ./$fileName/Perf_Tuning.txt
		
		echo "http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=7008" >> ./$fileName/Perf_Tuning.txt
		echo "http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=6456" >> ./$fileName/Perf_Tuning.txt
		echo "These are some parameters that you can tune under FreeBSD." >> ./$fileName/Perf_Tuning.txt
		echo  >> ./$fileName/Perf_Tuning.txt
		echo "Read ahead caching:" >> ./$fileName/Perf_Tuning.txt
		echo "Current: sysctl vfs.read_max (default is 8)" >> ./$fileName/Perf_Tuning.txt
		echo "Recommended: sysctl vfs.read_max=256" >> ./$fileName/Perf_Tuning.txt 
		echo  >> ./$fileName/Perf_Tuning.txt
		echo "Write caching:" >> ./$fileName/Perf_Tuning.txt
		echo "Current: sysctl vfs.write_behind (default is 1)" >> ./$fileName/Perf_Tuning.txt
		echo "Recommended: sysctl vfs.write_behind=1" >> ./$fileName/Perf_Tuning.txt
		echo >> ./$fileName/Perf_Tuning.txt
		echo "Bytes Outstanding before Write Cache Flush:" >> ./$fileName/Perf_Tuning.txt
		echo "Current: sysctl vfs.hirunningspace" >> ./$fileName/Perf_Tuning.txt
		echo "Recommended: sysctl vfs.hirunningspace=1048576" >> ./$fileName/Perf_Tuning.txt
		echo >> ./$fileName/Perf_Tuning.txt
		echo "You will need to experiment with different values to" >> ./$fileName/Perf_Tuning.txt
		echo "see what yields the best performance for you in your application." >> ./$fileName/Perf_Tuning.txt
		echo "...................................................................................................." >> ./$fileName/Perf_Tuning.txt
		if [ -f  ./$fileName/sysctl-ad.txt ]; then 
			echo "Current settings..." >> ./$fileName/Perf_Tuning.txt
			grep vfs.read_max ./$fileName/sysctl-ad.txt >> ./$fileName/Perf_Tuning.txt
			grep vfs.read_max ./$fileName/sysctl-a.txt >> ./$fileName/Perf_Tuning.txt
			grep vfs.write_behind ./$fileName/sysctl-ad.txt >> ./$fileName/Perf_Tuning.txt
			grep vfs.write_behind ./$fileName/sysctl-a.txt >> ./$fileName/Perf_Tuning.txt
			grep vfs.hirunningspace ./$fileName/sysctl-ad.txt >> ./$fileName/Perf_Tuning.txt
			grep vfs.hirunningspace ./$fileName/sysctl-a.txt >> ./$fileName/Perf_Tuning.txt
		fi
	
	
		echo "#All lines from all message files (messages, messages.0-20(.bz2), messages-????????(.bz2) with 'kernel: twa' in the line#" > ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.bz2), messages-????????(.bz2) with 'kernel: da' in the line#" > ./$fileName/OS_Disk_driver_messages.txt
		
		#echo "#All lines from all message files (messages, messages.0-20(.bz2), messages-????????(.bz2) with 'MR_MONITOR' in the line#" > ./$fileName/LSI_Products/MegaRAID/AENs/mrmonitord_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.bz2), messages-????????(.bz2) with 'kernel: mfi' in the line#" > ./$fileName/LSI_Products/MegaRAID/megaraid_driver_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with 'kernel: mpt' in the line#" > ./$fileName/LSI_Products/HBA/hba_driver_messages.txt
		
		#echo "#All lines from all message files (messages, messages.0-20(.bz2), messages-????????(.bz2) with 'MR_MONITOR' OR 'kernel: mfi' in the line#" > ./$fileName/LSI_Products/MegaRAID/megaraid_messages.txt
		
		
		#Make sure zipped messages don't overwrite unzipped.
		
		for i in s.20 s.19 s.18 s.17 s.16 s.15 s.14 s.13 s.12 s.11 s.10 s.9 s.8 s.7 s.6 s.5 s.4 s.3 s.2 s.1 s.0 s; do
			if [ -f ./$fileName/message$i ]; then 
				if [ -f  ./$fileName/message$i.bz2 ]; then mv ./$fileName/message$i.bz2 ./$fileName/message$i.bz2.dupe_name ; fi
			fi
		done
		
		#Checks for compressed/dated message files.
		
		bzip2 -d ./$fileName/messages-????????.bz2 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		ls ./$fileName/messages-???????? > ./$fileName/script_workspace/messages_dated.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		for i in $( cat ./$fileName/script_workspace/messages_dated.txt );do
			grep "kernel: twa" $i >> ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt
			#grep "MR_MONITOR" $i >> ./$fileName/LSI_Products/MegaRAID/AENs/mrmonitord_messages.txt
			grep "kernel: mfi" $i >> ./$fileName/LSI_Products/MegaRAID/megaraid_driver_messages.txt
			grep "kernel: mpt" $i >> ./$fileName/LSI_Products/HBA/hba_driver_messages.txt
			#egrep "MR_MONITOR|kernel: mfi" $i >> ./$fileName/LSI_Products/MegaRAID/megaraid_messages.txt
			grep "kernel: da" $i >> ./$fileName/OS_Disk_driver_messages.txt
		done
		
		
		for i in s.20 s.19 s.18 s.17 s.16 s.15 s.14 s.13 s.12 s.11 s.10 s.9 s.8 s.7 s.6 s.5 s.4 s.3 s.2 s.1 s.0 s; do
			if [ -f  ./$fileName/message$i.bz2 ]; then bzip2 -d ./$fileName/message$i.bz2 ; fi
		done
		
		
		for i in s.20 s.19 s.18 s.17 s.16 s.15 s.14 s.13 s.12 s.11 s.10 s.9 s.8 s.7 s.6 s.5 s.4 s.3 s.2 s.1 s.0 s; do
			if [ -f ./$fileName/message$i ]; then $grep "kernel: twa" ./$fileName/message$i >> ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt ; fi
			#	if [ -f ./$fileName/message$i ]; then $grep "MR_MONITOR" ./$fileName/message$i >> ./$fileName/LSI_Products/MegaRAID/AENs/mrmonitord_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then $grep "kernel: mfi" ./$fileName/message$i >> ./$fileName/LSI_Products/MegaRAID/megaraid_driver_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then $grep "kernel: mpt" ./$fileName/message$i >> ./$fileName/LSI_Products/HBA/hba_driver_messages.txt ; fi
			#	if [ -f ./$fileName/message$i ]; then egrep "MR_MONITOR|kernel: mfi" ./$fileName/message$i >> ./$fileName/LSI_Products/MegaRAID/megaraid_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then $grep "kernel: da" ./$fileName/message$i >> ./$fileName/OS_Disk_driver_messages.txt ; fi
		done
		
		
		grep " (0x03: 0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x03_9000_ERROR.txt 
		grep " (0x04: 0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x04_9000_EVENT.txt 
		grep " (0x06: 0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x06_9000_DRIVER.txt 
		grep " (0x09: 0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x09_FreeBSD_OS.txt 
		grep " (0x0B: 0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0B_API.txt 
		grep " (0x0C: 0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0C_3DMPLUS.txt 
		grep " (0x0D: 0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0D_CLI.txt 
		grep " (0x0E: 0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0E_7000_ERROR.txt 
		grep " (0x0F: 0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x0F_7000_EVENT.txt 
		grep " (0x11: 0x" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x11_7000_DRIVER.txt  
		
		for i in _x03_9000_ERROR _x04_9000_EVENT _x06_9000_DRIVER _x09_FreeBSD_OS _x0B_API _x0C_3DMPLUS _x0D_CLI _x0E_7000_ERROR _x0F_7000_EVENT _x11_7000_DRIVER; do
			if [ ! -s ./$fileName/LSI_Products/3ware/3ware_driver$i.txt ]; then rm ./$fileName/LSI_Products/3ware/3ware_driver$i.txt ; fi
		done
		
		grep " (0x03: 0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x03_9000_ERROR.txt 
		grep " (0x04: 0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x04_9000_EVENT.txt 
		grep " (0x06: 0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_9000_DRIVER.txt 
		grep " (0x09: 0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x09_FreeBSD_OS.txt 
		grep " (0x0B: 0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0B_API.txt 
		grep " (0x0C: 0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0C_3DMPLUS.txt 
		grep " (0x0D: 0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0D_CLI.txt 
		grep " (0x0E: 0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0E_7000_ERROR.txt 
		grep " (0x0F: 0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x0F_7000_EVENT.txt 
		grep " (0x11: 0x" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x11_7000_DRIVER.txt  
		
		for i in _x03_9000_ERROR _x04_9000_EVENT _x06_9000_DRIVER _x09_FreeBSD_OS _x0B_API _x0C_3DMPLUS _x0D_CLI _x0E_7000_ERROR _x0F_7000_EVENT _x11_7000_DRIVER; do
		if [ ! -s ./$fileName/LSI_Products/3ware/OS_Disk_driver$i.txt ]; then rm ./$fileName/LSI_Products/3ware/OS_Disk_driver$i.txt ; fi
		done
		
		
# Final fi
	fi
#
# End FreeBSD Only Section
#

###########################################################################################################################
#Start MacOS Only Section
###########################################################################################################################


	if [ "$OS_LSI" = "macos" ]; then 
	
	
		system_profiler -detaillevel full > ./$fileName/system_profile.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		grep "System Version" ./$fileName/system_profile.txt > ./$fileName/Mac_OS_X_Version.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		grep "Kernel Version" ./$fileName/system_profile.txt >> ./$fileName/Mac_OS_X_Version.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		
		
		kextstat > ./$fileName/kextstat.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		kextstat | $grep amcc > ./$fileName/LSI_Products/3ware/kextstat_amcc.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		kextstat | $grep 3ware > ./$fileName/LSI_Products/3ware/kextstat_3ware.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		

		
		#Add new logs as needed
		
		
		echo "#All lines from all system.log files (system.log, system.log.0-20(.gz)) with 'AMCC3ware9000' OR 'LSI3ware9000' in the line#" > ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt
		echo "#All lines from all system.log files (system.log, system.log.0-20(.gz)) with 'diskarbitrationd' in the line#" > ./$fileName/OS_Disk_driver_messages.txt
		
		
		#Make sure zipped messages don't overwrite unzipped.
		
		for i in g.20 g.19 g.18 g.17 g.16 g.15 g.14 g.13 g.12 g.11 g.10 g.9 g.8 g.7 g.6 g.5 g.4 g.3 g.2 g.1 g.0 g; do
			if [ -f ./$fileName/system.lo$i ]; then 
				if [ -f  ./$fileName/system.lo$i.gz ]; then mv ./$fileName/system.lo$i.gz ./$fileName/system.lo$i.gz.dupe_name ; fi
			fi
		done
	
		for i in g.20 g.19 g.18 g.17 g.16 g.15 g.14 g.13 g.12 g.11 g.10 g.9 g.8 g.7 g.6 g.5 g.4 g.3 g.2 g.1 g.0 g; do
			if [ -f  ./$fileName/system.lo$i.gz ]; then gunzip ./$fileName/system.lo$i.gz ; fi
		done
	
	
		for i in g.20 g.19 g.18 g.17 g.16 g.15 g.14 g.13 g.12 g.11 g.10 g.9 g.8 g.7 g.6 g.5 g.4 g.3 g.2 g.1 g.0 g; do
			if [ -f ./$fileName/system.lo$i ]; then $grep "AMCC3ware9000" ./$fileName/system.lo$i >> ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt ; 	fi
			if [ -f ./$fileName/system.lo$i ]; then $grep "diskarbitrationd" ./$fileName/system.lo$i >> ./$fileName/OS_Disk_driver_messages.txt ; fi
		done
	
		egrep "AMCC3ware9000 AEN|LSI3ware9000 AEN" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x04_9000_EVENT.txt 
		
		for i in _x04_9000_EVENT; do
			if [ ! -s ./$fileName/LSI_Products/3ware/3ware_driver$i.txt ]; then rm ./$fileName/LSI_Products/3ware/3ware_driver$i.txt > /dev/null 2>&1 ; fi
		done
		
		grep "diskarbitrationd" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x04_9000_EVENT.txt 
		
		for i in _x04_9000_EVENT; do
			if [ ! -s ./$fileName/LSI_Products/3ware/OS_Disk_driver$i.txt ]; then rm ./$fileName/LSI_Products/3ware/OS_Disk_driver$i.txt > /dev/null 2>&1 ; fi
		done
		
		
		
# Final fi
	fi
#
# End MacOS Only Section
#

###########################################################################################################################
#Start Solaris Only Section
###########################################################################################################################

	if [ "$OS_LSI" = "solaris" ]; then 
	
		uptime > ./$fileName/uptime.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		df -ha > ./$fileName/df-ha.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		who > ./$fileName/who.txt  2>>./$fileName/script_workspace/lsiget_errorlog.txt
		top -b -n 1 > ./$fileName/top-b-n1.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		ps -ef > ./$fileName/ps-ef.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		
		
		#
		# All 3ware Performance Tuning parameters should be gathered here!
		#
		# echo "Collecting 3ware SD Device Performance Tuning Data..."
		
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with ': tw' in the line#" > ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with ': mega_sas' in the line#" > ./$fileName/LSI_Products/MegaRAID/megaraid_driver_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with '] sd' in the line#" > ./$fileName/OS_Disk_driver_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with 'MR_MONITOR' in the line#" > ./$fileName/LSI_Products/MegaRAID/AENs/mrmonitord_messages.txt
		
		echo "#All lines from all message files (messages, messages.0-20(.gz), messages-????????(.gz) with 'MR_MONITOR' OR ': mega_sas' in the line#" > ./$fileName/LSI_Products/MegaRAID/megaraid_messages.txt
		
		
		
		
		#Make sure zipped messages don't overwrite unzipped.
		
		for i in s.20 s.19 s.18 s.17 s.16 s.15 s.14 s.13 s.12 s.11 s.10 s.9 s.8 s.7 s.6 s.5 s.4 s.3 s.2 s.1 s.0 s; do
			if [ -f ./$fileName/message$i ]; then 
				if [ -f  ./$fileName/message$i.gz ]; then mv ./$fileName/message$i.gz ./$fileName/message$i.gz.dupe_name ; fi
			fi
		done
	
#Checks for compressed/dated message files.
	
		gunzip ./$fileName/messages-????????.gz 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		ls ./$fileName/messages-???????? > ./$fileName/script_workspace/messages_dated.txt 2>>./$fileName/script_workspace/lsiget_errorlog.txt
		for i in $( cat ./$fileName/script_workspace/messages_dated.txt );do
		grep ": tw" $i >> ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt
		grep ": mega_sas" $i >> ./$fileName/LSI_Products/MegaRAID/megaraid_driver_messages.txt
		grep "MR_MONITOR" $i >> ./$fileName/LSI_Products/MegaRAID/AENs/mrmonitord_messages.txt
		egrep "MR_MONITOR|: mega_sas" $i >> ./$fileName/LSI_Products/MegaRAID/megaraid_messages.txt
		grep "] sd" $i >> ./$fileName/OS_Disk_driver_messages.txt
		done
		
		
		for i in s.20 s.19 s.18 s.17 s.16 s.15 s.14 s.13 s.12 s.11 s.10 s.9 s.8 s.7 s.6 s.5 s.4 s.3 s.2 s.1 s.0 s; do
			if [ -f  ./$fileName/message$i.gz ]; then gunzip ./$fileName/message$i.gz ; fi
		done
		
		
		for i in s.20 s.19 s.18 s.17 s.16 s.15 s.14 s.13 s.12 s.11 s.10 s.9 s.8 s.7 s.6 s.5 s.4 s.3 s.2 s.1 s.0 s; do
			if [ -f ./$fileName/message$i ]; then $grep ": tw" ./$fileName/message$i >> ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then $grep ": mega_sas" ./$fileName/message$i >> ./$fileName/LSI_Products/MegaRAID/megaraid_driver_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then $grep "MR_MONITOR" ./$fileName/message$i >> ./$fileName/LSI_Products/MegaRAID/AENs/mrmonitord_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then $grep "MR_MONITOR|: mega_sas" ./$fileName/message$i >> ./$fileName/LSI_Products/MegaRAID/megaraid_messages.txt ; fi
			if [ -f ./$fileName/message$i ]; then $grep "] sd" ./$fileName/message$i >> ./$fileName/OS_Disk_driver_messages.txt ; fi
		done
		
		
		grep "tw_aen_task AEN" ./$fileName/LSI_Products/3ware/3ware_driver_messages.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x04_9000_EVENT.txt 
		
		
		for i in _x04_9000_EVENT; do
			if [ ! -s ./$fileName/LSI_Products/3ware/3ware_driver$i.txt ]; then rm ./$fileName/LSI_Products/3ware/3ware_driver$i.txt > /dev/null 2>&1 ; fi
		done
		
		grep "] sd" ./$fileName/OS_Disk_driver_messages.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x04_9000_EVENT.txt 
		
		
		for i in _x04_9000_EVENT; do
			if [ ! -s ./$fileName/LSI_Products/3ware/OS_Disk_driver$i.txt ]; then rm ./$fileName/LSI_Products/3ware/OS_Disk_driver$i.txt > /dev/null 2>&1 ; fi
		done
		
		
				
		
# Final fi
	fi
#
# End Solaris Only Section
#

###########################################################################################################################
###########################################################################################################################
#Start Generic Section
###########################################################################################################################
###########################################################################################################################





########################################################################################################################### 
###Update on Code Set Change
# Based on errorcode.h 5.12.00.016FW 10.2.2.1 codeset 
# Errors = 0x03 
# Legacy error_codes, these are reserved on Apache 
########################################################################################################################### 


	x0000="no_error_status_dependent_code_for_this_error_status" 
	x0001="no_request_ID_available_for_this_error_status" 
	x0002="CP_queue_became_full" 
	x0003="illegal_SGL_offset_in_CP_Header" 
	x0004="illegal_number_of_SGL_entries_in_CPH" 
	x0005="could_not_allocate_additional_memory" 
	x0006="some_PCI_read_error_occurred" 
	x0007="timeout_during_PCI_transaction" 
	x0008="PCI_ERR_bit_for_a_PCI_transaction" 
	x0009="unrecoverable_disk_error" 
	x000A="completion_token_queue_overflow" 
	x000B="error_reading_SGL" 
	x000C="error_reading_CP_Header" 
	x000D="abort_req_for_cmd_that_wasn't_active" 
	x000E="illegal_size_in_CP_Header" 
	x000F="got_a_CPH_with_an_already_active_req_ID" 
	x0010="lengths_in_SGLs_not_match_block_count_in_CP" 
	x0011="requested_LBA_greater_than_maximum_LBA_of_the_unit" 
	x0012="host_address_or_SGL_size_not_on_8_dw_boundary" 
	x0013="data_integrity_error_on_read_or_write_test" 
	x0014="subcmd_num_in_CP_hdr_is_undef_for_this_cmd" 
	x0015="undefined_table_requested" 
	x0016="param_requested_is_out_of_bounds_of_table" 
	x0017="given_param_size_doesnt_match_param_size_in_table" 
	x0018="host_address_or_SGL_size_not_on_a_sector_boundary" 
	x0019="Achip_Unit__number_exceeds_maximum" 
	x001A="bad_pairing_of_disk-op_or_xer-op_from_Aop_queue" 
	x001B="Aport_timed_out_doing_an_Aop" 
	x001C="an_Achip_GSR_interrupt_occurred" 
	x001D="Aop_encountered_with_unknown_cmd_byte" 
	x001E="PCI_was_busy_when_tried_to_do_a_PCI_read_or_write" 
	x001F="next_Aop_should_have_been_a_disk-op_but_it_wasnt" 
	x0020="param_0_unsupported_for_now_for_get_or_set_param" 
	x0021="an_unimplemented_method_was_invoked" 
	x0022="request_ID_took_too_long_to_complete" 
	x0023="a_disk_task_file_error_occurred_during_a_1F_test" 
	x0024="data_lines_shorted_in_Sbuf_RAM" 
	x0025="data_lines_open_in_Sbuf_RAM" 
	x0026="addr_line_problem_in_Sbuf_RAM" 
	x0027="Sbuf_RAM_unreadable" 
	x0028="command_requires_at_least_1_SGL" 
	x0029="no_unit_num_is_available_for_use" 
	x002A="CP_queue_was_empty_when_tried_to_get_a_CP_ptr_from_it" 
	x002B="test_firmware_not_downloaded_to_RAM" 
	x002C="an_attempt_was_made_to_nest_internal_requests" 
	x002D="error_in_downloading_hex_file" 
	x002E="error_in_programming_the_flash_ROM" 
	x002F="error_in_rollcall" 
	x0030="error_in_wait_disks_rdy" 
	x0031="error_in_UIT_formatting" 
	x0032="incorrect_unit_type_for_the_request" 
	x0033="unit_does_not_have_the_logical_sub-unit_specified" 
	x0034="unit_has_corrupted_data_on_it" 
	x0035="could_not_write_DCB_to_disk" 
	x0036="could_not_get_profiler_from_disk" 
	x0037="unit_is_not_exportable" 
	x0038="unit_is_missing_a_sub-unit" 
	x0039="unit_is_not_operating_normally" 
	x003A="not_enough_SBUF_segments_to_service_the_request" 
	x003B="User_area_in_unit_was_not_written_with_zeroes" 
	x003C="user_data_on_unit_did_not_verify" 
	x003D="error_while_writing_0s_to_user_data" 
	x003E="a_unit_does_not_contain_a_logical_mapping_for_a_phys_drive" 
	x003F="drive_replacement_would_cause_a_double-degrade" 
	x0040="capacity_of_replacement_drive_is_too_small" 
	x0041="no_drive_detected" 
	x0042="drive_detected_to_be_busy" 
	x0043="aport_unavailable" 
	x0044="unable_to_clear_sbuf" 
	x0045="can_not_replace_drive_because_unit_not_degraded" 
	x0046="we_have_no_routine_to_program_this_mfr_or_type_of_flash" 
	x0047="cant_fill_Sbuf_with_zeros" 
	x0048="byte_count_in_PARAM_field_is_too_big_for_this_cmd" 
	x0049="timeout_while_waiting_for_data_from_display_panel" 
	x004A="CRC_error_reported_on_BFB_transfer" 
	x0051="for_drive_errors_the_status_register_gets_stuffed_into_LSB_of_ESDC" 
	x0060="reserved_-_this_is_a_valid_drive_status_error_code" 
	x0061="reserved_-_this_is_a_valid_drive_status_error_code" 
	
	x0100="SGL_entry_contains_zero_data" 
	x0101="Invalid_command_opcode" 
	x0102="SGL_entry_has_unaligned_address" 
	x0103="SGL_size_does_not_match_command" 
	x0104="SGL_entry_has_illegal_length" 
	x0105="Command_packet_is_not_aligned" 
	x0106="Invalid_request_ID" 
	x0107="Duplicate_request_ID" 
	x0108="ID_not_locked" 
	x0109="LBA_out_of_range" 
	x010A="Logical_unit_not_present" 
	x010B="Parameter_table_does_not_exist" 
	x010C="Parameter_index_does_not_exist" 
	x010D="Invalid_field_in_CDB" 
	x010E="Invalid_operation_for_specified_port" 
	x010F="Parameter_item_size_mismatch" 
	
	x0110="Failed_memory_allocation" 
	x0111="Memory_request_too_large" 
	x0112="Out_of_memory_segments" 
	x0113="Invalid_address_to_deallocate" 
	x0114="Out_of_memory" 
	x0115="Out_of_heap" 
	x0116="Invalid_BIOS_buffer_id" 
	
	x0117="Host_lock_not_available" 
	
	x011E="Unrecovered_Read_Error"
	x011F="Recovered_Data_with_error_correction_applied"
	
	x0120="Double_degrade" 
	x0121="Drive_not_degraded" 
	x0122="Reconstruct_error" 
	x0123="Replace_not_accepted" 
	x0124="Drive_capacity_too_small" 
	x0125="Sector_count_not_allowed" 
	x0126="No_spares_left" 
	x0127="Reconstruct_error" 
	x0128="Unit_offline" 
	x0129="Cannot_update_status_to_DCB" 
	x012A="Invalid_configuration_for_split" 
	x012B="Invalid_configuration_for_join" 
	x012C="No_migration_recovery" 
	x012D="No_SATA_spares" 
	x012E="No_SAS_spares"  
	x012F="Mixed_SAS_SATA_not_allowed_in_same_unit" 
	
	x0130="Invalid_stripe_handle" 
	x0131="Handle_that_was_not_locked" 
	x0132="Handle_that_was_not_empty" 
	x0133="Handle_has_different_owner" 
	
	x0140="IPR_has_parent" 
	
	x0150="Illegal_Pbuf_address_alignment" 
	x0151="Illegal_Pbuf_transfer_length" 
	x0152="Illegal_Sbuf_address_alignment" 
	x0153="Illegal_Sbuf_transfer_length" 
	
	x0160="Command_packet_too_large" 
	x0161="SGL_exceeds_maximum_length" 
	x0162="SGL_has_too_many_entries" 
	
	x0170="Insufficient_resources_for_rebuilder" 
	x0171="Verify_error_data_doesnt_equal_parity" 
	
	x0180="Requested_segment_not_in_directory_of_this_DCB" 
	x0181="DCB_segment_has_unsupported_version" 
	x0182="DCB_segment_has_checksum_error" 
	x0183="DCB_support_settings_segment_invalid" 
	x0184="DCB_UDB_unit_descriptor_block_segment_invalid" 
	x0185="DCB_GUID_globally_unique_identifier_segment_invalid" 
	
	x01A0="Could_not_clear_Sbuf" 
	
	x01C0="Flash_device_unsupported" 
	x01C1="Flash_out_of_bounds" 
	x01C2="Flash_write_verify_failed" 
	x01C3="Flash_file_object_not_found" 
	x01C4="Flash_file_already_present" 
	x01C5="Flash_file_system_full" 
	x01C6="Flash_file_not_present" 
	x01C7="Flash_file_size_mismatch" 
	x01C8="Flash_file_checksum_error" 
	x01C9="Flash_file_version_unsupported" 
	x01CA="Flash_file_system_error_detected" 
	x01CB="Flash_file_component_directory_not_found" 
	x01CC="Flash_file_component_not_found" 
	x01CD="Flash_write_cycle_failed" 
	x01CE="Flash_erase_cycle_failed" 
	
	x01D0="Invalid_field_in_parameter_list" 
	x01D1="Parameter_list_length_error" 
	x01D2="Parameter_not_changeable" 
	x01D3="Parameter_not_saveable" 
	x01D4="Invalid_mode_page" 
	
	x0200="Drive_CRC_error" 
	x0201="Internal_bus_CRC_error" 
	x0202="Drive_ECC_Medium_error" 
	x0203="Drive_TFR_readback_error" 
	x0204="Drive_timeout" 
	x0205="Drive_power_on_reset" 
	x0206="ADP_level_2_error" 
	x0207="Drive_soft_reset_failed" 
	x0208="Drive_not_ready" 
	x0209="Unclassified_drive_error" 
	x020A="Drive_aborted_command" 
	x020B="Port_link_error_detected" 
	x020C="Port_internal_error_detected" 
	x020D="Drive_not_ready_require_Spinup" 
	x020E="Uninitialized_drive_handle" 
	
	x0210="Internal_bus_CRC_error" 
	x0211="PCI_bus_abort_error" 
	x0212="PCI_bus_parity_error" 
	x0213="Port_handler_error" 
	x0214="Token_interrupt_count_error" 
	x0215="PCI_bus_timeout" 
	x0216="Buffer_ECC_error_corrected" 
	x0217="Buffer_ECC_error_not_corrected" 
	x0218="Xop_pool_parity_error" 
	
	x0230="Unsupported_command_during_flash_recovery" 
	x0231="Next_image_buffer_expected" 
	x0232="Binary_image_architecture_ID_incompatible" 
	x0233="Binary_image_no_signature_detected" 
	x0234="Binary_image_checksum_error_detected" 
	x0235="Binary_image_buffer_overflow_detected" 
	x0236="Binary_image_SRL_incompatible" 
	
	x0240="I2C_device_not_detected" 
	x0241="I2C_transaction_aborted" 
	x0242="SO-DIMM_parameters_incompatible_using_defaults" 
	x0243="SO-DIMM_unsupported" 
	x0244="I2C_clock_is_held_low_transfer_aborted" 
	x0245="I2C_data_is_held_low_transfer_aborted" 
	x0246="I2C_slave_device_NACKed_the_transfer"
	x0247="I2C_buffer_in-sufficient" 
	x0248="SPI_transfer_status_error" 
	x024A="I2C_interface_is_active" 
	x024B="Lost_arbitration" 
	x024C="I2C_transfer_error" 
	
	x0250="Unit_descriptor_size_invalid" 
	x0251="Unit_descriptor_size_exceeds_data_buffer" 
	x0252="Invalid_value_in_unit_descriptor" 
	x0253="Inadequate_disk_space_to_support_descriptor" 
	x0254="Unable_to_create_data_channel_for_this_unit_descriptor" 
	x0255="Unit_descriptor_specifies_a_drive_already_in_use" 
	x0256="Unable_to_write_configuration_to_all_disks" 
	x0257="Unit_descriptor_version_not_supported" 
	x0258="Invalid_subunit_for_RAID_0_or_5" 
	x0259="Too_many_unit_descriptors" 
	x025A="Invalid_configuration_in_unit_descriptor" 
	x025B="Invalid_LBA_offset_in_unit_descriptor" 
	x025C="Invalid_stripelet_size_in_unit_descriptor" 
	x025D="JBOD_unit_is_not_allowed" 
	x025E="Operation_not_allowed_retained_cache_data" 
	x025F="Exceeded_maximum_number_of_active_drives" 
	x0260="SMART_threshold_exceeded" 
	x0261="Maximum_number_of_units_reached" 
	
	
	x0270="Unit_not_in_NORMAL_state" 
	x0271="Invalid_drive_members" 
	x0272="Converted_unit_not_supported" 
	
	x0280="ResponseIU_status_code_EC_STATUS_BUSY" 
	x0281="ResponseIU_status_code_EC_STATUS_QUEUE_FULL" 
	x0282="ResponseIU_status_code_EC_STATUS_UNEXPECTED" 
	x0283="IO_Hold_Error"
	
	x0290="No_Sense_Info_EC_SK_NO_SENSE_INFO"  
	x0291="Recovered_Error_EC_SK_RECOVERED_ERROR"  
	x0293="Hardware_Error_EC_SK_HARDWARE_ERROR"  
	x0294="Hardware_ECC_Error_EC_SK_HARDWARE_ECC"  
	x0295="Illegal_Req_EC_SK_ILLEGAL_REQ"  
	x0296="Unit_Attention_EC_SK_UNIT_ATTENTION"  
	x0297="Unit_Attention_Reset_EC_SK_UNIT_ATTENTION" 
	# note: The error code below is reused - Commented Out 
	#x0205="ResponseIU_status_codeEC_SK_UNIT_REset" 
	x0298="Aborted_Cmd_EC_SK_ABORTED_CMD"  
	x0299="Sense_Keys_Unexpected_EC_SK_UNEXPECTED"  
	x029A="Unit_Attention_Mode_Page_Changed_EC_SK_UNIT_ATTENTION" 
	x029B="Current_command_Write_Fault"
	x029C="Deferred_Drive_Write_Fault"
	
	x029D="Lba_Out_Of_Range"
	
	x02A0="SAS_error_code_EC_PAYLOAD_PARITY" 
	x02A1="SAS_error_code_EC_UNDER_RUN_IN_RW" 
	x02A2="SAS_error_code_EC_UNDER_RUN_OUT" 
	x02A3="SAS_error_code_EC_OVER_RUN" 
	x02A4="SAS_error_code_EC_OPEN_REJECT_BUSY"  
	x02A5="SAS_error_code_EC_OPEN_REJECT_RETRY"   
	x02A6="SAS_error_code_EC_OPEN_REJECT_ABANDON"   
	x02A7="SAS_error_code_EC_OPEN_REJECT_STP_RES_BUSY"   
	x02A8="SAS_error_code_EC_RX_FRAME_ERROR"   
	x02A9="SAS_error_code_EC_RX_TRANSPORT_ERROR" 
	x02AA="SAS_error_code_EC_PORT_OFFLINE"   
	x02AB="SAS_Response_data_present"   
	
	x02B0="Tx_failure_-_SATA_SYNC_received" 
	x02B1="Tx_failure_-_BREAK_received" 
	x02B2="Protocol_overrun" 
	x02B3="Protocol_underrun" 
	x02B4="Open_failure_-_Connection_rejected" 
	x02B5="Open_failure_-_Bad_destination" 
	x02B6="Open_failure_-_Wrong_destination" 
	x02B7="Open_failure_-_Connection_rate_not_supported" 
	x02B8="Open_failure_-_Protocol_not_supported" 
	x02B9="Open_failure_-_STP_Resources_busy" 
	x02BA="Open_failure_-_No_destination" 
	x02BB="Open_failure_-_Pathway_blocked" 
	x02BC="Open_failure_-_Retry" 
	x02BD="Open_failure_-_Open_frame_timeout" 
	x02BE="STP_Inactivity" 
	x02BF="Failed_to_discover_Emulex_chip" 
	x02C0="Emulex_flash_file_is_corrupted" 
	x02C1="Error_while_flashing_Emulex" 
	x02C2="Target_returned_valid_sense_data_during_a_SCSI_PASSTHROUGH" 
	x02C3="Failed_to_unlock_flash_block_while_flashing_Emulex_ROM" 
	x02C4="Failed_to_erase_flash_block_while_flashing_Emulex_ROM" 
	x02C5="Failed_to_write_flash_block_while_flashing_Emulex_ROM" 
	x02C6="Failed_to_lock_flash_block_while_flashing_Emulex_ROM" 
	x02C7="ROM_size_is_not_a_multiple_of_128k" 
	x02C8="Emulex_SLI_command_timeout" 
	x02C9="Emulex_mailbox_status_error" 
	x02CA="Emulex_mailbox_format_error" 
	x02CB="Emulex_no_resources" 
	x02CC="Emulex_protocol_check_error" 
	x02CD="Emulex_protocol_fis_error" 
	x02CE="IOC_firmware_update_error" 
	
	x02D0="Discovery_module_resource_error" 
	x02D1="Delete_the_port_in_discovery_Manager" 
	x02D2="Discovery_module_bad_pointer_error" 
	x02D3="Discovery_module_unknown_SMP_function" 
	x02D4="Target_Unregistration_with_IOC_failed" 
	
	x02E0="SAS_Error_PAYLOAD_PARITY" 
	x02E1="SAS_Error_UNDER_RUN_IN_RW" 
	x02E4="SAS_Error_OPEN_REJECT_BUSY" 
	x02E5="SAS_Error_OPEN_REJECT_RETRY" 
	x02E6="SAS_Error_OPEN_REJECT_ABANDON" 
	x02E7="SAS_Error_OPEN_REJECT_STP_RES_BUSY" 
	x02E8="SAS_Error_RX_FRAME_ERROR" 
	x02EA="SAS_Error_PORT_OFFLINE" 
	
	x02EB="Suspend_IO_during_PL_TMF" 
	
	x02F0="Tx_failure_-_SATA_R_ERR_received" 
	x02F1="Tx_failure_-_SATA_DMAT_received" 
	x02F2="Non_specific_NCQ_error" 
	x02F3="Task_File_error" 
	x02F4="SATA_Register_Set_error" 
	
	x0300="Internal_errorcode_BBU_base_-_should_not_occur" 
	x0301="Invalid_BBU_state_change_request"  
	x0302="The_BBU_resource_needed_is_in_use_retry_command_after_a_delay"  
	x0303="Command_requires_a_battery_pack_to_be_present_and_enabled" 
	
	x0310="BBU_command_packet_error" 
	x0311="BBU_command_not_implemented" 
	x0312="BBU_command_buffer_underflow" 
	x0313="BBU_command_buffer_overflow" 
	x0314="BBU_command_incomplete" 
	x0315="BBU_command_checksum_error" 
	x0316="BBU_command_timeout" 
	
	x0317="BBU_flash_operation_failed" 
	x0318="BBU_flash_Vpp_voltage_out_of_progamming_range" 
	x0319="BBU_flash_incorrect_command_or_parameter_or_not_enough_space_in_stack" 
	x031A="BBU_flash_not_yet_completed" 
	x031B="BBU_flash_write_skip" 
	x031C="BBU_flash_invalid_erase_sector" 
	
	x0320="BBU_parameter_not_defined" 
	x0321="BBU_parameter_size_mismatch" 
	x0322="Cannot_write_a_read-only_BBU_parameter" 
	x0323="Invalid_state_bits_in_BBU_SetportPins_command" 
	
	x0330="FBU_nif_error"
	x0331="FBU_ERASE_BLOCK_ERROR"
	x0332="FBU_Program_error"
	x0333="FBU_ecc_uncorrectable"
	x0334="FBU_ecc_correctable"
	x0335="FBU_Program_error"
	x0336="FBU_Erase_error"
	x0337="FBU_No_defect_guard"
	x0338="FBU_Read_Error"
	x0339="FBU_Read_Error"
	
	x0350="Uncorrectable_ECC_Error"
	x0351="Correctable_ECC_Error"
	x0352="Access_out_of_memory_range"
	x0353="Dram_Controller_Fatal_Error"
	x0354="Dram_ECC_error_log_full"
	
	x0340="Invalid_discharge-learn_cycle_in_Battery_test" 
	x0341="Battery_test_failed"
	
	x0380="BBU_firmware_version_string_not_found" 
	x0381="BBU_operating_state_not_available" 
	x0382="BBU_not_present" 
	x0383="BBU_not_ready" 
	x0384="BBU_S1_not_compatible_with_HBA" 
	x0385="BBU_S0_not_compatible_with_HBA" 
	x0386="BBU_not_compatible_with_HBA" 
	x0387="BBU_not_in_S0" 
	x0388="BBU_not_in_S1" 
	x0389="Timeout_on_BBU_power_fail_interrupt" 
	x038A="BBU_invalid_response_length" 
	x038B="Not_S1_ident_or_event_packet" 
	x038C="HBA_has_backup_data" 
	x038D="Invalid_BBU_state" 
	x038E="BBU_invalid_response_code" 
	
	x0390="Log_updates_not_allowed" 
	x0391="Logs_are_invalid" 
	x0392="Logs_not_found" 
	
	x0400="Invalid_enclosure_port_defined" 
	x0401="Enclosure_resource_reserved" 
	x0402="Enclosure_parameter_not_defined" 
	x0403="Enclosure_parameter_re-defined" 
	x0404="Enclosure_port_is_input_port" 
	x0405="Invalid_SAFTE_page_requested" 
	x0406="Invalid_SES_page_requested" 
	x0407="EPCT_device_description_error" 
	x0408="EPCT_device_redefined" 
	x0409="EPCT_element_unknown" 
	x040A="EPCT_device_unknown" 
	x040B="EPCT_ID_unknown" 
	x040C="Invalid_enclosure_device" 
	x040D="EPCT_LED_descriptor_redefinition" 
	x040F="Enclosure_device_not_initialized" 
	x0410="Temperature_sensor_reading_unknown" 
	x0411="Enclosure_not_present" 
	x0412="Bad_EPCT_version" 
	x0413="Failed_to_create_SEP_object" 
	x0414="Too_many_enclosures_cannot_add_more" 
	x0415="Failed_to_create_enclosure_object" 
	x0416="Invalid_Sep_Command" 
	
	x1000="EC_NEED_CMD_PROCESS" 
	x1001="EC_UDMA_UPGRADE_SKIPPED" 
	x1002="EC_DRIVE_NOT_IN_UDMA" 
	x1003="EC_OFFLINE_TIMER_RUNNING" 
	x1004="EC_BIN_HANDLE_NOT_EMPTY" 
	x1005="EC_BIN_HANDLE_WRONG_OWNER" 
	x1006="EC_CMD_IN_PBUF" 
	x1007="EC_INVALID_DATA_CHKSUM" 
	x1008="EC_LBA_OVERLAP" 
	x1009="EC_SGL_NON_SECTOR_SIZE" 
	x100A="Retry_CMD"
	
	x100B="BT1680_Liberator_Error"
	x100C="BT1680_Liberator_Fail"
	
	x1010="Error_recovery_in_progress" 
	x1011="Error_recovery_complete" 
	x1012="No_LBA_to_repair_sector" 
	x1013="Retry_recovery_step" 
	x1014="Do_error_action" 
	x1015="Degrade_unit" 
	x1016="Sector_repair_was_not_completed" 
	x1017="Command_aborted" 
	x1018="Drive_added" 
	
	x1019="Drive_removed" 
	x101A="Retry_queued_command" 
	x101B="Drive_error" 
	x101C="Non-Dma_Retry_no_recovery" 
	x101D="Drive_removed_no_wait" 
	x1020="Simulate_power_fail" 
	x1021="Simulate_uC_error" 
	
	x1022="Need_to_transition_to_Drive_remove_error" 
	x1023="Simulate_exception_error" 
	x1024="Simulate_illegal_instruction_error" 
	
	x2000="Checksum_of_cache_meta_data_is_bad" 
	x2001="Signature_of_cache_meta_data_is_bad" 
	x2002="Cache_meta_data_is_bad_due_to_bad_parity_link" 
	
	x2100="SATA_NCQ_Error_to_trigger_error_handler" 
	x2101="SAS_Error_to_trigger_error_handler" 
	x2102="Drive_must_be_reset_either_locally_or_via_SMP"
	
	x2FFF="EC_FEATURE_NOT_IMPLEMENTED" 
	
	x3013="Data_integrity_error_in_diagnostic_test" 
	x3014="Undefined_Sub-command_for_diag_test" 
	x3017="Drive_reset_error_thru_Marvell" 
	x3018="Reading_config_space_error" 
	x3019="Read_or_write_memory_space_data_integrity_error" 
	x301A="Pchip_UCbuf_data_integrity_error" 
	x301B="Pchip_Xop_Pool_data_integrity_error" 
	x301C="Pchip_Cmd_Ram_data_integrity_error" 
	x301E="iHandler_was_busy_before_diag_test" 
	x3021="An_unimplemented_method_was_invoked" 
	x3024="Data_lines_shorted_in_Sbuf_RAM" 
	x3025="Data_lines_open_in_Sbuf_RAM" 
	x3026="Addr_line_problem_in_Sbuf_RAM" 
	x3027="Sbuf_RAM_unreadable" 
	x3047="Cant_fill_Sbuf_with_zeros" 
	x3062="iHandler_error_during_xfer_op" 
	x3063="Bad_disk_sequencer_cmd_issued_to_Aport" 
	x3064="Bad_RAM_location" 
	x3065="Bad_Shadowed_RAM_location" 
	x3066="Cant_determine_Sbuf_size" 
	x3067="Pbuf_read_or_write_error" 
	x3068="XOR_error" 
	x3069="No_disk_found_on_requested_Aport" 
	x306A="Interrupt_line_error" 
	x306B="Unable_to_calculate_checksum" 
	x306C="BBU_S0_or_S1_firmware_boundary_error" 
	x306D="Old_method_selected_wrong_value_EC_DQS_FIFO_set_WRONG" 
	x3070="NvRam_read_or_write_test_error" 
	x3071="SpdRom_read_test_error" 
	x3072="Hareware_strap_error" 
	x3073="Clock_Generator_data_integrity_error" 
	
	x3074="Inject_SBUF_ECC_incorrect_param"
	
	x3100="Error_manufacturing_diagnostic_test_failed" 
	x3101="XScale_Core_Processor_Subtest"
	x3102="SRAM_Subtest"
	x3103="TPMI_Subtest"
	x3104="Component_Internal_RAM_Subtest"
	x3105="ASIC_Register_Subtest"
	x3106="PCIX-E_Loopback_Subtest"
	x3107="4.0G_FC_or_3.0G_SAS_Link_Internal_Analog_Loopback_Subtest" 
	x3108="1.0G_FC_or_1.5G_SAS_Link_External_Loopback_Subtest" 
	x3109="2.0G_FC_or_1.5G_SAS_Link_External_Loopback_Subtest" 
	x310A="4.0G_FC_or_3.0G_SAS_Link_External_Loopback_Subtest" 
	x310B="TDMA_Subtest"
	x310C="Concurrent_DMA_Subtest"
	x310D="SDRAM_Subtest"
	
	x310E="Error_manufacturing_diagnostic_test-Coordinated_Reset_failed" 
	x310F="Error_manufacturing_diagnostic_test-Preemptive_Reset_failed" 
	x3110="Error_manufacturing_diagnostic_test-Invalid_Request_failed"
	
	x3111="Hareware_strap_error"
	
	x3112="Dma_completed_Miscompare_error"
	x3113="Dma_completed_error"
	
	x3200="No_RAID_key-s_found"
	x3201="RAID_key_bus_in_use"
	x3202="RAID_key_CRC_error"
	x3203="RAID_key_authentication_failure"
	x3204="RAID_key_contains_data_that_did_not_pass_validation" 
	x3205="Address_requested_is_not_valid_or_page_aligned"
	
	x3300="Invalid_board_id"
	
	x7E00="Error_manufacturing_diagnostic_test_failed" 
	x7E01="XScale_Core_Processor_Subtest"
	x7E02="SRAM_Subtest"
	x7E03="TPMI_Subtest"
	x7E04="Component_Internal_RAM_Subtest"
	x7E05="ASIC_Register_Subtest"
	x7E06="PCIX-E_Loopback_Subtest"
	x7E07="4.0G_FC_or_3.0G_SAS_Link_Internal_Analog_Loopback_Subtest" 
	x7E08="1.0G_FC_or_1.5G_SAS_Link_External_Loopback_Subtest" 
	x7E09="2.0G_FC_or_1.5G_SAS_Link_External_Loopback_Subtest" 
	x7E0A="4.0G_FC_or_3.0G_SAS_Link_External_Loopback_Subtest" 
	x7E0B="TDMA_Subtest"
	x7E0C="Concurrent_DMA_Subtest"
	x7E0D="SDRAM_Subtest"
	x7E0E="Error_manufacturing_diagnostic_test-Coordinated_Reset_failed" 
	x7E0F="Error_manufacturing_diagnostic_test-Preemptive_Reset_failed" 
	x7E10="Error_manufacturing_diagnostic_test-Invalid_Request_failed" 
	x7E11="EDMA_error"
	
	for i in "x0000 $x0000" "x0001 $x0001" "x0002 $x0002" "x0003 $x0003" "x0004 $x0004" "x0005 $x0005" "x0006 $x0006" "x0007 $x0007" "x0008 $x0008" "x0009 $x0009" "x000A $x000A" "x000B $x000B" "x000C $x000C" "x000D $x000D" "x000E $x000E" "x000F $x000F" "x0010 $x0010" "x0011 $x0011" "x0012 $x0012" "x0013 $x0013" "x0014 $x0014" "x0015 $x0015" "x0016 $x0016" "x0017 $x0017" "x0018 $x0018" "x0019 $x0019" "x001A $x001A" "x001B $x001B" "x001C $x001C" "x001D $x001D" "x001E $x001E" "x001F $x001F" "x0020 $x0020" "x0021 $x0021" "x0022 $x0022" "x0023 $x0023" "x0024 $x0024" "x0025 $x0025" "x0026 $x0026" "x0027 $x0027" "x0028 $x0028" "x0029 $x0029" "x002A $x002A" "x002B $x002B" "x002C $x002C" "x002D $x002D" "x002E $x002E" "x002F $x002F" "x0030 $x0030" "x0031 $x0031" "x0032 $x0032" "x0033 $x0033" "x0034 $x0034" "x0035 $x0035" "x0036 $x0036" "x0037 $x0037" "x0038 $x0038" "x0039 $x0039" "x003A $x003A" "x003B $x003B" "x003C $x003C" "x003D $x003D" "x003E $x003E" "x003F $x003F" "x0040 $x0040" "x0041 $x0041" "x0042 $x0042" "x0043 $x0043" "x0044 $x0044" "x0045 $x0045" "x0046 $x0046" "x0047 $x0047" "x0048 $x0048" "x0049 $x0049" "x004A $x004A" "x0051 $x0051" "x0060 $x0060" "x0061 $x0061" "x0100 $x0100" "x0101 $x0101" "x0102 $x0102" "x0103 $x0103" "x0104 $x0104" "x0105 $x0105" "x0106 $x0106" "x0107 $x0107" "x0108 $x0108" "x0109 $x0109" "x010A $x010A" "x010B $x010B" "x010C $x010C" "x010D $x010D" "x010E $x010E" "x010F $x010F" "x0110 $x0110" "x0111 $x0111" "x0112 $x0112" "x0113 $x0113" "x0114 $x0114" "x0115 $x0115" "x0116 $x0116" "x0117 $x0117" "x011E $x011E" "x011F $x011F" "x0120 $x0120" "x0121 $x0121" "x0122 $x0122" "x0123 $x0123" "x0124 $x0124" "x0125 $x0125" "x0126 $x0126" "x0127 $x0127" "x0128 $x0128" "x0129 $x0129" "x012A $x012A" "x012B $x012B" "x012C $x012C" "x012D $x012D" "x012E $x012E" "x012F $x012F" "x0130 $x0130" "x0131 $x0131" "x0132 $x0132" "x0133 $x0133" "x0140 $x0140" "x0150 $x0150" "x0151 $x0151" "x0152 $x0152" "x0153 $x0153" "x0160 $x0160" "x0161 $x0161" "x0162 $x0162" "x0170 $x0170" "x0171 $x0171" "x0180 $x0180" "x0181 $x0181" "x0182 $x0182" "x0183 $x0183" "x0184 $x0184" "x0185 $x0185" "x01A0 $x01A0" "x01C0 $x01C0" "x01C1 $x01C1" "x01C2 $x01C2" "x01C3 $x01C3" "x01C4 $x01C4" "x01C5 $x01C5" "x01C6 $x01C6" "x01C7 $x01C7" "x01C8 $x01C8" "x01C9 $x01C9" "x01CA $x01CA" "x01CB $x01CB" "x01CC $x01CC" "x01CD $x01CD" "x01CE $x01CE" "x01D0 $x01D0" "x01D1 $x01D1" "x01D2 $x01D2" "x01D3 $x01D3" "x01D4 $x01D4" "x0200 $x0200" "x0201 $x0201" "x0202 $x0202" "x0203 $x0203" "x0204 $x0204" "x0205 $x0205" "x0206 $x0206" "x0207 $x0207" "x0208 $x0208" "x0209 $x0209" "x020A $x020A" "x020B $x020B" "x020C $x020C" "x020D $x020D" "x0210 $x0210" "x0211 $x0211" "x0212 $x0212" "x0213 $x0213" "x0214 $x0214" "x0215 $x0215" "x0216 $x0216" "x0217 $x0217" "x0218 $x0218" "x0230 $x0230" "x0231 $x0231" "x0232 $x0232" "x0233 $x0233" "x0234 $x0234" "x0235 $x0235" "x0236 $x0236" "x0240 $x0240" "x0241 $x0241" "x0242 $x0242" "x0243 $x0243" "x0244 $x0244" "x0245 $x0245" "x0246 $x0246" "x0247 $x0247" "x0248 $x0248" "x024A $x024A" "x024B $x024B" "x024C $x024C" "x0250 $x0250" "x0251 $x0251" "x0252 $x0252" "x0253 $x0253" "x0254 $x0254" "x0255 $x0255" "x0256 $x0256" "x0257 $x0257" "x0258 $x0258" "x0259 $x0259" "x025A $x025A" "x025B $x025B" "x025C $x025C" "x025D $x025D" "x025E $x025E" "x025F $x025F" "x0261 $x0261" "x0260 $x0260" "x0270 $x0270" "x0271 $x0271" "x0272 $x0272" "x0280 $x0280" "x0281 $x0281" "x0282 $x0282" "x0283 $x0283" "x0290 $x0290" "x0291 $x0291" "x0293 $x0293" "x0294 $x0294" "x0295 $x0295" "x0296 $x0296" "x0297 $x0297" "x0298 $x0298" "x0299 $x0299" "x029A $x029A" "x029B $x029B" "x029C $x029C" "x029D $x029D" "x02A0 $x02A0" "x02A1 $x02A1" "x02A2 $x02A2" "x02A3 $x02A3" "x02A4 $x02A4" "x02A5 $x02A5" "x02A6 $x02A6" "x02A7 $x02A7" "x02A8 $x02A8" "x02A9 $x02A9" "x02AA $x02AA" "x02AB $x02AB" "x02B0 $x02B0" "x02B1 $x02B1" "x02B2 $x02B2" "x02B3 $x02B3" "x02B4 $x02B4" "x02B5 $x02B5" "x02B6 $x02B6" "x02B7 $x02B7" "x02B8 $x02B8" "x02B9 $x02B9" "x02BA $x02BA" "x02BB $x02BB" "x02BC $x02BC" "x02BD $x02BD" "x02BE $x02BE" "x02BF $x02BF" "x02C0 $x02C0" "x02C1 $x02C1" "x02C2 $x02C2" "x02C3 $x02C3" "x02C4 $x02C4" "x02C5 $x02C5" "x02C6 $x02C6" "x02C7 $x02C7" "x02C8 $x02C8" "x02C9 $x02C9" "x02CA $x02CA" "x02CB $x02CB" "x02CC $x02CC" "x02CD $x02CD" "x02CE $x02CE" "x02D0 $x02D0" "x02D1 $x02D1" "x02D2 $x02D2" "x02D3 $x02D3" "x02D4 $x02D4" "x02E0 $x02E0" "x02E1 $x02E1" "x02E4 $x02E4" "x02E5 $x02E5" "x02E6 $x02E6" "x02E7 $x02E7" "x02E8 $x02E8" "x02EA $x02EA" "x02EB $x02EB" "x02F0 $x02F0" "x02F1 $x02F1" "x02F2 $x02F2" "x02F3 $x02F3" "x02F4 $x02F4" "x0300 $x0300" "x0301 $x0301" "x0302 $x0302" "x0303 $x0303" "x0310 $x0310" "x0311 $x0311" "x0312 $x0312" "x0313 $x0313" "x0314 $x0314" "x0315 $x0315" "x0316 $x0316" "x0317 $x0317" "x0318 $x0318" "x0319 $x0319" "x031A $x031A" "x031B $x031B" "x031C $x031C" "x0320 $x0320" "x0321 $x0321" "x0322 $x0322" "x0323 $x0323" "x0330 $x0330" "x0331 $x0331" "x0332 $x0332" "x0333 $x0333" "x0334 $x0334" "x0335 $x0335" "x0336 $x0336" "x0337 $x0337" "x0338 $x0338" "x0339 $x0339" "x0340 $x0340" "x0341 $x0341" "x0350 $x0350" "x0351 $x0351" "x0352 $x0352" "x0353 $x0353" "x0354 $x0354" "x0380 $x0380" "x0381 $x0381" "x0382 $x0382" "x0383 $x0383" "x0384 $x0384" "x0385 $x0385" "x0386 $x0386" "x0387 $x0387" "x0388 $x0388" "x0389 $x0389" "x038A $x038A" "x038B $x038B" "x038C $x038C" "x038D $x038D" "x038E $x038E" "x0390 $x0390" "x0391 $x0391" "x0392 $x0392" "x0400 $x0400" "x0401 $x0401" "x0402 $x0402" "x0403 $x0403" "x0404 $x0404" "x0405 $x0405" "x0406 $x0406" "x0407 $x0407" "x0408 $x0408" "x0409 $x0409" "x040A $x040A" "x040B $x040B" "x040C $x040C" "x040D $x040D" "x040F $x040F" "x0410 $x0410" "x0411 $x0411" "x0412 $x0412" "x0413 $x0413" "x0414 $x0414" "x0415 $x0415" "x0416 $x0416" "x1000 $x1000" "x1001 $x1001" "x1002 $x1002" "x1003 $x1003" "x1004 $x1004" "x1005 $x1005" "x1006 $x1006" "x1007 $x1007" "x1008 $x1008" "x1009 $x1009" "x100A $x100A" "x100B $x100B" "x100C $x100C" "x1010 $x1010" "x1011 $x1011" "x1012 $x1012" "x1013 $x1013" "x1014 $x1014" "x1015 $x1015" "x1016 $x1016" "x1017 $x1017" "x1018 $x1018" "x1019 $x1019" "x101A $x101A" "x101B $x101B" "x101C $x101C" "x101D $x101D" "x1020 $x1020" "x1021 $x1021" "x1022 $x1022" "x1023 $x1023" "x1024 $x1024" "x2000 $x2000" "x2001 $x2001" "x2002 $x2002" "x2100 $x2100" "x2101 $x2101" "x2102 $x2102" "x2FFF $x2FFF" "x3013 $x3013" "x3014 $x3014" "x3017 $x3017" "x3018 $x3018" "x3019 $x3019" "x301A $x301A" "x301B $x301B" "x301C $x301C" "x301E $x301E" "x3021 $x3021" "x3024 $x3024" "x3025 $x3025" "x3026 $x3026" "x3027 $x3027" "x3047 $x3047" "x3062 $x3062" "x3063 $x3063" "x3064 $x3064" "x3065 $x3065" "x3066 $x3066" "x3067 $x3067" "x3068 $x3068" "x3069 $x3069" "x306A $x306A" "x306B $x306B" "x306C $x306C" "x306D $x306D" "x3070 $x3070" "x3071 $x3071" "x3072 $x3072" "x3073 $x3073" "x3074 $x3074" "x3100 $x3100" "x3101 $x3101" "x3102 $x3102" "x3103 $x3103" "x3104 $x3104" "x3105 $x3105" "x3106 $x3106" "x3107 $x3107" "x3108 $x3108" "x3109 $x3109" "x310A $x310A" "x310B $x310B" "x310C $x310C" "x310D $x310D" "x310E $x310E" "x310F $x310F" "x3110 $x3110" "x3111 $x3111" "x3112 $x3112" "x3113 $x3113" "x3200 $x3200" "x3201 $x3201" "x3202 $x3202" "x3203 $x3203" "x3204 $x3204" "x3205 $x3205" "x3300 $x3300" "x7E00 $x7E00" "x7E01 $x7E01" "x7E02 $x7E02" "x7E03 $x7E03" "x7E04 $x7E04" "x7E05 $x7E05" "x7E06 $x7E06" "x7E07 $x7E07" "x7E08 $x7E08" "x7E09 $x7E09" "x7E0A $x7E0A" "x7E0B $x7E0B" "x7E0C $x7E0C" "x7E0D $x7E0D" "x7E0E $x7E0E" "x7E0F $x7E0F" "x7E10 $x7E10" "x7E11 $x7E11"; do
	
		set $i
	
		if [ -f ./$fileName/LSI_Products/3ware/3ware_driver_x03_9000_ERROR.txt ]; then
	       		$grep -i $1 ./$fileName/LSI_Products/3ware/3ware_driver_x03_9000_ERROR.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x03_$1_$2.txt
	
			if [ ! -s ./$fileName/LSI_Products/3ware/3ware_driver_x03_$1_$2.txt ]; then rm ./$fileName/LSI_Products/3ware/3ware_driver_x03_$1_$2.txt > /dev/null 2>&1 ; fi
	
		fi
	
	done
	
	########################################################################################################################### 
	# Deferred errors (AENs) 0x04 
	########################################################################################################################### 
	x0000="AEN_queue_empty" 
	x0001="Controller_reset_occurred" 
	x0002="Degraded_unit" 
	x0003="Controller_error_occurred" 
	x0004="Rebuild_failed" 
	x0005="Rebuild_completed" 
	x0006="Incomplete_unit_detected" 
	x0007="Initialize_completed" 
	x0008="Unclean_shutdown_detected" 
	x0009="Drive_timeout_detected" 
	x000A="Drive_error_detected" 
	x000B="Rebuild_started" 
	x000C="Initialize_started" 
	x000D="Unit_deleted" 
	x000E="Initialize_failed" 
	x000F="SMART_threshold_exceeded" 
	x0010="Power_supply_reported_AC_under_range" 
	x0011="Power_supply_reported_DC_out_of_range" 
	x0012="Power_supply_reported_a_malfunction" 
	x0013="Power_supply_predicted_malfunction" 
	x0014="Battery_charge_below_threshold" 
	x0015="Fan_speed_below_threshold" 
	x0016="Temperature_sensor_above_threshold" 
	x0017="Power_supply_removed" 
	x0018="Power_supply_inserted" 
	x0019="Drive_removed" 
	x001A="Drive_inserted" 
	x001B="Drive_bay_cover_door_was_opened" 
	x001C="Drive_bay_cover_door_was_closed" 
	x001D="Product_case_was_opened" 
	x001E="Unit_inoperable" 
	x001F="Unit_operational" 
	x0020="Prepare_for_shutdown_power-off" 
	x0021="Downgrade_UDMA_mode" 
	x0022="Upgrade_UDMA_mode" 
	x0023="Sector_repair_completed" 
	x0024="Buffer_integrity_test_failed" 
	x0025="Cache_flush_failed_some_data_lost" 
	x0026="Drive_ECC_error_reported" 
	x0027="DCB_checksum_error_detected" 
	x0028="DCB_version_unsupported" 
	x0029="Verify_started" 
	x002A="Verify_failed" 
	x002B="Verify_completed" 
	x002C="Source_drive_ECC_error_overwritten" 
	x002D="Source_drive_error_occurred" 
	x002E="Replacement_drive_capacity_too_small" 
	x002F="Verify_not_started_unit_never_initialized" 
	x0030="Drive_not_supported" 
	x0031="Synchronize_host_or_controller_time" 
	x0032="Spare_capacity_too_small_for_some_units" 
	x0033="Migration_started" 
	x0034="Migration_failed" 
	x0035="Migration_completed" 
	x0036="Verify_fixed_data_or_parity_mismatch" 
	x0037="SO-DIMM_not_compatible" 
	x0038="SO-DIMM_not_detected" 
	x0039="Buffer_ECC_error_corrected" 
	x003A="Drive_power_on_reset_detected" 
	x003B="Rebuild_paused" 
	x003C="Initialize_paused" 
	x003D="Verify_paused" 
	x003E="Migration_paused" 
	x003F="Flash_file_system_error_detected" 
	x0040="Flash_file_system_repaired" 
	x0041="Unit_number_assignments_lost" 
	x0042="Primary_DCB_read_error_occurred" 
	x0043="Backup_DCB_read_error_detected" 
	x0044="Battery_voltage_is_normal" 
	x0045="Battery_voltage_is_low" 
	x0046="Battery_voltage_is_high" 
	x0047="Battery_voltage_is_too_low" 
	x0048="Battery_voltage_is_too_high" 
	x0049="Battery_temperature_is_normal" 
	x004A="Battery_temperature_is_low" 
	x004B="Battery_temperature_is_high" 
	x004C="Battery_temperature_is_too_low" 
	x004D="Battery_temperature_is_too_high" 
	x004E="Battery_capacity_test_started" 
	x004F="Cache_synchronization_skipped" 
	x0050="Battery_capacity_test_completed" 
	x0051="Battery_health_check_started" 
	x0052="Battery_health_check_completed" 
	x0053="Battery_capacity_test_is_overdue" 
	x0054="Charge_termination_voltage_is_at_high_level" 
	x0055="Battery_charging_started" 
	x0056="Battery_charging_completed" 
	x0057="Battery_charging_fault" 
	x0058="Battery_capacity_is_below_warning_level" 
	x0059="Battery_capacity_is_below_error_level" 
	x005A="Battery_is_present" 
	x005B="Battery_is_not_present" 
	x005C="Battery_is_weak" 
	x005D="Battery_health_check_failed" 
	x005E="Cache_synchronization_completed" 
	x005F="Cache_synchronization_failed_some_data_lost" 
	x0060="Redundancy_level_decreased" 
	x0061="Redundancy_level_increased" 
	#x0062="Enclosure_removed__9.5.0_CodeSet_and_Later" 
	#x0062="Local_link_up__PRE_9.5.0_CodeSet" 
	x0062="Shared_x0062" 
	#x0063="Enclosure_added__9.5.0_CodeSet_and_Later" 
	#x0063="Local_link_down__PRE_9.5.0_CodeSet" 
	x0063="Shared_x0063" 
	#x0064="Local_link_up__9.5.0_CodeSet_and_Later" 
	#x0064="Enclosure_removed__Only_9.4.3_CodeSet"  
	x0064="Shared_x0064"  
	#x0065="Local_link_down__9.5.0_CodeSet_and_Later" 
	#x0065="Enclosure_added__Only_9.4.3_CodeSet"  
	x0065="Shared_x0065"  
	x0067="NVRAM_data_preserved_over_power_fail" 
	x0068="NVRAM_data_not_preserved_over_power_fail" 
	x0070="Drive_Write_Fault"
	x00F7="Bad_cache_metadata_checksum" 
	x00F8="Bad_cache_metadata_signature" 
	x00F9="Cache_metadata_restore_failed" 
	x00FA="BBU_not_found_after_power_fail" 
	x00FB="BBU_and_HBA_state_out_of_sync" 
	x00FC="Recovered_or_finished_array_membership_update" 
	x00FD="Handler_lockup" 
	x00FE="Retrying_PCI_transfer" 
	x00FF="AEN_queue_is_full" 
	x0100="Error_occurred_during_device_discovery" 
	x8000="Enclosure_fan_normal"
	x8001="Enclosure_fan_error"
	x8002="Enclosure_fan_removed"
	x8003="Enclosure_fan_added"
	x8004="Enclosure_fan_status_unknown"
	x8005="Enclosure_fan_on"
	x8006="Enclosure_fan_off"
	x8010="Enclosure_fan_stopped"
	x8011="Enclosure_fan_started"
	x8012="Enclosure_fan_speed_increased"
	x8013="Enclosure_fan_speed_decreased"
	x8020="Enclosure_temperature_normal"
	x8021="Enclosure_temperature_low"
	x8022="Enclosure_temperature_high"
	x8023="Enclosure_temperature_too_low"
	x8024="Enclosure_temperature_too_high"
	x8025="Enclosure_temperature_sensor_removed" 
	x8026="Enclosure_temperature_sensor_added" 
	x8027="Enclosure_temperature_sensor_error" 
	x8028="Enclosure_temperature_status_unknown" 
	x8030="Enclosure_power_supply_normal"
	x8031="Enclosure_power_supply_failed"
	x8032="Enclosure_power_supply_removed"
	x8033="Enclosure_power_supply_added"
	x8034="Enclosure_power_supply_status_unknown" 
	x8036="Enclosure_power_supply_on"
	x8037="Enclosure_power_supply_off"
	x8040="Enclosure_power_supply_voltage_normal" 
	x8041="Enclosure_power_supply_voltage_high" 
	x8042="Enclosure_power_supply_voltage_low" 
	x8043="Enclosure_power_supply_voltage_status_unknown" 
	x8044="Enclosure_power_supply_current_normal" 
	x8045="Enclosure_power_supply_current_high" 
	x8046="Enclosure_power_supply_current_status_unknown"
	
	x8047="Enclosure_audio_alarm_activated_and_muted" 
	x8048="Enclosure_audio_alarm_failed"
	x8049="Enclosure_audio_alarm_removed"
	x804A="Enclosure_audio_alarm_added"
	x804B="Enclosure_audio_alarm_status_unknown"
	 
	#Deferred errors(AENs)0x04 
	for i in "x0000 $x0000" "x0001 $x0001" "x0002 $x0002" "x0003 $x0003" "x0004 $x0004" "x0005 $x0005" "x0006 $x0006" "x0007 $x0007" "x0008 $x0008" "x0009 $x0009" "x000A $x000A" "x000B $x000B" "x000C $x000C" "x000D $x000D" "x000E $x000E" "x000F $x000F" "x0010 $x0010" "x0011 $x0011" "x0012 $x0012" "x0013 $x0013" "x0014 $x0014" "x0015 $x0015" "x0016 $x0016" "x0017 $x0017" "x0018 $x0018" "x0019 $x0019" "x001A $x001A" "x001B $x001B" "x001C $x001C" "x001D $x001D" "x001E $x001E" "x001F $x001F" "x0020 $x0020" "x0021 $x0021" "x0022 $x0022" "x0023 $x0023" "x0024 $x0024" "x0025 $x0025" "x0026 $x0026" "x0027 $x0027" "x0028 $x0028" "x0029 $x0029" "x002A $x002A" "x002B $x002B" "x002C $x002C" "x002D $x002D" "x002E $x002E" "x002F $x002F" "x0030 $x0030" "x0031 $x0031" "x0032 $x0032" "x0033 $x0033" "x0034 $x0034" "x0035 $x0035" "x0036 $x0036" "x0037 $x0037" "x0038 $x0038" "x0039 $x0039" "x003A $x003A" "x003B $x003B" "x003C $x003C" "x003D $x003D" "x003E $x003E" "x003F $x003F" "x0040 $x0040" "x0041 $x0041" "x0042 $x0042" "x0043 $x0043" "x0044 $x0044" "x0045 $x0045" "x0046 $x0046" "x0047 $x0047" "x0048 $x0048" "x0049 $x0049" "x004A $x004A" "x004B $x004B" "x004C $x004C" "x004D $x004D" "x004E $x004E" "x004F $x004F" "x0050 $x0050" "x0051 $x0051" "x0052 $x0052" "x0053 $x0053" "x0054 $x0054" "x0055 $x0055" "x0056 $x0056" "x0057 $x0057" "x0058 $x0058" "x0059 $x0059" "x005A $x005A" "x005B $x005B" "x005C $x005C" "x005D $x005D" "x005E $x005E" "x005F $x005F" "x0060 $x0060" "x0061 $x0061" "x0062 $x0062" "x0063 $x0063" "x0064 $x0064" "x0065 $x0065" "x0067 $x0067" "x0068 $x0068" "x0070 $x0070" "x00F7 $x00F7" "x00F8 $x00F8" "x00F9 $x00F9" "x00FA $x00FA" "x00FB $x00FB" "x00FC $x00FC" "x00FD $x00FD" "x00FE $x00FE" "x00FF $x00FF" "x0100 $x0100" "x8000 $x8000" "x8001 $x8001" "x8002 $x8002" "x8003 $x8003" "x8004 $x8004" "x8005 $x8005" "x8006 $x8006" "x8010 $x8010" "x8011 $x8011" "x8012 $x8012" "x8013 $x8013" "x8020 $x8020" "x8021 $x8021" "x8022 $x8022" "x8023 $x8023" "x8024 $x8024" "x8025 $x8025" "x8026 $x8026" "x8027 $x8027" "x8028 $x8028" "x8030 $x8030" "x8031 $x8031" "x8032 $x8032" "x8033 $x8033" "x8034 $x8034" "x8036 $x8036" "x8037 $x8037" "x8040 $x8040" "x8041 $x8041" "x8042 $x8042" "x8043 $x8043" "x8044 $x8044" "x8045 $x8045" "x8046 $x8046" "x8047 $x8047" "x8049 $x8049" "x804A $x804A" "x804B $x804B" ; do
	
		set $i
	
		if [ -f ./$fileName/LSI_Products/3ware/3ware_driver_x04_9000_EVENT.txt ]; then
	
	       		$grep -i $1 ./$fileName/LSI_Products/3ware/3ware_driver_x04_9000_EVENT.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x04_$1_$2.txt
	
			if [ ! -s ./$fileName/LSI_Products/3ware/3ware_driver_x04_$1_$2.txt ]; then rm ./$fileName/LSI_Products/3ware/3ware_driver_x04_$1_$2.txt > /dev/null 2>&1 ; fi
	
		fi
	done
	
	if [ -f ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0062_Shared_x0062.txt ]; then
		grep -i "Enclosure removed" ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0062_Shared_x0062.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0062_Enclosure_removed.txt
		grep -i "Local link up" ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0062_Shared_x0062.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0062_Local_link_up.txt
		rm ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0062_Shared_x0062.txt
	fi
	
	if [ -f ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0063_Shared_x0063.txt ]; then
		grep -i "Enclosure added" ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0063_Shared_x0063.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0063_Enclosure_added.txt
		grep -i "Local link down" ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0063_Shared_x0063.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0063_Local_link_down.txt
		rm ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0063_Shared_x0063.txt
	fi
	
	if [ -f ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0064_Shared_x0064.txt ]; then
		grep -i "Local link up" ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0064_Shared_x0064.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0064_Local_link_up.txt
		grep -i "Enclosure removed" ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0064_Shared_x0064.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0064_Enclosure_removed.txt
		rm ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0064_Shared_x0064.txt
	fi
	
	if [ -f ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0065_Shared_x0065.txt ]; then
		grep -i "Local link down" ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0065_Shared_x0065.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0065_Local_link_down.txt
		grep -i "Enclosure added" ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0065_Shared_x0065.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0065_Enclosure_added.txt
		rm ./$fileName/LSI_Products/3ware/3ware_driver_x04_x0065_Shared_x0065.txt
	fi
	
	for i in _x0062_Enclosure_removed.txt _x0062_Local_link_up.txt _x0063_Enclosure_added.txt _x0063_Local_link_down.txt _x0064_Local_link_up.txt _x0064_Enclosure_removed.txt _x0065_Local_link_down.txt _x0065_Enclosure_added.txt; do
	
		if [ ! -s ./$fileName/LSI_Products/3ware/3ware_driver_x04$l ]; then rm ./$fileName/LSI_Products/3ware/3ware_driver_x04$l > /dev/null 2>&1 ; fi
	
	done
	
	###########################################################################################################################
	###Update on CodeSet Change
	# Based on errorcode.h 5.12.00.016FW 10.2.2.1 codeset 
	# Errors = 0x03 that accompany AEN's 0x04's don't have preceeding 0's
	# Duplicate of 0x03 errors without preceeding 0's
	# Example -  3w-9xxx: scsi0: AEN: WARNING (0x04:0x0043): Backup DCB read error detected:port=2, error=0x202.
	# Legacy error_codes, these are reserved on Apache 
	###########################################################################################################################
	x0="no_error_status_dependent_code_for_this_error_status" 
	x1="no_request_ID_available_for_this_error_status" 
	x2="CP_queue_became_full" 
	x3="illegal_SGL_offset_in_CP_Header" 
	x4="illegal_number_of_SGL_entries_in_CPH" 
	x5="could_not_allocate_additional_memory" 
	x6="some_PCI_read_error_occurred" 
	x7="timeout_during_PCI_transaction" 
	x8="PCI_ERR_bit_for_a_PCI_transaction" 
	x9="unrecoverable_disk_error" 
	xA="completion_token_queue_overflow" 
	xB="error_reading_SGL" 
	xC="error_reading_CP_Header" 
	xD="abort_req_for_cmd_that_wasn't_active" 
	xE="illegal_size_in_CP_Header" 
	xF="got_a_CPH_with_an_already_active_req_ID" 
	x10="lengths_in_SGLs_not_match_block_count_in_CP" 
	x11="requested_LBA_greater_than_maximum_LBA_of_the_unit" 
	x12="host_address_or_SGL_size_not_on_8_dw_boundary" 
	x13="data_integrity_error_on_read_or_write_test" 
	x14="subcmd_num_in_CP_hdr_is_undef_for_this_cmd" 
	x15="undefined_table_requested" 
	x16="param_requested_is_out_of_bounds_of_table" 
	x17="given_param_size_doesnt_match_param_size_in_table" 
	x18="host_address_or_SGL_size_not_on_a_sector_boundary" 
	x19="Achip_Unit_number_exceeds_maximum" 
	x1A="bad_pairing_of_disk-op_or_xer-op_from_Aop_queue" 
	x1B="Aport_timed_out_doing_an_Aop" 
	x1C="an_Achip_GSR_interrupt_occurred" 
	x1D="Aop_encountered_with_unknown_cmd_byte" 
	x1E="PCI_was_busy_when_tried_to_do_a_PCI_read_or_write" 
	x1F="next_Aop_should_have_been_a_disk-op_but_it_wasnt" 
	x20="param_0_unsupported_for_now_for_get_or_set_param" 
	x21="an_unimplemented_method_was_invoked" 
	x22="request_ID_took_too_long_to_complete" 
	x23="a_disk_task_file_error_occurred_during_a_1F_test" 
	x24="data_lines_shorted_in_Sbuf_RAM" 
	x25="data_lines_open_in_Sbuf_RAM" 
	x26="addr_line_problem_in_Sbuf_RAM" 
	x27="Sbuf_RAM_unreadable" 
	x28="command_requires_at_least_1_SGL" 
	x29="no_unit_num_is_available_for_use" 
	x2A="CP_queue_was_empty_when_tried_to_get_a_CP_ptr_from_it" 
	x2B="test_firmware_not_downloaded_to_RAM" 
	x2C="an_attempt_was_made_to_nest_internal_requests" 
	x2D="error_in_downloading_hex_file" 
	x2E="error_in_programming_the_flash_ROM" 
	x2F="error_in_rollcall" 
	x30="error_in_wait_disks_rdy" 
	x31="error_in_UIT_formatting" 
	x32="incorrect_unit_type_for_the_request" 
	x33="unit_does_not_have_the_logical_sub-unit_specified" 
	x34="unit_has_corrupted_data_on_it" 
	x35="could_not_write_DCB_to_disk" 
	x36="could_not_get_profiler_from_disk" 
	x37="unit_is_not_exportable" 
	x38="unit_is_missing_a_sub-unit" 
	x39="unit_is_not_operating_normally" 
	x3A="not_enough_SBUF_segments_to_service_the_request" 
	x3B="User_area_in_unit_was_not_written_with_zeroes" 
	x3C="user_data_on_unit_did_not_verify" 
	x3D="error_while_writing_0s_to_user_data" 
	x3E="a_unit_does_not_contain_a_logical_mapping_for_a_phys_drive" 
	x3F="drive_replacement_would_cause_a_double-degrade" 
	x40="capacity_of_replacement_drive_is_too_small" 
	x41="no_drive_detected" 
	x42="drive_detected_to_be_busy" 
	x43="aport_unavailable" 
	x44="unable_to_clear_sbuf" 
	x45="can_not_replace_drive_because_unit_not_degraded" 
	x46="we_have_no_routine_to_program_this_mfr_or_type_of_flash" 
	x47="cant_fill_Sbuf_with_zeros" 
	x48="byte_count_in_PARAM_field_is_too_big_for_this_cmd" 
	x49="timeout_while_waiting_for_data_from_display_panel" 
	x4A="CRC_error_reported_on_BFB_transfer" 
	x51="for_drive_errors_the_status_register_gets_stuffed_into_LSB_of_ESDC" 
	x60="reserved_-_this_is_a_valid_drive_status_error_code" 
	x61="reserved_-_this_is_a_valid_drive_status_error_code" 
	
	x100="SGL_entry_contains_zero_data" 
	x101="Invalid_command_opcode" 
	x102="SGL_entry_has_unaligned_address" 
	x103="SGL_size_does_not_match_command" 
	x104="SGL_entry_has_illegal_length" 
	x105="Command_packet_is_not_aligned" 
	x106="Invalid_request_ID" 
	x107="Duplicate_request_ID" 
	x108="ID_not_locked" 
	x109="LBA_out_of_range" 
	x10A="Logical_unit_not_present" 
	x10B="Parameter_table_does_not_exist" 
	x10C="Parameter_index_does_not_exist" 
	x10D="Invalid_field_in_CDB" 
	x10E="Invalid_operation_for_specified_port" 
	x10F="Parameter_item_size_mismatch" 
	
	x110="Failed_memory_allocation" 
	x111="Memory_request_too_large" 
	x112="Out_of_memory_segments" 
	x113="Invalid_address_to_deallocate" 
	x114="Out_of_memory" 
	x115="Out_of_heap" 
	x116="Invalid_BIOS_buffer_id" 
	
	x117="Host_lock_not_available" 
	
	x11E="Unrecovered_Read_Error"
	x11F="Recovered_Data_with_error_correction_applied"
	
	x120="Double_degrade" 
	x121="Drive_not_degraded" 
	x122="Reconstruct_error" 
	x123="Replace_not_accepted" 
	x124="Drive_capacity_too_small" 
	x125="Sector_count_not_allowed" 
	x126="No_spares_left" 
	x127="Reconstruct_error" 
	x128="Unit_offline" 
	x129="Cannot_update_status_to_DCB" 
	x12A="Invalid_configuration_for_split" 
	x12B="Invalid_configuration_for_join" 
	x12C="No_migration_recovery" 
	x12D="No_SATA_spares" 
	x12E="No_SAS_spares"  
	x12F="Mixed_SAS_SATA_not_allowed_in_same_unit" 
	
	x130="Invalid_stripe_handle" 
	x131="Handle_that_was_not_locked" 
	x132="Handle_that_was_not_empty" 
	x133="Handle_has_different_owner" 
	
	x140="IPR_has_parent" 
	
	x150="Illegal_Pbuf_address_alignment" 
	x151="Illegal_Pbuf_transfer_length" 
	x152="Illegal_Sbuf_address_alignment" 
	x153="Illegal_Sbuf_transfer_length" 
	
	x160="Command_packet_too_large" 
	x161="SGL_exceeds_maximum_length" 
	x162="SGL_has_too_many_entries" 
	
	x170="Insufficient_resources_for_rebuilder" 
	x171="Verify_error_data_doesnt_equal_parity" 
	
	x180="Requested_segment_not_in_directory_of_this_DCB" 
	x181="DCB_segment_has_unsupported_version" 
	x182="DCB_segment_has_checksum_error" 
	x183="DCB_support_settings_segment_invalid" 
	x184="DCB_UDB_unit_descriptor_block_segment_invalid" 
	x185="DCB_GUID_globally_unique_identifier_segment_invalid" 
	
	x1A0="Could_not_clear_Sbuf" 
	
	x1C0="Flash_device_unsupported" 
	x1C1="Flash_out_of_bounds" 
	x1C2="Flash_write_verify_failed" 
	x1C3="Flash_file_object_not_found" 
	x1C4="Flash_file_already_present" 
	x1C5="Flash_file_system_full" 
	x1C6="Flash_file_not_present" 
	x1C7="Flash_file_size_mismatch" 
	x1C8="Flash_file_checksum_error" 
	x1C9="Flash_file_version_unsupported" 
	x1CA="Flash_file_system_error_detected" 
	x1CB="Flash_file_component_directory_not_found" 
	x1CC="Flash_file_component_not_found" 
	x1CD="Flash_write_cycle_failed" 
	x1CE="Flash_erase_cycle_failed" 
	
	x1D0="Invalid_field_in_parameter_list" 
	x1D1="Parameter_list_length_error" 
	x1D2="Parameter_not_changeable" 
	x1D3="Parameter_not_saveable" 
	x1D4="Invalid_mode_page" 
	
	x200="Drive_CRC_error" 
	x201="Internal_bus_CRC_error" 
	x202="Drive_ECC_Medium_error" 
	x203="Drive_TFR_readback_error" 
	x204="Drive_timeout" 
	x205="Drive_power_on_reset" 
	x206="ADP_level_2_error" 
	x207="Drive_soft_reset_failed" 
	x208="Drive_not_ready" 
	x209="Unclassified_drive_error" 
	x20A="Drive_aborted_command" 
	x20B="Port_link_error_detected" 
	x20C="Port_internal_error_detected" 
	x20D="Drive_not_ready_require_Spinup" 
	x20E="Uninitialized_drive_handle" 
	
	x210="Internal_bus_CRC_error" 
	x211="PCI_bus_abort_error" 
	x212="PCI_bus_parity_error" 
	x213="Port_handler_error" 
	x214="Token_interrupt_count_error" 
	x215="PCI_bus_timeout" 
	x216="Buffer_ECC_error_corrected" 
	x217="Buffer_ECC_error_not_corrected" 
	x218="Xop_pool_parity_error" 
	
	x230="Unsupported_command_during_flash_recovery" 
	x231="Next_image_buffer_expected" 
	x232="Binary_image_architecture_ID_incompatible" 
	x233="Binary_image_no_signature_detected" 
	x234="Binary_image_checksum_error_detected" 
	x235="Binary_image_buffer_overflow_detected" 
	x236="Binary_image_SRL_incompatible" 
	
	x240="I2C_device_not_detected" 
	x241="I2C_transaction_aborted" 
	x242="SO-DIMM_parameters_incompatible_using_defaults" 
	x243="SO-DIMM_unsupported" 
	x244="I2C_clock_is_held_low_transfer_aborted" 
	x245="I2C_data_is_held_low_transfer_aborted" 
	x246="I2C_slave_device_NACKed_the_transfer"
	x247="I2C_buffer_in-sufficient" 
	x248="SPI_transfer_status_error" 
	x24A="I2C_interface_is_active" 
	x24B="Lost_arbitration" 
	x24C="I2C_transfer_error" 
	
	x250="Unit_descriptor_size_invalid" 
	x251="Unit_descriptor_size_exceeds_data_buffer" 
	x252="Invalid_value_in_unit_descriptor" 
	x253="Inadequate_disk_space_to_support_descriptor" 
	x254="Unable_to_create_data_channel_for_this_unit_descriptor" 
	x255="Unit_descriptor_specifies_a_drive_already_in_use" 
	x256="Unable_to_write_configuration_to_all_disks" 
	x257="Unit_descriptor_version_not_supported" 
	x258="Invalid_subunit_for_RAID_0_or_5" 
	x259="Too_many_unit_descriptors" 
	x25A="Invalid_configuration_in_unit_descriptor" 
	x25B="Invalid_LBA_offset_in_unit_descriptor" 
	x25C="Invalid_stripelet_size_in_unit_descriptor" 
	x25D="JBOD_unit_is_not_allowed" 
	x25E="Operation_not_allowed_retained_cache_data" 
	x25F="Exceeded_maximum_number_of_active_drives" 
	x260="SMART_threshold_exceeded" 
	x261="Maximum_number_of_units_reached" 
	
	
	x270="Unit_not_in_NORMAL_state" 
	x271="Invalid_drive_members" 
	x272="Converted_unit_not_supported" 
	
	x280="ResponseIU_status_code_EC_STATUS_BUSY" 
	x281="ResponseIU_status_code_EC_STATUS_QUEUE_FULL" 
	x282="ResponseIU_status_code_EC_STATUS_UNEXPECTED" 
	x283="IO_Hold_Error"
	
	x290="No_Sense_Info_EC_SK_NO_SENSE_INFO"  
	x291="Recovered_Error_EC_SK_RECOVERED_ERROR"  
	x293="Hardware_Error_EC_SK_HARDWARE_ERROR"  
	x294="Hardware_ECC_Error_EC_SK_HARDWARE_ECC"  
	x295="Illegal_Req_EC_SK_ILLEGAL_REQ"  
	x296="Unit_Attention_EC_SK_UNIT_ATTENTION"  
	x297="Unit_Attention_Reset_EC_SK_UNIT_ATTENTION" 
	# note: The error code below is reused - Commented Out 
	#x205="ResponseIU_status_codeEC_SK_UNIT_REset" 
	x298="Aborted_Cmd_EC_SK_ABORTED_CMD"  
	x299="Sense_Keys_Unexpected_EC_SK_UNEXPECTED"  
	x29A="Unit_Attention_Mode_Page_Changed_EC_SK_UNIT_ATTENTION" 
	x29B="Current_command_Write_Fault"
	x29C="Deferred_Drive_Write_Fault"
	
	x29D="Lba_Out_Of_Range"
	
	x2A0="SAS_error_code_EC_PAYLOAD_PARITY" 
	x2A1="SAS_error_code_EC_UNDER_RUN_IN_RW" 
	x2A2="SAS_error_code_EC_UNDER_RUN_OUT" 
	x2A3="SAS_error_code_EC_OVER_RUN" 
	x2A4="SAS_error_code_EC_OPEN_REJECT_BUSY"  
	x2A5="SAS_error_code_EC_OPEN_REJECT_RETRY"   
	x2A6="SAS_error_code_EC_OPEN_REJECT_ABANDON"   
	x2A7="SAS_error_code_EC_OPEN_REJECT_STP_RES_BUSY"   
	x2A8="SAS_error_code_EC_RX_FRAME_ERROR"   
	x2A9="SAS_error_code_EC_RX_TRANSPORT_ERROR" 
	x2AA="SAS_error_code_EC_PORT_OFFLINE"   
	x2AB="SAS_Response_data_present"   
	
	x2B0="Tx_failure_-_SATA_SYNC_received" 
	x2B1="Tx_failure_-_BREAK_received" 
	x2B2="Protocol_overrun" 
	x2B3="Protocol_underrun" 
	x2B4="Open_failure_-_Connection_rejected" 
	x2B5="Open_failure_-_Bad_destination" 
	x2B6="Open_failure_-_Wrong_destination" 
	x2B7="Open_failure_-_Connection_rate_not_supported" 
	x2B8="Open_failure_-_Protocol_not_supported" 
	x2B9="Open_failure_-_STP_Resources_busy" 
	x2BA="Open_failure_-_No_destination" 
	x2BB="Open_failure_-_Pathway_blocked" 
	x2BC="Open_failure_-_Retry" 
	x2BD="Open_failure_-_Open_frame_timeout" 
	x2BE="STP_Inactivity" 
	x2BF="Failed_to_discover_Emulex_chip" 
	x2C0="Emulex_flash_file_is_corrupted" 
	x2C1="Error_while_flashing_Emulex" 
	x2C2="Target_returned_valid_sense_data_during_a_SCSI_PASSTHROUGH" 
	x2C3="Failed_to_unlock_flash_block_while_flashing_Emulex_ROM" 
	x2C4="Failed_to_erase_flash_block_while_flashing_Emulex_ROM" 
	x2C5="Failed_to_write_flash_block_while_flashing_Emulex_ROM" 
	x2C6="Failed_to_lock_flash_block_while_flashing_Emulex_ROM" 
	x2C7="ROM_size_is_not_a_multiple_of_128k" 
	x2C8="Emulex_SLI_command_timeout" 
	x2C9="Emulex_mailbox_status_error" 
	x2CA="Emulex_mailbox_format_error" 
	x2CB="Emulex_no_resources" 
	x2CC="Emulex_protocol_check_error" 
	x2CD="Emulex_protocol_fis_error" 
	x2CE="IOC_firmware_update_error" 
	
	x2D0="Discovery_module_resource_error" 
	x2D1="Delete_the_port_in_discovery_Manager" 
	x2D2="Discovery_module_bad_pointer_error" 
	x2D3="Discovery_module_unknown_SMP_function" 
	x2D4="Target_Unregistration_with_IOC_failed" 
	
	x2E0="SAS_Error_PAYLOAD_PARITY" 
	x2E1="SAS_Error_UNDER_RUN_IN_RW" 
	x2E4="SAS_Error_OPEN_REJECT_BUSY" 
	x2E5="SAS_Error_OPEN_REJECT_RETRY" 
	x2E6="SAS_Error_OPEN_REJECT_ABANDON" 
	x2E7="SAS_Error_OPEN_REJECT_STP_RES_BUSY" 
	x2E8="SAS_Error_RX_FRAME_ERROR" 
	x2EA="SAS_Error_PORT_OFFLINE" 
	
	x2EB="Suspend_IO_during_PL_TMF" 
	
	x2F0="Tx_failure_-_SATA_R_ERR_received" 
	x2F1="Tx_failure_-_SATA_DMAT_received" 
	x2F2="Non_specific_NCQ_error" 
	x2F3="Task_File_error" 
	x2F4="SATA_Register_Set_error" 
	
	x300="Internal_errorcode_BBU_base_-_should_not_occur" 
	x301="Invalid_BBU_state_change_request"  
	x302="The_BBU_resource_needed_is_in_use_retry_command_after_a_delay"  
	x303="Command_requires_a_battery_pack_to_be_present_and_enabled" 
	
	x310="BBU_command_packet_error" 
	x311="BBU_command_not_implemented" 
	x312="BBU_command_buffer_underflow" 
	x313="BBU_command_buffer_overflow" 
	x314="BBU_command_incomplete" 
	x315="BBU_command_checksum_error" 
	x316="BBU_command_timeout" 
	
	x317="BBU_flash_operation_failed" 
	x318="BBU_flash_Vpp_voltage_out_of_progamming_range" 
	x319="BBU_flash_incorrect_command_or_parameter_or_not_enough_space_in_stack" 
	x31A="BBU_flash_not_yet_completed" 
	x31B="BBU_flash_write_skip" 
	x31C="BBU_flash_invalid_erase_sector" 
	
	x320="BBU_parameter_not_defined" 
	x321="BBU_parameter_size_mismatch" 
	x322="Cannot_write_a_read-only_BBU_parameter" 
	x323="Invalid_state_bits_in_BBU_SetportPins_command" 
	
	x330="FBU_nif_error"
	x331="FBU_ERASE_BLOCK_ERROR"
	x332="FBU_Program_error"
	x333="FBU_ecc_uncorrectable"
	x334="FBU_ecc_correctable"
	x335="FBU_Program_error"
	x336="FBU_Erase_error"
	x337="FBU_No_defect_guard"
	x338="FBU_Read_Error"
	x339="FBU_Read_Error"
	
	x350="Uncorrectable_ECC_Error"
	x351="Correctable_ECC_Error"
	x352="Access_out_of_memory_range"
	x353="Dram_Controller_Fatal_Error"
	x354="Dram_ECC_error_log_full"
	
	x340="Invalid_discharge-learn_cycle_in_Battery_test" 
	x341="Battery_test_failed"
	
	x380="BBU_firmware_version_string_not_found" 
	x381="BBU_operating_state_not_available" 
	x382="BBU_not_present" 
	x383="BBU_not_ready" 
	x384="BBU_S1_not_compatible_with_HBA" 
	x385="BBU_S0_not_compatible_with_HBA" 
	x386="BBU_not_compatible_with_HBA" 
	x387="BBU_not_in_S0" 
	x388="BBU_not_in_S1" 
	x389="Timeout_on_BBU_power_fail_interrupt" 
	x38A="BBU_invalid_response_length" 
	x38B="Not_S1_ident_or_event_packet" 
	x38C="HBA_has_backup_data" 
	x38D="Invalid_BBU_state" 
	x38E="BBU_invalid_response_code" 
	
	x390="Log_updates_not_allowed" 
	x391="Logs_are_invalid" 
	x392="Logs_not_found" 
	
	x400="Invalid_enclosure_port_defined" 
	x401="Enclosure_resource_reserved" 
	x402="Enclosure_parameter_not_defined" 
	x403="Enclosure_parameter_re-defined" 
	x404="Enclosure_port_is_input_port" 
	x405="Invalid_SAFTE_page_requested" 
	x406="Invalid_SES_page_requested" 
	x407="EPCT_device_description_error" 
	x408="EPCT_device_redefined" 
	x409="EPCT_element_unknown" 
	x40A="EPCT_device_unknown" 
	x40B="EPCT_ID_unknown" 
	x40C="Invalid_enclosure_device" 
	x40D="EPCT_LED_descriptor_redefinition" 
	x40F="Enclosure_device_not_initialized" 
	x410="Temperature_sensor_reading_unknown" 
	x411="Enclosure_not_present" 
	x412="Bad_EPCT_version" 
	x413="Failed_to_create_SEP_object" 
	x414="Too_many_enclosures_cannot_add_more" 
	x415="Failed_to_create_enclosure_object" 
	x416="Invalid_Sep_Command" 
	
	x1000="EC_NEED_CMD_PROCESS" 
	x1001="EC_UDMA_UPGRADE_SKIPPED" 
	x1002="EC_DRIVE_NOT_IN_UDMA" 
	x1003="EC_OFFLINE_TIMER_RUNNING" 
	x1004="EC_BIN_HANDLE_NOT_EMPTY" 
	x1005="EC_BIN_HANDLE_WRONG_OWNER" 
	x1006="EC_CMD_IN_PBUF" 
	x1007="EC_INVALID_DATA_CHKSUM" 
	x1008="EC_LBA_OVERLAP" 
	x1009="EC_SGL_NON_SECTOR_SIZE" 
	x100A="Retry_CMD"
	
	x100B="BT1680_Liberator_Error"
	x100C="BT1680_Liberator_Fail"
	
	x1010="Error_recovery_in_progress" 
	x1011="Error_recovery_complete" 
	x1012="No_LBA_to_repair_sector" 
	x1013="Retry_recovery_step" 
	x1014="Do_error_action" 
	x1015="Degrade_unit" 
	x1016="Sector_repair_was_not_completed" 
	x1017="Command_aborted" 
	x1018="Drive_added" 
	
	x1019="Drive_removed" 
	x101A="Retry_queued_command" 
	x101B="Drive_error" 
	x101C="Non-Dma_Retry_no_recovery" 
	x101D="Drive_removed_no_wait" 
	x1020="Simulate_power_fail" 
	x1021="Simulate_uC_error" 
	
	x1022="Need_to_transition_to_Drive_remove_error" 
	x1023="Simulate_exception_error" 
	x1024="Simulate_illegal_instruction_error" 
	
	x2000="Checksum_of_cache_meta_data_is_bad" 
	x2001="Signature_of_cache_meta_data_is_bad" 
	x2002="Cache_meta_data_is_bad_due_to_bad_parity_link" 
	
	x2100="SATA_NCQ_Error_to_trigger_error_handler" 
	x2101="SAS_Error_to_trigger_error_handler" 
	x2102="Drive_must_be_reset_either_locally_or_via_SMP"
	
	x2FFF="EC_FEATURE_NOT_IMPLEMENTED" 
	
	x3013="Data_integrity_error_in_diagnostic_test" 
	x3014="Undefined_Sub-command_for_diag_test" 
	x3017="Drive_reset_error_thru_Marvell" 
	x3018="Reading_config_space_error" 
	x3019="Read_or_write_memory_space_data_integrity_error" 
	x301A="Pchip_UCbuf_data_integrity_error" 
	x301B="Pchip_Xop_Pool_data_integrity_error" 
	x301C="Pchip_Cmd_Ram_data_integrity_error" 
	x301E="iHandler_was_busy_before_diag_test" 
	x3021="An_unimplemented_method_was_invoked" 
	x3024="Data_lines_shorted_in_Sbuf_RAM" 
	x3025="Data_lines_open_in_Sbuf_RAM" 
	x3026="Addr_line_problem_in_Sbuf_RAM" 
	x3027="Sbuf_RAM_unreadable" 
	x3047="Cant_fill_Sbuf_with_zeros" 
	x3062="iHandler_error_during_xfer_op" 
	x3063="Bad_disk_sequencer_cmd_issued_to_Aport" 
	x3064="Bad_RAM_location" 
	x3065="Bad_Shadowed_RAM_location" 
	x3066="Cant_determine_Sbuf_size" 
	x3067="Pbuf_read_or_write_error" 
	x3068="XOR_error" 
	x3069="No_disk_found_on_requested_Aport" 
	x306A="Interrupt_line_error" 
	x306B="Unable_to_calculate_checksum" 
	x306C="BBU_S0_or_S1_firmware_boundary_error" 
	x306D="Old_method_selected_wrong_value_EC_DQS_FIFO_set_WRONG" 
	x3070="NvRam_read_or_write_test_error" 
	x3071="SpdRom_read_test_error" 
	x3072="Hareware_strap_error" 
	x3073="Clock_Generator_data_integrity_error" 
	
	x3074="Inject_SBUF_ECC_incorrect_param"
	
	x3100="Error_manufacturing_diagnostic_test_failed" 
	x3101="XScale_Core_Processor_Subtest"
	x3102="SRAM_Subtest"
	x3103="TPMI_Subtest"
	x3104="Component_Internal_RAM_Subtest"
	x3105="ASIC_Register_Subtest"
	x3106="PCIX-E_Loopback_Subtest"
	x3107="4.0G_FC_or_3.0G_SAS_Link_Internal_Analog_Loopback_Subtest" 
	x3108="1.0G_FC_or_1.5G_SAS_Link_External_Loopback_Subtest" 
	x3109="2.0G_FC_or_1.5G_SAS_Link_External_Loopback_Subtest" 
	x310A="4.0G_FC_or_3.0G_SAS_Link_External_Loopback_Subtest" 
	x310B="TDMA_Subtest"
	x310C="Concurrent_DMA_Subtest"
	x310D="SDRAM_Subtest"
	
	x310E="Error_manufacturing_diagnostic_test-Coordinated_Reset_failed" 
	x310F="Error_manufacturing_diagnostic_test-Preemptive_Reset_failed" 
	x3110="Error_manufacturing_diagnostic_test-Invalid_Request_failed"
	
	x3111="Hareware_strap_error"
	
	x3112="Dma_completed_Miscompare_error"
	x3113="Dma_completed_error"
	
	x3200="No_RAID_key-s_found"
	x3201="RAID_key_bus_in_use"
	x3202="RAID_key_CRC_error"
	x3203="RAID_key_authentication_failure"
	x3204="RAID_key_contains_data_that_did_not_pass_validation" 
	x3205="Address_requested_is_not_valid_or_page_aligned"
	
	x3300="Invalid_board_id"
	
	x7E00="Error_manufacturing_diagnostic_test_failed" 
	x7E01="XScale_Core_Processor_Subtest"
	x7E02="SRAM_Subtest"
	x7E03="TPMI_Subtest"
	x7E04="Component_Internal_RAM_Subtest"
	x7E05="ASIC_Register_Subtest"
	x7E06="PCIX-E_Loopback_Subtest"
	x7E07="4.0G_FC_or_3.0G_SAS_Link_Internal_Analog_Loopback_Subtest" 
	x7E08="1.0G_FC_or_1.5G_SAS_Link_External_Loopback_Subtest" 
	x7E09="2.0G_FC_or_1.5G_SAS_Link_External_Loopback_Subtest" 
	x7E0A="4.0G_FC_or_3.0G_SAS_Link_External_Loopback_Subtest" 
	x7E0B="TDMA_Subtest"
	x7E0C="Concurrent_DMA_Subtest"
	x7E0D="SDRAM_Subtest"
	x7E0E="Error_manufacturing_diagnostic_test-Coordinated_Reset_failed" 
	x7E0F="Error_manufacturing_diagnostic_test-Preemptive_Reset_failed" 
	x7E10="Error_manufacturing_diagnostic_test-Invalid_Request_failed" 
	x7E11="EDMA_error"
	
	for i in "x0 $x0" "x1 $x1" "x2 $x2" "x3 $x3" "x4 $x4" "x5 $x5" "x6 $x6" "x7 $x7" "x8 $x8" "x9 $x9" "xA $xA" "xB $xB" "xC $xC" "xD $xD" "xE $xE" "xF $xF" "x10 $x10" "x11 $x11" "x12 $x12" "x13 $x13" "x14 $x14" "x15 $x15" "x16 $x16" "x17 $x17" "x18 $x18" "x19 $x19" "x1A $x1A" "x1B $x1B" "x1C $x1C" "x1D $x1D" "x1E $x1E" "x1F $x1F" "x20 $x20" "x21 $x21" "x22 $x22" "x23 $x23" "x24 $x24" "x25 $x25" "x26 $x26" "x27 $x27" "x28 $x28" "x29 $x29" "x2A $x2A" "x2B $x2B" "x2C $x2C" "x2D $x2D" "x2E $x2E" "x2F $x2F" "x30 $x30" "x31 $x31" "x32 $x32" "x33 $x33" "x34 $x34" "x35 $x35" "x36 $x36" "x37 $x37" "x38 $x38" "x39 $x39" "x3A $x3A" "x3B $x3B" "x3C $x3C" "x3D $x3D" "x3E $x3E" "x3F $x3F" "x40 $x40" "x41 $x41" "x42 $x42" "x43 $x43" "x44 $x44" "x45 $x45" "x46 $x46" "x47 $x47" "x48 $x48" "x49 $x49" "x4A $x4A" "x51 $x51" "x60 $x60" "x61 $x61" "x100 $x100" "x101 $x101" "x102 $x102" "x103 $x103" "x104 $x104" "x105 $x105" "x106 $x106" "x107 $x107" "x108 $x108" "x109 $x109" "x10A $x10A" "x10B $x10B" "x10C $x10C" "x10D $x10D" "x10E $x10E" "x10F $x10F" "x110 $x110" "x111 $x111" "x112 $x112" "x113 $x113" "x114 $x114" "x115 $x115" "x116 $x116" "x117 $x117" "x11E $x11E" "x11F $x11F" "x120 $x120" "x121 $x121" "x122 $x122" "x123 $x123" "x124 $x124" "x125 $x125" "x126 $x126" "x127 $x127" "x128 $x128" "x129 $x129" "x12A $x12A" "x12B $x12B" "x12C $x12C" "x12D $x12D" "x12E $x12E" "x12F $x12F" "x130 $x130" "x131 $x131" "x132 $x132" "x133 $x133" "x140 $x140" "x150 $x150" "x151 $x151" "x152 $x152" "x153 $x153" "x160 $x160" "x161 $x161" "x162 $x162" "x170 $x170" "x171 $x171" "x180 $x180" "x181 $x181" "x182 $x182" "x183 $x183" "x184 $x184" "x185 $x185" "x1A0 $x1A0" "x1C0 $x1C0" "x1C1 $x1C1" "x1C2 $x1C2" "x1C3 $x1C3" "x1C4 $x1C4" "x1C5 $x1C5" "x1C6 $x1C6" "x1C7 $x1C7" "x1C8 $x1C8" "x1C9 $x1C9" "x1CA $x1CA" "x1CB $x1CB" "x1CC $x1CC" "x1CD $x1CD" "x1CE $x1CE" "x1D0 $x1D0" "x1D1 $x1D1" "x1D2 $x1D2" "x1D3 $x1D3" "x1D4 $x1D4" "x200 $x200" "x201 $x201" "x202 $x202" "x203 $x203" "x204 $x204" "x205 $x205" "x206 $x206" "x207 $x207" "x208 $x208" "x209 $x209" "x20A $x20A" "x20B $x20B" "x20C $x20C" "x20D $x20D" "x210 $x210" "x211 $x211" "x212 $x212" "x213 $x213" "x214 $x214" "x215 $x215" "x216 $x216" "x217 $x217" "x218 $x218" "x230 $x230" "x231 $x231" "x232 $x232" "x233 $x233" "x234 $x234" "x235 $x235" "x236 $x236" "x240 $x240" "x241 $x241" "x242 $x242" "x243 $x243" "x244 $x244" "x245 $x245" "x246 $x246" "x247 $x247" "x248 $x248" "x24A $x24A" "x24B $x24B" "x24C $x24C" "x250 $x250" "x251 $x251" "x252 $x252" "x253 $x253" "x254 $x254" "x255 $x255" "x256 $x256" "x257 $x257" "x258 $x258" "x259 $x259" "x25A $x25A" "x25B $x25B" "x25C $x25C" "x25D $x25D" "x25E $x25E" "x25F $x25F" "x261 $x261" "x260 $x260" "x270 $x270" "x271 $x271" "x272 $x272" "x280 $x280" "x281 $x281" "x282 $x282" "x283 $x283" "x290 $x290" "x291 $x291" "x293 $x293" "x294 $x294" "x295 $x295" "x296 $x296" "x297 $x297" "x298 $x298" "x299 $x299" "x29A $x29A" "x29B $x29B" "x29C $x29C" "x29D $x29D" "x2A0 $x2A0" "x2A1 $x2A1" "x2A2 $x2A2" "x2A3 $x2A3" "x2A4 $x2A4" "x2A5 $x2A5" "x2A6 $x2A6" "x2A7 $x2A7" "x2A8 $x2A8" "x2A9 $x2A9" "x2AA $x2AA" "x2AB $x2AB" "x2B0 $x2B0" "x2B1 $x2B1" "x2B2 $x2B2" "x2B3 $x2B3" "x2B4 $x2B4" "x2B5 $x2B5" "x2B6 $x2B6" "x2B7 $x2B7" "x2B8 $x2B8" "x2B9 $x2B9" "x2BA $x2BA" "x2BB $x2BB" "x2BC $x2BC" "x2BD $x2BD" "x2BE $x2BE" "x2BF $x2BF" "x2C0 $x2C0" "x2C1 $x2C1" "x2C2 $x2C2" "x2C3 $x2C3" "x2C4 $x2C4" "x2C5 $x2C5" "x2C6 $x2C6" "x2C7 $x2C7" "x2C8 $x2C8" "x2C9 $x2C9" "x2CA $x2CA" "x2CB $x2CB" "x2CC $x2CC" "x2CD $x2CD" "x2CE $x2CE" "x2D0 $x2D0" "x2D1 $x2D1" "x2D2 $x2D2" "x2D3 $x2D3" "x2D4 $x2D4" "x2E0 $x2E0" "x2E1 $x2E1" "x2E4 $x2E4" "x2E5 $x2E5" "x2E6 $x2E6" "x2E7 $x2E7" "x2E8 $x2E8" "x2EA $x2EA" "x2EB $x2EB" "x2F0 $x2F0" "x2F1 $x2F1" "x2F2 $x2F2" "x2F3 $x2F3" "x2F4 $x2F4" "x300 $x300" "x301 $x301" "x302 $x302" "x303 $x303" "x310 $x310" "x311 $x311" "x312 $x312" "x313 $x313" "x314 $x314" "x315 $x315" "x316 $x316" "x317 $x317" "x318 $x318" "x319 $x319" "x31A $x31A" "x31B $x31B" "x31C $x31C" "x320 $x320" "x321 $x321" "x322 $x322" "x323 $x323" "x330 $x330" "x331 $x331" "x332 $x332" "x333 $x333" "x334 $x334" "x335 $x335" "x336 $x336" "x337 $x337" "x338 $x338" "x339 $x339" "x340 $x340" "x341 $x341" "x350 $x350" "x351 $x351" "x352 $x352" "x353 $x353" "x354 $x354" "x380 $x380" "x381 $x381" "x382 $x382" "x383 $x383" "x384 $x384" "x385 $x385" "x386 $x386" "x387 $x387" "x388 $x388" "x389 $x389" "x38A $x38A" "x38B $x38B" "x38C $x38C" "x38D $x38D" "x38E $x38E" "x390 $x390" "x391 $x391" "x392 $x392" "x400 $x400" "x401 $x401" "x402 $x402" "x403 $x403" "x404 $x404" "x405 $x405" "x406 $x406" "x407 $x407" "x408 $x408" "x409 $x409" "x40A $x40A" "x40B $x40B" "x40C $x40C" "x40D $x40D" "x40F $x40F" "x410 $x410" "x411 $x411" "x412 $x412" "x413 $x413" "x414 $x414" "x415 $x415" "x416 $x416" "x1000 $x1000" "x1001 $x1001" "x1002 $x1002" "x1003 $x1003" "x1004 $x1004" "x1005 $x1005" "x1006 $x1006" "x1007 $x1007" "x1008 $x1008" "x1009 $x1009" "x100A $x100A" "x100B $x100B" "x100C $x100C" "x1010 $x1010" "x1011 $x1011" "x1012 $x1012" "x1013 $x1013" "x1014 $x1014" "x1015 $x1015" "x1016 $x1016" "x1017 $x1017" "x1018 $x1018" "x1019 $x1019" "x101A $x101A" "x101B $x101B" "x101C $x101C" "x101D $x101D" "x1020 $x1020" "x1021 $x1021" "x1022 $x1022" "x1023 $x1023" "x1024 $x1024" "x2000 $x2000" "x2001 $x2001" "x2002 $x2002" "x2100 $x2100" "x2101 $x2101" "x2102 $x2102" "x2FFF $x2FFF" "x3013 $x3013" "x3014 $x3014" "x3017 $x3017" "x3018 $x3018" "x3019 $x3019" "x301A $x301A" "x301B $x301B" "x301C $x301C" "x301E $x301E" "x3021 $x3021" "x3024 $x3024" "x3025 $x3025" "x3026 $x3026" "x3027 $x3027" "x3047 $x3047" "x3062 $x3062" "x3063 $x3063" "x3064 $x3064" "x3065 $x3065" "x3066 $x3066" "x3067 $x3067" "x3068 $x3068" "x3069 $x3069" "x306A $x306A" "x306B $x306B" "x306C $x306C" "x306D $x306D" "x3070 $x3070" "x3071 $x3071" "x3072 $x3072" "x3073 $x3073" "x3074 $x3074" "x3100 $x3100" "x3101 $x3101" "x3102 $x3102" "x3103 $x3103" "x3104 $x3104" "x3105 $x3105" "x3106 $x3106" "x3107 $x3107" "x3108 $x3108" "x3109 $x3109" "x310A $x310A" "x310B $x310B" "x310C $x310C" "x310D $x310D" "x310E $x310E" "x310F $x310F" "x3110 $x3110" "x3111 $x3111" "x3112 $x3112" "x3113 $x3113" "x3200 $x3200" "x3201 $x3201" "x3202 $x3202" "x3203 $x3203" "x3204 $x3204" "x3205 $x3205" "x3300 $x3300" "x7E00 $x7E00" "x7E01 $x7E01" "x7E02 $x7E02" "x7E03 $x7E03" "x7E04 $x7E04" "x7E05 $x7E05" "x7E06 $x7E06" "x7E07 $x7E07" "x7E08 $x7E08" "x7E09 $x7E09" "x7E0A $x7E0A" "x7E0B $x7E0B" "x7E0C $x7E0C" "x7E0D $x7E0D" "x7E0E $x7E0E" "x7E0F $x7E0F" "x7E10 $x7E10" "x7E11 $x7E11"; do
	
		set $i
	
		if [ -f ./$fileName/LSI_Products/3ware/3ware_driver_x04_9000_EVENT.txt ]; then
	       		$grep -i error'='0$1"\." ./$fileName/LSI_Products/3ware/3ware_driver_x04_9000_EVENT.txt > ./$fileName/LSI_Products/3ware/3ware_driver_Ext_AEN_Error_$1_$2.txt
	
			if [ ! -s ./$fileName/LSI_Products/3ware/3ware_driver_Ext_AEN_Error_$1_$2.txt ]; then rm ./$fileName/LSI_Products/3ware/3ware_driver_Ext_AEN_Error_$1_$2.txt > /dev/null 2>&1 ; fi
	
		fi
	
	done
	###########################################################################################################################
	# 0x06 Driver Errors from 9.0, 9.4.1.2 & 9.5.1 3w-9xxx.c - Need to create a new section for 3w-sas.c driver, different errors
	###########################################################################################################################
	x0001="Found_unaligned_address_during_AEN_drain"
	x0002="Error_posting_request_sense"
	x0003="No_valid_response_while_draining_AEN_queue"
	x0004="Post_failed_while_reading_AEN_queue"
	x0005="Memory_allocation_failed"
	x0006="Failed_to_allocate_correctly_aligned_memory"
	x0007="Initconnection_failed_while_checking_SRL"
	x000A="Initconnection_base_mode_failed_while_checking_SRL"
	x000B="Incompatible_firmware_on_controller"
	#x000C="Character_ioctl_0xXX_timed_out_resetting_card." # 9.4.1.2
	#x000C="PCI_Parity_Error_clearing" # 9.4.1.2
	x000C="Shared_x000C"
	x000D="PCI_Abort_clearing"
	x000E="Controller_Queue_Error_clearing"
	x0010="Microcontroller_Error_clearing"
	x0011="Failed_to_allocate_memory_for_firmware_flash"
	x0012="No_valid_response_while_flashing_firmware"
	x0013="No_valid_response_during_get_param"
	x0014="No_valid_response_during_hard_reset"
	x0015="No_valid_response_during_init_connection"
	x0016="Command_packet_memory_allocation_failed"
	x0017="Generic_memory_allocation_failed"
	x0018="Event_info_memory_allocation_failed"
	x0019="Found_request_id_that_wasnt_pending"
	x001A="Received_a_request_id_that_wasnt_posted"
	x001B="Error_completing_AEN_during_attention_interrupt"
	x001C="Failed_to_map_scatter_gather_list"
	x001D="Failed_to_map_page"
	x001E="Found_unexpected_request_id_while_polling_for_response"
	x001F="Microcontroller_not_ready_during_reset_sequence"
	x0020="Response_queue_empty_failed_during_reset_sequence"
	x0021="Compatibility_check_failed_during_reset_sequence"
	x0022="AEN_drain_failed_during_reset_sequence"
	x0023="Failed_to_set_dma_mask"
	x0024="Failed_to_allocate_memory_for_device_extension"
	x0025="Failed_to_initialize_device_extension"
	x0026="Failed_to_get_mem_region"
	x0027="scsi_add_host_failed"
	x0028="Bad_scsi_host_data"
	x0029="Failed_to_register_character_device"
	x002B="Controller_reset_failed_during_scsi_host_reset"
	#x002C="Command_0xXX_timed_out_resetting_card" # 9.4.1.2
	#x002C="No_device_extension_for_proc_operation" # 9.0
	x002C="Shared_x002C" 
	x002D="Found_unaligned_address_during_execute_scsi"
	x002E="Found_unaligned_sgl_address_during_execute_scsi"
	x002F="Found_unaligned_sgl_address_during_internal_post"
	x0030="Error_requesting_IRQ"
	x0031="Connection_shutdown_failed"
	x0032="Firmware_and_driver_incompatibility_please_upgrade_firmware"
	x0033="Firmware_and_driver_incompatibility_please_upgrade_driver"
	x0034="Failed_to_enable_pci_device"
	x0035="Failed_to_ioremap"
	x0036="Response_queue_large_empty_failed_during_reset_sequence"
	x0037="Character_ioctl_timed_out_resetting_card"
	
	for i in "x0001 $x0001" "x0002 $x0002" "x0003 $x0003" "x0004 $x0004" "x0005 $x0005" "x0006 $x0006" "x0007 $x0007" "x000A $x000A" "x000B $x000B" "x000C $x000C" "x000D $x000D" "x000E $x000E" "x0010 $x0010" "x0011 $x0011" "x0012 $x0012" "x0013 $x0013" "x0014 $x0014" "x0015 $x0015" "x0016 $x0016" "x0017 $x0017" "x0018 $x0018" "x0019 $x0019" "x001A $x001A" "x001B $x001B" "x001C $x001C" "x001D $x001D" "x001E $x001E" "x001F $x001F" "x0020 $x0020" "x0021 $x0021" "x0022 $x0022" "x0023 $x0023" "x0024 $x0024" "x0025 $x0025" "x0026 $x0026" "x0027 $x0027" "x0028 $x0028" "x0029 $x0029" "x002B $x002B" "x002C $x002C" "x002D $x002D" "x002E $x002E" "x002F $x002F" "x0030 $x0030" "x0031 $x0031" "x0032 $x0032" "x0033 $x0033" "x0034 $x0034" "x0035 $x0035" "x0036 $x0036" "x0037 $x0037" ; do
	
		set $i
#Note: Appending to file rather than creating (>> vs >) due to duplicate error codes 0xc & 0x2c.
	
		if [ -f ./$fileName/LSI_Products/3ware/3ware_driver_x06_9000_DRIVER.txt ]; then
		
			$grep -i $1 ./$fileName/LSI_Products/3ware/3ware_driver_x06_9000_DRIVER.txt >> ./$fileName/LSI_Products/3ware/3ware_driver_x06_$1_$2.txt
		
			if [ ! -s ./$fileName/LSI_Products/3ware/3ware_driver_x06_$1_$2.txt ]; then rm ./$fileName/LSI_Products/3ware/3ware_driver_x06_$1_$2.txt > /dev/null 2>&1 ; fi
		fi
		
		if [ -f ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_9000_DRIVER.txt ]; then
		
		       	$grep -i $1 ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_9000_DRIVER.txt >> ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_$1_$2.txt
		
			if [ ! -s ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_$1_$2.txt ]; then rm ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_$1_$2.txt > /dev/null 2>&1 ; fi
		
		fi
	
	done



# MRR - Fixed indentation to here..............



	
	if [ -f ./$fileName/LSI_Products/3ware/3ware_driver_x06_x000C_Shared_x000C.txt ]; then
	
	grep -i "Character ioctl" ./$fileName/LSI_Products/3ware/3ware_driver_x06_x000C_Shared_x000C.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x06_x000C_Character_ioctl_0xXX_timed_out_resetting_card.txt
	
	grep -i "PCI Parity Error" ./$fileName/LSI_Products/3ware/3ware_driver_x06_x000C_Shared_x000C.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x06_x000C_PCI_Parity_Error_clearing.txt
	
	rm ./$fileName/LSI_Products/3ware/3ware_driver_x06_x000C_Shared_x000C.txt
	fi
	
	
	if [ -f ./$fileName/LSI_Products/3ware/3ware_driver_x06_x002C_Shared_x002C.txt ]; then
	
	
	grep -i "resetting card" ./$fileName/LSI_Products/3ware/3ware_driver_x06_x002C_Shared_x002C.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x06_x002C_Command_0xXX_timed_out_resetting_card.txt
	
	grep -i "No device extension" ./$fileName/LSI_Products/3ware/3ware_driver_x06_x002C_Shared_x002C.txt > ./$fileName/LSI_Products/3ware/3ware_driver_x06_x002C_No_device_extension_for_proc_operation.txt
	
	rm ./$fileName/LSI_Products/3ware/3ware_driver_x06_x002C_Shared_x002C.txt
	
	fi
	
	for i in _x002C_Command_0xXX_timed_out_resetting_card.txt _x002C_No_device_extension_for_proc_operation.txt _x000C_Character_ioctl_0xXX_timed_out_resetting_card.txt _x000C_PCI_Parity_Error_clearing.txt; do
	
			if [ ! -s ./$fileName/LSI_Products/3ware/3ware_driver_x06$i ]; then rm ./$fileName/LSI_Products/3ware/3ware_driver_x06$i > /dev/null 2>&1 ; fi
	
	done
	
	if [ -f ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_x000C_Shared_x000C.txt ]; then
	
	grep -i "Character ioctl" ./$fileName/LSI_Products/3ware/3ware_driver_x06_x002C_Shared_x002C.txt > ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_x000C_Character_ioctl_0xXX_timed_out_resetting_card.txt
	
	grep -i "PCI Parity Error" ./$fileName/LSI_Products/3ware/3ware_driver_x06_x002C_Shared_x002C.txt > ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_x000C_PCI_Parity_Error_clearing.txt
	
	rm ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_x000C_Shared_x000C.txt
	fi
	
	
	if [ -f ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_x002C_Shared_x002C.txt ]; then
	
	
	grep -i "resetting card" ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_x002C_Shared_x002C.txt > ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_x002C_Command_0xXX_timed_out_resetting_card.txt
	
	grep -i "No device extension" ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_x002C_Shared_x002C.txt > ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_x002C_No_device_extension_for_proc_operation.txt
	
	rm ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06_x002C_Shared_x002C.txt
	
	fi
	
	for i in _x002C_Command_0xXX_timed_out_resetting_card.txt _x002C_No_device_extension_for_proc_operation.txt _x000C_Character_ioctl_0xXX_timed_out_resetting_card.txt _x000C_PCI_Parity_Error_clearing.txt; do
	
			if [ ! -s ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06$i ]; then rm ./$fileName/LSI_Products/3ware/OS_Disk_driver_x06$i > /dev/null 2>&1 ; fi
	
	done
	
	###########################################################################################################################
	# MegaRAID Decimal AENs from MR FW event.h & eventmsg.h from Release 6.2 storelib
	###########################################################################################################################
	
	# FreeBSD doesnt report errors in the same format & no MR_monitord support
	if [ "$OS_LSI" != "freebsd" ]; then 
	if [ "$OS_LSI" != "macos" ] ; then
	
		if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
			date '+%H:%M:%S.%N' 
		fi	
		if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
			date '+%H:%M:%S' 
		fi
	echo "Evaluating MegaRAID AENs..."
	echo "This may take over 5 minutes, please be patient..."
	
	
	x0000="Info_000d_MegaRAID_FW_init_started"
	x0001="Info_001d_MegaRAID_FW_version_X"
	x0002="Fatal_002d_Unable_to_recover_cache_data_from_TBBU"
	x0003="Info_003d_Cache_data_recovered_from_TBBU_successfully"
	x0004="Info_004d_config_cleared"
	x0005="Warning_005d_Cluster_down_com_with_peer_lost"
	x0006="Info_006d_Virtual_drive_X_ownership_changed"
	x0007="Info_007d_Alarm_disabled_by_user"
	x0008="Info_008d_Alarm_enabled_by_user"
	x0009="Info_009d_Bkgrnd_init_rate_changed_to_X"
	x000a="Fatal_010d_Ctrl_cache_discarded_due_to_memory-BBU_problems"
	x000b="Fatal_011d_Unable_to_recover_cache_data_due_to_config_mismatch"
	x000c="Info_012d_Cache_data_recovered_successfully"
	x000d="Fatal_013d_Ctrl_cache_discarded_due_to_FW_version_incomp"
	x000e="Info_014d_CC_rate_changed_to_X"
	x000f="Fatal_015d_FW_error_X"
	x0010="Info_016d_Factory_defaults_restored"
	x0011="Info_017d_Flash_downloaded_image_corrupt"
	x0012="Critical_018d_Flash_erase_error"
	x0013="Critical_019d_Flash_timeout_during_erase"
	x0014="Critical_020d_Flash_error"
	x0015="Info_021d_Flashing_image_X"
	x0016="Info_022d_Flash_of_new_FW_images_complete"
	x0017="Critical_023d_Flash_programming_error"
	x0018="Critical_024d_Flash_timeout_during_programming"
	x0019="Critical_025d_Flash_chip_type_unknown"
	x001a="Critical_026d_Flash_command_set_unknown"
	x001b="Critical_027d_Flash_verify_failure"
	x001c="Info_028d_Flush_rate_changed_to_X_seconds"
	x001d="Info_029d_Hibernate_command_received_from_host"
	x001e="Info_030d_Event_log_cleared"
	x001f="Info_031d_Event_log_wrapped"
	x0020="Fatal_032d_Multi-bit_ECC_error_ECAR_X_ELOG_X_X"
	x0021="Warning_033d_Single-bit_ECC_error_ECAR_X_ELOG_X_X"
	x0022="Fatal_034d_Not_enough_Ctrl_memory"
	x0023="Info_035d_Patrol_Read_complete"
	x0024="Info_036d_Patrol_Read_paused"
	x0025="Info_037d_Patrol_Read_Rate_changed_to_X"
	x0026="Info_038d_Patrol_Read_resumed"
	x0027="Info_039d_Patrol_Read_started"
	x0028="Info_040d_Rebuild_rate_changed_to_X"
	x0029="Info_041d_Drive_group_mod_rate_changed_to_X"
	x002a="Info_042d_Shutdown_command_received_from_host"
	x002b="Info_043d_Test_event_X"
	x002c="Info_044d_Time_established_as_X_X_seconds_since_power_on"
	x002d="Info_045d_User_entered_FW_debugger"
	x002e="Warning_046d_Bkgrnd_init_aborted_on_X"
	x002f="Warning_047d_Bkgrnd_init_corrected_medium_error_X_at_X"
	x0030="Info_048d_Bkgrnd_init_completed_on_X"
	x0031="Fatal_049d_Bkgrnd_init_completed_with_uncorrectable_errors"
	x0032="Fatal_050d_Bkgrnd_init_detect_uncorrect_double_medium_errors"
	x0033="Critical_051d_Bkgrnd_init_failed_on_X"
	x0034="Progress_052d_Bkgrnd_init_on_X_is_X"
	x0035="Info_053d_Bkgrnd_init_started_on_X"
	x0036="Info_054d_Policy_change_on_X_from_X_to_X"
	x0037="Obsolete_055d_OBSOLETE"
	x0038="Warning_056d_CC_aborted_on_X"
	x0039="Warning_057d_CC_corrected_medium_error_X_at_X"
	x003a="Info_058d_CC_done_on_X"
	x003b="Info_059d_CC_done_with_corrections_on_X"
	x003c="Fatal_060d_CC_detected_uncorrectable_double_medium_errors"
	x003d="Critical_061d_CC_failed_on_X"
	x003e="Fatal_062d_CC_completed_with_uncorrectable_data_on_X"
	x003f="Warning_063d_CC_found_inconsistent_parity_on_X_at_strip_X"
	x0040="Warning_064d_CC_inconsistency_logging_disabled_too_many"
	x0041="Progress_065d_CC_on_X_is_X"
	x0042="Info_066d_CC_started_on_X"
	x0043="Warning_067d_init_aborted_on_X"
	x0044="Critical_068d_init_failed_on_X"
	x0045="Progress_069d_init_on_X_is_X"
	x0046="Info_070d_Fast_init_started_on_X"
	x0047="Info_071d_Full_init_started_on_X"
	x0048="Info_072d_init_complete_on_X"
	x0049="Info_073d_LD_Properties_updated_to_X_from_X"
	x004a="Info_074d_Drive_group_mod_complete_on_X"
	x004b="Fatal_075d_Drive_group_mod_stopped_due_to_unrecov_errors"
	x004c="Fatal_076d_Recon_detected_uncorrect_double_medium_errors"
	x004d="Progress_077d_Drive_group_mod_on_X_is_X"
	x004e="Info_078d_Drive_group_mod_resumed_on_X"
	x004f="Fatal_079d_Drv_group_mod_resume_failed_due_to_config_mismatch"
	x0050="Info_080d_Modifying_drive_group_started_on_X"
	x0051="Info_081d_State_change_on_X_from_X_to_X"
	x0052="Info_082d_Drive_Clear_aborted_on_X"
	x0053="Critical_083d_Drive_Clear_failed_on_X_Error_X"
	x0054="Progress_084d_Drive_Clear_on_X_is_X"
	x0055="Info_085d_Drive_Clear_started_on_X"
	x0056="Info_086d_Drive_Clear_completed_on_X"
	x0057="Warning_087d_Error_on_X_Error_X"
	x0058="Info_088d_Format_complete_on_X"
	x0059="Info_089d_Format_started_on_X"
	x005a="Critical_090d_Hot_Spare_SMART_polling_failed_on_X_Error_X"
	x005b="Info_091d_Drive_inserted_X"
	x005c="Warning_092d_Drive_X_is_not_supported"
	x005d="Warning_093d_Patrol_Read_corrected_medium_error_on_X_at_X"
	x005e="Progress_094d_Patrol_Read_on_X_is_X"
	x005f="Fatal_095d_Patrol_Read_found_an_uncorrectable_medium_error"
	x0060="Critical_096d_Predictive_failure_CDB_X"
	x0061="Fatal_097d_Patrol_Read_puncturing_bad_block_on_X_at_X"
	x0062="Info_098d_Rebuild_aborted_by_user_on_X"
	x0063="Info_099d_Rebuild_complete_on_X"
	x0064="Info_100d_Rebuild_complete_on_X"
	x0065="Critical_101d_Rebuild_failed_on_X_due_to_source_drive_error"
	x0066="Critical_102d_Rebuild_failed_on_X_due_to_target_drive_error"
	x0067="Progress_103d_Rebuild_on_X_is_X"
	x0068="Info_104d_Rebuild_resumed_on_X"
	x0069="Info_105d_Rebuild_started_on_X"
	x006a="Info_106d_Rebuild_automatically_started_on_X"
	x006b="Critical_107d_Rebuild_stopped_loss_of_cluster_ownership"
	x006c="Fatal_108d_Reassign_write_operation_failed_on_X_at_X"
	x006d="Fatal_109d_Unrecoverable_medium_error_during_rebuild"
	x006e="Info_110d_Corrected_medium_error_during_recovery"
	x006f="Fatal_111d_Unrecoverable_medium_error_during_recovery"
	x0070="Info_112d_Drive_removed_X"
	x0071="Warning_113d_Unexpected_sense_X_CDBX_Sense_X"
	x0072="Info_114d_State_change_on_X_from_X_to_X"
	x0073="Info_115d_State_change_by_user_on_X_from_X_to_X"
	x0074="Warning_116d_Redundant_path_to_X_broken"
	x0075="Info_117d_Redundant_path_to_X_restored"
	x0076="Info_118d_Dedicated_Hot_Spare_Drive_X_no_longer_useful"
	x0077="Critical_119d_SAS_topo_error_Loop_detected"
	x0078="Critical_120d_SAS_topo_error_Unaddressable_device"
	x0079="Critical_121d_SAS_topo_error_Multiple_ports_same_SAS_address"
	x007a="Critical_122d_SAS_topo_error_Expander_error"
	x007b="Critical_123d_SAS_topo_error_SMP_timeout"
	x007c="Critical_124d_SAS_topo_error_Out_of_route_entries"
	x007d="Critical_125d_SAS_topo_error_Index_not_found"
	x007e="Critical_126d_SAS_topo_error_SMP_function_failed"
	x007f="Critical_127d_SAS_topo_error_SMP_CRC_error"
	x0080="Critical_128d_SAS_topo_error_Multiple_subtractive"
	x0081="Critical_129d_SAS_topo_error_Table_to_table"
	x0082="Critical_130d_SAS_topo_error_Multiple_paths"
	x0083="Fatal_131d_Unable_to_access_device_X"
	x0084="Info_132d_Dedicated_Hot_Spare_created_on_X_X"
	x0085="Info_133d_Dedicated_Hot_Spare_X_disabled"
	x0086="Critical_134d_Dedicated_Hot_Spare_X_no_longer_useful"
	x0087="Info_135d_Global_Hot_Spare_created_on_X_X"
	x0088="Info_136d_Global_Hot_Spare_X_disabled"
	x0089="Critical_137d_Global_Hot_Spare_does_not_cover_all_drive_groups"
	x008a="Info_138d_Created_X"
	x008b="Info_139d_Deleted_X"
	x008c="Info_140d_Marking_LD_X_inconsistent"
	x008d="Info_141d_BBU_Present"
	x008e="Warning_142d_BBU_Not_Present"
	x008f="Info_143d_New_BBU_Detected"
	x0090="Info_144d_BBU_has_been_replaced"
	x0091="Critical_145d_BBU_temp_is_high"
	x0092="Warning_146d_BBU_voltage_low"
	x0093="Info_147d_BBU_started_charging"
	x0094="Info_148d_BBU_is_discharging"
	x0095="Info_149d_BBU_temp_is_normal"
	x0096="Fatal_150d_BBU_needs_to_be_replacement_SOH_Bad"
	x0097="Info_151d_BBU_relearn_started"
	x0098="Info_152d_BBU_relearn_in_progress"
	x0099="Info_153d_BBU_relearn_completed"
	x009a="Critical_154d_BBU_relearn_timed_out"
	x009b="Info_155d_BBU_relearn_pending_BBU_is_under_charge"
	x009c="Info_156d_BBU_relearn_postponed"
	x009d="Info_157d_BBU_relearn_will_start_in_4_days"
	x009e="Info_158d_BBU_relearn_will_start_in_2_day"
	x009f="Info_159d_BBU_relearn_will_start_in_1_day"
	x00a0="Info_160d_BBU_relearn_will_start_in_5_hours"
	x00a1="Info_161d_BBU_removed"
	x00a2="Info_162d_Current_capacity_of_the_BBU_is_below_threshold"
	x00a3="Info_163d_Current_capacity_of_the_BBU_is_above_threshold"
	x00a4="Info_164d_Enc_SES_discovered_on_X"
	x00a5="Info_165d_Enc_SAFTE_discovered_on_X"
	x00a6="Critical_166d_Enc_X_com_lost"
	x00a7="Info_167d_Enc_X_com_restored"
	x00a8="Critical_168d_Enc_X_fan_X_failed"
	x00a9="Info_169d_Enc_X_fan_X_inserted"
	x00aa="Critical_170d_Enc_X_fan_X_removed"
	x00ab="Critical_171d_Enc_X_power_supply_X_failed"
	x00ac="Info_172d_Enc_X_power_supply_X_inserted"
	x00ad="Critical_173d_Enc_X_power_supply_X_removed"
	x00ae="Critical_174d_Enc_X_SIM_X_failed"
	x00af="Info_175d_Enc_X_SIM_X_inserted"
	x00b0="Critical_176d_Enc_X_SIM_X_removed"
	x00b1="Warning_177d_Enc_X_temp_sensor_X_below_threshold"
	x00b2="Critical_178d_Enc_X_temp_sensor_X_below_error_threshold"
	x00b3="Warning_179d_Enc_X_temp_sensor_X_above_threshold"
	x00b4="Critical_180d_Enc_X_temp_sensor_X_above_error_threshold"
	x00b5="Critical_181d_Enc_X_shutdown"
	x00b6="Warning_182d_Enc_X_not_supported_too_many_Encs_connected"
	x00b7="Critical_183d_Enc_X_FW_mismatch"
	x00b8="Warning_184d_Enc_X_sensor_X_bad"
	x00b9="Critical_185d_Enc_X_phy_X_bad"
	x00ba="Critical_186d_Enc_X_is_unstable"
	x00bb="Critical_187d_Enc_X_hardware_error"
	x00bc="Critical_188d_Enc_X_not_responding"
	x00bd="Info_189d_SAS-SATA_mixing_not_supported_Drive_disabled"
	x00be="Info_190d_Enc_SES_hotplug_was_detect_but_is_not_supported"
	x00bf="Info_191d_Clustering_enabled"
	x00c0="Info_192d_Clustering_disabled"
	x00c1="Info_193d_Drive_too_small_to_be_used_for_auto-rebuild"
	x00c2="Info_194d_BBU_enabled_changing_WT_VDs_to_WB"
	x00c3="Warning_195d_BBU_disabled_changing_WB_VDs_to_WT"
	x00c4="Warning_196d_Bad_block_table_on_drive_X_is_80pct_full"
	x00c5="Fatal_197d_Bad_block_table_is_full_unable_to_log_block_X"
	x00c6="Info_198d_CC_Aborted_due_to_ownership_loss_on_X"
	x00c7="Info_199d_Bkgrnd_init_BGI_Aborted_Due_to_Ownership_Loss"
	x00c8="Critical_200d_BBU-charger_problems_detected_SOH_Bad"
	x00c9="Warning_201d_Single-bit_ECC_error_warn_threshold_exceeded"
	x00ca="Critical_202d_Single-bit_ECC_error_crit_threshold_exceeded"
	x00cb="Critical_203d_Single-bit_ECC_error_further_reporting_disabled"
	x00cc="Critical_204d_Enc_X_Power_supply_X_switched_off"
	x00cd="Info_205d_Enc_X_Power_supply_X_switched_on"
	x00ce="Critical_206d_Enc_X_Power_supply_X_cable_removed"
	x00cf="Info_207d_Enc_X_Power_supply_X_cable_inserted"
	x00d0="Info_208d_Enc_X_Fan_X_returned_to_normal"
	x00d1="Info_209d_BBU_Retention_test_was_initiated_on_previous_boot"
	x00d2="Info_210d_BBU_Retention_test_passed"
	x00d3="Critical_211d_BBU_Retention_test_failed"
	x00d4="Info_212d_NVRAM_Retention_test_initiated_on_previous_boot"
	x00d5="Info_213d_NVRAM_Retention_test_passed"
	x00d6="Critical_214d_NVRAM_Retention_test_failed"
	x00d7="Info_215d_X_test_completed_X_passes_successfully"
	x00d8="Critical_216d_test_FAILED_on_X_pass_Fail_data_errorOffset"
	x00d9="Info_217d_Self_Chk_diagnostics_completed"
	x00da="Info_218d_Foreign_config_detected"
	x00db="Info_219d_Foreign_config_imported"
	x00dc="Info_220d_Foreign_config_cleared"
	x00dd="Warning_221d_NVRAM_is_corrupt_reinitializing"
	x00de="Warning_222d_NVRAM_mismatch_occurred"
	x00df="Warning_223d_SAS_wide_port_X_lost_link_on_PHY_X"
	x00e0="Info_224d_SAS_wide_port_X_restored_link_on_PHY_X"
	x00e1="Warning_225d_SAS_port_PHY_has_exceeded_the_allowed_error_rate"
	x00e2="Warning_226d_Bad_block_reassigned_on_X_at_X_to_X"
	x00e3="Info_227d_Ctrl_Hot_Plug_detected"
	x00e4="Warning_228d_Enc_X_temp_sensor_X_differential_detected"
	x00e5="Info_229d_Drive_test_cannot_start_No_qualifying_drives_found"
	x00e6="Info_230d_Time_duration_provided_not_sufficient_for_self_Chk"
	x00e7="Info_231d_Marked_Missing_for_X_on_drive_group_X_row_X"
	x00e8="Info_232d_Replaced_Missing_as_X_on_drive_group_X_row_X"
	x00e9="Info_233d_Enc_X_temp_X_returned_to_normal"
	x00ea="Info_234d_Enc_X_FW_download_in_progress"
	x00eb="Warning_235d_Enc_X_FW_download_failed"
	x00ec="Warning_236d_X_is_not_a_certified_drive"
	x00ed="Info_237d_Dirty_cache_data_discarded_by_user"
	x00ee="Info_238d_Drives_missing_from_config_at_boot"
	x00ef="Info_239d_VDs_missing_drives_will_go_offline_at_boot"
	x00f0="Info_240d_VDs_missing_at_boot_X"
	x00f1="Info_241d_Previous_config_completely_missing_at_boot"
	x00f2="Info_242d_BBU_charge_complete"
	x00f3="Info_243d_Enc_X_fan_X_speed_changed"
	x00f4="Info_244d_Dedicated_spare_imported_as_global_missing_arrays"
	x00f5="Info_245d_Rebuild_not_possible_SAS-SATA_is_not_supp_in_array"
	x00f6="Info_246d_SEP_has_been_rebooted_Enc_FW_download_unavailable"
	x00f7="Info_247d_Inserted_PD_X_Info_X"
	x00f8="Info_248d_Removed_PD_X_Info_X"
	x00f9="Info_249d_VD_X_is_now_OPTIMAL"
	x00fa="Warning_250d_VD_X_is_now_PARTIALLY_DEGRADED"
	x00fb="Critical_251d_VD_X_is_now_DEGRADED"
	x00fc="Fatal_252d_VD_X_is_now_OFFLINE"
	x00fd="Warning_253d_BBU_requires_reconditioning_init_a_LEARN_cycle"
	x00fe="Warning_254d_VD_X_disabled_RAID-5_not_supported_by_this_RAID_key"
	x00ff="Warning_255d_VD_X_disabled_RAID-6_not_supported_by_this_Ctrl"
	x0100="Warning_256d_VD_X_disabled_SAS_drvs_not_supp_by_this_RAID_key"
	x0101="Warning_257d_PD_missing_X"
	x0102="Warning_258d_Puncturing_of_LBAs_enabled"
	x0103="Warning_259d_Puncturing_of_LBAs_disabled"
	x0104="Critical_260d_Enc_X_EMM_X_not_installed"
	x0105="Info_261d_Package_version_X"
	x0106="Warning_262d_Global_affinity_Hot_Spare_commissioned_in_a_dif_Enc"
	x0107="Warning_263d_Foreign_config_table_overflow"
	x0108="Warning_264d_Partial_foreign_config_imported_PDs_not_imported"
	x0109="Info_265d_Connector_X_is_active"
	x010a="Info_266d_Board_Revision_X"
	x010b="Warning_267d_Command_timeout_on_PD_X_CDBX"
	x010c="Warning_268d_PD_X_reset_Type_X"
	x010d="Warning_269d_VD_bad_block_table_on_X_is_80pct_full"
	x010e="Fatal_270d_VD_bad_block_table_is_full_unable_to_log_block"
	x010f="Fatal_271d_Uncorrectable_medium_error_logged"
	x0110="Info_272d_VD_medium_error_corrected_on_X_at_X"
	x0111="Warning_273d_Bad_block_table_on_PD_X_is_100pct_full"
	x0112="Warning_274d_VD_bad_block_table_on_PD_X_is_100pct_full"
	x0113="Fatal_275d_Ctrl_needs_replacement_IOP_is_faulty"
	x0114="Info_276d_CopyBack_started_on_PD_X_from_PD_X"
	x0115="Info_277d_CopyBack_aborted_on_PD_X_and_src_is_PD_X"
	x0116="Info_278d_CopyBack_complete_on_PD_X_from_PD_X"
	x0117="Progress_279d_CopyBack_on_PD_X_is_X"
	x0118="Info_280d_CopyBack_resumed_on_PD_X_from_X"
	x0119="Info_281d_CopyBack_automatically_started_on_PD_X_from_X"
	x011a="Critical_282d_CopyBack_failed_on_PD_X_due_to_source_X_error"
	x011b="Warning_283d_Early_Power_off_was_unsuccessful"
	x011c="Info_284d_BBU_FRU_is_X"
	x011d="Info_285d_X_FRU_is_X"
	x011e="Info_286d_Ctrl_hardware_revision_ID_X"
	x011f="Warning_287d_Foreign_import_incompatible_config_metadata"
	x0120="Info_288d_Redundant_path_restored_for_PD_X"
	x0121="Warning_289d_Redundant_path_broken_for_PD_X"
	x0122="Info_290d_Redundant_Enc_EMM_X_inserted_for_EMM_X"
	x0123="Info_291d_Redundant_Enc_EMM_X_removed_for_EMM_X"
	x0124="Warning_292d_Patrol_Read_can't_be_started"
	x0125="Info_293d_Copyback_aborted_by_user"
	x0126="Critical_294d_Copyback_aborted_hot_spare_needed_for_rebuild"
	x0127="Warning_295d_Copyback_aborted_PD_required_in_the_array"
	x0128="Fatal_296d_Ctrl_cache_discarded_for_missing_or_offline_VD"
	x0129="Info_297d_Copyback_cannot_be_started_PD_too_small"
	x012a="Info_298d_Copyback_cannot_be_started_PD_not_supported"
	x012b="Info_299d_Microcode_update_started_on_PD_X"
	x012c="Info_300d_Microcode_update_completed_on_PD_X"
	x012d="Warning_301d_Microcode_update_timeout_on_PD_X"
	x012e="Warning_302d_Microcode_update_failed_on_PD_X"
	x012f="Info_303d_Ctrl_properties_changed"
	x0130="Info_304d_Patrol_Read_properties_changed"
	x0131="Info_305d_CC_Schedule_properties_changed"
	x0132="Info_306d_BBU_properties_changed"
	x0133="Warning_307d_Periodic_BBU_Relearn_is_pending_init_manual_learn"
	x0134="Info_308d_Drive_security_key_created"
	x0135="Info_309d_Drive_security_key_backed_up"
	x0136="Info_310d_Drive_security_key_from_escrow_verified"
	x0137="Info_311d_Drive_security_key_changed"
	x0138="Warning_312d_Drive_security_key_re-key_operation_failed"
	x0139="Warning_313d_Drive_security_key_is_invalid"
	x013a="Info_314d_Drive_security_key_destroyed"
	x013b="Warning_315d_Drive_security_key_from_escrow_is_invalid"
	x013c="Info_316d_VD_X_is_now_secured"
	x013d="Warning_317d_VD_X_is_partially_secured"
	x013e="Info_318d_PD_X_security_activated"
	x013f="Info_319d_PD_X_security_disabled"
	x0140="Info_320d_PD_X_is_reprovisioned"
	x0141="Info_321d_PD_X_security_key_changed"
	x0142="Fatal_322d_Security_subsystem_problems_detected_for_PD_X"
	x0143="Fatal_323d_Ctrl_cache_pinned_for_missing_or_offline_VD_X"
	x0144="Fatal_324d_Ctrl_cache_pinned_for_missing_or_offline_VDs_X"
	x0145="Info_325d_Ctrl_cache_discarded_by_user_for_VDs_X"
	x0146="Info_326d_Ctrl_cache_destaged_for_VD_X"
	x0147="Warning_327d_CC_started_on_an_inconsistent_VD_X"
	x0148="Warning_328d_Drive_security_key_failure_cannot_access_config"
	x0149="Warning_329d_Drive_security_passphrase_from_user_is_invalid"
	x014a="Warning_330d_Detected_error_remote_BBU_connector_cable"
	x014b="Info_331d_Power_state_change_on_PD_X_from_X_to_X"
	x014c="Info_332d_Enc_X_element_SES_code_0xX_status_changed"
	x014d="Info_333d_PD_X_rebuild_not_possible_as_HDD-SSD_not_supported"
	x014e="Info_334d_Copyback_cant_start_HDD-SSD_mix_not_supported"
	x014f="Info_335d_VD_bad_block_table_on_X_is_cleared"
	x0150="Caution_336d_Caution_SAS_topo_error_0xX"
	x0151="Info_337d_A_cluster_of_medium-level_errors_were_corrected"
	x0152="Info_338d_Ctrl_requests_a_rescan_of_the_host_bus_adapter"
	x0153="Info_339d_Ctrl_repurposed_and_the_factory_defaults_restored"
	x0154="Info_340d_Drive_security_key_binding_updated"
	x0155="Info_341d_Drive_security_is_in_external_key_management_mode"
	x0156="Warning_342d_Drive_security_failed_to_communicate_with_external_key_manager"
	x0157="Info_343d_X_needs_key_to_be_X_X"
	x0158="Warning_344d_X_secure_failed"
	x0159="Critical_345d_Controller_encountered_a_fatal_error_and_was_reset"
	x015a="Info_346d_Snapshots_enabled_on_X_-Repository_X"
	x015b="Info_347d_Snapshots_disabled_on_X_-Repository_X_by_the_user"
	x015c="Critical_348d_Snapshots_disabled_on_X_-Repository_X_due_to_a_fatal_error"
	x015d="Info_349d_Snapshot_created_on_X_at_X"
	x015e="Info_350d_Snapshot_deleted_on_X_at_X"
	x015f="Info_351d_View_created_at_X_to_a_snapshot_at_X_for_X"
	x0160="Info_352d_"View_at_X_is_deleted_to_snapshot_at_X_for_X""
	x0161="Info_353d_Snapshot_rollback_started_on_X_from_snapshot_at_X"
	x0162="Fatal_354d_Snapshot_rollback_on_X_internally_aborted_for_snapshot_at_X"
	x0163="Info_355d_Snapshot_rollback_on_X_completed_for_snapshot_at_X"
	x0164="Info_356d_Snapshot_rollback_progress_for_snapshot_at_X_on_X_is_X"
	x0165="Warning_357d_Snapshot_space_for_X_in_snapshot_repository_X_is_80percent_full"
	x0166="Critical_358d_Snapshot_space_for_X_in_snapshot_repository_X_is_full"
	x0167="Warning_359d_View_at_X_to_snapshot_at_X_is_80percent_full_on_snapshot_repository_X"
	x0168="Critical_360d_View_at_X_to_snapshot_at_X_is_full_on_snapshot_repository_X"
	x0169="Critical_361d_Snapshot_repository_lost_for_X"
	x016a="Warning_362d_Snapshot_repository_restored_for_X"
	x016b="Critical_363d_Snapshot_encountered_an_unexpected_internal_error-_0xX"
	x016c="Info_364d_Auto_Snapshot_enabled_on_X_-snapshot_repository_X"
	x016d="Info_365d_Auto_Snapshot_disabled_on_X_-snapshot_repository_X"
	x016e="Critical_366d_Configuration_command_could_not_be_committed_to_disk_please_retry"
	x016f="Info_367d_COD_on_X_updated_as_it_was_stale"
	x0170="Warning_368d_Power_state_change_failed_on_X_-from_X_to_X"
	x0171="Warning_369d_X_is_not_available"
	x0172="Info_370d_X_is_available"
	x0173="Info_371d_X_is_used_for_CacheCade_with_capacity_0xX_logical_blocks"
	x0174="Info_372d_X_is_using_CacheCade_X"
	x0175="Info_373d_X_is_no_longer_using_CacheCade_X"
	x0176="Critical_374d_Snapshot_deleted_due_to_resource_constraints_for_X_in_snapshot_repository_X"
	x0177="Warning_375d_Auto_Snapshot_failed_for_X_in_snapshot_repository_X"
	x0178="Warning_376d_Controller_reset_on-board_expander"
	x0179="Warning_377d_CacheCade_-X_capacity_changed_and_is_now_0xX_logical_blocks"
	x017a="Warning_378d_Battery_cannot_initiate_transparent_learn_cycles"
	x017b="Info_379d_Premium_feature_X_key_was_applied_for_-_X"
	x017c="Info_380d_Snapshot_schedule_properties_changed_on_X"
	x017d="Info_381d_"Snapshot_scheduled_action_is_due_on_X""
	x017e="Info_382d_Performance_Metrics-_collection_command_0xX"
	x017f="Info_383d_Premium_feature_X_key_was_transferred_-_X"
	x0180="Info_384d_Premium_feature_serial_number_X"
	x0181="Warning_385d_"Premium_feature_serial_number_mismatched_Key-vault_serial_num_-_X""
	x0182="Warning_386d_Battery_cannot_support_data_retention_for_more_than_X_hours_Please_replace_the_battery"
	x0183="Info_387d_X_power_policy_changed_to_X_-from_X"
	x0184="Warning_388d_X_cannot_transition_to_max_power_savings"
	x0185="Info_389d_Host_driver_is_loaded_and_operational"
	x0186="Info_390d_X_mirror_broken"
	x0187="Info_391d_X_mirror_joined"
	x0188="Warning_392d_X_link_X_failure_in_wide_port"
	x0189="Info_393d_X_link_X_restored_in_wide_port"
	x018a="Info_394d_Memory_module_FRU_is_X"
	x018b="Warning_395d_"Cache-vault_power_pack_is_sub-optimal_Please_replace_the_pack""
	x018c="Warning_396d_Foreign_configuration_auto-import_did_not_import_any_drives"
	x018d="Warning_397d_Cache-vault_microcode_update_required"
	x018e="Warning_398d_CacheCade_-X_capacity_exceeds_maximum_allowed_size_extra_capacity_is_not_used"
	x018f="Warning_399d_LD_-X_protection_information_lost"
	x0190="Info_400d_Diagnostics_passed_for_X"
	x0191="Critical_401d_Diagnostics_failed_for_X"
	x0192="Info_402d_Server_Power_capability_Diagnostic_Test_Started"
	x0193="Info_403d_Drive_Cache_settings_enabled_during_rebuild_for_X"
	x0194="Info_404d_Drive_Cache_settings_restored_after_rebuild_for_X"
	x0195="Info_405d_Drive_X_commissioned_as_Emergency_spare"
	x0196="Warning_406d_Reminder-_Potential_non-optimal_configuration_due_to_drive_X_commissioned_as_emergency_spare"
	x0197="Info_407d_Consistency_Check_suspended_on_X"
	x0198="Info_408d_Consistency_Check_resumed_on_X"
	x0199="Info_409d_Background_Initialization_suspended_on_X"
	x019a="Info_410d_Background_Initialization_resumed_on_X"
	x019b="Info_411d_Reconstruction_suspended_on_X"
	x019c="Info_412d_Rebuild_suspended_on_X"
	x019d="Info_413d_Replace_Drive_suspended_on_X"
	x019e="Info_414d_Reminder-_Consistency_Check_suspended_on_X"
	x019f="Info_415d_Reminder-_Background_Initialization_suspended_on_X"
	x01a0="Info_416d_Reminder-_Reconstruction_suspended_on_X"
	x01a1="Info_417d_Reminder-_Rebuild_suspended_on_X"
	x01a2="Info_418d_Reminder-_Replace_Drive_suspended_on_X"
	x01a3="Info_419d_Reminder-_Patrol_Read_suspended"
	x01a4="Info_420d_Erase_aborted_on_X"
	x01a5="Critical_421d_Erase_failed_on_X_-Error_X02x"
	x01a6="Progress_422d_Erase_progress_on_X_is_X"
	x01a7="Info_423d_Erase_started_on_X"
	x01a8="Info_424d_Erase_completed_on_X"
	x01a9="Info_425d_Erase_aborted_on_X"
	x01aa="Critical_426d_Erase_failed_on_X"
	x01ab="Progress_427d_Erase_progress_on_X_is_X"
	x01ac="Info_428d_Erase_started_on_X"
	x01ad="Info_429d_Erase_complete_on_X"
	x01ae="Warning_430d_Potential_leakage_during_erase_on_X"
	x01af="Warning_431d_Battery_charging_was_suspended_due_to_high_battery_temperature"
	x01b0="Info_432d_NVCache_firmware_update_was_successful"
	x01b1="Warning_433d_NVCache_firmware_update_failed"
	x01b2="Fatal_434d_X_access_blocked_as_cached_data_in_CacheCade_is_unavailable"
	x01b3="Info_435d_"CacheCade_disassociate_started_on_X""
	x01b4="Info_436d_CacheCade_disassociate_completed_on_X"
	x01b5="Critical_437d_CacheCade_disassociate_failed_on_X"
	x01b6="Progress_438d_"CacheCade_disassociate_progress_on_X_is_X""
	x01b7="Info_439d_CacheCade_disassociate_aborted_by_user_on_X"
	x01b8="Info_440d_Link_speed_changed_on_SAS_port_X_and_PHY_X"
	x01b9="Warning_441d_Advanced_Software_Options_was_deactivated_for_-_X"
	x01ba="Info_442d_X_is_now_accessible"
	x01bb="Info_443d_X_is_using_CacheCade"
	x01bc="Info_444d_X_is_no_longer_using_CacheCade"
	x01bd="Warning_445d_Patrol_Read_aborted_on_X"
	x01be="Warning_446d_Transient_error_detected_while_communicating_with_X"
	x01bf="Warning_447d_PI_error_in_cache_for_LD_-X_at_LBA_X"
	x01c0="Info_448d_Flash_downloaded_image_is_not_supported"
	x01c1="Info_449d_BBU_mode_selected_-_X"
	x01c2="Info_450d_Periodic_Battery_Relearn_was_missed_and_rescheduled_to_X"
	x01c3="Info_451d_Controller_reset_requested_by_host"
	x01c4="Info_452d_Controller_reset_requested_by_host_completed"
	x01c5="Warning_453d_L3_cache_error_has_been_detected"
	x01c6="Warning_454d_L2_cache_error_has_been_detected"
	x01c7="Warning_455d_Controller_booted_in_headless_mode_with_errors"
	x01c8="Critical_456d_Controller_booted_to_safe_mode_due_to_critical_errors"
	x01c9="Warning_457d_Warning_Error_during_boot_-_X"
	x01ca="Critical_458d_Critical_Error_during_boot_-_X"
	x01cb="Fatal_459d_Fatal_Error_during_boot_-_X"
	x01cc="Info_460d_Peer_controller_has_joined_HA_domain_-ID-_X"
	x01cd="Info_461d_Peer_controller_has_left_HA_domain_-ID-_X"
	x01ce="Info_462d_X_is_managed_by_peer_controller"
	x01cf="Info_463d_X_is_managed_by_local_controller"
	x01d0="Info_464d_X_is_managed_by_peer_controller"
	x01d1="Info_465d_X_is_managed_by_local_controller"
	x01d2="Warning_466d_X_has_a_conflict_in_HA_domain"
	x01d3="Info_467d_X_access_is_shared"
	x01d4="Info_468d_X_access_is_exclusive"
	x01d5="Info_469d_X_is_incompatible_in_the_HA_domain"
	x01d6="Warning_470d_Peer_controller_is_incompatible"
	x01d7="Info_471d_Controllers_in_the_HA_domain_are_incompatible"
	x01d8="Info_472d_Controller_properties_are_incompatible_between_local_and_peer_controllers"
	x01d9="Warning_473d_FW_versions_do_not_match_in_the_HA_domain"
	x01da="Warning_474d_Advanced_Software_Options_X_do_not_match_in_the_HA_domain"
	x01db="Info_475d_HA_cache_mirror_is_online"
	x01dc="Warning_476d_HA_cache_mirror_is_offline"
	x01dd="Info_477d_X_access_blocked_as_cached_data_from_peer_controller_is_unavailable"
	x01de="Warning_478d_Cache-vault_power_pack_is_not_supported_Please_replace_the_pack"
	x01df="Warning_479d_X_temperature_-X_C_is_above_warning_threshold"
	x01e0="Critical_480d_X_temperature_-X_C_is_above_critical_threshold"
	x01e1="Info_481d_X_temperature_-X_C_is_normal"
	x01e2="Info_482d_X_IOs_are_being_throttled"
	x01e3="Info_483d_X_IOs_are_normal_-No_throttling"
	x01e4="Info_484d_X_has_Xpercent_life_left_Life_left_thresholds_-_warning-Xpercent_critical-Xpercent"
	x01e5="Info_485d_X_life_left_-Xpercent_is_below_optimal_Life_left_thresholds_-_warning-Xpercent_critical-Xpercent"
	x01e6="Info_486d_X_life_left_-Xpercent_is_critical_Life_left_thresholds_-_warning-Xpercent_critical-Xpercent"
	x01e7="Critical_487d_X_failuredevice_locked-up"
	x01e8="Warning_488d_Host_driver_needs_to_be_upgraded_X"
	x01e9="Warning_489d_Direct_communication_with_peer_controllers_was_not_established_Please_check_proper_cable_connections"
	x01ea="Warning_490d_Firmware_image_does_not_contain_signed_component"
	x01eb="Warning_491d_Authentication_failure_of_the_signed_firmware_image"
	x01ec="Info_492d_Setting_X_as_boot_device"
	x01ed="Info_493d_Setting_X_as_boot_device"
	x01ee="Info_494d_The_BBU_temperature_is_changed_to_X_Celsius"
	x01ef="Info_495d_The_controller_temperature_is_changed_to_X_Celsius"
	x01f0="Critical_496d_NVCache_capacity_is_too_less_to_support_data_backup_Write-back_VDs_will_be_converted_to_write-through"
	x01f1="Warning_497d_NVCache_data_backup_capacity_has_decreasedconsider_replacement"
	x01f2="Critical_498d_NVCache_device_failedcannot_support_data_retention"
	x01f3="Info_499d_Boot_Device_resetsetting_target_ID_as_invalid"
	x01f4="Warning_500d_Write_back_Nytro_cache_size_mismatch_between_the_servers_The_Nytro_cache_size_was_adjusted_to_Xld_GB"
	x01f5="Warning_501d_VD_Xld_is_not_shared_between_servers_but_assigned_for_caching_Write_back_Nytro_cache_content_of_the_VD_will_be_mirrored"
	x01f6="Info_502d_Power_X_watts_usage_base_IOs_throttle_started"
	x01f7="Info_503d_Power_base_IOs_throttle_stopped"
	x01f8="Info_504d_Controller_tunable_parameters_changed"
	x01f9="Info_505d_Controller_operating_temperature_within_normal_range_full_operation_restored"
	x01fa="Warning_506d_Controller_temperature_threshold_exceeded_This_may_indicate_inadequate_system_cooling_Switching_to_low_performance_mode"
	x01fb="Info_507d_Controller_supports_HA_modecurrently_functioning_with_HA_feature_set"
	x01fc="Info_508d_Controller_supports_HA_modecurrently_functioning_with_single_controller_feature_set"
	x01fd="Critical_509d_Cache-vault_components_mismatch_Write-back_VDs_will_be_converted_write-through"
	x01fe="Info_510d_Controller_has_entered_into_maintenance_mode_X"
	x01ff="Info_511d_Controller_has_returned_to_normal_mode"
	x0200="Info_512d_Topology_is_in_X_mode"
	x0201="Critical_513d_Cannot_enter_X_mode_because_X_LD_X_would_not_be_supported"
	x0202="Critical_514d_Cannot_enter_X_mode_because_X_PD_X_would_not_be_supported"
	
	for i in "x0000 $x0000" "x0001 $x0001" "x0002 $x0002" "x0003 $x0003" "x0004 $x0004" "x0005 $x0005" "x0006 $x0006" "x0007 $x0007" "x0008 $x0008" "x0009 $x0009" "x0010 $x0010" "x0011 $x0011" "x0012 $x0012" "x0013 $x0013" "x0014 $x0014" "x0015 $x0015" "x0016 $x0016" "x0017 $x0017" "x0018 $x0018" "x0019 $x0019" "x0020 $x0020" "x0021 $x0021" "x0022 $x0022" "x0023 $x0023" "x0024 $x0024" "x0025 $x0025" "x0026 $x0026" "x0027 $x0027" "x0028 $x0028" "x0029 $x0029" "x0030 $x0030" "x0031 $x0031" "x0032 $x0032" "x0033 $x0033" "x0034 $x0034" "x0035 $x0035" "x0036 $x0036" "x0037 $x0037" "x0038 $x0038" "x0039 $x0039" "x0040 $x0040" "x0041 $x0041" "x0042 $x0042" "x0043 $x0043" "x0044 $x0044" "x0045 $x0045" "x0046 $x0046" "x0047 $x0047" "x0048 $x0048" "x0049 $x0049" "x0050 $x0050" "x0051 $x0051" "x0052 $x0052" "x0053 $x0053" "x0054 $x0054" "x0055 $x0055" "x0056 $x0056" "x0057 $x0057" "x0058 $x0058" "x0059 $x0059" "x0060 $x0060" "x0061 $x0061" "x0062 $x0062" "x0063 $x0063" "x0064 $x0064" "x0065 $x0065" "x0066 $x0066" "x0067 $x0067" "x0068 $x0068" "x0069 $x0069" "x0070 $x0070" "x0071 $x0071" "x0072 $x0072" "x0073 $x0073" "x0074 $x0074" "x0075 $x0075" "x0076 $x0076" "x0077 $x0077" "x0078 $x0078" "x0079 $x0079" "x0080 $x0080" "x0081 $x0081" "x0082 $x0082" "x0083 $x0083" "x0084 $x0084" "x0085 $x0085" "x0086 $x0086" "x0087 $x0087" "x0088 $x0088" "x0089 $x0089" "x0090 $x0090" "x0091 $x0091" "x0092 $x0092" "x0093 $x0093" "x0094 $x0094" "x0095 $x0095" "x0096 $x0096" "x0097 $x0097" "x0098 $x0098" "x0099 $x0099" "x0100 $x0100" "x0101 $x0101" "x0102 $x0102" "x0103 $x0103" "x0104 $x0104" "x0105 $x0105" "x0106 $x0106" "x0107 $x0107" "x0108 $x0108" "x0109 $x0109" "x0110 $x0110" "x0111 $x0111" "x0112 $x0112" "x0113 $x0113" "x0114 $x0114" "x0115 $x0115" "x0116 $x0116" "x0117 $x0117" "x0118 $x0118" "x0119 $x0119" "x0120 $x0120" "x0121 $x0121" "x0122 $x0122" "x0123 $x0123" "x0124 $x0124" "x0125 $x0125" "x0126 $x0126" "x0127 $x0127" "x0128 $x0128" "x0129 $x0129" "x0130 $x0130" "x0131 $x0131" "x0132 $x0132" "x0133 $x0133" "x0134 $x0134" "x0135 $x0135" "x0136 $x0136" "x0137 $x0137" "x0138 $x0138" "x0139 $x0139" "x0140 $x0140" "x0141 $x0141" "x0142 $x0142" "x0143 $x0143" "x0144 $x0144" "x0145 $x0145" "x0146 $x0146" "x0147 $x0147" "x0148 $x0148" "x0149 $x0149" "x0150 $x0150" "x0151 $x0151" "x0152 $x0152" "x0153 $x0153" "x0154 $x0154" "x0155 $x0155" "x0156 $x0156" "x0157 $x0157" "x0158 $x0158" "x0159 $x0159" "x0160 $x0160" "x0161 $x0161" "x0162 $x0162" "x0163 $x0163" "x0164 $x0164" "x0165 $x0165" "x0166 $x0166" "x0167 $x0167" "x0168 $x0168" "x0169 $x0169" "x0170 $x0170" "x0171 $x0171" "x0172 $x0172" "x0173 $x0173" "x0174 $x0174" "x0175 $x0175" "x0176 $x0176" "x0177 $x0177" "x0178 $x0178" "x0179 $x0179" "x0180 $x0180" "x0181 $x0181" "x0182 $x0182" "x0183 $x0183" "x0184 $x0184" "x0185 $x0185" "x0186 $x0186" "x0187 $x0187" "x0188 $x0188" "x0189 $x0189" "x0190 $x0190" "x0191 $x0191" "x0192 $x0192" "x0193 $x0193" "x0194 $x0194" "x0195 $x0195" "x0196 $x0196" "x0197 $x0197" "x0198 $x0198" "x0199 $x0199" "x0200 $x0200" "x0201 $x0201" "x0202 $x0202" "x0203 $x0203" "x0204 $x0204" "x0205 $x0205" "x0206 $x0206" "x0207 $x0207" "x0208 $x0208" "x0209 $x0209" "x0210 $x0210" "x0211 $x0211" "x0212 $x0212" "x0213 $x0213" "x0214 $x0214" "x0215 $x0215" "x0216 $x0216" "x0217 $x0217" "x0218 $x0218" "x0219 $x0219" "x0220 $x0220" "x0221 $x0221" "x0222 $x0222" "x0223 $x0223" "x0224 $x0224" "x0225 $x0225" "x0226 $x0226" "x0227 $x0227" "x0228 $x0228" "x0229 $x0229" "x0230 $x0230" "x0231 $x0231" "x0232 $x0232" "x0233 $x0233" "x0234 $x0234" "x0235 $x0235" "x0236 $x0236" "x0237 $x0237" "x0238 $x0238" "x0239 $x0239" "x0240 $x0240" "x0241 $x0241" "x0242 $x0242" "x0243 $x0243" "x0244 $x0244" "x0245 $x0245" "x0246 $x0246" "x0247 $x0247" "x0248 $x0248" "x0249 $x0249" "x0250 $x0250" "x0251 $x0251" "x0252 $x0252" "x0253 $x0253" "x0254 $x0254" "x0255 $x0255" "x0256 $x0256" "x0257 $x0257" "x0258 $x0258" "x0259 $x0259" "x0260 $x0260" "x0261 $x0261" "x0262 $x0262" "x0263 $x0263" "x0264 $x0264" "x0265 $x0265" "x0266 $x0266" "x0267 $x0267" "x0268 $x0268" "x0269 $x0269" "x0270 $x0270" "x0271 $x0271" "x0272 $x0272" "x0273 $x0273" "x0274 $x0274" "x0275 $x0275" "x0276 $x0276" "x0277 $x0277" "x0278 $x0278" "x0279 $x0279" "x0280 $x0280" "x0281 $x0281" "x0282 $x0282" "x0283 $x0283" "x0284 $x0284" "x0285 $x0285" "x0286 $x0286" "x0287 $x0287" "x0288 $x0288" "x0289 $x0289" "x0290 $x0290" "x0291 $x0291" "x0292 $x0292" "x0293 $x0293" "x0294 $x0294" "x0295 $x0295" "x0296 $x0296" "x0297 $x0297" "x0298 $x0298" "x0299 $x0299" "x0300 $x0300" "x0301 $x0301" "x0302 $x0302" "x0303 $x0303" "x0304 $x0304" "x0305 $x0305" "x0306 $x0306" "x0307 $x0307" "x0308 $x0308" "x0309 $x0309" "x0310 $x0310" "x0311 $x0311" "x0312 $x0312" "x0313 $x0313" "x0314 $x0314" "x0315 $x0315" "x0316 $x0316" "x0317 $x0317" "x0318 $x0318" "x0319 $x0319" "x0320 $x0320" "x0321 $x0321" "x0322 $x0322" "x0323 $x0323" "x0324 $x0324" "x0325 $x0325" "x0326 $x0326" "x0327 $x0327" "x0328 $x0328" "x0329 $x0329" "x0330 $x0330" "x0331 $x0331" "x0332 $x0332" "x0333 $x0333" "x0334 $x0334" "x0335 $x0335" "x0336 $x0336" "x0337 $x0337" "x0338 $x0338" "x0339 $x0339" "x0340 $x0340" "x0341 $x0341" "x0342 $x0342" "x0343 $x0343" "x0344 $x0344" "x0345 $x0345" "x0346 $x0346" "x0347 $x0347" "x0348 $x0348" "x0349 $x0349" "x0350 $x0350" "x0351 $x0351" "x0352 $x0352" "x0353 $x0353" "x0354 $x0354" "x0355 $x0355" "x0356 $x0356" "x0357 $x0357" "x0358 $x0358" "x0359 $x0359" "x0360 $x0360" "x0361 $x0361" "x0362 $x0362" "x0363 $x0363" "x0364 $x0364" "x0365 $x0365" "x0366 $x0366" "x0367 $x0367" "x0368 $x0368" "x0369 $x0369" "x0370 $x0370" "x0371 $x0371" "x0372 $x0372" "x0373 $x0373" "x0374 $x0374" "x0375 $x0375" "x0376 $x0376" "x0377 $x0377" "x0378 $x0378" "x0379 $x0379" "x0380 $x0380" "x0381 $x0381" "x0382 $x0382" "x0383 $x0383" "x0384 $x0384" "x0385 $x0385" "x0386 $x0386" "x0387 $x0387" "x0388 $x0388" "x0389 $x0389" "x0390 $x0390" "x0391 $x0391" "x0392 $x0392" "x0393 $x0393" "x0394 $x0394" "x0395 $x0395" "x0396 $x0396" "x0397 $x0397" "x0398 $x0398" "x0399 $x0399" "x0400 $x0400" "x0401 $x0401" "x0402 $x0402" "x0403 $x0403" "x0404 $x0404" "x0405 $x0405" "x0406 $x0406" "x0407 $x0407" "x0408 $x0408" "x0409 $x0409" "x0410 $x0410" "x0411 $x0411" "x0412 $x0412" "x0413 $x0413" "x0414 $x0414" "x0415 $x0415" "x0416 $x0416" "x0417 $x0417" "x0418 $x0418" "x0419 $x0419" "x0420 $x0420" "x0421 $x0421" "x0422 $x0422" "x0423 $x0423" "x0424 $x0424" "x0425 $x0425" "x0426 $x0426" "x0427 $x0427" "x0428 $x0428" "x0429 $x0429" "x0430 $x0430" "x0431 $x0431" "x0432 $x0432" "x0433 $x0433" "x0434 $x0434" "x0435 $x0435" "x0436 $x0436" "x0437 $x0437" "x0438 $x0438" "x0439 $x0439" "x0440 $x0440" "x0441 $x0441" "x0442 $x0442" "x0443 $x0443" "x0444 $x0444" "x0445 $x0445" "x0446 $x0446" "x0447 $x0447" "x0448 $x0448" "x0449 $x0449" "x0450 $x0450" "x0451 $x0451" "x0452 $x0452" "x0453 $x0453" "x0454 $x0454" "x0455 $x0455" "x0456 $x0456" "x0457 $x0457" "x0458 $x0458" "x0459 $x0459" "x0460 $x0460" "x0461 $x0461" "x0462 $x0462" "x0463 $x0463" "x0464 $x0464" "x0465 $x0465" "x0466 $x0466" "x0467 $x0467" "x0468 $x0468" "x0469 $x0469" "x0470 $x0470" "x0471 $x0471" "x0472 $x0472" "x0473 $x0473" "x0474 $x0474" "x0475 $x0475" "x0476 $x0476" "x0477 $x0477" "x0478 $x0478" "x0479 $x0479" "x0480 $x0480" "x0481 $x0481" "x0482 $x0482" "x0483 $x0483" "x0484 $x0484" "x0485 $x0485" "x0486 $x0486" "x0487 $x0487" "x0488 $x0488" "x0489 $x0489" "x0490 $x0490" "x0491 $x0491" "x0492 $x0492" "x0493 $x0493" "x0494 $x0494" "x0495 $x0495" "x0496 $x0496" "x0497 $x0497" "x0498 $x0498" "x0499 $x0499" "x0500 $x0500" "x0501 $x0501" "x0502 $x0502" "x0503 $x0503" "x0504 $x0504" "x0505 $x0505" "x0506 $x0506" "x0507 $x0507" "x0508 $x0508" "x0509 $x0509" "x0510 $x0510" "x0511 $x0511" "x0512 $x0512" "x0513 $x0513" "x0514 $x0514"  ; do	
	set $i
	
	if [ -f ./$fileName/LSI_Products/MegaRAID/megaraid_driver_messages.txt ]; then
	       $grep -i $1 ./$fileName/LSI_Products/MegaRAID/megaraid_driver_messages.txt > ./$fileName/LSI_Products/MegaRAID/AENs/megasas_$1_$2.txt
	
			if [ ! -s ./$fileName/LSI_Products/MegaRAID/AENs/megasas_$1_$2.txt ]; then rm ./$fileName/LSI_Products/MegaRAID/AENs/megasas_$1_$2.txt > /dev/null 2>&1 ; fi
	
	fi
	
	done
	
	# Real error will be flagged by mrmonitord
	if [ -f ./$fileName/LSI_Products/MegaRAID/AENs/megasas_x0079_Critical_121d_SAS_topo_error_Multiple_ports_same_SAS_address.txt ]; then 
	grep -i "same" ./$fileName/LSI_Products/MegaRAID/AENs/megasas_x0079_Critical_121d_SAS_topo_error_Multiple_ports_same_SAS_address.txt > /dev/null 2>&1
		if [ "$?" -ne "0" ]; then
		rm ./$fileName/LSI_Products/MegaRAID/AENs/megasas_x0079_Critical_121d_SAS_topo_error_Multiple_ports_same_SAS_address.txt > /dev/null 2>&1 
		fi
	fi
	
	
	for i in Info Warning Critical Fatal Progress Obsolete ; do
	
		ls ./$fileName/LSI_Products/MegaRAID/AENs | $grep $i > /dev/null 2>&1
		if [ "$?" -eq "0" ]; then
			if [ ! -d ./$fileName/LSI_Products/MegaRAID/AENs/$i ] ; then mkdir ./$fileName/LSI_Products/MegaRAID/AENs/$i ; fi
		fi
	
	done
	
	for i in Info Warning Critical Fatal Progress Obsolete ; do
	
		mv ./$fileName/LSI_Products/MegaRAID/AENs/megasas_x????_$i* ./$fileName/LSI_Products/MegaRAID/AENs/$i/. > /dev/null 2>&1
	
	done
	
	
	
	
	
	###########################################################################################################################
	# MegaRAID Decimal AENs from MR FW event.h & eventmsg.h from Release 6.2 storelib
	###########################################################################################################################
	
	MRMON000="Info_0x0000h_MegaRAID_FW_init_started"
	MRMON001="Info_0x0001h_MegaRAID_FW_version_0x"
	MRMON002="Fatal_0x0002h_Unable_to_recover_cache_data_from_TBBU"
	MRMON003="Info_0x0003h_Cache_data_recovered_from_TBBU_successfully"
	MRMON004="Info_0x0004h_config_cleared"
	MRMON005="Warning_0x0005h_Cluster_down_com_with_peer_lost"
	MRMON006="Info_0x0006h_Virtual_drive_0x_ownership_changed"
	MRMON007="Info_0x0007h_Alarm_disabled_by_user"
	MRMON008="Info_0x0008h_Alarm_enabled_by_user"
	MRMON009="Info_0x0009h_Bkgrnd_init_rate_changed_to_0x"
	MRMON010="Fatal_0x000Ah_Ctrl_cache_discarded_due_to_memory-BBU_problems"
	MRMON011="Fatal_0x000Bh_Unable_to_recover_cache_data_due_to_config_mismatch"
	MRMON012="Info_0x000Ch_Cache_data_recovered_successfully"
	MRMON013="Fatal_0x000Dh_Ctrl_cache_discarded_due_to_FW_version_incomp"
	MRMON014="Info_0x000Eh_CC_rate_changed_to_0x"
	MRMON015="Fatal_0x000Fh_FW_error_0x"
	MRMON016="Info_0x0010h_Factory_defaults_restored"
	MRMON017="Info_0x0011h_Flash_downloaded_image_corrupt"
	MRMON018="Critical_0x0012h_Flash_erase_error"
	MRMON019="Critical_0x0013h_Flash_timeout_during_erase"
	MRMON020="Critical_0x0014h_Flash_error"
	MRMON021="Info_0x0015h_Flashing_image_0x"
	MRMON022="Info_0x0016h_Flash_of_new_FW_images_complete"
	MRMON023="Critical_0x0017h_Flash_programming_error"
	MRMON024="Critical_0x0018h_Flash_timeout_during_programming"
	MRMON025="Critical_0x0019h_Flash_chip_type_unknown"
	MRMON026="Critical_0x001Ah_Flash_command_set_unknown"
	MRMON027="Critical_0x001Bh_Flash_verify_failure"
	MRMON028="Info_0x001Ch_Flush_rate_changed_to_0x_seconds"
	MRMON029="Info_0x001Dh_Hibernate_command_received_from_host"
	MRMON030="Info_0x001Eh_Event_log_cleared"
	MRMON031="Info_0x001Fh_Event_log_wrapped"
	MRMON032="Fatal_0x0020h_Multi-bit_ECC_error_ECAR_0x_ELOG_0x_0x"
	MRMON033="Warning_0x0021h_Single-bit_ECC_error_ECAR_0x_ELOG_0x_0x"
	MRMON034="Fatal_0x0022h_Not_enough_Ctrl_memory"
	MRMON035="Info_0x0023h_Patrol_Read_complete"
	MRMON036="Info_0x0024h_Patrol_Read_paused"
	MRMON037="Info_0x0025h_Patrol_Read_Rate_changed_to_0x"
	MRMON038="Info_0x0026h_Patrol_Read_resumed"
	MRMON039="Info_0x0027h_Patrol_Read_started"
	MRMON040="Info_0x0028h_Rebuild_rate_changed_to_0x"
	MRMON041="Info_0x0029h_Drive_group_mod_rate_changed_to_0x"
	MRMON042="Info_0x002Ah_Shutdown_command_received_from_host"
	MRMON043="Info_0x002Bh_Test_event_0x"
	MRMON044="Info_0x002Ch_Time_established_as_0x_0x_seconds_since_power_on"
	MRMON045="Info_0x002Dh_User_entered_FW_debugger"
	MRMON046="Warning_0x002Eh_Bkgrnd_init_aborted_on_0x"
	MRMON047="Warning_0x002Fh_Bkgrnd_init_corrected_medium_error_0x_at_0x"
	MRMON048="Info_0x0030h_Bkgrnd_init_completed_on_0x"
	MRMON049="Fatal_0x0031h_Bkgrnd_init_completed_with_uncorrectable_errors"
	MRMON050="Fatal_0x0032h_Bkgrnd_init_detect_uncorrect_double_medium_errors"
	MRMON051="Critical_0x0033h_Bkgrnd_init_failed_on_0x"
	MRMON052="Progress_0x0034h_Bkgrnd_init_on_0x_is_0x"
	MRMON053="Info_0x0035h_Bkgrnd_init_started_on_0x"
	MRMON054="Info_0x0036h_Policy_change_on_0x_from_0x_to_0x"
	MRMON055="Obsolete_0x0037h_OBSOLETE"
	MRMON056="Warning_0x0038h_CC_aborted_on_0x"
	MRMON057="Warning_0x0039h_CC_corrected_medium_error_0x_at_0x"
	MRMON058="Info_0x003Ah_CC_done_on_0x"
	MRMON059="Info_0x003Bh_CC_done_with_corrections_on_0x"
	MRMON060="Fatal_0x003Ch_CC_detected_uncorrectable_double_medium_errors"
	MRMON061="Critical_0x003Dh_CC_failed_on_0x"
	MRMON062="Fatal_0x003Eh_CC_completed_with_uncorrectable_data_on_0x"
	MRMON063="Warning_0x003Fh_CC_found_inconsistent_parity_on_0x_at_strip_0x"
	MRMON064="Warning_0x0040h_CC_inconsistency_logging_disabled_too_many"
	MRMON065="Progress_0x0041h_CC_on_0x_is_0x"
	MRMON066="Info_0x0042h_CC_started_on_0x"
	MRMON067="Warning_0x0043h_init_aborted_on_0x"
	MRMON068="Critical_0x0044h_init_failed_on_0x"
	MRMON069="Progress_0x0045h_init_on_0x_is_0x"
	MRMON070="Info_0x0046h_Fast_init_started_on_0x"
	MRMON071="Info_0x0047h_Full_init_started_on_0x"
	MRMON072="Info_0x0048h_init_complete_on_0x"
	MRMON073="Info_0x0049h_LD_Properties_updated_to_0x_from_0x"
	MRMON074="Info_0x004Ah_Drive_group_mod_complete_on_0x"
	MRMON075="Fatal_0x004Bh_Drive_group_mod_stopped_due_to_unrecov_errors"
	MRMON076="Fatal_0x004Ch_Recon_detected_uncorrect_double_medium_errors"
	MRMON077="Progress_0x004Dh_Drive_group_mod_on_0x_is_0x"
	MRMON078="Info_0x004Fh_Drive_group_mod_resumed_on_0x"
	MRMON079="Fatal_0x004Fh_Drv_group_mod_resume_failed_due_to_config_mismatch"
	MRMON080="Info_0x0050h_Modifying_drive_group_started_on_0x"
	MRMON081="Info_0x0051h_State_change_on_0x_from_0x_to_0x"
	MRMON082="Info_0x0052h_Drive_Clear_aborted_on_0x"
	MRMON083="Critical_0x0053h_Drive_Clear_failed_on_0x_Error_0x"
	MRMON084="Progress_0x0054h_Drive_Clear_on_0x_is_0x"
	MRMON085="Info_0x0055h_Drive_Clear_started_on_0x"
	MRMON086="Info_0x0056h_Drive_Clear_completed_on_0x"
	MRMON087="Warning_0x0057h_Error_on_0x_Error_0x"
	MRMON088="Info_0x0058h_Format_complete_on_0x"
	MRMON089="Info_0x0059h_Format_started_on_0x"
	MRMON090="Critical_0x005Ah_Hot_Spare_SMART_polling_failed_on_0x_Error_0x"
	MRMON091="Info_0x005Bh_Drive_inserted_0x"
	MRMON092="Warning_0x005Ch_Drive_0x_is_not_supported"
	MRMON093="Warning_0x005Dh_Patrol_Read_corrected_medium_error_on_0x_at_0x"
	MRMON094="Progress_0x005Eh_Patrol_Read_on_0x_is_0x"
	MRMON095="Fatal_0x005Fh_Patrol_Read_found_an_uncorrectable_medium_error"
	MRMON096="Critical_0x0060h_Predictive_failure_CDB_0x"
	MRMON097="Fatal_0x0061h_Patrol_Read_puncturing_bad_block_on_0x_at_0x"
	MRMON098="Info_0x0062h_Rebuild_aborted_by_user_on_0x"
	MRMON099="Info_0x0063h_Rebuild_complete_on_0x"
	MRMON100="Info_0x0064h_Rebuild_complete_on_0x"
	MRMON101="Critical_0x0065h_Rebuild_failed_on_0x_due_to_source_drive_error"
	MRMON102="Critical_0x0066h_Rebuild_failed_on_0x_due_to_target_drive_error"
	MRMON103="Progress_0x0067h_Rebuild_on_0x_is_0x"
	MRMON104="Info_0x0068h_Rebuild_resumed_on_0x"
	MRMON105="Info_0x0069h_Rebuild_started_on_0x"
	MRMON106="Info_0x006Ah_Rebuild_automatically_started_on_0x"
	MRMON107="Critical_0x006Bh_Rebuild_stopped_loss_of_cluster_ownership"
	MRMON108="Fatal_0x006Ch_Reassign_write_operation_failed_on_0x_at_0x"
	MRMON109="Fatal_0x006Dh_Unrecoverable_medium_error_during_rebuild"
	MRMON110="Info_0x006Eh_Corrected_medium_error_during_recovery"
	MRMON111="Fatal_0x006Fh_Unrecoverable_medium_error_during_recovery"
	MRMON112="Info_0x0070h_Drive_removed_0x"
	MRMON113="Warning_0x0071h_Unexpected_sense_0x_CDBX_Sense_0x"
	MRMON114="Info_0x0072h_State_change_on_0x_from_0x_to_0x"
	MRMON115="Info_0x0073h_State_change_by_user_on_0x_from_0x_to_0x"
	MRMON116="Warning_0x0074h_Redundant_path_to_0x_broken"
	MRMON117="Info_0x0075h_Redundant_path_to_0x_restored"
	MRMON118="Info_0x0076h_Dedicated_Hot_Spare_Drive_0x_no_longer_useful"
	MRMON119="Critical_0x0077h_SAS_topo_error_Loop_detected"
	MRMON120="Critical_0x0078h_SAS_topo_error_Unaddressable_device"
	MRMON121="Critical_0x0079h_SAS_topo_error_Multiple_ports_same_SAS_address"
	MRMON122="Critical_0x007Ah_SAS_topo_error_Expander_error"
	MRMON123="Critical_0x007Bh_SAS_topo_error_SMP_timeout"
	MRMON124="Critical_0x007Ch_SAS_topo_error_Out_of_route_entries"
	MRMON125="Critical_0x007Dh_SAS_topo_error_Index_not_found"
	MRMON126="Critical_0x007Eh_SAS_topo_error_SMP_function_failed"
	MRMON127="Critical_0x007Fh_SAS_topo_error_SMP_CRC_error"
	MRMON128="Critical_0x0080h_SAS_topo_error_Multiple_subtractive"
	MRMON129="Critical_0x0081h_SAS_topo_error_Table_to_table"
	MRMON130="Critical_0x0082h_SAS_topo_error_Multiple_paths"
	MRMON131="Fatal_0x0083h_Unable_to_access_device_0x"
	MRMON132="Info_0x0084h_Dedicated_Hot_Spare_created_on_0x_0x"
	MRMON133="Info_0x0085h_Dedicated_Hot_Spare_0x_disabled"
	MRMON134="Critical_0x0086h_Dedicated_Hot_Spare_0x_no_longer_useful"
	MRMON135="Info_0x0087h_Global_Hot_Spare_created_on_0x_0x"
	MRMON136="Info_0x0088h_Global_Hot_Spare_0x_disabled"
	MRMON137="Critical_0x0089h_Global_Hot_Spare_does_not_cover_all_drive_groups"
	MRMON138="Info_0x008Ah_Created_0x"
	MRMON139="Info_0x008Bh_Deleted_0x"
	MRMON140="Info_0x008Ch_Marking_LD_0x_inconsistent"
	MRMON141="Info_0x008Dh_BBU_Present"
	MRMON142="Warning_0x008Eh_BBU_Not_Present"
	MRMON143="Info_0x008Fh_New_BBU_Detected"
	MRMON144="Info_0x0090h_BBU_has_been_replaced"
	MRMON145="Critical_0x0091h_BBU_temp_is_high"
	MRMON146="Warning_0x0092h_BBU_voltage_low"
	MRMON147="Info_0x0093h_BBU_started_charging"
	MRMON148="Info_0x0094h_BBU_is_discharging"
	MRMON149="Info_0x0095h_BBU_temp_is_normal"
	MRMON150="Fatal_0x0096h_BBU_needs_to_be_replacement_SOH_Bad"
	MRMON151="Info_0x0097h_BBU_relearn_started"
	MRMON152="Info_0x0098h_BBU_relearn_in_progress"
	MRMON153="Info_0x0099h_BBU_relearn_completed"
	MRMON154="Critical_0x009Ah_BBU_relearn_timed_out"
	MRMON155="Info_0x009Bh_BBU_relearn_pending_BBU_is_under_charge"
	MRMON156="Info_0x009Ch_BBU_relearn_postponed"
	MRMON157="Info_0x009Dh_BBU_relearn_will_start_in_4_days"
	MRMON158="Info_0x009Eh_BBU_relearn_will_start_in_2_day"
	MRMON159="Info_0x009Fh_BBU_relearn_will_start_in_1_day"
	MRMON160="Info_0x00A0h_BBU_relearn_will_start_in_5_hours"
	MRMON161="Info_0x00A1h_BBU_removed"
	MRMON162="Info_0x00A2h_Current_capacity_of_the_BBU_is_below_threshold"
	MRMON163="Info_0x00A3h_Current_capacity_of_the_BBU_is_above_threshold"
	MRMON164="Info_0x00A4h_Enc_SES_discovered_on_0x"
	MRMON165="Info_0x00A5h_Enc_SAFTE_discovered_on_0x"
	MRMON166="Critical_0x00A6h_Enc_0x_com_lost"
	MRMON167="Info_0x00A7h_Enc_0x_com_restored"
	MRMON168="Critical_0x00A8h_Enc_0x_fan_0x_failed"
	MRMON169="Info_0x00A9h_Enc_0x_fan_0x_inserted"
	MRMON170="Critical_0x00AAh_Enc_0x_fan_0x_removed"
	MRMON171="Critical_0x00ABh_Enc_0x_power_supply_0x_failed"
	MRMON172="Info_0x00ACh_Enc_0x_power_supply_0x_inserted"
	MRMON173="Critical_0x00ADh_Enc_0x_power_supply_0x_removed"
	MRMON174="Critical_0x00AEh_Enc_0x_SIM_0x_failed"
	MRMON175="Info_0x00AFh_Enc_0x_SIM_0x_inserted"
	MRMON176="Critical_0x00B0h_Enc_0x_SIM_0x_removed"
	MRMON177="Warning_0x00B1h_Enc_0x_temp_sensor_0x_below_threshold"
	MRMON178="Critical_0x00B2h_Enc_0x_temp_sensor_0x_below_error_threshold"
	MRMON179="Warning_0x00B3h_Enc_0x_temp_sensor_0x_above_threshold"
	MRMON180="Critical_0x00B4h_Enc_0x_temp_sensor_0x_above_error_threshold"
	MRMON181="Critical_0x00B5h_Enc_0x_shutdown"
	MRMON182="Warning_0x00B6h_Enc_0x_not_supported_too_many_Encs_connected"
	MRMON183="Critical_0x00B7h_Enc_0x_FW_mismatch"
	MRMON184="Warning_0x00B8h_Enc_0x_sensor_0x_bad"
	MRMON185="Critical_0x00B9h_Enc_0x_phy_0x_bad"
	MRMON186="Critical_0x00BAh_Enc_0x_is_unstable"
	MRMON187="Critical_0x00BBh_Enc_0x_hardware_error"
	MRMON188="Critical_0x00BCh_Enc_0x_not_responding"
	MRMON189="Info_0x00BDh_SAS-SATA_mixing_not_supported_Drive_disabled"
	MRMON190="Info_0x00BEh_Enc_SES_hotplug_was_detect_but_is_not_supported"
	MRMON191="Info_0x00BFh_Clustering_enabled"
	MRMON192="Info_0x00C0h_Clustering_disabled"
	MRMON193="Info_0x00C1h_Drive_too_small_to_be_used_for_auto-rebuild"
	MRMON194="Info_0x00C2h_BBU_enabled_changing_WT_VDs_to_WB"
	MRMON195="Warning_0x00C3h_BBU_disabled_changing_WB_VDs_to_WT"
	MRMON196="Warning_0x00C4h_Bad_block_table_on_drive_0x_is_80pct_full"
	MRMON197="Fatal_0x00C5h_Bad_block_table_is_full_unable_to_log_block_0x"
	MRMON198="Info_0x00C6h_CC_Aborted_due_to_ownership_loss_on_0x"
	MRMON199="Info_0x00C7h_Bkgrnd_init_BGI_Aborted_Due_to_Ownership_Loss"
	MRMON200="Critical_0x00C8h_BBU-charger_problems_detected_SOH_Bad"
	MRMON201="Warning_0x00C9h_Single-bit_ECC_error_warn_threshold_exceeded"
	MRMON202="Critical_0x00CAh_Single-bit_ECC_error_crit_threshold_exceeded"
	MRMON203="Critical_0x00CBh_Single-bit_ECC_error_further_reporting_disabled"
	MRMON204="Critical_0x00CCh_Enc_0x_Power_supply_0x_switched_off"
	MRMON205="Info_0x00CDh_Enc_0x_Power_supply_0x_switched_on"
	MRMON206="Critical_0x00CEh_Enc_0x_Power_supply_0x_cable_removed"
	MRMON207="Info_0x00CFh_Enc_0x_Power_supply_0x_cable_inserted"
	MRMON208="Info_0x00D0h_Enc_0x_Fan_0x_returned_to_normal"
	MRMON209="Info_0x00D1h_BBU_Retention_test_was_initiated_on_previous_boot"
	MRMON210="Info_0x00D2h_BBU_Retention_test_passed"
	MRMON211="Critical_0x00D3h_BBU_Retention_test_failed"
	MRMON212="Info_0x00D4h_NVRAM_Retention_test_initiated_on_previous_boot"
	MRMON213="Info_0x00D5h_NVRAM_Retention_test_passed"
	MRMON214="Critical_0x00D6h_NVRAM_Retention_test_failed"
	MRMON215="Info_0x00D7h_X_test_completed_0x_passes_successfully"
	MRMON216="Critical_0x00D8h_test_FAILED_on_0x_pass_Fail_data_errorOffset"
	MRMON217="Info_0x00D9h_Self_Chk_diagnostics_completed"
	MRMON218="Info_0x00DAh_Foreign_config_detected"
	MRMON219="Info_0x00DBh_Foreign_config_imported"
	MRMON220="Info_0x00DCh_Foreign_config_cleared"
	MRMON221="Warning_0x00DDh_NVRAM_is_corrupt_reinitializing"
	MRMON222="Warning_0x00DEh_NVRAM_mismatch_occurred"
	MRMON223="Warning_0x00DFh_SAS_wide_port_0x_lost_link_on_PHY_0x"
	MRMON224="Info_0x00E0h_SAS_wide_port_0x_restored_link_on_PHY_0x"
	MRMON225="Warning_0x00E1h_SAS_port_PHY_has_exceeded_the_allowed_error_rate"
	MRMON226="Warning_0x00E2h_Bad_block_reassigned_on_0x_at_0x_to_0x"
	MRMON227="Info_0x00E3h_Ctrl_Hot_Plug_detected"
	MRMON228="Warning_0x00E4h_Enc_0x_temp_sensor_0x_differential_detected"
	MRMON229="Info_0x00E5h_Drive_test_cannot_start_No_qualifying_drives_found"
	MRMON230="Info_0x00Eh_Time_duration_provided_not_sufficient_for_self_Chk"
	MRMON231="Info_0x00E7h_Marked_Missing_for_0x_on_drive_group_0x_row_0x"
	MRMON232="Info_0x00E8h_Replaced_Missing_as_0x_on_drive_group_0x_row_0x"
	MRMON233="Info_0x00E9h_Enc_0x_temp_0x_returned_to_normal"
	MRMON234="Info_0x00EAh_Enc_0x_FW_download_in_progress"
	MRMON235="Warning_0x00EBh_Enc_0x_FW_download_failed"
	MRMON236="Warning_0x00ECh_X_is_not_a_certified_drive"
	MRMON237="Info_0x00EDh_Dirty_cache_data_discarded_by_user"
	MRMON238="Info_0x00EEh_Drives_missing_from_config_at_boot"
	MRMON239="Info_0x00EFh_VDs_missing_drives_will_go_offline_at_boot"
	MRMON240="Info_0x00F0h_VDs_missing_at_boot_0x"
	MRMON241="Info_0x00F1h_Previous_config_completely_missing_at_boot"
	MRMON242="Info_0x00F2h_BBU_charge_complete"
	MRMON243="Info_0x00F3h_Enc_0x_fan_0x_speed_changed"
	MRMON244="Info_0x00F4h_Dedicated_spare_imported_as_global_missing_arrays"
	MRMON245="Info_0x00F5h_Rebuild_not_possible_SAS-SATA_is_not_supp_in_array"
	MRMON246="Info_0x00F6h_SEP_has_been_rebooted_Enc_FW_download_unavailable"
	MRMON247="Info_0x00F7_Inserted_PD_0x_Infoh_X"
	MRMON248="Info_0x00F8_Removed_PD_0x_Infoh_X"
	MRMON249="Info_0x00F9h_VD_0x_is_now_OPTIMAL"
	MRMON250="Warning_0x00FAh_VD_0x_is_now_PARTIALLY_DEGRADED"
	MRMON251="Critical_0x00FBh_VD_0x_is_now_DEGRADED"
	MRMON252="Fatal_0x00FCh_VD_0x_is_now_OFFLINE"
	MRMON253="Warning_0x00FDh_BBU_requires_reconditioning_init_a_LEARN_cycle"
	MRMON254="Warning_0x00FEh_VD_0x_disabled_RAID-5_not_supported_by_this_RAID_key"
	MRMON255="Warning_0x00FFh_VD_0x_disabled_RAID-6_not_supported_by_this_Ctrl"
	MRMON256="Warning_0x0100h_VD_0x_disabled_SAS_drvs_not_supp_by_this_RAID_key"
	MRMON257="Warning_0x0101h_PD_missing_0x"
	MRMON258="Warning_0x0102h_Puncturing_of_LBAs_enabled"
	MRMON259="Warning_0x0103h_Puncturing_of_LBAs_disabled"
	MRMON260="Critical_0x0104h_Enc_0x_EMM_0x_not_installed"
	MRMON261="Info_0x0105h_Package_version_0x"
	MRMON262="Warning_0x0106h_Global_affinity_Hot_Spare_commissioned_in_a_dif_Enc"
	MRMON263="Warning_0x0107h_Foreign_config_table_overflow"
	MRMON264="Warning_0x0108h_Partial_foreign_config_imported_PDs_not_imported"
	MRMON265="Info_0x0109h_Connector_0x_is_active"
	MRMON266="Info_0x010Ah_Board_Revision_0x"
	MRMON267="Warning_0x010Bh_Command_timeout_on_PD_0x_CDBX"
	MRMON268="Warning_0x010Ch_PD_0x_reset_Type_0x"
	MRMON269="Warning_0x010Dh_VD_bad_block_table_on_0x_is_80pct_full"
	MRMON270="Fatal_0x010Eh_VD_bad_block_table_is_full_unable_to_log_block"
	MRMON271="Fatal_0x010Fh_Uncorrectable_medium_error_logged"
	MRMON272="Info_0x0110h_VD_medium_error_corrected_on_0x_at_0x"
	MRMON273="Warning_0x0111h_Bad_block_table_on_PD_0x_is_100pct_full"
	MRMON274="Warning_0x0112h_VD_bad_block_table_on_PD_0x_is_100pct_full"
	MRMON275="Fatal_0x0113h_Ctrl_needs_replacement_IOP_is_faulty"
	MRMON276="Info_0x0114h_CopyBack_started_on_PD_0x_from_PD_0x"
	MRMON277="Info_0x0115h_CopyBack_aborted_on_PD_0x_and_src_is_PD_0x"
	MRMON278="Info_0x0116h_CopyBack_complete_on_PD_0x_from_PD_0x"
	MRMON279="Progress_0x0117h_CopyBack_on_PD_0x_is_0x"
	MRMON280="Info_0x0118h_CopyBack_resumed_on_PD_0x_from_0x"
	MRMON281="Info_0x0119h_CopyBack_automatically_started_on_PD_0x_from_0x"
	MRMON282="Critical_0x011Ah_CopyBack_failed_on_PD_0x_due_to_source_0x_error"
	MRMON283="Warning_0x011Bh_Early_Power_off_was_unsuccessful"
	MRMON284="Info_0x011Ch_BBU_FRU_is_0x"
	MRMON285="Info_0x011Dh_X_FRU_is_0x"
	MRMON286="Info_0x011Eh_Ctrl_hardware_revision_ID_0x"
	MRMON287="Warning_0x011Fh_Foreign_import_incompatible_config_metadata"
	MRMON288="Info_0x0120h_Redundant_path_restored_for_PD_0x"
	MRMON289="Warning_0x0121h_Redundant_path_broken_for_PD_0x"
	MRMON290="Info_0x0122h_Redundant_Enc_EMM_0x_inserted_for_EMM_0x"
	MRMON291="Info_0x0123h_Redundant_Enc_EMM_0x_removed_for_EMM_0x"
	MRMON292="Warning_0x0124h_Patrol_Read_can't_be_started"
	MRMON293="Info_0x0125h_Copyback_aborted_by_user"
	MRMON294="Critical_0x0126h_Copyback_aborted_hot_spare_needed_for_rebuild"
	MRMON295="Warning_0x0127h_Copyback_aborted_PD_required_in_the_array"
	MRMON296="Fatal_0x0128h_Ctrl_cache_discarded_for_missing_or_offline_VD"
	MRMON297="Info_0x0129h_Copyback_cannot_be_started_PD_too_small"
	MRMON298="Info_0x012Ah_Copyback_cannot_be_started_PD_not_supported"
	MRMON299="Info_0x012Bh_Microcode_update_started_on_PD_0x"
	MRMON300="Info_0x012Ch_Microcode_update_completed_on_PD_0x"
	MRMON301="Warning_0x012Dh_Microcode_update_timeout_on_PD_0x"
	MRMON302="Warning_0x012Eh_Microcode_update_failed_on_PD_0x"
	MRMON303="Info_0x012Fh_Ctrl_properties_changed"
	MRMON304="Info_0x0130h_Patrol_Read_properties_changed"
	MRMON305="Info_0x0131h_CC_Schedule_properties_changed"
	MRMON306="Info_0x0132h_BBU_properties_changed"
	MRMON307="Warning_0x0133h_Periodic_BBU_Relearn_is_pending_init_manual_learn"
	MRMON308="Info_0x0134h_Drive_security_key_created"
	MRMON309="Info_0x0135h_Drive_security_key_backed_up"
	MRMON310="Info_0x0136h_Drive_security_key_from_escrow_verified"
	MRMON311="Info_0x0137h_Drive_security_key_changed"
	MRMON312="Warning_0x0138h_Drive_security_key_re-key_operation_failed"
	MRMON313="Warning_0x0139h_Drive_security_key_is_invalid"
	MRMON314="Info_0x013Ah_Drive_security_key_destroyed"
	MRMON315="Warning_0x013Bh_Drive_security_key_from_escrow_is_invalid"
	MRMON316="Info_0x013Ch_VD_0x_is_now_secured"
	MRMON317="Warning_0x013Dh_VD_0x_is_partially_secured"
	MRMON318="Info_0x013Eh_PD_0x_security_activated"
	MRMON319="Info_0x013Fh_PD_0x_security_disabled"
	MRMON320="Info_0x0140h_PD_0x_is_reprovisioned"
	MRMON321="Info_0x0141h_PD_0x_security_key_changed"
	MRMON322="Fatal_0x0142h_Security_subsystem_problems_detected_for_PD_0x"
	MRMON323="Fatal_0x0143h_Ctrl_cache_pinned_for_missing_or_offline_VD_0x"
	MRMON324="Fatal_0x0144h_Ctrl_cache_pinned_for_missing_or_offline_VDs_0x"
	MRMON325="Info_0x0145h_Ctrl_cache_discarded_by_user_for_VDs_0x"
	MRMON326="Info_0x0146h_Ctrl_cache_destaged_for_VD_0x"
	MRMON327="Warning_0x0147h_CC_started_on_an_inconsistent_VD_0x"
	MRMON328="Warning_0x0148h_Drive_security_key_failure_cannot_access_config"
	MRMON329="Warning_0x0149h_Drive_security_passphrase_from_user_is_invalid"
	MRMON330="Warning_0x014Ah_Detected_error_remote_BBU_connector_cable"
	MRMON331="Info_0x014Bh_Power_state_change_on_PD_0x_from_0x_to_0x"
	MRMON332="Info_0x014Ch_Enc_0x_element_SES_code_0xX_status_changed"
	MRMON333="Info_0x014Dh_PD_0x_rebuild_not_possible_as_HDD-SSD_not_supported"
	MRMON334="Info_0x014Eh_Copyback_cant_start_HDD-SSD_mix_not_supported"
	MRMON335="Info_0x014Fh_VD_bad_block_table_on_0x_is_cleared"
	MRMON336="Caution_0x0150h_Caution_SAS_topo_error_0xX"
	MRMON337="Info_0x0151h_A_cluster_of_medium-level_errors_were_corrected"
	MRMON338="Info_0x0152h_Ctrl_requests_a_rescan_of_the_host_bus_adapter"
	MRMON339="Info_0x0153h_Ctrl_repurposed_and_the_factory_defaults_restored"
	MRMON340="Info_0x0154h_Drive_security_key_binding_updated"
	MRMON341="Info_0x0155h_Drive_security_is_in_external_key_management_mode"
	MRMON342="Warning_0x0156h_Drive_security_failed_to_communicate_with_external_key_manager"
	MRMON343="Info_0x0157h_X_needs_key_to_be_X_X"
	MRMON344="Warning_0x0158h_X_secure_failed"
	MRMON345="Critical_0x0159h_Controller_encountered_a_fatal_error_and_was_reset"
	MRMON346="Info_0x015ah_Snapshots_enabled_on_X_-Repository_X"
	MRMON347="Info_0x015bh_Snapshots_disabled_on_X_-Repository_X_by_the_user"
	MRMON348="Critical_0x015ch_Snapshots_disabled_on_X_-Repository_X_due_to_a_fatal_error"
	MRMON349="Info_0x015dh_Snapshot_created_on_X_at_X"
	MRMON350="Info_0x015eh_Snapshot_deleted_on_X_at_X"
	MRMON351="Info_0x015fh_View_created_at_X_to_a_snapshot_at_X_for_X"
	MRMON352="Info_0x0160h_View_at_X_is_deleted_to_snapshot_at X_for_X"
	MRMON353="Info_0x0161h_Snapshot_rollback_started_on_X_from_snapshot_at_X"
	MRMON354="Fatal_0x0162h_Snapshot_rollback_on_X_internally_aborted_for_snapshot_at_X"
	MRMON355="Info_0x0163h_Snapshot_rollback_on_X_completed_for_snapshot_at_X"
	MRMON356="Info_0x0164h_Snapshot_rollback_progress_for_snapshot_at_X_on_X_is_X"
	MRMON357="Warning_0x0165h_Snapshot_space_for_X_in_snapshot_repository_X_is_80percent_full"
	MRMON358="Critical_0x0166h_Snapshot_space_for_X_in_snapshot_repository_X_is_full"
	MRMON359="Warning_0x0167h_View_at_X_to_snapshot_at_X_is_80percent_full_on_snapshot_repository_X"
	MRMON360="Critical_0x0168h_View_at_X_to_snapshot_at_X_is_full_on_snapshot_repository_X"
	MRMON361="Critical_0x0169h_Snapshot_repository_lost_for_X"
	MRMON362="Warning_0x016ah_Snapshot_repository_restored_for_X"
	MRMON363="Critical_0x016bh_Snapshot_encountered_an_unexpected_internal_error-_0xX"
	MRMON364="Info_0x016ch_Auto_Snapshot_enabled_on_X_-snapshot_repository_X"
	MRMON365="Info_0x016dh_Auto_Snapshot_disabled_on_X_-snapshot_repository_X"
	MRMON366="Critical_0x016eh_Configuration_command_could_not_be_committed_to_disk_please_retry"
	MRMON367="Info_0x016fh_COD_on_X_updated_as_it_was_stale"
	MRMON368="Warning_0x0170h_Power_state_change_failed_on_X_-from_X_to_X"
	MRMON369="Warning_0x0171h_X_is_not_available"
	MRMON370="Info_0x0172h_X_is_available"
	MRMON371="Info_0x0173h_X_is_used_for_CacheCade_with_capacity_0xX_logical_blocks"
	MRMON372="Info_0x0174h_X_is_using_CacheCade_X"
	MRMON373="Info_0x0175h_X_is_no_longer_using_CacheCade_X"
	MRMON374="Critical_0x0176h_Snapshot_deleted_due_to_resource_constraints_for_X_in_snapshot_repository_X"
	MRMON375="Warning_0x0177h_Auto_Snapshot_failed_for_X_in_snapshot_repository_X"
	MRMON376="Warning_0x0178h_Controller_reset_on-board_expander"
	MRMON377="Warning_0x0179h_CacheCade_-X_capacity_changed_and_is_now_0xX_logical_blocks"
	MRMON378="Warning_0x017ah_Battery_cannot_initiate_transparent_learn_cycles"
	MRMON379="Info_0x017bh_Premium_feature_X_key_was_applied_for_-_X"
	MRMON380="Info_0x017ch_Snapshot_schedule_properties_changed_on_X"
	MRMON381="Info_0x017dh_Snapshot_scheduled_action_is_due_on X"
	MRMON382="Info_0x017eh_Performance_Metrics-_collection_command_0xX"
	MRMON383="Info_0x017fh_Premium_feature_X_key_was_transferred_-_X"
	MRMON384="Info_0x0180h_Premium_feature_serial_number_X"
	MRMON385="Warning_0x0181h_Premium_feature_serial_number_mismatched_Key-vault_serial_num_-X"
	MRMON386="Warning_0x0182h_Battery_cannot_support_data_retention_for_more_than_X_hours_Please_replace_the_battery"
	MRMON387="Info_0x0183h_X_power_policy_changed_to_X_-from_X"
	MRMON388="Warning_0x0184h_X_cannot_transition_to_max_power_savings"
	MRMON389="Info_0x0185h_Host_driver_is_loaded_and_operational"
	MRMON390="Info_0x0186h_X_mirror_broken"
	MRMON391="Info_0x0187h_X_mirror_joined"
	MRMON392="Warning_0x0188h_X_link_X_failure_in_wide_port"
	MRMON393="Info_0x0189h_X_link_X_restored_in_wide_port"
	MRMON394="Info_0x018ah_Memory_module_FRU_is_X"
	MRMON395="Warning_0x018bh_Cache-vault_power_pack_is sub-optimal_Please_replace_the_pack"
	MRMON396="Warning_0x018ch_Foreign_configuration_auto-import_did_not_import_any_drives"
	MRMON397="Warning_0x018dh_Cache-vault_microcode_update_required"
	MRMON398="Warning_0x018eh_CacheCade_-X_capacity_exceeds_maximum_allowed_size_extra_capacity_is_not_used"
	MRMON399="Warning_0x018fh_LD_-X_protection_information_lost"
	MRMON400="Info_0x0190h_Diagnostics_passed_for_X"
	MRMON401="Critical_0x0191h_Diagnostics_failed_for_X"
	MRMON402="Info_0x0192h_Server_Power_capability_Diagnostic_Test_Started"
	MRMON403="Info_0x0193h_Drive_Cache_settings_enabled_during_rebuild_for_X"
	MRMON404="Info_0x0194h_Drive_Cache_settings_restored_after_rebuild_for_X"
	MRMON405="Info_0x0195h_Drive_X_commissioned_as_Emergency_spare"
	MRMON406="Warning_0x0196h_Reminder-_Potential_non-optimal_configuration_due_to_drive_X_commissioned_as_emergency_spare"
	MRMON407="Info_0x0197h_Consistency_Check_suspended_on_X"
	MRMON408="Info_0x0198h_Consistency_Check_resumed_on_X"
	MRMON409="Info_0x0199h_Background_Initialization_suspended_on_X"
	MRMON410="Info_0x019ah_Background_Initialization_resumed_on_X"
	MRMON411="Info_0x019bh_Reconstruction_suspended_on_X"
	MRMON412="Info_0x019ch_Rebuild_suspended_on_X"
	MRMON413="Info_0x019dh_Replace_Drive_suspended_on_X"
	MRMON414="Info_0x019eh_Reminder-_Consistency_Check_suspended_on_X"
	MRMON415="Info_0x019fh_Reminder-_Background_Initialization_suspended_on_X"
	MRMON416="Info_0x01a0h_Reminder-_Reconstruction_suspended_on_X"
	MRMON417="Info_0x01a1h_Reminder-_Rebuild_suspended_on_X"
	MRMON418="Info_0x01a2h_Reminder-_Replace_Drive_suspended_on_X"
	MRMON419="Info_0x01a3h_Reminder-_Patrol_Read_suspended"
	MRMON420="Info_0x01a4h_Erase_aborted_on_X"
	MRMON421="Critical_0x01a5h_Erase_failed_on_X_-Error_X02x"
	MRMON422="Progress_0x01a6h_Erase_progress_on_X_is_X"
	MRMON423="Info_0x01a7h_Erase_started_on_X"
	MRMON424="Info_0x01a8h_Erase_completed_on_X"
	MRMON425="Info_0x01a9h_Erase_aborted_on_X"
	MRMON426="Critical_0x01aah_Erase_failed_on_X"
	MRMON427="Progress_0x01abh_Erase_progress_on_X_is_X"
	MRMON428="Info_0x01ach_Erase_started_on_X"
	MRMON429="Info_0x01adh_Erase_complete_on_X"
	MRMON430="Warning_0x01aeh_Potential_leakage_during_erase_on_X"
	MRMON431="Warning_0x01afh_Battery_charging_was_suspended_due_to_high_battery_temperature"
	MRMON432="Info_0x01b0h_NVCache_firmware_update_was_successful"
	MRMON433="Warning_0x01b1h_NVCache_firmware_update_failed"
	MRMON434="Fatal_0x01b2h_X_access_blocked_as_cached_data_in_CacheCade_is_unavailable "
	MRMON435="Info_0x01b3h_CacheCade_disassociate_started_on_X"
	MRMON436="Info_0x01b4h_CacheCade_disassociate_completed_on_X"
	MRMON437="Critical_0x01b5h_CacheCade_disassociate_failed_on_X"
	MRMON438="Progress_0x01b6h_CacheCade_disassociate_progress_on_X_is_X"
	MRMON439="Info_0x01b7h_CacheCade_disassociate_aborted_by_user_on_X"
	MRMON440="Info_0x01b8h_Link_speed_changed_on_SAS_port_X_and_PHY_X"
	MRMON441="Warning_0x01b9h_Advanced_Software_Options_was_deactivated_for_-_X"
	MRMON442="Info_0x01bah_X_is_now_accessible"
	MRMON443="Info_0x01bbh_X_is_using_CacheCade"
	MRMON444="Info_0x01bch_X_is_no_longer_using_CacheCade"
	MRMON445="Warning_0x01bdh_Patrol_Read_aborted_on_X"
	MRMON446="Warning_0x01beh_Transient_error_detected_while_communicating_with_X"
	MRMON447="Warning_0x01bfh_PI_error_in_cache_for_LD_-X_at_LBA_X"
	MRMON448="Info_0x01c0h_Flash_downloaded_image_is_not_supported"
	MRMON449="Info_0x01c1h_BBU_mode_selected_-_X"
	MRMON450="Info_0x01c2h_Periodic_Battery_Relearn_was_missed_and_rescheduled_to_X"
	MRMON451="Info_0x01c3h_Controller_reset_requested_by_host"
	MRMON452="Info_0x01c4h_Controller_reset_requested_by_host_completed"
	MRMON453="Warning_0x01c5h_L3_cache_error_has_been_detected"
	MRMON454="Warning_0x01c6h_L2_cache_error_has_been_detected"
	MRMON455="Warning_0x01c7h_Controller_booted_in_headless_mode_with_errors"
	MRMON456="Critical_0x01c8h_Controller_booted_to_safe_mode_due_to_critical_errors"
	MRMON457="Warning_0x01c9h_Warning_Error_during_boot_-_X"
	MRMON458="Critical_0x01cah_Critical_Error_during_boot_-_X"
	MRMON459="Fatal_0x01cbh_Fatal_Error_during_boot_-_X"
	MRMON460="Info_0x01cch_Peer_controller_has_joined_HA_domain_-ID-_X"
	MRMON461="Info_0x01cdh_Peer_controller_has_left_HA_domain_-ID-_X"
	MRMON462="Info_0x01ceh_X_is_managed_by_peer_controller"
	MRMON463="Info_0x01cfh_X_is_managed_by_local_controller"
	MRMON464="Info_0x01d0h_X_is_managed_by_peer_controller"
	MRMON465="Info_0x01d1h_X_is_managed_by_local_controller"
	MRMON466="Warning_0x01d2h_X_has_a_conflict_in_HA_domain"
	MRMON467="Info_0x01d3h_X_access_is_shared"
	MRMON468="Info_0x01d4h_X_access_is_exclusive"
	MRMON469="Info_0x01d5h_X_is_incompatible_in_the_HA_domain"
	MRMON470="Warning_0x01d6h_Peer_controller_is_incompatible"
	MRMON471="Info_0x01d7h_Controllers_in_the_HA_domain_are_incompatible"
	MRMON472="Info_0x01d8h_Controller_properties_are_incompatible_between_local_and_peer_controllers"
	MRMON473="Warning_0x01d9h_FW_versions_do_not_match_in_the_HA_domain"
	MRMON474="Warning_0x01dah_Advanced_Software_Options_X_do_not_match_in_the_HA_domain"
	MRMON475="Info_0x01dbh_HA_cache_mirror_is_online"
	MRMON476="Warning_0x01dch_HA_cache_mirror_is_offline"
	MRMON477="Info_0x01ddh_X_access_blocked_as_cached_data_from_peer_controller_is_unavailable"
	MRMON478="Warning_0x01deh_Cache-vault_power_pack_is_not_supported_Please_replace_the_pack"
	MRMON479="Warning_0x01dfh_X_temperature_-X_C_is_above_warning_threshold"
	MRMON480="Critical_0x01e0h_X_temperature_-X_C_is_above_critical_threshold"
	MRMON481="Info_0x01e1h_X_temperature_-X_C_is_normal"
	MRMON482="Info_0x01e2h_X_IOs_are_being_throttled"
	MRMON483="Info_0x01e3h_X_IOs_are_normal_-No_throttling"
	MRMON484="Info_0x01e4h_X_has_Xpercent_life_left_Life_left_thresholds_-_warning-Xpercent_critical-Xpercent"
	MRMON485="Info_0x01e5h_X_life_left_-Xpercent_is_below_optimal_Life_left_thresholds_-_warning-Xpercent_critical-Xpercent"
	MRMON486="Info_0x01e6h_X_life_left_-Xpercent_is_critical_Life_left_thresholds_-_warning-Xpercent_critical-Xpercent"
	MRMON487="Critical_0x01e7h_X_failuredevice_locked-up"
	MRMON488="Warning_0x01e8h_Host_driver_needs_to_be_upgraded_X"
	MRMON489="Warning_0x01e9h_Direct_communication_with_peer_controllers_was_not_established_Please_check_proper_cable_connections"
	MRMON490="Warning_0x01eah_Firmware_image_does_not_contain_signed_component"
	MRMON491="Warning_0x01ebh_Authentication_failure_of_the_signed_firmware_image"
	MRMON492="Info_0x01ech_Setting_X_as_boot_device"
	MRMON493="Info_0x01edh_Setting_X_as_boot_device"
	MRMON494="Info_0x01eeh_The_BBU_temperature_is_changed_to_X_Celsius"
	MRMON495="Info_0x01efh_The_controller_temperature_is_changed_to_X_Celsius"
	MRMON496="Critical_0x01f0h_NVCache_capacity_is_too_less_to_support_data_backup_Write-back_VDs_will_be_converted_to_write-through"
	MRMON497="Warning_0x01f1h_NVCache_data_backup_capacity_has_decreasedconsider_replacement"
	MRMON498="Critical_0x01f2h_NVCache_device_failedcannot_support_data_retention"
	MRMON499="Info_0x01f3h_Boot_Device_resetsetting_target_ID_as_invalid"
	MRMON500="Warning_0x01f4h_Write_back_Nytro_cache_size_mismatch_between_the_servers_The_Nytro_cache_size_was_adjusted_to_Xld_GB"
	MRMON501="Warning_0x01f5h_VD_Xld_is_not_shared_between_servers_but_assigned_for_caching_Write_back_Nytro_cache_content_of_the_VD_will_be_mirrored"
	MRMON502="Info_0x01f6h_Power_X_watts_usage_base_IOs_throttle_started"
	MRMON503="Info_0x01f7h_Power_base_IOs_throttle_stopped"
	MRMON504="Info_0x01f8h_Controller_tunable_parameters_changed"
	MRMON505="Info_0x01f9h_Controller_operating_temperature_within_normal_range_full_operation_restored"
	MRMON506="Warning_0x01fah_Controller_temperature_threshold_exceeded_This_may_indicate_inadequate_system_cooling_Switching_to_low_performance_mode"
	MRMON507="Info_0x01fbh_Controller_supports_HA_modecurrently_functioning_with_HA_feature_set"
	MRMON508="Info_0x01fch_Controller_supports_HA_modecurrently_functioning_with_single_controller_feature_set"
	MRMON509="Critical_0x01fdh_Cache-vault_components_mismatch_Write-back_VDs_will_be_converted_write-through"
	MRMON510="Info_0x01feh_Controller_has_entered_into_maintenance_mode_X"
	MRMON511="Info_0x01ffh_Controller_has_returned_to_normal_mode"
	MRMON512="Info_0x0200h_Topology_is_in_X_mode"
	MRMON513="Critical_0x0201h_Cannot_enter_X_mode_because_X_LD_X_would_not_be_supported"
	MRMON514="Critical_0x0202h_Cannot_enter_X_mode_because_X_PD_X_would_not_be_supported"
	
	for i in "MRMON000 $MRMON000" "MRMON001 $MRMON001" "MRMON002 $MRMON002" "MRMON003 $MRMON003" "MRMON004 $MRMON004" "MRMON005 $MRMON005" "MRMON006 $MRMON006" "MRMON007 $MRMON007" "MRMON008 $MRMON008" "MRMON009 $MRMON009" "MRMON010 $MRMON010" "MRMON011 $MRMON011" "MRMON012 $MRMON012" "MRMON013 $MRMON013" "MRMON014 $MRMON014" "MRMON015 $MRMON015" "MRMON016 $MRMON016" "MRMON017 $MRMON017" "MRMON018 $MRMON018" "MRMON019 $MRMON019" "MRMON020 $MRMON020" "MRMON021 $MRMON021" "MRMON022 $MRMON022" "MRMON023 $MRMON023" "MRMON024 $MRMON024" "MRMON025 $MRMON025" "MRMON026 $MRMON026" "MRMON027 $MRMON027" "MRMON028 $MRMON028" "MRMON029 $MRMON029" "MRMON030 $MRMON030" "MRMON031 $MRMON031" "MRMON032 $MRMON032" "MRMON033 $MRMON033" "MRMON034 $MRMON034" "MRMON035 $MRMON035" "MRMON036 $MRMON036" "MRMON037 $MRMON037" "MRMON038 $MRMON038" "MRMON039 $MRMON039" "MRMON040 $MRMON040" "MRMON041 $MRMON041" "MRMON042 $MRMON042" "MRMON043 $MRMON043" "MRMON044 $MRMON044" "MRMON045 $MRMON045" "MRMON046 $MRMON046" "MRMON047 $MRMON047" "MRMON048 $MRMON048" "MRMON049 $MRMON049" "MRMON050 $MRMON050" "MRMON051 $MRMON051" "MRMON052 $MRMON052" "MRMON053 $MRMON053" "MRMON054 $MRMON054" "MRMON055 $MRMON055" "MRMON056 $MRMON056" "MRMON057 $MRMON057" "MRMON058 $MRMON058" "MRMON059 $MRMON059" "MRMON060 $MRMON060" "MRMON061 $MRMON061" "MRMON062 $MRMON062" "MRMON063 $MRMON063" "MRMON064 $MRMON064" "MRMON065 $MRMON065" "MRMON066 $MRMON066" "MRMON067 $MRMON067" "MRMON068 $MRMON068" "MRMON069 $MRMON069" "MRMON070 $MRMON070" "MRMON071 $MRMON071" "MRMON072 $MRMON072" "MRMON073 $MRMON073" "MRMON074 $MRMON074" "MRMON075 $MRMON075" "MRMON076 $MRMON076" "MRMON077 $MRMON077" "MRMON078 $MRMON078" "MRMON079 $MRMON079" "MRMON080 $MRMON080" "MRMON081 $MRMON081" "MRMON082 $MRMON082" "MRMON083 $MRMON083" "MRMON084 $MRMON084" "MRMON085 $MRMON085" "MRMON086 $MRMON086" "MRMON087 $MRMON087" "MRMON088 $MRMON088" "MRMON089 $MRMON089" "MRMON090 $MRMON090" "MRMON091 $MRMON091" "MRMON092 $MRMON092" "MRMON093 $MRMON093" "MRMON094 $MRMON094" "MRMON095 $MRMON095" "MRMON096 $MRMON096" "MRMON097 $MRMON097" "MRMON098 $MRMON098" "MRMON099 $MRMON099" "MRMON100 $MRMON100" "MRMON101 $MRMON101" "MRMON102 $MRMON102" "MRMON103 $MRMON103" "MRMON104 $MRMON104" "MRMON105 $MRMON105" "MRMON106 $MRMON106" "MRMON107 $MRMON107" "MRMON108 $MRMON108" "MRMON109 $MRMON109" "MRMON110 $MRMON110" "MRMON111 $MRMON111" "MRMON112 $MRMON112" "MRMON113 $MRMON113" "MRMON114 $MRMON114" "MRMON115 $MRMON115" "MRMON116 $MRMON116" "MRMON117 $MRMON117" "MRMON118 $MRMON118" "MRMON119 $MRMON119" "MRMON120 $MRMON120" "MRMON121 $MRMON121" "MRMON122 $MRMON122" "MRMON123 $MRMON123" "MRMON124 $MRMON124" "MRMON125 $MRMON125" "MRMON126 $MRMON126" "MRMON127 $MRMON127" "MRMON128 $MRMON128" "MRMON129 $MRMON129" "MRMON130 $MRMON130" "MRMON131 $MRMON131" "MRMON132 $MRMON132" "MRMON133 $MRMON133" "MRMON134 $MRMON134" "MRMON135 $MRMON135" "MRMON136 $MRMON136" "MRMON137 $MRMON137" "MRMON138 $MRMON138" "MRMON139 $MRMON139" "MRMON140 $MRMON140" "MRMON141 $MRMON141" "MRMON142 $MRMON142" "MRMON143 $MRMON143" "MRMON144 $MRMON144" "MRMON145 $MRMON145" "MRMON146 $MRMON146" "MRMON147 $MRMON147" "MRMON148 $MRMON148" "MRMON149 $MRMON149" "MRMON150 $MRMON150" "MRMON151 $MRMON151" "MRMON152 $MRMON152" "MRMON153 $MRMON153" "MRMON154 $MRMON154" "MRMON155 $MRMON155" "MRMON156 $MRMON156" "MRMON157 $MRMON157" "MRMON158 $MRMON158" "MRMON159 $MRMON159" "MRMON160 $MRMON160" "MRMON161 $MRMON161" "MRMON162 $MRMON162" "MRMON163 $MRMON163" "MRMON164 $MRMON164" "MRMON165 $MRMON165" "MRMON166 $MRMON166" "MRMON167 $MRMON167" "MRMON168 $MRMON168" "MRMON169 $MRMON169" "MRMON170 $MRMON170" "MRMON171 $MRMON171" "MRMON172 $MRMON172" "MRMON173 $MRMON173" "MRMON174 $MRMON174" "MRMON175 $MRMON175" "MRMON176 $MRMON176" "MRMON177 $MRMON177" "MRMON178 $MRMON178" "MRMON179 $MRMON179" "MRMON180 $MRMON180" "MRMON181 $MRMON181" "MRMON182 $MRMON182" "MRMON183 $MRMON183" "MRMON184 $MRMON184" "MRMON185 $MRMON185" "MRMON186 $MRMON186" "MRMON187 $MRMON187" "MRMON188 $MRMON188" "MRMON189 $MRMON189" "MRMON190 $MRMON190" "MRMON191 $MRMON191" "MRMON192 $MRMON192" "MRMON193 $MRMON193" "MRMON194 $MRMON194" "MRMON195 $MRMON195" "MRMON196 $MRMON196" "MRMON197 $MRMON197" "MRMON198 $MRMON198" "MRMON199 $MRMON199" "MRMON200 $MRMON200" "MRMON201 $MRMON201" "MRMON202 $MRMON202" "MRMON203 $MRMON203" "MRMON204 $MRMON204" "MRMON205 $MRMON205" "MRMON206 $MRMON206" "MRMON207 $MRMON207" "MRMON208 $MRMON208" "MRMON209 $MRMON209" "MRMON210 $MRMON210" "MRMON211 $MRMON211" "MRMON212 $MRMON212" "MRMON213 $MRMON213" "MRMON214 $MRMON214" "MRMON215 $MRMON215" "MRMON216 $MRMON216" "MRMON217 $MRMON217" "MRMON218 $MRMON218" "MRMON219 $MRMON219" "MRMON220 $MRMON220" "MRMON221 $MRMON221" "MRMON222 $MRMON222" "MRMON223 $MRMON223" "MRMON224 $MRMON224" "MRMON225 $MRMON225" "MRMON226 $MRMON226" "MRMON227 $MRMON227" "MRMON228 $MRMON228" "MRMON229 $MRMON229" "MRMON230 $MRMON230" "MRMON231 $MRMON231" "MRMON232 $MRMON232" "MRMON233 $MRMON233" "MRMON234 $MRMON234" "MRMON235 $MRMON235" "MRMON236 $MRMON236" "MRMON237 $MRMON237" "MRMON238 $MRMON238" "MRMON239 $MRMON239" "MRMON240 $MRMON240" "MRMON241 $MRMON241" "MRMON242 $MRMON242" "MRMON243 $MRMON243" "MRMON244 $MRMON244" "MRMON245 $MRMON245" "MRMON246 $MRMON246" "MRMON247 $MRMON247" "MRMON248 $MRMON248" "MRMON249 $MRMON249" "MRMON250 $MRMON250" "MRMON251 $MRMON251" "MRMON252 $MRMON252" "MRMON253 $MRMON253" "MRMON254 $MRMON254" "MRMON255 $MRMON255" "MRMON256 $MRMON256" "MRMON257 $MRMON257" "MRMON258 $MRMON258" "MRMON259 $MRMON259" "MRMON260 $MRMON260" "MRMON261 $MRMON261" "MRMON262 $MRMON262" "MRMON263 $MRMON263" "MRMON264 $MRMON264" "MRMON265 $MRMON265" "MRMON266 $MRMON266" "MRMON267 $MRMON267" "MRMON268 $MRMON268" "MRMON269 $MRMON269" "MRMON270 $MRMON270" "MRMON271 $MRMON271" "MRMON272 $MRMON272" "MRMON273 $MRMON273" "MRMON274 $MRMON274" "MRMON275 $MRMON275" "MRMON276 $MRMON276" "MRMON277 $MRMON277" "MRMON278 $MRMON278" "MRMON279 $MRMON279" "MRMON280 $MRMON280" "MRMON281 $MRMON281" "MRMON282 $MRMON282" "MRMON283 $MRMON283" "MRMON284 $MRMON284" "MRMON285 $MRMON285" "MRMON286 $MRMON286" "MRMON287 $MRMON287" "MRMON288 $MRMON288" "MRMON289 $MRMON289" "MRMON290 $MRMON290" "MRMON291 $MRMON291" "MRMON292 $MRMON292" "MRMON293 $MRMON293" "MRMON294 $MRMON294" "MRMON295 $MRMON295" "MRMON296 $MRMON296" "MRMON297 $MRMON297" "MRMON298 $MRMON298" "MRMON299 $MRMON299" "MRMON300 $MRMON300" "MRMON301 $MRMON301" "MRMON302 $MRMON302" "MRMON303 $MRMON303" "MRMON304 $MRMON304" "MRMON305 $MRMON305" "MRMON306 $MRMON306" "MRMON307 $MRMON307" "MRMON308 $MRMON308" "MRMON309 $MRMON309" "MRMON310 $MRMON310" "MRMON311 $MRMON311" "MRMON312 $MRMON312" "MRMON313 $MRMON313" "MRMON314 $MRMON314" "MRMON315 $MRMON315" "MRMON316 $MRMON316" "MRMON317 $MRMON317" "MRMON318 $MRMON318" "MRMON319 $MRMON319" "MRMON320 $MRMON320" "MRMON321 $MRMON321" "MRMON322 $MRMON322" "MRMON323 $MRMON323" "MRMON324 $MRMON324" "MRMON325 $MRMON325" "MRMON326 $MRMON326" "MRMON327 $MRMON327" "MRMON328 $MRMON328" "MRMON329 $MRMON329" "MRMON330 $MRMON330" "MRMON331 $MRMON331" "MRMON332 $MRMON332" "MRMON333 $MRMON333" "MRMON334 $MRMON334" "MRMON335 $MRMON335" "MRMON336 $MRMON336" "MRMON337 $MRMON337" "MRMON338 $MRMON338" "MRMON339 $MRMON339" "MRMON340 $MRMON340" "MRMON341 $MRMON341" "MRMON342 $MRMON342" "MRMON343 $MRMON343" "MRMON344 $MRMON344" "MRMON345 $MRMON345" "MRMON346 $MRMON346" "MRMON347 $MRMON347" "MRMON348 $MRMON348" "MRMON349 $MRMON349" "MRMON350 $MRMON350" "MRMON351 $MRMON351" "MRMON352 $MRMON352" "MRMON353 $MRMON353" "MRMON354 $MRMON354" "MRMON355 $MRMON355" "MRMON356 $MRMON356" "MRMON357 $MRMON357" "MRMON358 $MRMON358" "MRMON359 $MRMON359" "MRMON360 $MRMON360" "MRMON361 $MRMON361" "MRMON362 $MRMON362" "MRMON363 $MRMON363" "MRMON364 $MRMON364" "MRMON365 $MRMON365" "MRMON366 $MRMON366" "MRMON367 $MRMON367" "MRMON368 $MRMON368" "MRMON369 $MRMON369" "MRMON370 $MRMON370" "MRMON371 $MRMON371" "MRMON372 $MRMON372" "MRMON373 $MRMON373" "MRMON374 $MRMON374" "MRMON375 $MRMON375" "MRMON376 $MRMON376" "MRMON377 $MRMON377" "MRMON378 $MRMON378" "MRMON379 $MRMON379" "MRMON380 $MRMON380" "MRMON381 $MRMON381" "MRMON382 $MRMON382" "MRMON383 $MRMON383" "MRMON384 $MRMON384" "MRMON385 $MRMON385" "MRMON386 $MRMON386" "MRMON387 $MRMON387" "MRMON388 $MRMON388" "MRMON389 $MRMON389" "MRMON390 $MRMON390" "MRMON391 $MRMON391" "MRMON392 $MRMON392" "MRMON393 $MRMON393" "MRMON394 $MRMON394" "MRMON395 $MRMON395" "MRMON396 $MRMON396" "MRMON397 $MRMON397" "MRMON398 $MRMON398" "MRMON399 $MRMON399" "MRMON400 $MRMON400" "MRMON401 $MRMON401" "MRMON402 $MRMON402" "MRMON403 $MRMON403" "MRMON404 $MRMON404" "MRMON405 $MRMON405" "MRMON406 $MRMON406" "MRMON407 $MRMON407" "MRMON408 $MRMON408" "MRMON409 $MRMON409" "MRMON410 $MRMON410" "MRMON411 $MRMON411" "MRMON412 $MRMON412" "MRMON413 $MRMON413" "MRMON414 $MRMON414" "MRMON415 $MRMON415" "MRMON416 $MRMON416" "MRMON417 $MRMON417" "MRMON418 $MRMON418" "MRMON419 $MRMON419" "MRMON420 $MRMON420" "MRMON421 $MRMON421" "MRMON422 $MRMON422" "MRMON423 $MRMON423" "MRMON424 $MRMON424" "MRMON425 $MRMON425" "MRMON426 $MRMON426" "MRMON427 $MRMON427" "MRMON428 $MRMON428" "MRMON429 $MRMON429" "MRMON430 $MRMON430" "MRMON431 $MRMON431" "MRMON432 $MRMON432" "MRMON433 $MRMON433" "MRMON434 $MRMON434" "MRMON435 $MRMON435" "MRMON436 $MRMON436" "MRMON437 $MRMON437" "MRMON438 $MRMON438" "MRMON439 $MRMON439" "MRMON440 $MRMON440" "MRMON441 $MRMON441" "MRMON442 $MRMON442" "MRMON443 $MRMON443" "MRMON444 $MRMON444" "MRMON445 $MRMON445" "MRMON446 $MRMON446" "MRMON447 $MRMON447" "MRMON448 $MRMON448" "MRMON449 $MRMON449" "MRMON450 $MRMON450" "MRMON451 $MRMON451" "MRMON452 $MRMON452" "MRMON453 $MRMON453" "MRMON454 $MRMON454" "MRMON455 $MRMON455" "MRMON456 $MRMON456" "MRMON457 $MRMON457" "MRMON458 $MRMON458" "MRMON459 $MRMON459" "MRMON460 $MRMON460" "MRMON461 $MRMON461" "MRMON462 $MRMON462" "MRMON463 $MRMON463" "MRMON464 $MRMON464" "MRMON465 $MRMON465" "MRMON466 $MRMON466" "MRMON467 $MRMON467" "MRMON468 $MRMON468" "MRMON469 $MRMON469" "MRMON470 $MRMON470" "MRMON471 $MRMON471" "MRMON472 $MRMON472" "MRMON473 $MRMON473" "MRMON474 $MRMON474" "MRMON475 $MRMON475" "MRMON476 $MRMON476" "MRMON477 $MRMON477" "MRMON478 $MRMON478" "MRMON479 $MRMON479" "MRMON480 $MRMON480" "MRMON481 $MRMON481" "MRMON482 $MRMON482" "MRMON483 $MRMON483" "MRMON484 $MRMON484" "MRMON485 $MRMON485" "MRMON486 $MRMON486" "MRMON487 $MRMON487" "MRMON488 $MRMON488" "MRMON489 $MRMON489" "MRMON490 $MRMON490" "MRMON491 $MRMON491" "MRMON492 $MRMON492" "MRMON493 $MRMON493" "MRMON494 $MRMON494" "MRMON495 $MRMON495" "MRMON496 $MRMON496" "MRMON497 $MRMON497" "MRMON498 $MRMON498" "MRMON499 $MRMON499" "MRMON500 $MRMON500" "MRMON501 $MRMON501" "MRMON502 $MRMON502" "MRMON503 $MRMON503" "MRMON504 $MRMON504" "MRMON505 $MRMON505" "MRMON506 $MRMON506" "MRMON507 $MRMON507" "MRMON508 $MRMON508" "MRMON509 $MRMON509" "MRMON510 $MRMON510" "MRMON511 $MRMON511" "MRMON512 $MRMON512" "MRMON513 $MRMON513" "MRMON514 $MRMON514"  ; do
	
		set $i
	
		if [ -f ./$fileName/LSI_Products/MegaRAID/AENs/mrmonitord_messages.txt ]; then
	       		$grep -i $1 ./$fileName/LSI_Products/MegaRAID/AENs/mrmonitord_messages.txt > ./$fileName/LSI_Products/MegaRAID/AENs/$1_$2.txt
	
			if [ ! -s ./$fileName/LSI_Products/MegaRAID/AENs/$1_$2.txt ]; then rm ./$fileName/LSI_Products/MegaRAID/AENs/$1_$2.txt > /dev/null 2>&1 ; fi
	
		fi
	
	done
	
	
	for i in Info Warning Critical Fatal Progress Obsolete ; do
	
		ls ./$fileName/LSI_Products/MegaRAID/AENs | $grep $i > /dev/null 2>&1
		if [ "$?" -eq "0" ]; then
			if [ ! -d ./$fileName/LSI_Products/MegaRAID/AENs/$i ] ; then mkdir ./$fileName/LSI_Products/MegaRAID/AENs/$i ; fi
		fi
	
	done
	
	###########################################################################################################################
	# Seperate Controller Specific AENs
	###########################################################################################################################
	
	
	
	for i in $($CLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
		for j in $(ls ./$fileName/LSI_Products/MegaRAID/AENs | $grep MRMON) ; do $grep "> Controller ID:  $i" ./$fileName/LSI_Products/MegaRAID/AENs/"$j" >> ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C"$i"_"$j"  
			if [ ! -s ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C"$i"_"$j" ]; then rm ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C"$i"_"$j" ; fi
			if [ ! -d ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i ] ; then mkdir ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i  ; fi
			mv ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C"$i"_$j ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i/$j > /dev/null 2>&1	
		done

# Different spacing in mrmonitord and MSM

		for j in $(ls ./$fileName/LSI_Products/MegaRAID/AENs | $grep MRMON) ; do $grep "> Controller ID: $i" ./$fileName/LSI_Products/MegaRAID/AENs/"$j" >> ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C"$i"_"$j"  
			if [ ! -s ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C"$i"_"$j" ]; then rm ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C"$i"_"$j" ; fi
			if [ ! -d ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i ] ; then mkdir ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i  ; fi
			mv ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C"$i"_$j ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i/$j > /dev/null 2>&1	
		done

		
		if [ -d ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i  ] ; then
	
			for j in Info Warning Critical Fatal Progress Obsolete ; do
	
				ls ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i | $grep $j > /dev/null 2>&1
				if [ "$?" -eq "0" ]; then
					if [ ! -d ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i/$j ] ; then mkdir ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i/$j ; fi
				fi
	
			done
	
		fi
	
		for j in Info Warning Critical Fatal Progress Obsolete ; do
	
			mv ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i/MRMON???_$j* ./$fileName/LSI_Products/MegaRAID/AENs/Controller_C$i/$j > /dev/null 2>&1
		
		done
	
	done
	
	
	for j in Info Warning Critical Fatal Progress Obsolete ; do
	
		mv ./$fileName/LSI_Products/MegaRAID/AENs/MRMON???_$j* ./$fileName/LSI_Products/MegaRAID/AENs/$j > /dev/null 2>&1
		
	done
	
	
	
	###########################################################################################################################
	# Special Monitoring of specific errors
	###########################################################################################################################
	
	
	if [ -f ./$fileName/LSI_Products/MegaRAID/AENs/Warning/MRMON113_Warning_0x0071h_Unexpected_sense_0x_CDBX_Sense_0x.txt ]; then 
	$grep -i "Sense =  0x70  0x00  0x0b  0x00  0x00  0x00  0x00  0x0a  0x00  0x00  0x00  0x00  0x47  0x03  0x00  0x00  0x00  0x00" ./$fileName/LSI_Products/MegaRAID/AENs/Warning/MRMON113_Warning_0x0071h_Unexpected_sense_0x_CDBX_Sense_0x.txt > /dev/null
		if [ "$?" -eq "0" ]; then
		#cho ".................................................||................................................."
		echo ".......................................iuCRC Error Detected........................................." >> ./$fileName/LSI_Products/MegaRAID/iuCRC_Error_Detected.txt
		echo "................................Upgrade to latest code and retest..................................." >> ./$fileName/LSI_Products/MegaRAID/iuCRC_Error_Detected.txt
		grep -i "Sense =  0x70  0x00  0x0b  0x00  0x00  0x00  0x00  0x0a  0x00  0x00  0x00  0x00  0x47  0x03  0x00  0x00  0x00  0x00" ./$fileName/LSI_Products/MegaRAID/AENs/Warning/MRMON113_Warning_0x0071h_Unexpected_sense_0x_CDBX_Sense_0x.txt >> ./$fileName/LSI_Products/MegaRAID/iuCRC_Error_Detected.txt
		fi
	fi
	###########################################################################################################################
	
	
	if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
		date '+%H:%M:%S.%N' 
	fi	
	if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
		date '+%H:%M:%S' 
	fi
	echo "Evaluating MegaRAID AENs completed..."
	
	# Return from if FreeBSD - Different Error Codes and no MR_Monitord support
	fi
	# Return from if MacOS - No MacOS support for MegaRAID
	fi
	
	###########################################################################################################################
	# 3ware CodeSet Check Start
	###########################################################################################################################
	#cho ".................................................||................................................."
	echo "...................................................................................................."  >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
	echo "                       Check the LSI Channel Products Page for the latest code set                  "  >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
	echo "                              http://www.lsi.com/channel/Pages/default.aspx                         "  >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
	echo "...................................................................................................."  >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
	
	
	for i in $($CLI_LOCATION$CLI_NAME show |grep ^c | cut -b 2-3); do #Support for Controller IDs 0-99
		#cho ".................................................||................................................."
		echo "........................................Controller_C$i Firmware......................................" >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		$CLI_LOCATION$CLI_NAME /c$i show model >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		$CLI_LOCATION$CLI_NAME /c$i show firmware | cut -s -d " " -f 6 > ./$fileName/script_workspace/fwC$i.txt 2>&1
		for j in $( cat ./$fileName/script_workspace/fwC$i.txt );do
		fgrep "$j"_FW ./$fileName/script_workspace/cversions_3w.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
			if [ "$?" -ne "0" ] ; then
			echo "Version not listed in cversions_3w.txt" >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
			cat ./$fileName/script_workspace/fwC$i.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
			fi
		done
		
		#cho ".................................................||................................................."
		echo "........................................Controller_C$i Driver........................................" >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		$CLI_LOCATION$CLI_NAME /c$i show driver | cut -s -d " " -f 5 > ./$fileName/script_workspace/drvC$i.txt 2>&1
		for j in $( cat ./$fileName/script_workspace/drvC$i.txt );do
		fgrep "$j"_DRV ./$fileName/script_workspace/cversions_3w.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
			if [ "$?" -ne "0" ] ; then
			echo "Version not listed in cversions_3w.txt" >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
			cat ./$fileName/script_workspace/drvC$i.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
			fi
		done
	done
	
	
	if [ -f ./$fileName/LSI_Products/3ware/3DM/3dm_version.txt ]; then 
	#cho ".................................................||................................................."
	echo "................................................3DM................................................." >> ./$fileName/LSI_Products/3ware/Versions_3w.txt
	for j in $( cat ./$fileName/LSI_Products/3ware/3DM/3dm_version.txt );do
	fgrep "$j"_3DM ./$fileName/script_workspace/cversions_3w.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_3w.txt" >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		cat ./$fileName/LSI_Products/3ware/3DM/3dm_version.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		fi
	done
	fi
	
	if [ -f ./$fileName/LSI_Products/3ware/3DM2/3dm2_ver.txt ]; then 
	#cho ".................................................||................................................."
	echo "................................................3DM2................................................" >> ./$fileName/LSI_Products/3ware/Versions_3w.txt
	
	for j in $( cat ./$fileName/LSI_Products/3ware/3DM2/3dm2_ver.txt );do
	fgrep "$j"_3DM2 ./$fileName/script_workspace/cversions_3w.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_3w.txt" >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		cat ./$fileName/LSI_Products/3ware/3DM2/3dm2_ver.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		fi
	done
	fi
	
	if [ -f ./$fileName/LSI_Products/3ware/3DM2/3dm2api_ver.txt ]; then 
	#cho ".................................................||................................................."
	#echo "..............................................3DM2 API.............................................." >> ./$fileName/LSI_Products/3ware/Versions_3w.txt
	
	for j in $( cat ./$fileName/LSI_Products/3ware/3DM2/3dm2api_ver.txt );do
	fgrep "$j"_API ./$fileName/script_workspace/cversions_3w.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_3w.txt" >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		cat ./$fileName/LSI_Products/3ware/3DM2/3dm2api_ver.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		fi
	done
	fi
	
	
	if [ -f ./$fileName/script_workspace/tw_cli_Bundled_version.txt ]; then 
	#cho ".................................................||................................................."
	echo "...................................Latest/Included TW_CLI version..................................." >> ./$fileName/LSI_Products/3ware/Versions_3w.txt
	for j in $( cat ./$fileName/script_workspace/tw_cli_Bundled_version.txt );do
	fgrep "$j"_CLI ./$fileName/script_workspace/cversions_3w.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_3w.txt" >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		cat ./$fileName/script_workspace/tw_cli_Bundled_version.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		fi
	done
	fi
	
	if [ -f ./$fileName/script_workspace/tw_cli_Existing_version.txt ]; then 
	#cho ".................................................||................................................."
	echo ".....................................Pre-Existing TW_CLI version...................................." >> ./$fileName/LSI_Products/3ware/Versions_3w.txt
	for j in $( cat ./$fileName/script_workspace/tw_cli_Existing_version.txt );do
	fgrep "$j"_CLI ./$fileName/script_workspace/cversions_3w.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_3w.txt" >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		cat ./$fileName/script_workspace/tw_cli_Existing_version.txt >> ./$fileName/LSI_Products/3ware/Versions_3w.txt 2>&1
		fi
	done
	fi
	
	#
	#Stop 3ware CodeSet Check
	#
	
	###########################################################################################################################
	# LSI HBA CodeSet Check Start
	###########################################################################################################################
	# No MacOS Support for HBA
	if [ "$OS_LSI" != "macos" ] ; then
	
	#cho ".................................................||................................................."
	echo "...................................................................................................."  >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
	echo "                       Check the LSI Channel Products Page for the latest code set                  "  >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
	echo "                              http://www.lsi.com/channel/Pages/default.aspx                         "  >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
	echo "...................................................................................................."  >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
	
	
	if [ "$NO_LSI_HBAs" != "YES" ] ; then 
	
	for i in $(./$LSUT_NAME 0 2>>./$fileName/script_workspace/lsiget_errorlog.txt | awk 'BEGIN{prt=0}{if (prt==1) print $0; else if ($3=="Chip") prt=1}' | $grep LSI | cut -d. -f1); do # Support for unlimited HBAs
	
	
		#cho ".................................................||................................................."
		echo "...................................Host Bus Adapter_$i Firmware......................................" >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
		./$LSUT_NAME -p $i 1 2>>./$fileName/script_workspace/lsiget_errorlog.txt | grep MPTFW | cut -d" " -f 5 > ./$fileName/script_workspace/fwH$i.txt 2>&1
		./$LSUT_NAME -p $i 47 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep "Board name is" >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
		for j in $( cat ./$fileName/script_workspace/fwH$i.txt );do
		fgrep "$j"_FW ./$fileName/script_workspace/cversions_HBA.txt >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
			if [ "$?" -ne "0" ] ; then
			echo "Version not listed in cversions_HBA.txt" >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
			cat ./$fileName/script_workspace/fwH$i.txt >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
			fi
		done
	
		#cho ".................................................||................................................."
		echo ".....................................Host Bus Adapter_$i BIOS........................................" >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
		./$LSUT_NAME -p $i 1 2>>./$fileName/script_workspace/lsiget_errorlog.txt | grep BIOS | cut -d" " -f 6 | cut -d- -f 2 > ./$fileName/script_workspace/biosH$i.txt 2>&1
		for j in $( cat ./$fileName/script_workspace/biosH$i.txt );do
		fgrep "$j"_BIOS ./$fileName/script_workspace/cversions_HBA.txt >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
			if [ "$?" -ne "0" ] ; then
			echo "Version not listed in cversions_HBA.txt" >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
			cat ./$fileName/script_workspace/biosH$i.txt >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
			fi
		done
		
		#cho ".................................................||................................................."
		echo "....................................Host Bus Adapter_$i Driver......................................" >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
		./$LSUT_NAME -p $i 47 2>>./$fileName/script_workspace/lsiget_errorlog.txt | $grep Driver | cut -dD -f2 | cut -d- -f2 > ./$fileName/script_workspace/drvH$i.txt 2>&1
		for j in $( cat ./$fileName/script_workspace/drvH$i.txt );do
		fgrep "$j"_DRV ./$fileName/script_workspace/cversions_HBA.txt >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
			if [ "$?" -ne "0" ] ; then
			echo "Version not listed in cversions_HBA.txt" >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
			cat ./$fileName/script_workspace/drvH$i.txt >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
			fi
		done
	done

	fi
	
	if [ -f ./$fileName/LSI_Products/MegaRAID/MSM/mrmonitord_version.txt ]; then 
	#cho ".................................................||................................................."
	echo "..........................................MSM MRMONITORD............................................" >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt
	for j in $( cat ./$fileName/LSI_Products/MegaRAID/MSM/mrmonitord_version.txt );do
	fgrep "$j"_MSMmd ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
		cat ./$fileName/LSI_Products/MegaRAID/MSM/mrmonitord_version.txt >> ./$fileName/LSI_Products/HBA/Versions_HBA.txt 2>&1
		fi
	done
	fi
	
	#
	#Stop LSI HBA CodeSet Check
	#
	
	# Return no MacOS support for HBA
	fi
	
	###########################################################################################################################
	# MegaRAID CodeSet Check Start
	###########################################################################################################################
	# No MacOS Support for MegaRAID
	if [ "$OS_LSI" != "macos" ] ; then
	
	#cho ".................................................||................................................."
	echo "...................................................................................................."  >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
	echo "                       Check the LSI Channel Products Page for the latest code set                  "  >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
	echo "                              http://www.lsi.com/channel/Pages/default.aspx                         "  >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
	echo "."  >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
	echo "...................................................................................................."  >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
	
	# Make sure at least 1 MegaRAID Adapter is identified
	if [ -f ./$fileName/script_workspace/adapter_numbers.txt ] ; then
	
	for i in `cat ./$fileName/script_workspace/adapter_numbers.txt` ; do #Support for all adapter IDs 
		#cho ".................................................||................................................."
		echo "........................................Adapter_A$i Firmware........................................." >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		$MCLI_LOCATION$MCLI_NAME adpallinfo a$i nolog | $grep -e "Product Name" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		$MCLI_LOCATION$MCLI_NAME adpallinfo a$i nolog | $grep Package | cut -d' ' -f4 > ./$fileName/script_workspace/fwA$i.txt 2>&1
		for j in $( cat ./$fileName/script_workspace/fwA$i.txt );do
		fgrep "$j"_FWp ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
			if [ "$?" -ne "0" ] ; then
			echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
			cat ./$fileName/script_workspace/fwA$i.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
			fi
		done
		
	if [ "$OS_LSI" = "linux" ]; then 
	
		if [ ! -f ./$fileName/script_workspace/megaraid_sas_ver.txt ] ; then
			$grep -e "Driver Name:        megaraid_sas" ./$fileName/LSI_Products/MegaRAID/AdpAliLog_A$i.txt > /dev/null 2>&1
			if [ "$?" -eq "0" ] ; then
				$grep -e "Driver Version:" ./$fileName/LSI_Products/MegaRAID/AdpAliLog_A$i.txt | cut -d: -f2 | tr [:blank:] @ | tr -d @ >> ./$fileName/script_workspace/megaraid_sas_ver.txt
			fi
		fi
		
		if [ ! -f ./$fileName/script_workspace/megasr_ver.txt ] ; then
			$grep -e "Driver Name:        megasr" ./$fileName/LSI_Products/MegaRAID/AdpAliLog_A$i.txt > /dev/null 2>&1
			if [ "$?" -eq "0" ] ; then
				$grep -e "Driver Version:" ./$fileName/LSI_Products/MegaRAID/AdpAliLog_A$i.txt | cut -d: -f2 | tr [:blank:] @ | tr -d @ >> ./$fileName/script_workspace/megasr_ver.txt
			fi
		fi
	
	
	
		#cho ".................................................||................................................."
		echo ".........................................Adapter_A$i Driver.........................................." >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
	
	$grep -e "Driver Name:        megasr" ./$fileName/LSI_Products/MegaRAID/AdpAliLog_A$i.txt > /dev/null 2>&1
		if [ "$?" -eq "0" ] ; then
			if [ -f ./$fileName/script_workspace/megasr_ver.txt ] ; then
			for j in $( cat ./$fileName/script_workspace/megasr_ver.txt );do
			fgrep "$j"_DRVl ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
				if [ "$?" -ne "0" ] ; then
				echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
				cat ./$fileName/script_workspace/megasr_ver.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
				fi
			done
			fi
		fi
		
	$grep -e "Driver Name:        megaraid_sas" ./$fileName/LSI_Products/MegaRAID/AdpAliLog_A$i.txt > /dev/null 2>&1
		if [ "$?" -eq "0" ] ; then
			if [ -f ./$fileName/script_workspace/megaraid_sas_ver.txt ] ; then
			for j in $( cat ./$fileName/script_workspace/megaraid_sas_ver.txt );do
			fgrep "$j"_DRVl ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
				if [ "$?" -ne "0" ] ; then
				echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
				cat ./$fileName/script_workspace/megaraid_sas_ver.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
				fi
			done
			fi
		fi		
	
	#OS Linux
	fi
	
	# Adapter Numbers
	done
	fi
	
	
	if [ -f ./$fileName/LSI_Products/MegaRAID/MSM/mrmonitord_version.txt ]; then 
	#cho ".................................................||................................................."
	echo "..........................................MSM MRMONITORD............................................" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt
	for j in $( cat ./$fileName/LSI_Products/MegaRAID/MSM/mrmonitord_version.txt );do
	fgrep "$j"_MSMmd ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		cat ./$fileName/LSI_Products/MegaRAID/MSM/mrmonitord_version.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		fi
	done
	fi
	
	
	
	if [ -f ./$fileName/script_workspace/mcli_Bundled_version.txt ]; then 
	#cho ".................................................||................................................."
	echo "..................................Latest/Included MegaCli version..................................." >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt
	for j in $( cat ./$fileName/script_workspace/mcli_Bundled_version.txt );do
	
	if [ "$OS_LSI" = "linux" ] ; then
	fgrep "$j"_CLIl ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		cat ./$fileName/script_workspace/mcli_Bundled_version.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		fi
	# Return OS=Linux
	fi
	if [ "$OS_LSI" = "vmware" ] ; then
	fgrep "$j"_CLIl ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		cat ./$fileName/script_workspace/mcli_Bundled_version.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		fi
	# Return OS=vmware
	fi
	if [ "$OS_LSI" = "freebsd" ] ; then
	fgrep "$j"_CLIf ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		cat ./$fileName/script_workspace/mcli_Bundled_version.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		fi
	# Return OS=freebsd
	fi
	if [ "$OS_LSI" = "sco" ] ; then
	fgrep "$j"_CLIsc ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		cat ./$fileName/script_workspace/mcli_Bundled_version.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		fi
	# Return OS=sco
	fi
	if [ "$OS_LSI" = "solaris" ] ; then
	fgrep "$j"_CLIso ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		cat ./$fileName/script_workspace/mcli_Bundled_version.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		fi
	# Return OS=solaris
	fi
	
	done
	fi
	
	if [ -f ./$fileName/script_workspace/mcli_Existing_version.txt ]; then 
	#cho ".................................................||................................................."
	echo "....................................Pre-Existing MegaCli version...................................." >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt
	for j in $( cat ./$fileName/script_workspace/mcli_Existing_version.txt );do
	
	if [ "$OS_LSI" = "linux" ] ; then
	fgrep "$j"_CLIl ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		cat ./$fileName/script_workspace/mcli_Existing_version.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		fi
	# Return OS=Linux
	fi
	if [ "$OS_LSI" = "vmware" ] ; then
	fgrep "$j"_CLIl ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		cat ./$fileName/script_workspace/mcli_Existing_version.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		fi
	# Return OS=vmware
	fi
	if [ "$OS_LSI" = "freebsd" ] ; then
	fgrep "$j"_CLIf ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		cat ./$fileName/script_workspace/mcli_Existing_version.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		fi
	# Return OS=freebsd
	fi
	if [ "$OS_LSI" = "solaris" ] ; then
	fgrep "$j"_CLIso ./$fileName/script_workspace/cversions_MR.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		if [ "$?" -ne "0" ] ; then
		echo "Version not listed in cversions_MR.txt" >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		cat ./$fileName/script_workspace/mcli_Existing_version.txt >> ./$fileName/LSI_Products/MegaRAID/Versions_MR.txt 2>&1
		fi
	# Return OS=solaris
	fi
	
	done
	fi
	
	
	#
	#Stop MegaRAID CodeSet Check
	#
	
	# Return for no MacOS support for MegaRAID
	fi

###########################################
# Return for G_* skip to the end
###########################################
fi # G_*
#

###########################################################################################################################
# Done with MegaCli! - Second iteration in case G_* option
###########################################################################################################################



###########################################################################################################################
###########################################################################################################################
# Monitor Mode - 
###########################################################################################################################
###########################################################################################################################
if [ "$tw_cli_Functional" != "NO" ]; then
if [ "$TWGETMONITORMODE" = "MONITOR" ]; then

if [ ! -d ./$fileName/LSI_Products/3ware/MONITOR ]; then 
	mkdir ./$fileName/LSI_Products/3ware/MONITOR 
	mkdir ./$fileName/LSI_Products/3ware/MONITOR/work_space
fi

# No Carriage Return embedded on end of line!
echo  ------------------------------------------------------------------------------ > ./$fileName/LSI_Products/3ware/MONITOR/work_space/no_alarms_check.txt
###########################################################################################################################
# Monitor Mode - Blank added to EOL in monitor_point_C$i.txt
# Getting latest AEN "monitor_point" to compare new AEN's against
# Verify monitor_point_C$i.txt is valid
###########################################################################################################################


for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
$CLI_LOCATION$CLI_NAME /c$i show alarms | sed '/^$/d' | tail -n 1  > ./$fileName/LSI_Products/3ware/MONITOR/work_space/monitor_point_C$i.txt

	cat ./$fileName/LSI_Products/3ware/MONITOR/work_space/monitor_point_C$i.txt | while read j ; do
	cat ./$fileName/LSI_Products/3ware/MONITOR/work_space/no_alarms_check.txt | while read k ; do
	if [ "$j" = "$k" ] ; then echo "There were no alarms" > ./$fileName/LSI_Products/3ware/MONITOR/work_space/monitor_point_C$i.txt ; fi
	done
	done
done

# NOT_FIRST_RUN
while [ "$GOTO_STOP_MONITOR" != "YES" ] ;  do

# Default 60 Second wait for checking Alarms/AENs with "show diag"
sleep 60
echo .
echo "lsigetlin.sh Monitor Mode - Command line \"$TWCMDLINE\"   `if [ "$VMWARE_SUPPORTED" != "YES" ] ; then 
								 	date '+%H:%M:%S.%N' 
								 fi	
								 if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
									date '+%H:%M:%S' 
								 fi`"
echo ""
echo "Saves Internal Controller Log daily and on specific errors."
echo "Exits after Controller Reset/Degraded Array/Rebuild Started AENs"
echo ""
echo "To terminate hit CTRL-C"
echo ""
echo 'If manually terminated and you still need to send the output to Support/your FAE, run;'
echo ""
echo "tar cf $fileName.tar ./$fileName"
echo "gzip -9 $fileName.tar"
echo ""
echo "Then send just the file $fileName.tar.gz to Support/your FAE."
echo ""
echo "If Monitor Mode completes, run a standard capture and include that as well."
echo .
echo .
echo .

###########################################################################################################################
# Monitor Mode - Blank added to EOL in alarms_C$i.txt
# Getting latest AENs to compare "monitor_point" against, changed order to get latest AENs on top
###########################################################################################################################
for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
$CLI_LOCATION$CLI_NAME /c$i show alarms reverse > ./$fileName/LSI_Products/3ware/MONITOR/work_space/alarms_C$i.txt
done
###########################################################################################################################
# Monitor Mode - Blank match j & k
# Comparing "monitor_point" and AENs, printing new AENs to new_alarms_C$i.txt 2>&1 
###########################################################################################################################
for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
if [ -f ./$fileName/LSI_Products/3ware/MONITOR/work_space/new_alarms_C$i.txt ] ; then rm ./$fileName/LSI_Products/3ware/MONITOR/work_space/new_alarms_C$i.txt ; fi

	cat ./$fileName/LSI_Products/3ware/MONITOR/work_space/monitor_point_C$i.txt | while read j ; do
	cat ./$fileName/LSI_Products/3ware/MONITOR/work_space/alarms_C$i.txt | while read k ; do
	if [ "$j" = "$k" ] ; then break ; else echo "$k" >> ./$fileName/LSI_Products/3ware/MONITOR/work_space/new_alarms_C$i.txt ;	fi
	done
	done
done
###########################################################################################################################
# Monitor Mode - Blank match j & k
# Comparing "monitor_point" and AENs, printing new AENs to AnyError_new_alarms_C$i.txt 2>&1 
# "Couldn't strip blank spaces on the end of the AEN strings to use one set of AEN files."
###########################################################################################################################
for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
if [ -f ./$fileName/LSI_Products/3ware/MONITOR/work_space/AnyError_new_alarms_C$i.txt ] ; then rm ./$fileName/LSI_Products/3ware/MONITOR/work_space/AnyError_new_alarms_C$i.txt ; fi
done

for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
if [ -f ./$fileName/LSI_Products/3ware/MONITOR/work_space/AnyError_monitor_point_C$i.txt ] ; then 

	cat ./$fileName/LSI_Products/3ware/MONITOR/work_space/AnyError_monitor_point_C$i.txt | while read j ; do
	cat ./$fileName/LSI_Products/3ware/MONITOR/work_space/alarms_C$i.txt | while read k ; do
	if [ "$j" = "$k" ] ; then break ; else echo "$k" >> ./$fileName/LSI_Products/3ware/MONITOR/work_space/AnyError_new_alarms_C$i.txt ; fi
	done
	done
fi
done


###########################################################################################################################
# Monitor Mode - 
# Searching for 3 specific AENs to stop test also just do a "show diag" on any "ERROR" and continue.
###########################################################################################################################
for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
grep "Controller reset occurred: resets=" ./$fileName/LSI_Products/3ware/MONITOR/work_space/new_alarms_C$i.txt > /dev/null 2>&1 
if [ "$?" -eq "0" ] ; then
	echo "Controller reset occurred: resets=" > ./$fileName/LSI_Products/3ware/MONITOR/work_space/ResetDegradeRebuild_C$i.txt
	GOTO_STOP_MONITOR=YES
fi

if [ "$GOTO_STOP_MONITOR" != "YES" ] ; then
	grep "Degraded unit: unit=" ./$fileName/LSI_Products/3ware/MONITOR/work_space/new_alarms_C$i.txt > /dev/null 2>&1
	if [ "$?" -eq "0" ] ; then
		echo "Degraded unit: unit=" > ./$fileName/LSI_Products/3ware/MONITOR/work_space/ResetDegradeRebuild_C$i.txt
		GOTO_STOP_MONITOR=YES
	fi
fi

if [ "$GOTO_STOP_MONITOR" != "YES" ] ; then
	grep "Rebuild started:" ./$fileName/LSI_Products/3ware/MONITOR/work_space/new_alarms_C$i.txt > /dev/null 2>&1
	if [ "$?" -eq "0" ] ; then
		echo "Rebuild started:" > ./$fileName/LSI_Products/3ware/MONITOR/work_space/ResetDegradeRebuild_C$i.txt
		GOTO_STOP_MONITOR=YES
	fi
fi
# return for controller #
done

if [ "$GOTO_STOP_MONITOR" != "YES" ] ; then


for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
if [ -f ./$fileName/LSI_Products/3ware/MONITOR/work_space/CREATEAnyErrorMONITORPOINT_C$i.txt ] ; then rm ./$fileName/LSI_Products/3ware/MONITOR/work_space/CREATEAnyErrorMONITORPOINT_C$i.txt ; fi
if [ -f ./$fileName/LSI_Products/3ware/MONITOR/work_space/AnyError_new_alarms_C$i.txt ] ; then
	grep "]  ERROR" ./$fileName/LSI_Products/3ware/MONITOR/work_space/AnyError_new_alarms_C$i.txt > /dev/null 2>&1
	if [ "$?" -eq "0" ] ; then echo "Dummy File - AnyError_new_alarms" > ./$fileName/LSI_Products/3ware/MONITOR/work_space/CREATEAnyErrorMONITORPOINT_C$i.txt ; fi
fi

if [ ! -e ./$fileName/LSI_Products/3ware/MONITOR/work_space/AnyError_new_alarms_C$i.txt ] ; then
	grep "]  ERROR" ./$fileName/LSI_Products/3ware/MONITOR/work_space/new_alarms_C$i.txt > /dev/null 2>&1
	if [ "$?" -eq "0" ] ; then echo "Dummy File - new_alarms" > ./$fileName/LSI_Products/3ware/MONITOR/work_space/CREATEAnyErrorMONITORPOINT_C$i.txt ; fi
fi
# return for controller #
done

###########################################################################################################################
# Monitor Mode - Blank added to EOL in monitor_point_C$i.txt
# Getting latest AEN "AnyError_monitor_point" to compare new AEN's against
###########################################################################################################################
for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
if [ ! -e ./$fileName/LSI_Products/3ware/MONITOR/work_space/CREATEAnyErrorMONITORPOINT_C$i.txt ] ; then
$CLI_LOCATION$CLI_NAME /c$i show alarms | sed '/^$/d' | tail -n 1  > ./$fileName/LSI_Products/3ware/MONITOR/work_space/AnyError_monitor_point_C$i.txt
fi
done
###########################################################################################################################
# Verify AnyError_monitor_point_C$i.txt is valid
###########################################################################################################################
for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
if [ ! -e ./$fileName/LSI_Products/3ware/MONITOR/work_space/CREATEAnyErrorMONITORPOINT_C$i.txt ] ; then

	cat ./$fileName/LSI_Products/3ware/MONITOR/work_space/AnyError_monitor_point_C$i.txt | while read j ; do
	cat ./$fileName/LSI_Products/3ware/MONITOR/work_space/no_alarms_check.txt | while read k ; do
	if [ "$j" = "$k" ] ; then echo "There were no alarms" > ./$fileName/LSI_Products/3ware/MONITOR/work_space/AnyError_monitor_point_C$i.txt ; fi
	done
	done
fi
done
###########################################################################################################################
# Monitor Mode - 
# log time/date stamps
###########################################################################################################################
mtodayDate=`date '+DATE:%m%d%y' | cut -d: -f2`
mcurrentTime=`date '+TIME:%H%M%S' | cut -d: -f2`
###########################################################################################################################
# Monitor Mode - 
# Default 60 Second Alarm Check wait * 60 Iterations = approx. 1 hour * 24 = approx. 1 day standard "show diag"
# 60 * 24 = 1440 lines 
###########################################################################################################################
for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
echo 1 >> ./$fileName/LSI_Products/3ware/MONITOR/work_space/Count_C$i.txt
grep -n "1" ./$fileName/LSI_Products/3ware/MONITOR/work_space/Count_C$i.txt | $grep "1440:" > /dev/null 2>&1
if [ "$?" -eq "0" ] ; then 
	$CLI_LOCATION$CLI_NAME /c$i show diag > ./"$fileName"/MONITOR/daily_"$mtodayDate"_"$mcurrentTime"_diag_C"$i".txt 
rm ./$fileName/LSI_Products/3ware/MONITOR/work_space/Count_C$i.txt
fi
done

###########################################################################################################################
# Monitor Mode - 
# The "show diag" on any error, not including the main three.
###########################################################################################################################
for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
if [ -f ./$fileName/LSI_Products/3ware/MONITOR/work_space/CREATEAnyErrorMONITORPOINT_C$i.txt ] ; then
	$CLI_LOCATION$CLI_NAME /c$i show diag > ./"$fileName"/MONITOR/AnyError_"$mtodayDate"_"$mcurrentTime"_diag_C"$i".txt 
	rm ./$fileName/LSI_Products/3ware/MONITOR/work_space/new_alarms_C$i.txt
fi
done

# Return for "if [ "$GOTO_STOP_MONITOR" != "YES" ] ; then"
fi
# Return for "while "$GOTO_STOP_MONITOR" != "YES" ;  do"
done

###########################################################################################################################
# Monitor Mode - 
# The "show diag" on the main three AENs.
###########################################################################################################################
for i in `cat ./$fileName/script_workspace/controller_numbers.txt` ; do #Support for Controller IDs 0-99
if [ -f ./$fileName/LSI_Products/3ware/MONITOR/work_space/ResetDegradeRebuild_C$i.txt ] ; then
	$CLI_LOCATION$CLI_NAME /c$i show diag > ./"$fileName"/MONITOR/ResetDegradeRebuild_"$mtodayDate"_"$mcurrentTime"_diag_C"$i".txt
	sleep 300
	$CLI_LOCATION$CLI_NAME /c$i show diag > ./"$fileName"/MONITOR/ResetDegradeRebuild_5min_"$mtodayDate"_"$mcurrentTime"_diag_C"$i".txt
fi
done

# Return from "if [ "$TWGETMONITORMODE" = "MONITOR" ]; then"
fi
fi

###########################################################################################################################
# Script Start/Stop times
###########################################################################################################################
TWGETLUNIXSTOPutc=`date -u`
TWGETLUNIXSTOP=`date`
echo "START Universal Time" > ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo $TWGETLUNIXSTARTutc >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo "START Local Time" >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo $TWGETLUNIXSTART >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo "STOP Universal Time" >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo $TWGETLUNIXSTOPutc >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo "STOP Local Time" >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo $TWGETLUNIXSTOP >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt

###########################################################################################################################
# Capture created logs in the working directory
###########################################################################################################################

if [ -f ./CtDbg.log ] ; then
mv ./CtDbg.log ./$fileName/LSI_Products/MegaRAID/
fi
if [ -f ./MegaSAS.log ] ; then
mv ./MegaSAS.log ./$fileName/LSI_Products/MegaRAID/
fi
if [ -f ./CmdTool.log ] ; then
mv ./CmdTool.log ./$fileName/LSI_Products/MegaRAID/
fi

###########################################################################################################################
# Clean up
###########################################################################################################################

	for i in re_execute_variable_shell.txt CtDbg.log MegaSAS.log CmdTool.log lsut MegaRAID_Terminology.txt Build_all_driver_source.sh Sense-Key_ASC-ASCQ_Opcodes_SBC4R16.txt cversions_3w.txt cversions_MR.txt cversions_HBA.txt create  freebsd_tw_cli.32 freebsd_tw_cli.64 lsut32 lsut64 linux_lsut.32 linux_lsut.64 linux_tw_cli.32 linux_tw_cli.64 macos_tw_cli.32 solaris_lsut.i386 solaris_storcli solaris_tw_cli.32 vmware_tw_cli.esxi dcli32 dcli64 freebsd_dcli.32 freebsd_dcli.64 linux_dcli.32 linux_dcli.64 solaris_dcli.i386 linux_storcli64 linux_storcli linux_libstorelibir-2.so.14.07-0 solaris_storcli vmware_storcli vmware_libstorelib.so freebsd_storcli64 freebsd_storcli ; do
if [ -f ./$i ] ; then
rm -f ./$i
fi
done



CLEANED_UP=YES

###########################################################################################################################
# Compressing the file output 
###########################################################################################################################


if [ -f ./$fileName/LSI_Products/MegaRAID/CmdTool.log ] ; then rm ./$fileName/LSI_Products/MegaRAID/CmdTool.log > /dev/null 2>&1 ; fi 
if [ -f ./$fileName/LSI_Products/MegaRAID/MegaSAS.log ] ; then rm ./$fileName/LSI_Products/MegaRAID/MegaSAS.log > /dev/null 2>&1 ; fi 

tar cf $fileName.tar ./$fileName 
gzip -9 $fileName.tar

 
#Keep subdir unless variable set
if [ "$TWGETDIRECTORYKEEP" != "YES" ] ; then rm -rf $fileName > /dev/null 2>&1 ; fi 


#cho ".................................................||................................................."
echo ""
echo "Script done. The file name is;"
echo ""
echo "$fileName.tar.gz"
echo ""
echo "Send just this file as is to your support rep."
echo ""
echo "\"$BASECMD -H\" provides a help screen."
echo ""
if [ "$TWGETDIRECTORYKEEP" != "YES" ] ; then
	if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
		date '+%H:%M:%S.%N' 
	fi	
	if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
		date '+%H:%M:%S' 
	fi 
fi
if [ "$TWGETDIRECTORYKEEP" = "YES" ] ; then 
echo "The following subdir was left for your use;"
echo ""
echo "$fileName"
echo ""
if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
	date '+%H:%M:%S.%N' 
fi	
if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
	date '+%H:%M:%S' 
fi
fi


if [ "$TWGETBATCHMODE" != "BATCH" ] ; then 
if [ "$TWGETBATCHMODE" != "QUIET" ] ; then 
   WaitQuit
fi
fi

