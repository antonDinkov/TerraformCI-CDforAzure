variable "resource_group_name" {
  type        = string
  description = "Resource group name in Azure"
}
variable "resource_group_location" {
  type        = string
  description = "Resource group location in Azure"
}
variable "app_service_plan_name" {
  type        = string
  description = "App service plan name"
}
variable "app_service_name" {
  type        = string
  description = "app name"
}
variable "sql_server_name" {
  type        = string
  description = "server name"
}
variable "sql_database_name" {
  type        = string
  description = "database name"
}
variable "sql_admin_login" {
  type        = string
  description = "sql login username"
}
variable "sql_admin_password" {
  type        = string
  description = "sql login password"
}
variable "firewall_rule_name" {
  type        = string
  description = "firewall name"
}
variable "repo_url" {
  type        = string
  description = "repository url"
}