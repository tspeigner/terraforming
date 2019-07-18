
# Declare the instance resource here
resource "aws_instance" "pfa" {
  count                       = "${var.count}"
  associate_public_ip_address = "true"
  key_name                    = "tommy"
  instance_type               = "t2.medium"
  security_groups             = ["sg-388fdf43"]
  subnet_id                   = "subnet-fdbb3198" 
  ami                         = "${var.aws_ami}"


tags {
    Name    = "${format("pfa-%02d.inf.puppet.vm", count.index+1,)}"
    Owner   = "Tommy"
    Purpose = "TSE Demo"
    Tech    = "PFA"
  }
}
