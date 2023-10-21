resource "aws_instance" "ubuntu" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg_jenkins.id]
  tags = {
    Name = "jenkins_instance"
  }

  #User Data in AWS EC2
  user_data = file("script.sh")
}

#Create security group 
resource "aws_security_group" "sg_jenkins" {
  name        = "sg_jenkins"
  description = "Open ports 22/8080/443"
  vpc_id      = var.vpc_id

  #Allow incoming TCP requests on port 22 from any IP
  ingress {
    description = "Incoming SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow incoming TCP requests on port 8080 from any IP
  ingress {
    description = "Incoming 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow incoming TCP requests on port 443 from any IP
  ingress {
    description = "Incoming 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_jenkins"
  }
}

#Create S3 bucket for Jenkins artifacts; PRIVATE BY DEFAULT
resource "aws_s3_bucket" "jenkins-artifacts-bucket" {
  bucket = "jenkins-artifacts-${random_id.randomness.hex}"

  tags = {
    Name = "jenkins_artifacts"
  }
}

#Create random number for S3 bucket name
resource "random_id" "randomness" {
  byte_length = 8
}
