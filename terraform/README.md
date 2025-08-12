# RunStack Terraform Infrastructure

Welcome to the Terraform part of RunStack! 🎉

This directory contains Infrastructure as Code (IaC) configuration to deploy and manage the Azure cloud resources needed for the RunStack application.

## 🤔 What is Terraform?

Terraform is a tool that lets you define your cloud infrastructure using code instead of clicking around in the Azure portal. Think of it as "recipes" for creating cloud resources that you can version control, share, and repeat consistently.

## 📁 File Structure

```
terraform/
├── main.tf                  # Main infrastructure configuration
├── variables.tf            # Input variables (like function parameters)
├── outputs.tf              # Output values (what gets returned)
├── terraform.tfvars.example # Example configuration file
├── .gitignore              # Files to ignore in version control
└── README.md               # This file
```

## 🏗️ What This Creates

This Terraform configuration creates the following Azure resources:

1. **Resource Group** - A container that holds all your Azure resources
2. **Azure Container Registry (ACR)** - Where your Docker images are stored
3. **Azure Kubernetes Service (AKS)** - Where your application runs
4. **Role Assignment** - Allows AKS to pull images from ACR

## 🚀 Getting Started

### Prerequisites

1. **Install Terraform**:
   ```bash
   # On Ubuntu/Debian
   sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
   wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform
   ```

2. **Install Azure CLI**:
   ```bash
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

3. **Login to Azure**:
   ```bash
   az login
   ```

### Step-by-Step Deployment

1. **Navigate to the terraform directory**:
   ```bash
   cd terraform
   ```

2. **Create your configuration file**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit terraform.tfvars** to customize your deployment:
   ```bash
   nano terraform.tfvars  # or use your favorite editor
   ```
   
   **Important**: Change the `acr_name` to something unique (it must be globally unique across all of Azure)!

4. **Initialize Terraform** (downloads required plugins):
   ```bash
   terraform init
   ```

5. **Plan your deployment** (see what will be created):
   ```bash
   terraform plan
   ```

6. **Apply the configuration** (actually create the resources):
   ```bash
   terraform apply
   ```
   
   Type `yes` when prompted to confirm.

## 📊 Understanding the Outputs

After deployment, Terraform will show you important information:

- **acr_login_server**: URL for your container registry
- **aks_cluster_name**: Name of your Kubernetes cluster  
- **resource_group_name**: Where all your resources live

## 🔧 Common Commands

```bash
# See current state
terraform show

# See output values
terraform output

# See sensitive output values
terraform output -json

# Update infrastructure (after changing .tf files)
terraform plan
terraform apply

# Destroy all resources (be careful!)
terraform destroy
```

## 💰 Cost Considerations

The default configuration uses:
- **AKS**: 2 Standard_DS2_v2 nodes (~$140-200/month)
- **ACR**: Basic tier (~$5/month)

**Tip**: To save money while learning, you can:
- Reduce `node_count` to 1
- Use smaller VM sizes
- Destroy resources when not in use: `terraform destroy`

## 🔒 Security Best Practices

1. **Never commit terraform.tfvars** - it's already in .gitignore
2. **Store state securely** - for production, use remote state storage
3. **Use service principals** - instead of your personal Azure account
4. **Review plans carefully** - always run `terraform plan` before `apply`

## 🐛 Troubleshooting

### Common Issues:

**"ACR name already exists"**
- Solution: Change `acr_name` in terraform.tfvars to something unique

**"Insufficient quota"**
- Solution: Check your Azure subscription limits or choose a different region

**"Authentication failed"**
- Solution: Run `az login` again

**Want to start over?**
```bash
terraform destroy  # Remove all resources
terraform apply    # Create them again
```

## 🎓 Learning More

Great resources for learning Terraform:
- [Terraform Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Learn](https://learn.hashicorp.com/terraform)
- [Azure Terraform Examples](https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples)

## 🔄 Next Steps

Once you're comfortable with this basic setup, you can extend it by:
- Adding monitoring and logging resources
- Setting up multiple environments (dev, staging, prod)
- Adding networking configurations
- Implementing CI/CD for infrastructure
- Using Terraform modules for reusability

## 🤝 Integration with Existing Kubernetes

Your existing Kubernetes manifests in the `/k8s` folder will work with the AKS cluster created by this Terraform configuration. After deployment, you can:

1. Get cluster credentials:
   ```bash
   az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw aks_cluster_name)
   ```

2. Deploy your existing Kubernetes manifests:
   ```bash
   kubectl apply -f ../k8s/
   ```

Happy Terraforming! 🌍✨
