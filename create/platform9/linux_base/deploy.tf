resource "openstack_networking_floatingip_v2" "myip" {
  count = "${var.count}"
  pool  = "${var.fip_pool}"
}

resource "openstack_compute_instance_v2" "linux_base" {
  name            = "${format("${var.vm_prefix}-%02d.${var.datacenter}.${var.domain}", count.index+1)}"
  count           = "${var.count}"
  image_id        = "667d85ac-1d1e-a494-4017-437858a3da17"
  flavor_name     = "m1.small"
  key_pair        = "tls"
  security_groups = ["default"]

  network {
    name = "network1"
  }
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  count       = "${var.count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.myip.*.address, count.index+1)}"
  instance_id = "${element(openstack_compute_instance_v2.linux_base.*.id, count.index+1)}"
}
