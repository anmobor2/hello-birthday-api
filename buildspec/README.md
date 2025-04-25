# AWS CodeBuild Buildspecs

This folder contains alternative CI/CD configurations designed for use with **AWS CodeBuild**.  
They provide a fully integrated AWS-native solution for those who prefer to use **CodePipeline + CodeBuild**, rather than GitHub Actions.

>  **Disclaimer**  
> These buildspec files are **not currently active** or triggered automatically.  
> They must be configured manually inside AWS CodeBuild projects, specifying the correct buildspec path (e.g., `buildspec/sonar-buildspec.yml`).  
> They serve as a ready-to-use alternative for teams deploying entirely within AWS infrastructure.

---

##  Files Overview

| File                      | Description                                                                 |
|---------------------------|-----------------------------------------------------------------------------|
| `build-buildspec.yml`     | Performs full security scans: Bandit (code), Safety (dependencies), Trivy (containers), ZAP (HTTP). |
| `test-buildspec.yml`      | Installs dependencies and runs Python unit tests via `pytest`.             |
| `sonar-buildspec.yml`     | Executes SonarCloud (or SonarQube) analysis after running tests with coverage. |
| `deploy-buildspec.yml`    | Updates ECS services: modifies task definitions and performs deployment.   |

---

## 🚀 How to Use These Files

To use any of these templates inside AWS:

1. Go to [AWS CodeBuild](https://console.aws.amazon.com/codesuite/codebuild/projects).
2. Create or edit a build project.
3. Set the **Source** as your repository (e.g., GitHub or CodeCommit).
4. Set the **Buildspec name/path** (for example):
   - `buildspec/build-buildspec.yml`
   - `buildspec/deploy-buildspec.yml`
5. Assign proper IAM roles with permissions for:
   - ECR
   - ECS
   - S3 (if applicable)
   - CodeBuild logging and artifacts

---

## Recommendation

This folder is provided as an optional, AWS-native CI/CD solution for teams that want:

- Tighter integration with AWS services
- To avoid GitHub Actions billing limits
- A fallback if GitHub Actions is unavailable or not preferred

You may continue using the default `.github/workflows/deploy.yml` pipeline for GitHub CI/CD unless a full migration to AWS-native tools is desired.

---

 Maintained by: **DevOps / Platform Engineering**