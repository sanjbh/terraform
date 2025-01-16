output "ec2_ip" {
  value = aws_instance.example.public_ip
}
