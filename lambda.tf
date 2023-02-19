resource "aws_lambda_function" "_" {
  filename         = "./lambda/main.zip"
  function_name    = "poo-storm-comment-api"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "main"
  runtime          = "go1.x"
  source_code_hash = filebase64sha256("./lambda/main.zip")

  lifecycle {
    ignore_changes = [source_code_hash]
  }
}

resource "aws_lambda_function_url" "api" {
  function_name      = aws_lambda_function._.function_name
  authorization_type = "NONE"
}
