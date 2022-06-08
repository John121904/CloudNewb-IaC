variable "prefix" {
  type    = string
  default = "cloudnewb"
}

#variable "resource_group_name" {
#  type = string
#}

variable "location" {
  type = string
}

variable "subscription_id" {
  type        = string
  description = "Enter Subscription ID for provisioning resources in Azure"
}

variable "client_id" {
  type        = string
  description = "Enter Client ID for Application created in Azure AD"
}

variable "client_secret" {
  type        = string
  description = "Enter Client Secret for Application in Azure AD"
}

variable "tenant_id" {
  type        = string
  description = "Enter Tenant ID of your Azure AD"
}