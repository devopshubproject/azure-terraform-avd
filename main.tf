##################################################
# locals for tagging
##################################################
locals {
  common_tags = {
    Owner       = "${var.owner}"
    Environment = "${var.environment}"
    Cost_center = "${var.cost_center}"
    Application = "${var.app_name}"
  }
}

##################################################
# Azure resource group
##################################################
resource "azurerm_resource_group" "rg" {
  name = "${var.environment}-${var.app_name}-rg"
  location = "${var.location}"
}

##################################################
# Azure Vnet
##################################################
data "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}"
  resource_group_name = "${var.vnet_rg_name}"
}

##################################################
# Azure Subnet
##################################################
data "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  virtual_network_name = "${data.azurerm_virtual_network.vnet.name}"
  resource_group_name = "${data.azurerm_virtual_network.vnet.resource_group_name}"
}

##################################################
# Azure NIC
##################################################

resource "azurerm_network_interface" "avd_nic" {
  name                = "${var.environment}-${var.app_name}-avd-name"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  enable_ip_forwarding = false
    ip_configuration {
      name = "${var.ipconf_name}"
      private_ip_address_allocation = "Dynamic"
      subnet_id = "${data.azurerm_subnet.subnet.id}"
     }
  tags = "${local.common_tags}"
}

##################################################
# Network security group
##################################################

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.environment}-${var.app_name}-nsg"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${var.location}"
  tags = "${local.common_tags}"
}

##################################################
# NSG adding to Subnet
##################################################

resource "azurerm_subnet_network_security_group_association" "nsg_subnet" {
  subnet_id                 = "${data.azurerm_subnet.subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

##############################################
# AZURE Host Pool
##############################################

resource "azurerm_virtual_desktop_host_pool" "pool" {
  name                     = "${var.environment}-${var.app_name}-pool"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${var.location}"
  type                     = "${var.host_pool_type}"
  load_balancer_type       = "${var.host_pool_load_balancer_type}"
  validate_environment     = "${var.host_pool_validate_environment}"
  maximum_sessions_allowed = "${var.host_pool_max_sessions_allowed}"

  registration_info {
    expiration_date = timeadd(format("%sT00:00:00Z", formatdate("YYYY-MM-DD", timestamp())), "3600m")
  }
  tags = "${local.common_tags}"
}

##############################################
# AZURE VIRTUAL DESKTOP Workspace
##############################################
resource "azurerm_virtual_desktop_workspace" "ws" {
  name                = "${var.environment}-${var.app_name}-ws"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${var.location}"
  friendly_name       = "${var.app_name}"
  description         = "A personal playbox workspace avd setup"
  tags = "${local.common_tags}"
}

resource "azurerm_virtual_desktop_application_group" "avd" {
  name                = "${var.environment}-${var.app_name}-avd"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${var.location}"
  host_pool_id        = "${azurerm_virtual_desktop_host_pool.pool.id}"
  type                = "${var.desktop_app_group_type}"
  friendly_name       = "${var.app_name}"
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "ws_ass" {
  workspace_id         = "${azurerm_virtual_desktop_workspace.ws.id}"
  application_group_id = "${azurerm_virtual_desktop_application_group.avd.id}"
}

##################################################
# Share Image Gallery
##################################################

#@#@#@#@#@#@#@# (Optional) @#@#@#@#@#@#@#@#@#@#@#

resource "azurerm_shared_image_gallery" "img_gallery" {
  name                = "${var.environment}-${var.app_name}-image-gallery"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${var.location}"
  description         = "Shared images gallery for storing the images which are to be used across the region"
  tags = "${local.common_tags}"
}

resource "azurerm_shared_image" "image" {
  name                = "${var.sig_image_name}"
  gallery_name        = "${azurerm_shared_image_gallery.img_gallery.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${var.location}"
  os_type             = "${var.os_type}"

  identifier {
    publisher = "${var.publisher}"
    offer     = "${var.offer}"
    sku       = "${var.sku}"
  }

}

##############################################
# AZURE VIRTUAL DESKTOP
##############################################

resource "azurerm_windows_virtual_machine" "avd_vm" {
  name                = "${var.environment}-${var.app_name}-avd-vm"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${var.location}"
  network_interface_ids = ["${azurerm_network_interface.avd_nic.id}"]
  size                = "${var.os_size}"
  admin_username      = "${var.username}"
  admin_password      = "${var.password}"
  os_disk {
    name                 = "${var.environment}-${var.app_name}-avd-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = "${azurerm_shared_image.image.id}"

  identity {
    type = "SystemAssigned"
  }
}