provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "learn" {
    name = var.learn_resource_group_name
    location = var.learn_resource_group_location
    tags = {
        x-created-by = "freelearning"
        x-created-for = var.learn_created_for_value
        x-module-id = "learn.create-azure-storage-account"
    }
}

resource "azurerm_storage_account" "learn" {
    name = var.storage_account_name
    resource_group_name = azurerm_resource_group.learn.name
    location = var.storage_account_location
    account_kind = "StorageV2"
    account_tier = "Standard"
    account_replication_type = "LRS"
    access_tier = "Hot"
    enable_https_traffic_only = true
    min_tls_version = "TLS1_2"
    allow_blob_public_access = true
    is_hns_enabled = false
    large_file_share_enabled = false
}