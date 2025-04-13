# Development environment specific variables
aws_region = "eu-west-1"
project_name = "hello-api"
vpc_cidr = "10.0.0.0/16"
domain_name = "hello-api.io"
route53_zone_id = "Z3HELLOAPI5XAMPLE"
ecr_repository_url = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/hello-api"

common_tags = {
  Project     = "hello-api"
  ManagedBy   = "terraform"
  Owner       = "development-team"
  CostCenter  = "dev-12345"
}
