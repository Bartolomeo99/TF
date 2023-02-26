variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "public_key" {
  default = "<awskeyname_of_key>.pub"
}
