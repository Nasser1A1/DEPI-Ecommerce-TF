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


##############################################
# IAM Role for ECR Access
##############################################
resource "aws_iam_role" "k3s_ecr_role" {
  name = "k3s-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

##############################################
# Attach AmazonEC2ContainerRegistryFullAccess
##############################################
resource "aws_iam_role_policy_attachment" "k3s_ecr_policy" {
  role       = aws_iam_role.k3s_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

##############################################
# Create Instance Profile
##############################################
resource "aws_iam_instance_profile" "k3s_ecr_instance_profile" {
  name = "k3s-ecr-instance-profile"
  role = aws_iam_role.k3s_ecr_role.name
}

###############################################
# Create EC2 Instance (K3S compatible)
###############################################
resource "aws_instance" "Dev-Server" {
  ami           = data.aws_ami.ubuntu_2204.id
  instance_type = "c7i-flex.large"

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  key_name = "Dev-Keypair"

  iam_instance_profile = aws_iam_instance_profile.k3s_ecr_instance_profile.name

  # Install Docker / Containerd / k3s bootstrap
  user_data = file("scripts/user_data.sh")

  tags = {
    Name = "Dev-Server-k3s"
  }
}


