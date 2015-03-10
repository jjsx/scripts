#!/usr/bin/perl -w
# 
# Script: Collects Nexenta systems data for SAC
# Author: Sajid Ashiq
# Mail: sajid.ashiq@nexenta.com
#


use strict;
use warnings;
use Carp::Assert;

# Define commands
my $tar = "/usr/bin/tar";
my $bzip2 = "/usr/bin/bzip2";
my $echo = "/usr/bin/echo";
my $cat = "/usr/bin/cat";
my $mkdir = "/usr/bin/mkdir";
my $wget = "/usr/bin/wget";
my $rm = "/usr/bin/rm -rf";
my $grep = "/usr/bin/grep";
my $awk = "/usr/bin/awk";
my $sed = "/usr/bin/sed";
my $ping = "/usr/sbin/ping";
my $dumpadm = "/usr/sbin/dumpadm";
my $fmdump = "/usr/sbin/fmdump";
my $cp = "/usr/bin/cp -p";
my $ls = "ls -lrt";
my $rsfcli = "/opt/HAC/RSF-1/bin/rsfcli -i0";
my $rsfmon = "/opt/HAC/RSF-1/bin/rsfmon -v";

#Get hostname 
my $hostname = `hostname`;
chomp($hostname);
my $autosmart = "";

# Define files
my $sourceslists = "/etc/apt/sources.list";
my $router = "/etc/defaultrouter";
my $servicefile = "/export/home/admin/sacservice";
my $xmlfile = "/var/svc/manifest/site/sacservice.xml";
my $script = "/etc/init.d/sacscript";
my $cluster_conf = "/opt/HAC/RSF-1/etc/config";
my $tmp_dir = "/var/tmp/autosac/";
my $sac_pack = "/export/home/admin/autosac.$hostname.tar.bz2";
my $fmdumpfile = "$tmp_dir";
$fmdumpfile .= "fmdump.out";
my $apache_conf = "/etc/apache2/sites-enabled/nmv";
my $apache_conf2 = "/etc/apache2/sites-enabled/nmv-ssl";
my $file = "$tmp_dir";
$file .= "autosac.";


#Attach hostname to file name 
$file .= $hostname;

#Check? NMV port
my $nmv_port = "";

#Define cluster variables
my $clustername = "";
my $node1 = "";
my $node2 = "";
my $node1ip = "";
my $node2ip = "";
my $cluster = "no";
my $partner = "";

#Check? Is this a cluster?
if (-e $cluster_conf) {#If cluster configuration exists, it is a cluster
 $cluster = "yes";
 
 #Get cluster name
 $clustername = `$cat $cluster_conf | $grep "CLUSTER_NAME"| $awk '{print \$2}'`;
 chomp($clustername);
 
 #Get first node name        
 $node1 = `$cat $cluster_conf| $grep MACHINE| $awk '{print \$2}'|head -1`; 
 chomp($node1);
	
 #Get second node name
 $node2 = `$cat $cluster_conf| $grep MACHINE| $awk '{print \$2}'|tail -1`;
 chomp($node2);
 
 #Get IP for node1
 $node1ip = `$grep '$node1\$' /etc/hosts |$awk '{print \$1}'`;
 chomp($node1ip);
	
 #Get IP for node2
 $node2ip = `$grep '$node2\$' /etc/hosts |$awk '{print \$1}'`;
 chomp($node2ip);

&copy_file_to_tmp("$cluster_conf"); 
}
 
# Get our pools
my @mypools = `zpool list |$awk '{ print \$1}'|$grep -v NAME|$grep -v syspool`;

#Create a temporal folder
print `$mkdir $tmp_dir`;

# Save checked files

&copy_file_to_tmp("/etc/hosts");
&copy_file_to_tmp("/kernel/drv/mpt_sas.conf");
&copy_file_to_tmp("/var/adm/messages*");
&copy_file_to_tmp("/etc/release");
&copy_file_to_tmp("/etc/system");


#Check if file exists and ask to overwrite it if exists 
if (-e $file) {#if the filename already exists promt user and ask user to overwrite it
 my $resp = &prompt_and_get_user_input("Do you want to overwrite $file [y/n]");
 if ($resp !~ /^y$/) {#exit if the user does not say y
  print "File '$file' will not be overwritten, exiting.\n";
  exit(1);
 }
}

#Create file or exit if can't 
my $file_desc;
open($file_desc, "+>", $file) or die "Exiting - Could not open $file: $!"; #open the file creating/truncating it if needed

