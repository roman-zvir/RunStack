#!/bin/bash
# terraform-quickstart.sh - Quick start script for Terraform beginners
# This script helps you get started with Terraform for RunStack

set -e  # Exit on any error

echo "🚀 Welcome to RunStack Terraform Quick Start!"
echo "============================================="
echo ""

# Check if we're in the right directory
if [ ! -f "terraform/main.tf" ]; then
    echo "❌ Error: Please run this script from the RunStack root directory"
    exit 1
fi

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first:"
    echo "   https://learn.hashicorp.com/tutorials/terraform/install-cli"
    exit 1
fi
echo "✅ Terraform found: $(terraform version -json | jq -r '.terraform_version')"

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first:"
    echo "   https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi
echo "✅ Azure CLI found"

# Check Azure login
if ! az account show &> /dev/null; then
    echo "❌ Not logged into Azure. Please run: az login"
    exit 1
fi
echo "✅ Logged into Azure as: $(az account show --query user.name -o tsv)"

cd terraform

# Setup configuration file
echo ""
echo "⚙️ Setting up configuration..."
if [ ! -f "terraform.tfvars" ]; then
    cp terraform.tfvars.example terraform.tfvars
    echo "✅ Created terraform.tfvars from example"
    
    # Generate a unique ACR name
    RANDOM_SUFFIX=$(openssl rand -hex 3)
    sed -i "s/runstackregistrydev123/runstackregistrydev${RANDOM_SUFFIX}/g" terraform.tfvars
    echo "✅ Generated unique ACR name: runstackregistrydev${RANDOM_SUFFIX}"
else
    echo "✅ terraform.tfvars already exists"
fi

# Initialize Terraform
echo ""
echo "🏗️ Initializing Terraform..."
terraform init

# Show plan
echo ""
echo "📋 Planning deployment..."
echo "This will show you what resources will be created:"
echo ""
terraform plan

echo ""
echo "🤔 Ready to deploy? This will create real Azure resources that cost money!"
echo ""
read -p "Do you want to proceed with deployment? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Deploying infrastructure..."
    terraform apply -auto-approve
    
    echo ""
    echo "🎉 Deployment complete!"
    echo ""
    echo "📋 Important information:"
    echo "========================"
    terraform output
    
    echo ""
    echo "🔧 Next steps:"
    echo "1. Get cluster credentials:"
    echo "   az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw aks_cluster_name)"
    echo ""
    echo "2. Deploy your application:"
    echo "   kubectl apply -f ../k8s/"
    echo ""
    echo "3. Check status:"
    echo "   kubectl get pods,svc"
    echo ""
    echo "💡 To clean up resources later: terraform destroy"
else
    echo "Deployment cancelled. You can run 'terraform apply' manually when ready."
fi

echo ""
echo "📚 For more information, see terraform/README.md"
echo "🎉 Happy Terraforming!"
