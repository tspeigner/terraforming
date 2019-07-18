output "Floating IP" {
  value = "Discovery server to https://${openstack_compute_floatingip_associate_v2.myip.floating_ip}:8443"
}