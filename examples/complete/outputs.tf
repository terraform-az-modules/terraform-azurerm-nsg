output "resource_group_name" {
  description = "The name of the resource group."
  value       = module.resource_group.resource_group_name
}

output "resource_group_location" {
  description = "The resource group location."
  value       = module.resource_group.resource_group_location
}

output "virtual_network_name" {
  description = "The name of the virtual network."
  value       = module.vnet.vnet_name
}

output "security_group_id" {
  value       = module.network_security_group.id
  description = "Network Security Group ID."
}

output "security_group_name" {
  value       = module.network_security_group.name
  description = "Network Security Group name."
}