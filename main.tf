provider "aws" {
  region = "eu-west-2"
}

variable "public_key_file" {
  type        = string
  description = "Public key to use to ssh into wg_server"
  default     = "~/.ssh/id_ed25519.pub"
}

resource "aws_instance" "wg_server" {
  # https://eu-west-2.console.aws.amazon.com/ec2/home?region=eu-west-2#ImageDetails:imageId=ami-0aaa5410833273cfe
  # ubuntu 22.04
  ami = "ami-0aaa5410833273cfe"

  associate_public_ip_address = "true"
  instance_type               = "t2.micro"

  credit_specification {
    cpu_credits = "standard"
  }

  key_name = aws_key_pair.wg_server_key.key_name

  root_block_device {
    volume_size = "8"
    volume_type = "gp2"
  }

  vpc_security_group_ids = [aws_security_group.sg_for_wg_server.id]

  tags = {
    Name = "wg-server"
  }
}

resource "aws_key_pair" "wg_server_key" {
  key_name   = "wg_server_ec2"
  public_key = file(var.public_key_file)
}

resource "aws_security_group" "sg_for_wg_server" {
  name = "security_group_for_wg_server"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = "0"
    protocol    = "-1"
    self        = "false"
    to_port     = "0"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "wireguard"
    from_port   = "51820"
    protocol    = "udp"
    self        = "false"
    to_port     = "51820"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh"
    from_port   = "22"
    protocol    = "tcp"
    self        = "false"
    to_port     = "22"
  }
}

output "public_ip" {
  value       = aws_instance.wg_server.public_ip
  description = "The public IP address of the wireguard server"
}
