output "Floating IP" {
  value = "Connect to server at ${openstack_compute_floatingip_associate_v2.myip.floating_ip}"
}
