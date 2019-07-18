provider "openstack" {
  user_name          = "${var.platform9_user_name}"
  tenant_name        = "${var.platform9_tenant_name}"
  password           = "${var.platform9_password}"
  auth_url           = "${var.platform9_auth_url}"
}
