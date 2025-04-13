# Multi-Environment Setup with Terraform

This document explains the architecture and workflow for managing multiple environments (dev, pre, pro) using Terraform.

## Project Structure

```
terraform/
├── modules/                   # Reusable modules
│   ├── networking/            # Network infrastructure
│   ├── ecs/                   # ECS services and tasks
│   ├── loadbalancer/          # Load balancer configuration
│   └── monitoring/            # Monitoring and alerting
├── environments/              # Environment-specific configurations
│   ├── dev/                   # Development environment
│   ├── pre/                   # Pre-production environment
│   └── pro/                   # Production environment
└── global/                    # Shared resources (ECR, KMS, etc.)
```

## Core Concepts

### 1. Module Reusability

All infrastructure components are defined as reusable modules. Each module:
- Has its own inputs (variables.tf)
- Has its own outputs (outputs.tf)
- Can be configured differently for each environment

### 2. Environment Isolation

Each environment:
- Has its own directory with configuration
- Has its own state file in S3
- Can be managed independently
- Uses environment-specific variables via terraform.tfvars

### 3. Global Resources

Shared resources like ECR repositories are defined once in the global directory and used by all environments.

## Workflow

### Initial Setup

1. First, deploy the global resources:
   ```bash
   cd terraform/global
   terraform init
   terraform apply
   ```

2. This creates shared infrastructure including:
   - ECR repository for Docker images
   - S3 bucket for terraform state
   - DynamoDB table for state locking
   - KMS keys for encryption

### Setting Up an Environment

To set up a specific environment (e.g., dev):

1. Navigate to the environment directory:
   ```bash
   cd terraform/environments/dev
   ```

2. Initialize Terraform with the proper backend:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the changes:
   ```bash
   terraform apply
   ```

### Making Changes

When making changes:

1. For environment-specific changes, modify files in the specific environment directory
2. For changes that affect all environments, modify the modules
3. To update a single environment after module changes:
   ```bash
   cd terraform/environments/dev
   terraform plan
   terraform apply
   ```

### CI/CD Integration

This structure works well with CI/CD pipelines:

1. **Dev Environment**: Automatic deployment on merge to development branch
2. **Pre Environment**: Automatic deployment on merge to staging branch
3. **Production Environment**: Manual approval required after successful pre-deployment

## Best Practices

1. **Version Control**: Keep all Terraform code in version control
2. **Code Reviews**: Require code reviews for changes
3. **State Management**: Never modify the Terraform state manually
4. **Variable Consistency**: Keep variable names consistent between environments
5. **Documentation**: Document all module inputs and outputs
6. **Secrets Management**: Use KMS for encrypting sensitive data

## Environment-Specific Considerations

### Development (dev)
- Less redundancy (single NAT gateway)
- Smaller instance sizes
- More lenient security groups for testing
- Debug-level logging

### Pre-production (pre)
- Mirror of production environment
- Used for final testing before production release
- Isolated from production data

### Production (pro)
- High availability (multiple NAT gateways)
- Redundancy across availability zones
- Strict security settings
- Production-ready resources
- Enhanced monitoring and alerting
