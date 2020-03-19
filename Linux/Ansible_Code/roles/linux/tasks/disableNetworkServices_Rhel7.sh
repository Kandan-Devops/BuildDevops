#!/bin/sh

echo "Disable Network Services for RHEL 7 "

# If RHEL7 ----- To disable service
for i in `cat /var/tmp/services`;do echo $i;/usr/sbin/systemctl disable $i;done

echo "Disabled Network Services for RHEL 7 "

echo " Stop Network Services for RHEL 7 "
# If RHEL7 ----- To stop service
for i in `cat /var/tmp/services`;do echo $i;/usr/sbin/systemctl stop $i;done 

echo "Stopped Network Services for RHEL 7" 
