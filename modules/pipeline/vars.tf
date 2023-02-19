variable "base_name" {}

variable "git_repo_name" {}

variable "codebuild_image" {
  type    = string
  default = "aws/codebuild/standard:6.0"
}

variable "custom_image" {
  type    = bool
  default = false
}

variable "git_branch" {
  type    = string
  default = "production"
}

variable "aws_region" {
  type = string
}

variable "additional_build_env_vars" {
  type    = map(any)
  default = {}
}

variable "enable_deploy" {
  type    = bool
  default = true
}

variable "buildspec" {
  type    = string
  default = "buildspec.yml"
}

variable "cloudfront_distribution_arn" {
  type = string
}
