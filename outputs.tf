output "registration_token" {
  value     = "${azurerm_virtual_desktop_host_pool.avd.registration_info.token}"
  sensitive = true
}