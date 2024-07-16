# output "environment" {
#   value       = local.environment
#   sensitive   = false
#   description = "description"
#   depends_on  = []
# }

# output name {
#   value       = "Private IP: ${data.azurerm_network_interface.nic-1-data.private_ip_address}"
#   sensitive   = false
#   description = "description"
#   depends_on  = []
# }

output "VNG_public_IP" {
  ## modify. check tfstate
  value = azurerm_public_ip.public-ip-VNG.ip_address
}
