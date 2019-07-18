resource "openstack_networking_floatingip_v2" "myip" {
  pool = "${var.fip_pool}"
}

resource "openstack_compute_instance_v2" "pmaster" {
  name            = "pmaster.inf.puppet.vm"
  image_id        = "5c509a1d-c7b2-4629-97ed-0d7ccd66e154"
  flavor_name     = "m1.medium"
  key_pair        = "tls-slice"
  security_groups = ["default", "sg0"]

  network {
    name = "network1"
  }

}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = "${openstack_networking_floatingip_v2.myip.0.address}"
  instance_id = "${openstack_compute_instance_v2.pmaster.0.id}"


# Remote execution, add master to hosts file, make the puppet lock file to control agents first run, run agent 3 times (until green)

  provisioner "local-exec" {
    command = "sudo bash -c \"/bin/echo '${openstack_compute_floatingip_associate_v2.myip.floating_ip} ${openstack_compute_instance_v2.pmaster.name}' >> /etc/hosts\"",
  }

    ## Copy the pe.conf file over to the server
  provisioner "file" {
    source      = "conf/pe.conf"
    destination = "/home/centos/pe.conf"

    ## Setup the connection information to copy the file over.
  connection {
    type        = "ssh"
    host        = "${openstack_compute_instance_v2.pmaster.*.name}" #poor persons DNS. If DNS is working ignore.
    user        = "${var.connection_user}"
    private_key = "${file("${var.private_key}")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      # Download and extract the PE Master files.
      "curl -o ${var.dl_file} -L \"https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=el&rel=7&arch=x86_64&ver=latest\"",
      "mkdir -p ${var.dl_folder}",
      "mv /home/centos/pe.conf ${var.dl_folder}",
      "tar zvxf puppetmaster.tar.gz -C ${var.dl_folder} --strip-components=1",
      "cd ${var.dl_folder}",
      "sudo bash -c \"./puppet-enterprise-installer -c pe.conf\"",
      #"sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
      #"sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
      ## Download and extract Go Git Server files
      #"wget --content-disposition \"${var.gogs_installer}\"",
      #"tar -zxvf linux_amd64.tar.gz",
    ]
   connection {
    type        = "ssh"
    host        = "${openstack_compute_instance_v2.pmaster.name}" #poor persons DNS. If DNS is working ignore.
    user        = "${var.connection_user}"
    private_key = "${file("${var.private_key}")}"
    }
  }
}

  output "pmaster_ip" {
    value = "${openstack_networking_floatingip_v2.myip.0.address}"
  } 
  output "pmaster_hostname" {
    value = "${openstack_compute_instance_v2.pmaster.*.name}"
  } 
