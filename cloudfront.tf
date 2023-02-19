locals {
  origin_id = "LambdaOrigin"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = replace(replace(aws_lambda_function_url.api.function_url, "https://", ""), "/\\/$/", "")
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  http_version        = "http2and3"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "https-only"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # cache optimized
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2019"
  }
}
