# Optional Azure AKS lab infrastructure

This Terraform root provisions a dedicated resource group, VNet/subnet, Log Analytics workspace and a small AKS cluster with managed identity, RBAC, OIDC issuer, workload identity and Azure Policy integration.

> **Cost warning:** AKS nodes, load balancer, Log Analytics ingestion and related Azure resources incur charges. This is not a free-tier lab. Review pricing, region quota and subscription policy before applying. Destroy the lab when finished.

## Prerequisites
- Terraform >= 1.8
- Azure CLI authenticated to the intended subscription
- Permission to create resource groups, VNets, AKS, Log Analytics and required role assignments
- AKS regional quota for the selected VM size

## Deploy
```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
terraform init
# Commit .terraform.lock.hcl after reviewing provider checksums/version.
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Review the plan carefully. It creates billable infrastructure. Do not run apply in a production subscription.

## Connect
```bash
az aks get-credentials --resource-group rg-supply-chain-lab --name aks-supply-chain-lab
kubectl get nodes
```

Install Kyverno and follow [the lab guide](../../docs/implementation/run-the-lab.md). Replace the demo deployment image with the exact GHCR image digest emitted by the release workflow.

## Destroy
```bash
terraform plan -destroy
terraform destroy
```

Confirm resource group and subscription before destroying. This is a simple public API-server lab cluster, not a production AKS baseline. Production requires private cluster/network design, private endpoints, egress control, workload identity federation, backup/DR, policy governance, monitoring, upgrade strategy and security review.
