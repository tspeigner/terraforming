resource "openstack_networking_floatingip_v2" "myip" {
  pool = "${var.fip_pool}"
}

resource "openstack_compute_instance_v2" "web" {
  #name            = "${format("web-%02d.${var.datacenter}.${var.slice_domain}", count.index+1)}"
  name            = "${format("web-%02d.${var.slice_domain}", count.index+1)}"
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
  floating_ip = "${openstack_networking_floatingip_v2.myip.0.address}"
  instance_id = "${openstack_compute_instance_v2.web.0.id}"


# Remote execution, add master to hosts file, make the puppet lock file to control agents first run, run agent 3 times (until green)

  provisioner "local-exec" {
    command = "sudo bash -c \"/bin/echo '${openstack_compute_instance_v2.web.network.0.fixed_ip_v4} ${openstack_compute_instance_v2.web.name}' >> /etc/hosts\"",
  }


## Create the keytabe file on the newly created instance.
  provisioner "file" {
    source      = "administrator.keytab"
    destination = "/tmp/administrator.keytab"
    }

## Setup the connection information to copy the file over.
  connection {
    type        = "ssh"
    host        = "${openstack_compute_instance_v2.web.name}" #poor persons DNS. If DNS is working ignore.
    user        = "${var.connection_user}"
    private_key = "${file("${var.private_key}")}"
    }

  provisioner "remote-exec" {
    inline = [
      "sudo -u root bash -c \"/bin/echo '10.32.171.156 master.inf.puppet.vm' >> /etc/hosts\"",
      "sudo -u root bash -c \"/bin/echo '10.32.171.175 puppet.local' >> /etc/hosts\"",
      "sudo -u root bash -c \"/usr/bin/hostnamectl set-hostname ${openstack_compute_instance_v2.web.name}\"",
      "sudo mkdir -p /opt/puppetlabs/puppet/cache/state",
      "sudo touch /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
      #"sudo bash -c \"curl -k https://master.inf.puppet.vm:8140/packages/current/install.bash | sudo bash -s extension_requests:pp_role=role::activedirectory agent:certname=${format("web-%02d.${var.datacenter}.${var.slice_domain}", count.index+1,)}\"",
      "sudo bash -c \"curl -k https://master.inf.puppet.vm:8140/packages/current/install.bash | sudo bash -s extension_requests:pp_role=role::activedirectory agent:certname=${format("web-%02d.${var.slice_domain}", count.index+1,)}\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
      #"sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
      #"sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock \"",
      "sudo rm /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent --enable\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
      ]
# Setup the host connection for remote-exec commands
   connection {
    type        = "ssh"
    host        = "${openstack_compute_instance_v2.web.name}" #poor persons DNS. If DNS is working ignore.
    user        = "${var.connection_user}"
    private_key = "${file("${var.private_key}")}"
    }
  }
}
