# Introduction to GitLab Infrastructure as Code Flow

## Infrastructure as Code, GitOps, and related buzzwords

Infrastructure as Code (IaC) is the approach of provisioning, configuring, running, and
destroying infrastructure elements using code. Infrastructure can mean anything
from installing an OS to bare-metal servers through Elastic Cloud Compute (EC2) instances, setting up and
scaling clusters, or just managing your GitLab instance, and connecting your cluster
with a project. Running these tools using code, instead of manual administration is the territory of IaC.

GitOps is a term originally coined by Weaveworks that meant managing a Kubernetes (K8s)
cluster by pushing code to your Git repository. In GitOps, a continuous deployment
job is started that runs your code, and applies changes to your Kubernetes cluster.
Since its original inception, GitOps became a synonym for IaC. People use it for
every type of infrastructure as code project that's executed in a continuous delivery
job attached to a Git repo, it's not about Kubernetes management only.

While managing Kubernetes with GitOps provides much value, many companies don't run
Kubernetes or they have other infrastructure needs beyond Kubernetes. Today the *de facto standard*
for generic infrastructure as code management is Terraform. Terraform provides various
providers to manage different infrastructure types. This way you can manage your GitLab
instance, an EKS, GKS or self-hosted Kubernetes cluster all from Terraform.
Alternatively, you can run your Terraform code from Git. Thus you get all the benefits of GitOps
with it as well.

### What is the best option for you

The best option depends on your needs, the technology background, and culture of your DevOps team. Making a technology
investment is a tough decision, and we obviously can not and do not want to provide here a generic, all-encompassing response. Still, we would like to point out a few questions and their consequences that might help you to follow along with the GitLab recommended Infrastructure as Code Flow.

When to use Terraform?

- If many developers are expected to touch and modify your infrastructure code, we recommend Terraform.
- If compliance is important, we recommend Terraform, as its state file might already fulfill your needs.

When not to use Terraform?

- If only some developers are expected to modify your infrastructure code, and they are already familiar with a specific tool (e.g. kubectl), then we recommend to stay with that.
- If operators or system admins are expected to manage your infrastructure directly, then IaC tools are not an option. We recommend thinking twice about this approach, and initiating a larger project to introduce IaC practices.

## Managing Kubernetes-only infrastructures with GitLab

Auto DevOps provides pre-defined CI/CD configuration which allows you to automatically detect, build, test, deploy, and monitor your applications. Leveraging CI/CD best practices and tools, Auto DevOps aims to simplify the setup and execution of a mature & modern software development lifecycle.

You can learn more about [GitLab's Auto DevOps offering](https://docs.gitlab.com/ee/topics/autodevops/) in its documentation.

If Auto DevOps does not fulfil your needs, we provide recommendations for a more generic setup below.

<!-- 

Managing K8s with GitLab, but splitting app and infra code:
https://www.youtube.com/watch?v=MOALiliVoeg

 -->

## Application code and infrastructure code

We recommend to separate your application code from your infrastructure code. For very simple infrastructures, like
serverless functions, the infrastructure code might stay beside your application code. For every other case, often these
codebases are managed by different sets of people and in different intervals. Moreover by separating your application and infrastructure codes, you can separate your CI
and CD pipelines that simplifies debugging, maintenance, and allows for better authorization management.

**# image here about the 2 pipelines, starting with code dev, being connected by docker and ending on an infrastructure #**

A successful run of the CI job in the application repo should start the deployment job in the infrastructure repo. Our
recommendation is to use the application CI job to build and push [container images to the registry](https://docs.gitlab.com/ee/user/packages/container_registry/), and have the infrastrucure job to use these images for the deployment.

Many users can re-use a single infrastructure as code repo for different application projects by setting appropriate
environment variables for the CD job.

## Infrastructure code organization

Depending on the diversity of your infrastructure, you might have one or many infrastructure projects. Our recommendation
is to always aim for a modular setup. You can either store your modules together with your running Terraform code, or as
separate projects, each being Git-tagged, and reference them from your main Terraform code, or by using a private
Terraform module registry. For versioning reasons, we recommend against storing the modules together with your main code.

```
Example code here on how to reference a module stored in another GitLab repo
```

Beside splitting your modules into their own projects, you might want to operate several infrastructure repos. Our recommendation is to
use separate repositories only when it's really necessary, that often means compliance reasons. Otherwise, manage all your
environments from a single repo where each environment has its own directory.

```
Example code organization directory tree
```

By default, this setup means a lot of code-duplication, as different environments of the same application often have only
minor differences. You might prefer avoiding such code-duplication with tools like [TerraGrunt](https://github.com/gruntwork-io/terragrunt).

## Infrastructure delivery pipelines

TODO all this section

<!-- 
TODO To be added later as we ship these features

## Reviewing Terraform plan

https://gitlab.com/gitlab-org/gitlab/issues/39402

Just adding: minor importance; removing: I want to check it

## Using GitLab CI/CD templates

add issue link if it exists
-->

[Testing with terratest](https://github.com/gruntwork-io/terratest)

### Review environments

This video shows [how our Solution Architects think about Tf](https://chorus.ai/meeting/617369?tab=summary&call=10CED52925A74815A9C7A837943EFC43):

```
terraform workspace new $CI_COMMIT_REF_NAME
terraform workspace select $CI_COMMIT_REF_NAME
terraform plan
```

### Infrastructure related project templates

<!-- TODO create and list reference architectures -->
We recommend creating company-specific project templates. As a quick-start, we've created a set of reference architectures.

### Merge trains

To avoid conflicts in applying changes, we recommend to always apply a specific plan, and to use
merge trains.

### Secrets management

Every secure key that finally ends in the `.tfstate` file should be time-restricted,
and automatically expire once the infra is ready.

Long living passwords (e.g. db password) should be retrieved directly from Vault
by the app or a configuration management tool like Ansible, not by Terraform.

## Company-wide infrastructure management with IaC

TODO how is this different from the above? What do we want to write about here?

## Recommended readings and videos

- Terraform: Up and Running
- Best practices with Terraform and Vault

## Example setups

- [Wag! @ re:Invent](https://www.youtube.com/watch?v=HfEl9GXZC0s)
- [Google's example setup for K8s](https://www.youtube.com/watch?v=MOALiliVoeg)
- [VMWare demo](https://www.youtube.com/watch?v=qXj4ShQZ4IM)
