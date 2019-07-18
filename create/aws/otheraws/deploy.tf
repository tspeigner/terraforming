variable "count" {
<<<<<<< HEAD
  default = 2
=======
  default = 10
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18
}

resource "aws_instance" "web" {
  count                       = "${var.count}"
  #name                        = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
  associate_public_ip_address = true
<<<<<<< HEAD
  instance_type               = "t2.micro"
=======
  instance_type               = "t2.medium"
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18
  security_groups             = ["sg-388fdf43"]
  subnet_id                   = "subnet-fdbb3198" 
  ami                         = "${var.aws_ami}"

 #keep separate for looks
  user_data = "${file("bootstrap.sh")}"

tags {
<<<<<<< HEAD
    Name    = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
    Owner   = "Tommy"
    Purpose = "TSE Test"
=======
    Name       = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
    Create_by  = "tommy@puppet.com"
    Purpose    = "TSE Demo"
    Department = "TSE"
    Lifetime   = "24h"
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18
  }
}
