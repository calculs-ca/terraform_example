
output "public_ip" {
  description = "Public IP address of the gateway instance"
  value       = openstack_compute_floatingip_associate_v2.fip_1.floating_ip
}

output "gateway_ip" {
  description = "Private IP address of the gateway instance"
  value       = openstack_compute_instance_v2.gateway.access_ip_v4
}

output "master_ip" {
  description = "Private IP address of the master instance"
  value       = openstack_compute_instance_v2.master.access_ip_v4 
}

output "minions_ip" {
  description = "Private IP address of the minion instances"
  value       = openstack_compute_instance_v2.minion[*].access_ip_v4 
}
