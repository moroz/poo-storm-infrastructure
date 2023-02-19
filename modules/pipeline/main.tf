locals {
  pipeline_name          = "${var.base_name}-codepipeline"
  app_name               = "${var.base_name}-app"
  artifact_bucket_name   = "${local.pipeline_name}-artifacts"
  codepipeline_role_name = "${local.pipeline_name}-service-role"
  codebuild_project_name = "${var.base_name}-build"
  codebuild_role_name    = "${local.codebuild_project_name}-service-role"
}

resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket        = local.artifact_bucket_name
  force_destroy = true
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = local.codebuild_project_name
  service_role  = aws_iam_role.codebuild_role.arn
  badge_enabled = false

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.codebuild_image
    privileged_mode             = true
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    dynamic "environment_variable" {
      for_each = var.additional_build_env_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = var.buildspec
    git_clone_depth = 0
  }
}

resource "aws_codepipeline" "cd_pipeline" {
  name     = local.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.pipeline_artifacts.bucket
  }

  stage {
    name = "Source"

    action {
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeCommit"
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact"
      ]
      run_order = 1
      version   = "1"

      configuration = {
        "RepositoryName"       = var.git_repo_name
        "BranchName"           = var.git_branch
        "PollForSourceChanges" = true
      }
    }
  }

  stage {
    name = "Build"

    action {
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      configuration = {
        "ProjectName" = aws_codebuild_project.codebuild_project.name
      }
      input_artifacts = [
        "SourceArtifact"
      ]
      output_artifacts = [
        "BuildArtifact"
      ]
      name      = "Build"
      run_order = 1
      version   = "1"
    }
  }
}

