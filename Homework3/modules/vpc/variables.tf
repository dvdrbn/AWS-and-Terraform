variable "name" {
  description = "Name for vpc enviroment"
  type        = string
}

variable "cidr_block" {
  description = "cidr block"
  type        = string
}

variable "tags" {
  description = "Tags to add to all resources"
  type        = map(string)
}

variable "azs" {
  description = "Availability zones for subnet deployment"
  type        = list(string)
}

variable "cidr_public" {
  description = "cidrs for public subnets"
  type        = list(string)
}

variable "cidr_private" {
  description = "cidrs for private subnets"
  type        = list(string)
}