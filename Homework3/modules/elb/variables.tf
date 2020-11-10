variable "name" {
  description = "Name for enviroment"
  type        = string
}

variable "instances" {
  description = "List of instances to balance"
  type        = list(string)
}

variable "subnets" {
  description = "List of subnets for deployment"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group ids"
  type        = list(string)
}

variable "tags" {
  description = "Tags to add to all resources"
  type        = map(string)
}