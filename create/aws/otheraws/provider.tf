provider "aws" {
  access_key              = "${var.aws_access_key}"
  secret_key              = "${var.aws_secret_key}"
  region                  = "${var.aws_region}"
<<<<<<< HEAD
  shared_credentials_file = "/Users/centos/.aws/creds"
=======
  shared_credentials_file = "/Users/tommy/.aws/credentials"
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18
}
