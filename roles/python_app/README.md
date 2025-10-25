# Ansible Role: python_app

[![CI](https://github.com/alisio/python_app/workflows/CI/badge.svg)](https://github.com/alisio/python_app/actions)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-alisio.python__app-blue.svg)](https://galaxy.ansible.com/alisio/python_app)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)

Idempotent provisioning of Python applications from Git repositories with isolated Micromamba environments, flexible dependency management, and optional systemd integration.

## Features

- ✅ **Multi-app support**: Manage multiple Python applications with a single role
- ✅ **Isolation**: Each app gets its own Micromamba conda environment
- ✅ **Flexible dependencies**: Support for `conda_env`, `requirements.txt`, or inline `pip_list`
- ✅ **Update strategies**: `pull`, `clone_fresh`, or `skip_if_exists`
- ✅ **Smart reinstall**: Dependencies reinstalled based on `always`, `on_change`, or `never`
- ✅ **Systemd integration**: Optional service creation and management
- ✅ **Post-install hooks**: Execute custom scripts after installation
- ✅ **Comprehensive validation**: Input validation and error handling
- ✅ **Idempotent**: Safe to run multiple times without side effects

## Installation

### From Ansible Galaxy

```bash
ansible-galaxy install alisio.python_app
```

### Using requirements.yml

```yaml
# requirements.yml
roles:
  - name: alisio.python_app
    version: "1.0.0"
```

Then install:
```bash
ansible-galaxy install -r requirements.yml
```

## Requirements

### Ansible

- Ansible Core >= 2.14
- Python >= 3.9 (on control node)

### Collections

```bash
ansible-galaxy collection install community.general ansible.posix
```

### Role Dependencies

```bash
ansible-galaxy role install mambaorg.micromamba
```

> **Note**: Dependencies are automatically installed when using `ansible-galaxy install`

### Managed Nodes

- Ubuntu 20.04/22.04, Debian 11/12, or RHEL 8/9
- Git >= 2.20
- Systemd >= 240 (if using systemd integration)

## Role Variables

### Required Variables (defined in group_vars/host_vars)

```yaml
python_apps:
  - name: "app_name"              # Unique identifier
    repo: "git@github.com:..."    # Git repository URL
    dest: "/opt/apps/app_name"    # Absolute path for code
    env_name: "app_env"           # Unique conda environment name
```

### Optional App Variables

| Variable | Default | Choices | Description |
|----------|---------|---------|-------------|
| `state` | `present` | `present`, `absent`, `latest` | Desired state |
| `branch` | `main` | Any Git ref | Branch, tag, or commit |
| `python_version` | `3.11` | `3.x` | Python version for environment |
| `update_strategy` | `pull` | `pull`, `clone_fresh`, `skip_if_exists` | How to update repo |
| `git_force` | `false` | `true`, `false` | Overwrite local changes |
| `force_recreate` | `false` | `true`, `false` | Recreate conda env |
| `reinstall_deps` | `on_change` | `always`, `on_change`, `never` | When to reinstall dependencies |
| `on_failure` | `fail` | `fail`, `warn`, `skip` | Failure handling |
| `owner` | `deploy` | username | File owner |
| `group` | `deploy` | groupname | File group |
| `mode` | `0755` | permissions | Directory permissions |

### Dependency Configuration

Choose ONE dependency type per app:

**Option 1: Conda environment file**
```yaml
dependencies:
  type: conda_env
  file: "environment.yml"
```

**Option 2: Requirements file**
```yaml
dependencies:
  type: requirements
  file: "requirements.txt"
```

**Option 3: Inline pip packages**
```yaml
dependencies:
  type: pip_list
  packages:
    - fastapi
    - uvicorn[standard]
```

### Environment Variables

```yaml
env_vars:
  DATABASE_URL: "{{ vault_database_url }}"
  API_KEY: "{{ vault_api_key }}"
  LOG_LEVEL: "info"
```

### Post-Install Scripts

```yaml
post_install:
  script: "scripts/setup.sh"
  args: ["--production"]
```

### Systemd Configuration

```yaml
systemd:
  enabled: true
  service_name: "my_app"                        # Optional
  service_template: "templates/custom.service.j2"  # Optional
```

### Role Defaults (override in group_vars if needed)

```yaml
default_user: "deploy"
micromamba_root_prefix: "/home/deploy/.micromamba"
python_app_base_dir: "/opt/apps"
python_app_default_python: "3.11"
python_app_log_level: "info"  # debug, info, warning, error
```

## Example Playbook

```yaml
---
# playbooks/provision_apps.yml
- name: Provision Python applications
  hosts: app_servers
  become: false  # Role handles privilege escalation when needed
  
  roles:
    - role: python_app
```

## Example Inventory

```yaml
# inventories/prod/group_vars/app_servers.yml
---
default_user: deploy
micromamba_root_prefix: "/home/deploy/.micromamba"

python_apps:
  # Full-featured app with all options
  - name: boleto_extract_prod
    repo: "git@github.com:org/boleto_extract.git"
    dest: "/opt/apps/boleto_extract"
    env_name: "boleto_prod"
    python_version: "3.10"
    branch: "main"
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
      script: "scripts/setup.sh"
      args: ["--production"]
    systemd:
      enabled: true
    owner: deploy
    group: deploy

  # Simple app with conda environment
  - name: data_processor
    repo: "https://github.com/org/data_processor.git"
    dest: "/opt/apps/data_processor"
    env_name: "data_proc"
    dependencies:
      type: conda_env
      file: "environment.yml"

  # App with inline pip packages
  - name: simple_api
    repo: "https://github.com/org/simple.git"
    dest: "/opt/apps/simple"
    env_name: "simple_env"
    dependencies:
      type: pip_list
      packages:
        - fastapi
        - uvicorn[standard]
        - pydantic
    systemd:
      enabled: true

  # Remove deprecated app
  - name: old_app
    repo: "git@github.com:org/old.git"
    dest: "/opt/apps/old"
    env_name: "old"
    state: absent
```

## Security & Vault

### Storing Secrets with Ansible Vault

**Never** store secrets in plain text. Use Ansible Vault:

```bash
# Create encrypted variables file
ansible-vault create inventories/prod/group_vars/app_servers/vault.yml
```

```yaml
# vault.yml (encrypted)
vault_database_url: "postgresql://user:pass@db.example.com/dbname"
vault_api_key: "sk-1234567890abcdef"
```

Reference in your app configuration:

```yaml
env_vars:
  DATABASE_URL: "{{ vault_database_url }}"
  API_KEY: "{{ vault_api_key }}"
```

Run playbook with vault password:

```bash
ansible-playbook playbooks/provision_apps.yml --ask-vault-pass
# or
ansible-playbook playbooks/provision_apps.yml --vault-password-file ~/.vault_pass
```

### Git Authentication

The role does NOT manage Git credentials. Configure authentication before running:

**SSH (recommended):**
```bash
# On target hosts, add SSH key
ssh-add ~/.ssh/deploy_key

# Or use ssh-agent forwarding
ansible-playbook -e "ansible_ssh_common_args='-o ForwardAgent=yes'" ...
```

**HTTPS with token:**
```yaml
# Use Vault for tokens
repo: "https://{{ vault_github_token }}@github.com/org/repo.git"
```

### File Permissions

The role enforces secure permissions:
- Repository files: `0755` (directories), `0644` (files)
- `.env` files: `0600` (sensitive data)
- Scripts: `0755` (if executable)
- Systemd units: `0644` (root-owned)

## Testing with Molecule

### Install Molecule

```bash
pip install molecule molecule-plugins[docker] ansible-lint yamllint
```

### Run Tests

```bash
# Full test sequence
cd roles/python_app
molecule test

# Just converge (apply role)
molecule converge

# Run verifications
molecule verify

# Idempotence check
molecule idempotence

# Cleanup
molecule destroy
```

### Test Scenarios

See `molecule/default/` for test implementation:
- Input validation
- Multiple apps with different dependency types
- Idempotence verification
- Update strategies
- State=absent handling
- Error conditions

## Validation & CI

### Pre-deployment Validation

```bash
# Syntax check
ansible-playbook playbooks/provision_apps.yml --syntax-check

# Dry run
ansible-playbook playbooks/provision_apps.yml --check --diff

# Lint
ansible-lint roles/python_app
yamllint roles/python_app
```

### CI Integration

Example GitHub Actions workflow:

```yaml
name: Ansible CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install ansible molecule molecule-plugins[docker] ansible-lint
          ansible-galaxy install -r requirements.yml
      
      - name: Run ansible-lint
        run: ansible-lint roles/python_app
      
      - name: Run Molecule tests
        run: |
          cd roles/python_app
          molecule test
```

## Variable Precedence

Understanding where to define variables (from lowest to highest precedence):

1. **Role defaults** (`roles/python_app/defaults/main.yml`): Base defaults
2. **Inventory** (`inventories/prod/hosts.ini`): Avoid; use group_vars instead
3. **Group vars** (`inventories/prod/group_vars/app_servers.yml`): Recommended for app definitions
4. **Host vars** (`inventories/prod/host_vars/server01.yml`): Host-specific overrides
5. **Play vars** (in playbook): Temporary overrides
6. **Extra vars** (`-e` CLI): Emergency overrides only

**Best Practice**: Define `python_apps` in `group_vars/app_servers.yml`, use `host_vars` for host-specific tweaks, avoid `extra-vars` except for exceptional cases.

## Troubleshooting

### Check logs

```bash
# Ansible verbose output
ansible-playbook -vvv playbooks/provision_apps.yml

# Systemd service logs
journalctl -u <service_name> -f
```

### Common Issues

**Git clone fails:**
- Verify SSH keys or HTTPS tokens are configured
- Check `git_force: true` if local changes exist

**Conda environment errors:**
- Use `force_recreate: true` to rebuild corrupted environments
- Check Python version compatibility

**Dependencies not updating:**
- Verify `reinstall_deps: on_change` or use `always`
- Check if dependency file changed

**Service won't start:**
- Review `journalctl -u <service_name>`
- Verify `ExecStart` command in systemd template
- Check environment variables and paths

## License

MIT

## Author

DevOps Team
