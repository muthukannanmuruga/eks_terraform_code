resource "aws_instance" "bastion" {
  ami                    = "ami-0d682f26195e9ec0f"  # Use an appropriate Amazon Linux AMI
  instance_type          = "t2.micro"
  key_name               = "mk_technologies_key"
  subnet_id = aws_subnet.public_subnet[0].id
  associate_public_ip_address = true
  vpc_security_group_ids        = [aws_security_group.bastion_sg.id]
  tags = { Name = "Bastion Host" }
  depends_on = [aws_security_group.bastion_sg]
  
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for Bastion Host"
  vpc_id      = aws_vpc.eks_vpc.id  # Replace with your VPC ID

  # Allow SSH from your public IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP
  }

  # Allow outbound traffic (so the bastion can reach private instances)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion SG"
  }
}
