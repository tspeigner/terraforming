
# Declare the instance resource here
resource "aws_instance" "web" {
  associate_public_ip_address = "true"
  key_name                    = "tommy"
  instance_type               = "t2.medium"
  security_groups             = ["sg-388fdf43"]
  subnet_id                   = "subnet-fdbb3198" 
  ami                         = "${var.aws_ami}"

data "aws_ami" "windows_2012R2" {
  most_recent = "true"
  owners      = ["amazon"]

  filter {
    name  = "name"
    value = ["Windows_Server-2012-R2_RTM-English-64Bit-Base-*"]
  }
}

resource "aws_instance" "puppetmaster" {
  associate_public_ip_address = "true"
  key_name                    = "tommy"
  security_groups             = [""]
  subnet_id                   = "subnet-"
  ami                         = var.aws_ami_id
  instance_type               = "t2.medium"
  key_name                    = var.aws_key_pair

  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
  }

  timeouts {
    create = "15m"
  }

  provisioner "file" {
    content     = templatefile("pe.conf.tmpl", { dns_alt_names = [self.public_dns, "localhost", "puppet"] })
    destination = "/tmp/pe.conf"
  }

  provisioner "file" {
    source      = "autosign-batch.json"
    destination = "/tmp/autosign-batch.json"
  }

  provisioner "remote-exec" {
    on_failure = continue
    inline = [
      "curl -L -o /tmp/puppet-enterprise-${var.pe_version}-${var.pe_platform}.tar.gz https://s3.amazonaws.com/pe-builds/released/${var.pe_version}/puppet-enterprise-${var.pe_version}-${var.pe_platform}.tar.gz",
      "tar zxf /tmp/puppet-enterprise-${var.pe_version}-${var.pe_platform}.tar.gz -C /tmp",
      "sudo mkdir -p /etc/puppetlabs/puppet",
      "sudo /tmp/puppet-enterprise-${var.pe_version}-${var.pe_platform}/puppet-enterprise-installer -c /tmp/pe.conf",
      "sudo puppet module install danieldreier/autosign",
      "sudo /opt/puppetlabs/puppet/bin/gem install ncedit",
      "sudo /opt/puppetlabs/puppet/bin/ncedit update_classes",
      "sudo /opt/puppetlabs/puppet/bin/ncedit batch --json-file /tmp/autosign-batch.json",
      "sudo puppet config set --section master autosign /opt/puppetlabs/puppet/bin/autosign-validator",
      "sudo service pe-puppetmaster restart",
      "sudo sh -c 'while ! puppet agent --test --detailed-exitcodes; do sleep 60; done'",
    ]
  }
}

tags {
    Name    = "master.inf.puppet.vm"
    Owner   = "Tommy"
    Purpose = "TSE Test"
    Tech    = "Terraform"
  }
}