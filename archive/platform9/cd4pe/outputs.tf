output "Floating IP" {
  value = "CD4PE ${openstack_compute_floatingip_associate_v2.myip.floating_ip}:8080"
}
