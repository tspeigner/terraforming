resource "openstack_networking_floatingip_v2" "myip" {
  count = 5
  pool  = "${var.fip_pool}"
}

resource "openstack_compute_instance_v2" "nce" {
  name            = "${format("nce-%02d.${var.datacenter}.${var.domain}", count.index+1)}"
  count           = "${var.count}"
  image_id        = "5c509a1d-c7b2-4629-97ed-0d7ccd66e154"
  flavor_name     = "d1.small"
  key_pair        = "tls-slice"
  security_groups = ["default", "sg0"]

  network {
    name = "network0"
  }
}
