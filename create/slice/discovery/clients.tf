resource "openstack_compute_instance_v2" "disco_clients" {
  name            = "${format("${var.client_prefix}-%02d.${var.datacenter}.${var.domain}", count.index+1)}"
  count           = "${var.client_count}"
  image_id        = "5c509a1d-c7b2-4629-97ed-0d7ccd66e154"
  flavor_name     = "g1.medium"
  key_pair        = "tls-slice"
  security_groups = ["default", "sg0"]

  network {
    name = "network0"
  }
}

resource "openstack_networking_floatingip_v2" "clients" {
  count = "${var.client_count}"
  pool  = "${var.fip_pool}"
}

resource "openstack_compute_floatingip_associate_v2" "clients" {
  count       = "${var.client_count}"
  floating_ip = "${element(openstack_networking_floatingip_v2.clients.*.address, count.index+1)}"
  instance_id = "${element(openstack_compute_instance_v2.disco_clients.*.id, count.index+1)}"
}

#resource "null_resource" "client_provision" {
#  depends_on = ["openstack_compute_floatingip_associate_v2.clients"]
#  
#  provisioner "remote-exec" {
#  inline = [
#  ]
#  }
#  connection {
#    host        = "${openstack_compute_floatingip_associate_v2.clients.floating_ip}"
#    type        = "ssh"
#    user        = "centos"
#    private_key = "${file("${path.module}/${var.key_file}")}"
#    agent       = "true"
#    timeout     = "5m"
#  }
#}

output "Client IPs" {
    value = "${openstack_networking_floatingip_v2.clients.*.address}"
}