my $date = `date`;
chomp($date);

# Creating result file header
&print_result("############################################################");
&print_result("###  Script started at $date   ###");
&print_result("############################################################");

###### Start License Check #####
 &print_result("\n ###################### License check ######################");

 #Show license for Nexenta
 &print_result("\n Show Nexenta license details");
 &print_nmc_cmd_output_to_file($file_desc, "show appliance license");

 #Show license for RSF
 &print_result("\n Show RSF license details");
 &print_bash_cmd_output_to_file($file_desc, $rsfmon);
 
##### End License check #####

##### Start DNS Check #####
 &print_result("\n ###################### DNS check ######################");
 
 #Check DNS ping www.nexenta.com
 &print_nmc_cmd_output_to_file($file_desc, "ping www.nexenta.com");
 my $nexenta = `$ping www.nexenta.com | $awk '{print \$3}'`;
 chomp($nexenta);
 
 #Check if ping answers alive if not, print host down
 if ( $nexenta ne 'alive' ){
  &print_result("Ping to www.nexenta.com DOWN");
  #TODO Is this a DarkSite?
 }else{
  &print_result("Ping to www.nexenta.com OK");
 }
 
##### End DNS Check #####

##### Start SMTP check #####
 &print_result("\n ###################### SMTP check ######################");
 
 #Check Mailer
 &print_nmc_cmd_output_to_file($file_desc, "setup appliance mailer verify");

#TODO Support bundle request

##### End SMTP check #####

##### Start NMV check #####
 &print_result("\n ###################### NMV check ######################");
 
 #TODO Check if NMV is password protected
 
 #Check if NMV is using SSL or not
 if (-e $apache_conf) {
  #Get NMV port for non SSL site
  my $nmv_port = `$cat $apache_conf|$grep "NameVirtualHost *"| awk -F : '{print \$2}'`;
  chomp($nmv_port);
  #Check NMV wget http://ip:2000 --http request
  &print_bash_cmd_output_to_file($file_desc, "$wget --progress=dot `hostname`:$nmv_port");
 }elsif ( -e $apache_conf2 ) {
  #Get NMV port for SSL site
  my $nmv_port = `$cat $apache_conf2|$grep "NameVirtualHost *"| awk -F : '{print \$2}'`;
  chomp($nmv_port);
  #Check NMW wget https://ip:2000 --https request
  &print_bash_cmd_output_to_file($file_desc, "$wget --no-proxy --no-check-certificate https://`hostname`:$nmv_port");
 }else{
  &print_result("Error: NMV port NOT FOUND, check NMV config");
  my $nmv_port = 0;
 }
 
 #Check? if nmv_port = 0 don't proceed with NMV check
 if ($nmv_port eq '0'){
  &print_result("Error: NMV port NOT FOUND, NMV check skipped");
 }else{
  #Check if we downloaded index.html or not
  my $wget2 = `ls -1rt index.html`;
  chomp($wget2);
  if ($wget2 eq 'index.html'){
   &print_result("Nexenta GUI WORKS!");
   #Remove index.html
   &print_bash_cmd_output_to_file($file_desc, "rm index.html");
  }else{
   &print_result("Error: Nexenta GUI is DOWN!");
  }
    
 }
  
##### End NMV check #####

##### Start NMC check #####
 &print_result("\n ###################### NMC check ######################");
 
 #Show appliance version
 &print_result("\n Running NMC command:");
 &print_nmc_cmd_output_to_file($file_desc, "show appliance version");
 
##### End NMC check #####

##### Start Disk Layout Check #####
 &print_result("\n ###################### Disk Layout check ######################");
 
 #Print show lun output
 &print_nmc_cmd_output_to_file($file_desc, "show lun");
 
 #Print show lun slotmap output
 &print_nmc_cmd_output_to_file($file_desc, "show lun slotmap");
 
##### End Disk Layout Check #####

##### Start ZVOL Check #####
 &print_result("\n ###################### ZVOL check ######################");
 
 #Print show zvol output
 &print_nmc_cmd_output_to_file($file_desc, "show zvol");
 
 #Get pools iostat
 &print_nmc_cmd_output_to_file($file_desc, "zpool iostat -v");

##### End ZVOL Check #####

