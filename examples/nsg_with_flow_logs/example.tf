provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  alias = "peer"
}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azure"
  version     = "1.0.1"
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
  version             = "1.0.1"
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
  label_order          = ["name", "environment", "location"]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  storage_account_name = "mystorage42343432"
  ##   Storage Container
  containers_list = [
    { name = "app-test", access_type = "private" },
    { name = "app2", access_type = "private" },
  ]
  ##   Storage File Share
  file_shares = [
    { name = "fileshare1", quota = 5 },
  ]
  ##   Storage Tables
  tables = ["table1"]
  ## Storage Queues
  queues                   = ["queue1"]
  management_policy_enable = true
  #enable private endpoint
  virtual_network_id                = module.vnet.vnet_id
  subnet_id                         = module.subnet.default_subnet_id[0]
  enable_diagnostic                 = false
  enable_advanced_threat_protection = false
}

##-----------------------------------------------------------------------------
## Network Security Group module call.
##-----------------------------------------------------------------------------
module "network_security_group" {
  depends_on                        = [module.subnet, module.storage]
  source                            = "../../"
  name                              = "core"
  environment                       = "dev"
  label_order                       = ["name", "environment", "location"]
  resource_group_name               = module.resource_group.resource_group_name
  location                          = module.resource_group.resource_group_location
  enable_flow_logs                  = true
  network_watcher_name              = module.vnet.network_watcher_name
  flow_log_storage_account_id       = module.storage.storage_account_id
  enable_traffic_analytics          = true
  flow_log_retention_policy_enabled = true
  enable_diagnostic                 = true
  resource_position_prefix          = true
  traffic_analytics_settings = {
    log_analytics_workspace_id          = module.log-analytics.workspace_id
    workspace_region                    = module.resource_group.resource_group_location
    log_analytics_workspace_resource_id = module.log-analytics.workspace_customer_id
    interval_in_minutes                 = 60
  }
  inbound_rules = [
    {
      name                       = "ssh"
      priority                   = 101
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "10.20.0.0/32"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "22"
      description                = "ssh allowed port"
    },
    {
      name                       = "https"
      priority                   = 102
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "0.0.0.0/0"
      source_port_range          = "*"
      destination_address_prefix = "VirtualNetwork"
      destination_port_range     = "80,443"
      description                = "https allowed port"
    }
  ]
  logs = [{
    category = "NetworkSecurityGroupEvent"
    },
    {
      category = "NetworkSecurityGroupRuleCounter"
    }
  ]
}
