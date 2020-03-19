#!/usr/bin/sh

VCENTER_HOST=$1
VCENTER_USER=$2
VCENTER_PASS=$3
VM_HOSTIP=$4
VM_HOSTNAME=$5

HOST_STATUS="false"

pwsh Scripts/get_existing_host.ps1 $VCENTER_HOST $VCENTER_USER $VCENTER_PASS 1> temp/vmware_host_allocated_list.txt
for IP in `cat temp/vmware_host_allocated_list.txt  | awk '{print $2}'`
 do
  if [ $IP == $VM_HOSTIP ]
  then
    HOST_STATUS="host_ip_already_exists"
    for HOSTNAME in `cat temp/vmware_host_allocated_list.txt | awk '{print $1}'`
    do
      if [ $HOSTNAME == $VM_HOSTNAME  ]
        then
        HOST_STATUS="host_ip_and_hostname_already_exist"
        echo "$HOST_STATUS"
        exit 0
      else
        continue
      fi
    done
    echo "$HOST_STATUS"
    exit 0
  else
    HOST_STATUS="no_data_exists"
  fi
done

for HOSTNAME in `cat temp/vmware_host_allocated_list.txt | awk '{print $1}'`
 do
  if [ $HOSTNAME == $VM_HOSTNAME  ]
  then
    HOST_STATUS="hostname_already_exists"
    echo "$HOST_STATUS"
    exit 0
  else
    HOST_STATUS="no_data_exists"
  fi
done
echo $HOST_STATUS