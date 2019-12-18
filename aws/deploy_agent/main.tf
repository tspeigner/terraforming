# t2.micro node
# Puppet Enabled
# CentOS

## Variables start here
variable "certname" {
  type = "string"
  default = "tfdemo.classroom.puppet.com"
}
variable "puppet_master" {
  type = "string"
}
variable "private_key" {
  type = "string"
}
variable "master_private_key" {
  type = "string"
}
variable "aws_key_pair" {
  type = "string"
}
provider "aws" {
  region = "us-west-2"
}
data "aws_ami" "centos" {
  owners      = ["679593333241"]
  most_recent = true
  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

## Provisioner with Puppet Provisioner starts here
resource "aws_instance" "tfdemo" {
  ami           = "${data.aws_ami.centos.id}"
#  ami = "ami-01ed306a12b7d1c96"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_pair}"
  tags = {
    Department = "SE"
    Project = "SE Demos"
  }
  provisioner "puppet" {
    server      = "${var.puppet_master}"
    server_user = "centos"
    autosign    = false
    open_source = false
    certname    = "${var.certname}"
    use_sudo    = true
    extension_requests = {
      pp_role = "tfdemo"
    }
    connection {
      type = "ssh"
      host = "${self.public_ip}"
      user = "centos"
      private_key = "${var.private_key}"
    }
  }

# Old school way of doing it, but it works well
  provisioner "remote-exec" {
    inline = [
      "sudo echo \"\" > /etc/hosts",
      "sudo echo \"54.174.136.153 puppet.classroom.puppet.com\" > /etc/hosts",
      "curl -k https://terramaster0.classroom.puppet.com:8140/packages/current/install.bash | sudo bash ${var.certname}",
    ]
    connection {
      type = "ssh"
      host = "${self.public_ip}"
      user = "centos"
      private_key = "${var.private_key}"
    }
  }

## Connects to Puppet server >> cleans the certificate of node being purged.
  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "sudo puppet node purge ${var.certname}",
    ]
    connection {
      type = "ssh"
      host = "${var.puppet_master}"
      user = "centos"
      private_key = "${var.master_private_key}"
    }
  }
}