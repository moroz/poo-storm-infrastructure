resource "aws_iam_role" "codepipeline_role" {
  name = local.codepipeline_role_name

  assume_role_policy = templatefile("./policies/codepipeline_assume_policy.tpl", {})
}

resource "aws_iam_role_policy" "codepipeline_role" {
  name = "${local.codepipeline_role_name}-policy"

  role = aws_iam_role.codepipeline_role.id

  policy = templatefile("./policies/codepipeline_policy.tpl", {})
}

resource "aws_iam_role_policy" "codebuild_role" {
  role = aws_iam_role.codebuild_role.name

  policy = templatefile("./policies/build_role_policy.tpl", {
    s3_bucket                   = aws_s3_bucket.pipeline_artifacts.arn
    aws_region                  = var.aws_region
    cloudfront_distribution_arn = var.cloudfront_distribution_arn
  })
}

resource "aws_iam_role" "codebuild_role" {
  name = local.codebuild_role_name

  assume_role_policy = templatefile("./policies/build_role_assume_policy.tpl", {})
}
