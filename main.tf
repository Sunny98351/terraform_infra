provider "azurerm" {
    subscription_id = "63624c86-fe10-49d1-b0c7-b5b0be84da6a"
    client_id = "27ed852a-f10d-41bc-951c-d12bca932c28"
    client_secret = "Wvi8Q~13MgHl609Cm6Ba6F-774N3uUnk5dECGb0F"
    tenant_id = "7270ce39-4b64-4579-8f7f-93639d71f1ca"

    features {
      
    }
  
}
resource "azurerm_resource_group" "terrformad1" {
   name = "adi-p12"
   location = "eastus2"
}

resource "azurerm_storage_account" "adi1" {
    name = "aditya"
    resource_group_name = "adi-p12"
    location = "eastus2"
    account_tier = "Standard"
    account_replication_type = "LRS"
    depends_on = [ azurerm_resource_group.terrformad1 ]
 
}

resource "azurerm_virtual_network" "macnetwork" {
    name = "adi-network"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.terrformad1.location
    resource_group_name = azurerm_resource_group.terrformad1.name
}
resource "azurerm_subnet" "mscsubnet" {
   name = "internal"
   resource_group_name = azurerm_resource_group.terrformad1.name
   virtual_network_name = azurerm_virtual_network.macnetwork.name
   address_prefixes = ["10.0.0.0/24"]
}
resource "azurerm_network_interface" "macinterface" {
    name = "mac-nic"
    location = azurerm_resource_group.terrformad1.location
    resource_group_name = azurerm_resource_group.terrformad1.name

    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.mscsubnet.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.adi_public_ip.id

    }

}
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.macinterface.id
  network_security_group_id = azurerm_network_security_group.adi_nsg.id
}


resource "azurerm_windows_virtual_machine" "adivm" {
    name = "adi-mac"
    resource_group_name = azurerm_resource_group.terrformad1.name
    location = azurerm_resource_group.terrformad1.location
    size = "Standard_DS1_v2"
    admin_username = "dbadmin"
    admin_password = "Adi@98351"
    network_interface_ids = [ azurerm_network_interface.macinterface.id ]
    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    
    }
    source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "19h1-pro"
    version   = "latest"
  }
     
    }
    resource "azurerm_network_security_group" "adi_nsg" {
  name                = "acceptanceTestSecurityGroup1"
  location            =azurerm_resource_group.terrformad1.location
  resource_group_name = azurerm_resource_group.terrformad1.name

  security_rule {
    name                       = "aznsg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  # adding public ip
    }
    resource "azurerm_public_ip" "adi_public_ip" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.terrformad1.name
  location            = azurerm_resource_group.terrformad1.location
  allocation_method   = "Static"
    }
  
