resource "aws_codecommit_repository" "lambda_repo" {
  repository_name = "${var.project_name}-lambda"
}

module "pipeline" {
  source = "./modules/pipeline"

  base_name                   = var.project_name
  git_repo_name               = aws_codecommit_repository.lambda_repo.repository_name
  aws_region                  = var.aws_region
  cloudfront_distribution_arn = aws_cloudfront_distribution.distribution.arn

  additional_build_env_vars = {
    CLOUDFRONT_DISTRIBUTION_ID = aws_cloudfront_distribution.distribution.id
    LAMBDA_FUNCTION_NAME       = aws_lambda_function._.function_name
  }
}
