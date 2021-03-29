variable "learn_resource_group_name" {
  description = "Name of automatically generated resource group for the Microsoft Learn exercise/sandbox"
  # Using this as a variable also makes it easier to use this template on resource groups not auto-generated by Learn.
}

variable "learn_resource_group_location" {
  description = "Location of automatically generated resource group for the Microsoft Learn exercise/sandbox"
  default = "westus" # my default region, although I imagine it changes based on detected location
}

variable "learn_x-created-for_value" {
  description = "Value of automatically generated tag on Microosft Learn exercise/sandbox resource group."
}

variable "vnets" {
  description = "IP schema per the excercise instructions on Microsoft Learn"
  # Unit 5: Exercise - Design and implement IP addressing for Azure virtual networks
  # https://docs.microsoft.com/en-us/learn/modules/design-ip-addressing-for-azure/5-exercise-implement-vnets
  default = [{
    vnet_name = "CoreServicesVnet"
    location  = "West US"
    address_space = ["10.20.0.0/16"]
    subnets = {
      GatewaySubnet = ["10.20.0.0/27"]
      SharedServicesSubnet = ["10.20.10.0/24"]
      DatabaseSubnet = ["10.20.20.0/24"]
      PublicWebServiceSubnet = ["10.20.30.0/24"]
    }
  },{
    vnet_name = "ManufacturingVnet"
    location  = "North Europe"
    address_space = ["10.30.0.0/16"]
    subnets = {
      ManufacturingSystemSubnet = ["10.30.10.0/24"]
      SensorSubnet1 = ["10.30.20.0/24"]
      SensorSubnet2 = ["10.30.21.0/24"]
      SensorSubnet3 = ["10.30.22.0/24"]
    }
  },{
    vnet_name = "ResearchVnet"
    location = "West India"
    address_space = ["10.40.40.0/24"]
    subnets = {
      ResearchSystemSubnet = ["10.40.40.0/24"]
    }
  }]
}