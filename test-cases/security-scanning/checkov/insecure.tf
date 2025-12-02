# Test case for Checkov - intentionally insecure Terraform configuration
# This file should trigger multiple Checkov security checks

# CKV_AWS_20: S3 Bucket has an ACL defined which allows public access
resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "my-insecure-test-bucket"
  acl    = "public-read"
}

# CKV_AWS_18: Ensure the S3 bucket has access logging enabled
# CKV_AWS_21: Ensure all data stored in the S3 bucket is securely encrypted at rest
resource "aws_s3_bucket" "unencrypted_bucket" {
  bucket = "my-unencrypted-bucket"

  versioning {
    enabled = false
  }
}

# CKV_AWS_8: Ensure all data stored in the Launch configuration EBS is securely encrypted
resource "aws_instance" "unencrypted_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  root_block_device {
    encrypted = false
  }

  # CKV_AWS_79: Ensure Instance Metadata Service Version 1 is not enabled
  metadata_options {
    http_tokens = "optional"
  }
}

# CKV_AWS_260: Ensure no security groups allow ingress from 0.0.0.0:0 to port 22
resource "aws_security_group" "insecure_sg" {
  name        = "insecure-sg"
  description = "Intentionally insecure security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