##### Start Network Check #####
 &print_result("\n ###################### Network config check ######################");
 
 #Print default gateway
 &print_result("\n System Gateway:");
 &print_nmc_cmd_output_to_file($file_desc, "show network gateway");
 
 #Get default gateway
 my $gateway = `$cat /etc/defaultrouter`;
 chomp($gateway);
 
 #TODO check if gateway is alive 
 #Ping default gateway
 &print_result("Checking if gateway is alive");
 &print_bash_cmd_output_to_file($file_desc, "$ping $gateway");

 #TODO Convert this to function
 #Check if repositories are responding
 &print_result("\n Checking access to repositories:");
 $autosmart = `grep '\^deb\\ ' /etc/apt/sources.list | grep 'plugins' | awk '{print \$2"/dists/hardy-stable/main/Contents-solaris-i386.gz"}' | xargs -n1 wget -i - -O - -q -t 1 -T 45 | zcat -c | awk '{print \$2}' | sort | uniq|grep nmc-autosmart`;
 chomp($autosmart);
 &print_result("\n");
 if ($autosmart eq 'base/nmc-autosmart'){
  &print_result("Repository is UP!");
  &print_nmc_cmd_output_to_file($file_desc, "setup appliance upgrade -t"); 
 }else{
  &print_result("Error: Unable to reach to repository");
 }
  
#TODO Get all configured IPs x device
#TODO Check /etc/netmasks and see if all configured networks have netmask
#TODO Check if more than one IP in a subnet

##### End Network Check #####

##### Start Crash dump device check #####
 &print_result("\n ###################### Crash dump devices check ######################");
 
 #Check if crash dump directory exists
 &print_result("\n Checking if crash dump directory exists:");
 my $crash_dir = `$dumpadm|$grep "Savecore directory"|$sed 's/Savecore directory: //'`;
 chomp($crash_dir);
 if (-e $crash_dir) {
  &print_result("Crash dump directory exists.");
 }else{
  &print_result("Error: Crash dump directory NOT found.");
 }
 
 #Check if crash dump file exists
 &print_result("\n Checking if crash files exists:");
 my @crash_files = </var/crash/myhost/vmdump.*>;
 if (scalar(@crash_files) == 0){
  &print_result("No crash files found on this system.");
 }else{
  &print_result("Error: Crash files found.");
  &print_bash_cmd_output_to_file($file_desc, "$ls $crash_dir");
 }
 
 #Check if crash dump device is configured
 &print_result("\n Checking configured crash dump device:");
 my $dump_device = `$dumpadm|$grep "dedicated"`;
 chomp($dump_device);
 if (defined($dump_device)){
  &print_result("Configured dump device is:$dump_device");
 }else{
  &print_result("Error: No dedicated dump device");
 }
 
##### End Crash dump device check #####

##### Start Auto Scrub Check #####
 &print_result("\n ###################### Auto-Scrub check ######################");
 
 #Get auto-scrub configuration
 &print_result("\n Checking auto-scrub:");
 &print_nmc_cmd_output_to_file($file_desc, "show auto-scrub");

##### End Auto Scrub Check #####

##### Start Auto Sync Check #####
 &print_result("\n ###################### Auto-Sync check ######################");
 
 #Get auto-sync configuration
 &print_result("\n Checking auto-sync:");
 &print_nmc_cmd_output_to_file($file_desc, "show auto-sync");

##### End Auto Sync Check #####

##### Start Auto Snap Check #####
 &print_result("\n ###################### Auto-Snap check ######################");
 
 #Get auto-snap configuration
 &print_result("\n Checking auto-snap:");
 &print_nmc_cmd_output_to_file($file_desc, "show auto-snap");

##### End Auto Snap Check #####

##### Start MPIO check #####
 &print_result("\n ###################### MPIO check ######################");
 
 # Get MPXIO config and see if it is enabled
 &print_result("\n Checking /kernel/drv/mpt_sas.conf file:");
 my $mpxio_status = `$grep -i mpxio-disable /kernel/drv/mpt_sas.conf | $grep -v "#"`;
 chomp($mpxio_status);
 my $mpxio_ok = 'mpxio-disable="no";';
 if ( $mpxio_status eq $mpxio_ok ){
  &print_result("MPXIO is enabled");
 }else{
  &print_result("Error: MPXIO is NOT enabled");
 }
 
##### End MPIO check #####

##### Start OS version check #####
 &print_result("\n ###################### OS version check ######################");

 #OS version
 &print_result("\n OS details:");
 &print_bash_cmd_output_to_file($file_desc, "uname -a");
 
 #Nexenta version
 &print_result("\n Appliance version:");
 &print_nmc_cmd_output_to_file($file_desc, "show appliance version");
 
