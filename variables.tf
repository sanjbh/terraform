variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "server_port" {
  type        = number
  description = "The port the server will use for HTTP requests"
}

