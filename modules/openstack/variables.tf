variable "minion_count" {
  description = "Number of minions"
}

variable "openstack_password" {
  description = "openstack password"
  sensitive = true
}
