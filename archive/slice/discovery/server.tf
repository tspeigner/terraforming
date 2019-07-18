resource "openstack_compute_instance_v2" "disco_server" {
  name            = "${format("${var.vm_prefix}-%02d.${var.datacenter}.${var.domain}", count.index+1)}"
  count           = "${var.server_count}"
  image_id        = "5c509a1d-c7b2-4629-97ed-0d7ccd66e154"
  flavor_name     = "g1.medium"
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
  instance_id = "${element(openstack_compute_instance_v2.disco_server.*.id, count.index+1)}"
  }

resource "null_resource" "provision" {
  depends_on = ["openstack_compute_floatingip_associate_v2.myip"]
  
  connection {
    host        = "${openstack_compute_floatingip_associate_v2.myip.floating_ip}"
    type        = "ssh"
    user        = "centos"
    private_key = "${file("${path.module}/${var.key_file}")}"
    agent       = "true"
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "${var.pd_license_file}"
    destination = "${var.pd_license_loc}${var.pd_license_file}"
  }
  provisioner "file" {
    source      = "installpd.sh"
    destination = "${var.pd_license_loc}/installpd.sh"
  }
  # Set the PE master hostname on the new node
  # Install PE agent
  provisioner "remote-exec" {
  inline = [
    "sudo chmod a+x ${var.pd_license_loc}/installpd.sh",
    "sudo ./installpd.sh",
  ]
  }
}