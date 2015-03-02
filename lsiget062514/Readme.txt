Capture_Script_Version_062514
17:09:00.290299797

LSI HBA/MegaRAID/3ware Data collection script for Linux, FreeBSD, & Solaris X86 (sh shell).
This script will collect system logs and info as well as controller, disk and
enclosure info for debugging purposes. All files included in the original
lsigetlunix_xxxxxx.tgz file MUST be kept in the same subdir as lsigetlunix.sh.
You MUST have root access rights to run this script, su/sudo/root/etc. The latest version of this
script as well as information on what data can be collected manually can be found at;

http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=8264

OR

ftp0.lsil.com
User:tsupport
Password:tsupport
/outgoing_perm/CaptureScripts  (Usually newer scripts than KB article)

To automatically get the latest script you can download the following file & grep for the current
latest file. This ensures support will always have access to the latest data to speed up the support
process.

Example;

/outgoing_perm/CaptureScripts/Latest_Script_Versions.txt
#Used for automated remote script updates
LatestFreebsd#lsigetfreebsd_062012.tgz
LatestLinux#lsigetlinux_062012.tgz
LatestLunix#lsigetlunix_062012.tgz
LatestMacOS#lsigetmacos_062012.tgz
LatestSolaris#lsigetsolaris_062012.tgz
LatestWin#lsigetwin_062012.tgz

This script is being packaged for all supported linux/Unix based OS's
together as well as individually for each OS with different bundled
utilities. The exact same script is used in all cases, this is being done
to cut down on the size of the full .tgz file.

	lsigetlunix_xxxxxx.tgz   - Linux/Unix - FreeBSD/Linux/Solaris
	lsigetfreebsd_xxxxxx.tgz - FreeBSD
	lsigetlinux_xxxxxx.tgz   - Linux
	lsigetmacos_xxxxxx.tgz   - MacOS (MacOS - Not currently tested, support not explicitly removed though)
	lsigetsolaris_xxxxxx.tgz - Solaris
	lsigetvmware_xxxxxx.tgz  - VMWare  (currently - Not Supported)

Optional Command Line Options:
./lsigetlunix.sh [Comment] [Option(s)]
Comment: Enclose noncontiguous strings in double quotes "My Comments"
Option:
-P             = PRINT filename in ./LSICAPTUREFILES.TXT for batch automation.
-D             = Working DIRECTORY is not deleted.
-Q             = QUIET Mode - No keystrokes required unless error.
-B             = BATCH Mode - No keystrokes required.
-E_AEC         = Clear and ENABLE AEC. !Under Direction Only!
-E_DPMSTAT     = Clear and ENABLE DPMSTAT.
-E_AEC_DPMSTAT = Clear and ENABLE AEC and DPMSTAT. !Under Direction Only!
-G_AEC         = Disable and GET AEC Logs, IF enabled. !Under Direction Only!
-G_DPMSTAT     = Disable and GET DPMSTAT Logs, IF enabled.
-G_AEC_DPMSTAT = Disable and GET AEC/DPMSTAT Logs, IF enabled. !Under Direction Only!
-M             = MONITOR Mode - Standard and daily/targeted logging. (3ware Only)
-MRWA          = MegaRAID Work Around - Limit commands for compatibility issues with old code
-H             = This Help Screen.

Example ./lsigetlunix.sh -D -Q "This is my comment"
Runs the standard script leaving the working directory, without prompts
and leaves a comment.

Example ./lsigetlunix.sh -Q "This is my comment" -D -M
Runs the standard script leaving the working directory, without prompts
and leaves a comment, once done the script stays resident in Monitor Mode.

Notes:
Send just the created .tar.gz file as is to your support rep.

AEC = Advanced Event Capture - This is an unreleased INTERNAL option!
Do NOT use AEC without being directed to by Technical Support or an FAE! (3ware Only)

DPMSTAT = Disk Performance Monitoring Statistics - Captures performance
related information on a controller/disk basis. Detailed information can
found in the 9.5.1 or later Users Guide available at; (3ware Only)

http://www.lsi.com/channel/products/raid_controllers/sata_sas/3ware_9750-8e/index.html

All of the -G_* GET Options are done automatically if AEC or DPMSTAT was
enabled previously with the -E_* "ENABLE" options by default. The -G_*
options are meant for quick repetitive results without getting other system
information. Normally you should run the standard ./lsigetlunix.sh file without
a -G_* option to provide as much info as possible. (3ware Only)

If there are competing comments the lowest variable number wins.
If there are contradictory options the lowest variable number with the
option order listed in the help wins. Valid combinations would be;
-D or -D with -B or -Q any -E_* or -G_* option by itself or in conjunction
with a -D and -B/-Q option. -E_* is allowed with -D but has no effect as
there is no working directory created.

