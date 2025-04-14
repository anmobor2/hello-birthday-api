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

#### Deployment Steps

1. Configure Terraform variables:
```
cd deploy/terraform
cp terraform.tfvars.example terraform.tfvars
```

2. Initialize Terraform:
```
terraform init
```
3. Apply the configuration:
```
terraform apply
```
4. Build and deploy the application:
```
cd ../../
deploy/scripts/build.sh
deploy/scripts/deploy.sh
```

### AWS Architecture

The system is deployed on AWS using the following services:

   - Amazon ECS (Fargate): For running application containers without managing servers

   - Application Load Balancer: For traffic distribution between application instances

   - Amazon RDS/Aurora: For production database

   - Amazon ECR: For Docker image storage

   - CloudWatch: For monitoring and logging

   - Route 53: For DNS management

For complete details, see the architecture diagram in the documentation.

### SRE Considerations

   - Scalability: The application can scale horizontally by adding more ECS tasks.

   - Availability: Runs in multiple availability zones with a load balancer.

   - Monitoring: CloudWatch metrics and alarms for CPU and memory.

   - Zero-downtime deployment: Uses blue/green deployment strategy in ECS.

   - Security: Implemented in a VPC with public/private subnets and proper security groups.

Design Decisions

   - Python/FastAPI: Chosen for simplicity, performance, and development ease.

   - Separate date service: Birthday calculation logic is in a separate service for easier testing and extensibility.

   - SQLAlchemy: Provides abstraction layer for different database types.

   - SQLite for development: Simplifies local testing without additional setup.

   - AWS Fargate: Simplifies operations by eliminating server management.

   - Infrastructure as Code: All infrastructure defined with Terraform for easy replication and version control.
## Pipeline Test
