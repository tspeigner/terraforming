resource "openstack_networking_floatingip_v2" "myip" {
  count = "${var.count}"
  pool  = "${var.fip_pool}"
}

resource "openstack_compute_instance_v2" "splunktest" {
  name            = "${format("${var.vm_prefix}-%02d.${var.datacenter}.${var.domain}", count.index+1)}"
  count           = "${var.count}"
  image_id        = "5c509a1d-c7b2-4629-97ed-0d7ccd66e154"
  flavor_name     = "m1.medium"
  key_pair        = "tls-slice"
  security_groups = ["default", "sg0"]

  network {
    name = "network0"
  }


provisioner "remote-exec" {
    inline = "sudo bash -c \"/bin/echo '10.32.173.164 master.inf.puppet.vm' >> /etc/hosts\"",
  }

provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/puppetlabs/puppet/cache/state",
      "sudo touch /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
      "sudo bash -c \"curl -k https://master.inf.puppet.vm:8140/packages/current/install.bash | sudo bash -s extension_requests:pp_role=cd4pe_client\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock \"",
      "sudo rm /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent --enable\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
    ]
   connection {
    type        = "ssh"
    host        = "${openstack_compute_floatingip_associate_v2..floating_ip}"
    user        = "centos"
    private_key = "${file("${var.key_file}")}"
    agent       = "true"
    timeout     = "5m"
   }
  }
}
resource "openstack_compute_floatingip_associate_v2" "myip" {
  count       = "${var.count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.myip.*.address, count.index+1)}"
  instance_id = "${element(openstack_compute_instance_v2.splunktest.*.id, count.index+1)}"
}
