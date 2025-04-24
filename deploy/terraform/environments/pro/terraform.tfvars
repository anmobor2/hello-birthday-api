# Production environment specific variables
aws_region = "eu-west-1"
project_name = "hello-api"
vpc_cidr = "10.1.0.0/16"
domain_name = "hello-api.io"
route53_zone_id = "Z3HELLOAPI5XAMPLE"
ecr_repository_url = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/hello-api"

# Production specific scaling
min_capacity = 2
max_capacity = 6
desired_count = 2

# Production specific resources
container_cpu = 512
container_memory = 1024

# Enhanced security for production
enable_waf = true
enable_https = true
ssl_certificate_arn = "arn:aws:acm:eu-west-1:123456789012:certificate/example-cert"

# Monitoring
alarm_email = "production-team@example.com"
enable_enhanced_monitoring = true

common_tags = {
  Project     = "hello-api"
  ManagedBy   = "terraform"
  Owner       = "production-team"
  CostCenter  = "prod-67890"
  DataClassification = "internal"
}
