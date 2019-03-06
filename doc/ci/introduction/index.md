---
description: "An overview of Continuous Integration, Continuous Delivery, and Continuous Deployment, as well as an introduction to GitLab CI/CD."
---

# Introduction to CI/CD with GitLab

In this document we'll present an overview of Continuous Integration,
Continuous Delivery, and Continuous Deployment, as well as an introduction to
GitLab CI/CD.

<!-- TBA: PM's introductory video? -->

## Introduction to continuous methods

Read the sections below for an introduction to the continuous methodology of software development:

- [Continuous Integration](#continuous-integration)
- [Continuous Delivery](#continuous-delivery)
- [Continuous Deployment](#continuous-deployment)

### Continuous Integration

Consider an application which has its code stored in a Git
repository in GitLab. Developers push code changes every day,
multiple times a day. For every push to the repository, you
can create a set of scripts to build and test your application
automatically, decreasing the chance of introducing errors to your app.

This practice is known as [Continuous Integration](https://en.wikipedia.org/wiki/Continuous_integration);
for every change submitted to a given application, it's built
and tested automatically and continuously, making sure the introduced changes
pass all tests, guidelines, and code compliances you established
for your app.

[GitLab itself](https://gitlab.com/gitlab-org/gitlab-ce) is a
practical example of using Continuous Integration as a software
development method. For every push to the project, there's a set
of scripts the code is checked against.

<!-- TBA: illustration -->

### Continuous Delivery

[Continuous Delivery](https://continuousdelivery.com/) is a step
beyond Continuous Integration, where you not only build
and test your application at every code change pushed to your
application's codebase, but, as an additional step, you also
deploy it continuously, but the deployment is triggered manually.

This method ensures the code is checked automatically but requires
someone to manually and strategically trigger the deployment
of the changes.

> Continuous Delivery is a software engineering approach in
which Continuous Integration, automated testing, and automated
deployment capabilities allow software to be developed and
deployed rapidly, reliably and repeatedly with minimal human
intervention.

<!-- TBA: illustration -->

### Continuous Deployment

[Continuous Deployment](https://www.airpair.com/continuous-deployment/posts/continuous-deployment-for-practical-people)
is a further step beyond Continuous Integration, in the same light as
Continuous Delivery. The difference is that instead of deploying your
application manually, you set it up so that the deployment is also
triggered automatically.

> Continuous Deployment is a software development practice in which
every code change goes through the entire pipeline and is put into
production automatically, resulting in many production deployments
every day. It does everything that Continuous Delivery does, but
the final deployment step is also fully automated, with no human intervention at all.

<!-- TBA: illustration -->

## Introduction to GitLab CI/CD

GitLab CI/CD is a powerful tool built into GitLab that allows you
to apply all the continuous methods (Continuous Integration,
Delivery, and Deployment) to your software with no third-party
application or integration needed.

### How GitLab CI/CD works

To use GitLab CI/CD, all you need is an application codebase hosted in a
Git repository, and configure your build, test, and deployment
scripts in a file called [`.gitlab-ci.yml`](../yaml/README.md),
placed at the root of your repository.

In this file, you define the scripts you want to run, include and
cache dependencies, choose what commands you want to run in sequence
and those you want to run in parallel, define where you want to
deploy your app to, and choose if you want to run the script automatically
or if you want to trigger it manually. Once you're familiar with
GitLab CI/CD you can add more advanced steps into the configuration file.

To add scripts to that file, you'll need to organize them in a
sequence that suits your application and are in accordance with
the tests you wish to perform. To visualize the process, imagine
that all the scripts you add to the configuration file are the
same as the commands you run on a terminal in your computer.

Once you've added your `.gitlab-ci.yml` configuration file to your
repository, GitLab will detect it and run your scripts with the
tool called [GitLab Runner](https://docs.gitlab.com/runner/), which
works similarly to your terminal.

GitLab CI/CD not only executes the scripts you've set, but also shows you
what's happening during execution, as you would see in your terminal:

![job running](img/job_running.png)

You create the strategy for your app and GitLab runs the pipeline
for you according to what you've set. Your pipeline status is also
displayed by GitLab:

![pipeline status](img/pipeline_status.png)

At the end, if anything goes wrong, you can easily
[roll back](../environments.md#rolling-back-changes) all the changes:

![rollback button](img/rollback.png)

### Basic CI/CD Workflow

This is a very simple example for how GitLab CI/CD fits in a common
development workflow.

Assume that you have discussed a code implementation in an issue
and worked locally on your proposed changes. Once you push your
commits to a feature branch in a remote repository in GitLab,
the CI/CD pipeline set for your project is triggered. By doing
so, GitLab CI/CD:

- Runs automated scripts (sequential or parallel):
  - Build and test your app.
  - Deploy to a staging environment.
  - Preview the changes with Review Apps.

Once you're happy with your implementation:

- Get your code reviewed and approved.
- Merge the feature branch into the default branch.
  - GitLab CI/CD deploys your changes automatically to a production environment.
-  And finally you and your team can easily roll it back if something goes wrong.

GitLab CI/CD is capable of a doing a lot more, but this workflow
exemplifies GitLab's ability to track the entire process,
without the need of any external tool to deliver your software.
And, most usefully, you can visualize all the steps through
the GitLab UI.

<!-- ONCE WE HAVE IT, LINK TO EXAMPLE WORKFLOWS FOR DEV TEAMS USING CI/CD. -->

<img src="../img/cicd_pipeline_infograph.png" alt="pipeline graph" class="image-noshadow">

### Setting up GitLab CI/CD for the first time

To get started with GitLab CI/CD, you need to familiarize yourself
with the [`.gitlab-ci.yml`](../yaml/README.md) configuration file
syntax and with its attributes.

This document [introduces the concepts of GitLab CI/CD in the scope of GitLab Pages](../../user/project/pages/getting_started_part_four.md).
Although it's meant for users who want to write their own Pages
script from scratch, it does a good job introducing the setup of GitLab CI/CD.
It covers the very first general steps of writing a CI/CD configuration
file, so we recommend you read through it to understand GitLab's CI/CD
logic, and learn how to write your own script (or tweak an
existing one) for any application you wish to use GitLab CI/CD for.

### GitLab CI/CD feature set

- Easily set up your app's entire lifecycle with [Auto DevOps](../../topics/autodevops/index.md).
- Deploy static websites with [GitLab Pages](../../user/project/pages/index.md).
- Deploy your app to different [environments](../environments.md).
- Preview changes per merge request with [Review Apps](../review_apps/index.md).
- Develop secure and private Docker images with [Container Registry](../../user/project/container_registry.md).
- Install your own [GitLab Runner](https://docs.gitlab.com/runner/).
- [Schedule pipelines](../../user/project/pipelines/schedules.md).
- Check for app vulnerabilities with [Security Test reports](https://docs.gitlab.com/ee/user/project/merge_requests/#security-reports-ultimate). **[ULTIMATE]**

To see all CI/CD features, navigate back to the [CI/CD index](../README.md).
