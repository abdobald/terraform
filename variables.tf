variable "ACCESS_KEY_08" {}

variable "SECRET_KEY_08" {}

variable "cidr_block" {}

variable "aba_key" {
  description = "Path to the SSH Public Key to add to AWS."
  default     = "~/.ssh/id_rsa.pub"
}
