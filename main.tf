provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon-linux.id
  instance_type = var.instance_type

}
