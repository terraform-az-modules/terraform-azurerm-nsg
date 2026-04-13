## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create | Used when creating the Resource Group. | `string` | `"30m"` | no |
| custom\_name | Override default naming convention | `string` | `null` | no |
| delete | Used when deleting the Resource Group. | `string` | `"30m"` | no |
| deployment\_mode | Specifies how the infrastructure/resource is deployed | `string` | `"terraform"` | no |
| enable\_diagnostic | Set to false to prevent the module from creating the diagnosys setting for the NSG Resource.. | `bool` | `false` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| eventhub\_authorization\_rule\_id | Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| eventhub\_name | Eventhub Name to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| extra\_tags | Variable to pass extra tags. | `map(string)` | `null` | no |
| inbound\_rules | List of objects that represent the configuration of each inbound rule. | <pre>list(object({<br>    name                         = string<br>    priority                     = number<br>    access                       = string<br>    protocol                     = string<br>    source_address_prefix        = optional(string)<br>    source_address_prefixes      = optional(list(string))<br>    source_port_range            = optional(string)<br>    destination_address_prefix   = optional(string)<br>    destination_address_prefixes = optional(list(string))<br>    destination_port_range       = optional(string)<br>    description                  = optional(string)<br>  }))</pre> | `[]` | no |
| label\_order | The order of labels used to construct resource names or tags. If not specified, defaults to ['name', 'environment', 'location']. | `list(any)` | <pre>[<br>  "name",<br>  "environment",<br>  "location"<br>]</pre> | no |
| location | The location/region where the virtual network is created. Changing this forces a new resource to be created. | `string` | `""` | no |
| log\_analytics\_destination\_type | Possible values are AzureDiagnostics and Dedicated, default to AzureDiagnostics. When set to Dedicated, logs sent to a Log Analytics workspace will go into resource specific tables, instead of the legacy AzureDiagnostics table. | `string` | `"AzureDiagnostics"` | no |
| log\_analytics\_workspace\_id | log analytics workspace id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| logs | List of log categories. Defaults to all available. | `list(map(string))` | `[]` | no |
| managedby | ManagedBy, eg 'terraform-az-modules'. | `string` | `"terraform-az-modules"` | no |
| name | Name  (e.g. `app` or `cluster`). | `string` | `""` | no |
| nic\_association | If true, the Network Security Group will be associated with the network interfaces specified in `nic_ids`. | `bool` | `false` | no |
| nic\_ids | A list of Network Interface IDs to associate with the Network Security Group. | `list(string)` | `[]` | no |
| outbound\_rules | List of objects that represent the configuration of each outbound rule. | <pre>list(object({<br>    name                         = string<br>    priority                     = number<br>    access                       = string<br>    protocol                     = string<br>    source_address_prefix        = optional(string)<br>    source_address_prefixes      = optional(list(string))<br>    source_port_range            = optional(string)<br>    destination_address_prefix   = optional(string)<br>    destination_address_prefixes = optional(list(string))<br>    destination_port_range       = optional(string)<br>    description                  = optional(string)<br>  }))</pre> | `[]` | no |
| read | Used when retrieving the Resource Group. | `string` | `"5m"` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/terraform-az-modules/terraform-azure-nsg"` | no |
| resource\_group\_name | The name of the resource group in which to create the network security group. | `string` | n/a | yes |
| resource\_position\_prefix | Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.<br><br>- If true, the keyword is prepended: "vnet-core-dev".<br>- If false, the keyword is appended: "core-dev-vnet".<br><br>This helps maintain naming consistency based on organizational preferences. | `bool` | `true` | no |
| storage\_account\_id | Storage ID for Log Analytics | `string` | `null` | no |
| subnet\_association | If true, the Network Security Group will be associated with the subnets specified in `subnet_ids`. | `bool` | `true` | no |
| subnet\_ids | A list of Subnet IDs to associate with the Network Security Group. | `list(string)` | `[]` | no |
| update | Used when updating the Resource Group. | `string` | `"30m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The network security group configuration ID. |
| name | The name of the network security group. |
| network\_security\_group\_id | The ID of network security group |
| tags | The tags assigned to the resource. |

