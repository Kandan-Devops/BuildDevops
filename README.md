#Build Devops
=============

## Introduction :- 

The objective of this solution includes end to end automation of provisioning and configuration of Virtual Machine on a Vmware Vsphere infrastructure. large portion of our infrastructure business still runs on classic VMware infrastructure. There has been mutliple tries to build autiomation in virtual machine provisioning and configuration, however due to complex workflow and lack of integration we were not been able to achieve end to end automation in this area.

With new Devops methods, tools, API integration and configuration management, we have built an end to end packaged solution which can truely established automation of vmware VM provision and configuration on a vsphere infrastruture.

Input  :  standard build sheet used across IBM.

Output :  IP address & Hostname of newly provisioned and Configured VM. 

**Here is the high level workflow:**

1. Build check list commited by a engineer on a git repo, build sheet is validated by SME/Customer.
2. Once the build sheet approved at Git a jenkin job starts to convert the build sheet into a terraform code.
3. Second job starts with a terraform code execution which connects to vpshere and build the VM based on build sheet.
4. Once the Build is completes, Third job of jenkins will start invoke Ansible to install/configure tools.
5. Once the configuration completes, Fourth job starts to capture the Name and IP address of newly provisioned VM and send it to Slack Channel.
6. In every step there are multiple validation / Error Handling code in place to aviod issues.

## Tools & Technology are used to build this solution. 


## Installation & Configuration :-
  1. Terraform  
  2. Ansible  
  3. Jenkins
  4. Gitlab 
  5. PowerCli 
  6. Python
  7. Vmware Vsphere
  
Pre-Requisites
--------------

Control VM ( RHEL / Centos / Ubuntu)  - This machine is required to setup BuildDevops pipeline.

__Control VM Hardware Specifications :-__

Processor   : 2 CPU's
Memory      : 4 GB
Storage     : 100 GB (Including OS disk)
Netowrk     : 1 Nic card (1 Gbps) speed.

**Note  :- One time Internet connectivity is required to setup (Ansible, Jenkins & Updates).**

Install the below software components on the Control VM to build this solution.   

  1. Terraform  
  2. Ansible  
  3. Jenkins
  4. Gitlab 
  5. PowerCli 
  6. Python
  
This repository assumes all the required softwares are installed  in a Linux machine which is considered as control machine.

Jenkins installation :-  Refer the following URL to install Jenkins latest version

https://jenkins.io/doc/book/installing/ 

Terraform Installation :-  Please refer this URL

https://www.terraform.io/downloads.html 

Gitlab Installation :- Please refer this URL. It's used to create Private Repository in the internal Network.

https://linuxize.com/post/how-to-install-and-configure-gitlab-on-centos-7/

Ansible Installatoin :- Refer the following URL to install Ansible latest version .

http://docs.ansible.com/ansible/latest/intro_installation.html

Ansible Setup guide: Ansible can be run from any machine with Python 2 (versions 2.6 or 2.7) or Python 3 (versions 3.5 and higher) installed (Windows isn’t supported for the control machine). This includes Red Hat Enterprise Linux (RHEL), Debian, CentOS, OS X, any of the BSDs, and so on. It communicates over normal SSH or WinRm channels in order to retrieve information from remote machines, issue commands, and copy files.

Bigfix Client Installation :-

User can download BigFix binary files from BigFix Enterprise Suite Download Center link: 

http://support.bigfix.com/bes/release/9.5/patch11/


Powershell CLI Installation:- Refer the following URL to install powershell in Linux,  
https://bgstack15.wordpress.com/2019/04/15/install-powershell-and-powercli-on-centos-7-linux/

Python:- Python 2.6 or later is required to be installed in control machine. And certain modules like xlrd, python-terraform are required to support the excel data import and terraform VM deployment respectively.


## Configuration Steps:
----------------------

**GitLab Configuration :-**

1)	Post GitLab Installation, create new Project and new Repository in GitLab
2)	Create new repo with similar files and folder structure as per Github ( previously defined) 

