data "template_file" "user_data" {
  template = "${file("./install_agent.ps1")}"
}

# Declare the instance resource here
resource "aws_instance" "web" {
  connection {
    type     = "winrm"
    user     = "Administrator"
    password = "${var.admin_password}"
    timeout  = "10m"
  }
  count                       = "${var.count}"
  associate_public_ip_address = "true"
  key_name                    = "tommy"
  instance_type               = "t2.medium"
  security_groups             = ["sg-388fdf43"]
  subnet_id                   = "subnet-fdbb3198" 
  ami                         = "${var.aws_ami}"
  user_data                   = "${data.template_file.user_data.rendered}"

  

tags {
    Name    = "${format("win2016-%02d.inf.puppet.vm", count.index+1,)}"
    Owner   = "Tommy"
    Purpose = "TSE Test"
    Tech    = "Terraform"
    }
}
