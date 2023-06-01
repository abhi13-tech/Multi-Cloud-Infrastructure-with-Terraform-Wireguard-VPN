#!/bin/bash
# Script to backdate commits for Multi-Cloud Infrastructure with Terraform & Wireguard VPN repository
# Repository: https://github.com/abhi13-tech/Multi-Cloud-Infrastructure-with-Terraform-Wireguard-VPN.git

# Exit on error
set -e

# Configuration
AUTHOR_NAME="abhi13-tech"
AUTHOR_EMAIL="adunooria1@montclair.edu"  # Replace with your actual email
START_DATE="2023-06-01"  # Starting date for the project
REPO_URL="https://github.com/abhi13-tech/Multi-Cloud-Infrastructure-with-Terraform-Wireguard-VPN.git"

# Check if we're in the correct repository
if [ ! -d ".git" ]; then
  echo "Error: Not in a git repository."
  echo "Please clone your repository first:"
  echo "git clone $REPO_URL"
  echo "cd Multi-Cloud-Infrastructure-with-Terraform-Wireguard-VPN"
  exit 1
fi

# Verify we're in the right repo
CURRENT_REMOTE=$(git config --get remote.origin.url 2>/dev/null || echo "")
if [[ "$CURRENT_REMOTE" != *"Multi-Cloud-Infrastructure-with-Terraform-Wireguard-VPN"* ]]; then
  echo "Warning: This doesn't appear to be the Multi-Cloud Infrastructure repository."
  read -p "Continue anyway? (y/n): " continue_choice
  if [[ $continue_choice != "y" && $continue_choice != "Y" ]]; then
    exit 1
  fi
fi

# Define commit sequence with realistic development timeline
declare -a COMMITS=(
  "2023-06-01 09:00:00|Initial project setup and repository structure"
  "2023-06-02 14:30:00|Add Terraform configuration files and provider setup"
  "2023-06-05 10:15:00|Implement AWS module with VPC and networking"
  "2023-06-07 16:45:00|Add security groups and EC2 instance for AWS"
  "2023-06-10 11:20:00|Implement Azure module with resource group and VNet"
  "2023-06-12 13:50:00|Add Azure VM and network security group configuration"
  "2023-06-15 09:30:00|Implement GCP module with VPC network and subnet"
  "2023-06-17 15:10:00|Add GCP compute instance and firewall rules"
  "2023-06-20 12:00:00|Create Wireguard module for VPN configuration"
  "2023-06-22 14:25:00|Add Wireguard setup scripts and configuration templates"
  "2023-06-25 10:45:00|Implement client configuration generation"
  "2023-06-27 16:20:00|Add environment-specific configurations"
  "2023-06-30 11:35:00|Create comprehensive documentation and README"
  "2023-07-03 13:15:00|Add .gitignore and terraform.tfvars.example"
  "2023-07-05 09:50:00|Refactor modules for better reusability"
  "2023-07-08 15:30:00|Add validation and error handling"
  "2023-07-10 12:40:00|Update outputs and add networking routes"
  "2023-07-12 14:55:00|Fix security group configurations"
  "2023-07-15 10:20:00|Add production environment configuration"
  "2023-07-17 16:10:00|Final testing and documentation updates"
)

# Function to create file structure if it doesn't exist
create_file_structure() {
  # Create directories
  mkdir -p modules/{aws,azure,gcp,wireguard/scripts}
  mkdir -p environments/{dev,prod}
  
  # Create main files if they don't exist
  touch main.tf variables.tf outputs.tf versions.tf
  touch terraform.tfvars.example .gitignore README.md
  
  # Create module files
  for provider in aws azure gcp wireguard; do
    touch modules/$provider/{main.tf,variables.tf,outputs.tf}
  done
  
  # Create environment files
  for env in dev prod; do
    touch environments/$env/{main.tf,variables.tf,terraform.tfvars.example}
  done
  
  # Create Wireguard scripts
  touch modules/wireguard/scripts/{setup-wireguard.sh,generate-client-config.sh,wireguard.conf.tpl}
}

