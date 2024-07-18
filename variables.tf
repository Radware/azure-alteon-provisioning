variable "location" {
  description = "Azure Region"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
  default     = "alteon-deploy"
}

variable "owner_tag" {
  description = "The owner of the resources"
  type        = string
  default     = "tomerel@radware.com"
}

variable "vnet_cidr" {
  description = "VNet CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "Subnets CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "admin_user" {
  description = "Admin username for VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for VM"
  type        = string
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_DS3_v2"
}

variable "gel_url_primary" {
  description = "GEL primary URL"
  default     = "http://primary.gel.example.com"
}

variable "gel_url_secondary" {
  description = "GEL secondary URL"
  default     = "http://secondary.gel.example.com"
}

variable "gel_ent_id" {
  description = "GEL enterprise ID"
  default     = "12345"
}

variable "gel_throughput_mb" {
  description = "GEL throughput in MB"
  default     = "100"
}

variable "gel_dns_pri" {
  description = "GEL primary DNS"
  default     = "8.8.8.8"
}

variable "ntp_primary_server" {
  description = "NTP primary server IP Address only"
  default     = "132.163.97.8"
}

variable "ntp_tzone" {
  description = "NTP time zone"
  default     = "UTC"
}

variable "cc_local_ip" {
  description = "Local IP address"
  default     = "10.0.1.2"
}

variable "cc_remote_ip" {
  description = "Remote IP address"
  default     = "0.0.0.0"
}

variable "vm_name" {
  description = "VM name"
  default     = "default-vm"
}

variable "hst1_ip" {
  description = "Syslog Server IP for syslog host 1"
  default     = "1.2.3.4"
}

variable "hst1_severity" {
  description = "Severity[0-7] for syslog host 1"
  default     = "7"
}

variable "hst1_facility" {
  description = "facility[0-7] for syslog host 1"
  default     = "0"
}

variable "hst1_module" {
  description = "Module for syslog host 1"
  default     = "all"
}

variable "hst1_port" {
  description = "Port for syslog host 1"
  default     = "514"
}

variable "hst2_ip" {
  description = "Syslog Server IP for syslog host 2"
  default     = "0.0.0.0"
}

variable "hst2_severity" {
  description = "Severity for syslog host 2"
  default     = "7"
}

variable "hst2_facility" {
  description = "Facility for syslog host 2"
  default     = "0"
}

variable "hst2_module" {
  description = "Module for syslog host 2"
  default     = "all"
}

variable "hst2_port" {
  description = "Port for syslog host 2"
  default     = "514"
}


// helpers

variable "operation" {
  description = "Operation type: create or destroy"
  type        = string
  default     = "create"
}