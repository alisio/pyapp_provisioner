# Python App Provisioner

Ansible-based automation for provisioning multiple Python applications with isolated Micromamba environments.

## 🚀 Quick Start

### 1. Install Dependencies

```bash
# Install Ansible collections and roles
ansible-galaxy install -r requirements.yml

# Install Molecule for testing (optional)
pip install molecule molecule-plugins[docker] ansible-lint
```

### 2. Configure Your Applications

Edit `inventories/prod/group_vars/app_servers.yml`:

```yaml
python_apps:
  - name: my_app
    repo: "git@github.com:org/my_app.git"
    dest: "/opt/apps/my_app"
    env_name: "my_app_env"
    dependencies:
      type: requirements
      file: "requirements.txt"
```

### 3. Configure Secrets (if needed)

```bash
# Create encrypted vault file
ansible-vault create inventories/prod/group_vars/app_servers/vault.yml

# Add your secrets
vault_database_url: "postgresql://..."
vault_api_key: "sk-..."
```

### 4. Run Provisioning

```bash
# Dry run first
ansible-playbook playbooks/provision_apps.yml --check --diff

# Apply for real
ansible-playbook playbooks/provision_apps.yml

# With vault password
ansible-playbook playbooks/provision_apps.yml --ask-vault-pass
```

## 📁 Project Structure

```
.
├── ansible.cfg                           # Ansible configuration
├── requirements.yml                      # Galaxy dependencies
├── playbooks/
│   └── provision_apps.yml               # Main playbook
├── inventories/
│   └── prod/
│       ├── hosts.ini                    # Inventory file
│       └── group_vars/
│           └── app_servers.yml          # App definitions
│           └── app_servers/
│               └── vault.yml            # Encrypted secrets
└── roles/
    └── python_app/                      # Main role
        ├── defaults/
        ├── tasks/
        ├── templates/
        ├── handlers/
        ├── meta/
        ├── molecule/                    # Tests
        └── README.md                    # Role documentation
```

## 🎯 Features

- ✅ **Multi-application management** from a single configuration
- ✅ **Isolated environments** using Micromamba
- ✅ **Flexible dependencies**: conda_env, requirements.txt, or inline pip_list
- ✅ **Update strategies**: pull, clone_fresh, skip_if_exists
- ✅ **Smart dependency reinstall**: always, on_change, never
- ✅ **Systemd integration** for service management
- ✅ **Post-install hooks** for custom setup scripts
- ✅ **Comprehensive validation** with detailed error messages
- ✅ **Idempotent operations** safe to run multiple times

## 📖 Documentation

- **Role Documentation**: See [roles/python_app/README.md](roles/python_app/README.md)
- **SRS Specification**: See [srs.md](srs.md)

## 🧪 Testing

```bash
# Run full test suite
cd roles/python_app
molecule test

# Run specific scenarios
molecule converge  # Apply role
molecule verify    # Run verifications
molecule idempotence  # Check idempotence

# Lint
ansible-lint roles/python_app
yamllint roles/python_app
```

## 🔐 Security

### Git Authentication

Configure SSH keys on target hosts before running:

```bash
# On target hosts
ssh-add ~/.ssh/deploy_key

# Or use SSH agent forwarding
ansible-playbook -e "ansible_ssh_common_args='-o ForwardAgent=yes'" playbooks/provision_apps.yml
```

### Vault Usage

```bash
# Create vault
ansible-vault create inventories/prod/group_vars/app_servers/vault.yml

# Edit vault
ansible-vault edit inventories/prod/group_vars/app_servers/vault.yml

# View vault
ansible-vault view inventories/prod/group_vars/app_servers/vault.yml

# Use password file (not recommended for production)
echo "your_vault_password" > .vault_pass
chmod 600 .vault_pass
```

## 📋 Example Configurations

### Simple App with Requirements

```yaml
python_apps:
  - name: simple_api
    repo: "https://github.com/org/simple.git"
    dest: "/opt/apps/simple"
    env_name: "simple_env"
    dependencies:
      type: requirements
      file: "requirements.txt"
```

### Production App with All Features

```yaml
python_apps:
  - name: production_app
    repo: "git@github.com:org/app.git"
    dest: "/opt/apps/app"
    env_name: "app_prod"
    python_version: "3.10"
    branch: "v2.0.0"
    state: present
    update_strategy: pull
    reinstall_deps: on_change
    dependencies:
      type: requirements
      file: "requirements.txt"
    env_vars:
      DATABASE_URL: "{{ vault_database_url }}"
      API_KEY: "{{ vault_api_key }}"
    post_install:
      script: "scripts/migrate.sh"
      args: ["--production"]
    systemd:
      enabled: true
      service_name: "production_app"
    owner: deploy
    group: deploy
```

### Remove Deprecated App

```yaml
python_apps:
  - name: old_app
    repo: "git@github.com:org/old.git"
    dest: "/opt/apps/old"
    env_name: "old"
    state: absent
    systemd:
      enabled: true
```

## 🛠️ Troubleshooting

### Verbose Output

```bash
ansible-playbook -vvv playbooks/provision_apps.yml
```

### Check Service Logs

```bash
# On target host
journalctl -u <service_name> -f
```

### Validate Configuration

```bash
ansible-playbook playbooks/provision_apps.yml --syntax-check
ansible-playbook playbooks/provision_apps.yml --check --diff
```

## 📦 CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Provision Apps
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Ansible
        run: |
          pip install ansible
          ansible-galaxy install -r requirements.yml
      - name: Run playbook
        env:
          ANSIBLE_VAULT_PASSWORD: ${{ secrets.VAULT_PASSWORD }}
        run: |
          echo "$ANSIBLE_VAULT_PASSWORD" > .vault_pass
          ansible-playbook playbooks/provision_apps.yml --vault-password-file .vault_pass
```

## 📄 License

MIT

## 👥 Contributors

DevOps Team
