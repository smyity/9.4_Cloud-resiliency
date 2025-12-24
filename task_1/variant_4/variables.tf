variable "flow" {
  type    = string
  default = "9-4"
}

variable "cloud_id" {
  type    = string
  default = "b1gc3k00qi2fi08ed282"
}
variable "folder_id" {
  type    = string
  default = "b1gbhs59559ntu7hvlcn"
}

variable "vm_name" {
  type    = list(string)
  default = ["primary", "secondary"]
}

variable "ssh_port" {
  type    = string
  default = "32545"
}

variable "vm_user" {
  type    = string
  default = "osho"
}