##### End OS version check #####

##### Start FMdump errors check #####
 &print_result("\n ###################### fmdump errors check ######################");
 &print_result("\n Saving fmdump errors to $fmdumpfile\n");
 
 #Create new file to save fmdump output
 my $file_desc6;
 open($file_desc6, ">", $fmdumpfile) or die "Exiting - Could not open $servicefile: $!"; #create the file 
 
 # Checking for errors in the last seven days
 &print_bash_cmd_output_to_file($file_desc6, "$fmdump -eV -t7day");

 # Checking for errors in the last one day
 &print_bash_cmd_output_to_file($file_desc6, "$fmdump -eV -t1day");

 close($file_desc6);
 
 &print_result("Check $fmdumpfile content");
 
##### End FMdump errors check #####

##### Start System logs check#####
 &print_result("\n ###################### System logs check ######################");
 
 #copying /var/adm/messages*
 &copy_file_to_tmp("/var/adm/messages*");
 
 #Check messages file for dump or SunOS
 &print_bash_cmd_output_to_file($file_desc, "$cat /var/adm/messages | egrep -i 'dump|SunOS'");

##### End System logs check#####

##### Start Check C-STATEs #####
 &print_result("\n ###################### C-STATES check ######################");
 
 #Check c-states
 &print_bash_cmd_output_to_file($file_desc, "/usr/bin/kstat | grep supported_max_cstates");

 my @cstates = `/usr/bin/kstat | grep supported_max_cstates| awk '{ print \$2}'| uniq`;
 foreach my $cstate (@cstates) {
  chomp($cstate);
  #Checking if any of the values is different than 0 or 1
  if ( $cstate > 1 ) {
  &print_result("Error: Check C-STATES");
  }else{
   &print_result("C-STATES values are 0 or 1");
  }
 }
##### End Check C-STATEs #####

############################  Starting Cluster Checks #######################
 
 #If it is a cluster proceed
 if ($cluster eq 'yes'){
  &print_result("\n ################## Starting Cluster Checks #################");
  
  #Print Clustername
  &print_result("Cluster name is: $clustername");
  
  #Print SSH-BIND
  &print_result("\n ####### Checking SSH-BINDINGS #######");
  &print_nmc_cmd_output_to_file($file_desc, "show network ssh-bindings");
  
  &print_result("\n ####### Getting Admin interfaces #######");
  #Check which of both IPs is our IP and get who is our partner
  my @ips = `ifconfig -a | $grep inet| $grep -v inet6 | $grep -v '127.0.0.1' | $awk '{ print \$2}'`;
  foreach my $ip ( @ips) {
   chomp($ip);
   if ( $ip eq $node1ip ){
    &print_result("\n$ip is our admin IP");
    $partner = $node2;
    &print_result("\n$node2ip is our partner admin IP");
   }elsif ( $ip eq $node2ip ){
    &print_result("\n$ip is our admin IP");
    $partner = $node1;
    &print_result("\n$node1ip is our partner admin IP");
   }else{
    print "$ip is not our admin interface! \n";
   }
  }
  
  &print_result("\n ####### Checking IP connectivity between nodes #######");
  #Get partner name configured at ssh-bind
  my $ssh_bind = `nmc -c "show network ssh-bindings" | $grep "$partner"|$awk '{ print \$1}'|$awk -F "\@" '{ print \$2}'`;
  $ssh_bind =~ s/\n//g;
  chomp($ssh_bind);
  
  #Get all partners IPS
  &print_result("\n Connecting to $ssh_bind to test IPs");
  
  my @partnerips = `ssh root\@$ssh_bind ifconfig -a | $grep inet| $grep -v inet6 | $grep -v '127.0.0.1' | $awk '{ print \$2}'`;
  
  #Print that we are connected to partner
  
  # Checking which IPs are alive
  my $alive ='';
  foreach my $partnerip ( @partnerips) {
   chomp($partnerip);
   $alive = `$ping $partnerip | $awk '{print \$3}'`;
   chomp($alive);
   if ( $alive eq 'alive' ){
    &print_result("$partnerip is alive");    
   }else{
    &print_result("Warning $partnerip is down");
   } 
  }
  
  # Get the second node name from cluster file - Some setup use FQDN and some don't
  my $short_partner_name = `$echo $ssh_bind | $sed 's/\\\.\[\^ \]\*/ /g'`;
  chomp($short_partner_name);
  my $cluster_partner = `$cat $cluster_conf |$grep MACHINE|$awk '{print \$2}'|grep $short_partner_name`;
  chomp($cluster_partner);
  
  &print_result("\n ######### Checking zpools #########");
  # Check our pools
  &print_bash_cmd_output_to_file($file_desc, "zpool list");
  
  &print_result("\n ######### Failing zpools to partner #########");
  &print_result("\n note: if not pools were found this section will be empty.");
  #TODO if @pools = 0 don't print header
  my @pools = `zpool list |$awk '{ print \$1}'|$grep -v NAME|$grep -v syspool`;
  foreach my $pool ( @pools) {
   chomp($pool);
   
   #Failover pools to partner
   &print_nmc_cmd_output_to_file($file_desc, "setup group rsf-cluster $clustername shared-volume $pool failover $cluster_partner");
   
   &print_result("\n Checking zpool after failover");
   &print_bash_cmd_output_to_file($file_desc, "zpool list");
   
   &print_result("\n Checking zpool after failover on $cluster_partner");
   &print_bash_cmd_output_to_file($file_desc, "ssh root\@$cluster_partner zpool list");
     
  }
   
  &print_result("\n ######### END Cluster Checks #########");
 }else{
  &print_result("This is not a cluster");
 }
 
