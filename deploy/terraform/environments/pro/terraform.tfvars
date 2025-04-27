aws_region = "eu-west-1"
project_name = "hello-api"
environment = "pro"

vpc_cidr = "10.1.0.0/16"
private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
enable_nat_gateway = true
single_nat_gateway = false

ecr_repository_url = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/hello-api"
container_image_tag = "pro-latest"
container_port = 8000
container_cpu = 512
container_memory = 1024
desired_count = 2

enable_autoscaling = true
min_capacity = 2
max_capacity = 6
cpu_scaling_target = 70

health_check_path = "/health"
alb_internal = false
enable_deletion_protection = true
enable_https = true
ssl_certificate_arn = "arn:aws:acm:eu-west-1:123456789012:certificate/example-cert"

domain_name = "hello-api.io"
route53_zone_id = "Z3HELLOAPI5XAMPLE"
create_dns_record = true

cpu_alarm_threshold = 70
memory_alarm_threshold = 70
error_alarm_threshold = 2
create_alarm_topic = true
alarm_email = "production-team@example.com"
enable_enhanced_monitoring = true

enable_secretsmanager = true
grafana_admin_user_arns = []
waf_web_acl_arn = "arn:aws:wafv2:eu-west-1:123456789012:global/webacl/example"

common_tags = {
  Project     = "hello-api"
  ManagedBy   = "terraform"
  Owner       = "production-team"
  CostCenter  = "prod-67890"
  DataClassification = "internal"
}

enable_cicd = true
github_repository = "tu-usuario/hello-api"

