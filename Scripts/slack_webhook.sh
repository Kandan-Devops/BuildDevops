#!/usr/bin/sh

SLACK_TOKEN_URL=$1
JOB_STATUS=$2
HOST_NAME=$3
HOST_IP=$4
VCENTER_HOST=$5
OS_TEMPLATE=$6

SLACK_NOTIFY()
{
 SLACK_TOKEN_URL=$1
 MESSAGE=$2
 curl -X POST --data-urlencode "payload={\"channel\": \"#build-as-a-service\", \"username\": \"Terraform-vSphere\", \"text\": \"$MESSAGE\", \"emoji\": \":vsphere:\"}" $SLACK_TOKEN_URL
}

if [ $JOB_STATUS == "SUCCESS"  ]; then
 MESSAGE="Provisioned a new VM: ' $HOST_NAME ' and its IP address: ' $HOST_IP ' in vCenter ' $VCENTER_HOST '."
 SLACK_NOTIFY "$SLACK_TOKEN_URL" "$MESSAGE"

elif [ $JOB_STATUS == "terraform_failed"  ]; then
 MESSAGE="Terraform failed to provision the VM: ' $HOST_NAME ' with IP address: ' $HOST_IP ' in Vcenter ' $VCENTER_HOST '. Please check the jenkins build console for detailed log."
 SLACK_NOTIFY $SLACK_TOKEN_URL "$MESSAGE"

elif [ $JOB_STATUS == "NEXT_ROW"  ]; then
 MESSAGE="Initiating the build for next row of the buildsheet....!"
 SLACK_NOTIFY $SLACK_TOKEN_URL "$MESSAGE"

elif [ $JOB_STATUS == "host_ip_already_exists" ]; then
 MESSAGE="Ignoring the current build task, IP address: ' $HOST_IP ' is already exists in vCenter ' $VCENTER_HOST '."
 SLACK_NOTIFY $SLACK_TOKEN_URL "$MESSAGE"

elif [ $JOB_STATUS == "hostname_already_exists" ]; then
 MESSAGE="Ignoring the current build task, Hostname: ' $HOST_NAME ' is already exists in vCenter ' $VCENTER_HOST '."
 SLACK_NOTIFY $SLACK_TOKEN_URL "$MESSAGE"

elif [ $JOB_STATUS == "host_ip_and_hostname_already_exist" ]; then
 MESSAGE="Ignoring the current build task, Hostname: ' $HOST_NAME ' and IP address: ' $HOST_IP ' are already exist in vCenter ' $VCENTER_HOST '."
 SLACK_NOTIFY $SLACK_TOKEN_URL "$MESSAGE"

elif [ $JOB_STATUS == "template_not_available_in_vCenter" ]; then
 MESSAGE="Ignoring the current build task with Hostname: ' $HOST_NAME ' and IP address: ' $HOST_IP ', Selected OS template ' $OS_TEMPLATE ' not available in the vCenter  ' $VCENTER_HOST '."
 SLACK_NOTIFY $SLACK_TOKEN_URL "$MESSAGE"

elif [ $JOB_STATUS == "vcenter_connection_failed" ]; then
 MESSAGE="Trouble in connecting vCenter ' $VCENTER_HOST 'for checking the availability of Hostname: ' $HOST_NAME ' and IP address: ' $HOST_IP '. Due to wrong vCenter credentials or the vCenter is currently not online."
 SLACK_NOTIFY $SLACK_TOKEN_URL "$MESSAGE"
 
else
 MESSAGE="Trouble in getting current build status. Please check the jenkins console or contact the administrator"
 SLACK_NOTIFY $SLACK_TOKEN_URL "$MESSAGE"

fi