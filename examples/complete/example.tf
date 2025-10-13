provider "azurerm" {
  features {}
}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azure"
  version     = "1.0.0"
  name        = "core"
  environment = "dev"
  location    = "centralus"
  label_order = ["name", "environment", "location"]
}

# ------------------------------------------------------------------------------
# Virtual Network
# ------------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azure"
  version             = "1.0.0"
  name                = "core"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##-----------------------------------------------------------------------------
## Subnet Module call.
## Subnet to which network security group will be attached.
##-----------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azure"
  version              = "1.0.0"
  environment          = "dev"
  label_order          = ["name", "environment", "location"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name            = "subnet1"
      subnet_prefixes = ["10.0.1.0/24"]
    }
  ]
}

##-----------------------------------------------------------------------------
## Log Analytics module call.
## Log Analytics workspace in which network security group diagnostic setting logs will be received.
##-----------------------------------------------------------------------------
module "log-analytics" {
  source                      = "terraform-az-modules/log-analytics/azure"
  version                     = "1.0.1"
  name                        = "core"
  environment                 = "dev"
  label_order                 = ["name", "environment", "location"]
  log_analytics_workspace_sku = "PerGB2018"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  log_analytics_workspace_id  = module.log-analytics.workspace_id
}

##-----------------------------------------------------------------------------
## Network Security Group module call.
##-----------------------------------------------------------------------------
module "network_security_group" {
  depends_on               = [module.subnet]
  source                   = "../../"
  name                     = "core"
  environment              = "dev"
  label_order              = ["name", "environment", "location"]
  resource_group_name      = module.resource_group.resource_group_name
  location                 = module.resource_group.resource_group_location
  resource_position_prefix = true
  inbound_rules = [
    {
      name                       = "ssh"
      priority                   = 101
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "22"
      description                = "ssh allowed port"
    },
    {
      name                       = "https"
      priority                   = 102
      access                     = "Allow"
      protocol                   = "*"
      source_address_prefix      = "0.0.0.0/0"
      source_port_range          = "80,443"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "22"
      description                = "ssh allowed port"
    }
  ]
  enable_diagnostic                 = true
  log_analytics_workspace_id        = module.log-analytics.workspace_id
  flow_log_retention_policy_days    = 100
  flow_log_retention_policy_enabled = true
  logs = [{
    category = "NetworkSecurityGroupEvent"
    },
    {
      category = "NetworkSecurityGroupRuleCounter"
    }
  ]
}