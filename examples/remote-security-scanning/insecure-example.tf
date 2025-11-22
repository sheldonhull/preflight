# Example of insecure Terraform configuration
# This will trigger Checkov security warnings

# CKV_AWS_20: S3 Bucket has public access
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "my-public-bucket"
  acl    = "public-read"  # ❌ Public access enabled
}

# CKV_AWS_18: S3 bucket without logging
# CKV_AWS_21: S3 bucket without encryption
resource "aws_s3_bucket" "unencrypted_bucket" {
  bucket = "my-unencrypted-bucket"  # ❌ No encryption configured

  versioning {
    enabled = false  # ❌ Versioning disabled
  }
}

# CKV_AWS_8: EC2 instance with unencrypted EBS
# CKV_AWS_79: EC2 instance with IMDSv1 enabled
resource "aws_instance" "insecure_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  root_block_device {
    encrypted = false  # ❌ Unencrypted root volume
  }

  metadata_options {
    http_tokens = "optional"  # ❌ IMDSv1 allowed (security risk)
  }

  monitoring = false  # ❌ Monitoring disabled
}

# CKV_AWS_260: Security group allows SSH from anywhere
# CKV_AWS_24: Security group allows RDP from anywhere
resource "aws_security_group" "insecure_sg" {
  name        = "insecure-sg"
  description = "Insecure security group for testing"

  # ❌ SSH open to the world
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from anywhere"
  }

  # ❌ RDP open to the world
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "RDP from anywhere"
  }

  # ❌ All traffic allowed outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# CKV_AWS_19: Security group without description
resource "aws_security_group_rule" "no_description" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.insecure_sg.id
  # ❌ No description provided
}
