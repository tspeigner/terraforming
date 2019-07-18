output "public_dns" {
  value = "${aws_instance.cd4pe.public_dns}"
}

# Declare the instance resource here
resource "aws_instance" "cd4pe" {
  count                       = "${var.count}"
  associate_public_ip_address = "true"
  key_name                    = "tommy"
  instance_type               = "t2.medium"
  security_groups             = ["sg-388fdf43"]
  subnet_id                   = "subnet-fdbb3198" 
  ami                         = "${var.aws_ami}"


provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/puppetlabs/puppet/cache/state",
      "sudo touch /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
      "sudo bash -c \"curl -k https://ip-10-98-10-11.us-west-2.compute.internal:8140/packages/current/install.bash | sudo bash -s extension_requests:pp_role=role::cd4pe\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t --agent_disabled_lockfile /tmp/puppet_first_run.lock \"",
      "sudo rm /opt/puppetlabs/puppet/cache/state/agent_disabled.lock",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent --enable\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
    ]
   connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file("${path.module}/${var.key_file}")}"
    agent       = "true"
    timeout     = "5m"
   }
  }

tags {
    Name    = "${format("cd4pe.inf.puppet.vm")}"
    Owner   = "Tommy"
    Purpose = "TSE Test"
    Tech    = "Terraform"
  }
}
