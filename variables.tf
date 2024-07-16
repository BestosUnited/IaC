variable "key" {
    type = string
    default=""
}

variable "location" {
    type = string
    default="Norway East"
}

variable "rg-hub-name" {
    type = string
    default="rg-bestos-hub"
}

variable "vnet-hub-name" {
    type = string
    default="vnet-bestos-hub"
}

variable "VNET_address_spaces" {
    type = map
    default = {
        "dev" = "10.11.0.0/16"
        "qa" = "10.12.0.0/16"
        "prod" = "10.13.0.0/16"
    }
}

variable "VM_subnet_address_prefixes" {
    type = map
    default = {
        "dev" = "10.11.1.0/24"
        "qa" = "10.12.1.0/24"
        "prod" = "10.13.1.0/24"
    }
}

# variable "APP_subnet_address_prefixes" {
#     type = map
#     default = {
#         "dev" = "10.11.1.0/24"
#         "qa" = "10.12.1.0/24"
#         "prod" = "10.13.1.0/24"
#     }
# }