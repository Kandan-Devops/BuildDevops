#!/usr/bin/python

#to perform ipcalc netmask conversion command
import os

# sys module provides access to any command-line arguments via the sys.argv
import sys

# Import `xlrd` python module to perform read operation from xlsx buildsheet, used the command "pip install xlrd" to install xlrd module in controller machine
import xlrd

# Import terraform python module, used the command "pip install python-terraform" to install the module in controller machine
#triggering terraform from python reference: https://geekdudes.wordpress.com/2018/02/13/using-python-wrapper-with-terraform/
from python_terraform import *

# Open the buildsheet
buildsheet = xlrd.open_workbook('buildsheet.xlsx')

# Load the server details sheet by name
srv_det_sheet = buildsheet.sheet_by_name('Server List')

#Arguments passed in cmdline 
vcenter_user=sys.argv[1]
vcenter_password=sys.argv[2]
domain_admin_user=sys.argv[3]
domain_admin_password=sys.argv[4]
local_admin_pass=sys.argv[5]
root_password=sys.argv[6]
new_root_password=sys.argv[7]
new_admin_password=sys.argv[8]
row=int(sys.argv[9])
slack_token_url=sys.argv[10]

#Fetching inputs from buildsheet
host_name =  srv_det_sheet.cell_value(row, 0)
os_type = srv_det_sheet.cell_value(row, 1)
os_template =  srv_det_sheet.cell_value(row, 3)
domain =  srv_det_sheet.cell_value(row, 9)
vcpu =  int(srv_det_sheet.cell_value(row, 11))
mem =  int(srv_det_sheet.cell_value(row, 12))
mb = int(1024)
mem = (mb*mem)
vcenter_host =  srv_det_sheet.cell_value(row, 13)
dc =  srv_det_sheet.cell_value(row, 14)
clus =  srv_det_sheet.cell_value(row, 15)
ds =  srv_det_sheet.cell_value(row, 16)
nw =  srv_det_sheet.cell_value(row, 17)
host_ip =  srv_det_sheet.cell_value(row, 18)
netmask =  srv_det_sheet.cell_value(row, 19)
netmask = os.popen('ipcalc ' + host_ip + ' -p ' + netmask + ' | cut -d "=" -f2').read()
netmask = int(netmask)
gw =  srv_det_sheet.cell_value(row, 20)
dns1 =  srv_det_sheet.cell_value(row, 21)
dns2 =  srv_det_sheet.cell_value(row, 22)

d1 =  int(srv_det_sheet.cell_value(row, 35))
d1typ = srv_det_sheet.cell_value(row, 34)
if d1typ == 'Thin':
 d1typ = 'true'
else:
 d1typ = 'false'

d2 =  int(srv_det_sheet.cell_value(row, 38))
d2typ = srv_det_sheet.cell_value(row, 37)
if d2typ == 'Thin':
 d2typ = 'true'
else:
 d2typ = 'false'

print("Checking the resource availability status to initiate the build for hostname ( " + host_name + " ) and IP ( " + host_ip + " ) to provision VM in ( " + vcenter_host + " ) using the OS template ( " + os_template + " )..........")

#defining the function for slack notification
def my_slack(STATUS): 
 null_output = os.popen('/usr/bin/sh Scripts/slack_webhook.sh ' + slack_token_url + ' ' + STATUS + ' ' + host_name + ' ' + host_ip + ' ' + vcenter_host + ' ' + os_template).read()
   
