aws_region = "eu-west-1"
project_name = "hello-api"
environment = "pre"

vpc_cidr = "10.2.0.0/16"
private_subnet_cidrs = ["10.2.1.0/24", "10.2.2.0/24"]
public_subnet_cidrs  = ["10.2.101.0/24", "10.2.102.0/24"]
enable_nat_gateway = true
single_nat_gateway = true

ecr_repository_url = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/hello-api"
container_image_tag = "pre-latest"
container_port = 8000
container_cpu = 256
container_memory = 512
desired_count = 1

enable_autoscaling = true
min_capacity = 1
max_capacity = 3
cpu_scaling_target = 70

health_check_path = "/health"
alb_internal = false
enable_deletion_protection = false
enable_https = true
ssl_certificate_arn = "arn:aws:acm:eu-west-1:123456789012:certificate/example-pre"

domain_name = "hello-api.io"
route53_zone_id = "Z3HELLOAPI5XAMPLE"
create_dns_record = true

cpu_alarm_threshold = 75
memory_alarm_threshold = 75
error_alarm_threshold = 3
create_alarm_topic = true
alarm_email = "preprod-team@hello-api.com"
enable_enhanced_monitoring = true

enable_secretsmanager = true
grafana_admin_user_arns = []
waf_web_acl_arn = ""

common_tags = {
  Project     = "hello-api"
  ManagedBy   = "terraform"
  Owner       = "preprod-team"
  CostCenter  = "pre-45678"
}