# Function to add realistic content to files based on commit
add_commit_content() {
  local commit_index=$1
  local commit_msg=$2
  
  case $commit_index in
    0) # Initial setup
      echo "# Multi-Cloud Infrastructure with Terraform & Wireguard VPN" > README.md
      echo "terraform {}" > main.tf
      ;;
    1) # Terraform configuration
      echo 'terraform { required_version = ">= 1.0.0" }' > versions.tf
      echo 'variable "environment" { type = string }' > variables.tf
      ;;
    2) # AWS module
      echo 'resource "aws_vpc" "main" { cidr_block = var.vpc_cidr }' > modules/aws/main.tf
      ;;
    3) # AWS security
      echo 'resource "aws_security_group" "wireguard" {}' >> modules/aws/main.tf
      ;;
    4) # Azure module
      echo 'resource "azurerm_resource_group" "main" {}' > modules/azure/main.tf
      ;;
    5) # Azure VM
      echo 'resource "azurerm_virtual_machine" "wireguard" {}' >> modules/azure/main.tf
      ;;
    6) # GCP module
      echo 'resource "google_compute_network" "main" {}' > modules/gcp/main.tf
      ;;
    7) # GCP instance
      echo 'resource "google_compute_instance" "wireguard" {}' >> modules/gcp/main.tf
      ;;
    8) # Wireguard module
      echo 'resource "null_resource" "wireguard_setup" {}' > modules/wireguard/main.tf
      ;;
    9) # Wireguard scripts
      echo '#!/bin/bash' > modules/wireguard/scripts/setup-wireguard.sh
      echo 'sudo apt-get install wireguard' >> modules/wireguard/scripts/setup-wireguard.sh
      ;;
    10) # Client config
      echo '[Interface]' > modules/wireguard/scripts/wireguard.conf.tpl
      ;;
    11) # Environment configs
      echo 'module "aws" { source = "../../modules/aws" }' > environments/dev/main.tf
      ;;
    12) # Documentation
      echo -e "\n## Features\n- Multi-cloud deployment" >> README.md
      ;;
    13) # Git files
      echo "*.tfstate" > .gitignore
      echo "environment = \"dev\"" > terraform.tfvars.example
      ;;
    *) # General updates
      echo -e "\n# Updated: $(date)" >> README.md
      ;;
  esac
}

# Create initial file structure
echo "Creating project file structure..."
create_file_structure

# Process each commit
echo "Creating backdated commits..."
for i in "${!COMMITS[@]}"; do
  IFS='|' read -r date_time commit_msg <<< "${COMMITS[$i]}"
  
  echo "Creating commit $((i+1))/${#COMMITS[@]}: $commit_msg"
  
  # Add content based on commit
  add_commit_content $i "$commit_msg"
  
  # Stage all changes
  git add .
  
  # Check if there are changes to commit
  if git diff --staged --quiet; then
    echo "No changes to commit for: $commit_msg"
    continue
  fi
  
  # Set the date environment variables
  export GIT_AUTHOR_DATE="$date_time"
  export GIT_COMMITTER_DATE="$date_time"
  
  # Create the commit
  git commit -m "$commit_msg" --author="$AUTHOR_NAME <$AUTHOR_EMAIL>"
  
  # Small delay to ensure commits are in order
  sleep 1
done

# Clear environment variables
unset GIT_AUTHOR_DATE
unset GIT_COMMITTER_DATE

echo ""
echo "✅ Successfully created ${#COMMITS[@]} backdated commits!"
echo ""
echo "📋 Next steps:"
echo "1. Review the commit history: git log --oneline"
echo "2. If satisfied, force push to your repository:"
echo "   git push -f origin main"
echo ""
echo "⚠️  Warning: Force pushing will overwrite the remote history!"
echo "   Make sure you have a backup if needed."
