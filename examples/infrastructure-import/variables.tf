variable "aws_region" {
  description = "AWS region for resource import"
  type        = string
  default     = "us-west-2"
}

variable "gcp_project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "github_owner" {
  description = "GitHub organization or user name"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}
