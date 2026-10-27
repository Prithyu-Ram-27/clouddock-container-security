# CloudDock

## Project Title
Container Image Hardening and Security Scanner with Automated Cloud Deployment

## Team
- Badri Narayan Sahu — 25BCE1167
- Prithyu Ram B — 25BCE1126

## Project Overview
CloudDock demonstrates container image hardening, vulnerability scanning,
and automated deployment using Docker, Trivy, GitHub Actions, Docker Hub,
and AWS EC2.

## Technology Stack
- Python Flask
- Docker
- Trivy
- GitHub Actions
- Docker Hub
- AWS EC2
- Ubuntu Server

## Application Endpoints
- `/` — CloudDock application home page
- `/health` — Application health check

## Security Objectives
- Use a slim container base image
- Run the application as a non-root user
- Scan container images for vulnerabilities
- Block images that violate the configured security gate
- Deploy verified images to AWS EC2
