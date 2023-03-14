provider "aws" {
  region = "eu-west-2"
}

locals {
  wg_server = {
    ami      = "ami-0aaa5410833273cfe"
    ssh_user = "ubuntu"
    port     = "51820"
  }
}

variable "private_key_file" {
  type        = string
  description = "Private key to use to ssh into wg_server"
  default     = "~/.ssh/id_ed25519"
}

data "tls_public_key" "wg_server_pubkey" {
  private_key_openssh = file(var.private_key_file)
}

resource "aws_key_pair" "wg_server_key" {
  key_name   = "wg_server_ec2"
  public_key = data.tls_public_key.wg_server_pubkey.public_key_openssh
}

resource "aws_instance" "wg_server" {
  # https://eu-west-2.console.aws.amazon.com/ec2/home?region=eu-west-2#ImageDetails:imageId=ami-0aaa5410833273cfe
  # ubuntu 22.04
  ami = local.wg_server.ami

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

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install wireguard-tools mawk grep iproute2 qrencode",
      "wget https://raw.githubusercontent.com/burghardt/easy-wg-quick/master/easy-wg-quick",
      "chmod +x easy-wg-quick",
      "mkdir -p wg-server",
    ]

    connection {
      type        = "ssh"
      host        = aws_instance.wg_server.public_ip
      user        = local.wg_server.ssh_user
      private_key = file(var.private_key_file)
    }
  }
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
    from_port   = local.wg_server.port
    protocol    = "udp"
    self        = "false"
    to_port     = local.wg_server.port
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

output "wg_server_host" {
  value       = aws_instance.wg_server.public_ip
  description = "Hostname (ip) of the wireguard server"
}

output "wg_server_user" {
  value       = local.wg_server.ssh_user
  description = "SSH user to connect to the wireguard server"
}

output "wg_server_port" {
  value       = local.wg_server.port
  description = "Port at which wireguard server is listening"
}
