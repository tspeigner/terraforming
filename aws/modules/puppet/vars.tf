variable "pe_version"       { default = "2019.0.2" }
variable "pe_platform"      { default = "ubuntu-16.04-amd64" }
variable "access_key"       {}
variable "secret_key"       {}
variable "aws_region"       { default = "us-east-1" }
variable "aws_key_pair"     { default = "tommy"}
variable "aws_ami_id"       {}
# variable user_name          {
#     description = "The first part of your puppet.com email address."
#     default     = "tommy"
}