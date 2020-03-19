#!/bin/sh

echo "Disable Network Services for RHEL 6"
#If RHEL6 ----- To disable service
for i in `cat /var/tmp/services`;do echo $i;/usr/sbin/chkconfig $i off;done

echo "Disabled Network Services for RHEL 6" 

echo "Stop Network Services for RHEL 6"
$If RHEL6 ----- To stop service
for i in `cat /var/tmp/services`;do echo $i;/usr/sbin/chkconfig $i stop;done 
echo "Stopped Network Services for RHEL 6"
