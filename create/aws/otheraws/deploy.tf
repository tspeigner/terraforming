variable "count" {
  default = 2
}

resource "aws_instance" "web" {
  count                       = "${var.count}"
  #name                        = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  security_groups             = ["sg-388fdf43"]
  subnet_id                   = "subnet-fdbb3198" 
  ami                         = "${var.aws_ami}"

 #keep separate for looks
  user_data = "${file("bootstrap.sh")}"

tags {
    Name    = "${format("web-%02d.inf.puppet.vm", count.index+1,)}"
    Owner   = "Tommy"
    Purpose = "TSE Test"
  }
}
