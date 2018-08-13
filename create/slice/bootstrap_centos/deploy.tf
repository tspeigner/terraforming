variable "count" {
  default = 2
}

resource "openstack_compute_instance_v2" "web" {
  count                       = "${var.count}"
  name                        = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
  image_name                  = "centos_7_x86_64"
  flavor_name                 = "d1.small"
  key_pair                    = "${var.openstack_keypair}"
  security_groups             = ["sg0", "default"]
  network {
    name = "${var.tenant_network}"
  }

  user_data = "${file("bootstrap.sh")}"
}
