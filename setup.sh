#!/bin/bash
# Quick start script for pyapp_provisioner
# This script helps you get started quickly

set -e

echo "=========================================="
echo "Python App Provisioner - Quick Start"
echo "=========================================="
echo ""

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed"
    echo "Install with: pip install ansible"
    exit 1
fi
echo "✓ Ansible found: $(ansible --version | head -n1)"

# Check if ansible-galaxy is available
if ! command -v ansible-galaxy &> /dev/null; then
    echo "❌ ansible-galaxy not found"
    exit 1
fi
echo "✓ ansible-galaxy found"

echo ""
echo "Installing dependencies..."
echo "------------------------"

# Install Ansible collections and roles
ansible-galaxy install -r requirements.yml --force

echo ""
echo "✓ Dependencies installed"
echo ""
echo "Next steps:"
echo "==========="
echo ""
echo "1. Configure your applications:"
echo "   Edit: inventories/prod/group_vars/app_servers.yml"
echo ""
echo "2. Update your inventory:"
echo "   Edit: inventories/prod/hosts.ini"
echo ""
echo "3. (Optional) Configure secrets with Vault:"
echo "   ansible-vault create inventories/prod/group_vars/app_servers/vault.yml"
echo ""
echo "4. Test your configuration:"
echo "   ansible-playbook playbooks/provision_apps.yml --syntax-check"
echo "   ansible-playbook playbooks/provision_apps.yml --check --diff"
echo ""
echo "5. Run provisioning:"
echo "   ansible-playbook playbooks/provision_apps.yml"
echo ""
echo "Optional: Run Molecule tests"
echo "   cd roles/python_app"
echo "   molecule test"
echo ""
echo "=========================================="
echo "Ready to go! 🚀"
echo "=========================================="
