# Deploy Scripts

This folder contains helper shell scripts for building, testing, and deploying the **Hello Birthday API** project.

Currently, these scripts are intended for **manual execution** or **future automation pipelines**.  
They are **not automatically invoked** by the GitHub Actions workflows or AWS CodeBuild pipelines at this time.

## Scripts Overview

| Script              | Purpose                                                                         |
|---------------------|---------------------------------------------------------------------------------|
| `build.sh`           | Build the application package or Docker image locally.                        |
| `test.sh`            | Run local tests (unit tests, coverage reports).                               |
| `deploy.sh`          | Manually deploy the application to the designated environment (if needed).    |
| `deploy_docker.sh`   | Build and push Docker images manually to the Docker registry or ECR.           |

## Important Notes

- These scripts assume they are executed from the project root:
  ```bash
  ./deploy/scripts/build.sh
  ./deploy/scripts/test.sh
  ./deploy/scripts/deploy.sh
  ./deploy/scripts/deploy_docker.sh
  
### Disclaimer:
This folder is intended for maintainers, DevOps engineers, and developers familiar with the deployment process. Use with care.