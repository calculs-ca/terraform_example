terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name        = "MYUSERNAME"
  tenant_name      = "RPPNAME"
  tenant_id        = "RPPID"
  password         = var.openstack_password
  user_domain_name = "CCDB"
  auth_url         = "https://beluga.cloud.computecanada.ca:5000"
  region           = "RegionOne"
}

data "local_file" "gateway_user_data" {
  filename = "./cloudinit/gateway.yml"
}

data "local_file" "node_user_data" {
  filename = "./cloudinit/node.yml"
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip           = "MYPUBLICIP"
  instance_id           = openstack_compute_instance_v2.gateway.id
  wait_until_associated = true
}

resource "openstack_compute_instance_v2" "gateway" {
  name        = "epigeec_proxy"
  image_name  = "Ubuntu-20.04.3-Focal-x64-2021-11"
  flavor_name = "p4-7.5gb" #"p1-1gb"
  user_data   = data.local_file.gateway_user_data.content
  block_device {
    delete_on_termination = true
    destination_type      = "volume"
    source_type           = "image"
    uuid                  = "43f6cb7a-43cd-4205-8d10-01b052bd6819"
    volume_size           = 25
  }
  security_groups = ["epigeec", "web"]
  network {
    uuid = "39e2642a-7afe-4e64-abf2-5c6a7b05912d"
  }
  key_pair = "jonathanl"
}

resource "openstack_compute_instance_v2" "master" {
  name        = "epigeec_main"
  image_name  = "Ubuntu-20.04.3-Focal-x64-2021-11"
  flavor_name = "p4-7.5gb"
  user_data   = data.local_file.gateway_user_data.content
  block_device {
    delete_on_termination = true
    destination_type      = "volume"
    source_type           = "image"
    uuid                  = "43f6cb7a-43cd-4205-8d10-01b052bd6819"
    volume_size           = 50
  }
  security_groups = ["epigeec"]
  network {
    uuid = "39e2642a-7afe-4e64-abf2-5c6a7b05912d"
  }
  key_pair = "jonathanl"
}

resource "openstack_compute_instance_v2" "minion" {
  count       = var.minion_count
  name        = "epigeec${count.index}"
  image_name  = "Ubuntu-20.04.3-Focal-x64-2021-11"
  flavor_name = "p4-7.5gb" #p8-30gb
  user_data   = data.local_file.gateway_user_data.content
  block_device {
    delete_on_termination = true
    destination_type      = "volume"
    source_type           = "image"
    uuid                  = "43f6cb7a-43cd-4205-8d10-01b052bd6819"
    volume_size           = 25
  }
  security_groups = ["epigeec"]
  network {
    uuid = "39e2642a-7afe-4e64-abf2-5c6a7b05912d"
  }
  key_pair = "jonathanl"
}

resource "openstack_blockstorage_volume_v2" "volume" {
  count       = var.minion_count + 1
  name        = "epivolume${count.index}"
  size        = 100
  volume_type = "volumes-ec"
}

resource "openstack_compute_volume_attach_v2" "minion_volume" {
  count       = var.minion_count
  instance_id = openstack_compute_instance_v2.minion[count.index].id
  volume_id   = openstack_blockstorage_volume_v2.volume[count.index].id
}

resource "openstack_compute_volume_attach_v2" "master_volume" {
  instance_id = openstack_compute_instance_v2.master.id
  volume_id   = openstack_blockstorage_volume_v2.volume[var.minion_count].id
}
