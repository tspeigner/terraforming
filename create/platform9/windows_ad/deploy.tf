<<<<<<< HEAD:create/slice/deploy.tf
variable "count" {
 default = "2"
}

variable "use_floating_ip" {
  default = "1"
}
=======
## TODO: change all of the Linux specific commands to Powershell
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18:create/platform9/windows_ad/deploy.tf

resource "openstack_networking_floatingip_v2" "myip" {
  pool  = "${var.fip_pool}"
  count = "${var.use_floating_ip > 0 ? var.count : 0}"
}

<<<<<<< HEAD:create/slice/deploy.tf
resource "openstack_compute_instance_v2" "web" {
  #name            = "${format("web-%02d.${var.datacenter}.${var.slice_domain}", count.index+1)}"
  name            = "${format("web-%02d.${var.domain}", count.index+1)}"
=======
resource "openstack_compute_instance_v2" "ad" {
  name            = "${format("ad-%02d.${var.datacenter}.${var.slice_domain}", count.index+1)}"
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18:create/platform9/windows_ad/deploy.tf
  count           = "${var.count}"
  image_id        = "5c509a1d-c7b2-4629-97ed-0d7ccd66e154"
  flavor_name     = "d1.small"
  key_pair        = "tls-slice"
  security_groups = ["default", "sg0"]

  network {
    name = "network1"
  }

}

resource "openstack_compute_floatingip_associate_v2" "myip" {
<<<<<<< HEAD:create/slice/deploy.tf
  count       = "${var.use_floating_ip > 0 ? var.count : 0}"
  floating_ip = "${element(openstack_networking_floatingip_v2.myip.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.web.*.id, count.index)}"
=======
  floating_ip = "${openstack_networking_floatingip_v2.myip.0.address}"
  instance_id = "${openstack_compute_instance_v2.ad.0.id}"
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18:create/platform9/windows_ad/deploy.tf


# Remote execution, add master to hosts file, make the puppet lock file to control agents first run, run agent 3 times (until green)

  provisioner "local-exec" {
<<<<<<< HEAD:create/slice/deploy.tf
    #command = "sudo bash -c \"/bin/echo '${openstack_compute_floatingip_associate_v2.myip.floating_ip} ${openstack_compute_instance_v2.web.name}' >> /etc/hosts\"",
    command = "sudo bash -c \"/bin/echo '${var.slice_linux_vms} ${openstack_compute_instance_v2.web.name}' >> /etc/hosts\"",
=======
    command = "sudo bash -c \"/bin/echo '${openstack_compute_instance_v2.ad.network.0.fixed_ip_v4} ${openstack_compute_instance_v2.ad.name}' >> /etc/hosts\"",
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18:create/platform9/windows_ad/deploy.tf
  }

## Setup the connection information to copy the file over.
  connection {
    type        = "ssh"
    host        = "${openstack_compute_instance_v2.web.name}" 
    user        = "${var.connection_user}"
    private_key = "${file("${var.private_key}")}"
    }

  provisioner "remote-exec" {
    inline = [
      "sudo -u root bash -c \"/bin/echo '10.32.171.156 master.inf.puppet.vm' >> /etc/hosts\"",
      "sudo -u root bash -c \"/usr/bin/hostnamectl set-hostname ${openstack_compute_instance_v2.web.*.name}\"",
      "sudo mkdir -p /opt/puppetlabs/puppet/cache/state",
      "sudo touch /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
<<<<<<< HEAD:create/slice/deploy.tf
      "sudo bash -c \"curl -k https://master.inf.puppet.vm:8140/packages/current/install.bash | sudo bash -s extension_requests:pp_role=role::activedirectory agent:certname=${format("web-%02d.${var.datacenter}.${var.domain}", count.index+1,)}\"",
=======
      "sudo bash -c \"curl -k https://master.inf.puppet.vm:8140/packages/current/install.bash | sudo bash -s agent:certname=${format("ad-%02d.${var.datacenter}.${var.slice_domain} extension_requests:pp_role=role::activedirectory", count.index+1,)}\"",
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18:create/platform9/windows_ad/deploy.tf
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
      "sudo rm /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent --enable\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
      ]
# Setup the host connection for remote-exec commands
   connection {
    type        = "ssh"
<<<<<<< HEAD:create/slice/deploy.tf
    host        = "${openstack_compute_instance_v2.web.name}" 
=======
    host        = "${openstack_compute_instance_v2.ad.name}" #poor persons DNS. If DNS is working ignore.
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18:create/platform9/windows_ad/deploy.tf
    user        = "${var.connection_user}"
    private_key = "${file("${var.private_key}")}"
    }
  }

# Purge the node from PuppetDB when Terraform Destroy is run
  provisioner "remote-exec" {
    when   = "destroy"
    inline = [
    # Purge node from PE Database
      #"sudo bash -c \"/opt/puppetlabs/bin/puppet node purge ${element(openstack_compute_instance_v2.web.*.name)}\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet node purge ${element(openstack_compute_instance_v2.web.*.name, count.index)}\"",
      #"sudo bash -c \"/opt/puppetlabs/bin/puppet cert clean ${element(openstack_compute_instance_v2.web.*.name)}\"",
    ]
  connection {
    type        = "ssh"
    host        = "10.32.171.156" # puppet master IP
    user        = "${var.connection_user}"
    private_key = "${file("${var.master_key}")}"
    }
  }
}
  #output "slice_floating_ip" {
  #  value = "${openstack_networking_floatingip_v2.myip.*.address}"
  #} 
  #output "slice_linux_vms" {
  #  value = "${openstack_compute_instance_v2.web.*.name}"
  #} 
