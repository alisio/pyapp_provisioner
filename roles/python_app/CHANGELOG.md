# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release
- Multi-application provisioning with Micromamba environments
- Support for conda_env, requirements.txt, and pip_list dependencies
- Update strategies: pull, clone_fresh, skip_if_exists
- Smart dependency reinstallation (always, on_change, never)
- Systemd service integration
- Post-install script execution
- Comprehensive input validation
- Full idempotency
- Molecule test suite
- Complete documentation

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- Ansible Vault integration for secrets
- Proper file permissions (0755 for directories, 0600 for .env files)
- Least privilege execution (become only when necessary)

## [1.0.0] - 2025-10-25

### Added
- Initial stable release
- Production-ready Python application provisioner
- Full test coverage with Molecule
- Comprehensive documentation
