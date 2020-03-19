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

resource "vsphere_virtual_machine" "linuxvm" {
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
           linux_options {
             host_name      = "${var.host_name}"
             domain         = "${var.dom}"
             time_zone      = "190"
           } 
            network_interface {
             ipv4_address = "${var.host_ip}"
             ipv4_netmask = "${var.netmask}"
            }
            ipv4_gateway    = "${var.gw}"
            dns_server_list = ["${var.dns1}","${var.dns2}"]
            dns_suffix_list = ["${var.dom}"]
        }
        
    #custom_attributes = "poc test"
    }

    provisioner "remote-exec" {
     inline = [
      "systemd-machine-id-setup",
      "echo \"${var.new_root_password}\" | passwd --stdin root",
      "useradd -m -c \"Admin User\" admin",
      "echo \"${var.new_admin_password}\" | passwd --stdin admin",
      "usermod -aG wheel admin",
      "passwd --lock root",
      "rm -rf /root/.ssh/authorized_keys"
     ]
    }
    connection {
     host     = "${self.default_ip_address}"
     type     = "ssh"
     user     = "root"
     password = "${var.root_password}"
    }   
    provisioner "local-exec" {
      command = "ansible-playbook ../Ansible_Code/installOnLinux.yml --tags \"bigfix,saac_basic,saac_ssh\" -i ../Ansible_Code/hosts.yml -v  -e 'ansible_user=admin ansible_password=${var.new_admin_password} ansible_become_pass=${var.new_admin_password}'"
    }
    provisioner "local-exec" {
      command = "/usr/bin/sh ../../Scripts/slack_webhook.sh ${var.slack_token_url} SUCCESS ${vsphere_virtual_machine.linuxvm.name} ${vsphere_virtual_machine.linuxvm.default_ip_address} ${var.vcenter_host}"
    }
    
}

output "virtual_machine_name" {
 value = "${vsphere_virtual_machine.linuxvm.name}"
}
output "my_ip_address" {
 value = "${vsphere_virtual_machine.linuxvm.default_ip_address}"
}


