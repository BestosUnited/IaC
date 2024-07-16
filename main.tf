terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "BESTOS-RG"
    storage_account_name = "sabestos"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  } 
}

locals {
  environment = terraform.workspace
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "RG-1" {
  name     = "rg-bestos-${local.environment}"
  location = var.location
}


## if merging HUB and SPOKE:


resource "azurerm_virtual_network" "VNET-1" {
  name                = "vnet-bestos-${local.environment}-001"
  resource_group_name = azurerm_resource_group.RG-1.name
  address_space       = [var.VNET_address_spaces["${local.environment}"]]
  location            = azurerm_resource_group.RG-1.location
}

resource "azurerm_subnet" "subnet-VM" {
  name                 = "subnet-bestos-${local.environment}-001"
  resource_group_name  = azurerm_resource_group.RG-1.name
  virtual_network_name = azurerm_virtual_network.VNET-1.name
  address_prefixes     = [var.VM_subnet_address_prefixes["${local.environment}"]]
}

resource "azurerm_public_ip" "public-ip-1" {
  name                = "public-ip-bestos-${local.environment}-001"
  resource_group_name = azurerm_resource_group.RG-1.name
  location            = azurerm_resource_group.RG-1.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic-1" {
  name                = "nic-bestos-${local.environment}-001"
  location            = azurerm_resource_group.RG-1.location
  resource_group_name = azurerm_resource_group.RG-1.name

  ip_configuration {
    name      = "internal"
    subnet_id = azurerm_subnet.subnet-VM.id

    #means that NIC receives available IP after being assigned to a subnet (after being plugged into the switch)
    private_ip_address_allocation = "Dynamic" 
    public_ip_address_id          = azurerm_public_ip.public-ip-1.id
  }
}

resource "azurerm_network_security_group" "nsg-1" {
  name                = "nsg-bestos-${local.environment}-001"
  location            = azurerm_resource_group.RG-1.location
  resource_group_name = azurerm_resource_group.RG-1.name

  security_rule {
    name                       = "AllowAll"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet-VM-nsg-1" {
  subnet_id                 = azurerm_subnet.subnet-VM.id
  network_security_group_id = azurerm_network_security_group.nsg-1.id
}

resource "azurerm_windows_virtual_machine" "vm-windows-1" {
  name                = "vm-bestos-${local.environment}"
  resource_group_name = azurerm_resource_group.RG-1.name
  location            = azurerm_resource_group.RG-1.location
  size                = "Standard_F2"
  ## use env variables here
  admin_username      = "adminuser"
  admin_password      = "Password1234+"
  network_interface_ids = [
    azurerm_network_interface.nic-1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

# # #   # depends_on = [
# # #   #   azurerm_subnet.subnet-VM
# # #   # ]
}


resource "azurerm_subnet" "subnet-VNG" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.RG-1.name
  virtual_network_name = azurerm_virtual_network.VNET-1.name
  address_prefixes     = ["10.11.0.0/24"]
}

resource "azurerm_public_ip" "public-ip-VNG" {
  name                = "public-ip-bestos-VNG-001"
  resource_group_name = azurerm_resource_group.RG-1.name
  location            = azurerm_resource_group.RG-1.location
  allocation_method   = "Dynamic"
}


resource "azurerm_local_network_gateway" "lng-1" {
  name                = "lng-bestos-001"
  location            = azurerm_resource_group.RG-1.location
  resource_group_name = azurerm_resource_group.RG-1.name
  gateway_address     = "92.220.49.188" #on-prem public IP
  ### This must be a network CIDR that on-prem VPN server knows routes to.
  address_space       = ["10.0.0.0/24"] #on-prem adress space (NODE CIDR) 
}

resource "azurerm_virtual_network_gateway" "vng-1" {
  name                = "vng-bestos-001"
  location            = azurerm_resource_group.RG-1.location
  resource_group_name = azurerm_resource_group.RG-1.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.public-ip-VNG.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet-VNG.id
  }

### This is needed only for P2S VPN:
#   vpn_client_configuration {
#     address_space = ["192.168.0.0/24"]

# #     root_certificate {
# #       name = "DigiCert-Federated-ID-Root-CA"

# #       public_cert_data = <<EOF
# # MIIC5zCCAc+gAwIBAgIQZGG4Mk3sS6xLPqy3+OdwEzANBgkqhkiG9w0BAQsFADAW
# # MRQwEgYDVQQDDAtQMlNSb290Q2VydDAeFw0yMzA4MzExMjE1MjJaFw0yNTA4MzEx
# # MjI1MjJaMBYxFDASBgNVBAMMC1AyU1Jvb3RDZXJ0MIIBIjANBgkqhkiG9w0BAQEF
# # AAOCAQ8AMIIBCgKCAQEAvSEcFSNPkKMyfyMM7cVmLZr3bFwKjI8IXp+gcSpDZbl0
# # 8ZK90cJqbssBcuYZjy3aCiyPD8eB6KE7399t6kHdM3svcnA2UP4NLru10Ao+vqWD
# # 4GnMa8Y4684iAnaNV6/NfjDtDc8liLB+pDQ0qp28of8LnGDvmDgKSk1txsZ1Fl+l
# # wV1H+D6Qwh1JtO9fuNrK9uBh6JE7x6rS/IiSoa6mq2HVXpApayn3Ebl3rrWl1jAj
# # Q0YJ/va5A+UFVGlEgzAs+XW1f1ffv6alJSx2f4L5hEuoRlakMYR3vNTEqcWLIp7G
# # ReaV9QFCz2RHe3cyuZQqWmic8DSb2dkyJT7Gvlf8kQIDAQABozEwLzAOBgNVHQ8B
# # Af8EBAMCAgQwHQYDVR0OBBYEFEdFjqp/ZeOjB4Lpi3CcakO9qdkZMA0GCSqGSIb3
# # DQEBCwUAA4IBAQBtfwwGzF+P06Qd6MlBypT79r6mifP1fuezzrDCyVy8m7HJZJPD
# # NV/gQXMLiGBJ6DSjMzVWgT+kmx37qC/M1+lEdGiTOW24qcPk/4PBiegaDJAP9t51
# # lLqYo6PemiAXZNJ3bllOzfeYQG9VlGyi0U1SlTCegSyoOwRQE2pM5ztitVNdPZMI
# # 0GgfC+Mj6COuxnUZA87Dc3NYOzlZQRHptM21P8stU2MCAYJoZfSgNCbztr6zoqE7
# # ++iC9LFVWGspJSn1PdEqjdv78z/I1QIpsI3n4ANapgIc/XZNvoHOKxEM8l4MXk6t
# # 6MWoDm9COXsjeM62GSPeKtwPHR2CNuHdB1w2
# # EOF
# #     }

#     # revoked_certificate {
#     #   name       = "Verizon-Global-Root-CA"
#     #   thumbprint = "912198EEF23DCAC40939312FEE97DD560BAE49B1"
#     # }
#   }
}

resource "azurerm_virtual_network_gateway_connection" "s2s-vng-1-lng-1" {
  name                = "s2s-bestos-001"
  location            = azurerm_resource_group.RG-1.location
  resource_group_name = azurerm_resource_group.RG-1.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vng-1.id
  local_network_gateway_id   = azurerm_local_network_gateway.lng-1.id

  shared_key = "bestos_2023"
}






##------------------------------------------------------------------
## if module is for SPOKE VNET, use this: 


# resource "azurerm_virtual_network" "VNET-spoke" {
#   name                = "vnet-bestos-${local.environment}-001"
#   resource_group_name = azurerm_resource_group.RG-1.name
#   address_space       = [var.VNET_address_spaces["${local.environment}"]]
#   location            = azurerm_resource_group.RG-1.location


# resource "azurerm_subnet" "subnet-VM" {
#   name                 = "subnet-bestos-${local.environment}-001"
#   resource_group_name  = azurerm_resource_group.RG-1.name
#   virtual_network_name = azurerm_virtual_network.VNET-spoke.name
#   address_prefixes     = [var.VM_subnet_address_prefixes["${local.environment}"]]
# }


# resource "azurerm_subnet" "subnet-WEBAPP" {
#   name                 = "subnet-bestos-${local.environment}-002"
#   resource_group_name  = azurerm_resource_group.RG-1.name
#   virtual_network_name = azurerm_virtual_network.VNET-spoke.name
#   address_prefixes     = [var.APP_subnet_address_prefixes["${local.environment}"]]
# }

# ### Here we have to retrieve Hub VNET id...
# data "azurerm_virtual_network" "VNET-HUB" {
#   name                = var.vnet-hub-name
#   resource_group_name = var.rg-hub-name
# }

# resource "azurerm_virtual_network_peering" "peering-Spoke-to-Hub" {
#   name                      = "peering-Spoke-to-Hub-${local.environment}"
#   #SPOKE RG - this VNET
#   resource_group_name       = azurerm_resource_group.RG-1.name
#   virtual_network_name      = azurerm_virtual_network.VNET-spoke.name
#   remote_virtual_network_id = data.azurerm_virtual_network.VNET-HUB.id

#   ## Only if VNG exists
#   #use_remote_gateways=true
# }

# resource "azurerm_virtual_network_peering" "peering-Hub-to-Spoke" {
#   name                      = "peering-Hub-to-Spoke-${local.environment}"
#   #HUB RG - this VNET.
#   resource_group_name       = var.rg-hub-name
#   virtual_network_name      = data.azurerm_virtual_network.VNET-HUB.name
#   remote_virtual_network_id = azurerm_virtual_network.VNET-spoke.id

#   ##Need this only if HUB VNET will have an NVA to forward traffic between spokes. 
#   #allow_forwarded_traffic = false
#   ## Only if VNG exists
#   #allow_gateway_transit = true
# }

# resource "azurerm_public_ip" "public-ip-1" {
#   name                = "public-ip-bestos-${local.environment}-001"
#   resource_group_name = azurerm_resource_group.RG-1.name
#   location            = azurerm_resource_group.RG-1.location
#   allocation_method   = "Dynamic"

#   tags = {
#     environment = "${local.environment}"
#   }
# }

# resource "azurerm_network_interface" "nic-1" {
#   name                = "nic-bestos-${local.environment}-001"
#   location            = azurerm_resource_group.RG-1.location
#   resource_group_name = azurerm_resource_group.RG-1.name

#   ip_configuration {
#     name      = "internal"
#     subnet_id = azurerm_subnet.subnet-VM.id

#     #means that NIC receives available IP after being assigned to a subnet (after being plugged into the switch)
#     private_ip_address_allocation = "Dynamic" 
#     public_ip_address_id          = azurerm_public_ip.public-ip-1.id
#   }
  
# }

# resource "azurerm_network_security_group" "nsg-1" {
#   name                = "nsg-bestos-${local.environment}-001"
#   location            = azurerm_resource_group.RG-1.location
#   resource_group_name = azurerm_resource_group.RG-1.name

#   security_rule {
#     name                       = "AllowRDP"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "3389"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

# resource "azurerm_subnet_network_security_group_association" "subnet-VM-nsg-1" {
#   subnet_id                 = azurerm_subnet.subnet-VM.id
#   network_security_group_id = azurerm_network_security_group.nsg-1.id
# }

# resource "azurerm_windows_virtual_machine" "vm-windows-1" {
#   name                = "vm-bestos-${local.environment}"
#   resource_group_name = azurerm_resource_group.RG-1.name
#   location            = azurerm_resource_group.RG-1.location
#   size                = "Standard_F2"
#   admin_username      = "adminuser"
#   admin_password      = "Password1234!+"
#   network_interface_ids = [
#     azurerm_network_interface.nic-1.id,
#   ]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "MicrosoftWindowsServer"
#     offer     = "WindowsServer"
#     sku       = "2016-Datacenter"
#     version   = "latest"
#   }

#   # depends_on = [
#   #   azurerm_subnet.subnet-VM
#   # ]
# }

# resource "azurerm_service_plan" "asp-1" {
#   name                = "asp-bestos-${local.environment}-001"
#   location            = azurerm_resource_group.RG-1.location
#   resource_group_name = azurerm_resource_group.RG-1.name
#   sku_name            = "B1"
#   os_type             = "Windows"
# }

# resource "azurerm_windows_web_app" "webapp-1" {
#   name                = "webapp-bestos-${local.environment}-001"
#   location            = azurerm_resource_group.RG-1.location
#   resource_group_name = azurerm_resource_group.RG-1.name
#   #this is interesting! apparently MAIN.tf fetches resource attributes from TFSTATE itself!
#   service_plan_id     = azurerm_service_plan.asp-1.id 
#   # virtual_network_subnet_id = azurerm_subnet.subnet-WEBAPP.id
  

#   site_config {} 
# }

# ##App Service Plan - Linux
# # resource "azurerm_service_plan" "ASP-1" {
# #   name                = "asp-bestos-${local.environment}-001"
# #   resource_group_name = azurerm_resource_group.RG-1.name
# #   location            = azurerm_resource_group.RG-1.location
# #   os_type             = "Linux"
# #   sku_name            = "B1"
# # }

# ##Linux web app
# # resource "azurerm_linux_web_app" "linux_web_app-1" {
# #   name                = "linuxWebApp-bestos-${local.environment}-001"
# #   resource_group_name = azurerm_resource_group.RG-1.name
# #   location            = azurerm_service_plan.ASP-1.location
# #   service_plan_id     = azurerm_service_plan.ASP-1.id

# #   site_config {}
# # }
