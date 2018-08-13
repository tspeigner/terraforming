output "slice_floating_ip" {
  value = "${openstack_networking_floatingip_v2.myip.*.address}"
}

output "slice_linux_vms" {
  value = "${openstack_compute_instance_v2.web.*.name}"
}
