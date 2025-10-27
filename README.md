Project: openwebui-on-eks
Location: openwebui-on-eks/README.md

Flow Diagram:

                                            ┌────────────────────────┐
                                            │     Terraform (IaC)     │
                                            │  - Provisions EKS/Infra │
                                            │  - Creates VPC, Nodes   │
                                            └──────────┬─────────────┘
                                                    │
                                                    ▼
                                            ┌────────────────────────┐
                                            │     Kubernetes Cluster  │
                                            │ (EKS or Minikube Local) │
                                            └──────────┬─────────────┘
                                                    │
                                            ┌─────────┴─────────────┐
                                            ▼                       ▼
                                    ┌────────────────┐       ┌────────────────┐
                                    │  Ollama Pod     │<---->│ OpenWebUI Pod  │
                                    │  - Runs LLMs     │     │ - Frontend UI  │
                                    │  (Llama2/phi3)   │     │ - Calls Ollama │
                                    └────────────────┘       └────────────────┘
                                            ▲                      │
                                            │                      ▼
                                            │             ┌────────────────┐
                                            │             │   Ingress /    │
                                            │             │   LoadBalancer │
                                            │             │ (Exposes UI)   │
                                            │             └────────────────┘
                                            │
                                            ▼
                                    ┌────────────────────────┐
                                    │   End User / Browser    │
                                    │ Access via URL or Ngrok │
                                    └────────────────────────┘

Flow Summary
--------
- Terraform → Automates infrastructure creation (EKS / Minikube setup).
- Kubernetes → Hosts all workloads (openwebui, ollama pods, services, ingress).
- OpenWebUI Pod → The web interface for chatting with models.
- Ollama Pod → Runs the actual lightweight LLM (e.g., llama2, phi3:mini).
- Service & Env Vars → OLLAMA_BASE_URL connects OpenWebUI to Ollama’s service inside the cluster.
- Ingress / LoadBalancer → Makes OpenWebUI accessible externally.
- User → Accesses the deployed UI via public URL (EKS endpoint or Ngrok).

Overview
--------
This repository contains infrastructure and deployment artifacts to run OpenWebUI (a web UI for hosting ML models) on AWS EKS. It focuses on reproducible cluster creation, container build/publish, Kubernetes manifests/Helm charts, and basic operational notes.

Contents
-------------------
- terraform-eks         - eksctl / terraform or cloudformation snippets for EKS cluster and networking
- k8s/                  - Kubernetes manifests for OpenWebUI, ingress, services, PVCs and helm charts.
- virtualbox-local-setup - Local vm setup on virtualbox and installation using ansible playbooks

Prerequisites
-------------
- AWS account with permissions to create VPC, EKS, IAM, ECR, ELB
- Local tools:
    - awscli (v2) configured (aws configure)
    - eksctl
    - kubectl
    - docker
    - jq (optional)

Quick setup (example)
---------------------
1. Configure AWS
    - Ensure AWS credentials and region are set:
        - export AWS_PROFILE=your-profile
        - export AWS_REGION=us-east-1

2. Create VPC & EKS cluster using terraform scripts
    - terraform init
    - terraform plan
    - terraform apply

3. Deploy to Kubernetes
    - Ensure kubectl context points to the new cluster:
        - aws eks update-kubeconfig --region $AWS_REGION --name openwebui
    - Apply provided manifests
        - kubectl apply -f k8s/ollama.yaml
        - kubectl apply -f k8s/openwebui.yaml
    - OR we can install the things using helm:
        - helm create openwebui-helm-chart # For creating helm chart
        - helm install openwebui ./openwebui-helm-chart # For installing it into the cluster
        - helm upgrade openwebui ./openwebui-chart --set openwebui.replicas=2  # for Upgrading or change values
        - helm uninstall openwebui # For Uninstalling openwebui

5. Accessing the UI
    - If Service type=LoadBalancer:
        - kubectl get svc -n openwebui
        - Visit the EXTERNAL-IP:PORT shown.
    - If using Ingress with ALB/NGINX:
        - Configure DNS to point to the ingress controller external endpoint.
    - If you want to access over privateip address

6. Downloading LLM models:
    - kubectl exec -it deploy/ollama -n openwebui -- ollama pull llama2
    - kubectl exec -it deploy/ollama -n openwebui -- ollama pull phi3:mini

7. Check list of downloaded models:
    - kubectl exec -it deploy/ollama -n openwebui -- ollama list

8. Restart the OpenwebUI pods:
    - kubectl rollout restart deploy/openwebui -n openwebui

9. Optional: Troubleshooting steps:
    - kubectl exec -it deploy/openwebui -n openwebui -- printenv | grep OLLAMA_BASE_URL
    - kubectl logs deploy/openwebui -n openwebui
    - kubectl describe deploy/openwebui -n openwebui
    - kubectl logs deploy/ollama -n openwebui
    - kubectl describe deploy/ollama -n openwebui