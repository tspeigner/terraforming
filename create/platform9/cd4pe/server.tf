resource "openstack_compute_instance_v2" "cd4pe" {
  name            = "${format("${var.vm_prefix}-%02d.${var.datacenter}.${var.domain}", count.index+1)}"
  count           = "${var.server_count}"
  image_id        = "5c509a1d-c7b2-4629-97ed-0d7ccd66e154"
  flavor_name     = "g1.large"
  key_pair        = "tls-slice"
  security_groups = ["default", "sg0"]

  network {
    name = "network0"
  }
}

resource "openstack_networking_floatingip_v2" "myip" {
  count = "${var.server_count}"
  pool  = "${var.fip_pool}"
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  count       = "${var.server_count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.myip.*.address, count.index+1)}"
  instance_id = "${element(openstack_compute_instance_v2.cd4pe.*.id, count.index+1)}"
}

resource "null_resource" "hostfile" {
  provisioner "local-exec" {
    command = "sudo bash -c \"/bin/echo $floating_ip >> /etc/hosts\"",
  }
}




