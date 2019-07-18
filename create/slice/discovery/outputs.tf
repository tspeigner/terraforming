output "Floating IP" {
  value = "${openstack_compute_floatingip_associate_v2.myip.floating_ip}"
}