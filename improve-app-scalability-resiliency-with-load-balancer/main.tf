provider "azurerm" {
  features {}
}

locals {
  priv_ip_config_name = "IPConfigPrivate"
  linux_vm_username = "azureuser"
}

resource "azurerm_resource_group" "learn" {
  name = var.learn_resource_group_name
  location = var.learn_resource_group_location
  tags = {
    x-created-by = "freelearning"
    x-created-for = var.learn_created_for_value
    x-module-id = "learn.improve-app-scalability-resiliency-with-load-balancer"
  }
}

resource "azurerm_virtual_network" "learn" {
  name = "bePortalVnet"
  location = azurerm_resource_group.learn.location
  resource_group_name = azurerm_resource_group.learn.name
  address_space = [ "10.0.0.0/24" ]
}

resource "azurerm_subnet" "learn" {
  name                 = "bePortalSubnet"
  resource_group_name  = azurerm_resource_group.learn.name
  virtual_network_name = azurerm_virtual_network.learn.name
  address_prefixes     = azurerm_virtual_network.learn.address_space
}

resource "azurerm_availability_set" "learn" {
  name = "portalAvailabilitySet"
  location = azurerm_resource_group.learn.location
  resource_group_name = azurerm_resource_group.learn.name
}

resource "azurerm_network_interface" "learn" {
  count = 2
  name                = "webNic${count.index}"
  location            = azurerm_resource_group.learn.location
  resource_group_name = azurerm_resource_group.learn.name

  ip_configuration {
    name                          = local.priv_ip_config_name
    subnet_id                     = azurerm_subnet.learn.id
    private_ip_address_allocation = "Dynamic"
  }
}

data "template_file" "learn" {
  template = file("${path.module}/cloud-init.txt")
}

data "template_cloudinit_config" "learn" {
  gzip = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = data.template_file.learn.rendered
  }
}

resource "azurerm_linux_virtual_machine" "learn" {
  count = 2

  name = "webVM${count.index}"
  location = azurerm_resource_group.learn.location
  resource_group_name = azurerm_resource_group.learn.name
  admin_username = local.linux_vm_username
  network_interface_ids = [ azurerm_network_interface.learn[count.index].id ]
  availability_set_id = azurerm_availability_set.learn.id
  size = "Standard_B2ms"
  custom_data = data.template_cloudinit_config.learn.rendered

  admin_ssh_key {
    username = local.linux_vm_username
    # ssh-keygen -m PEM -t rsa -b 4096
    public_key = file("../.ssh/id_rsa.pub")
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }
}

resource "azurerm_public_ip" "learn" {
  name = "myPublicIP"
  location = azurerm_resource_group.learn.location  
  resource_group_name = azurerm_resource_group.learn.name
  allocation_method = "Static"
  domain_name_label = var.domain_name_label
}

resource "azurerm_lb" "learn" {
  name = "MyLoadBalancer"
  location = azurerm_resource_group.learn.location  
  resource_group_name = azurerm_resource_group.learn.name

  frontend_ip_configuration {
    name = "myFrontEnd"
    public_ip_address_id = azurerm_public_ip.learn.id
  }
}

resource "azurerm_lb_backend_address_pool" "learn" {
  loadbalancer_id = azurerm_lb.learn.id
  name = "myBackEndPool"  
}

resource "azurerm_lb_probe" "learn" {
  resource_group_name = azurerm_resource_group.learn.name
  loadbalancer_id = azurerm_lb.learn.id
  name = "myHealthProbe"  
  protocol = "http"
  port = 80
  interval_in_seconds = 5
  request_path = "/"
}

resource "azurerm_lb_rule" "learn" {
  resource_group_name = azurerm_resource_group.learn.name
  loadbalancer_id = azurerm_lb.learn.id
  name = "myLoadBalancerRule"
  frontend_ip_configuration_name = "myFrontEnd"
  protocol = "Tcp"
  frontend_port = 80
  backend_port = 80
  backend_address_pool_id = azurerm_lb_backend_address_pool.learn.id
  probe_id = azurerm_lb_probe.learn.id
}

resource "azurerm_network_interface_backend_address_pool_association" "learn" {
  count = 2
  
  network_interface_id = azurerm_network_interface.learn[count.index].id
  ip_configuration_name = local.priv_ip_config_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.learn.id
}