############################  End Cluster Checks #######################
 close($file_desc);

# Ask if user wants to Reboot
 my $rebooty = &prompt_and_get_user_input("Do you want to REBOOT the node [y/n]");
 if ($rebooty !~ /^y$/) { #exit if the user does not say y
  print "No Reboot, exiting.\n";
  
  # Pack and compress all temp files
  print `$tar -cvf - -C $tmp_dir . | $bzip2 -9 - > $sac_pack`;
  
  # Remove temporal files
  print `$rm $tmp_dir`;
  
  # Print autosac packet location
  print "Your autosac packet is: '$sac_pack' \n";
  
  # Reminder
  print "Remember to provide this packet and a support bundle to the SUPPORT TEAM \n";
  
  exit(1);
  
 }else{#User said he wants to reboot

######## Start creating script #########
  my $reboot_time=`date +'%s'`;
  chomp($reboot_time);
  
  my $scriptfile_content_p1 = <<"SCRIPTFILE_P1";
#!/bin/bash
#
# Author: Sajid Ashiq
# Mail: sajid.ashiq\@nexenta.com
#
#ident  "@(#)sacservice    1.14"    06/11/17 SMI
#
case "\$1" in
'start')
        if [ ! -f /export/home/admin/foo ]
        then
                touch "/export/home/admin/foo"
                exit 0
        else
            reboot="$reboot_time"
            start=`date +'%s'`    
        	echo "System started reboot at: \$reboot" >> "$file"
        
        	echo "System started at : \$start" >> "$file"
        	let result=\$start-\$reboot
        	
        	if [ \$result -gt 1200 ]
        	then
        	 echo Error: It took \$result seconds to reboot >> "$file"
        	else
        	 echo System took \$result seconds to reboot >> "$file"
        	fi
        	
        	 echo "" >> "$file"
        	 cluster="$cluster"
            if [ "\$cluster" = "yes" ]
            then
        	 ############ Checking if cluster is ready (5 rsfmon processes)
        	 rsfmons=`ps -ef|grep rsfmon|grep -v "grep rsfmon"|wc -l`
        	 while [ \$rsfmons -lt 5 ]
             do
        	  sleep 10
        	  rsfmons=`ps -ef|grep rsfmon|grep -v "grep rsfmon"|wc -l`
        	 done
        	 sleep 300
        	 echo "" >> "$file"
        	 echo Failing over pools to their original place >> "$file"
SCRIPTFILE_P1

