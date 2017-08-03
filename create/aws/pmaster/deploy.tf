
# Declare the instance resource here
resource "aws_instance" "web" {
  associate_public_ip_address = "true"
  key_name                    = "tommy"
  instance_type               = "t2.medium"
  security_groups             = ["sg-388fdf43"]
  subnet_id                   = "subnet-fdbb3198" 
  ami                         = "${var.aws_ami}"

provisioner "local-exec" {
    command = "sudo bash -c \"/bin/echo '${aws_instance.web.public_ip} pmaster' >> /etc/hosts\"",
  }

provisioner "remote-exec" {
    inline = [
      "sudo bash -c \"yum install -y postgresql mlocate wget telnet git\"",
      "sudo bash -c \"service postgresql start\"",
      "sudo bash -c \"chkconfig postgresql\"",
      ## Download and extract the PE Master files.
      #"wget --content-disposition \"${var.puppet_master_installer}\"",
      #"tar -zxvf puppet-enterprise-2017.2.2-el-7-x86_64.tar.gz",
      ## Download and extract Go Git Server files
      "wget --content-disposition \"${var.gogs_installer}\"",
      "tar -zxvf linux_amd64.tar.gz",
      #"export APP_NAME=\"gogs\" MYSQL_PASSWORD=\"puppetlabs\" HOSTNAME=\"master.inf.puppet.vm\"",
      #"mysqladmin -u root password \"$${MYSQL_PASSWORD}\" mysqladmin -u root –password=\"$${MYSQL_PASSWORD}\" password \"$${MYSQL_PASSWORD}\" mysql -u root -p$${MYSQL_PASSWORD} -e \"CREATE DATABASE IF NOT EXISTS $${APP_NAME}; use $${APP_NAME}; set global storage_engine=INNODB;\"",

    ]
   connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file("${path.module}/${var.key_file}")}"
    agent       = "false"
    timeout     = "5m"
   }
  }

tags {
    Name    = "master.inf.puppet.vm"
    Owner   = "Tommy"
    Purpose = "TSE Test"
    Tech    = "Terraform"
  }
}
