resource "openstack_networking_floatingip_v2" "myip" {
  count = "${var.count}"
  pool  = "${var.fip_pool}"
}

resource "openstack_compute_instance_v2" "linux_base" {
  name            = "${format("${var.vm_prefix}-%02d.${var.datacenter}.${var.domain}", count.index+1)}"
  count           = "${var.count}"
  image_id        = "5c509a1d-c7b2-4629-97ed-0d7ccd66e154"
  flavor_name     = "d1.small"
  key_pair        = "tls-slice"
  security_groups = ["default", "sg0"]

  network {
    name = "network0"
  }
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  count       = "${var.count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.myip.*.address, count.index+1)}"
  instance_id = "${element(openstack_compute_instance_v2.linux_base.*.id, count.index+1)}"
}
