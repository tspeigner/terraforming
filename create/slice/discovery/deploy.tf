resource "openstack_compute_instance_v2" "disco_server" {
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

resource "openstack_networking_floatingip_v2" "myip" {
  count = "${var.count}"
  pool  = "${var.fip_pool}"
}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  count       = "${var.count}"
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
    source      = ""
    destination = "/home/centos/"
  }

  # Set the PE master hostname on the new node
  # Install PE agent
  provisioner "remote-exec" {
  inline = [
    "sudo -u root bash -c \"/bin/yum install -y yum-utils device-mapper-persistent-data lvm2\"",
    "sudo -u root bash -c \"/bin/yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo\"",
    "sudo -u root bash -c \"/bin/yum install -y docker-ce\"",
    "sudo -u root bash -c \"/usr/bin/systemctl start docker\"",
    "sudo -u root bash -c \"/usr/bin/docker ps\"",
    "sudo -u root bash -c \"/usr/bin/curl -O https://storage.googleapis.com/chvwcgv0lwrpc2nvdmvyes1jbgkk/production/latest/linux-amd64/puppet-discovery\"",
    "sudo -u root bash -c \"/usr/bin/chmod a+x ./puppet-discovery\"",
    "sudo -u root bash -c \"./puppet-discovery start\"",
  ]
  }
}
