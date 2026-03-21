End-to-End-EKS-GitOps-CD-Pipeline
Automated Provisioning of a Production-Grade Amazon 
EKS Cluster using Terraform, GitHub Actions, and 
GitOps with ArgoCD.

🎯 Purpose of the Project
The goal of this project is to demonstrate the 
ability to automate cloud infrastructure and 
application delivery. Instead of manually clicking 
through the AWS Console, this project uses a 
"Code-First" approach to build a self-healing 
Kubernetes environment that synchronizes 
automatically with GitHub.

👥 Target Users & Stakeholder Value
This project solves real-world bottlenecks for 
three key groups:

1. The Software Developers (The "Tenants")
The Problem: Waiting days for infrastructure to be 
ready to host an app.
The Solution: A GitOps-driven platform. Developers 
simply push code to a kubernetes/ folder, and the 
infrastructure updates itself.
Key Benefit: Velocity. No more waiting for 
"tickets" to be cleared.

2. The DevOps Team (The "Guardians")
The Problem: "Configuration Drift"—where the live 
server doesn't match the documentation.
The Solution: Using ArgoCD, the cluster constantly 
"heartbeats" against GitHub. If someone manually 
changes a setting in AWS, ArgoCD automatically 
reverts it to the "Truth" in Git.
Key Benefit: Reliability. The system is 
self-correcting.

3. The Business Owners (The "Stakeholders")
The Problem: High costs and unpredictable downtime.
The Solution: * Cost Governance: Used t3.small 
instances specifically sized to handle the 
management overhead while staying cost-effective.
High Availability: Spread across multiple 
Availability Zones in the London region.

Key Benefit: Risk Mitigation.

📊 Summary: Problem vs. Solution

User Role	Old Manual Problem	Your 
Project's Automated Solution
Developer	"I have to wait weeks for a 
server."	Self-Service: Deploy instantly via 
Git push.
DevOps	"I have to manually fix server drift."	
GitOps: ArgoCD auto-syncs state 24/7.
CEO/Owner	"The site is down and we are losing 
money."	High Availability: EKS replaces failed 
nodes automatically.

🛠 Tech Stack
Cloud: AWS (VPC, EKS, IAM, EC2)
IaC: Terraform
CI/CD: GitHub Actions (Infrastructure)
Continuous Delivery: ArgoCD (GitOps)
Orchestration: Kubernetes (EKS)
Tools: kubectl, helm, terraform-cli

🚀 Step-by-Step Implementation

Phase 1: Infrastructure as Code (Terraform)
Provisioned a VPC and EKS Control Plane.
Configured IAM Roles and OIDC Providers for secure 
cluster communication.
Automated the deployment via GitHub Actions.

Phase 2: GitOps Controller Setup
Installed ArgoCD into the cluster.
Created a secure tunnel using kubectl port-forward 
to manage the dashboard.

Phase 3: The "Magic" Moment (Scaling & Sync)
Connected the cluster to the kubernetes/ directory 
in GitHub.
Demonstrated automatic scaling from 2 to 4 replicas 
purely by changing a number in Git.

🔧 Engineering Challenges & Solutions

Challenge: AWS Service Quotas & VPC Limits

The Problem: Initial deployments failed because the 
region reached the limit for VPC creation.

The Solution: Refactored the Terraform logic to 
dynamically target the Default VPC, ensuring a 
successful deployment without hitting AWS regional 
soft limits.

Challenge: Kubelet Pressure & Node Sizing

The Problem: t3.micro nodes were too small to run 
the ArgoCD management stack, causing 
"ImagePullBackOff" and "NodeNotReady" errors.

The Solution: Upscaled the Managed Node Group to 
t3.small instances, providing the necessary memory 
overhead for the Kubernetes control plane to 
function smoothly.

Challenge: Resource Resurrection (Auto-Scaling 
Loops)

The Problem: Attempting to delete instances 
manually caused the EKS Node Group to recreate them 
automatically.

The Solution: Developed a manual teardown 
sequence—terminating the Node Group first to break 
the scaling logic, followed by the Cluster, 
ensuring 100% cost control.

🏁 Final Project Status: ARCHIVED
Infrastructure: Verified & Successfully Teardown.
Documentation: Complete.
Automation: CI/CD & GitOps verified for Scaling.
Next Project: [Cloud-Native-Monitoring-Stack 
(Prometheus & Grafana)] 🔜
