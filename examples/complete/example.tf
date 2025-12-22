provider "azurerm" {
  features {}
  subscription_id = "1ac2caa4-336e-4daa-b8f1-0fbabe2d4b11"
}

provider "azurerm" {
  features {}
  subscription_id = "1ac2caa4-336e-4daa-b8f1-0fbabe2d4b11"
  alias           = "peer"
}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.3"
  name        = "core"
  environment = "dev"
  location    = "centralus"
  label_order = ["name", "environment", "location"]
}

##-----------------------------------------------------------------------------
## Virtual Network module call.
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
  name                = "core"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}


# ------------------------------------------------------------------------------
# Subnet
# ------------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.1"
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
  source                      = "terraform-az-modules/log-analytics/azurerm"
  version                     = "1.0.2"
  name                        = "core"
  environment                 = "dev"
  label_order                 = ["name", "environment", "location"]
  log_analytics_workspace_sku = "PerGB2018"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  log_analytics_workspace_id  = module.log-analytics.workspace_id
}

##-----------------------------------------------------------------------------
## Storage Module call.
## Storage account in which network security group flow log will be received.
##-----------------------------------------------------------------------------
module "storage" {
  providers = {
    azurerm.main_sub = azurerm
    azurerm.dns_sub  = azurerm.peer
  }
  source               = "clouddrove/storage/azure"
  version              = "1.1.1"
  name                 = "core"
  environment          = "dev"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  storage_account_name = "mystorage42343432"
  containers_list = [
    { name = "app-test", access_type = "private" },
    { name = "app2", access_type = "private" },
  ]
  file_shares = [
    { name = "fileshare1", quota = 5 },
  ]
  tables                            = ["table1"]
  queues                            = ["queue1"]
  management_policy_enable          = true
  virtual_network_id                = module.vnet.vnet_id
  subnet_id                         = module.subnet.subnet_ids.subnet1
  enable_diagnostic                 = false
  enable_advanced_threat_protection = false
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
  subnet_ids               = [module.subnet.subnet_ids.subnet1]
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
  enable_diagnostic          = true
  log_analytics_workspace_id = module.log-analytics.workspace_id
  storage_account_id         = module.storage.storage_account_id
  logs = [{
    category = "NetworkSecurityGroupEvent"
    },
    {
      category = "NetworkSecurityGroupRuleCounter"
    }
  ]
}