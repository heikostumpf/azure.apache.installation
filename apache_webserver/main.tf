provider "azurerm" {
    version = "~> 1.33"
}
# Resource Group
resource "azurerm_resource_group" "apache_web_server_rg" {
    name        = "${var.prefix}-${var.web_server_name}-rg"
    location    = "${var.location}"
}

resource "azurerm_virtual_network" "apache_web_server_vnet" {
    name                = "${var.prefix}-${var.web_server_name}-vnet" 
    address_space       = "${var.vnet_address_space}"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.apache_web_server_rg.name}"
}

# Public IP for Virtual Machine
resource "azurerm_public_ip" "apache_web_server_public_ip" {
    name                = "${var.prefix}-${var.web_server_name}-public-ip"
    location            = "${var.location}"
    resource_group_name = "${azurerm.apache_web_server_rg.name}"
    allocation_method   = "Dynamic"
}

resource "azurerm_virtual_machine" "apache_web_server_vm" {
    name                    = "${var.prefix}-${var.web_server_name}-srv"
    location                = "${var.location}"
    resource_group_name     = "${azurerm.apache_web_server_rg.name}"

    sku {
        name        = "Standard_B1ls"
        tier        = "Standard"
        capacity    = "${var.web_server_count}"
    }

    storage_profile_image_reference {
        publisher   = "Canonical"
        offer       = "UbuntuServer"
        sku         = "18.04-LTS"
        version     = "latest"
    }

    storage_profile_os_disk {
        name                = ""
        caching             = "ReadWrite"
        create_option       = "FromImage"
        managed_disk_type   = "Standard_LRS"
    }

    os_profile {
        computer_name_prefix  = "${local.web_server_name}" 
        admin_username = "testadmin"
        admin_password = "Password1234"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}