**Slack Configuration :-**

1)	Go to Slack, create new workspace or use existing one.
2)	Create new channel as required
3)	Go to Apps in Slack, browse through ‘Incoming webhooks' and configure required parameters under 'custom configuration'.

**BigFix Agent Configuration :-**
1) Update the BigFix binary file location on the Ansible playbook variable file in the following path: "projectFolder/Ansible_Code/group_vars/input_vars.yml" 
2) Ensure the following parameter set on projectFolder/Ansible_Code/group_vars/windows  file for windows VM provision.

 	"ansible_connection: winrm" 
 
 	"ansible_winrm_transport: basic" 
 
 	"ansible_winrm_port: 5985" 
 


**Jenkins Configuration:-**

1)	Create new job (free style project) with parametrised job, includes vCenter username, password, Domain admin username, password and local administrator username, password, these details are masked by password plugins in Jenkins.
2)	The above details are passed to terraform as an input variable in encrypted format.
3)	Enable the webhook trigger in Jenkins and integrate with GIT repository to auto trigger the Jenkins build whenever the new buildsheet.xlsx is uploaded in GIT.
4)	Configure GIT repository details (URL) under Source code management in Jenkins to integrate GIT repo provider.
5)	Go to build trigger tab in Jenkins, enable check box for "Build when a change is pushed to GIT"
6)	Enable below check boxes under Jenkins ‘Build Environment tab’
o	"Delete workspace before build starts", 
o	"Mask passwords and regexes (and enable global passwords)"
7)	Go to build tab in Jenkins, select execute shell and type "sh jenkins_build.sh" in the command text box.
	Enable slack notification by providing the required slack details from Jenkins ‘configuration settings’
9)	Go to ‘Post-Build Actions’ in Jenkins, enable the following slack notifications:
o	Notify Build Start, Notify Success, Notify Unstable, Notify Every Failure, Notify Back to Normal.
10)	Finally save the build job in Jenkins.

Execution flow
---------------

1. Input the build Sheet, which is an excel sheet file containing the config details of a VM. Download the latest version of  "buildsheet.xlsx" from the GitHub and update the details in each row in the same format. In the Column heading "Operating system template",  Provide exact VM template name as per the vCenter (For exmaple windows2016 sever need to build, provide correct vm template name in the column). 

2. It can trigger multiple VM provisioning sequentially provided each VM configuration details row by row in the buildsheet. 
     **Note: In the Build sheet each  column info is very sensitive and therefore changing the Column position will affect the whole deployment.**

3. Once completing the buildsheet.xlsx update, upload it to GIT repo. The Git repo master branch  can be restricted from direct push by establishing a developer branch in order to validate the buildsheet  by Peer SME/SDM/Client/Any authorize person or can do direct master branch push depending on the client requirement. 

4. Upon buildsheet approval, it will then auto trigger the jenkins with the credentials already configured in jenkins.

5. Jenkin will trigger python script to pick values from build sheet and pass to terraform configuration.

6. Teraform will start provision VM applying the configuration details fetched from the build sheet. 

7. Once the Teraform VM provision completes, It will run Guest Customization tasks on both Windows / Linux VM's ( like Assign IP address, configure DNS, Domain join etc).  

8. It Would start Post provision tasks, Will invoke Ansbile playbook to install bigfix Client agent on the VM. 

9. Once the deployment successfully completes, Notification will send to the Slack channel with newly created VM Name and IP  address. 

## Contact List :-

**If you have any queries / help needed to setup this solution, Please reach out to the below team members.**

- Souri Subudhi  	 	Delivery Leader (Devops) Mail ID : ssubudh1@in.ibm.com 

-  K Kandan			Cloud Infra Architect    Mail ID : kandk017@in.ibm.com 

- Emin Asif Abdul Azeez 	Devops Engineer		 Mail ID : eabdul26@in.ibm.com 

- Richard D Chinnappan		Devops Engineer		 Mail ID : rchinnap@in.ibm.com 




