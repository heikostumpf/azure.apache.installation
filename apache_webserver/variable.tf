variable "prefix" {
    default = "heiko"
}

variable "location" {
    default = "West US"
}

variable "web_server_name" {
    default = "apache-web"
}

variable "vnet_address_space" {
    default = ["10.0.0.0/16"]
}

variable "subnet_address_space" {
    default = ["10.0.1.0/24", "10.0.2.0/24"]
}