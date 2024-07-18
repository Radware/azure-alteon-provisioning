# Azure Alteon ADC Deployment with Terraform

This Terraform project deploys an Azure Virtual Network with management, data, and server subnets, network security groups, network interfaces, and a Virtual Machine configured with specific user data.

## Prerequisites

- Terraform installed on your local machine.
- Azure CLI installed and configured with your credentials.

### Installing Azure CLI

To install Azure CLI, follow these steps:

1. **Download and Install Azure CLI**

   For Windows, download the installer from [Azure CLI Windows Installer](https://aka.ms/installazurecliwindows).

   For macOS, you can use Homebrew:

   ```sh
   brew install azure-cli
   ```

   For Linux, you can use a package manager like `apt` for Debian-based distributions:

   ```sh
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

   Or `yum` for Red Hat-based distributions:

   ```sh
   sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
   sudo sh -c 'echo -e "[azure-cli]
   name=Azure CLI
   baseurl=https://packages.microsoft.com/yumrepos/azure-cli
   enabled=1
   gpgcheck=1
   gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
   sudo yum install azure-cli 
   ```

2. **Verify the Installation**

   After installation, verify that Azure CLI is installed correctly by running:

   ```sh
   az --version
   ```

3. **Configure Azure CLI**

   Sign in and configure your Azure CLI with your credentials by running:

   ```sh
   az login
   ```

   You will be prompted to open a browser and log in with your Azure account credentials.


By ensuring that Azure CLI is installed and configured, you will be able to interact with Azure services from your local machine.

### 2. Download the files to your PC

Clone this git repository to your local pc:

```sh
git clone https://github.com/Radware/azure-alteon-provisioning.git
```


### 3. Configure Variables

Copy the example `terraform.tfvars.example` file to `terraform.tfvars`:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Edit the `terraform.tfvars` file to customize the values according to your environment:

```plaintext
#Azure location (region)
location            = "West Europe"

#Name of the resource group
resource_group_name = "MyADCResourceGroup"

#VNET main Subnet
vnet_cidr           = "10.1.0.0/16"

subnet_cidrs        = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

admin_user      = "radware"

admin_password      = "Admin123!"

vm_size             = "Standard_DS3_v2"

# GEL primary URL
gel_url_primary = "http://primary.gel.example.com"

# GEL secondary URL
gel_url_secondary = "http://secondary.gel.example.com"

# GEL enterprise ID
gel_ent_id = "12345"

# GEL throughput in MB
gel_throughput_mb = 100

# GEL primary DNS
gel_dns_pri = "8.8.8.8"

# NTP primary server IP Address only
ntp_primary_server = "132.163.97.8"
.
.
.

```

### 4. Initialize Terraform

Initialize your Terraform working directory, which will download the necessary provider plugins and set up the backend.

```sh
terraform init
```

### 5. Plan the Deployment

Before applying the changes, you can run the `terraform plan` command to see a preview of the actions that Terraform will take to deploy your infrastructure.

```sh
terraform plan
```

### 6. Apply the Configuration

Finally, apply the configuration to deploy the resources. Terraform will prompt you for confirmation before proceeding.

```sh
terraform apply
```

## Resources Created

- **Virtual Network (VNet)**: A virtual network with a specified address space.
- **Subnets**: Management, data, and server subnets.
- **Network Security Groups (NSGs)**: Define security rules to allow traffic for specific ports and protocols.
- **Network Interfaces (NICs)**: Attached to the subnets.
- **Public IP Address**: Allocated and associated with the management network interface.
- **Virtual Machine (VM)**: Configured with user data from a template file.

## User Data Template

The `userdata.tpl` file is used to configure the VM instance. 
It includes variables for admin credentials, GEL URLs, VM name, and syslog configuration. 
The template file is populated with values from `terraform.tfvars` during the deployment.

## Cleanup

To destroy the resources created by this Terraform configuration, run:

```sh
terraform destroy
```

## Notes

- Ensure that your Azure credentials are configured correctly.
- Review the security group rules and adjust as needed to match your security requirements.# azure-alteon-provisioning
