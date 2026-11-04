resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
resource "azurerm_virtual_network" "lab" {
  name                = "${var.cluster_name}-vnet"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.80.0.0/16"]
  tags                = var.tags
}
resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.80.1.0/24"]
}
resource "azurerm_log_analytics_workspace" "lab" {
  name                = "${var.cluster_name}-logs"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}
resource "azurerm_kubernetes_cluster" "lab" {
  name                = var.cluster_name
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  dns_prefix          = var.cluster_name

  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  azure_policy_enabled              = true
  local_account_disabled            = true

  default_node_pool {
    name                 = "system"
    vm_size              = var.node_vm_size
    node_count           = var.node_count
    vnet_subnet_id       = azurerm_subnet.aks.id
    type                 = "VirtualMachineScaleSets"
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 2
    os_disk_size_gb      = 64
    upgrade_settings { max_surge = "33%" }
  }
  identity { type = "SystemAssigned" }
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }
  oms_agent { log_analytics_workspace_id = azurerm_log_analytics_workspace.lab.id }
  tags = var.tags
}
