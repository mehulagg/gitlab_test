# Introduction to GitLab Terraform Flow

# Application code and infrastructure code

2 projects:

- application code
- application related infrastructure code

# Infrastructure code organisation

Company wide infrastructure code lives here. Depending on how decentralised the
infrastructure team is, this might mean just a collection of Terraform modules,
in which case every final infrastructure code lives in the application related infrastructure code repositories.

# Infrastructure delivery pipelines

<!-- 
To be added later as we ship these features

## Reviewing Terraform plan

https://gitlab.com/gitlab-org/gitlab/issues/39402

## Using GitLab CI/CD templates

add issue link if it exists
-->

# Secrets management

Every secure key that finally ends in the .tfstate file should be time-restricted,
and automatically expire once the infra is ready.

Long living passwords (e.g. db password) should be retrieved directly from Vault
by the app or a configuration management tool like Ansible, not by Terraform.

# Recommended readings and videos

- Terraform: Up and Running
- Best practices with Terraform and Vault