## Improvement - need to pass unique tfvars file for each environment

key ="wVy6OcHlFrtoI4j03dAPJv7aUl8TzWYTUSxp/gDTNo+sjWWhu2LjwJiH1rVPEida+JASE2xVSHOI+AStfqj89g=="

location ="Norway East"

rg-hub-name = "rg-bestos-hub"

vnet-hub-name="vnet-bestos-hub"

VNET_address_spaces = {
        "dev" = "10.11.0.0/16"
        "qa" = "10.12.0.0/16"
        "prod" = "10.13.0.0/16"
    }

VM_subnet_address_prefixes = {
        "dev" = "10.11.1.0/24"
        "qa" = "10.12.1.0/24"
        "prod" = "10.13.1.0/24"
    }

# APP_subnet_address_prefixes = {
#         "dev" = "10.11.1.0/24"
#         "qa" = "10.12.1.0/24"
#         "prod" = "10.13.1.0/24"
#     }