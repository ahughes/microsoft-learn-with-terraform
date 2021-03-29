provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "learn" {
    name = var.learn_resource_group_name
    location = var.learn_resource_group_location
    tags = {
        x-created-by = "freelearning"
        x-created-for = var.learn_x-created-for_value
        x-module-id = "learn.design-ip-addressing-for-azure"
    }
}

resource "azurerm_virtual_network" "learn" {
    count = length(var.vnets)
    
    name = var.vnets[count.index]["vnet_name"]
    location = var.vnets[count.index]["location"]
    address_space = var.vnets[count.index]["address_space"]
    resource_group_name = azurerm_resource_group.learn.name
}

locals {
  subnets_list = flatten([
    for net in var.vnets: [
      for name,space in net.subnets: {
        sub_vnet = net.vnet_name
        sub_name = name
        sub_space = space
    }]
  ])

  subnets_map = {
    for obj in local.subnets_list : "${obj.sub_name}" => obj
  }
}

resource "azurerm_subnet" "local" {
  for_each = local.subnets_map
  
  name = each.value.sub_name
  virtual_network_name = each.value.sub_vnet
  address_prefixes = each.value.sub_space
  resource_group_name = azurerm_resource_group.learn.name  
}