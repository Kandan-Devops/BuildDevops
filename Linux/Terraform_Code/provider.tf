#provider file

provider "vsphere" {
    user            = "${var.vcenter_user}"
    password        = "${var.vcenter_password}"
    vsphere_server  = "${var.vcenter_host}"
    allow_unverified_ssl = true
    version = "1.12"
}