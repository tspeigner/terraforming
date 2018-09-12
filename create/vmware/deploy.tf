#Deploy a Folder, VM

resource "vsphere_folder" "tftest" {
  datacenter    = "${var.vsphere_datacenter}"
  path          = "TSEs/tommy/tftest"
}

# Create a virtual machine within the folder
resource "vsphere_virtual_machine" "tftest" {
  name       = "node-${format("%02d.${var.datacenter}.${var.domain}", count.index+1)}"
  folder     = "${vsphere_folder.tftest.path}"
  #folder     = "TSEs/tommy/tftest"
  cluster    = "${var.vsphere_cluster}"
  datacenter = "${var.vsphere_datacenter}"
  vcpu       = 1
  memory     = 1024

# Network setup
  network_interface {
    label = "VM Network"
  }

#Define Domain and DNS
  domain      = "inf.puppet.vm"
  dns_servers = ["8.8.8.8", "10.240.0.10"]

  disk {
    datastore = "${var.datastore}"
    template  = "${var.template_name}"
    type      = "thin"
  }

# Loop for Count
  count = "${var.node_count}"

# Install the Puppet agent

provisioner "remote-exec" {
    inline = [
      "sudo -u root bash -c \"/bin/echo '10.32.171.156 master.inf.puppet.vm' >> /etc/hosts\"",
      "sudo mkdir -p /opt/puppetlabs/puppet/cache/state",
      "sudo touch /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
      "sudo bash -c \"curl -k https://master.inf.puppet.vm:8140/packages/current/install.bash | sudo bash\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
      "sudo rm /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent --enable\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
    ]
   connection {
    type        = "ssh"
    user        = "${var.node_user}"
    password    = "${var.node_password}"
    #private_key = "${var.key_file_path}"
   }
  }
}

