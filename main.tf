module "openstack" {
  source             = "./modules/openstack"
  minion_count       = 2
  openstack_password = trimspace(file("MYPASSWORDFILE"))
}

output "public_ip" {
  value = module.openstack.public_ip
}

output "gateway_ip" {
  value = module.openstack.gateway_ip
}

output "master_ip" {
  value = module.openstack.master_ip
}

output "minions_ip" {
  value = module.openstack.minions_ip
}

resource "local_file" "inventory" {
  content = templatefile("templates/inventory.ini", {
    master_ip = module.openstack.master_ip
  })
  filename = "../ansible/hosts"
}
