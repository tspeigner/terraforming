# Define how many instances you want
variable "count" {
  default = 2
}

# Declare the instance resource here
resource "aws_instance" "web" {
  count                       = "${var.count}"
  associate_public_ip_address = "true"
  key_name                    = "tommy"
  instance_type               = "t2.medium"
  security_groups             = ["sg-388fdf43"]
  subnet_id                   = "subnet-fdbb3198" 
  ami                         = "${var.aws_ami}"


provisioner "remote-exec" {
    inline = [
      "sudo -u root bash -c \"/bin/echo '10.98.10.242 master.inf.puppet.vm' >> /etc/hosts\"",
      "sudo mkdir -p /opt/puppetlabs/puppet/cache/state",
      "sudo touch /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
      "sudo bash -c \"curl -k https://ip-10-98-10-242.us-west-2.compute.internal:8140/packages/current/install.bash | sudo bash -s extension_requests:pp_role=role::linux_webserver\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock \"",
      "sudo rm /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent --enable\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
    ]
   connection {
    type        = "ssh"
    user        = "centos"
    private_key = "${file("${path.module}/${var.key_file}")}"
    agent       = "false"
    timeout     = "5m"
   }
  }

tags {
    Name    = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
    Owner   = "Tommy"
    Purpose = "TSE Test"
    Tech    = "Terraform"
  }
}
