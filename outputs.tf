output "id" {
  value       = try(azurerm_network_security_group.nsg[0].id, null)
  description = "The network security group configuration ID."
}

output "name" {
  value       = try(azurerm_network_security_group.nsg[0].name, null)
  description = "The name of the network security group."
}

output "tags" {
  value       = module.labels.tags
  description = "The tags assigned to the resource."
}

output "network_security_group_id" {
  value       = azurerm_network_security_group.nsg[0].id
  description = "The ID of network security group"
}
