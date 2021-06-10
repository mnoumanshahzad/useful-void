provider "aws" {
    region = "eu-central-1"
}

variable "bucket_name" {}

resource "aws_s3_bucket" "tf_state" {
    bucket = var.bucket_name
    force_destroy = true
    
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
    
    versioning {
      enabled = true
    }
}

resource "aws_ssm_parameter" "just_a_parameter" {
    name = var.bucket_name
    type = "String"
    value = "just_a_value"  
}