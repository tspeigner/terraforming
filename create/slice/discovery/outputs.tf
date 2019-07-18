output "Floating IP" {
<<<<<<< HEAD
  value = "${openstack_compute_floatingip_associate_v2.myip.floating_ip}"
=======
  value = "Discovery server to https://${openstack_compute_floatingip_associate_v2.myip.floating_ip}:8443"
>>>>>>> a1fac142bdcd1e94fabfd4c16327841cdb4b0a18
}