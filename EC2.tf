##############################################
# Get Amazon Linux 2 Free Tier AMI
##############################################
data "aws_ami" "ubuntu_2204" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical official Ubuntu owner ID
}

##############################################
# Security Group - allow HTTP + SSH
##############################################
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

###############################################
# Create EC2 Instance (K3S compatible)
###############################################
resource "aws_instance" "Dev-Server" {
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = "t3.medium" 

  # Optional: Create a keypair for SSH
  key_name = "Dev-Keypair"

  # Install Docker automatically
  user_data = file("scripts/user_data.sh")

  tags = {
    Name = "Dev-Server-k3s"
  }
}

