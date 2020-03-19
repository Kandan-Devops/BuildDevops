data "vsphere_datacenter" "dc" {
    name = "${var.dc}"
}
data "vsphere_datastore" "dsname" {
    name          = "${var.ds}"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_compute_cluster" "cluster1" {
    name          = "${var.clus}"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "nw" {
    name = "${var.nw}"
     datacenter_id = "${data.vsphere_datacenter.dc.id}"
}
data "vsphere_virtual_machine"  "vmtemplate" {
    name = "${var.os_template}"
    datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "winvm" {
    name             = "${var.host_name}"
    resource_pool_id = "${data.vsphere_compute_cluster.cluster1.resource_pool_id}"
    datastore_id     = "${data.vsphere_datastore.dsname.id}"
    annotation       = "VM Provisioned through Automation Pipeline"

    num_cpus    = "${var.vcpu}"
    memory      = "${var.mem}"
    guest_id    = "${data.vsphere_virtual_machine.vmtemplate.guest_id}"
    scsi_type   = "${data.vsphere_virtual_machine.vmtemplate.scsi_type}"

    cpu_hot_add_enabled    = true
    cpu_hot_remove_enabled = true
    memory_hot_add_enabled = true
    boot_delay             = "5000"
    wait_for_guest_net_timeout = "10"
    wait_for_guest_ip_timeout =  "10"
    # wait_for_guest_net_routable = false

    network_interface {
        network_id = "${data.vsphere_network.nw.id}"
        #adapter_type = "${data.vsphere_virtual_machine.vmtemplate.network_interface_types[0]}"
        adapter_type = "vmxnet3"
    }

    disk {
        label  = "disk0"
        unit_number = 0
        #size             = "${data.vsphere_virtual_machine.vmtemplate.disks.0.size}"  
        size = "${var.d1}"
        eagerly_scrub    = "${data.vsphere_virtual_machine.vmtemplate.disks.0.eagerly_scrub}"
        #thin_provisioned = "${data.vsphere_virtual_machine.vmtemplate.disks.0.thin_provisioned}"
        #eagerly_scrub    = false
        thin_provisioned = "${var.d1typ}"     
    }
    disk {
        label = "disk01"
        unit_number =1
        size  = "${var.d2}"
        thin_provisioned = "${var.d2typ}"
    }
    clone {

        linked_clone  = false
        template_uuid = "${data.vsphere_virtual_machine.vmtemplate.id}"
        
        customize {
            
           #skip_customization = true
           timeout      = -1

           windows_options {
            computer_name         = "${var.host_name}"
            admin_password        = "${var.local_admin_pass}"
            organization_name     = "IBM-devops"
            join_domain           = "${var.dom}"
            domain_admin_user     = "${var.dom_admin_user}"
            domain_admin_password = "${var.dom_admin_password}"
            time_zone             = "190"
            auto_logon            = true
            auto_logon_count      = 1
            run_once_command_list = [
              "winrm quickconfig -force",
              "winrm set winrm/config @{MaxEnvelopeSizekb=\"100000\"}",
              "winrm set winrm/config/Service @{AllowUnencrypted=\"true\"}",
              "winrm set winrm/config/Service/Auth @{Basic=\"true\"}"
            ]
          }
           
            network_interface {
            dns_domain      = "${var.dom}"
            dns_server_list = ["${var.dns1}","${var.dns2}"]
            ipv4_address    = "${var.host_ip}"
            ipv4_netmask    = "${var.netmask}"
            }

            ipv4_gateway =   "${var.gw}"
            
        }
        
   
        
 #custom_attributes = "poc test"
}

provisioner "file" {
        source      = "../Scripts/winrm_access_disable.ps1"
        destination = "C:/Temp/winrm_access_disable.ps1"
      connection {
       type     = "winrm"
       insecure = true
       host     = "${var.host_ip}"
       user     = "Administrator"
       password = "${var.local_admin_pass}"
      }
  }
  
 provisioner "remote-exec" {
    inline = ["winrm get winrm/config/service"]

    connection {
      type     = "winrm"
      insecure = true
      host     = "${var.host_ip}"
      user     = "Administrator"
      password = "${var.local_admin_pass}"
      
    }
 } 

  provisioner "local-exec" {
    command = "ansible-playbook ../Ansible_Code/installBigfixClient.yml -i ../Ansible_Code/hosts.yml -v  -e 'ansible_user=administrator ansible_password=${var.local_admin_pass}'"
  }
  provisioner "local-exec" {
    command = "/usr/bin/sh ../../Scripts/slack_webhook.sh ${var.slack_token_url} SUCCESS ${vsphere_virtual_machine.winvm.name} ${vsphere_virtual_machine.winvm.default_ip_address} ${var.vcenter_host}"
  }

/* provisioner "remote-exec" {
    inline = ["powershell -ExecutionPolicy Unrestricted -File C:\\Temp\\winrm_access_disable.ps1"]
     connection {
      type     = "winrm"
      insecure = true
      host     = "${var.host_ip}"
      user     = "Administrator"
      password = "${var.local_admin_pass}"
     }
 } */

}
 

output "virtual_machine_name" {
 value = "${vsphere_virtual_machine.winvm.name}"
}
output "my_ip_address" {
 value = "${vsphere_virtual_machine.winvm.default_ip_address}"
}


