variable "namespace" {
  description = "Default namespace"
  default = "khanh"
}

variable "instance_type" {
  description = "Instance type"  
}
#ssh ubuntu@ip
variable "public_key_path" {
  description = "Path to public key for ssh access"
}

variable "vpc_id" {
  description = "VPC id"  
}

variable subnet_ids {
  type        = list(string)
  description = "subnet ids"  
}
