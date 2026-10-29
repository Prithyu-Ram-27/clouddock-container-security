# CloudDock: Build, Security Scan, and Deploy

## Overview

CloudDock is a containerized application deployment project that demonstrates **Continuous Integration and Continuous Deployment (CI/CD)** with automated container security scanning and cloud deployment.

The project uses GitHub Actions to build Docker images, scan them for vulnerabilities using Trivy, push images to Docker Hub, and deploy applications to an AWS EC2 instance.

It contains two applications:

- **Nginx application:** Demonstrates a successful build, security scan, image push, and deployment.
- **Flask application:** Demonstrates how a security scan can block the pipeline before an image is pushed or deployed when qualifying vulnerabilities are detected.

The project illustrates the integration of containerization, automation, cloud deployment, and security checks in a workflow.

## Objectives

- Build Docker images automatically using GitHub Actions.
- Scan container images for known vulnerabilities using Trivy.
- Prevent vulnerable images from proceeding through the pipeline when they match the configured security threshold.
- Push images to Docker Hub after successful security scans.
- Deploy approved images to AWS EC2.
- Send Slack notifications for successful and failed workflows.
- Demonstrate security-gated CI/CD using separate application workflows.

## Technologies Used

| Technology | Purpose |
|---|---|
| Git and GitHub | Source-code management |
| GitHub Actions | CI/CD automation |
| Docker | Containerization |
| Docker Hub | Container image registry |
| Trivy | Container vulnerability scanning |
| AWS EC2 | Application hosting |
| Ubuntu | EC2 operating system |
| SSH | Remote deployment |
| Slack | Pipeline notifications |
| Python and Flask | Flask web application |
| Nginx | Static web application server |

## Project Structure

CloudDock/
├── app/
│   └── index.html
├── Dockerfile
├── .dockerignore
├── flask-app/
│   ├── app.py
│   ├── Dockerfile
│   └── requirements.txt
├── .github/
│   └── workflows/
│       ├── deploy.yml
│       └── flask-deploy.yml
└── README.md

## Architecture

                    GitHub Repository
                           |
                Push to main / Manual Run
                           |
                    GitHub Actions
                           |
                     Build Docker Image
                           |
                      Trivy Scan
                           |
                 +---------+---------+
                 |                   |
             Scan Pass           Scan Fails
                 |                   |
          Push to Docker Hub    Stop Pipeline
                 |                   |
          Deploy to EC2        No Deployment
                 |
          Application Running
                 |
               Browser

The Flask workflow uses a security gate before the image-push and deployment stages. If Trivy reports vulnerabilities matching the configured severity threshold, the scan fails and subsequent deployment stages are skipped.

## Applications

### 1. Nginx Application

The Nginx application serves a static HTML page from a Docker container.

**Workflow stages:**

1. Check out the repository.
2. Set up Docker Buildx.
3. Build the Docker image.
4. Scan the image using Trivy.
5. Log in to Docker Hub.
6. Push the image with commit-specific and `latest` tags.
7. Deploy the image to AWS EC2 over SSH.
8. Send a Slack notification.

The application is exposed on EC2 port `5000`, mapped to port `80` inside the container.

Example browser URL:

http://YOUR_EC2_PUBLIC_IP:5000

### 2. Flask Security Demonstration

The Flask application provides two endpoints:

- `/` — Returns application information as JSON.
- `/health` — Returns a health status.

The application listens on port `5000` inside the container. If deployment is permitted, the container port is mapped to EC2 port `5001`.

Example URLs after a successful deployment:

http://YOUR_EC2_PUBLIC_IP:5001/
http://YOUR_EC2_PUBLIC_IP:5001/health

The Flask workflow uses a deliberately vulnerable Flask dependency for the security demonstration.

**Expected security-gate behavior:**

1. GitHub Actions builds the Flask image.
2. Trivy scans the image for HIGH and CRITICAL library vulnerabilities.
3. If a matching vulnerability is detected, Trivy exits with a non-zero status.
4. The workflow fails at the scan stage.
5. Docker Hub push and EC2 deployment steps are skipped.
6. Slack receives a failure notification, provided the webhook is configured and available.

The vulnerable image is intended for scanning in the CI environment, not for deployment to EC2.

The scan outcome depends on the vulnerabilities identified by the scanner and its vulnerability database. Verify the actual Trivy report to confirm that the intended finding was detected.

## Security Configuration

The Trivy step uses the following settings:

exit-code: "1"
ignore-unfixed: true
vuln-type: library
severity: HIGH,CRITICAL

