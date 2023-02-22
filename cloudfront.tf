locals {
  origin_id = "LambdaOrigin"
}

resource "aws_cloudfront_response_headers_policy" "cors" {
  name = "cors-response-policy"

  cors_config {
    access_control_allow_credentials = true

    access_control_allow_headers {
      items = ["Access-Control-Request-Headers", "Origin", "Access-Control-Request-Methods"]
    }

    access_control_allow_methods {
      items = ["GET", "HEAD", "OPTIONS", "POST"]
    }

    access_control_allow_origins {
      items = ["https://moroz.dev", "http://localhost:3000"]
    }

    origin_override = true
  }
}

resource "aws_cloudfront_cache_policy" "cached_with_qs" {
  name        = "cache-with-query-string"
  default_ttl = 86400
  max_ttl     = 315360000
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings {
        items = ["url"]
      }
    }
  }
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = replace(replace(aws_lambda_function_url.api.function_url, "https://", ""), "/\\/$/", "")
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  http_version        = "http2and3"

  default_cache_behavior {
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "https-only"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    compress               = true

    response_headers_policy_id = aws_cloudfront_response_headers_policy.cors.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }
}