my $scriptfile_content_p2 = <<"SCRIPTFILE_P2";
        
             echo "" >> "$file"
             echo "Checking if any failover mode in manual" >> "$file"
             manualfail=(`$rsfcli status|grep manual|awk '{print \$5}'`)
             for i in "\${manualfail[@]}"
             do
              echo "###### Changing failover mode for \$i to automatic ######" >> "$file"
              $rsfcli -h \$i automatic >> "$file"
             done
             echo "Done..." >> "$file"
             echo "" >> "$file"
             echo "Checking current pools status" >> "$file"
             zpool list >> "$file"
             echo "" >> "$file"
             echo "########### Cluster status now ############" >> "$file"
             $rsfcli status >> "$file"
             echo "###########################################" >> "$file"
            fi
            echo "########### Content of /etc/hosts #########" >> "$file"
            cat "/etc/hosts" >> "$file"
            
            echo "###########################################" >> "$file"
            echo "########### Content of /etc/system #########" >> "$file"
            cat "/etc/system" >> "$file"
            echo "###########################################" >> "$file"
            
           # Pack and compress all temp files
             $tar -cvf - -C $tmp_dir . | $bzip2 -9 - > $sac_pack 
             # Remove temporal files 
             $rm $tmp_dir 
             rm '$script'
             rm '/etc/rc2.d/S99sacscript' 
             rm '/export/home/admin/foo'
        
       fi
        ;;

'stop')
     /usr/bin/pkill -x -u 0 sacservice
        ;;

*)
        echo "Usage: \$0 { start | stop }"
        ;;
esac
exit 0

SCRIPTFILE_P2

 # Create script that will run after reboot
 my $file_desc4;
 open($file_desc4, ">", $script) or die "Exiting - Could not open $script: $!"; #create the file
 print $file_desc4 $scriptfile_content_p1;
 
 # Check if it is a cluster to add failover section to BASH script
 if ($cluster eq 'yes'){
  my $short_hostname = `hostname | $sed 's/\\\.\[\^ \]\*/ /g'`;
  chomp($short_hostname);
  my $cluster_host = `$cat $cluster_conf |$grep MACHINE|$awk '{print \$2}'|grep $short_hostname`;
  chomp($cluster_host);
  # Adding lines to failover pools
  foreach my $mypool ( @mypools) {
   chomp($mypool);
   #Failover pools to this machine
   print $file_desc4 "nmc -c \"setup group rsf-cluster $clustername shared-volume $mypool failover $cluster_host\"  >> \"$file\" \n";
   
  }
  
  #Check if any of the pools is in manual failover
  my @manualfails = `$rsfcli status|grep manual|awk '{print \$5}'`;
  
  foreach my $manualfail ( @manualfails) {
   chomp($manualfail);
   #Set failover to automatic
   print `$rsfcli -h $manualfail automatic`;
  }
 }
  
 print $file_desc4 $scriptfile_content_p2; 
 close($file_desc4);

 # Changing file permissions
 print `chmod 544 $script`;
 
 # Create link to run script on startup
 print `ln -s $script /etc/rc2.d/S99sacscript`;
 
######## End creating script #########
  # Print autosac packet location
  print "Your autosac packet will be saved after reboot at: '$sac_pack' \n";
  
  # Reminder
  print "Remember to provide this packet and a support bundle to the SUPPORT TEAM \n";
     
   # Rebooting appliance
   print `$script start \&`;
   print "Rebooting \n";
   print "This script will take upto 10 minutes after boot to end \n";
   print `nmc -c "setup appliance reboot -y"`;
  
   exit(0); 
 
 }


############  Subroutines ############
#get user input for certain commands
sub prompt_and_get_user_input( $ ) {
 my $msg = shift;
 assert($msg);
 
 print $msg.": ";
 my $input = <STDIN>;
 chomp $input;
 
 return $input;
}

#TODO if output null print something
#returns the output of nmc cmd
sub print_nmc_cmd_output_to_file( $$ ) {
 my $fd = shift;
 assert($fd);
 my $cmd = shift;
 assert($cmd);
 
 print $fd "\nOutput from nmc '$cmd':\n";
 print $fd `nmc -c '$cmd' 2>&1`or die;
 
 print "nmc '$cmd' output saved to file\n";
}
 
#returns the output of shell cmd
sub print_bash_cmd_output_to_file( $$ ) {
 my $fd = shift;
 assert($fd);
 my $cmd = shift;
 assert($cmd);
 
 print $fd "\nOutput from shell '$cmd':\n";
 print $fd `$cmd 2>&1` or die;
 
 print "shell '$cmd' output saved to file\n";
}
 

#Copy used files to a $dir_tmp
sub copy_file_to_tmp ( $ ) {
 my $new_file = shift;
 assert($new_file);
			
 print `$cp $new_file $tmp_dir` or die;
}

#Print to result file
sub print_result ( $ ){
 my $result = shift;
 assert($result);
 
 print $file_desc "$result \n" ;
}