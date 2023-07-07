resource "aws_lambda_function" "_" {
  filename         = "./lambda/main.zip"
  function_name    = "poo-storm-comment-api"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "main"
  runtime          = "go1.x"
  source_code_hash = filebase64sha256("./lambda/main.zip")

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }

  environment {
    variables = {
      CLOUDFRONT_DISTRIBUTION_ID = "E3IT66EGD1FU89" # aws_cloudfront_distribution.distribution.id
    }
  }
}

resource "aws_lambda_function_url" "api" {
  function_name      = aws_lambda_function._.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_function" "rust" {
  filename         = "./rust/bootstrap.zip"
  function_name    = "poo-storm-comment-api-rust"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "rust.handler"
  runtime          = "provided.al2"
  source_code_hash = filebase64sha256("./rust/bootstrap.zip")

  lifecycle {
    ignore_changes = [filename, source_code_hash]
  }

  environment {
    variables = {
      # CLOUDFRONT_DISTRIBUTION_ID = aws_cloudfront_distribution.distribution["rust"].id
    }
  }
}

resource "aws_lambda_function_url" "rust_api" {
  function_name      = aws_lambda_function.rust.function_name
  authorization_type = "NONE"
}
