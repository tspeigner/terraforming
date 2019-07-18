resource "openstack_networking_floatingip_v2" "myip" {
  pool = "${var.fip_pool}"
}

resource "openstack_compute_instance_v2" "web" {
  #name            = "${format("master.${var.datacenter}.${var.domain}", count.index+1)}"
  name            = "master.${var.domain}"
  count           = "${var.count}"
  image_id        = "5c509a1d-c7b2-4629-97ed-0d7ccd66e154"
  flavor_name     = "g1.large"
  key_pair        = "tls"
  #security_groups = ["default", "sg0"]
  security_groups = "${var.security_groups}"

  network {
    name = "network1"
  }

}

resource "openstack_compute_floatingip_associate_v2" "myip" {
  floating_ip = "${openstack_networking_floatingip_v2.myip.0.address}"
  instance_id = "${openstack_compute_instance_v2.web.0.id}"


# Remote execution, add master to hosts file, make the puppet lock file to control agents first run, run agent 3 times (until green)

  #provisioner "local-exec" {
  #  command = "sudo bash -c \"/bin/echo '${openstack_compute_instance_v2.web.network.0.fixed_ip_v4} ${openstack_compute_instance_v2.web.name}' >> /etc/hosts\"",
  #}
  provisioner "local-exec" {
    command = "sudo bash -c \"/bin/echo '${openstack_networking_floatingip_v2.myip.0.address} ${openstack_compute_instance_v2.web.name}' >> /etc/hosts\"",
  }

  ## Copy the pe.conf file over to the server
  #provisioner "file" {
  #  source      = "conf/pe.conf"
  #  destination = "/home/ec2-user/pe.conf"
  #}
  

  provisioner "remote-exec" {
    inline = [
    # Download and extract the PE Master files.
      "curl -o ${var.dl_file} -L \"https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=el&rel=7&arch=x86_64&ver=latest\"",
      "mkdir -p ${var.dl_folder}",
      "mv /home/ec2-user/pe.conf ${var.dl_folder}",
      "tar zvxf puppetmaster.tar.gz -C ${var.dl_folder} --strip-components=1",
      "cd ${var.dl_folder}",
      "sudo bash -c \"./puppet-enterprise-installer -c pe.conf\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet module install beersy-pe_code_manager_easy_setup --version 2.0.2\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
      "sudo bash -c \"/bin/mkdir -p /root/.puppetlabs\"",
      "sudo bash -c \"/bin/touch /root/.puppetlabs/token\"",
      "sleep 3",
      "sudo bash -c \"/bin/curl -k -X POST -H 'Content-Type: application/json' -d '{\"login\": \"admin\", \"password\": \"puppetlabs\"}' https://${openstack_compute_instance_v2.web.name}:4433/rbac-api/v1/auth/token >> /root/.puppetlabs/token\"",
      "sleep 3",
     # "sudo bash -c \"/opt/puppetlabs/bin/puppet-task run pe_code_manager_easy_setup::setup_code_manager r10k_remote_url=git@github.com:tspeigner/control-repo-1.git\"",
      "echo \"Now, put this generated Public SSH Key in your version control system:\"",
     # "echo \"$(sudo /usr/bin/head -n 1 /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub)\"",
     # "echo ********************************",
     # "echo \"Also, put the appropriate webhook URL's in your version control system:\"",
     # "webhook_url=$(sudo /usr/bin/head -n 1 /etc/puppetlabs/puppetserver/.puppetlabs/webhook_url.txt)",
     # "echo More information about webhook url's and all their parameters can be found here:",
     # "echo https://puppet.com/docs/pe/2017.3/code_management/code_mgr_webhook.html#triggering-code-manager-with-a-webhook"

##################################################################################################################################
# Previous code
##################################################################################################################################
    #  "sudo -u root bash -c \"/bin/echo '10.32.168.157 ${var.currentPE}' >> /etc/hosts\"",
    #  "sudo mkdir -p /opt/puppetlabs/puppet/cache/state",
    #  "sudo touch /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
    #  "sudo bash -c \"curl -k https://${var.currentPE}:8140/packages/current/install.bash | sudo bash -s agent:certname=${format("web-%02d.${var.datacenter}.${var.domain}", count.index+1,)}\"",
    #  "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
    #  "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock \"",
    #  "sudo rm /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
    #  "sudo bash -c \"/opt/puppetlabs/bin/puppet agent --enable\"",
    #  "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
      ]
# Setup the host connection for remote-exec commands
   connection {
    type        = "ssh"
    host        = "${openstack_compute_instance_v2.web.name}" #poor persons DNS. If DNS is working ignore.
    user        = "${var.connection_user}"
    private_key = "${file("${var.private_key}")}"
    }
  }
}
output "Floating IP" {
  value = "${openstack_networking_floatingip_v2.myip.0.address}"
}