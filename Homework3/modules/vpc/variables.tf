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