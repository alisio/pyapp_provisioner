# Galaxy Publication Guide

This guide helps you publish the `python_app` role to Ansible Galaxy.

## Prerequisites

1. **Ansible Galaxy Account**
   - Create account at https://galaxy.ansible.com
   - Note your username (you'll need it)

2. **GitHub Repository**
   - Role should be in a GitHub repository
   - Repository can be public or private (Galaxy can access private repos)

3. **API Token**
   - Get your API token from Galaxy: https://galaxy.ansible.com/me/preferences
   - Store securely (needed for automated imports)

## Pre-Publication Checklist

### ✅ Required Files
- [x] `meta/main.yml` - Galaxy metadata
- [x] `README.md` - Role documentation
- [x] `LICENSE` - License file (MIT)
- [x] `tasks/main.yml` - Main task file
- [x] `defaults/main.yml` - Default variables
- [x] `handlers/main.yml` - Handlers
- [x] `CHANGELOG.md` - Version history

### ✅ Optional but Recommended
- [x] `molecule/` - Tests
- [x] `templates/` - Jinja2 templates
- [x] `files/` - Static files
- [x] `vars/` - Variables (high precedence)
- [x] `.github/workflows/` - CI/CD

### ⚠️ Update Before Publishing

1. **Update `meta/main.yml`:** ✅ COMPLETED
   ```yaml
   galaxy_info:
     role_name: python_app
     author: alisio
     namespace: alisio
     description: Idempotent provisioning of Python applications with Micromamba environments
     company: Alisio DevOps
     license: MIT
     min_ansible_version: "2.14"
   ```

2. **Update LICENSE:** ✅ COMPLETED
   - Replaced "DevOps Team" with "Alisio"

3. **Update README.md:** ✅ COMPLETED
   - Added installation instructions with Galaxy username (alisio)
   - Added badges (CI status, Galaxy download count, etc.)

## Publication Methods

### Method 1: GitHub Integration (Recommended)

1. **Connect GitHub to Galaxy:**
   - Log into Galaxy
   - Go to "My Content" → "Add Content"
   - Select "Import Role from GitHub"
   - Authorize Galaxy to access your GitHub

2. **Import Role:**
   - Galaxy will scan your repositories
   - Select the repository containing `python_app`
   - Galaxy will import automatically

3. **Configure Auto-Import:**
   - Enable webhook for automatic updates
   - Every push to main branch will trigger re-import

### Method 2: Manual Import

```bash
# From the role directory
ansible-galaxy role import --token YOUR_API_TOKEN alisio ansible-role-python-app
```

### Method 3: Travis CI Integration

Add to `.travis.yml`:
```yaml
deploy:
  provider: script
  script: ansible-galaxy role import --token $GALAXY_TOKEN $TRAVIS_REPO_SLUG
  on:
    tags: true
```

## Installation Command

After publication, users can install with:

```bash
ansible-galaxy install alisio.python_app
```

Or in `requirements.yml`:
```yaml
roles:
  - name: alisio.python_app
    version: "1.0.0"
```

## Version Tagging

Use Git tags for versioning:

```bash
# Tag a version
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Galaxy will detect tags automatically
```

## Adding Badges to README

Add these to the top of your README.md: ✅ COMPLETED

```markdown
[![CI](https://github.com/alisio/python_app/workflows/CI/badge.svg)](https://github.com/alisio/python_app/actions)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-alisio.python__app-blue.svg)](https://galaxy.ansible.com/alisio/python_app)
[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
```

## Testing Galaxy Import Locally

Before publishing:

```bash
# Build the role archive
ansible-galaxy role build /path/to/python_app

# This creates python_app-1.0.0.tar.gz

# Test installation locally
ansible-galaxy role install ./python_app-1.0.0.tar.gz
```

## Troubleshooting

### Import Fails

**Check:**
- `meta/main.yml` has valid YAML
- All required fields in `galaxy_info` are present
- Galaxy tags are valid
- Role name follows Galaxy naming conventions (lowercase, underscores)

### Molecule Tests Fail

**Ensure:**
- All dependencies in `molecule/default/requirements.yml` are accessible
- Docker is available for molecule tests
- Test scenarios don't require external resources

### Dependencies Not Found

**Verify:**
- All role dependencies in `meta/main.yml` exist on Galaxy
- Collection dependencies are available on Galaxy/Automation Hub
- Version constraints are not too restrictive

## Post-Publication

1. **Verify Installation:**
   ```bash
   ansible-galaxy install alisio.python_app
   ansible-galaxy info alisio.python_app
   ```

2. **Update Documentation:**
   - Add Galaxy installation instructions to README
   - Update version in CHANGELOG.md
   - Document any breaking changes

3. **Promote Your Role:**
   - Share on social media
   - Add to company/team documentation
   - Submit to awesome-ansible lists

## Maintenance

### Releasing New Versions

1. Update CHANGELOG.md
2. Update version in meta/main.yml (optional)
3. Commit changes
4. Tag release: `git tag -a v1.1.0 -m "Release 1.1.0"`
5. Push: `git push && git push --tags`
6. Galaxy auto-imports (if webhook enabled)

### Deprecating the Role

If you need to deprecate:

1. Update README with deprecation notice
2. Set in `meta/main.yml`:
   ```yaml
   galaxy_info:
     deprecated: true
     deprecated_message: "This role is deprecated. Use XYZ instead."
   ```

## Support

- **Galaxy Docs**: https://docs.ansible.com/ansible/latest/galaxy/user_guide.html
- **Galaxy Support**: https://github.com/ansible/galaxy/issues
- **Community**: https://forum.ansible.com

---

## Quick Start for This Role

```bash
# 1. Update meta/main.yml with your Galaxy username ✅ DONE
# Already updated to: alisio

# 2. Update LICENSE with your name ✅ DONE
# Already updated to: Alisio

# 3. Commit and push
git add .
git commit -m "Prepare for Galaxy publication"
git push

# 4. Tag release
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0

# 5. Import to Galaxy (one-time)
ansible-galaxy role import --token YOUR_API_TOKEN alisio ansible-role-python-app

# 6. Enable webhook for auto-updates in Galaxy UI
```

After publication, users install with:
```bash
ansible-galaxy install alisio.python_app
```
