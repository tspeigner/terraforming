variable "count" {
  default = 10
}

resource "aws_instance" "web" {
  count                       = "${var.count}"
  #name                        = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
  associate_public_ip_address = true
  instance_type               = "t2.medium"
  security_groups             = ["sg-388fdf43"]
  subnet_id                   = "subnet-fdbb3198" 
  ami                         = "${var.aws_ami}"

 #keep separate for looks
  user_data = "${file("bootstrap.sh")}"

tags {
    Name       = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
    Create_by  = "tommy@puppet.com"
    Purpose    = "TSE Demo"
    Department = "TSE"
    Lifetime   = "24h"
  }
}
