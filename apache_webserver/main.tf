provider "azurerm" {
    version = "~> 1.33"
}
# Resource Group
resource "azurerm_resource_group" "apache_web_server_rg" {
    name        = "${var.prefix}-${var.web_server_name}-rg"
    location    = "${var.location}"
}

# Virtual Network
resource "azurerm_virtual_network" "apache_web_server_vnet" {
    name                = "${var.prefix}-${var.web_server_name}-vnet" 
    address_space       = "${var.vnet_address_space}"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.apache_web_server_rg.name}"
}

# Subnet
resource "azurerm_subnet" "apache_web_server_subnet" {
    name                    = "${var.prefix}-${var.web_server_name}-subnet" 
    resource_group_name     = "${azurerm_resource_group.apache_web_server_rg.name}"
    virtual_network_name    = "${azurerm_virtual_network.apache_web_server_vnet.name}"
    address_prefix          = "${var.subnet_address_space[0]}"
}

# Public IP for Virtual Machine
resource "azurerm_public_ip" "apache_web_server_public_ip" {
    name                = "${var.prefix}-${var.web_server_name}-public-ip"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.apache_web_server_rg.name}"
    allocation_method   = "Dynamic"
}

# Network Interface (NIC)
resource "azurerm_network_interface" "apache_web_server_nic" {
    name                = "${var.prefix}-${var.web_server_name}-nic"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.apache_web_server_rg.name}"
    network_security_group_id = "${azurerm_network_security_group.apache_web_server_nsg.id}"

    ip_configuration {
        name                            = "${var.prefix}-${var.web_server_name}-ip-configuration"
        subnet_id                       = "${azurerm_subnet.apache_web_server_subnet.id}"
        private_ip_address_allocation   = "Dynamic"
        public_ip_address_id            = "${azurerm_public_ip.apache_web_server_public_ip.id}"
    }
}

resource "azurerm_virtual_machine" "apache_web_server_vm" {
    name                = "${var.prefix}-${var.web_server_name}-srv"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.apache_web_server_rg.name}"
    network_interface_ids = ["${azurerm_network_interface.apache_web_server_nic.id}"]
    vm_size        = "Standard_B1ls"
    
    delete_os_disk_on_termination = true
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher   = "Canonical"
        offer       = "UbuntuServer"
        sku         = "18.04-LTS"
        version     = "latest"
    }

    storage_os_disk {
        name                = "${var.web_server_name}-osdisk"
        caching             = "ReadWrite"
        create_option       = "FromImage"
        managed_disk_type   = "Standard_LRS"
    }

    os_profile {
        computer_name  = "${var.web_server_name}" 
        admin_username = "testadmin"
        admin_password = "Password1234"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_network_security_group" "apache_web_server_nsg" {
    name                = "${var.prefix}-${var.web_server_name}-nsg"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.apache_web_server_rg.name}"
}

resource "azurerm_network_security_rule" "apache_web_server_ssh" {
    name                        = "SSH_Inbound"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.apache_web_server_rg.name}"
    network_security_group_name = "${azurerm_network_security_group.apache_web_server_nsg.name}"
}

resource "azurerm_network_security_rule" "apache_web_server_http" {
    name                        = "HTTP_Inbound"
    priority                    = 200
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = "${azurerm_resource_group.apache_web_server_rg.name}"
    network_security_group_name = "${azurerm_network_security_group.apache_web_server_nsg.name}"
}

resource "azurerm_virtual_machine_extension" "apache_web_server_installation" {
    name                    = "${var.prefix}-${var.web_server_name}-installation"
    location                = "${var.location}"
    resource_group_name     = "${azurerm_resource_group.apache_web_server_rg.name}"
    virtual_machine_name    = "${azurerm_virtual_machine.apache_web_server_vm.name}"
    publisher               = "Microsoft.Azure.Extensions"
    type                    = "CustomScript"
    type_handler_version    = "2.0"

    settings = <<SETTINGS
        {
            "commandToExecute": "apt-get update && apt-get install apache2 -y && apt-get install php libapache2-mod-php -y && service apache2 start"
        }
    SETTINGS
}