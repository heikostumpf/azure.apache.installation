# Terraform Scripts for Microsoft Azure

This repository contains various terraform projects to provision cloud environments in Microsoft Azure.

## Projects
1. Apache WebServer ([apache_webserver](https://github.com/heikostumpf/terraform.azure/tree/master/apache_webserver)]): Provision a Virtual Machine running an Apache Webserver with PHP. A public IP enables access to the Apache WebServer.

## Authentication
To run the terraform scripts in this repository it is sufficient enough to log into Azure by using a User-Account. However, Microsoft Azure is recommending the usage of a ServicePrincipal.

```
$ az login
```

## Run
```
$ cd navigate/into/project/folder
$ terraform init
$ terraform plan
$ terraform apply
```

## Destroy
```
$ cd navigate/into/project/folder
$ terraform destory
```

## Disclaimer
Most of the terraform projects create infrastructure components that cost money.

## Links
* [Terraform Azure Authentication](https://www.terraform.io/docs/providers/azurerm/auth/azure_cli.html)
* [How to enable ssh on Azure VM](https://medium.com/techinpieces/practical-azure-how-to-enable-ssh-on-azure-vm-84d8fba8103e)