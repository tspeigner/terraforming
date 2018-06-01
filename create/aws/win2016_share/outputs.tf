#output "" {
#  value = ""
#}

output "Public DNS" { 
    value = "${aws_instance.web.public_dns}"
  }