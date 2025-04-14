# Local Testing with LocalStack

This document explains how to test the Terraform configuration locally using LocalStack, which emulates AWS services on your local machine.

## Overview

LocalStack provides local emulation of AWS services, allowing developers to:
- Test infrastructure changes without incurring AWS costs
- Validate configurations without internet connectivity
- Speed up development and testing cycles
- Avoid accidental modifications to production infrastructure

## Setup Instructions

### 1. Install LocalStack

```bash
# Using Homebrew (macOS)
brew install localstack

# Using pip (any platform)
pip install localstack
```

### 2. Start LocalStack

```bash
# Start LocalStack in the background
localstack start
```

You should see output indicating that various AWS services are starting up locally.

### 3. Configure Terraform Provider

The `providers.tf` file is already configured to detect a local environment and use LocalStack endpoints. No changes are needed if you're using this repository's version.

### 4. Run Terraform Commands

```bash
# Initialize Terraform
terraform init

# Plan the infrastructure (using LocalStack)
terraform plan
```

## Switching Between LocalStack and Real AWS

The repository is configured to make switching between LocalStack and real AWS simple:

### To use LocalStack (local testing)

1. Ensure LocalStack is running locally
2. Uncomment the LocalStack provider in `providers.tf`
3. Comment out the regular AWS provider

### To use real AWS (actual deployment)

1. Comment out the LocalStack provider in `providers.tf`
2. Uncomment the regular AWS provider
3. Ensure proper AWS credentials are configured in your environment

## Limitations

When testing with LocalStack, be aware of these limitations:

1. **Service Support**: Not all AWS services or features are fully implemented in LocalStack
2. **Local State**: Terraform state is local and not synchronized with any remote state
3. **Resource Matching**: Some resource configurations may work differently between LocalStack and real AWS

## Best Practices for Local Testing

1. **Consistent Testing**: Use the same input variables for local testing as you would for actual deployments
2. **Test Data**: Use realistic but non-sensitive data for testing
3. **Isolated Testing**: Test one module at a time when troubleshooting specific components
4. **Version Control**: Don't commit the LocalStack configuration to your primary branches

## Troubleshooting

If you encounter issues with LocalStack:

1. Check LocalStack logs: `docker logs localstack`
2. Verify LocalStack services are running: `localstack status services`
3. Ensure you're using supported LocalStack features: [LocalStack AWS Feature Coverage](https://docs.localstack.cloud/aws/feature-coverage/)
