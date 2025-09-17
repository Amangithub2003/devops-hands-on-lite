provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "devops_server" {
  ami           = "ami-0360c520857e3138f" # Ubuntu 22.04 in us-east-1
  instance_type = "t2.micro"
  key_name      = "my-key"

  tags = {
    Name = "devops-lite-server"
  }
}

