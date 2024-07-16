terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }

   backend "azurerm" {
    storage_account_name = "sabestos"
    container_name       = "terraform"
    key                  = "hub.tfstate"
  } 
}

locals {
  environment = terraform.workspace
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "RG-HUB" {
  name     = var.rg-hub-name
  location = var.location
}

resource "azurerm_virtual_network" "VNET-HUB" {
  name                = var.vnet-hub-name
  resource_group_name = azurerm_resource_group.RG-HUB.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG-HUB.location
}

# resource "azurerm_subnet" "subnet-VNG" {
#   name                 = "GatewaySubnet"
#   resource_group_name  = azurerm_resource_group.RG-HUB.name
#   virtual_network_name = azurerm_virtual_network.VNET-HUB.name
#   address_prefixes     = ["10.0.0.0/24"]
# }

# resource "azurerm_public_ip" "public-ip-VNG" {
#   name                = "public-ip-bestos-VNG-001"
#   resource_group_name = azurerm_resource_group.RG-HUB.name
#   location            = azurerm_resource_group.RG-HUB.location
#   allocation_method   = "Dynamic"
# }


# resource "azurerm_local_network_gateway" "lng-1" {
#   name                = "lng-bestos-001"
#   location            = azurerm_resource_group.RG-HUB.location
#   resource_group_name = azurerm_resource_group.RG-HUB.name
#   gateway_address     = "92.220.49.188" #on-prem public IP
#   address_space       = ["192.168.1.0/24"] #on-prem adress space
# }

# resource "azurerm_virtual_network_gateway" "vng-1" {
#   name                = "vng-bestos-001"
#   location            = azurerm_resource_group.RG-HUB.location
#   resource_group_name = azurerm_resource_group.RG-HUB.name

#   type     = "Vpn"
#   vpn_type = "RouteBased"

#   active_active = false
#   enable_bgp    = false
#   sku           = "Basic"

#   ip_configuration {
#     name                          = "vnetGatewayConfig"
#     public_ip_address_id          = azurerm_public_ip.public-ip-VNG.id
#     private_ip_address_allocation = "Dynamic"
#     subnet_id                     = azurerm_subnet.subnet-VNG.id
#   }

# #   vpn_client_configuration {
# #     address_space = ["192.168.0.0/24"]

# # #     root_certificate {
# # #       name = "DigiCert-Federated-ID-Root-CA"

# # #       public_cert_data = <<EOF
# # # MIIC5zCCAc+gAwIBAgIQZGG4Mk3sS6xLPqy3+OdwEzANBgkqhkiG9w0BAQsFADAW
# # # MRQwEgYDVQQDDAtQMlNSb290Q2VydDAeFw0yMzA4MzExMjE1MjJaFw0yNTA4MzEx
# # # MjI1MjJaMBYxFDASBgNVBAMMC1AyU1Jvb3RDZXJ0MIIBIjANBgkqhkiG9w0BAQEF
# # # AAOCAQ8AMIIBCgKCAQEAvSEcFSNPkKMyfyMM7cVmLZr3bFwKjI8IXp+gcSpDZbl0
# # # 8ZK90cJqbssBcuYZjy3aCiyPD8eB6KE7399t6kHdM3svcnA2UP4NLru10Ao+vqWD
# # # 4GnMa8Y4684iAnaNV6/NfjDtDc8liLB+pDQ0qp28of8LnGDvmDgKSk1txsZ1Fl+l
# # # wV1H+D6Qwh1JtO9fuNrK9uBh6JE7x6rS/IiSoa6mq2HVXpApayn3Ebl3rrWl1jAj
# # # Q0YJ/va5A+UFVGlEgzAs+XW1f1ffv6alJSx2f4L5hEuoRlakMYR3vNTEqcWLIp7G
# # # ReaV9QFCz2RHe3cyuZQqWmic8DSb2dkyJT7Gvlf8kQIDAQABozEwLzAOBgNVHQ8B
# # # Af8EBAMCAgQwHQYDVR0OBBYEFEdFjqp/ZeOjB4Lpi3CcakO9qdkZMA0GCSqGSIb3
# # # DQEBCwUAA4IBAQBtfwwGzF+P06Qd6MlBypT79r6mifP1fuezzrDCyVy8m7HJZJPD
# # # NV/gQXMLiGBJ6DSjMzVWgT+kmx37qC/M1+lEdGiTOW24qcPk/4PBiegaDJAP9t51
# # # lLqYo6PemiAXZNJ3bllOzfeYQG9VlGyi0U1SlTCegSyoOwRQE2pM5ztitVNdPZMI
# # # 0GgfC+Mj6COuxnUZA87Dc3NYOzlZQRHptM21P8stU2MCAYJoZfSgNCbztr6zoqE7
# # # ++iC9LFVWGspJSn1PdEqjdv78z/I1QIpsI3n4ANapgIc/XZNvoHOKxEM8l4MXk6t
# # # 6MWoDm9COXsjeM62GSPeKtwPHR2CNuHdB1w2
# # # EOF
# # #     }

# #     # revoked_certificate {
# #     #   name       = "Verizon-Global-Root-CA"
# #     #   thumbprint = "912198EEF23DCAC40939312FEE97DD560BAE49B1"
# #     # }
# #   }
# }

# resource "azurerm_virtual_network_gateway_connection" "s2s-vng-1-lng-1" {
#   name                = "s2s-bestos-001"
#   location            = azurerm_resource_group.RG-HUB.location
#   resource_group_name = azurerm_resource_group.RG-HUB.name

#   type                       = "IPsec"
#   virtual_network_gateway_id = azurerm_virtual_network_gateway.vng-1.id
#   local_network_gateway_id   = azurerm_local_network_gateway.lng-1.id

#   shared_key = "bestos_2023"
# }