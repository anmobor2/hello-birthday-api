# Hello API
A simple API that stores and retrieves users' birthdays.

## Project Description
This project implements a REST API with the following endpoints:

- **PUT /hello/<username>**: Saves or updates a user's date of birth.
- **GET /hello/<username>**: Returns a birthday message for the user.

## Requirements

- Python 3.8+
- FastAPI
- SQLite (for development) / PostgreSQL (for production)

## Project Structure
The application follows a clear layered architecture, separating business logic (services), database logic (models), and the API (HTTP controllers).

- **`app/`**: Contains the main application code
  - **`main.py`**: Entry point of the application
  - **`config.py`**: Application configuration
  - **`database.py`**: Database configuration
  - **`models/`**: Data models and validation schemas
  - **`services/`**: Business logic services
  - **`api/`**: HTTP routes and controllers

- **`tests/`**: Automated tests
- **`docker/`**: Docker configuration
- **`deploy/`**: CI/CD and deployment scripts and configurations

## Features

- Input validation (username with letters only, date of birth in the past)
- Unit and integration tests
- Configuration for different environments (development, testing, production)
- Docker for containerization
- Infrastructure as code with Terraform for AWS
- Zero-downtime deployment

## Local Development
### Environment Setup

Clone the repository:

# Project Setup and Deployment Guide

#### 1. Clone the repository
```
git clone https://github.com/yourusername/hello-api.git
cd hello-api
```
#### 2. Create a virtual environment and install dependencies
```
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install -r requirements-dev.txt # For development
```
#### 3. Run the application
```
uvicorn app.main:app --reload
```

#### 4. Access API documentation
```
    Swagger UI: http://localhost:8000/docs

    ReDoc: http://localhost:8000/redoc
```
Run Tests
```
pytest
```
### Docker Usage
#### Build and Run with Docker Compose
```
cd docker
docker-compose up --build
```

### AWS Deployment
#### Requirements

   - AWS account with configured AWS CLI
   - Terraform installed

#### Terraform Infrastructure Deployment

1. Move to the Terraform directory:
```
cd deploy/terraform
```

2. Initialize Terraform:
```
terraform init
```
3. Choose the environment (dev, pre, or pro) and apply the configuration using the corresponding variables file.

For example, for development:
```
cd deploy/terraform/environments/dev
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```
O
```
terraform -chdir=deploy/terraform/environments/dev init
terraform -chdir=deploy/terraform/environments/dev plan -var-file=terraform.tfvars
terraform -chdir=deploy/terraform/environments/dev apply -var-file=terraform.tfvars
```

For production:
```
cd deploy/terraform/environments/pro
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```
O
```
terraform -chdir=deploy/terraform/environments/pro init
terraform -chdir=deploy/terraform/environments/pro plan -var-file=terraform.tfvars
terraform -chdir=deploy/terraform/environments/pro apply -var-file=terraform.tfvars
```

4. Build and deploy the application Docker images:

```
cd ../../
deploy/scripts/build.sh
deploy/scripts/deploy.sh
```

#### Terraform Structure and Behavior

  - Modular Architecture:
  Infrastructure is composed of reusable modules (networking, ecs, loadbalancer, iam, monitoring, etc.).

  - Environment-specific Configuration:
  Each environment (dev, pre, pro) has its own variables file under deploy/terraform/environments/.

  - Dynamic Features:

      WAF (Web Application Firewall) is optionally attached to the Load Balancer if a waf_web_acl_arn is provided.

      CI/CD pipelines are optionally created via AWS CodePipeline and CodeBuild if enable_cicd is set to true.

  - State Management:
  Remote state is stored securely in an S3 bucket with locking via DynamoDB.


### AWS Architecture

The system is deployed on AWS using the following services:

   - Amazon ECS (Fargate): For running application containers without managing servers

   - Application Load Balancer: For traffic distribution between application instances

   - Amazon RDS/Aurora: For production database

   - Amazon ECR: For Docker image storage

   - AWS WAF (optional): To protect against common web attacks

   - CloudWatch: For monitoring, alarms and logging

   - Route 53: For DNS management

For complete details, see the architecture diagram in the documentation.

### SRE Considerations

   - Scalability: The application can scale horizontally by adding more ECS tasks.

   - Availability: Runs in multiple availability zones with a load balancer.

   - Monitoring and Alerting: CPU, memory, and application-level metrics with alarms.

   - Zero-downtime deployment: Uses blue/green deployment strategy in ECS.

   - Security: VPC isolation, security groups, HTTPS endpoints, optional WAF protection.

   - Resilient Deployments: Terraform enables full reproducibility of infrastructure.

Design Decisions

   - Python/FastAPI: Chosen for simplicity, performance, and development ease.

   - Separate date service: Birthday calculation logic is in a separate service for easier testing and extensibility.

   - SQLAlchemy: Provides abstraction layer for different database types.

   - SQLite for development: Simplifies local testing without additional setup.

   - AWS Fargate: Simplifies operations by eliminating server management.

   - Infrastructure as Code: All infrastructure defined with Terraform for easy replication and version control.


## AWS Buildspec Templates

Note: The `buildspec/` folder contains AWS CodeBuild buildspec templates.  
These are not currently active but can be used to configure AWS-native CI/CD pipelines if needed.

