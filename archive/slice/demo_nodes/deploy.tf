resource "openstack_networking_floatingip_v2" "myip" {
  count = "${var.count}"
  pool  = "${var.fip_pool}"
}

resource "openstack_compute_instance_v2" "demo_node" {
  name            = "${format("${var.vm_prefix}-%02d.${var.datacenter}.${var.domain}", count.index+1)}"
  count           = "${var.count}"
  image_id        = "5c509a1d-c7b2-4629-97ed-0d7ccd66e154"
  flavor_name     = "d1.small"
  key_pair        = "tls-slice"
  security_groups = ["default", "sg0"]

  network {
    name = "network0"
  }

#provisioner "local-exec" {
  #count   = "${var.count}"
#  command = "sudo bash -c \"/bin/echo '$floating_ip $instance_id' >> /etc/hosts\""
#}

provisioner "remote-exec" {

     inline = [
       "sudo -u root bash -c \"/bin/echo '192.168.0.24 master.inf.puppet.vm' >> /etc/hosts\"",
       "sudo mkdir -p /opt/puppetlabs/puppet/cache/state",
       "sudo touch /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
       "sudo bash -c \"curl -k https://master.inf.puppet.vm:8140/packages/current/install.bash | sudo bash -s\"",
       "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
       "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
       "sudo rm /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
       "sudo bash -c \"/opt/puppetlabs/bin/puppet agent --enable\"",
       "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
     ]

     # Setup the host connection for remote-exec commands
     connection {
       type        = "ssh"
       host        = "${openstack_compute_instance_v2.demo_node.name}" #poor persons DNS. If DNS is working ignore.
       user        = "${var.connection_user}"
       private_key = "${file("${var.private_key}")}"
       agent       = "true"
     }
   }
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  count       = "${var.count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.myip.*.address, count.index+1)}"
  instance_id = "${element(openstack_compute_instance_v2.demo_node.*.id, count.index+1)}"
}