These settings mean:

- `exit-code: "1"` — Fail the scan when findings matching the configured severity criteria are reported.
- `ignore-unfixed: true` — Ignore vulnerabilities for which no fix is available.
- `vuln-type: library` — Scan application libraries rather than operating-system packages.
- `severity: HIGH,CRITICAL` — Apply the security gate to high- and critical-severity findings.

A passing scan does not guarantee that an image is completely vulnerability-free.

## Prerequisites

Before running the workflows, ensure that you have:

- A GitHub repository with Actions enabled.
- Docker Hub account and repository access.
- An AWS EC2 Ubuntu instance with Docker installed.
- SSH connectivity from GitHub Actions to EC2.
- An EC2 security group configured with appropriate access rules.
- A Slack incoming webhook, if notifications are required.

## GitHub Secrets

Configure these repository secrets under **Settings → Secrets and variables → Actions**.

| Secret | Description |
|---|---|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub password or access token |
| `EC2_HOST` | Public IP address or hostname of the EC2 instance |
| `EC2_USERNAME` | SSH username, commonly `ubuntu` |
| `EC2_SSH_KEY` | Private SSH key used for deployment |
| `SLACK_WEBHOOK_URL` | Slack incoming webhook URL |

Never commit passwords, private SSH keys, access tokens, or webhook URLs to the repository.

## AWS EC2 Configuration

The deployment uses the same EC2 instance for both applications, with separate containers and host ports.

| Application | EC2 host port | Container port |
|---|---:|---:|
| Nginx | 5000 | 80 |
| Flask | 5001 | 5000 |

Configure inbound security-group rules only for the access that is required. For browser testing, restrict application ports to your trusted public IP when possible. Avoid exposing SSH port `22` to all IP addresses.

If the Flask image fails its security scan, the workflow should not deploy it.

## Running the Workflows

### Nginx workflow

1. Push changes to the `main` branch.
2. Open the repository's **Actions** tab.
3. Select the Nginx workflow.
4. Inspect the build, scan, push, deployment, and notification stages.
5. Open the application in a browser after a successful deployment.

### Flask security workflow

1. Push the Flask application and workflow files to `main`, or run the Flask workflow manually from the **Actions** tab.
2. Open the workflow run.
3. Inspect the Docker image build.
4. Examine the Trivy scan output.
5. If a qualifying vulnerability is detected, verify that the scan fails and the push and deployment steps are skipped.
6. Inspect the Slack failure notification, if configured.

Because the Flask workflow is configured to run on pushes to `main` as well as manual dispatches, adding its files to the repository can trigger both the Flask and existing Nginx workflows independently.

## Verification Commands

Connect to the EC2 instance using SSH and check the running containers:

sudo docker ps

Inspect the Nginx container logs:

sudo docker logs clouddock-app

Inspect the Flask container logs after a successful deployment:

sudo docker logs clouddock-flask

Test the applications locally on EC2:

curl -I http://localhost:5000
curl http://localhost:5001/
curl http://localhost:5001/health

The Flask commands will succeed only if the Flask container has been deployed and is running.

## Expected Results

| Scenario | Expected result |
|---|---|
| Nginx image passes its scan | Image is pushed and deployed |
| Flask image contains a matching HIGH or CRITICAL vulnerability | Workflow fails at Trivy |
| Flask scan fails | Image-push and deployment steps are skipped |
| Flask image passes its scan | Image is pushed and deployment is attempted |
| Deployment succeeds | Application is accessible through its configured port |
| Pipeline fails | Slack failure notification is attempted |

## Learning Outcomes

This project demonstrates:

- CI/CD pipeline design and automation.
- Docker image creation and deployment.
- Container vulnerability scanning.
- Security gates in DevSecOps.
- AWS EC2 deployment using SSH.
- Docker Hub image versioning.
- Workflow failure handling and notifications.
- Separation of successful deployments from intentionally blocked deployments.

## Possible Future Enhancements

- Replace SSH-based deployment with AWS Systems Manager where permitted.
- Add HTTPS using a domain name and reverse proxy.
- Introduce image signing and software bill of materials (SBOM) generation.
- Use a maintained Flask version and automated dependency updates for production workloads.

## Disclaimer

The vulnerable Flask dependency is included strictly to demonstrate security scanning and pipeline failure handling. Do not deploy the intentionally vulnerable image in a production environment. Use maintained dependencies and review scan findings before deploying real applications.

---

**CloudDock demonstrates how automated security checks can become a mandatory gate in a container deployment pipeline.**