Monitor Mode = Runs the standard capture script and then remains resident
logging "show diag" approx. every 24 hours and also monitors for three
specific AEN's (Controller Reset/Degraded Array/Rebuild Started). If any
of these are encountered a final "show diag" will be done and the script
will finish normally. Use to capture the internal printlog/buf prior to
the buffer being overwritten. Run a standard capture after Monitor Mode completes. (3ware Only)

MRWA = MegaRAID Work Around - Limits the MegaCli(64) commands that are run.
MegaCli has been seen to hang in some cases when running the 92xx controllers with
pre 4.1.1 FW and/or driver versions. Currently this switch bypasses the encinfo & adplilog
parameters. Instead of using this switch it is recommended to upgrade your code as this
work around is not always 100% effective. See the troubleshooting section for more information.

Trouble Shooting Script Issues -

I. Ubuntu 9.04
sudo ./lsigetlunix.sh -D -Q
Tue Sep 22 17:06:32 PDT 2009
export: 3: 22: bad variable name

Run;
sudo bash ./lsigetlunix.sh -D -Q

II. Script hangs with MegaRAID Controller

If you are positive the script is hung, CTRL-C the process, wait 3 minutes.
If the prompt doesn't come back kill the term window, do a ps -ea, note the
# of any lsigetlunix.sh or MegaCli(64) processes. Do a kill -9 process-number
for each process. If any can't be killed, wait 3 minutes, there is a 180 second
timeout on MegaCli. Upgrade your driver/fw/capture script to the latest version and
try again. If you cant upgrade or if you still have problems try the -MRWA switch.
If you still have problems manually zip the subdirectory structure and 
email it to your support rep.

III. Fails to run on Solaris - Error is ./lsigetlunix.sh: test: argument expected
Old version of Bourne shell is loaded by default, the following two shells were tried automatically
/bin/sh was changed to /usr/xpg4/bin/sh and then /bin/bash
depending on what is installed on the system, you can try others, i.e. csh/ksh or install a
supported shell...

Recommended Code Set/Release Versions

3ware-

This script should run with any release between 7.6.0 & 10.2.2.1 on the 7k, 8k & 9k family of
controllers. If you are running an earlier Code Set you can still run this script as it also
captures system information. If you are using a latter Code Set you should obtain
the latest script file set at the following link; http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=8264

HOWEVER - It is recommended to update to the latest code base in general.
10.2.2.1 utilities are backwards compatible to 7xxx, 8xxx, 95xx and 96xx controllers.
10.2.2.1 drivers are for 6Gb controllers ONLY.
10.2.2.1 firmware is for 6Gb controllers ONLY.
9.5.5.1 drivers are backwards compatible to 95xx and 96xx controllers.
9.5.5.1 firmware is only compatible with 96xx controllers.

97xx - 5.12.00.016FW(10.2.2.1) for 9750 & 10.0 utilities & drivers
96xx - Highly Recommend 4.10.00.027FW(9.5.5.1) for 9690SA/9650SE & 9.5.3 utilities & drivers
9550/9590 - Highly Recommend 3.08.00.029FW(9.4.3) & 9.5.5.1 utilities & drivers
9500S - Highly Recommend 2.08.00.009FW(9.3.0.8), use 9.5.5.1 utilities & drivers
7/8xxx - Require 1.05.00.068FW(7.7.1), use 7.7.1 or latest OS included drivers & 9.5.3 utilities

3ware Drivers/FW/Utilities/Docs
http://www.lsi.com/channel/ChannelDownloads/

MegaRAID -

This script should run with any release between 3.1 & 5.5 on the 82xx, 83xx, 84xx, 87xx,
88xx & 92xx family of controllers. If you are running an earlier Code Set you can still run
this script as it also captures system information. If you are using a latter Code Set you
should obtain the latest script file set at the following link;
http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=8264

HOWEVER - It is recommended to update to the latest code base in general.
5.5 utilities are backwards compatible to 82xx, 83xx, 84xx, 87xx, 88xx, and 92xx controllers.
5.5 drivers are backwards compatible to 83xx, 84xx, 87xx, 88xx, and 92xx controllers.
5.5 firmware is only compatible with 9265/9266/9285 controllers.
4.9 firmware is only compatible with 9260/9261/9280 controllers.

HBA/MegaRAID Drivers/FW/Utilities/Docs
http://www.lsi.com/channel/ChannelDownloads/

Check the ftp site for code updates as well, the MegaRAID Web site updates lag sometimes.
FTP Site - 3ware/HBA/MegaRAID
ftp0.lsil.com
User:tsupport
Password:tsupport
/outgoing_perm/Official_MegaRAID_Releases/

HBA -

This script should run with any LSI HBA using an mpt based driver.

Capture Script Version: 062514

17:09:00.311849895
