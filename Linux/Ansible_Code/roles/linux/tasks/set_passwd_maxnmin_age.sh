#!/bin/sh

echo Setting password max and min age
for i in `cat /etc/passwd |egrep -v "nologin|sync|shutdown|halt" |awk -F: '{print $1}'`;do chage -m $1 $i;done  
for i in `cat /etc/passwd |egrep -v "nologin|sync|shutdown|halt" |awk -F: '{print $1}'`;do chage -M $2 $i;done
echo Password min and max age setting completed successfully       
