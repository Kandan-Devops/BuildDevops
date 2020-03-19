#!/usr/bin/sh

VCENTER_HOST=$1
VCENTER_USER=$2
VCENTER_PASS=$3
VM_TEMPLATE=$4

TEMPLATE_STATUS="false"

pwsh Scripts/get_template_list.ps1 $VCENTER_HOST $VCENTER_USER $VCENTER_PASS 1> temp/vmware_template_list.txt
for TEMPLATE in `cat temp/vmware_template_list.txt`
 do
  if [ $TEMPLATE == $VM_TEMPLATE ]
   then
    TEMPLATE_STATUS="template_available"
    echo $TEMPLATE_STATUS
    exit 0
  elif [ $TEMPLATE != $VM_TEMPLATE ]
   then
    TEMPLATE_STATUS="template_not_available_in_vCenter"
  fi
done

echo $TEMPLATE_STATUS