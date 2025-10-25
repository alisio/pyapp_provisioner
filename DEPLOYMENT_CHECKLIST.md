# 📋 Pre-Production Checklist

Use this checklist before deploying to production environments.

## ✅ Configuration Validation

### Inventory Setup
- [ ] `inventories/prod/hosts.ini` contains correct target servers
- [ ] SSH access tested to all target hosts: `ansible all -m ping`
- [ ] Correct `ansible_user` configured for each host
- [ ] Python 3 available on all target hosts

### Application Configuration
- [ ] `python_apps` list defined in `group_vars/app_servers.yml`
- [ ] Each app has unique `name` field
- [ ] Each app has unique `env_name` field
- [ ] All repository URLs are accessible (SSH keys or tokens configured)
- [ ] All `dest` paths use absolute paths
- [ ] Dependency types correctly specified (conda_env, requirements, or pip_list)
- [ ] Dependency files exist in repositories (for conda_env/requirements types)

### Security
- [ ] Secrets moved to Ansible Vault: `ansible-vault create inventories/prod/group_vars/app_servers/vault.yml`
- [ ] Vault password stored securely (not in repository)
- [ ] No plain-text passwords in configuration files
- [ ] SSH keys properly configured on target hosts
- [ ] File ownership/permissions appropriate for environment
- [ ] `.vault_pass` file in `.gitignore` (if used)

## ✅ Pre-Deployment Testing

### Syntax & Linting
```bash
# Syntax check
ansible-playbook playbooks/provision_apps.yml --syntax-check

# Ansible linting
ansible-lint roles/python_app

# YAML linting
yamllint .
```
- [ ] Syntax check passes
- [ ] No linting errors (warnings acceptable)
- [ ] YAML formatting correct

### Dry Run
```bash
# Check mode with diff
ansible-playbook playbooks/provision_apps.yml --check --diff
```
- [ ] Dry run completes without errors
- [ ] Changes shown are expected
- [ ] No unexpected file modifications

### Limited Scope Test
```bash
# Test on single host first
ansible-playbook playbooks/provision_apps.yml --limit server01
```
- [ ] Single host provisioning successful
- [ ] Services start correctly
- [ ] Applications respond as expected

### Molecule Tests (Optional but Recommended)
```bash
cd roles/python_app
molecule test
```
- [ ] All molecule tests pass
- [ ] Idempotence verified
- [ ] No unexpected changes on re-run

## ✅ Dependency Installation

### Galaxy Requirements
```bash
ansible-galaxy install -r requirements.yml
```
- [ ] `mambaorg.micromamba` role installed
- [ ] `community.general` collection installed (>= 6.0)
- [ ] `ansible.posix` collection installed (>= 1.5)

### Target Host Prerequisites
- [ ] Git >= 2.20 installed on all hosts
- [ ] Systemd >= 240 available (if using systemd integration)
- [ ] Sufficient disk space for repositories and environments
- [ ] Network access to package repositories (PyPI, conda-forge)

## ✅ Execution Plan

### Variables Review
- [ ] `default_user` set correctly
- [ ] `micromamba_root_prefix` path appropriate
- [ ] `python_app_base_dir` has sufficient space
- [ ] Python versions available in conda-forge
- [ ] Log level appropriate for environment

### Rollback Plan
- [ ] Backup strategy defined (if `python_app_backup_enabled: true`)
- [ ] Rollback procedure documented
- [ ] Previous versions tagged in Git
- [ ] Service downtime window planned

### Monitoring & Alerting
- [ ] Service monitoring configured (if applicable)
- [ ] Log aggregation ready to receive logs
- [ ] Alert thresholds defined
- [ ] On-call team notified

## ✅ Deployment Execution

### Pre-Deployment
```bash
# Verify Ansible connectivity
ansible all -m ping

# Check disk space
ansible all -m shell -a "df -h /opt"

# Verify user exists
ansible all -m shell -a "id {{ default_user }}"
```
- [ ] All hosts respond to ping
- [ ] Sufficient disk space available
- [ ] Deploy user exists and accessible

### Deployment
```bash
# Option 1: No vault
ansible-playbook playbooks/provision_apps.yml

# Option 2: With vault password prompt
ansible-playbook playbooks/provision_apps.yml --ask-vault-pass

# Option 3: With vault password file
ansible-playbook playbooks/provision_apps.yml --vault-password-file .vault_pass

# Option 4: Verbose for troubleshooting
ansible-playbook playbooks/provision_apps.yml -vvv
```
- [ ] Playbook completes successfully
- [ ] No failed tasks
- [ ] All expected changes reported

## ✅ Post-Deployment Validation

### Service Status
On each target host, verify:
```bash
# Check conda environments
micromamba env list

# Verify services (if systemd enabled)
systemctl status <app_name>.service

# Check service logs
journalctl -u <app_name>.service -n 50
```
- [ ] All conda environments created
- [ ] Services running (if enabled)
- [ ] No errors in service logs
- [ ] Applications responding to requests

### Application Testing
- [ ] HTTP endpoints responding (if applicable)
- [ ] Database connections working
- [ ] Environment variables loaded correctly
- [ ] Post-install scripts executed successfully

### File Verification
```bash
# On target hosts
ls -la /opt/apps/
ls -la ~/.micromamba/envs/
```
- [ ] Repository directories exist with correct ownership
- [ ] Conda environments present
- [ ] .env files created (if env_vars defined)
- [ ] Permissions correct (755 for dirs, 600 for .env)

### Dependency Verification
```bash
# Activate environment and check packages
micromamba run -n <env_name> pip list
```
- [ ] All required packages installed
- [ ] Correct package versions
- [ ] No dependency conflicts

## ✅ Documentation & Handoff

### Operations Documentation
- [ ] Service restart procedures documented
- [ ] Log locations documented
- [ ] Configuration update process documented
- [ ] Troubleshooting guide created

### Access & Credentials
- [ ] Vault password shared with operations team (securely)
- [ ] SSH key access documented
- [ ] Service account credentials documented (if any)

### Monitoring
- [ ] Dashboards created/updated
- [ ] Alerts configured
- [ ] SLOs defined
- [ ] Runbooks updated

## 🚨 Troubleshooting Quick Reference

### Common Issues

**Git clone fails:**
```bash
# Test SSH access
ssh -T git@github.com

# Check SSH keys
ssh-add -l

# Test with verbose SSH
GIT_SSH_COMMAND="ssh -v" git clone <repo_url>
```

**Conda environment errors:**
```bash
# List environments
micromamba env list

# Remove corrupted environment
micromamba env remove -n <env_name>

# Re-run with force_recreate
```

**Service won't start:**
```bash
# Check service status
systemctl status <service_name>

# View logs
journalctl -u <service_name> -xe

# Verify ExecStart command manually
cd /opt/apps/<app_name>
micromamba run -n <env_name> python main.py
```

**Permission denied:**
```bash
# Check ownership
ls -la /opt/apps/<app_name>

# Fix ownership if needed
chown -R deploy:deploy /opt/apps/<app_name>
```

## 📞 Support Contacts

- **DevOps Team**: [contact info]
- **On-call**: [contact info]
- **Escalation**: [contact info]

---

**Checklist completed by**: _______________  
**Date**: _______________  
**Environment**: ☐ Dev  ☐ Staging  ☐ Production  
**Deployment approved**: ☐ Yes  ☐ No
