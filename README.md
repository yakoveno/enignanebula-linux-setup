# EnigmaNebula Linux Setup

This repository contains the complete setup for EnigmaNebula's independent Linux system.

## Overview

This is a Git-based Linux environment that can be deployed on any new PC with a single setup script. It includes:

- Automated system provisioning via Ansible
- Complete OpenClaw configuration
- Docker services for EnigmaNebula
- Security and monitoring tools

## Structure

- `/ansible` - Ansible playbooks for automated system provisioning
- `/dotfiles` - Configuration files (shell, editor configs, etc.)
- `/services` - Docker Compose files for services
- `/scripts` - Automation and maintenance scripts
- `/docs` - Setup instructions and documentation

## Deployment

To deploy this system on a new machine:

1. Boot from Ubuntu Server installation media
2. Run the setup script: `./setup.sh`
3. The system will automatically configure itself with EnigmaNebula

## License

This project is maintained by EnigmaNebula for autonomous operation.