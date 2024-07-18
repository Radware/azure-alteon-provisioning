#Point to azure provider
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

# create resource group
resource "azurerm_resource_group" "alteon-deploy" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    Owner = var.owner_tag
  }
}

#create virtual network
resource "azurerm_virtual_network" "alteon-deploy" {
  name                = "alteon-deploy-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.alteon-deploy.location
  resource_group_name = azurerm_resource_group.alteon-deploy.name
  tags = {
    Owner = var.owner_tag
  }
}

#create management subnet 
resource "azurerm_subnet" "mgmt_subnet" {
  name                 = "alteon-deploy-mgmt-subnet"
  resource_group_name  = azurerm_resource_group.alteon-deploy.name
  virtual_network_name = azurerm_virtual_network.alteon-deploy.name
  address_prefixes     = [var.subnet_cidrs[0]]

}

#create data subnet
resource "azurerm_subnet" "client_subnet" {
  name                 = "alteon-deploy-data-subnet"
  resource_group_name  = azurerm_resource_group.alteon-deploy.name
  virtual_network_name = azurerm_virtual_network.alteon-deploy.name
  address_prefixes     = [var.subnet_cidrs[1]]

}

#create server subnet
resource "azurerm_subnet" "servers_subnet" {
  name                 = "alteon-deploy-servers-subnet"
  resource_group_name  = azurerm_resource_group.alteon-deploy.name
  virtual_network_name = azurerm_virtual_network.alteon-deploy.name
  address_prefixes     = [var.subnet_cidrs[2]]

}

#create management Public IP address for configure the alteon after boot up.
resource "azurerm_public_ip" "alteon-deploy" {
  name                = "alteon-deploy-pip"
  location            = azurerm_resource_group.alteon-deploy.location
  resource_group_name = azurerm_resource_group.alteon-deploy.name
  allocation_method   = "Static"
  tags = {
    Owner = var.owner_tag
  }
}

#create management NIC
resource "azurerm_network_interface" "mgmt_nic" {
  name                = "alteon-deploy-mgmt-nic"
  location            = azurerm_resource_group.alteon-deploy.location
  resource_group_name = azurerm_resource_group.alteon-deploy.name
  

  ip_configuration {
    primary                       = true
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mgmt_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.alteon-deploy.id
  }
  tags = {
    Owner = var.owner_tag
  }
}

#create client NIC
resource "azurerm_network_interface" "client_nic" {
  name                = "alteon-deploy-client-nic"
  location            = azurerm_resource_group.alteon-deploy.location
  resource_group_name = azurerm_resource_group.alteon-deploy.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.client_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    Owner = var.owner_tag
  }
}

#create servers NIC
resource "azurerm_network_interface" "servers_nic" {
  name                = "alteon-deploy-servers-nic"
  location            = azurerm_resource_group.alteon-deploy.location
  resource_group_name = azurerm_resource_group.alteon-deploy.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.servers_subnet.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
  #for PIP address 
  ip_configuration {
    name                          = "secondary"
    subnet_id                     = azurerm_subnet.servers_subnet.id
    private_ip_address_allocation = "Dynamic"
    primary                       = false
  }
  tags = {
    Owner = var.owner_tag
  }
}

resource "azurerm_network_security_group" "alteon-deploy" {
  name                = "alteon-deploy-nsg"
  location            = azurerm_resource_group.alteon-deploy.location
  resource_group_name = azurerm_resource_group.alteon-deploy.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_https"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_custom_ssh"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2222"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_custom_https"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_custom_port"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "7070"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    Owner = var.owner_tag
  }
}


resource "azurerm_virtual_machine" "alteon-deploy" {
  name                  = "alteon-deploy-vm"
  location              = azurerm_resource_group.alteon-deploy.location
  resource_group_name   = azurerm_resource_group.alteon-deploy.name
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  network_interface_ids = [
    azurerm_network_interface.mgmt_nic.id,
    azurerm_network_interface.client_nic.id,
    azurerm_network_interface.servers_nic.id
  ]
  primary_network_interface_id = azurerm_network_interface.mgmt_nic.id
  vm_size               = var.vm_size

  storage_os_disk {
    name              = "alteon-deploy-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "radware"
    offer     = "radware-alteon-va"
    sku       = "radware-alteon-ng-va-adc"
    version   = "latest"
  }

  os_profile {
    computer_name  = "alteon-deployvm"
    admin_username = var.admin_user
    admin_password = var.admin_password
     # Use the templatefile function to inject user data
    custom_data = templatefile("${path.module}/userdata.tpl", {
    admin_user             = var.admin_user,
    admin_password         = var.admin_password,
    gel_url_primary        = var.gel_url_primary,
    gel_url_secondary      = var.gel_url_secondary,
    vm_name                = var.vm_name,
    gel_ent_id             = var.gel_ent_id,
    gel_throughput_mb      = var.gel_throughput_mb,
    gel_dns_pri            = var.gel_dns_pri,
    ntp_primary_server     = var.ntp_primary_server,
    ntp_tzone              = var.ntp_tzone,
    cc_local_ip            = var.cc_local_ip,
    cc_remote_ip           = var.cc_remote_ip,
    adc_data_eni_private_ip = azurerm_network_interface.client_nic.private_ip_address,
    adc_servers_eni_private_ip = azurerm_network_interface.servers_nic.ip_configuration[0].private_ip_address,
    adc_servers_eni_private_ip_PIP = azurerm_network_interface.servers_nic.ip_configuration[1].private_ip_address,
    #data_subnet_gateway    = local.data_subnet_gateway,
    #servers_subnet_gateway = local.servers_subnet_gateway
    hst1_ip                = var.hst1_ip,
    hst1_severity          = var.hst1_severity,
    hst1_facility          = var.hst1_facility,
    hst1_module            = var.hst1_module,
    hst1_port              = var.hst1_port,
    hst2_ip                = var.hst2_ip,
    hst2_severity          = var.hst2_severity,
    hst2_facility          = var.hst2_facility,
    hst2_module            = var.hst2_module,
    hst2_port              = var.hst2_port
    })
  }

  os_profile_linux_config {
      disable_password_authentication = false
    }

  tags = {
    Owner = var.owner_tag
  }

  plan {
  name      = "radware-alteon-ng-va-adc"
  product   = "radware-alteon-va"
  publisher = "radware"
  }

}

 

output "deployment_message" {
  value = var.operation == "create" ? format("Alteon ADC has been deployed to Azure VM in region %s with tenant ID %s and instance ID %s. Access it at https://%s. You can SSH into the instance using port 2222. It might take 15-20 minutes for Alteon ADC to load up the config. If the userdata that was passed to the TF template was not valid, the admin password that you defined will not work, and instead the admin password will be the Instance ID: R@dware12345 | You may use PIP address %s", var.location, data.azurerm_client_config.current.tenant_id, azurerm_virtual_machine.alteon-deploy.id, azurerm_public_ip.alteon-deploy.ip_address, azurerm_network_interface.servers_nic.ip_configuration[1].private_ip_address) : format("Alteon ADC in Azure VM in region %s with instance ID %s is being destroyed.", var.location, azurerm_virtual_machine.alteon-deploy.id)
}
