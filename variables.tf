##### Global Variable #####

#### Tags ####
variable "owner" {
  type        = string
  description = "The name of the infra provisioner or owner"
  default     = "Prem"
}
variable "environment" {
  type        = string
  description = "The environment name"
}
variable "cost_center" {
  type        = string
  description = "The cost_center name for this project"
  default     = "personal budget"
}
variable "app_name" {
  type        = string
  description = "Application name of project"
  default     = "rd"
}
variable "location" {
  type        = string
  description = "The Location for Infra centre"
  default     = "West Europe"
}

### Network ###
variable "vnet_name" {
  type        = string
  description = "The core network environment vnet name"
}
variable "vnet_rg_name" {
  type        = string
  description = "The core network vnet resource group name"
}
variable "subnet_name" {
  type        = string
  description = "The cluster network subnet resource name"
}

variable "ipconf_name" {
  type        = string
  description = "The nic name for the compute resource"
}

### Host Pool ###
variable "host_pool_type" {
  type    = string
  default = "Pooled"
}

variable "host_pool_load_balancer_type" {
  type    = string
  default = "BreadthFirst"
}

variable "host_pool_validate_environment" {
  type    = bool
  default = false
}

variable "host_pool_max_sessions_allowed" {
  type    = number
  default = 999999
}

### Desktop App group ###
variable "desktop_app_group_type" {
  type    = string
  default = "Desktop"
}

### Share Image Gallery ###
variable "sig_image_name" {
  type        = string
  description = "Image definition name"
}

variable "publisher" {
  type        = string
  description = "Name of the OS publisher"
}

variable "offer" {
  type        = string
  description = "The Offer Name for the Image"
}

variable "sku" {
  type        = string
  description = "The Name of the SKU for the Image."
}

### VM Details ###
variable "os_type" {
  type        = string
  description = "The size of the vm"
}

variable "username" {
  type        = string
  description = "The root user name for the compute resource"
}

variable "password" {
  type        = string
  description = "The root password for the compute resource"
}

### AAD Details ##

variable "domain_name" {
  type        = string
  description = "The domain name for the vm to join"
}

variable "ou_path" {
  type        = string
  description = "The ou path details for the ad group"
}

variable "domain_user_upn" {
  type        = string
  description = "user details"
}

variable "domain_password" {
  type = string
  description = "user domain password details"
}