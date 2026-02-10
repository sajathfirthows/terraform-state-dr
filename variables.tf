variable "region" {
  description = "AWS region where resources are created"
  type        = string
  default     = "us-east-1"
}

variable "terraform_state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
}

variable "environment" {
  description = "Environment name for governance and tagging"
  type        = string
  default     = "shared"
}

variable "owner" {
  description = "Team or owner responsible for this backend"
  type        = string
  default     = "platform-team"
}

variable "noncurrent_version_retention_days" {
  description = "Retention period for non-current state versions"
  type        = number
  default     = 30
}

variable "replica_region" {
  description = "AWS region for the disaster recovery backup bucket"
  type        = string
  default     = "us-west-2"
}
