  output "puppet_master_private" { 
    value = "${aws_instance.web.private_dns}"
  }
  output "puppet_master_public" { 
<<<<<<< HEAD
    value = "${aws_instance.web.private_dns}"
=======
    value = "${aws_instance.web.public_dns}"
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18
  }

# Declare the instance resource here
resource "aws_instance" "web" {
  associate_public_ip_address = "true"
  key_name                    = "tommy"
  instance_type               = "t2.medium"
  security_groups             = ["sg-190e7962"] ##Tommy Master SG
  subnet_id                   = "subnet-fdbb3198" 
  ami                         = "${var.aws_ami}"


## Copy the pe.conf file over to the server
  provisioner "file" {
    source      = "conf/pe.conf"
    destination = "/home/ec2-user/pe.conf"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file("${path.module}/${var.key_file}")}"
    agent       = "false"
    timeout     = "5m"
   }
  }

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
<<<<<<< HEAD
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
      ## Download and extract Go Git Server files
      #"wget --content-disposition \"${var.gogs_installer}\"",
      #"tar -zxvf linux_amd64.tar.gz",
=======
      "sudo bash -c \"/opt/puppetlabs/bin/puppet module install beersy-pe_code_manager_easy_setup\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet resource package puppetclassify ensure=present provider=puppet_gem\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet apply -e \"class { 'pe_code_manager_easy_setup': r10k_remote_url => 'https://gitlab.com/tspeigner/control-repo-1.git', git_management_system => 'gitlab'}\"\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet apply -e \"class { 'pe_code_manager_easy_setup': r10k_remote_url => 'https://gitlab.com/tspeigner/control-repo-1.git', git_management_system => 'gitlab'}\"\"",
      #"sudo bash -c \"\"",
      "sudo bash -c \"/opt/puppetlabs/bin/puppet agent -t\"",
      "sudo bash -c \"/usr/bin/cat /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa.pub\"",
      "sudo bash -c \"/usr/bin/cat /etc/puppetlabs/puppetserver/.puppetlabs/webhook_url.txt\"",
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18
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
<<<<<<< HEAD
    Name    = "master.inf.puppet.vm"
    Owner   = "Tommy"
    Purpose = "TSE Test"
    Tech    = "Terraform"
=======
    Name     = "awsmaster.inf.puppet.vm"
    Owner    = "Tommy"
    Purpose  = "TSE Test"
    Tech     = "Terraform"
    Lifetime = "permanent"
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18
  }
}