#check if hostIP or hostname already exists
HOST_STATUS = os.popen('/usr/bin/sh Scripts/check_existing_host.sh ' + vcenter_host + ' ' + vcenter_user + ' ' + vcenter_password + ' ' + host_ip + ' ' + host_name).read().rstrip()
print("Vcenter host check status: " + HOST_STATUS)
if HOST_STATUS == "no_data_exists":
 #check if selected os template available or not in the vcenter
 TEMPLATE_STATUS = os.popen('/usr/bin/sh Scripts/check_template_exists.sh ' + vcenter_host + ' ' + vcenter_user + ' ' + vcenter_password + ' ' + os_template).read().rstrip()
 print("Vcenter OS template availability status: " + TEMPLATE_STATUS)
 if TEMPLATE_STATUS == "template_not_available_in_vCenter": 
  my_slack(TEMPLATE_STATUS)
  exit()
 #Here starts the terraform operation to provision the VM.
 if os_type.lower() == 'Windows'.lower(): 
  os.popen('cd Windows/Ansible_Code; echo [windows] > hosts.yml ; echo ' + host_ip + ' >> hosts.yml' )
  tf = Terraform(working_dir='Windows/Terraform_Code', variables={'slack_token_url':slack_token_url, 'vcenter_user':vcenter_user, 'vcenter_password':vcenter_password, 'vcenter_host':vcenter_host, 'dom_admin_user':domain_admin_user, 'dom_admin_password':domain_admin_password, 'local_admin_pass':local_admin_pass, 'host_name':host_name, 'os_template':os_template, 'dom':domain, 'vcpu':vcpu, 'mem':mem, 'dc':dc, 'clus':clus, 'ds':ds, 'nw':nw, 'host_ip':host_ip, 'netmask':netmask, 'gw':gw, 'dns1':dns1, 'dns2':dns2, 'd1':d1, 'd1typ':d1typ, 'd2':d2, 'd2typ':d2typ})
  tf.plan(no_color=IsFlagged, refresh=False, capture_output=True)
  print(tf.init()) 
  print(tf.plan())
  print(tf.apply())
  #checking if the terraform executed successfully or not by getting the presence of tfstate file
  exists = os.path.isfile('Windows/Terraform_Code/terraform.tfstate')
  if exists:
    os.system('mv Windows/Terraform_Code/terraform.tfstate temp/terraform.tfstate-' + str(row))
  else:
    HOST_STATUS="terraform_failed"
    my_slack(HOST_STATUS)
 elif os_type.lower() == 'Linux'.lower():
  os.popen('cd Linux/Ansible_Code; echo [linux] > hosts.yml ; echo ' + host_ip + ' >> hosts.yml' )
  tf = Terraform(working_dir='Linux/Terraform_Code', variables={'slack_token_url':slack_token_url, 'vcenter_user':vcenter_user, 'vcenter_password':vcenter_password, 'vcenter_host':vcenter_host, 'root_password':root_password, 'new_root_password':new_root_password, 'new_admin_password':new_admin_password, 'host_name':host_name, 'os_template':os_template, 'dom':domain, 'vcpu':vcpu, 'mem':mem, 'dc':dc, 'clus':clus, 'ds':ds, 'nw':nw, 'host_ip':host_ip, 'netmask':netmask, 'gw':gw, 'dns1':dns1, 'dns2':dns2, 'd1':d1, 'd1typ':d1typ, 'd2':d2, 'd2typ':d2typ})
  tf.plan(no_color=IsFlagged, refresh=False, capture_output=True)
  print(tf.init()) 
  print(tf.plan())
  print(tf.apply())
  #checking if the terraform executed successfully or not by getting the presence of tfstate file
  exists = os.path.isfile('Linux/Terraform_Code/terraform.tfstate')
  if exists:
    os.system('mv Linux/Terraform_Code/terraform.tfstate temp/terraform.tfstate-' + str(row))
  else:
    HOST_STATUS="terraform_failed"
    my_slack(HOST_STATUS)
 else:
  print("unable to check the OS type, please contact the administrator")
else:
  if HOST_STATUS == "host_ip_already_exists":
    print('********************************* The requested IP ( ' + host_ip + ' ) already exists *************************************')
    my_slack(HOST_STATUS)
  elif HOST_STATUS == "hostname_already_exists":
    print("******************************** The requested HOSTNAME ( " + host_name + " ) already exists **********************************")
    my_slack(HOST_STATUS)
  elif HOST_STATUS == "host_ip_and_hostname_already_exist":
    print("************************* The requested HOSTNAME ( " + host_name + " ) and the IP ( " + host_ip + " ) are already exist ************************")
    my_slack(HOST_STATUS)
  else:
    HOST_STATUS="vcenter_connection_failed"
    print("*********** Trouble in checking host allocated status with Vcenter, either connectivity issue or attempting with wrong credentials!. please check with the administrator ************************")
    my_slack(HOST_STATUS)